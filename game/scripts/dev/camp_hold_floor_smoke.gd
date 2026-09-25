extends SceneTree

## design_handoff_camp — pravilo rezervisanog ★3 cvijeca: drzanje Trade staje
## kad bi tip pao ispod broja koji sljedeca sezona trazi (Frost Orchard: 20
## Harvest Pumpkin), tap prodaje dalje, novcici do tada ostaju. Ostali tipovi i
## sjemenke nisu pogodeni; bez sljedece sezone nema granice.

var _backup: String = ""
var _interval: float = 0.1


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("camp_hold_floor_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _hold(button: Node, ticks: int) -> void:
	button.call("_tick_repeat", float(button.get("auto_repeat_delay")))
	for _i in ticks:
		button.call("_tick_repeat", _interval)
	await process_frame


func _pumpkin(gs: Node) -> int:
	return int((gs.get("garden_crystal_stash") as Dictionary).get("pumpkin", 0))


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	gs.call("reset_seasons_to_s1")
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var button := camp.get_node_or_null("%ExchangeButton")
	var bar := camp.get_node_or_null("%ExchangeBar")
	var grid := camp.get_node_or_null("%CrystalGrid") as GridContainer
	if button == null or bar == null or grid == null:
		_fail("Trade nodes missing")
		return
	_interval = 1.0 / float(button.get("auto_repeat_rate"))

	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {"clover": 2, "pumpkin": 23})
	camp.call("_on_tab_pressed", "flowers")
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	camp.call("_on_crystal_chip_pressed", "pumpkin")
	await process_frame
	var chip := _chip(grid, "pumpkin")
	if chip == null or not bool(chip.call("is_reserved")) or str(chip.call("get_badge_text")) != "Kept · 20 / 20":
		_fail("pumpkin above the floor must read 'Kept · 20 / 20', got '%s'" % (str(chip.call("get_badge_text")) if chip else ""))
		return
	if not is_equal_approx((chip as Control).custom_minimum_size.y, 176.0):
		_fail("reserved chip must stay 176 px tall (badge sits in the pips row)")
		return
	if str(bar.call("get_state")) != "idle":
		_fail("above the floor the rule is invisible (idle), got %s" % str(bar.call("get_state")))
		return

	# 23 → tap 22 → drzanje 21, 20 → stop (ne 19).
	var price := int(gs.call("crystal_exchange_coins_for_type", "pumpkin"))
	button.call("begin_press", true)
	await process_frame
	await _hold(button, 10)
	if _pumpkin(gs) != 20:
		_fail("hold must stop at the floor (20), pumpkin=%d" % _pumpkin(gs))
		return
	if not bool(button.call("is_repeat_blocked")):
		_fail("repeat must be blocked at the floor")
		return
	if int(gs.get("wallet_coins")) != price * 3:
		_fail("coins earned before the stop must stay (%d), got %s" % [price * 3, str(gs.get("wallet_coins"))])
		return
	if str(bar.call("get_state")) != "holdstop":
		_fail("stopped hold must be holdstop, got %s" % str(bar.call("get_state")))
		return
	if str(bar.call("get_warning_text")) != "Hold stopped · Frost Orchard keeps 20":
		_fail("holdstop strip text wrong: '%s'" % str(bar.call("get_warning_text")))
		return
	if str(button.call("get_title")) != "Sell 1" or not str(button.call("get_sub")).is_empty():
		_fail("holdstop button must read just 'Sell 1', got '%s / %s'" % [
			str(button.call("get_title")), str(button.call("get_sub"))
		])
		return
	# v2: tekst badgea se ne mijenja na granici, samo stil (amber).
	if str(_chip(grid, "pumpkin").call("get_badge_text")) != "Kept · 20 / 20":
		_fail("chip badge at the floor must stay 'Kept · 20 / 20'")
		return
	button.call("end_press")
	await process_frame
	if bool(camp.get("_pending_trade_save")):
		_fail("release must flush the save")
		return

	# Tap prodaje dalje: 20 → 19, stanje warn.
	button.call("begin_press", true)
	await process_frame
	button.call("end_press")
	await process_frame
	if _pumpkin(gs) != 19:
		_fail("tap below the floor must still sell 1, pumpkin=%d" % _pumpkin(gs))
		return
	# v2: upozorenje nose boja, lokot i strip iznad reda — ne podnaslov dugmeta.
	if str(bar.call("get_state")) != "warn" or str(button.call("get_title")) != "Trade":
		_fail("below the floor must warn (pink Trade), state=%s" % str(bar.call("get_state")))
		return
	if str(bar.call("get_warning_text")) != "Frost Orchard needs 1 more of these":
		_fail("warn strip text wrong: '%s'" % str(bar.call("get_warning_text")))
		return

	# Ispod granice drzanje ostaje iskljuceno: pritisak = 1 komad.
	button.call("begin_press", true)
	await process_frame
	await _hold(button, 10)
	if _pumpkin(gs) != 18:
		_fail("hold below the floor must sell only the tap, pumpkin=%d" % _pumpkin(gs))
		return
	button.call("end_press")
	await process_frame

	# Auto prelaz s nerezervisanog tipa u rezervisani staje na njegovoj granici.
	camp.call("_on_crystal_chip_pressed", "clover")
	button.call("begin_press", true)
	await process_frame
	await _hold(button, 10)
	button.call("end_press")
	await process_frame
	if int((gs.get("garden_crystal_stash") as Dictionary).get("clover", 0)) != 0:
		_fail("clover (not reserved) must sell out on hold")
		return
	if _pumpkin(gs) != 18:
		_fail("auto switch into pumpkin must not sell below the floor, pumpkin=%d" % _pumpkin(gs))
		return

	# Sjemenke (T1 pumpkin) nemaju granicu.
	gs.set("seed_bag", {"pumpkin": 3})
	camp.call("_on_tab_pressed", "seeds")
	camp.set("_force_default_trade_select", true)
	camp.call("_refresh_garden_card")
	await process_frame
	button.call("begin_press", true)
	await process_frame
	await _hold(button, 5)
	button.call("end_press")
	await process_frame
	if int((gs.get("seed_bag") as Dictionary).get("pumpkin", 0)) != 0:
		_fail("seed pumpkins are not reserved — hold must sell all 3")
		return

	# Bez sljedece besplatne sezone nema granice.
	var unlocked: Array = gs.get("unlocked_seasons")
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	gs.set("unlocked_seasons", unlocked)
	gs.set("garden_crystal_stash", {"pumpkin": 21})
	camp.call("_on_tab_pressed", "flowers")
	camp.set("_force_default_crystal_select", true)
	camp.call("_refresh_crystal_card")
	await process_frame
	if bool(_chip(grid, "pumpkin").call("is_reserved")):
		_fail("no next season → no reserved badge")
		return
	button.call("begin_press", true)
	await process_frame
	await _hold(button, 10)
	button.call("end_press")
	await process_frame
	if _pumpkin(gs) != 10:
		_fail("without a next season hold must sell freely (21 → 10), pumpkin=%d" % _pumpkin(gs))
		return

	print("camp_hold_floor_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _chip(grid: GridContainer, type_id: String) -> Node:
	for child in grid.get_children():
		if str(child.call("get_type_id")) == type_id:
			return child
	return null
