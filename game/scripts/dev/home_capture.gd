extends SceneTree

## Dev: renderuje hub u SubViewport 1080 x 1920 i snima PNG za stanja iz
## design_handoff_home_v3 (HomeScreen.dc.html §6.1) + kadrove prelaza (u 0 … 1)
## i zatvaranje s odsetanim Pipom. Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/home_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node
var _hub: Node
var _home: Node
var _stage: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	img.save_png(_out.path_join("godot_%s.png" % shot))
	print("captured ", shot)


func _refresh() -> void:
	_stage.set("_known_ready", false)
	_home.call("refresh_for_meta_hub")
	_hub.call("refresh_top_bar")


## Stanje iz mocka: otkljucane Country Bloom, Frost Orchard, Lantern Meadow;
## igra se Lantern; 320 coina, 14 ★3 Lanterna (Midnight Lotus).
func _base_state(coins: int = 320, stars: int = 14) -> void:
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("reset_seasons_to_s1")
	_gs.call("clear_owned_paid_seasons")
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow"]:
		unlocked.append(id)
	_gs.call("set_active_season", "lantern_meadow")
	_gs.call("set_free_strip_focus", "lantern_meadow")
	_gs.call("set_home_band", "free")
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", coins)
	_gs.set("seed_bag", {"dusk_firefly_grass": 112})
	_gs.set("garden_crystal_stash", {
		"midnight_lotus": stars, "dusk_firefly_grass": 7, "paper_lantern_bloom": 5,
		"foxfire_lily": 3, "glow_wisteria": 2,
	})
	_gs.set("discovered_blooms", {"dusk_firefly_grass": true, "midnight_lotus": true})
	_gs.set("last_daily_chest_day", "")


func _show(season_id: String) -> void:
	_stage.call("show_season", season_id, false)
	await _frames(4)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_base_state()

	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	_hub = (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(_hub)
	await _frames(30)
	_hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = _hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	_home = host.get_node("Page_%d" % MetaHubPages.MAIN)
	_stage = _home.get_node("%SeasonStage")
	_refresh()
	await _show("lantern_meadow")
	await _capture("free_active")

	await _show("frost_orchard")
	await _capture("free_open")

	await _show("amber_canopy")
	await _capture("free_locked")

	_base_state(1250, 20)
	_refresh()
	await _show("amber_canopy")
	await _capture("free_unlock")

	_base_state()
	var owned: Array = _gs.get("owned_paid_seasons")
	owned.append("coral_tide")
	_refresh()
	await _show("moonlit_warren")
	await _capture("premium_buy")
	await _show("coral_tide")
	await _capture("premium_owned")
	await _show("ember_fen")
	await _capture("premium_soon")

	# Prelaz: pravi tween, zaustavljen i vodjen rucno kroz u.
	_base_state()
	_refresh()
	await _show("lantern_meadow")
	_stage.call("open_season_field", "lantern_meadow")
	var tw: Tween = _stage.get("_field_tween")
	if tw:
		tw.pause()
	for i in 11:
		var u := float(i) / 10.0
		_stage.call("_set_u", u)
		await _frames(2)
		await _capture("open_%02d" % i)
	_stage.call("_set_u", 0.99)
	await _frames(2)
	await _capture("open_099")
	_stage.call("_set_u", 1.0)
	await _frames(2)
	await _capture("open_100")
	if tw:
		tw.kill()
	_stage.call("_on_field_tween_finished")
	if OS.get_environment("MM_FREEZE_PIP") == "1":
		_stage.get_node("%SeasonField").call("_stop_wander")
	await _frames(2)
	await _capture("open_done")
	await _frames(4)
	await _capture("field")
	await _wait(4.0)
	await _capture("field_walked")

	_stage.call("close_season_field")
	tw = _stage.get("_field_tween")
	if tw:
		tw.pause()
	for i in 11:
		var u := 1.0 - float(i) / 10.0
		_stage.call("_set_u", u)
		await _frames(2)
		await _capture("close_%02d" % i)
	if tw:
		tw.kill()
	_stage.call("_on_field_tween_finished")
	await _frames(4)
	await _capture("closed")

	# Prva sesija: tutorial hint oko Playa.
	_gs.call("reset_seasons_to_s1")
	_gs.set("tutorial_complete", false)
	_gs.set("discovered_blooms", {})
	_gs.set("garden_crystal_stash", {})
	_refresh()
	await _show("country_bloom")
	await _capture("first_session")

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
