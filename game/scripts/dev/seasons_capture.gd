extends SceneTree

## Dev: snima današnji izgled svih 8 sezona za seasons-cd-brief (seasons-ref/):
## Home kartica, polje sezone (svih 13 mjesta izraslo), Camp link kartica
## (Frost, Lantern, Amber) i run. Save se vraća na kraju.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/seasons_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/). $MM_PART=home|camp|run bira dio.
## $MM_SEASONS=country_bloom,moonlit_warren snima samo te sezone. Sezona s kitom
## (design_handoff_seasons) dobija i kadrove prelaza (u = 0,5 / 0,999) i Pipove poze.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const SEASONS: Array[String] = [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]
const FREE_NEXT: Array[String] = ["frost_orchard", "lantern_meadow", "amber_canopy"]
const PAID: Array[String] = ["moonlit_warren", "coral_tide", "starfall_glade"]

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	call_deferred("_run")


func _seasons() -> Array[String]:
	var only := OS.get_environment("MM_SEASONS")
	if only.is_empty():
		return SEASONS
	var out: Array[String] = []
	for id in only.split(","):
		if SEASONS.has(id.strip_edges()):
			out.append(id.strip_edges())
	return out


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _page(hub: Node, index: int) -> Node:
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	return host.get_node_or_null("Page_%d" % index)


func _clear_viewport() -> void:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)


func _new_hub(page: int) -> Node:
	await _clear_viewport()
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", page, false)
	await _frames(12)
	return hub


## Svih 13 mjesta polja traži najviše 10 ★3 po tipu — 12 za svaki tip svih sezona.
func _base_state() -> void:
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", 320)
	_gs.set("wallet_diamonds", 12)
	_gs.set("seed_bag", {"clover": 14, "daisy": 9, "buttercup": 5})
	var stash := {}
	for type_id in SeedCatalog.all_type_ids():
		stash[type_id] = 12
	_gs.set("garden_crystal_stash", stash)
	_gs.set("last_daily_chest_day", "")
	_gs.call("reset_seasons_to_s1")
	_gs.call("clear_owned_paid_seasons")


func _unlock_all() -> void:
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in FREE_NEXT:
		if not unlocked.has(id):
			unlocked.append(id)
	for id in PAID:
		_gs.call("grant_paid_season", id)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)

	# MM_PART=home|camp|run snima samo taj dio (prazno = sve).
	var part := OS.get_environment("MM_PART")
	if part.is_empty() or part == "home":
		await _home_shots()
	if part.is_empty() or part == "camp":
		await _camp_shots()
	if part.is_empty() or part == "run":
		await _run_shots()

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _home_shots() -> void:
	_base_state()
	_unlock_all()
	var hub := await _new_hub(MetaHubPages.MAIN)
	var home := _page(hub, MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.set("_known_ready", false)
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _frames(6)
	for id in _seasons():
		stage.call("show_season", id, false)
		await _frames(6)
		await _capture("home_card_%s" % id)
		if not bool(_gs.call("is_season_playable", id)):
			continue
		_gs.call("set_active_season", id)
		if not bool(stage.call("open_season_field", id, false)):
			continue
		await _frames(20)
		await _capture("home_field_%s" % id)
		await _wait(3.0)
		await _capture("home_field_%s_walked" % id)
		if UiSeasons.has_kit(id):
			await _kit_shots(stage, id)
		stage.call("close_season_field", false)
		await _frames(10)


## Prelaz kartica → polje (isti recept u rectu kartice) i Pipove poze na polju.
func _kit_shots(stage: Node, id: String) -> void:
	var field: Node = stage.get_node("%SeasonField")
	var pip: Node = field.get_node("MeadowPip")
	field.call("hold_pip")
	for u in [0.5, 0.999]:
		stage.call("_set_u", u)
		await _frames(3)
		await _capture("home_u%03d_%s" % [roundi(u * 1000.0), id])
	stage.call("_set_u", 1.0)
	await _frames(3)
	await _capture("home_u1000_%s" % id)
	stage.call("_release_pip")
	await _frames(3)
	field.call("_stop_wander")
	for pose in ["sniff", "sleep"]:
		pip.call("set_pose", pose, false, 1.0)
		await _wait(0.9)
		await _capture("home_pip_%s_%s" % [pose, id])
	var flowers: Array = field.call("_meadow_flowers")
	if not flowers.is_empty():
		flowers[0].call("play_sniff")
		await _wait(0.25)
		await _capture("home_bow_%s" % id)


## Link kartica pokazuje sljedeću zaključanu besplatnu sezonu.
func _camp_shots() -> void:
	for i in FREE_NEXT.size():
		_base_state()
		var unlocked: Array = _gs.get("unlocked_seasons")
		for j in i:
			unlocked.append(FREE_NEXT[j])
		var hub := await _new_hub(MetaHubPages.CAMP)
		var camp := _page(hub, MetaHubPages.CAMP)
		if camp and camp.has_method("refresh_for_meta_hub"):
			camp.call("refresh_for_meta_hub")
		await _frames(10)
		await _capture("camp_link_%s" % FREE_NEXT[i])


func _run_shots() -> void:
	_base_state()
	_unlock_all()
	for id in _seasons():
		await _clear_viewport()
		# Ember Fen je "coming soon" i ne može biti aktivna — run ga crta preko id-a.
		if not bool(_gs.call("set_active_season", id)):
			_gs.set("active_season_id", id)
		var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
		_svp.add_child(run)
		await _frames(40)
		await _wait(2.5)
		await _capture("run_%s" % id)
		await _wait(2.0)
		await _capture("run_%s_b" % id)
		# Prepreke i sjeme sezone u bočnim stazama (Pip je u srednjoj).
		var types: Array = SeedCatalog.types_for_season(id)
		run.call("_spawn_obstacle_at_lane", 0)
		run.call("_spawn_obstacle_at_lane", 2)
		await _wait(0.5)
		if types.size() >= 6:
			run.call("_spawn_guaranteed_seed", str(types[5]), 2)
			run.call("_spawn_guaranteed_seed", str(types[0]), 0)
		await _wait(1.1)
		await _capture("run_%s_obj" % id)
		run.queue_free()
		await _frames(4)
