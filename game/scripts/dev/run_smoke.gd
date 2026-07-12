extends SceneTree

func _initialize() -> void:
	call_deferred("_test")


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	print("run load err=", err)
	await process_frame
	await process_frame
	var run := current_scene
	print("run scene=", run.name if run else "null")
	if run and run.has_method("start_run"):
		print("run controller ok")
	quit(0)
