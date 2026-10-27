extends SceneTree

## Sir Pip (design_handoff_muncher_premium_pip · B) — premium Pip skin za pravi novac:
##   1. katalog: pip_knight je IAP kozmetika (SKU pip_knight, €3.99), nije u coin listi;
##   2. Shop · Looks: premium kartica money.buy → money.busy → kupljen i nošen („Wearing");
##   3. kupovina obuče skin (Pip svuda = knight), coini / sjemenke netaknuti (Pillar 2);
##   4. drugi skin → „✓ Owned" se može tapnuti i vraća Sir Pipa;
##   5. restore (bez user flowa) vraća vlasništvo, ne mijenja nošeni skin;
##   6. Ormar: „Premium" oznaka; nekupljen je pod velom, a tap vodi u Shop na njegovu karticu;
##   7. dev reset (stub) ga vraća u prodavnicu i slot na Classic.
## Sve je Play tok (€) → iap_override = 1, jer mora raditi kad se kupovine vrate; v1 kupovina Sir
## Pipa za coine je u coin_offers_smoke.

const SKU := "pip_knight"
const ITEM := "pip_knight"

var _backup := ""
var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _iap() -> Node:
	return get_root().get_node_or_null("IAPManager")


func _fail(msg: String) -> void:
	if _failed:
		return
	_failed = true
	push_error("premium_pip_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _finish() -> void:
	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("premium_pip_smoke OK")
	quit(0)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	MonetizationConfig.iap_override = 1
	var gs := _gs()
	var iap := _iap()
	var Catalog = load("res://scripts/monetization/cosmetic_catalog.gd")
	var Config = load("res://scripts/monetization/monetization_config.gd")
	# 1 — katalog
	if not bool(Catalog.is_iap_item(ITEM)) or bool(Catalog.is_shop_item(ITEM)):
		_fail("pip_knight must be an IAP item, not a coin item")
	if str(Catalog.get_sku(ITEM)) != SKU or str(Config.cosmetic_for_sku(SKU)) != ITEM:
		_fail("SKU ↔ cosmetic mapping broken")
	if bool(Config.is_consumable(SKU)) or str(iap.call("get_price_label", SKU)).is_empty():
		_fail("pip_knight should be a non-consumable with a price")
	if not bool(iap.call("is_stub_mode")):
		_fail("smoke expects stub IAP on desktop")
	gs.set("wallet_coins", 120)
	var cos: Object = gs.get("cosmetics")
	cos.set("owned", {"pip_blossom": true})
	cos.set("equipped", {"pip_skin": "pip_blossom"})
	var coins_before := int(gs.get("wallet_coins"))
	var seeds_before := str(gs.get("seed_bag"))

	# 2 — Shop kartica
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		_fail("shop load failed %d" % err)
		_finish()
		return
	await _frames(20)
	var shop := current_scene as Control
	shop.call("select_tab", "looks", false)
	shop.call("refresh_shop")
	await _frames(3)
	var card: Node = shop.call("get_premium_card", SKU)
	if card == null:
		_fail("premium card missing in Looks")
		_finish()
		return
	if str(card.call("get_state")) != "money.buy":
		_fail("expected money.buy, got %s" % card.call("get_state"))
	if shop.call("get_cosmetic_card", ITEM) != null:
		_fail("pip_knight must not get a coin card")
	var btn: Node = card.call("get_buy_button")
	btn.emit_signal("clicked")
	await _frames(2)
	if str(card.call("get_state")) != "money.busy":
		_fail("expected money.busy while buying, got %s" % card.call("get_state"))
	await create_timer(1.3).timeout
	await _frames(2)

	# 3 — kupljen i nošen
	if not bool(gs.call("owns_cosmetic", ITEM)) or str(gs.call("get_equipped_cosmetic", "pip_skin")) != ITEM:
		_fail("purchase should own and wear Sir Pip")
	if UiPip.equipped_skin_key() != "knight":
		_fail("equipped Pip skin should be knight, got %s" % UiPip.equipped_skin_key())
	if str(card.call("get_state")) != "owned" or not bool(card.call("is_worn")):
		_fail("card should say Wearing after purchase")
	if int(gs.get("wallet_coins")) != coins_before or str(gs.get("seed_bag")) != seeds_before:
		_fail("Sir Pip must not touch coins or seeds (Pillar 2)")
	if not str(shop.call("get_toast_text")).contains("Sir Pip"):
		_fail("purchase toast missing (%s)" % shop.call("get_toast_text"))

	# 4 — drugi skin, pa „✓ Owned" vraća Sir Pipa
	gs.call("equip_cosmetic", "pip_blossom")
	await _frames(3)
	if bool(card.call("is_worn")) or str(card.call("get_state")) != "owned":
		_fail("card should be Owned (not worn) after wearing Blossom")
	if not bool(btn.call("is_tappable")):
		_fail("Owned premium button should be tappable to wear")
	btn.emit_signal("clicked")
	await _frames(3)
	if str(gs.call("get_equipped_cosmetic", "pip_skin")) != ITEM or not bool(card.call("is_worn")):
		_fail("tap on Owned should wear Sir Pip")

	# 5 — restore: vlasništvo da, nošeni skin ostaje
	gs.call("equip_cosmetic", "pip_blossom")
	cos.get("owned").erase(ITEM)
	iap.call("_grant_product", SKU, "", false)
	if not bool(gs.call("owns_cosmetic", ITEM)) or str(gs.call("get_equipped_cosmetic", "pip_skin")) != "pip_blossom":
		_fail("restore should own Sir Pip without changing the worn skin")
	iap.connect("purchase_failed", func(sku: String, reason: String) -> void:
		if sku == SKU:
			gs.set_meta("premium_fail", reason)
	)
	iap.call("purchase", SKU)
	if str(gs.get_meta("premium_fail", "")) != "already_owned":
		_fail("buying an owned Sir Pip should fail with already_owned")

	# 6 — Ormar
	await _check_wardrobe(gs, cos)

	# 7 — dev reset
	gs.call("equip_cosmetic", ITEM)
	iap.call("reset_purchases_for_dev")
	if bool(gs.call("owns_cosmetic", ITEM)) or str(gs.call("get_equipped_cosmetic", "pip_skin")) != "":
		_fail("dev reset should return Sir Pip to the shop and Pip to Classic")
	_finish()


func _check_wardrobe(gs: Node, cos: Object) -> void:
	cos.get("owned").erase(ITEM)
	cos.set("equipped", {})
	var sheet: Control = (load("res://scripts/ui/wardrobe_sheet.gd") as GDScript).new()
	sheet.name = "WardrobeSmoke"
	root.add_child(sheet)
	await _frames(3)
	sheet.call("open", "", false)
	sheet.call("select_slot", "pip_skin")
	await _frames(4)
	var knight: Node = sheet.call("get_card", ITEM)
	if knight == null:
		_fail("wardrobe has no Sir Pip card")
		return
	if not bool(knight.call("is_premium")) or str(knight.get("state")) != UiWardrobe.CARD_NONE:
		_fail("unowned Sir Pip should be a veiled Premium card")
	if not bool(knight.get("enabled")):
		_fail("veiled Sir Pip must still take a tap (→ Shop)")
	var asked := []
	sheet.connect("shop_requested", func(slot_id: String, item_id: String) -> void: asked.append([slot_id, item_id]))
	knight.call("simulate_tap")
	await _frames(2)
	if asked.is_empty() or str(asked[0][1]) != ITEM:
		_fail("tap on veiled Sir Pip should ask the Shop for his card (%s)" % str(asked))
	var classic: Node = sheet.call("get_card", "")
	if classic == null or not bool(classic.call("is_free_skin")) or bool(classic.call("is_premium")):
		_fail("Classic should keep the Free tag")
	sheet.call("close", false)
	await _frames(2)
	sheet.queue_free()
