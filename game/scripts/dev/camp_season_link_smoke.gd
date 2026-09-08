extends SceneTree

## CAMP3-C + star-3 — camp next-lock: card navigates; Unlock spends after Home delay.

const SAVE_PATH := "user://player_save.json"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const S1 := "country_bloom"
const S2 := "frost_orchard"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("camp_season_link_smoke: %s" % msg)
	quit(1)


func _page(hub: Node, index: int) -> Node:
	var swipe: Node = hub.get_node_or_null("RootVBox/SwipePager")
	if swipe == null or not swipe.has_method("get_pages_host"):
		return null
	var host: Node = swipe.call("get_pages_host")
	if host == null:
		return null
	return host.get_node_or_null("Page_%d" % index)


func _go_page(hub: Node, index: int) -> void:
	if hub.has_method("go_to_page"):
		hub.call("go_to_page", index, false)


func _unlock_all_free(gs: Node) -> void:
	var unlocked: Array = gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	gs.set("unlocked_seasons", unlocked)


func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 100)
	gs.set("garden_crystal_stash", {"pumpkin": 3})
	gs.call("reset_seasons_to_s1")
	gs.call("debug_playtest_two_free")
	var unlocked_fx: Array = gs.get("unlocked_seasons")
	var paid_fx: Array = gs.get("owned_paid_seasons")
	if (
		unlocked_fx.size() != 2
		or not unlocked_fx.has(S1)
		or not unlocked_fx.has(S2)
	):
		_fail("debug_playtest_two_free should unlock Bloom+Frost, got %s" % str(unlocked_fx))
		return
	if not paid_fx.is_empty():
		_fail("debug_playtest_two_free must leave paid empty, got %s" % str(paid_fx))
		return
	if str(gs.call("next_locked_free_id")) != "lantern_meadow":
		_fail(
			"two-free next lock should be lantern_meadow, got '%s'"
			% str(gs.call("next_locked_free_id"))
		)
		return
	gs.call("reset_seasons_to_s1")
	gs.set("home_season_field_open", true)
	gs.set("home_season_field_id", S1)

	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	for _i in 16:
		await process_frame

	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub: Node = hubs[0]
	_go_page(hub, MetaHubPages.CAMP)
	for _j in 12:
		await process_frame

	var camp: Node = _page(hub, MetaHubPages.CAMP)
	if camp == null:
		_fail("Camp page missing")
		return
	if camp.has_method("refresh_for_meta_hub"):
		camp.call("refresh_for_meta_hub")
	for _k in 6:
		await process_frame

	var card: Control = camp.get_node_or_null("%SeasonLinkCard") as Control
	if card == null or not card.visible:
		_fail("SeasonLinkCard should be visible for next-lock Frost")
		return
	if card.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("SeasonLinkCard must STOP")
		return
	var title: Label = camp.get_node_or_null("%SeasonLinkTitle") as Label
	if title == null or title.text.find("Frost Orchard") < 0:
		_fail("title should be Frost Orchard, got '%s'" % (title.text if title else ""))
		return
	if title.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("SeasonLinkTitle must IGNORE")
		return
	var coins_lbl: Label = camp.get_node_or_null("%SeasonLinkCoins") as Label
	var seeds_lbl: Label = camp.get_node_or_null("%SeasonLinkT3") as Label
	var coins_bar: ProgressBar = camp.get_node_or_null("%SeasonLinkCoinsBar") as ProgressBar
	var t3_bar: ProgressBar = camp.get_node_or_null("%SeasonLinkT3Bar") as ProgressBar
	if coins_lbl == null or seeds_lbl == null or coins_bar == null or t3_bar == null:
		_fail("progress widgets missing")
		return
	if coins_lbl.text != "100 / 500":
		_fail("coins label expected '100 / 500' got '%s'" % coins_lbl.text)
		return
	if seeds_lbl.text != "3 / 20":
		_fail("star-3 count expected '3 / 20' got '%s'" % seeds_lbl.text)
		return
	var coin_icon: TextureRect = camp.get_node_or_null("%SeasonLinkCoinIcon") as TextureRect
	if coin_icon == null or coin_icon.texture == null:
		_fail("SeasonLink coin icon missing texture")
		return
	var flower_name: Label = camp.get_node_or_null("%SeasonLinkFlowerName") as Label
	if flower_name == null or flower_name.text.findn("Harvest Pumpkin") < 0:
		_fail("SeasonLink flower should be Harvest Pumpkin, got '%s'" % (flower_name.text if flower_name else ""))
		return
	var camp_progress: Control = camp.get_node_or_null("%SeasonUnlockProgress") as Control
	var split_row: Control = camp_progress.get_node_or_null("SplitRow") as Control if camp_progress else null
	if camp_progress == null or split_row == null:
		_fail("SeasonUnlockProgress must have SplitRow")
		return
	if split_row.get_node_or_null("CoinCol") == null or split_row.get_node_or_null("FlowerCol") == null:
		_fail("SplitRow must have CoinCol and FlowerCol")
		return
	if split_row.get_node_or_null("SectionDivider") == null:
		_fail("SplitRow must have vertical SectionDivider")
		return
	if coins_lbl.get_theme_font_size("font_size") < 28:
		_fail("Camp coins font must be >= 28, got %s" % coins_lbl.get_theme_font_size("font_size"))
		return
	var camp_flower: Control = camp_progress.find_child("SeasonLinkFlower", true, false) as Control
	if camp_flower == null or not is_equal_approx(
		coin_icon.custom_minimum_size.x, camp_flower.custom_minimum_size.x
	):
		_fail(
			"SeasonLink coin and flower icon side should match (~88), coin=%s flower=%s"
			% [
				str(coin_icon.custom_minimum_size.x),
				str(camp_flower.custom_minimum_size.x if camp_flower else 0.0),
			]
		)
		return
	if not is_equal_approx(coins_bar.max_value, 500.0) or not is_equal_approx(coins_bar.value, 100.0):
		_fail("coins bar expected 100/500 got %s/%s" % [str(coins_bar.value), str(coins_bar.max_value)])
		return
	if not is_equal_approx(t3_bar.max_value, 20.0) or not is_equal_approx(t3_bar.value, 3.0):
		_fail("T3 bar expected 3/20 got %s/%s" % [str(t3_bar.value), str(t3_bar.max_value)])
		return
	if coins_bar.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("SeasonLinkCoinsBar must IGNORE")
		return
	var garden: Control = camp.get_node_or_null("%GardenCard") as Control
	if garden == null:
		_fail("GardenCard missing")
		return
	if card.size.y + 1.0 < garden.size.y:
		_fail(
			"SeasonLinkCard should be at least GardenCard height, card=%s garden=%s"
			% [str(card.size.y), str(garden.size.y)]
		)
		return
	var unlock_btn: Control = camp.get_node_or_null("%SeasonLinkUnlock") as Control
	if unlock_btn == null:
		_fail("SeasonLinkUnlock missing")
		return
	if unlock_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("unaffordable Camp Unlock must IGNORE")
		return
	if not bool(unlock_btn.get("disabled")):
		_fail("unaffordable Camp Unlock must be disabled")
		return
	if str(unlock_btn.get("button_variant")) != "subtle":
		_fail("unaffordable Camp Unlock should be subtle, got %s" % str(unlock_btn.get("button_variant")))
		return
	var upgrades: CanvasItem = camp.get_node_or_null("%UpgradeCards") as CanvasItem
	if upgrades == null or upgrades.visible:
		_fail("UpgradeCards should stay hidden")
		return
	var seed_scroll: Control = camp.get_node_or_null("%SeedBagScroll") as Control
	var crystal_scroll: Control = camp.get_node_or_null("%CrystalScroll") as Control
	if seed_scroll == null or crystal_scroll == null:
		_fail("SeedBagScroll/CrystalScroll missing")
		return
	var exchange_btn: Control = camp.get_node_or_null("%ExchangeButton") as Control
	if exchange_btn == null or absf(unlock_btn.size.x - exchange_btn.size.x) > 8.0:
		_fail(
			"Unlock width must match Exchange, unlock=%s exchange=%s"
			% [
				str(unlock_btn.size.x if unlock_btn else 0.0),
				str(exchange_btn.size.x if exchange_btn else 0.0),
			]
		)
		return

	var coins_before: int = int(gs.get("wallet_coins"))
	var unlocked_before: Array = gs.get("unlocked_seasons")
	if card.has_method("navigate_to_lock"):
		card.call("navigate_to_lock")
	for _n in 12:
		await process_frame

	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("card tap should go to Home, page=%s" % str(hub.call("current_page_index")))
		return
	if str(gs.get("focus_season_id")) != S2:
		_fail("strip_focus should be frost_orchard, got %s" % str(gs.get("focus_season_id")))
		return
	if str(gs.get("home_band")) != "free":
		_fail("home_band should be free")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("home_season_field_open should be false")
		return
	if int(gs.get("wallet_coins")) != coins_before:
		_fail("wallet_coins must not change on camp card tap")
		return
	if not bool(gs.call("is_season_playable", S1)):
		_fail("Bloom must stay playable")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("Frost must stay locked after camp card tap")
		return
	var unlocked_after: Array = gs.get("unlocked_seasons")
	if unlocked_after.has(S2):
		_fail("camp card tap must not append frost_orchard")
		return
	if unlocked_before.size() != unlocked_after.size():
		_fail("unlocked_seasons size must not change on camp card tap")
		return
	var home: Node = _page(hub, MetaHubPages.MAIN)
	if home == null:
		_fail("Home page missing after card tap")
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing after card tap")
		return
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	var gate: Control = stage.get_node_or_null("%UnlockGate") as Control
	if gate == null or not gate.visible:
		_fail("Home UnlockGate should be visible on locked Frost")
		return

	_go_page(hub, MetaHubPages.CAMP)
	for _p in 8:
		await process_frame
	camp = _page(hub, MetaHubPages.CAMP)
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"pumpkin": 20})
	if camp.has_method("refresh_for_meta_hub"):
		camp.call("refresh_for_meta_hub")
	for _q in 4:
		await process_frame
	if not bool(gs.call("can_unlock_free", S2)):
		_fail("Frost should be affordable with 500c/20 Bloom star-3")
		return
	coins_before = int(gs.get("wallet_coins"))
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	if card == null or not card.visible:
		_fail("SeasonLinkCard should stay visible when Frost is affordable")
		return
	unlock_btn = camp.get_node_or_null("%SeasonLinkUnlock") as Control
	if unlock_btn == null:
		_fail("SeasonLinkUnlock missing when affordable")
		return
	if unlock_btn.mouse_filter != Control.MOUSE_FILTER_STOP:
		_fail("affordable Camp Unlock must STOP")
		return
	if bool(unlock_btn.get("disabled")):
		_fail("affordable Camp Unlock must be enabled")
		return
	if str(unlock_btn.get("button_variant")) != "gold":
		_fail("affordable Camp Unlock should be gold, got %s" % str(unlock_btn.get("button_variant")))
		return
	if card.has_method("navigate_to_lock"):
		card.call("navigate_to_lock")
	for _nav in 12:
		await process_frame
	if int(gs.get("wallet_coins")) != coins_before:
		_fail("affordable card tap must not spend coins")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("affordable card tap must not grant Frost")
		return

	_go_page(hub, MetaHubPages.CAMP)
	for _back in 8:
		await process_frame
	camp = _page(hub, MetaHubPages.CAMP)
	if camp.has_method("refresh_for_meta_hub"):
		camp.call("refresh_for_meta_hub")
	for _rf in 4:
		await process_frame
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	if card == null or not card.visible:
		_fail("SeasonLinkCard missing before Unlock spend")
		return
	coins_before = int(gs.get("wallet_coins"))
	if card.has_method("_on_unlock_clicked"):
		card.call("_on_unlock_clicked")
	await create_timer(0.7).timeout
	for _r in 8:
		await process_frame
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("Unlock should go to Home, page=%s" % str(hub.call("current_page_index")))
		return
	if int(gs.get("wallet_coins")) != coins_before - 500:
		_fail(
			"affordable camp Unlock should spend 500 coins, before=%d after=%d"
			% [coins_before, int(gs.get("wallet_coins"))]
		)
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("pumpkin", 0)) != 0:
		_fail("affordable camp Unlock should spend 20 pumpkin, got %s" % str(stash.get("pumpkin", 0)))
		return
	if not bool(gs.call("is_season_playable", S2)):
		_fail("affordable camp Unlock should grant Frost")
		return

	_go_page(hub, MetaHubPages.CAMP)
	for _s in 6:
		await process_frame
	camp = _page(hub, MetaHubPages.CAMP)
	_unlock_all_free(gs)
	if camp.has_method("refresh_for_meta_hub"):
		camp.call("refresh_for_meta_hub")
	for _t in 4:
		await process_frame
	var next_id := str(gs.call("next_locked_free_id"))
	if not next_id.is_empty():
		_fail("next_locked_free_id should be empty after all free granted, got %s" % next_id)
		return
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	if card == null or card.visible:
		_fail("SeasonLinkCard should hide when no next lock")
		return

	print("camp_season_link_smoke OK")
	quit(0)
