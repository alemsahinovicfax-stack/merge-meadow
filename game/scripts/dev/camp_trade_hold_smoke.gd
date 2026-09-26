extends SceneTree

## CAMP-06 / design_handoff_camp — tap = 1 sjeme, hold = 10/s, prelazak na
## sljedeci tip dok se drzi; Trade dugme "Trade" → "Trading" (v2: bez podnaslova).

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_trade_hold_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
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
		var want_link := str(mini(int(gs.get("wallet_coins")), 500))
		if not link_coins.text.begins_with(want_link):
			return "season link coins must update mid-hold, label='%s' wallet=%s" % [link_coins.text, want_coins]
	return ""


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
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
	var bar := camp.get_node_or_null("%ExchangeBar")
	if button == null or bar == null:
		_fail("ExchangeButton / ExchangeBar missing")
		return
	if not bool(button.get("auto_repeat")):
		_fail("Trade button must have auto_repeat on")
		return
	if not button.get("repeat_guard") is Callable or not (button.get("repeat_guard") as Callable).is_valid():
		_fail("Trade button must have a repeat_guard (reserved flower floor)")
		return

	gs.set("seed_bag", {"clover": 24})
	gs.set("wallet_coins", 0)
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	if str(button.call("get_title")) != "Trade" or not str(button.call("get_sub")).is_empty():
		_fail("idle Trade button must read just 'Trade', got '%s / %s'" % [button.call("get_title"), button.call("get_sub")])
		return

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
	if str(bar.call("get_state")) != "idle":
		_fail("first tap is not a hold yet, state=%s" % str(bar.call("get_state")))
		return

	# Unutar početnog delaya ponavljanje još ne kreće.
	button.call("_tick_repeat", float(button.get("auto_repeat_delay")))
	await process_frame
	bag = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 23:
		_fail("repeat must not fire during the hold delay")
		return

	# Save je odgođen dok traje hold (inače 10 zapisa na disk u sekundi).
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
	if str(bar.call("get_state")) != "hold" or str(button.call("get_title")) != "Trading":
		_fail("repeat must show hold state 'Trading', state=%s title=%s" % [bar.call("get_state"), button.call("get_title")])
		return
	if int(bar.call("get_gain")) != rate + 1:
		_fail("TradeFeedback must sum the hold (+%d), gain=%s" % [rate + 1, str(bar.call("get_gain"))])
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
	if int(bar.call("get_gain")) != 0 or str(bar.call("get_state")) != "idle":
		_fail("release must hand +N to the header and return to idle")
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
	# v2: prelaz se vidi po novom imenu u baru, bez rečenice.
	if str(bar.call("get_selected_text")).is_empty():
		_fail("auto switch must show the new type name")
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

	# Prazna vreca: Trade bar se sklanja dok nema sta prodati.
	gs.set("seed_bag", {})
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	if (bar as Control).visible:
		_fail("empty bag must hide the Trade bar")
		return

	print("camp_trade_hold_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
