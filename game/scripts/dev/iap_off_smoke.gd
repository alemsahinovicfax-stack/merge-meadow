extends SceneTree

## MonetizationConfig.IAP_ENABLED = false (v1 samo s reklamama, 2026-10-26) — nijedna ponuda za pravi
## novac; ono što se prodavalo pravim novcem nudi se za coine (IAPManager.buy_with_coins):
##  1. Shop: tabovi Seasons · Looks · Boosters (otvara se na Seasons), nema Supporta (Remove Ads,
##     Starter Pack, Restore); teme, Merge Hint, Loot Burst i Sir Pip s coin cijenom (Ember dok nije
##     u igri ne); kozmetika za coine ostaje;
##  2. IAPManager.purchase → "unavailable"; Billing se ne spaja (nema klijenta);
##  3. Settings: nema sekcije Purchases (RestoreButton), Privacy & help ostaje;
##  4. Home (SeasonStage): Premium tab s temama za coine (bez Embera), kartica nosi coin cijenu;
##  5. Ormar: Sir Pip se nudi (pod velom, tap vodi u Shop); kupljen stoji; s IAP-om isto;
##  6. Camp: kad su sve besplatne sezone otključane, kartica nudi prvu temu za coine;
##  7. nigdje na tim ekranima „€", „$", „Restore purchases", „Purchase cancelled" ni billing poruka.
## Prekidač se postavlja kroz MonetizationConfig.iap_override (konstanta ostaje netaknuta).

