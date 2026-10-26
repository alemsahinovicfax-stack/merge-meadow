extends SceneTree

## MonetizationConfig.IAP_ENABLED = false (v1 samo s reklamama) — nijedna ponuda za pravi novac:
##  1. Shop: samo tab Looks (otvara se na njemu), bez kartica sezona / boostera / supporta / Sir Pipa;
##     kozmetika za coine ostaje;
##  2. IAPManager.purchase → "unavailable";
##  3. Settings: nema sekcije Purchases (RestoreButton), Privacy & help ostaje;
##  4. Home (SeasonStage): nema Premium taba dok igrač nema plaćenu sezonu; s kupljenom se vrati;
##  5. Ormar: Sir Pip se ne nudi; ako je već tvoj, stoji.
## Prekidač se postavlja kroz MonetizationConfig.iap_override (konstanta ostaje netaknuta).

const SIR_PIP := "pip_knight"
## Bez statičkih referenci na UI skripte: -s skripta se kompajlira prije autoloada (GameState,
## IAPManager), pa UiShopV2 / WardrobeSheet idu kroz load().
const UI_SHOP := "res://scripts/visual/ui_shop_v2.gd"
const WARDROBE := "res://scripts/ui/wardrobe_sheet.gd"
const CATALOG := "res://scripts/seasons/season_catalog.gd"
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
	MonetizationConfig.iap_override = 0
	var tabs: Array = (load(UI_SHOP) as Script).call("visible_tabs")
	if MonetizationConfig.iap_enabled() or tabs != ["looks"]:
		_fail("override 0 must turn IAP off (tabs %s)" % str(tabs))

	await _check_shop()
	_check_purchase()
	await _check_settings()
	await _check_stage(gs)
	await _check_wardrobe(cos)

	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("iap_off_smoke OK")
	quit(0)


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
	if labels != ["Looks"]:
		_fail("shop tabs should be only Looks, got %s" % str(labels))
	if str(shop.call("active_tab")) != "looks":
		_fail("shop should open on Looks, got %s" % str(shop.call("active_tab")))
	shop.call("select_tab", "seasons", false)
	if str(shop.call("active_tab")) != "looks":
		_fail("hidden Seasons tab must not open")
	for prefix in ["SeasonCard_", "BoosterCard_", "SupportCard_", "PremiumCard_"]:
		if not shop.find_children(prefix + "*", "", true, false).is_empty():
			_fail("shop still builds %s cards" % prefix)
	if shop.find_children("CosmeticCard_*", "", true, false).is_empty():
		_fail("coin cosmetics should stay in Looks")


func _check_purchase() -> void:
	var iap := get_root().get_node("IAPManager")
	var got := []
	var cb := func(sku: String, reason: String) -> void: got.append("%s:%s" % [sku, reason])
	iap.connect("purchase_failed", cb)
	iap.call("purchase", "remove_ads")
	iap.disconnect("purchase_failed", cb)
	if got != ["remove_ads:unavailable"]:
		_fail("purchase with IAP off should fail as unavailable, got %s" % str(got))


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
	settings.call("reopen")


func _check_stage(gs: Node) -> void:
	if change_scene_to_file("res://scenes/ui/season_stage.tscn") != OK:
		_fail("season stage scene failed")
		return
	await _frames(12)
	var stage := current_scene
	if bool(stage.call("has_premium_tab")):
		_fail("Premium tab should be hidden with IAP off and no paid season owned")
	var tabs := stage.find_child("SeasonTabs", true, false) as Control
	if tabs != null and tabs.is_visible_in_tree():
		_fail("SeasonTabs should be hidden")
	var paid: Array = (load(CATALOG) as Script).call("paid_defs")
	if paid.is_empty():
		_fail("catalog has no paid seasons")
		return
	gs.call("grant_paid_season", str(paid[0].get("id")))
	var ids: Array = stage.call("tab_ids", "premium")
	if ids != [str(paid[0].get("id"))]:
		_fail("owned paid season should stay on Premium tab, got %s" % str(ids))
	gs.call("clear_owned_paid_seasons")


func _check_wardrobe(cos: Object) -> void:
	var w: Control = (load(WARDROBE) as Script).new()
	get_root().add_child(w)
	await _frames(3)
	w.call("select_slot", "meadow_bg")
	w.call("select_slot", "pip_skin")
	await _frames(2)
	if w.call("get_card", SIR_PIP) != null:
		_fail("Wardrobe should not offer Sir Pip with IAP off")
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
		_fail("with IAP on the Wardrobe should offer Sir Pip again")
	MonetizationConfig.iap_override = 0
	w.queue_free()
