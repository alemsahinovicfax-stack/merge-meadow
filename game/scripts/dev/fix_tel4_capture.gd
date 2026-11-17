extends SceneTree

## Dev: slike za FIX-TEL-4 (2026-11-14) — Level Path s 25 levela (svih 8 sezona, vrh / sredina /
## dno) i Boost dugmad u boji tiera. BEZ --headless, s APPDATA kopijom:
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/fix_tel4_capture.gd
## MM_SHOTS = "path", "boosts" ili prazno (sve). PNG ide u $MM_OUT (ili %TEMP%/mm_fix_tel4).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const SEASONS: Array[String] = [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]

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
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _open_field(id: String) -> void:
	_gs.call("set_active_season", id)
	_stage.set("_known_ready", false)
	_home.call("refresh_for_meta_hub")
	_hub.call("refresh_top_bar")
	_stage.call("show_season", id, false)
	await _frames(3)
	_stage.call("open_season_field", id, false)
	await _frames(4)


func _close_all() -> void:
	if bool(_stage.call("is_level_path_open")):
		_stage.call("close_level_path", false)
	_stage.call("close_season_field", false)
	await _frames(3)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_fix_tel4")
	DirAccess.make_dir_recursive_absolute(_out)
	var want := OS.get_environment("MM_SHOTS")
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("reset_seasons_to_s1")
	_gs.call("clear_owned_paid_seasons")
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		unlocked.append(id)
	var owned: Array = _gs.get("owned_paid_seasons")
	for id in ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]:
		owned.append(id)
	_gs.set("tutorial_complete", true)
	_gs.set("reduce_motion", true)
	_gs.set("wallet_coins", 8450)
	_gs.set("last_daily_chest_day", "")
	var d: LevelPathDomain = _gs.get("level_path_domain")
	d.reset()
	for id in SEASONS:
		d.set_level(id, 22)
		var list: Array[int] = [5, 10]
		d.claimed[id] = list
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

	if want.is_empty() or want == "path":
		for id in SEASONS:
			await _open_field(id)
			_stage.call("open_level_path", false)
			await _wait(0.4)
			var path = _stage.get("level_path")
			path.set_scroll(0.0)
			await _frames(4)
			await _capture("path_%s_top" % id)
			path.set_scroll(1000.0)
			await _frames(4)
			await _capture("path_%s_20" % id)
			if id == "country_bloom" or id == "ember_fen":
				path.set_scroll(2300.0)
				await _frames(4)
				await _capture("path_%s_mid" % id)
				path.set_scroll(LevelPathKit.scroll_max())
				await _frames(4)
				await _capture("path_%s_bottom" % id)
			if id == "country_bloom":
				path.set_scroll(1000.0)
				path.tap_reward(20)
				await _wait(0.6)
				await _capture("popup_20")
				path.get_popup().claim()
				await _wait(1.8)
				path.set_scroll(2300.0)
				path.tap_reward(15)
				await _wait(0.6)
				await _capture("popup_15")
				path.get_popup().claim()
				await _wait(1.8)
				d.set_level(id, 26)
				_stage.call("_restore_level_path")
				await _wait(0.5)
				path.set_scroll(0.0)
				await _frames(4)
				await _capture("path_complete")
				path.tap_reward(25)
				await _wait(0.6)
				await _capture("popup_25")
				path.get_popup().claim()
				await _wait(1.8)
			await _close_all()

	if want.is_empty() or want == "boosts":
		# Country Bloom: Magnet level 0 (prvi ljubičasti, može), Loot level 2 (zlatni, može),
		# Twin level 1 (drugi ljubičasti, nema cvijeća).
		var sid := "country_bloom"
		var stash: Dictionary = _gs.get("garden_crystal_stash")
		stash.clear()
		stash[str(_gs.call("season_flower_by_slot", sid, 0))] = 7
		stash[str(_gs.call("season_flower_by_slot", sid, 2))] = 12
		_gs.call("set_active_season", sid)
		_gs.set("magnet_level", 0)
		_gs.set("multiplier_level", 2)
		(_gs.call("_upgrade_row", sid) as Dictionary)["twin"] = 1
		await _open_field(sid)
		await _wait(0.6)
		var menu: Node = _home
		if not menu.has_method("_open_upgrades_sheet"):
			menu = _home.find_child("MainMenu", true, false)
		menu.call("_open_upgrades_sheet")
		await _wait(0.9)
		await _capture("boosts_a")
		menu.call("_close_upgrades_sheet")
		await _wait(0.4)
		# Sve tri bez dovoljno: level 3 (zlatni ×5, nema), level 1 bez coina.
		stash.clear()
		_gs.set("wallet_coins", 40)
		_gs.set("magnet_level", 3)
		_gs.set("multiplier_level", 0)
		stash[str(_gs.call("season_flower_by_slot", sid, 0))] = 9
		menu.call("_open_upgrades_sheet")
		await _wait(0.9)
		await _capture("boosts_b")
	print("fix_tel4_capture OK")
	quit(0)
