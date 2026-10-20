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
	var chips := {
		1: {"chip_id": 1, "type_id": "clover", "tier": 1, "pos": Vector2.ZERO},
		2: {"chip_id": 2, "type_id": "clover", "tier": 1, "pos": Vector2(8, 0)},
	}
	# --script ne vidi autoload kao globalni identifikator. Poziv ide preko root-a.
	var gs: Node = root.get_node("GameState")
	var merged: Dictionary = gs.call("try_merge_arena_chips", 1, 2, chips)
	if not bool(merged.get("ok", false)) or int(merged.get("new_tier", 0)) != 2:
		push_error("merge_arena_smoke: T1+T1 did not become T2")
		_quit(1)
		return
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	print("arena err=", err)
	for i in 8:
		await process_frame
	print("scene=", current_scene.name if current_scene else "null")
	if current_scene == null:
		push_error("merge_arena_smoke: arena scene did not load")
		_quit(1)
		return
	print("merge_arena_smoke OK")
	_quit(0)
