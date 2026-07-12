extends SceneTree

func _initialize() -> void:
	call_deferred("_test")


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	print("arena err=", err)
	for i in 8:
		await process_frame
	print("scene=", current_scene.name if current_scene else "null")
	quit(0)
