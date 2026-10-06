extends SceneTree

## MainMenu ima Play dugme, a kampanja iz Homea ucitava run scenu.

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_test")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _fail(msg: String) -> void:
	push_error("menu_play_smoke: " + msg)
	_quit(1)


func _test() -> void:
	await process_frame
	var router := get_root().get_node_or_null("SceneRouter")
	var gs := get_root().get_node_or_null("GameState")
	if router == null or gs == null:
		_fail("SceneRouter / GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)
	change_scene_to_file("res://scenes/main_menu.tscn")
	for i in 5:
		await process_frame
	var menu := current_scene
	# Home v3: jedno Play dugme zivi u SeasonStage-u — %PlayButton nije vidljiv iz MainMenu-a.
	var btn: Control = null
	if menu and menu.has_method("get_play_button"):
		btn = menu.call("get_play_button") as Control
	if btn == null:
		_fail("Play button missing on MainMenu")
		return
	gs.call("begin_campaign_run")
	router.call("change_to", gs.get("SCENE_RUN"))
	for i in 8:
		await process_frame
	var scene_path := current_scene.scene_file_path if current_scene else ""
	if scene_path != str(gs.get("SCENE_RUN")):
		_fail("run scene did not load (scene=%s)" % scene_path)
		return
	print("menu_play_smoke OK")
	_quit(0)
