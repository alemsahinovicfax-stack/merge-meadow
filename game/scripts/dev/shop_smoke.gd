extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop smoke: scene load failed %d" % err)
		quit(1)
		return
	for _i in 40:
		await process_frame
	var shop := current_scene
	if shop == null:
		push_error("shop smoke: no scene")
		quit(1)
		return
	for _i in 5:
		await process_frame
	print("shop smoke OK")
	quit(0)
