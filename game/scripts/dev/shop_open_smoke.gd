extends SceneTree

## Smoke: load shop once (autoloads via project.godot).

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop_open_smoke: shop failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	print("shop_open_smoke OK")
	quit(0)
