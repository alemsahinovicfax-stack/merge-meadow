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
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	print("arena err=", err)
	for i in 8:
		await process_frame
	print("scene=", current_scene.name if current_scene else "null")
	_quit(0)
