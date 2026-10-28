extends SceneTree

## v1 samo s reklamama (2026-10-26): kupovina za coine u UI-u — dva tapa svuda; bez dovoljno coina
## „Need N more coins" i ništa se ne daje.
##  1. Shop · Seasons: coins.buy → ✓ potvrda → kupljeno (▶ Play), wallet umanjen tačno za cijenu;
##  2. Shop · Boosters: Merge Hint → Yours; Loot Burst dva puta → toast „+5 …", ★3 +10;
##  3. Shop · Looks: Sir Pip → Wearing; short tap (i na običnom izgledu) → pilula „Need N more
##     coins", bez potvrde i bez trošenja; pilula nestane kad coina ima dovoljno;
##  4. Home · Premium: prvi tap = potvrda, drugi = kupljeno + toast „Yours"; bez coina toast;
##  5. Camp kartica plaćene sezone: price → confirm → burst; bez coina short + toast.
## Prekidač ide kroz MonetizationConfig.iap_override = 0 (konstanta ostaje netaknuta).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const MOONLIT := "season_pack_moonlit_warren"
const CORAL := "season_pack_coral_tide"
const STARFALL := "season_pack_starfall_glade"
const KNIGHT := "pip_knight"
const NEED := "Need %s more coins"

var _backup := ""
var _failed := false
var _gs: Node
var _iap: Node


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("coin_offers_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _price(sku: String) -> int:
	return int(_iap.call("get_coin_price", sku))


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_gs = get_root().get_node("GameState")
	_iap = get_root().get_node("IAPManager")
	MonetizationConfig.iap_override = 0
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_reset()
	await _check_shop()
	if not _failed:
		await _check_home()
	if not _failed:
		await _check_camp()
	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("coin_offers_smoke OK")
	quit(0)


## Igrač bez ijedne stvari koja se prodavala pravim novcem, na prvoj sezoni.
func _reset() -> void:
	_gs.call("reset_seasons_to_s1")
	_gs.call("clear_owned_paid_seasons")
	_gs.call("revoke_iap_cosmetics")
	_gs.set("merge_hint_owned", false)
	var cos: Object = _gs.get("cosmetics")
	cos.set("owned", {})
	cos.set("equipped", {})


func _tap(btn: Node, frames: int = 3) -> void:
	btn.emit_signal("clicked")
	await _frames(frames)


# --- 1–3 Shop ---

func _check_shop() -> void:
	if change_scene_to_file("res://scenes/ui/shop_screen.tscn") != OK:
		_fail("shop scene failed")
		return
	await _frames(20)
	var shop := current_scene as Control
	# Sezona: dva tapa.
	var price := _price(MOONLIT)
	_gs.set("wallet_coins", price + 5)
	shop.call("refresh_shop")
	await _frames(3)
	var card: Node = shop.call("get_season_card", MOONLIT)
	if card == null:
		_fail("Moonlit Warren card missing")
		return
	var btn: Node = card.get("buy")
	if str(card.call("get_state")) != "coins.buy" or str(btn.get("price")) != UiChrome.format_count(price):
		_fail("Moonlit should be coins.buy %d, got %s %s" % [price, card.call("get_state"), btn.get("price")])
		return
	await _tap(btn)
	if str(card.call("get_state")) != "coins.confirm" or int(_gs.get("wallet_coins")) != price + 5:
		_fail("first tap should only arm the confirm (%s)" % card.call("get_state"))
		return
	await _tap(btn, 4)
	if not (_gs.get("owned_paid_seasons") as Array).has("moonlit_warren"):
		_fail("second tap should buy Moonlit Warren")
		return
	if int(_gs.get("wallet_coins")) != 5 or str(card.call("get_state")) != "play":
		_fail("after buying: wallet 5 and ▶ Play, got %d %s" % [int(_gs.get("wallet_coins")), card.call("get_state")])
		return
	# Merge Hint.
	var hint: Node = shop.call("get_booster_card", "merge_hint")
	_gs.set("wallet_coins", _price("booster_merge_hint"))
	shop.call("refresh_shop")
	await _frames(3)
	await _tap(hint.get("buy"))
	await _tap(hint.get("buy"), 4)
	if not bool(_gs.get("merge_hint_owned")) or str(hint.call("get_state")) != "owned" or int(_gs.get("wallet_coins")) != 0:
		_fail("Merge Hint should be owned for its coin price (%s)" % hint.call("get_state"))
		return
	# Loot Burst dva puta (cilj = sljedeća besplatna sezona).
	_gs.call("reset_seasons_to_s1")
	var target: Dictionary = _gs.call("get_loot_burst_target")
	var flower := str(target.get("flower", ""))
	var stash_before := int((_gs.get("garden_crystal_stash") as Dictionary).get(flower, 0))
	_gs.set("wallet_coins", _price("booster_loot_burst") * 2)
	shop.call("refresh_shop")
	await _frames(3)
	var loot: Node = shop.call("get_booster_card", "loot_burst")
	if loot == null or not (loot as Control).visible:
		_fail("Loot Burst card should be offered while a free season is locked")
		return
	for i in 2:
		await _tap(loot.get("buy"))
		await _tap(loot.get("buy"), 4)
	var stash_after := int((_gs.get("garden_crystal_stash") as Dictionary).get(flower, 0))
	if stash_after != stash_before + 2 * MonetizationConfig.LOOT_BURST_STAR3 or int(_gs.get("wallet_coins")) != 0:
		_fail("two Loot Bursts should add %d ★3 (%d → %d)" % [2 * MonetizationConfig.LOOT_BURST_STAR3, stash_before, stash_after])
		return
	if not str(shop.call("get_toast_text")).begins_with("+%d" % MonetizationConfig.LOOT_BURST_STAR3):
		_fail("Loot Burst toast missing (%s)" % shop.call("get_toast_text"))
	# Sir Pip.
	_gs.set("wallet_coins", _price(KNIGHT))
	shop.call("select_tab", "looks", false)
	shop.call("refresh_shop")
	await _frames(3)
	var knight: Node = shop.call("get_premium_card", KNIGHT)
	if knight == null:
		_fail("Sir Pip card missing in Looks")
		return
	await _tap(knight.call("get_buy_button"))
	await _tap(knight.call("get_buy_button"), 4)
	if not bool(_gs.call("owns_cosmetic", KNIGHT)) or not bool(knight.call("is_worn")):
		_fail("Sir Pip should be bought and worn")
		return
	# Premalo coina: drhtaj + pilula, ništa dato.
	_gs.set("wallet_coins", 10)
	shop.call("select_tab", "seasons", false)
	shop.call("refresh_shop")
	await _frames(3)
	var coral: Node = shop.call("get_season_card", CORAL)
	if str(coral.call("get_state")) != "coins.short":
		_fail("Coral with 10 coins should be coins.short, got %s" % coral.call("get_state"))
		return
	(coral.get("buy") as Node).emit_signal("short_tapped")
	await _frames(3)
	var want := NEED % UiChrome.format_count(_price(CORAL) - 10)
	if str(shop.call("get_need_text")) != want:
		_fail("short tap should show '%s', got '%s'" % [want, shop.call("get_need_text")])
	if str(shop.call("get_confirm_id")) != "" or int(_gs.get("wallet_coins")) != 10 \
			or (_gs.get("owned_paid_seasons") as Array).has("coral_tide"):
		_fail("short tap must not arm, spend or grant")
	var blossom: Node = shop.call("get_cosmetic_card", "pip_blossom")
	(blossom.call("get_buy_button") as Node).emit_signal("short_tapped")
	await _frames(3)
	if str(shop.call("get_need_text")) != NEED % UiChrome.format_count(CosmeticCatalog.get_coin_cost("pip_blossom") - 10):
		_fail("Looks short tap should show the same bubble, got '%s'" % shop.call("get_need_text"))
	_gs.set("wallet_coins", _price(CORAL))
	shop.call("refresh_shop")
	await _frames(3)
	if not str(shop.call("get_need_text")).is_empty() or str(coral.call("get_state")) != "coins.buy":
		_fail("bubble should clear once the coins are there")


# --- 4 Home ---

func _check_home() -> void:
	_reset()
	if change_scene_to_file("res://scenes/ui/season_stage.tscn") != OK:
		_fail("season stage scene failed")
		return
	await _frames(12)
	var stage := current_scene
	var id := "coral_tide"
	var price := _price(CORAL)
	_gs.set("wallet_coins", price + 3)
	stage.call("refresh")
	stage.call("show_season", id, false)
	await _frames(3)
	if str(stage.call("card_status", id)) != "buy":
		_fail("Coral card on Home should be buy, got %s" % stage.call("card_status", id))
		return
	var content: Node = stage.call("get_card_content")
	var data: Dictionary = content.get("data")
	if int(data.get("coin_price", 0)) != price or bool(data.get("confirm", false)):
		_fail("Home card data should carry the coin price (%s)" % str(data))
		return
	stage.call("press_part", "buy")
	await _frames(3)
	data = content.get("data")
	if not bool(data.get("confirm", false)) or int(_gs.get("wallet_coins")) != price + 3:
		_fail("first tap on Home should only arm the confirm")
		return
	stage.call("press_part", "buy")
	await _frames(4)
	if not (_gs.get("owned_paid_seasons") as Array).has(id) or int(_gs.get("wallet_coins")) != 3:
		_fail("second tap on Home should buy Coral for %d" % price)
		return
	if str(stage.call("get_toast_text")) != "Yours":
		_fail("Home should say Yours, got '%s'" % stage.call("get_toast_text"))
	_gs.set("wallet_coins", 3)
	stage.call("show_season", "starfall_glade", false)
	await _frames(3)
	stage.call("press_part", "buy")
	await _frames(3)
	var want := NEED % UiChrome.format_count(_price(STARFALL) - 3)
	if str(stage.call("get_need_text")) != want:
		_fail("Home without coins should show '%s', got '%s'" % [want, stage.call("get_need_text")])
	if (_gs.get("owned_paid_seasons") as Array).has("starfall_glade") or bool((content.get("data") as Dictionary).get("confirm", false)):
		_fail("Home without coins must not buy or arm")


# --- 5 Camp ---

func _check_camp() -> void:
	_reset()
	var unlocked: Array = _gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	_gs.set("unlocked_seasons", unlocked)
	var price := _price(MOONLIT)
	_gs.set("wallet_coins", price + 1)
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(12)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var camp: Node = host.get_node("Page_%d" % MetaHubPages.CAMP)
	var card: Control = camp.get_node("%SeasonLinkCard")
	var btn: Node = camp.get_node("%SeasonLinkUnlock")
	camp.call("refresh_for_meta_hub")
	await _frames(4)
	if not card.visible or not bool(card.call("is_paid")) or str(card.call("get_season_id")) != "moonlit_warren":
		_fail("Camp card should offer Moonlit Warren for coins")
		return
	if str(card.call("get_paid_button_state")) != "price" or str(card.call("get_price_text")) != UiChrome.format_count(price):
		_fail("Camp button should read %d, got %s / %s" % [price, card.call("get_paid_button_state"), card.call("get_price_text")])
		return
	await _tap(btn)
	if str(card.call("get_paid_button_state")) != "confirm" or int(_gs.get("wallet_coins")) != price + 1:
		_fail("first tap in Camp should only arm the confirm")
		return
	await _tap(btn)
	if not (_gs.get("owned_paid_seasons") as Array).has("moonlit_warren") or int(_gs.get("wallet_coins")) != 1:
		_fail("second tap in Camp should buy Moonlit Warren")
		return
	if str(card.call("get_paid_button_state")) != "burst":
		_fail("Camp should play the unlock burst, got %s" % card.call("get_paid_button_state"))
	await create_timer(2.0).timeout
	camp.call("refresh_for_meta_hub")
	await _frames(4)
	_gs.set("wallet_coins", 0)
	card.call("refresh")
	await _frames(2)
	if str(card.call("get_paid_button_state")) != "short":
		_fail("Camp without coins should be short, got %s" % card.call("get_paid_button_state"))
		return
	var next_def: SeasonDef = SeasonCatalog.get_def(str(card.call("get_season_id")))
	await _tap(btn)
	var want := NEED % UiChrome.format_count(_price(next_def.iap_product_id))
	if str(card.call("get_need_text")) != want:
		_fail("Camp without coins should show '%s', got '%s'" % [want, card.call("get_need_text")])
	if (_gs.get("owned_paid_seasons") as Array).has(str(card.call("get_season_id"))):
		_fail("Camp without coins must not buy")
