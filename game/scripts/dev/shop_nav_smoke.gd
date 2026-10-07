extends SceneTree

## Smoke: main menu → Shop (SceneRouter), koristi autoload SceneTree.
## Putanje su literali: staticka referenca na GameState u --script smokeu je
## ranije vjesala proces (greske-katalog).

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _run() -> void:
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		push_error("shop_nav_smoke: main menu failed %d" % err)
		_quit(1)
		return
	for _i in 10:
		await process_frame
	var gs := root.get_node_or_null("GameState")
	if gs:
		gs.set("tutorial_complete", true)
	var router := root.get_node_or_null("SceneRouter")
	if router == null:
		push_error("shop_nav_smoke: SceneRouter missing")
		_quit(1)
		return
	router.call("change_to", "res://scenes/ui/shop_screen.tscn")
	for _i in 40:
		await process_frame
	var shop := current_scene
	if shop == null or not str(shop.scene_file_path).ends_with("shop_screen.tscn"):
		push_error("shop_nav_smoke: wrong scene %s" % shop)
		_quit(1)
		return
	print("shop_nav_smoke OK")
	_quit(0)
