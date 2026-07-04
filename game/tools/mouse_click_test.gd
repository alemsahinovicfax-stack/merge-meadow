extends SceneTree


func _initialize() -> void:
	_test()


func _test() -> void:
	await process_frame
	change_scene_to_file("res://scenes/main_menu.tscn")
	await process_frame
	await process_frame
	await process_frame

	var menu := current_scene
	var btn := menu.get_node("Panel/VBox/PlayButton")
	print("clicked_conns=", btn.get_signal_connection_list("clicked").size())
	print("pressed_conns=", btn.get_signal_connection_list("pressed").size())
	print("btn_rect=", btn.get_global_rect())

	var center: Vector2 = btn.get_global_rect().get_center()
	print("click_at=", center)

	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = center
	down.global_position = center
	menu.get_viewport().push_input(down)

	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = center
	up.global_position = center
	menu.get_viewport().push_input(up)

	await process_frame
	await process_frame
	print("after_push_input=", current_scene.scene_file_path if current_scene else "null")
	quit(0 if current_scene and "run" in current_scene.scene_file_path else 1)
