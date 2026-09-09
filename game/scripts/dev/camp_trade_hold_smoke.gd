extends SceneTree

## CAMP-06 — tap = 1 sjeme, hold = 6/s, i prelazak na sljedeći tip dok se drži.


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_trade_hold_smoke: %s" % msg)
	quit(1)


## Novac i sjeme moraju pratiti svaki pojedini trade, ne tek otpuštanje dugmeta.
func _assert_live_chrome(camp: Node, gs: Node) -> String:
	var coins_lbl := camp.get_node_or_null("%CoinsLabel") as Label
	var seeds_lbl := camp.get_node_or_null("%SeedsLabel") as Label
	if coins_lbl == null or seeds_lbl == null:
		return "camp header labels missing"
	var want_coins := str(int(gs.get("wallet_coins")))
	if coins_lbl.text != want_coins:
		return "coins must update mid-hold, label='%s' wallet=%s" % [coins_lbl.text, want_coins]
	var want_seeds := str(int(gs.call("sum_seed_bag_only")))
	if not seeds_lbl.text.begins_with(want_seeds):
		return "seeds must update mid-hold, label='%s' bag=%s" % [seeds_lbl.text, want_seeds]
	var link_card := camp.get_node_or_null("%SeasonLinkCard") as CanvasItem
	var link_coins := camp.get_node_or_null("%SeasonLinkCoins") as Label
	if link_card and link_card.visible and link_coins:
		if not link_coins.text.begins_with(want_coins):
			return (
				"season link coins must update mid-hold, label='%s' wallet=%s"
				% [link_coins.text, want_coins]
			)
	return ""


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := get_root().get_node_or_null("GameState")
	if camp == null or gs == null:
		_fail("camp/GameState missing")
		return
	var button := camp.get_node_or_null("%ExchangeButton")
	if button == null:
		_fail("ExchangeButton missing")
		return
	if not bool(button.get("auto_repeat")):
		_fail("Trade button must have auto_repeat on")
		return
	if not bool(button.get("ghost_when_disabled")):
		_fail("Trade button must ghost when disabled")
		return
	if str(button.get("label_text")) != "Trade":
		_fail("Trade button label must be 'Trade' got '%s'" % str(button.get("label_text")))
		return

	gs.set("seed_bag", {"clover": 24})
	gs.set("wallet_coins", 0)
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame

	# Tap = tačno jedno sjeme.
	button.call("begin_press", true)
	await process_frame
	var bag: Dictionary = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 23:
		_fail("tap must trade exactly 1, clover got %s" % str(bag.get("clover")))
		return
	if not bool(button.call("is_holding")):
		_fail("button should be holding after begin_press")
		return

	# Unutar početnog delaya ponavljanje još ne kreće.
	button.call("_tick_repeat", float(button.get("auto_repeat_delay")))
	await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 23:
		_fail("repeat must not fire during the hold delay")
		return

	# Save je odgođen dok traje hold (inače 6 zapisa na disk u sekundi).
	if not bool(camp.get("_pending_trade_save")):
		_fail("hold must defer the save")
		return

	# Jedna sekunda držanja = auto_repeat_rate komada (Camp: 10).
	var rate := int(round(float(button.get("auto_repeat_rate"))))
	if rate != 10:
		_fail("Camp hold rate should be 10/s, got %d" % rate)
		return
	var interval := 1.0 / float(rate)
	for _j in rate:
		button.call("_tick_repeat", interval)
	await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 23 - rate:
		_fail("1s hold must trade %d, clover got %s" % [rate, str(bag.get("clover"))])
		return

	# Header i link-season prate hold uživo — bez čekanja na otpuštanje.
	var chrome_err := _assert_live_chrome(camp, gs)
	if not chrome_err.is_empty():
		_fail(chrome_err)
		return

	button.call("end_press")
	await process_frame
	if bool(button.call("is_holding")):
		_fail("end_press must stop the hold")
		return
	if bool(camp.get("_pending_trade_save")):
		_fail("release must flush the save")
		return

	# Kad se tip isprazni tokom holda, trgovanje se nastavlja sljedećim tipom.
	gs.set("seed_bag", {"clover": 1, "tulip": 3})
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	if str(camp.get("_selected_trade_type")) != "clover":
		_fail("expected clover selected first got %s" % str(camp.get("_selected_trade_type")))
		return
	button.call("begin_press", true)
	await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 0:
		_fail("clover should be spent by the first press")
		return
	if str(camp.get("_selected_trade_type")) != "tulip":
		_fail("selection must advance to tulip got %s" % str(camp.get("_selected_trade_type")))
		return
	button.call("_tick_repeat", float(button.get("auto_repeat_delay")))
	for _k in 2:
		button.call("_tick_repeat", interval)
	await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("tulip", 0)) != 1:
		_fail("hold must keep trading the next type, tulip got %s" % str(bag.get("tulip")))
		return
	button.call("end_press")
	await process_frame

	print("camp_trade_hold_smoke OK")
	quit(0)
