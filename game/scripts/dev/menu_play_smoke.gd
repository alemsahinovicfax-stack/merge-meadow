extends SceneTree

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_test")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _test() -> void:
	await process_frame
	for c in get_root().get_children():
		print("root child: ", c.name)
	change_scene_to_file("res://scenes/main_menu.tscn")
	for i in 5:
		await process_frame
	var router := get_root().get_node_or_null("SceneRouter")
	var gs := get_root().get_node_or_null("GameState")
	print("router=", router, " gs=", gs)
	var menu := current_scene
	var btn := menu.get_node("%PlayButton") if menu else null
	if btn and router and gs:
		gs.call("begin_campaign_run")
		router.call("change_to", gs.get("SCENE_RUN"))
		for i in 8:
			await process_frame
		print("scene=", current_scene.scene_file_path if current_scene else "null")
	_quit(0)
