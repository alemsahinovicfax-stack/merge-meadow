extends SceneTree

## design_handoff_ads_only u igri: tenda puni 1032 px (3 taba 336 / x 24·372·720, 4 taba 249 /
## x 24·285·546·807), coin cijena fiksne širine u svakom stanju (S 300 · M 320 · L 360, potvrda
## +0 px), broj „10,000", oblačić „Need N more coins" iznad dugmeta, oznaka „Special" (L / M / S),
## Home tabovi „Journey / Themes" i nigdje „Premium" na tim mjestima u v1.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const MOONLIT := "season_pack_moonlit_warren"

var _backup := ""
var _failed := false
# Klase koje vise o autoloadima učitavaju se tek u _run (SceneTree skripta se kompajlira prije njih).
var Shop: GDScript
var Price: GDScript
var Tag: GDScript
var Tabs: GDScript


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("ads_only_design_smoke: %s" % msg)
	_failed = true


func _iap() -> Node:
	return get_root().get_node("IAPManager")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	Shop = load("res://scripts/visual/ui_shop_v2.gd")
	Price = load("res://scripts/visual/ui_coin_price.gd")
	Tag = load("res://scripts/ui/special_tag.gd")
	Tabs = load("res://scripts/ui/home_v3_tabs.gd")
	MonetizationConfig.iap_override = 0
	_check_tabs()
	_check_sizes()
	await _check_shop()
	await _check_home()
	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("ads_only_design_smoke OK")
	quit(0)


func _check_tabs() -> void:
	for want in [[3, 336, 348, 24], [4, 249, 261, 24]]:
		var n: int = want[0]
		var got := [n, Shop.call("tab_w", n), Shop.call("tab_step", n), Shop.call("tab_x0", n)]
		if got != want:
			_fail("tabs n=%d should be %s, got %s" % [n, str(want), str(got)])
	# Srednji od 3 taba stoji na sredini tende (x 540).
	var mid: int = int(Shop.call("tab_x0", 3)) + int(Shop.call("tab_step", 3)) + int(Shop.call("tab_w", 3)) / 2
	if mid != 540:
		_fail("middle tab of 3 should be centered on 540, got %d" % mid)


func _check_sizes() -> void:
	var want := {"S": Vector2(300, 120), "M": Vector2(320, 120), "L": Vector2(360, 132)}
	for k in want:
		if Price.call("button_size", k) != want[k]:
			_fail("coin price %s should be %s, got %s" % [k, want[k], Price.call("button_size", k)])
	if Price.call("price_text", 10000) != "10,000":
		_fail("price should read 10,000")
	# „10,000" na 44 px staje u S (300) s novčićem 48 i razmakom 12, uz zrak sa strana.
	var inner := 48.0 + 12.0 + float(load("res://scripts/visual/ui_home_v3.gd").call("text_w", 900, 44, "10,000", 0.0, true))
	if inner > 300.0 - 2.0 * 40.0:
		_fail("10,000 at 44 px should fit S with air, needs %.0f" % inner)
	var heights := {"L": 60.0, "M": 52.0, "S": 44.0}
	for k in heights:
		if (Tag.call("tag_size", k) as Vector2).y != heights[k]:
			_fail("Special %s should be h %d" % [k, heights[k]])


func _check_shop() -> void:
	if change_scene_to_file("res://scenes/ui/shop_screen.tscn") != OK:
		_fail("shop scene failed")
		return
	await _frames(20)
	var shop := current_scene
	var gs := get_root().get_node("GameState")
	gs.call("clear_owned_paid_seasons")
	var price: int = _iap().call("get_coin_price", MOONLIT)
	gs.set("wallet_coins", price + 5)
	shop.call("refresh_shop")
	await _frames(3)
	var bar := shop.find_child("ShopTabBar", true, false) as Control
	var tabs: Array = bar.call("get_tabs")
	var xs: Array = []
	for t in tabs:
		xs.append(int((t as Control).position.x))
		if int((t as Control).size.x) != 336:
			_fail("v1 tab should be 336 wide, got %s" % (t as Control).size.x)
	if xs != [24, 372, 720]:
		_fail("v1 tabs should sit at 24 / 372 / 720, got %s" % str(xs))
	var card: Node = shop.call("get_season_card", MOONLIT)
	var btn := card.get("buy") as Control
	var widths := {}
	widths["buy"] = btn.custom_minimum_size.x
	btn.emit_signal("clicked")
	await _frames(3)
	if str(card.call("get_state")) != "coins.confirm":
		_fail("first tap should arm the confirm, got %s" % card.call("get_state"))
	widths["confirm"] = btn.custom_minimum_size.x
	btn.emit_signal("clicked")
	await _frames(3)
	if str(card.call("get_state")) != "play" or not bool(btn.call("is_buying")):
		_fail("second tap should buy (play + buying ring), got %s / %s" % [card.call("get_state"), btn.call("is_buying")])
	widths["play"] = btn.custom_minimum_size.x
	gs.set("wallet_coins", 0)
	var coral: Node = shop.call("get_season_card", "season_pack_coral_tide")
	shop.call("refresh_shop")
	await _frames(3)
	var cbtn := coral.get("buy") as Control
	widths["short"] = cbtn.custom_minimum_size.x
	for k in widths:
		if float(widths[k]) != 300.0:
			_fail("season button should stay 300 wide in %s, got %s" % [k, widths[k]])
	cbtn.emit_signal("short_tapped")
	await _frames(3)
	var need := str(shop.call("get_need_text"))
	if need != "Need %s more coins" % UiChrome.format_count(int(_iap().call("get_coin_price", "season_pack_coral_tide"))):
		_fail("need bubble text wrong: '%s'" % need)
	var bubble := shop.find_child("NeedCoinsBubble", true, false) as Control
	if bubble == null or bubble.get_global_rect().end.y > cbtn.get_global_rect().position.y + 1.0:
		_fail("need bubble should sit above the button")
	var knight: Node = shop.call("get_premium_card", "pip_knight")
	var tag := knight.find_child("PremiumTag", true, false) if knight else null
	if tag == null or str(tag.get("size_key")) != "L":
		_fail("Sir Pip should carry the Special L tag")


func _check_home() -> void:
	if change_scene_to_file("res://scenes/ui/season_stage.tscn") != OK:
		_fail("season stage scene failed")
		return
	await _frames(12)
	var stage := current_scene
	var consts: Dictionary = Tabs.get_script_constant_map()
	if consts.get("LABEL_FREE") != "Journey" or consts.get("LABEL_PREMIUM") != "Themes":
		_fail("Home tabs should read Journey / Themes")
	var gs := get_root().get_node("GameState")
	gs.call("clear_owned_paid_seasons")
	gs.set("wallet_coins", 4200)
	stage.call("refresh")
	stage.call("show_season", "moonlit_warren", false)
	await _frames(3)
	var content: Control = stage.call("get_card_content")
	if (content.call("part_rect", "buy") as Rect2).size != Vector2(360, 132):
		_fail("Home theme price should be L 360 x 132")
	if not bool(content.call("has_savings")) or str(content.call("savings_text")) != "4,200 / 10,000":
		_fail("savings pill should read 4,200 / 10,000, got '%s'" % content.call("savings_text"))
	MonetizationConfig.iap_override = 1
	stage.call("refresh")
	await _frames(2)
	if bool(content.call("has_savings")):
		_fail("savings pill must hide with IAP on")
	MonetizationConfig.iap_override = 0
