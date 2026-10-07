extends SceneTree

## F1/F2 — Loot To Camp ne smije odmah pokrenuti run (#8 regression).


var _backup: String = ""


func _gs() -> Node:
	return get_root().get_node("GameState")


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_step")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _step() -> void:
	await process_frame
	var gs := _gs()
	gs.call("begin_fresh_run")
	gs.call("finish_run", {"clover": 2}, 2, true, 10.0)
	change_scene_to_file("res://scenes/ui/loot_screen.tscn")
	await process_frame
	await process_frame
	gs.call("go_to_camp")
	for _i in 10:
		await process_frame
	var path := ""
	if current_scene:
		path = str(current_scene.scene_file_path)
	if path.contains("run_scene"):
		push_error("loot_camp_nav_smoke: landed on run (double-tap regression)")
		_quit(1)
		return
	if not path.contains("meta_hub"):
		push_error("loot_camp_nav_smoke: expected meta_hub, got %s" % path)
		_quit(1)
		return
	print("loot_camp_nav_smoke OK")
	_quit(0)
