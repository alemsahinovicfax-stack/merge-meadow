extends SceneTree

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop smoke: scene load failed %d" % err)
		_quit(1)
		return
	for _i in 40:
		await process_frame
	var shop := current_scene
	if shop == null:
		push_error("shop smoke: no scene")
		_quit(1)
		return
	for _i in 5:
		await process_frame
	print("shop smoke OK")
	_quit(0)
