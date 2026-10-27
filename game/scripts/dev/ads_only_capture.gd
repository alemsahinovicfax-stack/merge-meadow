extends SceneTree

## Dev: snimke za CD brief „v1 bez kupovina" (ads-only-cd-brief) — hub u SubViewportu 1080 x 1920:
##   Shop: 3 taba (Seasons · Looks · Boosters), teme za coine (fali / ima / potvrda / „Need N more
##   coins"), Boosters, Sir Pip u Looks, pa za poređenje Shop s kupovinama pravim novcem (4 taba, €);
##   Home: tab Free i tab Premium (coin pilula: ima / potvrda / fali + toast);
##   Camp: kartica teme poslije besplatnih sezona (cijena / potvrda / fali + pilula).
## Save se vraća na kraju. Pokretanje BEZ --headless (APPDATA kopija):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/ads_only_capture.gd
## JPG ide u $MM_OUT (ili %TEMP%/mm_design/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const POOR := 4200
const RICH := 12000

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node
var _hub: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_jpg(_out.path_join("%s.jpg" % shot), 0.88)
	print("captured ", shot)


func _page(index: int) -> Node:
	var host: Node = _hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	return host.get_node_or_null("Page_%d" % index)


func _wallet(n: int) -> void:
	_gs.set("wallet_coins", n)
	_hub.call("refresh_top_bar")


func _reset_state() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("reset_seasons_to_s1")
	_gs.call("clear_owned_paid_seasons")
	_gs.call("revoke_iap_cosmetics")
	_gs.set("merge_hint_owned", false)
	var cos: Object = _gs.get("cosmetics")
	cos.set("owned", {"meadow_sunset": true})
	cos.set("equipped", {"meadow_bg": "meadow_sunset"})


func _make_hub() -> void:
	if _hub != null:
		_hub.queue_free()
		await _frames(4)
	_hub = (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(_hub)
	await _frames(40)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	MonetizationConfig.iap_override = 0
	_reset_state()
	_gs.set("wallet_coins", POOR)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	await _make_hub()
	await _shop_shots()
	await _home_shots()
	await _camp_shots()
	# Poređenje: isti Shop s kupovinama pravim novcem (4 taba, € cijene).
	MonetizationConfig.iap_override = 1
	_reset_state()
	await _make_hub()
	_hub.call("go_to_page", MetaHubPages.SHOP, false)
	await _frames(20)
	var shop := _page(MetaHubPages.SHOP)
	shop.call("refresh_for_meta_hub")
	await _frames(10)
	await _capture("a15_shop_seasons_iap_on_4_tabs")
	MonetizationConfig.iap_override = -1
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _shop_shots() -> void:
	_hub.call("go_to_page", MetaHubPages.SHOP, false)
	await _frames(20)
	var shop := _page(MetaHubPages.SHOP)
	shop.call("refresh_for_meta_hub")
	await _frames(10)
	await _capture("a01_shop_seasons_coins_short")
	var moon: Node = shop.call("get_season_card", "season_pack_moonlit_warren")
	(moon.get("buy") as Node).emit_signal("short_tapped")
	await _frames(6)
	await _capture("a02_shop_seasons_need_more_coins")
	_wallet(RICH)
	shop.call("refresh_shop")
	await _frames(6)
	await _capture("a03_shop_seasons_coins_buy")
	(moon.get("buy") as Node).emit_signal("clicked")
	await _frames(6)
	await _capture("a04_shop_seasons_confirm")
	shop.call("_cancel_confirm")
	_wallet(POOR)
	shop.call("select_tab", "boosters", false)
	shop.call("refresh_shop")
	await _frames(8)
	await _capture("a05_shop_boosters_coins")
	shop.call("show_cosmetic_slot", "pip_skin", "pip_knight")
	await _frames(8)
	await _capture("a06_shop_looks_sir_pip_coins")


func _home_shots() -> void:
	_wallet(POOR)
	_hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(20)
	var home := _page(MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.call("refresh")
	stage.call("show_season", "country_bloom", false)
	await _frames(10)
	await _capture("a07_home_free_tab")
	stage.call("show_season", "frost_orchard", false)
	await _frames(8)
	await _capture("a08_home_free_tab_locked_next")
	_wallet(RICH)
	stage.call("refresh")
	stage.call("show_season", "moonlit_warren", false)
	await _frames(10)
	await _capture("a09_home_premium_coin_buy")
	stage.call("press_part", "buy")
	await _frames(6)
	await _capture("a10_home_premium_confirm")
	stage.call("_cancel_buy_confirm")
	_wallet(POOR)
	stage.call("refresh")
	stage.call("show_season", "coral_tide", false)
	await _frames(8)
	stage.call("press_part", "buy")
	await _frames(6)
	await _capture("a11_home_premium_short_toast")


func _camp_shots() -> void:
	var unlocked: Array = _gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	_gs.set("unlocked_seasons", unlocked)
	_gs.call("clear_owned_paid_seasons")
	_wallet(RICH)
	_hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(20)
	var camp := _page(MetaHubPages.CAMP)
	camp.call("refresh_for_meta_hub")
	await _frames(10)
	await _capture("a12_camp_theme_price")
	var btn: Node = camp.get_node("%SeasonLinkUnlock")
	btn.emit_signal("clicked")
	await _frames(6)
	await _capture("a13_camp_theme_confirm")
	var card: Node = camp.get_node("%SeasonLinkCard")
	card.set("_confirm_until", 0)
	_wallet(POOR)
	card.call("refresh")
	await _frames(4)
	btn.emit_signal("clicked")
	await _frames(6)
	await _capture("a14_camp_theme_short_toast")
