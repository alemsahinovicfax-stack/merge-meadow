extends SceneTree

## Dev: snimke za izvještaj prenosa design_handoff_leveli_endless (2026-10-22) — najava levela,
## pojas u LevelChipu i par, cilj (vozi / prolaz), Endless HUD (nova stepenica, novi rekord), pauza,
## kraj Endlessa (rekord / bez), Endless dugme (zaključano + toast, otvoreno + rekord, trenutak
## otključavanja), Level Path (pločice, zastavice, spreman sanduk). Pip neranjiv, vrijeme ubrzano.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/levels_endless_capture.gd
## JPG ide u $MM_OUT (ili %TEMP%/mm_design/levels_endless/). Save se vraća na kraju.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const FAST := 6.0

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_jpg(_out.path_join("%s.jpg" % shot), 0.86)
	print("captured ", shot)


func _clear() -> void:
	Engine.time_scale = 1.0
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)


func _start_run(season: String, level: int) -> Node:
	await _clear()
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", season)
	if level == 0:
		_gs.call("begin_endless_run")
	else:
		_gs.set("run_level", level)
		_gs.call("begin_campaign_run")
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(2)
	var player := run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	return run


## Ubrzano do `sec` igre.
func _fast_to(run: Node, sec: float) -> void:
	Engine.time_scale = FAST
	while is_instance_valid(run) and float(run.get("elapsed")) < sec and int(run.get("_state")) == 0:
		await process_frame
	Engine.time_scale = 1.0


func _has_pair(run: Node) -> bool:
	for c in run.get_node("World").get_children():
		if c.is_in_group("obstacle") and str(c.get("pair_kind")) == "wide" and c.position.y > 300.0 and c.position.y < 1200.0:
			return true
	return false


func _run_shots() -> void:
	# A2 · najava (Frost Orchard, level 14 = Dash) usred ulaska, pa usred leta u čip.
	var run := await _start_run("frost_orchard", 14)
	await create_timer(0.42).timeout
	await _capture("l01_intro_level14_frost")
	await create_timer(0.5).timeout
	await _capture("l02_intro_fly_level14_frost")
	# A1 + A4 · level 20 (Sprint ★): pločica u čipu i par kao jedan predmet.
	run = await _start_run("lantern_meadow", 20)
	await _fast_to(run, 55.0)
	Engine.time_scale = FAST
	var stop_at := float(run.get("elapsed")) + 40.0
	while is_instance_valid(run) and not _has_pair(run) and float(run.get("elapsed")) < stop_at:
		await process_frame
	Engine.time_scale = 1.0
	run.set("_state", 2)
	await _frames(3)
	await _capture("l03_level20_pair_lantern")
	# A6 · cilj vozi (Frost Orchard, level 6), pa prolaz.
	run = await _start_run("frost_orchard", 6)
	var dur := float(_gs.call("get_run_duration"))
	run.set("elapsed", dur - 6.0)
	await _fast_to(run, dur - 1.4)
	run.set("_state", 2)
	await _frames(3)
	await _capture("l04_gate_riding_frost")
	run.set("_state", 0)
	while is_instance_valid(run) and int(run.get("_state")) == 0:
		await process_frame
	await create_timer(0.32).timeout
	await _capture("l05_gate_pass_frost")
	await create_timer(0.6).timeout
	_gs.set("level_path_hop", {})
	# B3/B4 · Endless 3:00 — nova stepenica (Pace 9) + nalet.
	var lp = _gs.get("level_path_domain")
	lp.set_level("amber_canopy", 16)
	lp.endless_best["amber_canopy"] = 265.0
	run = await _start_run("amber_canopy", 0)
	run.set("elapsed", 176.0)
	await _fast_to(run, 179.6)
	run.set("elapsed", 179.95)
	await create_timer(0.3).timeout
	run.set("_state", 2)
	await _capture("l06_endless_pace_amber")
	run.set("_state", 0)
	# B5 · novi rekord (rekord sezone 4:25).
	run.set("elapsed", 264.6)
	await create_timer(0.62).timeout
	run.set("_state", 2)
	await _capture("l07_endless_new_best_amber")
	await create_timer(1.0).timeout
	await _capture("l08_endless_hud_after_best_amber")
	# B7 · pauza.
	run.set("_state", 0)
	run.call("_on_pause_pressed")
	await create_timer(0.5).timeout
	await _capture("l09_endless_pause_amber")


