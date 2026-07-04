extends SceneTree


func _initialize() -> void:
	_test()


func _test() -> void:
	await process_frame
	var err_main := change_scene_to_file("res://scenes/main_menu.tscn")
	print("main_menu err=", err_main)
	await process_frame
	await process_frame
	var err_run := change_scene_to_file("res://scenes/run/run_scene.tscn")
	print("run_scene err=", err_run)
	for _i in 10:
		await process_frame
	if current_scene:
		print("current=", current_scene.scene_file_path)
	else:
		print("current=null")
	quit()
