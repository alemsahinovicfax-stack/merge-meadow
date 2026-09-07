extends SceneTree

## Bug-025 — ASC grid, default TL select, leftover 1–2 tradeable.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("camp_trade_select_smoke: camp load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := _gs()
	if camp == null or gs == null:
		push_error("camp_trade_select_smoke: camp/GameState missing")
		quit(1)
		return

	# clover ★1, tulip ★2 — ASC puts clover first.
	gs.set("seed_bag", {"tulip": 3, "clover": 8, "daisy": 2})
	gs.set("wallet_coins", 10)
	camp.set("_force_default_trade_select", true)
	if camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	for _j in 4:
		await process_frame

	var grid := camp.get_node_or_null("%SeedBagGrid") as GridContainer
	if grid == null or grid.get_child_count() < 3:
		push_error("camp_trade_select_smoke: SeedBagGrid missing chips")
		quit(1)
		return
	var first_chip: Node = grid.get_child(0)
	var first_id := str(first_chip.call("get_type_id")) if first_chip.has_method("get_type_id") else ""
	if first_id != "daisy":
		push_error("camp_trade_select_smoke: ASC expected Field Daisy first got %s" % first_id)
		quit(1)
		return
	var chip_err := _assert_chip_stack(first_chip as Control, "seed")
	if not chip_err.is_empty():
		push_error("camp_trade_select_smoke: %s" % chip_err)
		quit(1)
		return

	var selected := str(camp.get("_selected_trade_type"))
	if selected != "daisy":
		push_error("camp_trade_select_smoke: default select should be daisy got %s" % selected)
		quit(1)
		return

	# Daisy (2) can select and trade leftover.
	if camp.has_method("_on_seed_chip_pressed"):
		camp.call("_on_seed_chip_pressed", "daisy")
	await process_frame
	selected = str(camp.get("_selected_trade_type"))
	if selected != "daisy":
		push_error("camp_trade_select_smoke: daisy (2) should select got %s" % selected)
		quit(1)
		return
	var exchange := camp.get_node_or_null("%ExchangeButton")
	if exchange and bool(exchange.get("disabled")):
		push_error("camp_trade_select_smoke: Trade should enable for daisy leftover")
		quit(1)
		return
	var coins_before := int(gs.get("wallet_coins"))
	var leftover_coins := int(gs.call("seed_exchange_coins_for_take", 2, "daisy"))
	if leftover_coins != 2:
		push_error("camp_trade_select_smoke: expected 2 coins for take=2 daisy got %d" % leftover_coins)
		quit(1)
		return
	camp.call("_on_exchange_pressed")
	for _k in 4:
		await process_frame
	var bag: Dictionary = gs.get("seed_bag")
	if int(bag.get("daisy", 0)) != 0:
		push_error("camp_trade_select_smoke: daisy should be 0 after leftover trade")
		quit(1)
		return
	if int(gs.get("wallet_coins")) != coins_before + leftover_coins:
		push_error(
			"camp_trade_select_smoke: coins after daisy trade expected %d got %s"
			% [coins_before + leftover_coins, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	# After daisy depletes, next in ASC order is clover (Meadow Clover).
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		push_error(
			"camp_trade_select_smoke: after daisy deplete expected clover got %s" % selected
		)
		quit(1)
		return

	# Batch trade clover 8 → 5 → 2; leftover 2 still tradeable.
	camp.call("_on_seed_chip_pressed", "clover")
	await process_frame
	coins_before = int(gs.get("wallet_coins"))
	var batch := int(gs.call("seed_exchange_coins_for_take", 3, "clover"))
	camp.call("_on_exchange_pressed")
	for _m in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 5:
		push_error("camp_trade_select_smoke: clover expected 5 got %s" % str(bag.get("clover")))
		quit(1)
		return
	if int(gs.get("wallet_coins")) != coins_before + batch:
		push_error("camp_trade_select_smoke: batch coins wrong")
		quit(1)
		return
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		push_error("camp_trade_select_smoke: select should persist got %s" % selected)
		quit(1)
		return

	camp.call("_on_exchange_pressed")
	for _n in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 2:
		push_error("camp_trade_select_smoke: clover expected 2 got %s" % str(bag.get("clover")))
		quit(1)
		return
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		push_error("camp_trade_select_smoke: leftover 2 should keep select got %s" % selected)
		quit(1)
		return
	if exchange and bool(exchange.get("disabled")):
		push_error("camp_trade_select_smoke: Trade should stay enabled for leftover 2")
		quit(1)
		return

	coins_before = int(gs.get("wallet_coins"))
	camp.call("_on_exchange_pressed")
	for _o in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 0:
		push_error("camp_trade_select_smoke: clover should be 0 after leftover trade")
		quit(1)
		return
	if int(gs.get("wallet_coins")) != coins_before + 2:
		push_error(
			"camp_trade_select_smoke: leftover clover coins expected %d got %s"
			% [coins_before + 2, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	# After clover depletes, only tulip remains → auto-select tulip.
	selected = str(camp.get("_selected_trade_type"))
	if selected != "tulip":
		push_error(
			"camp_trade_select_smoke: after clover deplete expected tulip got %s" % selected
		)
		quit(1)
		return

	# Page show resets to default (tulip remaining ★2 only).
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	selected = str(camp.get("_selected_trade_type"))
	if selected != "tulip":
		push_error("camp_trade_select_smoke: default after reset should be tulip got %s" % selected)
		quit(1)
		return

	print("camp_trade_select_smoke OK")
	quit(0)


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
