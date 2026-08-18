extends SceneTree

## Bug-008 / Garden seed grid — camp UniqueName + hub chrome + SeedBagGrid.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("camp_layout_smoke: camp scene load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	if camp == null or not str(camp.scene_file_path).ends_with("camp_scene.tscn"):
		push_error("camp_layout_smoke: wrong scene")
		quit(1)
		return
	var required: Array[String] = [
		"GardenCliff",
		"BagLabel",
		"SeedBagGrid",
		"CrystalGrid",
		"CrystalExchangeButton",
		"UpgradeButton",
		"MergeButton",
		"PlayButton",
		"HomeButton",
		"ResourceBar",
	]
	for node_name in required:
		var node := camp.get_node_or_null("%" + node_name)
		if node == null:
			push_error("camp_layout_smoke: missing %%%s" % node_name)
			quit(1)
			return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("camp_layout_smoke: GameState missing")
		quit(1)
		return
	gs.set("seed_bag", {"clover": 3, "daisy": 2})
	if camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	elif camp.has_method("_refresh_ui"):
		camp.call("_refresh_ui")
	for _j in 4:
		await process_frame
	var grid := camp.get_node("%SeedBagGrid") as GridContainer
	if grid == null or grid.get_child_count() < 2:
		push_error(
			"camp_layout_smoke: SeedBagGrid expected >=2 chips, got %d"
			% (grid.get_child_count() if grid else -1)
		)
		quit(1)
		return
	var home := camp.get_node("%HomeButton") as Control
	var settings := camp.get_node("%SettingsButton") as Control
	var collection := camp.get_node("%CollectionButton") as Control
	var wallet := camp.get_node("%ResourceBar") as Control
	if not home.visible:
		push_error("camp_layout_smoke: Home should be visible standalone")
		quit(1)
		return
	if camp.has_method("set_meta_hub_mode"):
		camp.call("set_meta_hub_mode", true)
	if home.visible or settings.visible or collection.visible or wallet.visible:
		push_error("camp_layout_smoke: hub chrome still visible after set_meta_hub_mode")
		quit(1)
		return
	print("camp_layout_smoke OK")
	quit(0)
