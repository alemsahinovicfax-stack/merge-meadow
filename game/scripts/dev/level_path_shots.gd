extends SceneTree

## Dev: snimci Level Patha u igri (izvještaj paketa design_handoff_level_path). Pokretanje BEZ
## --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/level_path_shots.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/level_path_game/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
## Napredak kao u mocku paketa (§ Odlučeno 19): [level, uzete nagrade].
const PROG := {
	"country_bloom": [7, []], "frost_orchard": [3, []], "lantern_meadow": [11, [5]],
	"amber_canopy": [21, [5, 10, 15, 20]], "moonlit_warren": [15, [5, 10]],
	"coral_tide": [20, [5, 10, 15]], "starfall_glade": [1, []], "ember_fen": [9, [5]],
}
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


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
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
	_gs.set("last_daily_chest_day", "")
	_gs.set("level_path_hop", {})
	var d: LevelPathDomain = _gs.get("level_path_domain")
	d.reset()
	for id in PROG:
		d.set_level(id, int(PROG[id][0]))
		var list: Array[int] = []
		for n in PROG[id][1]:
			list.append(int(n))
		d.claimed[id] = list


func _open_field(id: String) -> void:
	_gs.call("set_active_season", id)
	_stage.set("_known_ready", false)
	_home.call("refresh_for_meta_hub")
	_hub.call("refresh_top_bar")
	_stage.call("show_season", id, false)
	await _frames(3)
	_stage.call("open_season_field", id, false)
	await _frames(4)
	_stage.get_node("%SeasonField").call("_stop_wander")


func _close_all() -> void:
	if bool(_stage.call("is_level_path_open")):
		_stage.call("close_level_path", false)
	_stage.call("close_season_field", false)
	await _frames(3)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("level_path_game")
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

	# kartica i polje s badgeom (CB: nagrada 5 čeka)
	_gs.call("set_active_season", "country_bloom")
	_stage.call("show_season", "country_bloom", false)
	await _frames(6)
	await _capture("g00_card_badge")
	await _open_field("country_bloom")
	await _frames(4)
	await _capture("g01_field_badge")
	# prelaz polje → put (sredina)
	_stage.call("open_level_path", true)
	await _wait(0.26)
	await _capture("g02_to_path_mid")
	await _wait(0.6)
	await _capture("g03_path_country_bloom")
	await _close_all()

	var i := 4
	for id in SEASONS:
		if id == "country_bloom":
			continue
		await _open_field(id)
		_stage.call("open_level_path", false)
		await _wait(0.3)
		await _capture("g%02d_path_%s" % [i, id])
		await _close_all()
		i += 1

	# zaključana nagrada (toast) i popup nagrade 5
	await _open_field("country_bloom")
	_stage.call("open_level_path", false)
	await _wait(0.2)
	var path = _stage.get("level_path")
	path.tap_reward(10)
	await _wait(0.25)
	await _capture("g11_locked_toast")
	await _wait(1.8)
	path.tap_reward(5)
	await _wait(0.45)
	await _capture("g12_reward_popup")
	path.get_popup().claim()
	await _wait(0.42)
	await _capture("g13_reward_fly")
	await _wait(1.0)
	await _capture("g14_reward_claimed")
	# skok 7 → 8 (sredina)
	(_gs.get("level_path_domain") as LevelPathDomain).set_level("country_bloom", 8)
	_gs.set("level_path_hop", {"season": "country_bloom", "from": 7, "to": 8})
	_stage.call("_restore_level_path")
	await _wait(0.5)
	await _capture("g15_hop_mid")
	await _wait(1.0)
	await _close_all()

	# nagrada 20 i complete (Coral: 20 → 21)
	await _open_field("coral_tide")
	(_gs.get("level_path_domain") as LevelPathDomain).set_level("coral_tide", 21)
	_gs.set("level_path_hop", {"season": "coral_tide", "from": 20, "to": 21})
	_stage.call("open_level_path", false)
	await _wait(2.0)
	await _capture("g16_complete")
	path.tap_reward(20)
	await _wait(0.5)
	await _capture("g17_reward20_popup")
	path.get_popup().claim()
	await _wait(1.6)
	await _close_all()

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
