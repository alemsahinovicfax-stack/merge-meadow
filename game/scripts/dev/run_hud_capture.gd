extends SceneTree

## Dev: snima današnji HUD runa za run-hud-cd-brief (run-hud-ref/): level mod, Endless,
## tutorial run, i Starfall Glade (tamna). Save se vraća na kraju (CampSmokeUtil).
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_hud_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

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
	_svp.get_texture().get_image().save_png(_out.path_join("runhud_%s.png" % shot))
	print("captured ", shot)


func _shot(name: String, season: String, setup: Callable) -> void:
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)
	_gs.set("active_season_id", season)
	setup.call()
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	await create_timer(3.0).timeout
	await _capture(name)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	await _shot("01_level_country_bloom", "country_bloom", func() -> void:
		_gs.set("tutorial_complete", true)
		_gs.call("begin_campaign_run"))
	await _shot("02_endless_country_bloom", "country_bloom", func() -> void:
		_gs.set("tutorial_complete", true)
		_gs.call("begin_endless_run", 1))
	await _shot("03_level_starfall_glade", "starfall_glade", func() -> void:
		_gs.set("tutorial_complete", true)
		_gs.call("begin_campaign_run"))
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
