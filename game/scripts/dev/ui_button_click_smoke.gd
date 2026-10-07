extends SceneTree

## Smoke: shop load nakon click-guard / typography promjena (headless).
## Autoloade uzima iz roota u _run(): identifikator GameState u --script testu
## kompajlira game_state.gd prije nego SceneRouter postoji (greske-katalog #21).

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _run() -> void:
	var gs := get_root().get_node_or_null("GameState")
	if gs == null or get_root().get_node_or_null("SceneRouter") == null:
		push_error("ui_button_click_smoke: GameState / SceneRouter autoload missing")
		_quit(1)
		return
	var shop_path := str(gs.get("SCENE_SHOP"))
	if not ResourceLoader.exists(shop_path):
		push_error("ui_button_click_smoke: shop path invalid")
		_quit(1)
		return
	var err := change_scene_to_file(shop_path)
	if err != OK:
		push_error("ui_button_click_smoke: shop load failed %d" % err)
		_quit(1)
		return
	for _i in 20:
		await process_frame
	var shop := current_scene
	if shop == null or not str(shop.scene_file_path).ends_with("shop_screen.tscn"):
		push_error("ui_button_click_smoke: wrong scene %s" % shop)
		_quit(1)
		return
	print("ui_button_click_smoke OK")
	_quit(0)
