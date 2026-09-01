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
		"GardenTitle",
		"BagLabel",
		"SeedBagGrid",
		"CrystalTitle",
		"CrystalGrid",
		"CrystalExchangeButton",
		"UpgradeButton",
		"MergeButton",
		"PlayButton",
		"HomeButton",
		"ResourceBar",
		"StatusToast",
	]
	for node_name in required:
		var node := camp.get_node_or_null("%" + node_name)
		if node == null:
			push_error("camp_layout_smoke: missing %%%s" % node_name)
			quit(1)
			return
	var garden_title := camp.get_node("%GardenTitle") as Label
	var crystal_title := camp.get_node("%CrystalTitle") as Label
	if garden_title == null or not garden_title.text.contains("Seeds"):
		push_error("camp_layout_smoke: GardenTitle should be Seeds")
		quit(1)
		return
	if crystal_title == null or not crystal_title.text.contains("Flowers"):
		push_error("camp_layout_smoke: CrystalTitle should be Flowers")
		quit(1)
		return
	if camp.get_node_or_null("%CompanionTitle") != null:
		push_error("camp_layout_smoke: CompanionTitle should be removed")
		quit(1)
		return
	if camp.get_node_or_null("%PipSlot") != null:
		push_error("camp_layout_smoke: PipSlot should be removed")
		quit(1)
		return
	var crystal_cliff := camp.get_node_or_null("%CrystalCliff") as CanvasItem
	if crystal_cliff != null and crystal_cliff.visible:
		push_error("camp_layout_smoke: CrystalCliff should be hidden")
		quit(1)
		return
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("camp_layout_smoke: GameState missing")
		quit(1)
		return
	gs.set("seed_bag", {"clover": 3, "daisy": 2})
	gs.set("sprinkler_donations", 1)
	gs.set("collection_journal_pending", {"clover": true})
	if camp.has_method("_refresh_ui"):
		camp.call("_refresh_ui", "x")
	elif camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	for _j in 4:
		await process_frame
	var toast := camp.get_node("%StatusToast") as CanvasItem
	if toast == null or toast.visible:
		push_error("camp_layout_smoke: StatusToast must stay hidden after _refresh_ui")
		quit(1)
		return
	var cliff := camp.get_node("%GardenCliff") as Label
	var cliff_text := cliff.text if cliff else ""
	if cliff_text.contains("New blooms in Journal") or cliff_text.contains("1 more T2"):
		push_error("camp_layout_smoke: GardenCliff still has journal/T2 tutorial: %s" % cliff_text)
		quit(1)
		return
	if camp.has_method("_garden_cliff_text"):
		var empty_cliff := str(camp.call("_garden_cliff_text", 0, 0))
		if empty_cliff.contains("New blooms in Journal") or empty_cliff.contains("1 more T2"):
			push_error(
				"camp_layout_smoke: _garden_cliff_text(0,0) still tutorial: %s" % empty_cliff
			)
			quit(1)
			return
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
