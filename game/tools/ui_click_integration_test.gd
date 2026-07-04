extends SceneTree

const LOG := "res://tools/ui_click_test_log.txt"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var log := []
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	log.append("load_main_err=%d" % err)
	await process_frame
	await process_frame
	await process_frame

	var root := current_scene
	if root == null:
		log.append("FAIL no scene")
		_write_log(log)
		quit(1)
		return

	var play := root.get_node_or_null("Panel/VBox/PlayButton")
	log.append("play_exists=%s" % (play != null))
	if play == null:
		_write_log(log)
		quit(1)
		return

	log.append("play_script=%s" % play.get_script())
	log.append("clicked_conns=%d" % play.get_signal_connection_list("clicked").size())
	log.append("pressed_conns=%d" % play.get_signal_connection_list("pressed").size())

	var center: Vector2 = play.global_position + play.size * 0.5
	log.append("play_rect=%s global_center=%s" % [play.get_rect(), center])

	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = center
	down.global_position = center
	root.get_viewport().push_input(down)

	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = center
	up.global_position = center
	root.get_viewport().push_input(up)

	await process_frame
	await process_frame

	var after := current_scene
	log.append("scene_after_click=%s" % (after.name if after else "null"))

	_write_log(log)
	quit(0 if after and after.name != "MainMenu" else 1)


func _write_log(lines: Array) -> void:
	var f := FileAccess.open(LOG, FileAccess.WRITE)
	for line in lines:
		f.store_line(str(line))
	f.close()
