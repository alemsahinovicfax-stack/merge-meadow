extends SceneTree

## Bug-011 — select seed type then trade 3 → coins; select persists while eligible.


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
	gs.set("seed_bag", {"clover": 8, "daisy": 2})
	gs.set("wallet_coins", 10)
	if camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	for _j in 4:
		await process_frame
	var grid := camp.get_node_or_null("%SeedBagGrid") as GridContainer
	if grid == null or grid.get_child_count() < 2:
		push_error("camp_trade_select_smoke: SeedBagGrid missing chips")
		quit(1)
		return
	# Daisy (2) must not enable trade; clover (8) must.
	if camp.has_method("_on_seed_chip_pressed"):
		camp.call("_on_seed_chip_pressed", "daisy")
	await process_frame
	var selected := str(camp.get("_selected_trade_type"))
	if selected == "daisy":
		push_error("camp_trade_select_smoke: daisy (<3) should not select")
		quit(1)
		return
	camp.call("_on_seed_chip_pressed", "clover")
	await process_frame
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		push_error("camp_trade_select_smoke: expected clover selected got %s" % selected)
		quit(1)
		return
	var exchange := camp.get_node_or_null("%ExchangeButton")
	if exchange and bool(exchange.get("disabled")):
		push_error("camp_trade_select_smoke: Trade should be enabled")
		quit(1)
		return
	if camp.has_method("_on_exchange_pressed"):
		camp.call("_on_exchange_pressed")
	for _k in 4:
		await process_frame
	var bag: Dictionary = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 5:
		push_error("camp_trade_select_smoke: clover expected 5 got %s" % str(bag.get("clover")))
		quit(1)
		return
	var reward := int(gs.get("EXCHANGE_COINS_REWARD"))
	if int(gs.get("wallet_coins")) != 10 + reward:
		push_error(
			"camp_trade_select_smoke: coins expected %d got %s"
			% [10 + reward, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_trade_type"))
	if selected != "clover":
		push_error("camp_trade_select_smoke: select should persist after trade #1 got %s" % selected)
		quit(1)
		return
	if exchange and bool(exchange.get("disabled")):
		push_error("camp_trade_select_smoke: Trade should stay enabled after trade #1")
		quit(1)
		return
	camp.call("_on_exchange_pressed")
	for _m in 4:
		await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 2:
		push_error("camp_trade_select_smoke: clover expected 2 after trade #2 got %s" % str(bag.get("clover")))
		quit(1)
		return
	if int(gs.get("wallet_coins")) != 10 + reward * 2:
		push_error(
			"camp_trade_select_smoke: coins expected %d got %s"
			% [10 + reward * 2, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_trade_type"))
	if not selected.is_empty():
		push_error("camp_trade_select_smoke: select should clear when clover < 3 got %s" % selected)
		quit(1)
		return
	if exchange and not bool(exchange.get("disabled")):
		push_error("camp_trade_select_smoke: Trade should be disabled when select cleared")
		quit(1)
		return
	print("camp_trade_select_smoke OK")
	quit(0)
