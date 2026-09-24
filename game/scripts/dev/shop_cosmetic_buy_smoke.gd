extends SceneTree

## Bug-017 + design_handoff_shop: kupovina kozmetike za coine ide u dva tapa
## ("Buy & wear" -> potvrda), skida coine, oprema predmet i javlja na kartici.

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
	if str(card.call("get_mode")) != "buy":
		_fail("expected buy mode, got %s" % str(card.call("get_mode")))
		return
	if str(card.call("get_action_text")) != "Buy & wear":
		_fail("buy label %s" % str(card.call("get_action_text")))
		return
	if str(card.call("get_price_text")) != "150":
		_fail("price tag %s" % str(card.call("get_price_text")))
		return

	card.emit_signal("buy_requested", "meadow_sunset")
	await _frames(3)
	if str(shop.call("get_confirm_id")) != "meadow_sunset":
		_fail("first tap should open the confirm row")
		return
	if str(card.call("get_mode")) != "confirm":
		_fail("card should be in confirm mode")
		return
	if int(gs.get("wallet_coins")) != 300:
		_fail("first tap must not spend coins")
		return

	card.emit_signal("buy_confirmed", "meadow_sunset")
	await _frames(4)
	if int(gs.get("wallet_coins")) != 150:
		_fail("wallet expected 150 got %s" % str(gs.get("wallet_coins")))
		return
	var owned: Dictionary = cosmetics.get("owned")
	if not bool(owned.get("meadow_sunset", false)):
		_fail("meadow_sunset should be owned")
		return
	if not bool(gs.call("is_cosmetic_equipped", "meadow_sunset")):
		_fail("meadow_sunset should be equipped")
		return
	if str(card.call("get_mode")) != "equipped":
		_fail("card should be equipped, got %s" % str(card.call("get_mode")))
		return
	if str(card.call("get_badge_text")) != "Wearing":
		_fail("badge %s" % str(card.call("get_badge_text")))
		return
	var status: Node = card.call("get_status")
	if status == null or not status.visible or str(status.call("get_kind")) != "ok":
		_fail("bought status missing on the card")
		return
	if not str(status.call("get_title_text")).begins_with("Bought"):
		_fail("bought text %s" % str(status.call("get_title_text")))
		return

	gs.set("wallet_coins", 10)
	shop.call("refresh_shop")
	await _frames(3)
	var pricey: Node = shop.call("get_cosmetic_card", "pip_blossom")
	if str(pricey.call("get_mode")) != "short":
		_fail("pip_blossom should be short on coins")
		return
	if bool(pricey.call("is_action_enabled")):
		_fail("short card must not be buyable")
		return
	if str(pricey.call("get_action_text")) != "Need 240 more":
		_fail("short label %s" % str(pricey.call("get_action_text")))
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("shop_cosmetic_buy_smoke OK")
	quit(0)
