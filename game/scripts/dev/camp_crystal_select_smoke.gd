extends SceneTree

## CAMP3-B — default ASC select, persist, next-type after deplete, rarity bg.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("camp_crystal_select_smoke: camp load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := _gs()
	if camp == null or gs == null:
		push_error("camp_crystal_select_smoke: camp/GameState missing")
		quit(1)
		return
	if camp.get_node_or_null("RootVBox/MainScroll/ContentMargin/Content/GardenCard/GardenVBox/CrystalRow") != null:
		push_error("camp_crystal_select_smoke: CrystalRow still inside GardenCard")
		quit(1)
		return
	var crystal_card := camp.get_node_or_null("RootVBox/MainScroll/ContentMargin/Content/CrystalCard")
	if crystal_card == null:
		push_error("camp_crystal_select_smoke: CrystalCard missing")
		quit(1)
		return
	var seed_scroll := camp.get_node_or_null(
		"RootVBox/MainScroll/ContentMargin/Content/GardenCard/GardenVBox/SeedBagScroll"
	)
	if seed_scroll == null:
		push_error("camp_crystal_select_smoke: SeedBagScroll missing (layout parity)")
		quit(1)
		return
	var seed_grid_path := camp.get_node_or_null(
		"RootVBox/MainScroll/ContentMargin/Content/GardenCard/GardenVBox/SeedBagScroll/SeedBagGrid"
	)
	if seed_grid_path == null:
		push_error("camp_crystal_select_smoke: SeedBagGrid not under SeedBagScroll")
		quit(1)
		return
	gs.set("garden_crystal_stash", {"clover": 2, "daisy": 1, "pumpkin": 1})
	gs.set("wallet_coins", 10)
	camp.set("_force_default_crystal_select", true)
	if camp.has_method("_refresh_crystal_card"):
		camp.call("_refresh_crystal_card")
	elif camp.has_method("_refresh_ui"):
		camp.call("_refresh_ui")
	for _j in 4:
		await process_frame
	var grid := camp.get_node_or_null("%CrystalGrid") as GridContainer
	if grid == null or grid.get_child_count() < 3:
		push_error("camp_crystal_select_smoke: CrystalGrid missing chips")
		quit(1)
		return
	var first_chip: Node = grid.get_child(0)
	var first_id := str(first_chip.call("get_type_id")) if first_chip.has_method("get_type_id") else ""
	if first_id != "daisy":
		push_error("camp_crystal_select_smoke: ASC expected Field Daisy first got %s" % first_id)
		quit(1)
		return
	var chip_err := _assert_chip_stack(first_chip as Control, "flower")
	if not chip_err.is_empty():
		push_error("camp_crystal_select_smoke: %s" % chip_err)
		quit(1)
		return
	var exchange := camp.get_node_or_null("%CrystalExchangeButton")
	if exchange == null:
		push_error("camp_crystal_select_smoke: CrystalExchangeButton missing")
		quit(1)
		return
	var selected := str(camp.get("_selected_crystal_type"))
	if selected != "daisy":
		push_error("camp_crystal_select_smoke: default select should be daisy got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should be enabled after default select")
		quit(1)
		return
	var daisy_chip := _chip_by_type(grid, "daisy")
	var pumpkin_chip := _chip_by_type(grid, "pumpkin")
	var daisy_bg := _chip_bg(daisy_chip)
	var pumpkin_bg := _chip_bg(pumpkin_chip)
	if daisy_bg.is_equal_approx(pumpkin_bg):
		push_error("camp_crystal_select_smoke: star-1 daisy bg should differ from star-3 pumpkin")
		quit(1)
		return
	gs.set("garden_crystal_stash", {"clover": 2, "daisy": 1})
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	for _j2 in 4:
		await process_frame
	if camp.has_method("_on_crystal_chip_pressed"):
		camp.call("_on_crystal_chip_pressed", "clover")
	await process_frame
	selected = str(camp.get("_selected_crystal_type"))
	if selected != "clover":
		push_error("camp_crystal_select_smoke: tap clover should select got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should be enabled for clover")
		quit(1)
		return
	if camp.has_method("_on_crystal_exchange_pressed"):
		camp.call("_on_crystal_exchange_pressed")
	for _k in 4:
		await process_frame
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 1:
		push_error("camp_crystal_select_smoke: clover expected 1 got %s" % str(stash.get("clover")))
		quit(1)
		return
	var reward := int(gs.call("crystal_exchange_coins_for_type", "clover"))
	if int(gs.get("wallet_coins")) != 10 + reward:
		push_error(
			"camp_crystal_select_smoke: coins expected %d got %s"
			% [10 + reward, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_crystal_type"))
	if selected != "clover":
		push_error("camp_crystal_select_smoke: select should persist after exchange #1 got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should stay enabled after #1")
		quit(1)
		return
	camp.call("_on_crystal_exchange_pressed")
	for _m in 4:
		await process_frame
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 0:
		push_error("camp_crystal_select_smoke: clover expected 0 after #2 got %s" % str(stash.get("clover")))
		quit(1)
		return
	if int(gs.get("wallet_coins")) != 10 + reward * 2:
		push_error(
			"camp_crystal_select_smoke: coins expected %d got %s"
			% [10 + reward * 2, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_crystal_type"))
	if selected != "daisy":
		push_error("camp_crystal_select_smoke: after clover deplete expected daisy got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: leftover daisy should keep Exchange enabled")
		quit(1)
		return
	if int(stash.get("daisy", 0)) != 1:
		push_error("camp_crystal_select_smoke: daisy leftover expected 1 got %s" % str(stash.get("daisy")))
		quit(1)
		return
	print("camp_crystal_select_smoke OK")
	quit(0)


func _chip_by_type(grid: GridContainer, type_id: String) -> Node:
	if grid == null:
		return null
	for child in grid.get_children():
		if child.has_method("get_type_id") and str(child.call("get_type_id")) == type_id:
			return child
	return null


func _chip_bg(chip: Node) -> Color:
	if chip == null or not (chip is Control):
		return Color.BLACK
	var sb := (chip as Control).get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		return (sb as StyleBoxFlat).bg_color
	return Color.BLACK


func _assert_chip_stack(chip: Control, kind: String) -> String:
	if chip == null:
		return "%s chip missing" % kind
	var min_h := chip.custom_minimum_size.y
	if min_h < 90.0 or min_h > 120.0:
		return "%s chip min_h %s" % [kind, str(min_h)]
	var icon := chip.find_child("PlantIcon", true, false) as Control
	if icon == null or icon.custom_minimum_size.x < 76.0:
		return "%s icon too small" % kind
	var name_lab := chip.find_child("NameLabel", true, false) as Label
	if name_lab == null:
		return "%s NameLabel missing" % kind
	if name_lab.text.find("★") >= 0:
		return "%s name must not include stars, got '%s'" % [kind, name_lab.text]
	var want_stars := clampi(int(chip.get("_rarity")), 0, 3)
	var stars := chip.find_child("StarsRow", true, false) as HBoxContainer
	if stars == null or stars.get_child_count() != want_stars:
		return "%s StarsRow must have %d filled stars" % [kind, want_stars]
	var count_lab := chip.find_child("CountLabel", true, false) as Control
	var pill := chip.find_child("PricePill", true, false) as Control
	if count_lab == null or pill == null:
		return "%s count/pill missing" % kind
	if name_lab.global_position.x <= icon.global_position.x:
		return "%s name must sit right of icon" % kind
	if count_lab.global_position.x <= icon.global_position.x:
		return "%s count must sit right of icon" % kind
	if pill.global_position.x <= count_lab.global_position.x:
		return "%s pill must sit right of count" % kind
	return ""