const SIR_PIP := "pip_knight"
## Bez statičkih referenci na UI skripte: -s skripta se kompajlira prije autoloada (GameState,
## IAPManager), pa UiShopV2 / WardrobeSheet idu kroz load().
const UI_SHOP := "res://scripts/visual/ui_shop_v2.gd"
const WARDROBE := "res://scripts/ui/wardrobe_sheet.gd"
const CATALOG := "res://scripts/seasons/season_catalog.gd"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
## Tekst koji u v1 ne smije postojati (mala slova).
const BANNED: Array[String] = ["€", "$", "restore purchases", "purchases restored", "purchase cancelled", "billing"]
var _backup := ""
var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("iap_off_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node("GameState")
	var cos: Object = gs.get("cosmetics")
	cos.set("owned", {})
	gs.call("clear_owned_paid_seasons")
	gs.set("merge_hint_owned", false)
	gs.call("reset_seasons_to_s1")
	MonetizationConfig.iap_override = 0
	var tabs: Array = (load(UI_SHOP) as Script).call("visible_tabs")
	if MonetizationConfig.iap_enabled() or tabs != ["seasons", "looks", "boosters"]:
		_fail("override 0 must turn IAP off (tabs %s)" % str(tabs))

	await _check_shop()
	_check_purchase()
	await _check_settings()
	await _check_stage(gs)
	await _check_wardrobe(cos)
	await _check_camp(gs)

	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("iap_off_smoke OK")
	quit(0)


## Tekst koji ekran nosi ili crta (Labeli, dugmad, statusi, cijene, podaci kartica).
func _all_text(root: Node) -> String:
	var out := ""
	for n in root.find_children("*", "", true, false):
		if n is Label:
			out += (n as Label).text + "\n"
		for prop in ["price", "owned_label", "text", "title", "label", "status_text", "data"]:
			if prop in n:
				out += str(n.get(prop)) + "\n"
	return out


func _scan(root: Node, where: String) -> void:
	var text := _all_text(root).to_lower()
	for word in BANNED:
		if text.contains(word):
			_fail("%s shows '%s' without IAP" % [where, word])


func _check_shop() -> void:
	if change_scene_to_file("res://scenes/ui/shop_screen.tscn") != OK:
		_fail("shop scene failed")
		return
	await _frames(20)
	var shop := current_scene as Control
	var tabs: Array = (shop.call("get_tab_bar") as Node).call("get_tabs")
	var labels: Array[String] = []
	for t in tabs:
		labels.append(str(t.get("label")))
	if labels != ["Seasons", "Looks", "Boosters"]:
		_fail("shop tabs should be Seasons · Looks · Boosters, got %s" % str(labels))
	if str(shop.call("active_tab")) != "seasons":
		_fail("shop should open on Seasons, got %s" % str(shop.call("active_tab")))
	shop.call("select_tab", "support", false)
	if str(shop.call("active_tab")) != "seasons":
		_fail("hidden Support tab must not open")
	if not shop.find_children("SupportCard_*", "", true, false).is_empty() or shop.find_child("RestoreLink", true, false) != null:
		_fail("shop still builds Support (Remove Ads / Starter Pack / Restore)")
	var iap := get_root().get_node("IAPManager")
	var seasons := shop.find_children("SeasonCard_*", "", true, false)
	var want_seasons := 0
	for def in (load(CATALOG) as Script).call("paid_defs"):
		if bool(iap.call("is_coin_offer", def.iap_product_id)):
			want_seasons += 1
	if seasons.size() != want_seasons or want_seasons < 3:
		_fail("expected %d season cards for coins, got %d" % [want_seasons, seasons.size()])
	if shop.find_child("SeasonCard_ember_fen", true, false) != null \
			and bool(get_root().get_node("GameState").call("is_test_locked_season", "ember_fen")):
		_fail("Ember Fen must stay hidden while it is not in the game")
	for card in seasons:
		_check_coin_card(card, str(card.get("sku")), iap)
	for booster_id in ["merge_hint", "loot_burst"]:
		var card: Node = shop.call("get_booster_card", booster_id)
		if card == null:
			_fail("Boosters should offer %s for coins" % booster_id)
			continue
		_check_coin_card(card, str(card.get("sku")), iap)
	var knight: Node = shop.call("get_premium_card", SIR_PIP)
	if knight == null:
		_fail("Looks should offer Sir Pip for coins")
	else:
		_check_coin_card(knight, SIR_PIP, iap)
	if shop.find_children("CosmeticCard_*", "", true, false).is_empty():
		_fail("coin cosmetics should stay in Looks")
	_scan(shop, "Shop")


## Kartica u coin stanju: dugme nosi coin cijenu (broj), ne € iz Playa.
func _check_coin_card(card: Node, sku: String, iap: Node) -> void:
	var state := str(card.call("get_state"))
	if not state.begins_with("coins."):
		_fail("%s should be a coin offer, got %s" % [sku, state])
		return
	var btn: Node = card.get("buy")
	var price := int(iap.call("get_coin_price", sku))
	if price <= 0 or str(btn.get("price")) != str(price):
		_fail("%s button should show %d coins, got '%s'" % [sku, price, btn.get("price")])


func _check_purchase() -> void:
	var iap := get_root().get_node("IAPManager")
	var got := []
	var cb := func(sku: String, reason: String) -> void: got.append("%s:%s" % [sku, reason])
	iap.connect("purchase_failed", cb)
	iap.call("purchase", "remove_ads")
	iap.disconnect("purchase_failed", cb)
	if got != ["remove_ads:unavailable"]:
		_fail("purchase with IAP off should fail as unavailable, got %s" % str(got))
	if iap.get("_billing_client") != null or not bool(iap.call("is_stub_mode")):
		_fail("Billing must not connect without IAP")


func _check_settings() -> void:
	if change_scene_to_file("res://scenes/ui/settings_screen.tscn") != OK:
		_fail("settings scene failed")
		return
	await _frames(10)
	var settings := current_scene
	if settings.find_child("RestoreButton", true, false) != null:
		_fail("Settings should not build Restore purchases")
	if settings.find_child("Section_Purchases", true, false) != null:
		_fail("Settings should not build the Purchases section")
	if settings.find_child("LinkRow_PrivacyChoices", true, false) == null:
		_fail("Privacy choices must stay")
	_scan(settings, "Settings")
	settings.call("reopen")


func _check_stage(gs: Node) -> void:
	if change_scene_to_file("res://scenes/ui/season_stage.tscn") != OK:
		_fail("season stage scene failed")
		return
	await _frames(12)
	var stage := current_scene
	if not bool(stage.call("has_premium_tab")):
		_fail("Premium tab should show the themes for coins")
	var want: Array = []
	for def in (load(CATALOG) as Script).call("paid_defs"):
		if bool(get_root().get_node("IAPManager").call("is_coin_offer", def.iap_product_id)):
			want.append(def.id)
	var ids: Array = stage.call("tab_ids", "premium")
	if ids != want or want.size() < 3:
		_fail("Premium tab should list the coin themes %s, got %s" % [str(want), str(ids)])
	if ids.has("ember_fen") and bool(gs.call("is_test_locked_season", "ember_fen")):
		_fail("Premium tab must hide Ember Fen while it is not in the game")
	stage.call("show_season", "moonlit_warren", false)
	await _frames(3)
	var tabs := stage.find_child("SeasonTabs", true, false) as Control
	if tabs == null or not tabs.is_visible_in_tree():
		_fail("SeasonTabs should be visible")
	var data: Dictionary = (stage.call("get_card_content") as Node).get("data")
	if int(data.get("coin_price", 0)) <= 0 or str(stage.call("card_status", "moonlit_warren")) != "buy":
		_fail("Moonlit card should be a coin buy, got %s" % str(data))
	_scan(stage, "Home")


func _check_wardrobe(cos: Object) -> void:
	var w: Control = (load(WARDROBE) as Script).new()
	get_root().add_child(w)
	await _frames(3)
	w.call("select_slot", "meadow_bg")
	w.call("select_slot", "pip_skin")
	await _frames(2)
	if w.call("get_card", SIR_PIP) == null:
		_fail("Wardrobe should offer Sir Pip (for coins in the Shop)")
	cos.set("owned", {SIR_PIP: true})
	w.call("select_slot", "meadow_bg")
	w.call("select_slot", "pip_skin")
	await _frames(2)
	if w.call("get_card", SIR_PIP) == null:
		_fail("owned Sir Pip must stay in the Wardrobe")
	cos.set("owned", {})
	MonetizationConfig.iap_override = 1
	w.call("select_slot", "meadow_bg")
	w.call("select_slot", "pip_skin")
	await _frames(2)
	if w.call("get_card", SIR_PIP) == null:
		_fail("with IAP on the Wardrobe should offer Sir Pip too")
	MonetizationConfig.iap_override = 0
	_scan(w, "Wardrobe")
	w.queue_free()


func _check_camp(gs: Node) -> void:
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.call("reset_seasons_to_s1")
	var unlocked: Array = gs.get("unlocked_seasons")
	for def in (load(CATALOG) as Script).call("free_defs_sorted"):
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	gs.set("unlocked_seasons", unlocked)
	gs.call("clear_owned_paid_seasons")
	gs.set("wallet_coins", 0)
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(12)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var camp: Node = host.get_node("Page_%d" % MetaHubPages.CAMP)
	camp.call("refresh_for_meta_hub")
	await _frames(4)
	var card: Control = camp.get_node("%SeasonLinkCard")
	if not card.visible or not bool(card.call("is_paid")) or str(card.call("get_season_id")) != "moonlit_warren":
		_fail("Camp should offer the first theme for coins")
		return
	var title := str(camp.get_node("%SeasonLinkUnlock").call("get_title"))
	if not title.is_valid_int():
		_fail("Camp button should show a coin price, got '%s'" % title)
	_scan(camp, "Camp")
