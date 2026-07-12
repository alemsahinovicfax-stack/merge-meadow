extends SceneTree

func _initialize() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop smoke: scene load failed %d" % err)
		quit(1)
		return
	call_deferred("_step")


func _step() -> void:
	for _i in 3:
		await process_frame
	var shop := current_scene
	if shop == null:
		push_error("shop smoke: no scene")
		quit(1)
		return
	if shop.has_method("_refresh_ui"):
		shop._refresh_ui()
	for _i in 3:
		await process_frame
	print("shop smoke OK")
	quit(0)
