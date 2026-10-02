extends SceneTree

## Shop v2 · Looks: coin kupovina u dva tapa na ISTOM dugmetu (coins.buy → coins.confirm →
## kupljeno i nošeno), 3 s bez tapa vraća nazad, nema dovoljno coina → coins.short (tap ne
## troši ništa), kupljeno = „Wearing" i kartica `#FFF6D6`; stanje isto kao u Ormaru.

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("shop_cosmetic_buy_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop load failed %d" % err)
		return
	await _frames(20)
	var shop := current_scene as Control
	var gs := _gs()
	if shop == null or gs == null:
		_fail("shop/GameState missing")
		return
	gs.set("wallet_coins", 300)
	var cosmetics: Object = gs.get("cosmetics")
	cosmetics.set("owned", {})
	cosmetics.set("equipped", {})
	shop.call("refresh_shop")
	await _frames(4)

	var card: Node = shop.call("get_cosmetic_card", "meadow_sunset")
	if card == null:
		_fail("meadow_sunset card missing")
		return
	var btn: Node = card.call("get_buy_button")
	if str(card.call("get_state")) != "coins.buy" or str(btn.get("price")) != "150":
		_fail("expected coins.buy 150, got %s %s" % [card.call("get_state"), btn.get("price")])
		return

	# Prvi tap: potvrda na istom dugmetu, coini netaknuti.
	btn.emit_signal("clicked")
	await _frames(3)
	if str(shop.call("get_confirm_id")) != "meadow_sunset" or str(card.call("get_state")) != "coins.confirm":
		_fail("first tap should arm the confirm state")
		return
	if int(gs.get("wallet_coins")) != 300:
		_fail("first tap must not spend coins")
		return
	# 3 s bez tapa → nazad na coins.buy.
	await create_timer(3.3).timeout
	if str(card.call("get_state")) != "coins.buy":
		_fail("confirm should time out back to coins.buy")
		return

	# Dva tapa: kupi i obuci.
	btn.emit_signal("clicked")
	await _frames(2)
	btn.emit_signal("clicked")
	await _frames(4)
	if int(gs.get("wallet_coins")) != 150:
		_fail("wallet expected 150 got %s" % str(gs.get("wallet_coins")))
		return
	if not bool(gs.call("owns_cosmetic", "meadow_sunset")):
		_fail("meadow_sunset should be owned")
		return
	if str(gs.call("get_equipped_cosmetic", "meadow_bg")) != "meadow_sunset":
		_fail("bought item should be worn")
		return
	if str(card.call("get_state")) != "owned" or not bool(card.call("is_worn")) or str(btn.get("owned_label")) != "Wearing":
		_fail("card should show Wearing")
		return
	if not bool(card.get("yours")):
		_fail("bought card should use the yours fill")
		return

	# Nema dovoljno coina: coins.short, tap ne troši i ne potvrđuje.
	var sky: Node = shop.call("get_cosmetic_card", "pip_blossom")
	if str(sky.call("get_state")) != "coins.short":
		_fail("pip_blossom (250) with 150 coins should be coins.short, got %s" % str(sky.call("get_state")))
		return
	var short_btn: Node = sky.call("get_buy_button")
	short_btn.emit_signal("short_tapped")
	await _frames(3)
	if int(gs.get("wallet_coins")) != 150 or str(shop.call("get_confirm_id")) != "":
		_fail("short tap must not spend or arm confirm")
		return

	# Ormar skine (Default) → Shop kaže Owned, ne Wearing.
	gs.call("apply_wardrobe", {"meadow_bg": ""})
	shop.call("refresh_shop")
	await _frames(3)
	if bool(card.call("is_worn")) or str(btn.get("owned_label")) != "Owned":
		_fail("after Default in the Wardrobe the Shop should show Owned")
		return
	CampSmokeUtil.restore_save(self, _backup)
	print("shop_cosmetic_buy_smoke OK")
	quit(0)
