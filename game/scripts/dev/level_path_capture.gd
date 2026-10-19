extends SceneTree

## Dev: snima polje sezone na Homeu (stanje u kojem Play danas pokrece run) za
## reference briefa level-path-cd-brief. Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/level_path_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/level_path/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const SEASONS: Array[String] = [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]

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


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	img.save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _base_state() -> void:
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
	_gs.set("wallet_coins", 640)
	_gs.set("run_level", 7)
	_gs.set("last_daily_chest_day", "")


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("level_path")
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

	var i := 1
	for id in SEASONS:
		_gs.call("set_active_season", id)
		_stage.set("_known_ready", false)
		_home.call("refresh_for_meta_hub")
		_hub.call("refresh_top_bar")
		_stage.call("show_season", id, false)
		await _frames(4)
		if i == 1:
			await _capture("l00_card_%s" % id)
		_stage.call("open_season_field", id)
		var tw: Tween = _stage.get("_field_tween")
		if tw:
			tw.kill()
		_stage.call("_set_u", 1.0)
		_stage.call("_on_field_tween_finished")
		_stage.get_node("%SeasonField").call("_stop_wander")
		await _frames(6)
		await _capture("l%02d_field_%s" % [i, id])
		_stage.call("close_season_field")
		var tw2: Tween = _stage.get("_field_tween")
		if tw2:
			tw2.kill()
		_stage.call("_set_u", 0.0)
		_stage.call("_on_field_tween_finished")
		await _frames(4)
		i += 1

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
