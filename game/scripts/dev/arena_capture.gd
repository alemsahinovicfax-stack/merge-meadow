extends SceneTree

## Dev: renderuje Arenu v2 u SubViewport 1080 x 1633 i snima PNG — svih 8 livada (nivo 0 i 4)
## s korpom, sjemenkama i muncherom, plus combo i stanja munchera. Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/arena_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const SAVE_PATH := "user://player_save.json"
const SEASONS := [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node
var _arena: Control


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	img.save_png(_out.path_join("arena_%s.png" % shot))
	print("captured ", shot)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	if FileAccess.file_exists(SAVE_PATH):
		_backup = FileAccess.get_file_as_string(SAVE_PATH)
	_gs = get_root().get_node("GameState")
	_gs.set("tutorial_complete", true)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1633)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	_arena = load("res://scenes/camp/merge_arena.tscn").instantiate()
	_svp.add_child(_arena)
	await _frames(6)
	var bg := _arena.get_node("Bg")
	var pest := _arena.get_node("RootVBox/Playfield/MuncherPest")
	_gs.set("seed_bag", {"clover": 16, "daisy": 12, "buttercup": 10, "tulip": 12})
	_arena.call("_on_bag_clicked")
	await _frames(40)
	for id in SEASONS:
		_arena.set("_session_open", false)
		bg.call("set_season", id)
		for level in [0, 4]:
			bg.call("set_t3_level", float(level), false)
			await _frames(3)
			await _capture("%s_l%d" % [id, level])
	bg.call("set_season", "country_bloom")
	bg.call("set_t3_level", 1.0, false)
	for _i in 5:
		_arena.call("register_arena_combo_merge", Vector2(540, 760))
	await _frames(6)
	await _capture("combo5")
	pest.call("on_t3_created")
	await _frames(20)
	await _capture("muncher_frozen")
	await create_timer(2.6).timeout
	await _capture("muncher_hunt")
	if _backup.is_empty():
		DirAccess.remove_absolute(SAVE_PATH)
	else:
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		f.store_string(_backup)
	quit(0)
