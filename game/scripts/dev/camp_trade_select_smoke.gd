extends SceneTree

## Bug-025 / design_handoff_camp — ASC grid, default select, tap = 1, auto prelaz
## na sljedeci tip kad se odabrani isprazni; CampStashChip struktura.

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("camp_trade_select_smoke: %s" % msg)
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

	# clover ★1, tulip ★2 — ASC puts daisy/clover first (ime), tulip poslije.
	gs.set("seed_bag", {"tulip": 3, "clover": 8, "daisy": 2})
	gs.set("wallet_coins", 10)
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	for _j in 4:
		await process_frame

	var grid := camp.get_node_or_null("%SeedBagGrid") as GridContainer
	if grid == null or grid.get_child_count() < 3:
		_fail("SeedBagGrid missing chips")
		return
	var first_chip: Node = grid.get_child(0)
	var first_id := str(first_chip.call("get_type_id")) if first_chip.has_method("get_type_id") else ""
	if first_id != "daisy":
		_fail("ASC expected Field Daisy first got %s" % first_id)
		return
	var chip_err := CampSmokeUtil.chip_error(first_chip as Control, "seed")
	if not chip_err.is_empty():
		_fail(chip_err)
		return
	if not bool(first_chip.call("is_selected")):
		_fail("default chip must render selected")
		return

	var selected := str(camp.get("_selected_trade_type"))
	if selected != "daisy":
		_fail("default select should be daisy got %s" % selected)
		return

	# CAMP-06: jedan tap = jedno sjeme (hold ponavlja, vidi camp_trade_hold_smoke).
	if int(gs.call("seed_exchange_take_count", 8)) != 1:
		_fail("one tap must take exactly 1 seed")
		return

	camp.call("_on_seed_chip_pressed", "daisy")
	await process_frame
	var exchange := camp.get_node_or_null("%ExchangeButton")
	if exchange == null or bool(exchange.get("disabled")):
		_fail("Trade should enable for daisy leftover")
		return
	var bar := camp.get_node_or_null("%ExchangeBar")
	# v2: bar nosi samo ime i dugme; cijena po komadu stoji na kartici predmeta.
	if bar == null or camp.get_node_or_null("%SelectedValue") != null:
		_fail("Trade bar must not repeat the price (SelectedValue is gone)")
		return
	if str(bar.call("get_button_text")) != "Trade":
		_fail("idle Trade button must read 'Trade', got '%s'" % str(bar.call("get_button_text")))
		return
	var daisy_coin := int(gs.call("seed_exchange_coins_for_take", 1, "daisy"))
	var coins_before := int(gs.get("wallet_coins"))
	camp.call("_on_exchange_pressed")
	for _k in 4:
		await process_frame
	var bag: Dictionary = gs.get("seed_bag")
	if int(bag.get("daisy", 0)) != 1:
		_fail("daisy expected 1 got %s" % str(bag.get("daisy")))
		return
	if int(gs.get("wallet_coins")) != coins_before + daisy_coin:
		_fail("coins after daisy tap expected %d got %s" % [coins_before + daisy_coin, str(gs.get("wallet_coins"))])
		return
	if int(bar.call("get_gain")) != daisy_coin:
		_fail("TradeFeedback must show +%d, gain=%s" % [daisy_coin, str(bar.call("get_gain"))])
		return
	if str(camp.get("_selected_trade_type")) != "daisy":
		_fail("daisy should keep select")
		return

	camp.call("_on_exchange_pressed")
	for _l in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("daisy", 0)) != 0:
		_fail("daisy should be 0 after second tap")
		return
	# After daisy depletes, next in ASC order is clover (Meadow Clover).
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		_fail("after daisy deplete expected clover got %s" % selected)
		return
	if grid.get_child_count() != 2:
		_fail("depleted daisy chip should leave the grid, children=%d" % grid.get_child_count())
		return
	var seeds_tab := camp.get_node_or_null("%SeedsTab")
	if seeds_tab == null or str(seeds_tab.call("get_count_text")) != "2":
		_fail("Seeds tab must count 2 types after daisy deplete")
		return

	# Clover 8 → 7 per tap; select persists while stock remains.
	camp.call("_on_seed_chip_pressed", "clover")
	await process_frame
	coins_before = int(gs.get("wallet_coins"))
	var clover_coin := int(gs.call("seed_exchange_coins_for_take", 1, "clover"))
	camp.call("_on_exchange_pressed")
	for _m in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 7:
		_fail("clover expected 7 got %s" % str(bag.get("clover")))
		return
	if int(gs.get("wallet_coins")) != coins_before + clover_coin:
		_fail("single tap coins wrong")
		return
	if bool(exchange.get("disabled")):
		_fail("Trade should stay enabled while clover remains")
		return

	# Drain the remaining 7 clover one tap at a time.
	coins_before = int(gs.get("wallet_coins"))
	for _n in 7:
		camp.call("_on_exchange_pressed")
		await process_frame
	for _o in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 0:
		_fail("clover should be 0 got %s" % str(bag.get("clover")))
		return
	if int(gs.get("wallet_coins")) != coins_before + clover_coin * 7:
		_fail("drain coins expected %d got %s" % [coins_before + clover_coin * 7, str(gs.get("wallet_coins"))])
		return
	# After clover depletes, only tulip remains → auto-select tulip.
	selected = str(camp.get("_selected_trade_type"))
	if selected != "tulip":
		_fail("after clover deplete expected tulip got %s" % selected)
		return

	# Page show resets to default (tulip remaining ★2 only).
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	if str(camp.get("_selected_trade_type")) != "tulip":
		_fail("default after reset should be tulip")
		return

	print("camp_trade_select_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
