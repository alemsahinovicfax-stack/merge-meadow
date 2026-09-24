extends SceneTree

## Home — Season Stage pass 2 / 1a (design_handoff_home_v2): raspored 1:1 s
## SeasonStage.dc.html, stanja kartice, dock, swipe, unlock, premium, Camp dolazak,
## poklon i tutorial hint.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const TOL := 1.5

var _backup := ""
var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


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


func _rect_is(c: Control, expected: Rect2) -> bool:
	var r := c.get_global_rect()
	return r.position.distance_to(expected.position) <= TOL and absf(r.size.x - expected.size.x) <= TOL and absf(r.size.y - expected.size.y) <= TOL


func _overflow(n: Node, page: Rect2) -> String:
	for child in n.get_children():
		var c := child as Control
		if c != null:
			if not c.visible:
				continue
			var r := c.get_global_rect()
			if r.size.x > 0.5 and r.size.y > 0.5 and not page.grow(TOL).encloses(r):
				return "%s %s" % [str(c.get_path()), str(r)]
		var deeper := _overflow(child, page)
		if not deeper.is_empty():
			return deeper
	return ""


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
	gs.call("clear_owned_paid_seasons")
	gs.set("tutorial_complete", true)
	var iap := get_root().get_node_or_null("IAPManager")
	if iap and iap.has_method("reset_purchases_for_dev"):
		iap.call("reset_purchases_for_dev")

	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(16)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(12)
	var swipe := hub.get_node("RootVBox/SwipePager") as Control
	var host: Node = swipe.call("get_pages_host")
	var home := host.get_node_or_null("Page_%d" % MetaHubPages.MAIN) as Control
	if home == null:
		_fail("Home page missing")
		return
	home.call("refresh_for_meta_hub")
	await _frames(4)
	var stage := home.get_node_or_null("%SeasonStage") as Control
	var browser := stage.get_node_or_null("%SeasonBrowser") as SeasonBrowser
	var clip := stage.get_node_or_null("%CardClip") as Control
	var play := home.get_node_or_null("%PlayButton") as Control
	var gift := home.get_node_or_null("%DailyChestCard") as Control
	var play_row := home.get_node_or_null("%PlayRow") as Control
	if stage == null or browser == null or clip == null or play == null or gift == null or play_row == null:
		_fail("stage / dock / PlayRow nodes missing")
		return

	# --- raspored: SeasonStage.dc.html (stranica 1080 x 1597 od y=143) ---
	var page := swipe.get_global_rect()
	if not page.is_equal_approx(Rect2(0, 143, 1080, 1597)):
		_fail("hub content should be 1080 x 1597 at y 143, got %s" % str(page))
		return
	var bloom := stage.call("get_card", "country_bloom") as HomeSeasonCard
	if bloom == null or not bloom.visible or not _rect_is(bloom, Rect2(24, 167, 1032, 1100)):
		_fail("SeasonCard must be 1032 x 1100 at (24, 167), got %s" % str(bloom.get_global_rect() if bloom else Rect2()))
		return
	if not _rect_is(browser, Rect2(0, 1291, 1080, 222)):
		_fail("SeasonBrowser must be 1080 x 222 at (0, 1291), got %s" % str(browser.get_global_rect()))
		return
	if not _rect_is(play_row, Rect2(24, 1537, 1032, 180)):
		_fail("PlayRow must be 1032 x 180 at (24, 1537), got %s" % str(play_row.get_global_rect()))
		return
	if not _rect_is(play, Rect2(24, 1537, 836, 180)) or not _rect_is(gift, Rect2(876, 1537, 180, 180)):
		_fail("Play 836 x 180 + Gift 180 expected, got %s / %s" % [str(play.get_global_rect()), str(gift.get_global_rect())])
		return
	if gift.get_parent() != play_row:
		_fail("DailyChestCard must sit in PlayRow")
		return
	var spill := _overflow(home, page)
	if not spill.is_empty():
		_fail("nothing may spill off the Home page: %s" % spill)
		return
	var bg := home.get_node("Background") as ColorRect
	if not bg.color.is_equal_approx(UiStage.PAGE_BG):
		_fail("Home background must be #243329, got %s" % bg.color.to_html(false))
		return
	if not clip.is_in_group("block_hub_swipe"):
		_fail("CardClip must block hub swipe")
		return
	if bool(swipe.call("should_block_hub_swipe_at", browser.get_global_rect().get_center())):
		_fail("hub swipe must pass over the dock")
		return
	if bool(swipe.call("should_block_hub_swipe_at", play.get_global_rect().get_center())):
		_fail("hub swipe must pass over the Play row")
		return
	var art := bloom.get_part_rect("art")
	if absf(art.size.y - 446.0) > TOL or absf(art.position.y - 26.0) > TOL:
		_fail("active card art slot expected 446 px at y 26, got %s" % str(art))
		return

	# --- novi igrac: Bloom aktivna, Frost next lock, Lantern/Amber daleko ---
	if str(stage.call("get_free_path_text")) != "Free path 1 / 4":
		_fail("dock free path expected 'Free path 1 / 4' got '%s'" % str(stage.call("get_free_path_text")))
		return
	var bloom_token := browser.get_token("country_bloom")
	var frost_token := browser.get_token("frost_orchard")
	var amber_token := browser.get_token("amber_canopy")
	var moon_token := browser.get_token("moonlit_warren")
	if bloom_token == null or frost_token == null or moon_token == null:
		_fail("dock tokens missing")
		return
	if absf(bloom_token.get_global_rect().position.x - 20.0) > TOL or absf(moon_token.get_global_rect().position.x - 550.0) > TOL:
		_fail("tokens at x 20 (free) and 550 (premium) expected")
		return
	if absf(bloom_token.base_position.y + 1291.0 - 1366.0) > TOL or not bloom_token.is_lifted():
		_fail("focused token row at y 1366, lifted 6 px")
		return
	if bloom_token.status != HomeDockToken.S_OPEN or not bloom_token.active or frost_token.status != HomeDockToken.S_NEXT:
		_fail("dock: Bloom open+active, Frost next lock")
		return
	if amber_token.status != HomeDockToken.S_FAR or browser.get_token("ember_fen").status != HomeDockToken.S_SOON:
		_fail("dock: Amber far lock, Ember soon")
		return
	if bloom.state != HomeSeasonCard.ST_ACTIVE or bloom.get_badge_text() != "PLAYING" or bloom.get_rim_width() != 8:
		_fail("Bloom card must be active with ▶ PLAYING and 8 px rim")
		return
	if bloom.shown_flower_names() != PackedStringArray(["Meadow Clover", "Barn Tulip", "Harvest Pumpkin"]):
		_fail("Bloom roster must show clover / tulip / pumpkin, got %s" % str(bloom.shown_flower_names()))
		return
	if bloom.get_meta_text() != "FREE · 1 OF 4" or bloom.get_count_text() != "6 flowers · 3 shown":
		_fail("title meta/count: '%s' / '%s'" % [bloom.get_meta_text(), bloom.get_count_text()])
		return
	if not bloom.has_open_button() or bloom.hit_part(bloom.get_part_rect("prev").get_center()) != HomeSeasonCard.PART_NONE:
		_fail("Open meadow expected; prev arrow disabled on the first page")
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom" or str(home.call("home_play_action")) != "run":
		_fail("Play must run in Country Bloom")
		return

	# --- daleki lock: shake + tamni toast, fokus ostaje ---
	stage.call("tap_card", "lantern_meadow")
	await _frames(2)
	if str(stage.call("focused_card_id")) != "country_bloom":
		_fail("far lock must not take focus")
		return
	if not browser.get_token("lantern_meadow").is_shaking() or str(stage.call("get_toast_text")) != "Unlock Frost Orchard first":
		_fail("far lock tap: shake + 'Unlock Frost Orchard first' toast")
		return

	# --- swipe na kartici: lijevo = sljedeca (Frost), na krajevima rubber-band ---
	stage.call("_pointer", Vector2(500, 500), true)
	stage.call("_drag", Vector2(560, 500))
	await _frames(1)
	if bloom.position.x > UiStage.RUBBER + 0.5 or bloom.position.x <= 0.0:
		_fail("rubber-band at the first page expected (0, 40], got %s" % str(bloom.position.x))
		return
	stage.call("_pointer", Vector2(560, 500), false)
	await _wait(0.35)
	if bloom.position.x != 0.0 or str(stage.call("focused_card_id")) != "country_bloom":
		_fail("rubber-band must snap back on Bloom")
		return
	stage.call("_pointer", Vector2(700, 500), true)
	stage.call("_drag", Vector2(500, 500))
	stage.call("_drag", Vector2(420, 500))
	await _frames(1)
	var frost := stage.call("get_card", "frost_orchard") as HomeSeasonCard
	if not frost.visible or absf(frost.position.x - (1080.0 - 280.0)) > TOL:
		_fail("neighbor Frost must peek at +1080 during the drag, got %s" % str(frost.position.x))
		return
	stage.call("_pointer", Vector2(420, 500), false)
	await _wait(0.35)
	if str(stage.call("focused_card_id")) != "frost_orchard" or not frost.visible or bloom.visible:
		_fail("swipe left must page to Frost")
		return
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("card swipe must not move the hub")
		return
	if str(gs.get("active_season_id")) != "country_bloom" or str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("focus != active: Play stays on Country Bloom while previewing Frost")
		return
	if frost.state != HomeSeasonCard.ST_GATHER or frost.get_badge_text() != "PREVIEW · LOCKED" or frost.get_rim_width() != 4:
		_fail("Frost gather: PREVIEW · LOCKED, 4 px rim")
		return
	if frost.get_unlock_title() != "Needs 500 coins + 20 flowers" or frost.get_unlock_sub() != "run in Country Bloom to collect":
		_fail("gather button text: '%s' / '%s'" % [frost.get_unlock_title(), frost.get_unlock_sub()])
		return
	if frost.is_unlock_enabled() or absf(frost.get_part_rect("art").size.y - 228.0) > TOL:
		_fail("gather: Unlock disabled, art slot 228 px")
		return
	if not frost_token.focused or not frost_token.is_lifted() or bloom_token.focused:
		_fail("dock focus must follow the card")
		return

	# --- unlock: 500 + 20 ★3, trenutak 420 ms, pa aktivna + toast ---
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {str(gs.call("star3_type_id_for_season", "country_bloom")): 20})
	stage.call("refresh")
	await _frames(2)
	if frost.state != HomeSeasonCard.ST_READY or not frost.is_unlock_enabled():
		_fail("Frost must be ready")
		return
	if frost.get_unlock_title() != "Unlock Frost Orchard" or frost.get_unlock_sub() != "spends 500 coins + 20 Harvest Pumpkin":
		_fail("ready text: '%s' / '%s'" % [frost.get_unlock_title(), frost.get_unlock_sub()])
		return
	frost.emit_signal("unlock_pressed", "frost_orchard")
	await _frames(1)
	if int(gs.get("wallet_coins")) != 0 or not bool(gs.call("is_season_playable", "frost_orchard")):
		_fail("Unlock must spend immediately")
		return
	if frost.state != HomeSeasonCard.ST_UNLOCKING or not frost.is_unlock_playing() or frost.get_unlock_title() != "Unlocking…":
		_fail("unlocking moment expected")
		return
	if str(home.call("get_play_chip_text")) != "Frost Orchard":
		_fail("Play must switch to the unlocked season")
		return
	await _wait(0.6)
	if frost.state != HomeSeasonCard.ST_ACTIVE or str(stage.call("get_toast_text")) != "Frost Orchard unlocked · now playing":
		_fail("after unlock: Frost active + gold toast, got %s / '%s'" % [frost.state, str(stage.call("get_toast_text"))])
		return
	if str(stage.call("get_free_path_text")) != "Free path 2 / 4" or browser.get_token("lantern_meadow").status != HomeDockToken.S_NEXT:
		_fail("dock after unlock: 2 / 4, Lantern next lock")
		return

	# --- otkljucana ali ne aktivna: preview, tap otvara polje i postaje aktivna ---
	stage.call("tap_card", "country_bloom")
	await _wait(0.35)
	if bloom.state != HomeSeasonCard.ST_OPEN or bloom.get_badge_text() != "PREVIEW · UNLOCKED":
		_fail("Bloom preview while Frost is active")
		return
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("previewing Bloom must not change the active season")
		return
	stage.call("tap_card", "country_bloom")
	await _wait(0.35)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("tap on the focused open card must open the field")
		return
	if (stage.get_node("%SelectLayer") as Control).visible or gift.visible:
		_fail("field open: SelectLayer and Gift hidden")
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("opening the field makes the season active")
		return
	stage.call("close_season_field")
	await _wait(0.3)
	if not (stage.get_node("%SelectLayer") as Control).visible or not gift.visible:
		_fail("close field: SelectLayer + Gift back")
		return

	# --- premium: pregled 6 cvjetova, kupovina, Ember soon ---
	stage.call("tap_card", "coral_tide")
	await _wait(0.4)
	var coral := stage.call("get_card", "coral_tide") as HomeSeasonCard
	if coral == null or not coral.visible or coral.state != HomeSeasonCard.ST_PREMIUM:
		_fail("Coral Tide premium preview expected")
		return
	if coral.shown_flower_count() != 6 or coral.get_count_text() != "6 flowers" or coral.get_meta_text() != "PREMIUM PACK":
		_fail("premium preview shows all 6 flowers")
		return
	if coral.get_badge_text() != "PREVIEW · PREMIUM" or coral.get_buy_title() != "Get Coral Tide Garden" or coral.get_price_text().is_empty():
		_fail("premium: badge / 'Get Coral Tide Garden' / price")
		return
	if absf(coral.get_part_rect("art").size.y - 248.0) > TOL:
		_fail("premium art slot 248 px expected, got %s" % str(coral.get_part_rect("art")))
		return
	coral.emit_signal("cta_pressed", "coral_tide")
	await _frames(2)
	if coral.state != HomeSeasonCard.ST_PURCHASING or coral.get_buy_title() != "Waiting for store…" or coral.is_buy_enabled():
		_fail("purchasing: Waiting for store…, Buy disabled")
		return
	if str(home.call("home_play_action")) != "run":
		_fail("Play keeps working while the purchase runs")
		return
	await _wait(1.3)
	if not bool(gs.call("is_season_playable", "coral_tide")) or str(gs.get("active_season_id")) != "coral_tide":
		_fail("purchase must grant + activate Coral Tide")
		return
	if coral.state != HomeSeasonCard.ST_ACTIVE or str(stage.call("get_toast_text")) != "Coral Tide Garden is yours · now playing":
		_fail("bought: active card + toast, got %s / '%s'" % [coral.state, str(stage.call("get_toast_text"))])
		return
	if browser.get_token("coral_tide").status != HomeDockToken.S_OPEN or str(home.call("get_play_chip_text")) != "Coral Tide Garden":
		_fail("bought pack: ✓ token + Play renamed")
		return
	stage.call("tap_card", "ember_fen")
	await _wait(0.4)
	var ember := stage.call("get_card", "ember_fen") as HomeSeasonCard
	if ember.state != HomeSeasonCard.ST_SOON or ember.get_info_title() != "Coming soon" or ember.hit_part(ember.get_part_rect("next").get_center()) != HomeSeasonCard.PART_NONE:
		_fail("Ember Fen: Coming soon, last page (next arrow off)")
		return

	# --- dolazak iz Campa: toast, bez ponovnog unlock trenutka ---
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {str(gs.call("star3_type_id_for_season", "frost_orchard")): 20})
	if not bool(gs.call("unlock_free", "lantern_meadow")):
		_fail("Lantern unlock for Camp arrival failed")
		return
	gs.call("set_free_strip_focus", "lantern_meadow")
	gs.call("set_home_band", "free")
	home.call("refresh_for_meta_hub")
	await _frames(3)
	var lantern := stage.call("get_card", "lantern_meadow") as HomeSeasonCard
	if str(stage.call("focused_card_id")) != "lantern_meadow" or lantern.state != HomeSeasonCard.ST_ACTIVE:
		_fail("Camp arrival: Lantern focused + active")
		return
	if lantern.is_unlock_playing() or str(stage.call("get_toast_text")) != "Unlocked in Camp · now playing":
		_fail("Camp arrival: toast, no second unlock moment")
		return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {str(gs.call("star3_type_id_for_season", "lantern_meadow")): 20})
	if not bool(gs.call("unlock_free", "amber_canopy")):
		_fail("Amber unlock failed")
		return
	home.call("refresh_for_meta_hub")
	await _frames(3)
	if str(stage.call("get_free_path_text")) != "Free path 4 / 4":
		_fail("all free: dock 4 / 4")
		return
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]:
		var c := stage.call("get_card", id) as HomeSeasonCard
		if c.is_gate() or browser.get_token(id).status != HomeDockToken.S_OPEN:
			_fail("all free: no lock left (%s)" % id)
			return

	# --- Daily gift: roze tacka dok je spreman ---
	gs.set("last_daily_chest_day", "")
	home.call("_refresh_chest_card")
	if not bool(home.call("is_gift_claimable")):
		_fail("ready daily gift shows the pink dot")
		return
	home.call("_finish_chest_claim")
	if bool(home.call("is_gift_claimable")) or not gift.visible:
		_fail("claimed gift: visible, no dot")
		return
	var overlay := home.get_node("%RewardOverlay") as Control
	overlay.visible = false

	# --- prva sesija: oblacic + prsten oko Play ---
	gs.set("tutorial_complete", false)
	home.call("refresh_for_meta_hub")
	await _frames(3)
	var stage_hint := home.get_node_or_null("%StageHint") as Control
	var hint_panel := home.get_node_or_null("%TutorialHintPanel") as Control
	if stage_hint == null or not stage_hint.visible or hint_panel.visible:
		_fail("first session: StageHint visible, old hint panel hidden")
		return
	if not gift.visible or bool(home.call("is_gift_claimable")):
		_fail("first session: Gift stays in the row, without the dot")
		return
	spill = _overflow(home, page)
	if not spill.is_empty():
		_fail("first session: nothing may spill off the page: %s" % spill)
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("season_home_smoke OK")
	quit(0)
