extends SceneTree

## Home — biranje sezone, smjer 1a Season Trail (design_handoff_home, 2026-09-21).
## Kolona kartica (harmonika), unlock s prstenom, premium sekcija i kupovina,
## dolazak iz Campa, Play = run odmah, daily gift. Backup/restore pravog save-a.

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


func _today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func _card(stage: Node, id: String) -> Control:
	return stage.call("get_card", id) as Control


func _rgb_near(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.01 and absf(a.g - b.g) < 0.01 and absf(a.b - b.b) < 0.01


func _star3_for(gs: Node, season_id: String) -> String:
	return str(gs.call("star3_type_id_for_season", season_id))


## Svi vidljivi elementi kolone + razmaci; otvorena kartica mora popuniti kolonu.
func _trail_used(stage: Node) -> float:
	var list := stage.get_node("%TrailList") as VBoxContainer
	var sep := list.get_theme_constant("separation")
	var used := 0.0
	var shown := 0
	for c in list.get_children():
		var ctrl := c as Control
		if ctrl == null or not ctrl.visible:
			continue
		used += ctrl.size.y
		shown += 1
	return used + float(sep * maxi(shown - 1, 0))


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

	# --- struktura: stari dvotrakasti stage, Browser i sheet su obrisani ---
	for gone in ["%BandColumn", "%PaidBand", "%FreeBand", "%SeasonBrowser", "%SeasonUnlockSheet", "%UnlockGate"]:
		if stage.get_node_or_null(gone) != null:
			_fail("%s should be removed" % gone)
			return
	for gone in ["DecorMoundLeft", "DecorMoundRight", "%PlayThemeBadge", "%PipPortrait"]:
		if home.get_node_or_null(gone) != null:
			_fail("%s should be removed" % gone)
			return
	if not stage.get_node("%SeasonTrail") is ScrollContainer:
		_fail("SeasonTrail must be a ScrollContainer")
		return
	if (stage as Control).is_in_group("block_hub_swipe"):
		_fail("1a: SeasonStage must not block hub swipe")
		return
	var stage_mid := (stage as Control).get_global_rect().get_center()
	if bool(swipe.call("should_block_hub_swipe_at", stage_mid)):
		_fail("1a: hub swipe must pass over the season trail")
		return
	var bg := home.get_node_or_null("Background") as ColorRect
	if bg == null or not _rgb_near(bg.color, UiHome.PAGE_BG):
		_fail("Home background must be #2E4733 like Camp")
		return

	# --- stranica: TopRow 130, ProgressIndicator 420, Play 1032 x 156 + cip ---
	var top_row := home.get_node_or_null("%TopRow") as Control
	var gift := home.get_node_or_null("%DailyChestCard") as Control
	var progress := home.get_node_or_null("%ProgressIndicator") as Control
	if top_row == null or gift == null or progress == null or gift.get_parent() != top_row:
		_fail("TopRow must hold DailyChestCard + ProgressIndicator")
		return
	if not is_equal_approx(top_row.size.y, UiHome.TOP_ROW_H):
		_fail("TopRow height %s expected 130" % str(top_row.size.y))
		return
	if not is_equal_approx(progress.size.x, UiHome.PROGRESS_W):
		_fail("ProgressIndicator width %s expected 420" % str(progress.size.x))
		return
	if str(progress.call("get_text")) != "1 / 4":
		_fail("progress expected 1 / 4 got %s" % str(progress.call("get_text")))
		return
	var play := home.get_node_or_null("%PlayButton") as Control
	if play == null or not is_equal_approx(play.size.y, UiHome.PLAY_H) or absf(play.size.x - 1032.0) > 1.0:
		_fail("Play must be 1032 x 156, got %s" % str(play.size if play else Vector2.ZERO))
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("Play chip expected Country Bloom got '%s'" % str(home.call("get_play_chip_text")))
		return
	if str(home.call("home_play_action")) != "run":
		_fail("Play must start a run directly (decision 2026-09-21)")
		return
	var column := home.get_node_or_null("%HomeColumn") as Control
	if not is_equal_approx(column.offset_left, 24.0) or not is_equal_approx(column.offset_top, 24.0):
		_fail("HomeColumn must sit on padding 24")
		return
	if top_row.get_global_rect().end.y > (stage as Control).get_global_rect().position.y:
		_fail("TopRow must sit above the trail")
		return

	# --- novi igrac: Bloom otvorena i aktivna, Frost next lock, dalje zakljucano ---
	var bloom := _card(stage, "country_bloom")
	var frost := _card(stage, "frost_orchard")
	var lantern := _card(stage, "lantern_meadow")
	var amber := _card(stage, "amber_canopy")
	if bloom == null or frost == null or lantern == null or amber == null:
		_fail("free season cards missing")
		return
	if str(bloom.get("variant")) != UiHome.EXPANDED or not bool(bloom.call("is_active")):
		_fail("new player: Country Bloom must be expanded + active")
		return
	if not bool(bloom.call("has_roster")) or not bool(bloom.call("has_open_button")) or not bool(bloom.call("has_playing_badge")):
		_fail("active card needs roster, Open meadow and Playing now")
		return
	if float(bloom.call("roster_art_side")) < 64.0 or float(bloom.call("roster_art_side")) > 116.0:
		_fail("roster art frame must be 64..116, got %s" % str(bloom.call("roster_art_side")))
		return
	if str(frost.get("variant")) != UiHome.NEXTLOCK or str(frost.get("state")) != UiHome.ST_NEXT:
		_fail("new player: Frost must be the compact next lock")
		return
	if str(frost.call("get_chip_text")) != "Next free season":
		_fail("next lock chip expected 'Next free season' got '%s'" % str(frost.call("get_chip_text")))
		return
	if str(frost.call("get_need_text")) != "Need 500 more coins and 20 more Harvest Pumpkin":
		_fail("next lock need line got '%s'" % str(frost.call("get_need_text")))
		return
	if str(lantern.get("state")) != UiHome.ST_LOCKED or not bool(lantern.call("has_lock")):
		_fail("Lantern must be locked with LockBox")
		return
	if str(lantern.call("get_status_text")) != "Opens after Frost Orchard":
		_fail("Lantern status got '%s'" % str(lantern.call("get_status_text")))
		return
	var locked_fill := UiHome.locked_fill(UiHome.mood("lantern_meadow"))
	if not _rgb_near(Color(lantern.call("get_fill_color")), locked_fill):
		_fail("locked fill must be derived from mood")
		return
	if int(bloom.call("get_border_width")) != UiHome.CARD_BORDER_ACTIVE:
		_fail("active card border must be 6")
		return
	var header := stage.call("get_premium_header") as Control
	if header == null or bool(stage.call("is_premium_open")):
		_fail("premium section must start closed on the free path")
		return
	if str(header.call("get_chevron_text")) != "4  ↓" or str(header.call("get_note_text")) != "Free path never needs them":
		_fail("closed premium row text wrong")
		return
	if _card(stage, "coral_tide") != null and _card(stage, "coral_tide").visible:
		_fail("premium cards must be hidden while the section is closed")
		return
	var trail := stage.get_node("%SeasonTrail") as Control
	if absf(_trail_used(stage) - trail.size.y) > 2.0:
		_fail("open card must fill the trail: used %.0f vs %.0f" % [_trail_used(stage), trail.size.y])
		return

	# --- tap na zakljucanu iza next locka = odbijanje, fokus se ne mijenja ---
	stage.call("tap_card", "lantern_meadow")
	await _frames(2)
	if str(stage.call("focused_card_id")) != "country_bloom":
		_fail("tap past next lock must bounce")
		return

	# --- tap na next lock = puni poster, Unlock mutno dok ne stigne oboje ---
	stage.call("tap_card", "frost_orchard")
	await _wait(0.35)
	if str(frost.get("variant")) != UiHome.POSTER:
		_fail("tap next lock must open the poster")
		return
	if bool(frost.call("is_unlock_enabled")):
		_fail("Unlock must be disabled at 0 / 500")
		return
	if str(frost.call("get_unlock_sub")) != "needs 500 more coins and 20 more Harvest Pumpkin":
		_fail("unlock sub got '%s'" % str(frost.call("get_unlock_sub")))
		return
	if str(bloom.get("variant")) != UiHome.COLLAPSED or str(bloom.call("get_status_text")) != "Tap to open the meadow ↗":
		_fail("collapsed active card must say Tap to open the meadow ↗")
		return
	if not bool(bloom.call("has_playing_badge")):
		_fail("collapsed active card keeps Playing now")
		return

	# --- spremno: 500 coina + 20 Harvest Pumpkin ---
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "country_bloom"): 20})
	stage.call("refresh")
	await _frames(2)
	if str(frost.get("state")) != UiHome.ST_READY or not bool(frost.call("is_unlock_enabled")):
		_fail("Frost must be ready with gold Unlock")
		return
	if str(frost.call("get_need_text")) != "Both ready — unlock it whenever you like.":
		_fail("ready need line got '%s'" % str(frost.call("get_need_text")))
		return
	if str(frost.call("get_unlock_sub")) != "spends 500 coins and 20 Harvest Pumpkin":
		_fail("ready unlock sub got '%s'" % str(frost.call("get_unlock_sub")))
		return

	# --- trenutak otkljucavanja: odmah trosi, prsten, pa otvorena sezona s "New" ---
	frost.emit_signal("unlock_pressed", "frost_orchard")
	await _frames(1)
	if int(gs.get("wallet_coins")) != 0 or not bool(gs.call("is_season_playable", "frost_orchard")):
		_fail("Unlock must spend immediately")
		return
	if str(frost.get("state")) != UiHome.ST_UNLOCKING or str(frost.call("get_unlock_title")) != "Frost Orchard unlocked":
		_fail("unlocking frame expected 'Frost Orchard unlocked' got '%s'" % str(frost.call("get_unlock_title")))
		return
	var burst := frost.get_node_or_null("UnlockBurst") as Control
	if burst == null or not burst.visible:
		_fail("UnlockBurst ring must play")
		return
	if bool(frost.call("has_new_badge")):
		_fail("New must wait until the ring is done")
		return
	if str(home.call("get_play_chip_text")) != "Frost Orchard":
		_fail("Play chip must switch to the unlocked season right away")
		return
	await _wait(1.2)
	if str(frost.get("variant")) != UiHome.EXPANDED or not bool(frost.call("is_active")):
		_fail("after unlock Frost must be the open active season")
		return
	if not bool(frost.call("has_new_badge")):
		_fail("fresh unlock must show New")
		return
	if str(lantern.get("variant")) != UiHome.NEXTLOCK:
		_fail("Lantern must become the next lock")
		return
	if str(progress.call("get_text")) != "2 / 4" or str(home.call("get_play_chip_text")) != "Frost Orchard":
		_fail("progress / play chip must follow the unlock")
		return

	# --- tap na otkljucanu zatvorenu = izaberi i otvori ---
	stage.call("tap_card", "country_bloom")
	await _wait(0.35)
	if str(gs.get("active_season_id")) != "country_bloom" or str(bloom.get("variant")) != UiHome.EXPANDED:
		_fail("tap on unlocked card must select + expand it")
		return
	if str(home.call("get_play_chip_text")) != "Country Bloom":
		_fail("play chip must follow the active season")
		return

	# --- tap na otvorenu aktivnu = polje sezone; nazad vraca kolonu ---
	stage.call("tap_card", "country_bloom")
	await _frames(3)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("tap on open active card must open the season field")
		return
	if trail.visible or not (stage.get_node("%SeasonField") as Control).visible:
		_fail("field open: trail hidden, field visible")
		return
	if top_row.visible:
		_fail("field open: TopRow hides (field keeps its own chrome)")
		return
	if not is_equal_approx(play.custom_minimum_size.y, 96.0):
		_fail("field open: Play returns to the 96 px field button")
		return
	stage.call("close_season_field")
	await _frames(3)
	if not trail.visible or not top_row.visible:
		_fail("close field: trail + TopRow must come back")
		return

	# --- premium: otvori sekciju, pregled prije kupovine, coming soon ---
	stage.call("toggle_premium")
	await _wait(0.35)
	var coral := _card(stage, "coral_tide")
	var ember := _card(stage, "ember_fen")
	if not bool(stage.call("is_premium_open")) or coral == null or not coral.visible:
		_fail("premium toggle must show premium cards")
		return
	if str(header.call("get_note_text")) != "Preview before you buy" or str(header.call("get_chevron_text")) != "↑":
		_fail("open premium header text wrong")
		return
	if str(coral.call("get_status_text")) != "Premium · preview inside" or str(coral.call("get_price_text")).is_empty():
		_fail("collapsed premium needs status + price tag")
		return
	if str(ember.get("state")) != UiHome.ST_SOON or str(ember.call("get_status_text")) != "Coming soon" or not bool(ember.call("has_lock")):
		_fail("Ember Fen must be a Coming soon card with lock")
		return
	var soon_fill := UiHome.soon_fill(UiHome.mood("ember_fen"))
	if not _rgb_near(Color(ember.call("get_fill_color")), soon_fill):
		_fail("coming soon fill must be derived from mood")
		return
	stage.call("tap_card", "coral_tide")
	await _wait(0.35)
	if str(coral.get("variant")) != UiHome.PREMIUM or str(gs.get("home_band")) != "paid":
		_fail("tap premium must open its preview")
		return
	if str(coral.call("get_cta_title")) != "Get Coral Tide Garden" or not bool(coral.call("is_cta_enabled")):
		_fail("premium CTA expected 'Get Coral Tide Garden' got '%s'" % str(coral.call("get_cta_title")))
		return
	if not bool(coral.call("has_roster")):
		_fail("premium preview shows the 6-flower roster")
		return
	if coral.size.y < 555.0:
		_fail("premium preview keeps its 556 px height when the list scrolls, got %s" % str(coral.size.y))
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("previewing premium must not change the active season")
		return

	# --- kupovina (stub 0,9 s): Purchasing… pa kupljena i aktivna ---
	coral.emit_signal("cta_pressed", "coral_tide")
	await _frames(2)
	if str(coral.get("state")) != UiHome.ST_BUSY or str(coral.call("get_cta_title")) != "Purchasing…" or bool(coral.call("is_cta_enabled")):
		_fail("purchase in progress must show disabled Purchasing…")
		return
	await _wait(1.3)
	if not bool(gs.call("is_season_playable", "coral_tide")) or str(gs.get("active_season_id")) != "coral_tide":
		_fail("purchase must grant + activate Coral Tide")
		return
	if str(coral.get("state")) != UiHome.ST_OWNED or str(coral.call("get_cta_title")) != "Open meadow ↗":
		_fail("owned premium CTA expected 'Open meadow ↗' got '%s'" % str(coral.call("get_cta_title")))
		return
	if not bool(coral.call("has_new_badge")):
		_fail("fresh purchase must show New")
		return
	if str(home.call("get_play_chip_text")) != "Coral Tide Garden":
		_fail("play chip must follow the purchased season")
		return
	stage.call("tap_card", "ember_fen")
	await _wait(0.35)
	if str(ember.call("get_cta_title")) != "Coming soon" or bool(ember.call("is_cta_enabled")):
		_fail("Ember Fen CTA must be disabled Coming soon")
		return

	# --- zatvori premium dok je fokus tamo = fokus nazad na besplatni put ---
	stage.call("toggle_premium")
	await _wait(0.35)
	if bool(stage.call("is_premium_open")) or str(gs.get("home_band")) != "free":
		_fail("closing premium must return focus to the free path")
		return

	# --- dolazak iz Campa: sezona vec otkljucana, fokus + New, bez prstena ---
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "frost_orchard"): 20})
	if not bool(gs.call("unlock_free", "lantern_meadow")):
		_fail("Lantern unlock for Camp arrival failed")
		return
	gs.call("set_free_strip_focus", "lantern_meadow")
	gs.call("set_home_band", "free")
	home.call("refresh_for_meta_hub")
	await _frames(3)
	if str(lantern.get("variant")) != UiHome.EXPANDED or not bool(lantern.call("has_new_badge")):
		_fail("arrival from Camp: Lantern open with New")
		return
	var lantern_burst := lantern.get_node_or_null("UnlockBurst") as Control
	if lantern_burst != null and lantern_burst.visible:
		_fail("arrival from Camp must not replay the unlock ring")
		return

	# --- sve 4 free: nema next locka, premium sekcija otvorena sama ---
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {_star3_for(gs, "lantern_meadow"): 20})
	if not bool(gs.call("unlock_free", "amber_canopy")):
		_fail("Amber unlock failed")
		return
	var fresh_stage := stage
	fresh_stage.set("_premium_user_set", false)
	home.call("refresh_for_meta_hub")
	await _frames(3)
	if str(progress.call("get_text")) != "4 / 4":
		_fail("all free: progress 4 / 4")
		return
	if not bool(stage.call("is_premium_open")):
		_fail("all free: premium section opens by default")
		return
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy"]:
		var c := _card(stage, id)
		if str(c.get("variant")) == UiHome.NEXTLOCK or str(c.get("variant")) == UiHome.POSTER:
			_fail("all free: no next lock card")
			return

	# --- daily gift + tutorial ---
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
	if absf(progress.size.x - top_row.size.x) > 1.0:
		_fail("tutorial: ProgressIndicator takes the whole row")
		return
	if hint.get_global_rect().end.y > play.get_global_rect().position.y:
		_fail("tutorial hint must float above Play")
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("season_home_smoke OK")
	quit(0)
