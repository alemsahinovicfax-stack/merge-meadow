extends SceneTree

## Smoke: shop load nakon click-guard / typography promjena (headless).

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ResourceLoader.exists(GameState.SCENE_SHOP):
		push_error("ui_button_click_smoke: shop path invalid")
		quit(1)
		return
	var err := change_scene_to_file(GameState.SCENE_SHOP)
	if err != OK:
		push_error("ui_button_click_smoke: shop load failed %d" % err)
		quit(1)
		return
	for _i in 20:
		await process_frame
	var shop := current_scene
	if shop == null or not str(shop.scene_file_path).ends_with("shop_screen.tscn"):
		push_error("ui_button_click_smoke: wrong scene %s" % shop)
		quit(1)
		return
	print("ui_button_click_smoke OK")
	quit(0)
