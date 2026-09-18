extends SceneTree

## CAMP3-C / design_handoff_camp — hero kartica sljedece sezone: tap vodi na Home
## bez trosenja; Unlock trosi odmah (500 + 20 ★3), burst na kartici, pa Home.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const S1 := "country_bloom"
const S2 := "frost_orchard"

var _backup: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("camp_season_link_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
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


func _center_y(node: Control) -> float:
	return node.global_position.y + node.size.y * 0.5


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 100)
	gs.set("garden_crystal_stash", {"pumpkin": 3})
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
	if absf(card.size.y - 422.0) > 1.5 or absf(card.size.x - 1032.0) > 1.5:
		_fail("hero card expected 1032 × 422 got %s" % str(card.size))
		return
	var title: Label = camp.get_node_or_null("%SeasonLinkTitle") as Label
	var eyebrow: Label = camp.get_node_or_null("%SeasonEyebrow") as Label
	if title == null or title.text != "Frost Orchard" or eyebrow == null or eyebrow.text != "Next free season":
		_fail("hero must read 'Next free season' / 'Frost Orchard'")
		return
	if title.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("SeasonLinkTitle must IGNORE")
		return
	var coins_lbl: Label = camp.get_node_or_null("%SeasonLinkCoins") as Label
	var t3_lbl: Label = camp.get_node_or_null("%SeasonLinkT3") as Label
	var coins_bar: ProgressBar = camp.get_node_or_null("%SeasonLinkCoinsBar") as ProgressBar
	var t3_bar: ProgressBar = camp.get_node_or_null("%SeasonLinkT3Bar") as ProgressBar
	if coins_lbl == null or t3_lbl == null or coins_bar == null or t3_bar == null:
		_fail("progress widgets missing")
		return
	if coins_lbl.text != "100 / 500" or t3_lbl.text != "3 / 20":
		_fail("progress expected '100 / 500' + '3 / 20' got '%s' + '%s'" % [coins_lbl.text, t3_lbl.text])
		return
	if coins_lbl.get_theme_font_size("font_size") < 44:
		_fail("season numbers must be >= 44 px")
		return
	var coin_icon: TextureRect = camp.get_node_or_null("%SeasonLinkCoinIcon") as TextureRect
	if coin_icon == null or coin_icon.texture == null:
		_fail("SeasonLink coin icon missing texture")
		return
	var flower_name: Label = camp.get_node_or_null("%SeasonLinkFlowerName") as Label
	if flower_name == null or flower_name.text.findn("Harvest Pumpkin") < 0 or flower_name.text.find("★★★") < 0:
		_fail("flower caption should be 'Harvest Pumpkin ★★★', got '%s'" % (flower_name.text if flower_name else ""))
		return
	var flower_art: Control = camp.get_node_or_null("%SeasonLinkFlower") as Control
	if absf(_center_y(coin_icon) - _center_y(flower_art)) > 2.0:
		_fail("coin icon and flower art must share a row")
		return
	if absf(_center_y(coins_bar) - _center_y(t3_bar)) > 2.0:
		_fail("bars must share a row")
		return
	if not is_equal_approx(coins_bar.max_value, 500.0) or not is_equal_approx(coins_bar.value, 100.0):
		_fail("coins bar expected 100/500")
		return
	if not is_equal_approx(t3_bar.max_value, 20.0) or not is_equal_approx(t3_bar.value, 3.0):
		_fail("T3 bar expected 3/20")
		return
	if coins_bar.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("SeasonLinkCoinsBar must IGNORE")
		return
	var unlock_btn: Control = camp.get_node_or_null("%SeasonLinkUnlock") as Control
	if unlock_btn == null:
		_fail("SeasonLinkUnlock missing")
		return
	if unlock_btn.mouse_filter != Control.MOUSE_FILTER_IGNORE or not bool(unlock_btn.get("disabled")):
		_fail("unaffordable Camp Unlock must be disabled and IGNORE")
		return
	if str(card.call("get_state")) != "short":
		_fail("unaffordable card state should be short")
		return
	if str(unlock_btn.call("get_sub")) != "needs 400 more coins and 17 more flowers":
		_fail("Unlock sub should list what is missing, got '%s'" % str(unlock_btn.call("get_sub")))
		return
	if unlock_btn.size.y < 132.0 - 1.5 or absf(unlock_btn.size.x - 988.0) > 2.0:
		_fail("Unlock must span the card (988 × 132), got %s" % str(unlock_btn.size))
		return

	var coins_before: int = int(gs.get("wallet_coins"))
	var unlocked_before: Array = (gs.get("unlocked_seasons") as Array).duplicate()
	card.call("navigate_to_lock")
	for _n in 12:
		await process_frame
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("card tap should go to Home, page=%s" % str(hub.call("current_page_index")))
		return
	if str(gs.get("focus_season_id")) != S2 or str(gs.get("home_band")) != "free":
		_fail("card tap must focus Frost on the free band")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("home_season_field_open should be false")
		return
	if int(gs.get("wallet_coins")) != coins_before or bool(gs.call("is_season_playable", S2)):
		_fail("card tap must not spend or unlock")
		return
	if (gs.get("unlocked_seasons") as Array).size() != unlocked_before.size():
		_fail("unlocked_seasons size must not change on camp card tap")
		return
	var home: Node = _page(hub, MetaHubPages.MAIN)
	var stage: Node = home.get_node_or_null("%SeasonStage") if home else null
	if stage == null:
		_fail("SeasonStage missing after card tap")
		return
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
	camp.call("refresh_for_meta_hub")
	for _q in 4:
		await process_frame
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	unlock_btn = camp.get_node_or_null("%SeasonLinkUnlock") as Control
	if not bool(gs.call("can_unlock_free", S2)) or str(card.call("get_state")) != "ready":
		_fail("Frost should be ready with 500c/20 Bloom star-3")
		return
	if unlock_btn.mouse_filter != Control.MOUSE_FILTER_STOP or bool(unlock_btn.get("disabled")):
		_fail("affordable Camp Unlock must be enabled and STOP")
		return
	if str(unlock_btn.call("get_title")) != "Unlock Frost Orchard":
		_fail("ready Unlock should read 'Unlock Frost Orchard', got '%s'" % str(unlock_btn.call("get_title")))
		return
	coins_before = int(gs.get("wallet_coins"))
	card.call("navigate_to_lock")
	for _nav in 12:
		await process_frame
	if int(gs.get("wallet_coins")) != coins_before or bool(gs.call("is_season_playable", S2)):
		_fail("affordable card tap must not spend or grant Frost")
		return

	_go_page(hub, MetaHubPages.CAMP)
	for _back in 8:
		await process_frame
	camp = _page(hub, MetaHubPages.CAMP)
	camp.call("refresh_for_meta_hub")
	for _rf in 4:
		await process_frame
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	unlock_btn = camp.get_node_or_null("%SeasonLinkUnlock") as Control
	coins_before = int(gs.get("wallet_coins"))
	card.call("_on_unlock_clicked")
	await process_frame
	# Trosi odmah, burst ostaje na Campu.
	if int(gs.get("wallet_coins")) != coins_before - 500:
		_fail("Unlock should spend 500 coins at once, before=%d after=%d" % [coins_before, int(gs.get("wallet_coins"))])
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("pumpkin", 0)) != 0 or not bool(gs.call("is_season_playable", S2)):
		_fail("Unlock should spend 20 pumpkin and grant Frost")
		return
	if str(card.call("get_state")) != "unlocking" or str(unlock_btn.call("get_title")) != "Frost Orchard unlocked":
		_fail("card must show the unlocking moment, state=%s title=%s" % [card.call("get_state"), unlock_btn.call("get_title")])
		return
	if int(hub.call("current_page_index")) != MetaHubPages.CAMP:
		_fail("burst plays on Camp before going Home")
		return
	await create_timer(1.2).timeout
	for _r in 8:
		await process_frame
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("Unlock should go to Home after the burst, page=%s" % str(hub.call("current_page_index")))
		return
	if str(gs.get("focus_season_id")) != S2:
		_fail("Home should focus the unlocked Frost")
		return

	_go_page(hub, MetaHubPages.CAMP)
	for _s in 6:
		await process_frame
	camp = _page(hub, MetaHubPages.CAMP)
	_unlock_all_free(gs)
	camp.call("refresh_for_meta_hub")
	for _t in 4:
		await process_frame
	if not str(gs.call("next_locked_free_id")).is_empty():
		_fail("next_locked_free_id should be empty after all free granted")
		return
	card = camp.get_node_or_null("%SeasonLinkCard") as Control
	if card == null or card.visible:
		_fail("SeasonLinkCard should hide when no next lock")
		return

	print("camp_season_link_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
