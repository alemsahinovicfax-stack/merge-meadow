extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var gs: Node = get_root().get_node_or_null("GameState")
	if gs:
		gs.call("mark_tutorial_complete")
		print("user_data_dir=", OS.get_user_data_dir())
	else:
		push_error("GameState autoload missing")
	quit()
