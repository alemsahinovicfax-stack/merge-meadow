extends SceneTree

## CAMP3-B / design_handoff_camp — Flowers tab: default ASC select, persist,
## next-type after deplete, rarity bg; isto Trade dugme kao Seeds.

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("camp_crystal_select_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := _gs()
	if camp == null or gs == null:
		_fail("camp/GameState missing")
		return
	for legacy in ["CrystalCard", "GardenCard", "CrystalExchangeButton", "CrystalScroll"]:
		if camp.get_node_or_null("%" + legacy) != null:
			_fail("legacy %s should be gone (one list, one Trade bar)" % legacy)
			return
	var grid := camp.get_node_or_null("%CrystalGrid") as GridContainer
	var scroll := camp.get_node_or_null("%StashScroll") as ScrollContainer
	if grid == null or scroll == null or not scroll.is_ancestor_of(grid):
		_fail("CrystalGrid must live in StashScroll")
		return

	gs.call("reset_seasons_to_s1")
	gs.set("garden_crystal_stash", {"clover": 2, "daisy": 1, "pumpkin": 1})
	gs.set("wallet_coins", 10)
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	camp.call("_on_tab_pressed", "flowers")
	for _j in 4:
		await process_frame
	if not grid.visible or (camp.get_node("%SeedBagGrid") as Control).visible:
		_fail("Flowers tab must show CrystalGrid only")
		return
	var flowers_tab := camp.get_node_or_null("%FlowersTab")
	if flowers_tab == null or not bool(flowers_tab.call("is_active")) or str(flowers_tab.call("get_count_text")) != "3":
		_fail("Flowers tab must be active and count 3 types")
		return
	if (camp.get_node("%MergeShortcut") as Control).visible:
		_fail("Merge shortcut belongs to the Seeds tab only")
		return
	if grid.get_child_count() < 3:
		_fail("CrystalGrid missing chips")
		return
	var first_chip: Node = grid.get_child(0)
	if str(first_chip.call("get_type_id")) != "daisy":
		_fail("ASC expected Field Daisy first got %s" % str(first_chip.call("get_type_id")))
		return
	var chip_err := CampSmokeUtil.chip_error(first_chip as Control, "flower")
	if not chip_err.is_empty():
		_fail(chip_err)
		return
	var exchange := camp.get_node_or_null("%ExchangeButton")
	if exchange == null or bool(exchange.get("disabled")):
		_fail("Trade should be enabled after default select")
		return
	if str(camp.get("_selected_crystal_type")) != "daisy":
		_fail("default select should be daisy")
		return
	var daisy_chip := _chip_by_type(grid, "daisy")
	var pumpkin_chip := _chip_by_type(grid, "pumpkin")
	if _chip_bg(daisy_chip).is_equal_approx(_chip_bg(pumpkin_chip)):
		_fail("star-1 daisy bg should differ from star-3 pumpkin")
		return
	# Frost Orchard trazi 20 Harvest Pumpkin — chip nosi badge i prije prodaje.
	if not bool(pumpkin_chip.call("is_reserved")) or str(pumpkin_chip.call("get_badge_text")) != "Kept · 1 / 20":
		_fail("pumpkin must show 'Kept · 1 / 20', got '%s'" % str(pumpkin_chip.call("get_badge_text")))
		return
	if bool(daisy_chip.call("is_reserved")):
		_fail("daisy is not reserved")
		return

	gs.set("garden_crystal_stash", {"clover": 2, "daisy": 1})
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	for _j2 in 4:
		await process_frame
	camp.call("_on_crystal_chip_pressed", "clover")
	await process_frame
	if str(camp.get("_selected_crystal_type")) != "clover":
		_fail("tap clover should select")
		return
	camp.call("_on_exchange_pressed")
	for _k in 4:
		await process_frame
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 1:
		_fail("clover expected 1 got %s" % str(stash.get("clover")))
		return
	var reward := int(gs.call("crystal_exchange_coins_for_type", "clover"))
	if int(gs.get("wallet_coins")) != 10 + reward:
		_fail("coins expected %d got %s" % [10 + reward, str(gs.get("wallet_coins"))])
		return
	if str(camp.get("_selected_crystal_type")) != "clover" or bool(exchange.get("disabled")):
		_fail("select should persist after exchange #1")
		return
	camp.call("_on_exchange_pressed")
	for _m in 4:
		await process_frame
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 0:
		_fail("clover expected 0 after #2")
		return
	if int(gs.get("wallet_coins")) != 10 + reward * 2:
		_fail("coins expected %d got %s" % [10 + reward * 2, str(gs.get("wallet_coins"))])
		return
	if str(camp.get("_selected_crystal_type")) != "daisy" or bool(exchange.get("disabled")):
		_fail("after clover deplete expected daisy with Trade enabled")
		return
	if int(stash.get("daisy", 0)) != 1:
		_fail("daisy leftover expected 1")
		return

	# Prazan stash: prazno stanje s CTA prema Areni, Trade bar ostaje.
	gs.set("garden_crystal_stash", {})
	camp.call("_refresh_crystal_card")
	await process_frame
	var empty := camp.get_node_or_null("%EmptyState") as Control
	var cta := camp.get_node_or_null("%EmptyCta")
	if empty == null or not empty.visible or scroll.visible:
		_fail("empty stash must show EmptyState instead of the grid")
		return
	if cta == null or str(cta.call("get_title")) != "Merge in Arena ↗":
		_fail("empty stash CTA should read 'Merge in Arena ↗'")
		return

	print("camp_crystal_select_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _chip_by_type(grid: GridContainer, type_id: String) -> Node:
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