func _loot_shots() -> void:
	await _clear()
	var lp = _gs.get("level_path_domain")
	_gs.call("set_active_season", "amber_canopy")
	lp.endless_best["amber_canopy"] = 265.0
	_gs.set("run_is_endless", true)
	_gs.call("finish_run", {"copper_leaf": 14, "cider_dahlia": 9, "amber_magnolia": 3}, 151, true, 420.0)
	var loot := (load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(loot)
	await create_timer(1.4).timeout
	await _capture("l10_loot_endless_new_best")
	await _clear()
	_gs.set("run_is_endless", true)
	_gs.call("finish_run", {"copper_leaf": 7, "cider_dahlia": 4, "amber_magnolia": 1}, 95, true, 265.0 - 31.0)
	loot = (load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(loot)
	await create_timer(1.4).timeout
	await _capture("l11_loot_endless")
	_gs.set("run_is_endless", false)


## Hub s otvorenim poljem sezone `id`; vraća [hub, home, stage].
func _open_field(id: String) -> Array:
	await _clear()
	_gs.call("set_active_season", id)
	_gs.set("level_path_hop", {})
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.set("_known_ready", false)
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	stage.call("show_season", id, false)
	await _frames(4)
	stage.call("open_season_field", id)
	var tw: Tween = stage.get("_field_tween")
	if tw:
		tw.kill()
	stage.call("_set_u", 1.0)
	stage.call("_on_field_tween_finished")
	stage.get_node("%SeasonField").call("_stop_wander")
	await _frames(6)
	return [hub, home, stage]


func _home_shots() -> void:
	var lp = _gs.get("level_path_domain")
	# B1 · zaključan (Pip na 9 = 8 / 15) + tap → toast.
	lp.set_level("country_bloom", 9)
	lp.claimed["country_bloom"] = [5]
	var f: Array = await _open_field("country_bloom")
	var home: Node = f[1]
	var stage: Node = f[2]
	await _capture("l12_field_endless_locked")
	home.call("_on_endless_play_pressed")
	await create_timer(0.4).timeout
	await _capture("l13_field_endless_locked_toast")
	# Level Path: pločice + zastavice (Pip na 9).
	await create_timer(2.0).timeout
	stage.call("_on_play_pressed")
	await create_timer(1.0).timeout
	await _capture("l14_path_bands_country")
	# C · spreman sanduk 10 (Pip na 12).
	lp.set_level("country_bloom", 12)
	lp.claimed["country_bloom"] = [5]
	f = await _open_field("country_bloom")
	stage = f[2]
	stage.call("_on_play_pressed")
	await create_timer(1.0).timeout
	var view: Node = stage.get("level_path")
	if view:
		view.call("set_scroll", float(LevelPathKit.chest(10)["pos"].y) - 900.0)
	await create_timer(0.2).timeout
	await _capture("l15_path_chest_ready_country")
	await create_timer(0.4).timeout
	await _capture("l16_path_chest_ready_country_b")
	# B2 · trenutak otključavanja (Lantern Meadow, skok 15 → 16).
	lp.set_level("lantern_meadow", 16)
	lp.endless_seen.erase("lantern_meadow")
	f = await _open_field("lantern_meadow")
	stage = f[2]
	_gs.set("level_path_hop", {"season": "lantern_meadow", "from": 15, "to": 16})
	stage.call("_on_play_pressed")
	var t0 := Time.get_ticks_msec()
	var face: Node = (f[1] as Node).get("endless_face")
	while Time.get_ticks_msec() - t0 < 6000 and (face == null or not bool(face.call("is_animating"))):
		await process_frame
	await create_timer(UiLevels.UNLOCK_DELAY + 0.42).timeout
	await _capture("l17_unlock_flip_lantern")
	await create_timer(0.6).timeout
	await _capture("l18_unlock_bubble_lantern")
	# B8 · otvoren + rekord sezone na polju.
	lp.endless_best["lantern_meadow"] = 192.0
	f = await _open_field("lantern_meadow")
	await _capture("l19_field_endless_best_lantern")


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("levels_endless")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.set("reduce_motion", false)
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	await _run_shots()
	await _loot_shots()
	await _home_shots()
	await _clear()
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
