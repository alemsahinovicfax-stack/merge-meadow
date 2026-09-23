extends SceneTree

## Home — biranje sezone, smjer 1a Season Stage (design_handoff_home_v2).
## Jedna kartica, dock tokena, unlock, premium, Play = run aktivne sezone.
## Backup/restore pravog save-a.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

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
	push_error("season_home_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _card(stage: Node, id: String) -> Control:
	return stage.call("get_card", id) as Control


func _rgb_near(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.02 and absf(a.g - b.g) < 0.02 and absf(a.b - b.b) < 0.02


func _star3_for(gs: Node, season_id: String) -> String:
	return str(gs.call("star3_type_id_for_season", season_id))


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)
	var iap := _iap()
	if iap and iap.has_method("reset_purchases_for_dev"):
		iap.call("reset_purchases_for_dev")

	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(16)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(12)
	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	var host: Node = swipe.call("get_pages_host")
	var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN)
	if home == null:
		_fail("Home page missing")
		return
	home.call("refresh_for_meta_hub")
	await _frames(4)
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return

	if stage.get_node_or_null("%SeasonTrail") != null:
		_fail("SeasonTrail should be replaced by SeasonSelect")
		return
	var select := stage.get_node_or_null("%SeasonSelect") as Control
	if select == null or not select.visible:
		_fail("SeasonSelect missing")
		return
	var browser := select.get_node_or_null("SeasonBrowser") as Control
	if browser == null:
		_fail("SeasonBrowser missing")
		return
	var bloom := _card(stage, "country_bloom")
	if bloom == null:
		_fail("Country Bloom card missing")
		return
	var card_mid := bloom.get_global_rect().get_center()
	if not bool(swipe.call("should_block_hub_swipe_at", card_mid)):
		_fail("swipe on the season card must block the hub")
		return
	if bool(swipe.call("should_block_hub_swipe_at", browser.get_global_rect().get_center())):
		_fail("swipe on the season dock must reach the hub")
		return
	var bg := home.get_node_or_null("Background") as ColorRect
	if bg == null or not _rgb_near(bg.color, UiHome.PAGE_BG):
		_fail("Home background must be #243329")
		return

	var play := home.get_node_or_null("%PlayButton") as Control
	var gift := home.get_node_or_null("%DailyChestCard") as Control
	if play == null or gift == null or gift.get_parent() != home.get_node("%PlayRow"):
		_fail("Play row must hold Play and the daily gift")
		return
	if not is_equal_approx(play.size.y, UiHome.PLAY_H) or absf(play.size.x - 836.0) > 4.0:
		_fail("Play must be about 836 x 180, got %s" % str(play.size))
		return
	if not is_equal_approx(gift.size.x, 180.0) or not is_equal_approx(gift.size.y, 180.0):
		_fail("Daily gift must be 180 px, got %s" % str(gift.size))
		return
	if str(home.call("get_play_sub_text")) != "run in Country Bloom":
		_fail("Play sub expected 'run in Country Bloom' got '%s'" % str(home.call("get_play_sub_text")))
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("Play must name the active season")
		return
	if str(home.call("home_play_action")) != "run":
		_fail("Play must start a run directly")
		return
	var progress := home.get_node_or_null("%ProgressIndicator") as Control
	if progress == null or str(progress.call("get_text")) != "1 / 4":
		_fail("progress expected 1 / 4")
		return
	if str(stage.call("get_free_path_text")) != "1 / 4":
		_fail("free path label expected 1 / 4 got '%s'" % str(stage.call("get_free_path_text")))
		return

	if str(bloom.get("variant")) != UiHome.EXPANDED or not bool(bloom.call("is_active")):
		_fail("new player: Country Bloom must be the active card")
		return
	if not bool(bloom.call("has_roster")) or int(bloom.call("roster_count")) != 3:
		_fail("active card shows 3 roster flowers")
		return
	if not bool(bloom.call("has_open_button")) or not bool(bloom.call("has_playing_badge")):
		_fail("active card needs Open meadow and PLAYING")
		return
	if int(bloom.call("get_border_width")) != 8:
		_fail("active card rim must be 8")
		return
	if _card(stage, "frost_orchard") != null:
		_fail("Frost must not be the focused card yet")
		return
	var frost_token := stage.call("get_token", "frost_orchard") as Control
	var lantern_token := stage.call("get_token", "lantern_meadow") as Control
	if frost_token == null or lantern_token == null:
		_fail("free tokens missing")
		return

	stage.call("tap_token", "lantern_meadow")
	await _frames(4)
	if str(stage.call("focused_card_id")) != "country_bloom":
		_fail("far lock must not take focus")
		return
	if str(stage.call("get_toast_text")) != "Unlock Frost Orchard first":
		_fail("far lock toast got '%s'" % str(stage.call("get_toast_text")))
		return

	stage.call("tap_card", "frost_orchard")
	await _frames(3)
	var frost := _card(stage, "frost_orchard")
	if frost == null or str(frost.get("variant")) != UiHome.POSTER or str(frost.get("state")) != UiHome.ST_NEXT:
		_fail("Frost focus must open the gather poster")
		return
	if bool(frost.call("is_unlock_enabled")):
		_fail("Unlock must be disabled at 0 / 500")
		return
	if str(frost.call("get_unlock_title")) != "Needs 500 coins + 20 flowers":
		_fail("gather title got '%s'" % str(frost.call("get_unlock_title")))
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("previewing Frost must not change the active season")
		return
	if str(home.call("get_play_sub_text")) != "run in Country Bloom":
		_fail("Play stays on the active season while previewing")
		return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "country_bloom"): 20})
	stage.call("refresh")
	await _frames(2)
	if str(frost.get("state")) != UiHome.ST_READY or not bool(frost.call("is_unlock_enabled")):
		_fail("Frost must be ready to unlock")
		return
	if str(frost.call("get_unlock_title")) != "Unlock Frost Orchard":
		_fail("ready title got '%s'" % str(frost.call("get_unlock_title")))
		return

	frost.emit_signal("unlock_pressed", "frost_orchard")
	await _frames(2)
	if int(gs.get("wallet_coins")) != 0 or not bool(gs.call("is_season_playable", "frost_orchard")):
		_fail("Unlock must spend immediately")
		return
	if str(frost.get("state")) != UiHome.ST_UNLOCKING:
		_fail("unlocking frame missing")
		return
	var burst := frost.get_node_or_null("CardBody/SeasonArt/UnlockBurst") as Control
	if burst == null or not burst.visible:
		_fail("Unlock ring must play")
		return
	await _wait(0.55)
	frost = _card(stage, "frost_orchard")
	if frost == null or str(frost.get("variant")) != UiHome.EXPANDED or not bool(frost.call("is_active")):
		_fail("after unlock Frost must be the active card")
		return
	if str(progress.call("get_text")) != "2 / 4" or str(home.call("get_play_chip_text")) != "Frost Orchard":
		_fail("progress / play must follow the unlock")
		return
	if str(stage.call("get_toast_text")).find("unlocked") < 0:
		_fail("unlock toast missing, got '%s'" % str(stage.call("get_toast_text")))
		return

	stage.call("tap_card", "country_bloom")
	await _frames(2)
	if str(gs.get("active_season_id")) != "frost_orchard" or _card(stage, "country_bloom") == null:
		_fail("previewing an open season must not change the active season")
		return
	stage.call("tap_card", "country_bloom")
	await _frames(3)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("active_season_id")) != "country_bloom":
		_fail("second tap on an open season must open the field and make it active")
		return
	if select.visible:
		_fail("field open hides the season select")
		return
	if gift.is_visible_in_tree():
		_fail("field open hides the daily gift")
		return
	stage.call("close_season_field")
	await _frames(3)
	if not select.visible or not gift.visible:
		_fail("close field brings select and the gift back")
		return

	stage.call("tap_card", "coral_tide")
	await _frames(3)
	var coral := _card(stage, "coral_tide")
	if coral == null or str(coral.get("variant")) != UiHome.PREMIUM:
		_fail("premium token must open the preview card")
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("premium preview must not change the active season")
		return
	if str(coral.call("get_cta_title")) != "Get Coral Tide Garden" or not bool(coral.call("is_cta_enabled")):
		_fail("premium buy title got '%s'" % str(coral.call("get_cta_title")))
		return
	if str(coral.call("get_price_text")).is_empty() or int(coral.call("roster_count")) != 6:
		_fail("premium preview needs a price and 6 flowers")
		return
	var ember := stage.call("get_token", "ember_fen") as Control
	if ember == null:
		_fail("Ember Fen token missing")
		return
	stage.call("tap_token", "ember_fen")
	await _frames(2)
	var ember_card := _card(stage, "ember_fen")
	if ember_card == null or str(ember_card.get("state")) != UiHome.ST_SOON:
		_fail("Ember Fen must be coming soon")
		return
	if str(ember_card.call("get_cta_title")) != "Coming soon" or bool(ember_card.call("is_cta_enabled")):
		_fail("Ember Fen has no buy button")
		return
	if not str(ember_card.call("get_price_text")).is_empty():
		_fail("Ember Fen must not show a price")
		return

	stage.call("tap_card", "coral_tide")
	await _frames(2)
	coral = _card(stage, "coral_tide")
	coral.emit_signal("cta_pressed", "coral_tide")
	await _frames(2)
	if str(coral.get("state")) != UiHome.ST_BUSY or bool(coral.call("is_cta_enabled")):
		_fail("purchase in progress disables Buy")
		return
	if str(coral.call("get_cta_title")) != "Waiting for store…":
		_fail("purchasing title got '%s'" % str(coral.call("get_cta_title")))
		return
	await _wait(1.3)
	if not bool(gs.call("is_season_playable", "coral_tide")) or str(gs.get("active_season_id")) != "coral_tide":
		_fail("purchase must grant and activate Coral Tide")
		return
	coral = _card(stage, "coral_tide")
	if coral == null or not bool(coral.call("is_active")) or not bool(coral.call("has_open_button")):
		_fail("owned premium becomes the active card with Open meadow")
		return
	if str(home.call("get_play_chip_text")) != "Coral Tide Garden":
		_fail("play must follow the purchased season")
		return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "frost_orchard"): 20})
	if not bool(gs.call("unlock_free", "lantern_meadow")):
		_fail("Lantern unlock for Camp arrival failed")
		return
	gs.call("set_free_strip_focus", "lantern_meadow")
	gs.call("set_home_band", "free")
	home.call("refresh_for_meta_hub")
	await _frames(3)
	var lantern := _card(stage, "lantern_meadow")
	if lantern == null or str(lantern.get("variant")) != UiHome.EXPANDED or not bool(lantern.call("is_active")):
		_fail("arrival from Camp: Lantern is focused and active")
		return
	var lantern_burst := lantern.get_node_or_null("CardBody/SeasonArt/UnlockBurst") as Control
	if lantern_burst != null and lantern_burst.visible:
		_fail("arrival from Camp must not replay the unlock ring")
		return
	if str(stage.call("get_toast_text")) != "Unlocked in Camp · now playing":
		_fail("camp toast got '%s'" % str(stage.call("get_toast_text")))
		return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "lantern_meadow"): 20})
	if not bool(gs.call("unlock_free", "amber_canopy")):
		_fail("Amber unlock failed")
		return
	home.call("refresh_for_meta_hub")
	await _frames(3)
	if str(progress.call("get_text")) != "4 / 4":
		_fail("all free: progress 4 / 4")
		return
	if stage.call("get_token", "coral_tide") == null:
		_fail("premium tokens stay on the dock when the free path is done")
		return

	gs.set("last_daily_chest_day", "")
	home.call("_refresh_chest_card")
	var caption := home.get_node_or_null("%DailyCaption") as Label
	if caption == null or caption.text != "Tap to open" or not bool(home.call("is_chest_attention_active")):
		_fail("ready daily gift: Tap to open + attention")
		return
	home.call("_finish_chest_claim")
	if caption.text != "Back tomorrow" or bool(home.call("is_chest_attention_active")):
		_fail("claimed daily gift: Back tomorrow, no attention")
		return
	gs.set("tutorial_complete", false)
	home.call("refresh_for_meta_hub")
	await _frames(3)
	var hint := home.get_node_or_null("%TutorialHintPanel") as Control
	if hint == null or not hint.visible or gift.visible:
		_fail("tutorial: hint visible, daily gift hidden")
		return
	if hint.get_global_rect().end.y > play.get_global_rect().position.y + 8.0:
		_fail("tutorial hint must sit above Play")
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("season_home_smoke OK")
	quit(0)
