extends SceneTree


func _initialize() -> void:
	print("GameState exists=", get_root().has_node("GameState"))
	_test()


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	print("load menu err=", err)
	await process_frame
	await process_frame
	var menu := current_scene
	print("menu=", menu)
	if menu == null:
		quit()
		return
	var btn := menu.get_node_or_null("Panel/VBox/PlayButton")
	print("btn=", btn)
	if btn and btn.has_signal("clicked"):
		print("connections=", btn.get_signal_connection_list("clicked").size())
		btn.clicked.emit()
	await process_frame
	print("after emit=", current_scene.scene_file_path if current_scene else "null")
	var gs := get_root().get_node_or_null("GameState")
	print("gs=", gs)
	if gs:
		gs.call("go_to_scene", "res://scenes/run/run_scene.tscn")
	await process_frame
	await process_frame
	print("after direct=", current_scene.scene_file_path if current_scene else "null")
	quit()
