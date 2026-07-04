extends SceneTree


func _initialize() -> void:
	_test()


func _test() -> void:
	await process_frame
	print("emulate_touch=", Input.is_emulating_touch_from_mouse())
	change_scene_to_file("res://scenes/main_menu.tscn")
	await process_frame
	await process_frame
	await process_frame

	var menu := current_scene
	var btn := menu.get_node("Panel/VBox/PlayButton")
	var center: Vector2 = btn.get_global_rect().get_center()

	# Touch (kao emulate_touch_from_mouse=true)
	var touch_down := InputEventScreenTouch.new()
	touch_down.pressed = true
	touch_down.position = center
	menu.get_viewport().push_input(touch_down)
	var touch_up := InputEventScreenTouch.new()
	touch_up.pressed = false
	touch_up.position = center
	touch_up.index = 0
	menu.get_viewport().push_input(touch_up)
	await process_frame
	await process_frame
	print("after_touch=", current_scene.scene_file_path if current_scene else "null")

	# Mouse
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = center
	menu.get_viewport().push_input(down)
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = center
	menu.get_viewport().push_input(up)
	await process_frame
	await process_frame
	print("after_mouse=", current_scene.scene_file_path if current_scene else "null")
	quit()
