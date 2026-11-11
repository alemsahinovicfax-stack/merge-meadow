extends SceneTree

## Dev: slike svih stranica huba u stvarnom prozoru (omjer telefona / tableta) — FIX-TEL.
## Za razliku od store_capture (SubViewport 1080 x 1920), ovdje se slika root viewport, pa se
## vidi šta radi aspect expand / keep na visokom i širokom ekranu.
## Pokretanje BEZ --headless, s APPDATA kopijom (scripts/screen-matrix.ps1):
##   godot --path game --rendering-driver opengl3 --resolution 405x900 -s res://scripts/dev/screen_matrix_capture.gd
## PNG ide u $MM_OUT/<MM_TAG>_<stranica>.png.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const NAMES := ["shop", "journal", "home", "camp", "arena"]

var _out := ""
var _tag := ""
var _gs: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _shot(shot: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_out.path_join("%s_%s.png" % [_tag, shot]))
	print("captured ", shot, " viewport ", root.get_visible_rect().size)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_matrix")
	DirAccess.make_dir_recursive_absolute(_out)
	_tag = OS.get_environment("MM_TAG")
	if _tag.is_empty():
		var ws := root.size
		_tag = "%dx%d" % [ws.x, ws.y]
	_gs = root.get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("reduce_motion", false)
	_gs.set("wallet_coins", 8450)
	_gs.set("seed_bag", {"clover": 18, "daisy": 16, "buttercup": 12, "tulip": 14, "sunflower": 10})
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await create_timer(2.5).timeout
	var hub: Node = current_scene
	for i in [MetaHubPages.MAIN, MetaHubPages.CAMP, MetaHubPages.ARENA, MetaHubPages.COLLECTION, MetaHubPages.SHOP]:
		hub.call("go_to_page", i, false)
		await create_timer(1.6).timeout
		await _shot(NAMES[i])
	# Home → polje sezone → Level Path.
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await create_timer(0.8).timeout
	var page: Node = hub.find_child("Page_%d" % MetaHubPages.MAIN, true, false)
	var stage: Node = page.get_node_or_null("%SeasonStage") if page else null
	if stage != null:
		var sid := str(_gs.get("active_season_id"))
		stage.call("open_season_field", sid)
		var tw: Tween = stage.get("_field_tween")
		if tw:
			tw.kill()
		stage.call("_set_u", 1.0)
		stage.call("_on_field_tween_finished")
		await create_timer(1.4).timeout
		await _shot("home_field")
		stage.call("_on_play_pressed")
		await create_timer(1.6).timeout
		await _shot("level_path")
	print("screen_matrix_capture OK")
	quit(0)
