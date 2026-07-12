extends SceneTree

## Smoke: main menu → Shop (SceneRouter), koristi autoload SceneTree.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		push_error("shop_nav_smoke: main menu failed %d" % err)
		quit(1)
		return
	for _i in 10:
		await process_frame
	var gs := root.get_node_or_null("GameState")
	if gs:
		gs.tutorial_complete = true
	var router := root.get_node_or_null("SceneRouter")
	if router == null:
		push_error("shop_nav_smoke: SceneRouter missing")
		quit(1)
		return
	router.change_to(GameState.SCENE_SHOP)
	for _i in 40:
		await process_frame
	var shop := current_scene
	if shop == null or not str(shop.scene_file_path).ends_with("shop_screen.tscn"):
		push_error("shop_nav_smoke: wrong scene %s" % shop)
		quit(1)
		return
	print("shop_nav_smoke OK")
	quit(0)
