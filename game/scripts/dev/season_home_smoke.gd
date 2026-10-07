extends SceneTree

## Home v3 (design_handoff_home_v3, runda 2): biranje u dva taba + prelaz u polje.
## Cuva nalaze iz testiranja rundi 1 i 2: strelice i tabovi primaju PRAVI klik
## (ne padaju na karticu i ne otvaraju polje), swipe po kartici lista, unos je
## zakljucan dok traje prelaz, ime / Pip / Play su po JEDAN objekat i vidljivi u
## svakom kadru, trake kartice = trake livade (predaja bez šava), Pip se vraca sa
## stopala gdje je odsetao, i na biranju nema loopa.
## Runda 3: kartica nosi svih sest cvjetova (dva reda po tri), zakljucana
## besplatna sezona ih drzi pod velom uz jedan katanac, a tap na Unlock ih
## otkriva disk po disk.
## Runda 4: imena cvijeca se ne preklapaju ni na jednoj od 8 sezona kad su
## svih sest prikazana — to je najgori slucaj i stanje nove igre.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const TOL := 1.5

var _backup := ""
var _failed := false
var _page_origin := Vector2.ZERO
## Ucitano u _run (poslije autoloada) — UiHomeV3 → PipDraw treba GameState.
var V: GDScript
var PART_GATE := "gate"
var PART_UNLOCK := "unlock"
var PART_BUY := "buy"


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


func _settle(stage: Node) -> void:
	for _i in 300:
		if bool(stage.call("is_busy")):
			await create_timer(0.02).timeout
		else:
			break
	await _frames(2)


func _rect_is(r: Rect2, expected: Rect2) -> bool:
	return r.position.distance_to(expected.position) <= TOL \
		and absf(r.size.x - expected.size.x) <= TOL and absf(r.size.y - expected.size.y) <= TOL


## Crtezi cvijeca koji se zaista crtaju (skriveni su pod punim velom).
func _arts_drawn(content: Object) -> int:
	var count := 0
	for child in (content as Node).get_children():
		if str(child.name).begins_with("RosterArt_") and (child as CanvasItem).visible:
			count += 1
	return count


func _veiled(content: Object) -> int:
	var count := 0
	for a in content.call("veil_alphas") as PackedFloat32Array:
		if a > 0.001:
			count += 1
	return count


## Iz px kartice u px stranice (kartica pocinje na CARD_RECT.position).
func _on_page(card_local: Rect2) -> Rect2:
	return Rect2(card_local.position + (V.CARD_RECT as Rect2).position, card_local.size)


func _page_rect(c: Control) -> Rect2:
	var r := c.get_global_rect()
	r.position -= _page_origin
	return r


## Pravi klik (mis) u koordinatama stranice — ide kroz GUI kao prst.
func _click(page_pos: Vector2) -> void:
	var p := page_pos + _page_origin
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = p
	down.global_position = p
	get_root().push_input(down, true)
	await process_frame
	var up := down.duplicate() as InputEventMouseButton
	up.pressed = false
	get_root().push_input(up, true)
	await _frames(2)


func _drag(from: Vector2, to: Vector2, steps: int = 8) -> void:
	var a := from + _page_origin
	var b := to + _page_origin
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = a
	down.global_position = a
	get_root().push_input(down, true)
	await process_frame
	for i in steps:
		var m := InputEventMouseMotion.new()
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		m.position = a.lerp(b, float(i + 1) / float(steps))
		m.global_position = m.position
		get_root().push_input(m, true)
		await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = b
	up.global_position = b
	get_root().push_input(up, true)
	await _frames(2)


## Pokrene pravi prelaz i u svakom frameu provjeri: napredak ide samo u jednom
## smjeru, tacno jedan Pip (putujuci ILI livadin), ime i Play uvijek vidljivi,
## i u svakom kadru postoji ili kartica ili trake livade (nikad prazna stranica).
func _run_live(stage: Node, field: Control, card: Control, pip: Control, play: Control, name_n: Control, opening: bool) -> String:
	var meadow_pip := stage.get_node("%MeadowPip") as Control
	var ground := field.get_node("MeadowGround") as Control
	if opening:
		stage.call("open_season_field", str(_gs().get("active_season_id")))
	else:
		stage.call("close_season_field")
	if not bool(stage.call("is_field_transitioning")):
		return "transition did not start"
	var last: float = -1.0 if opening else 2.0
	var frames := 0
	while bool(stage.call("is_field_transitioning")) and frames < 600:
		await process_frame
		frames += 1
		var u: float = stage.call("transition_u")
		if (opening and u < last - 0.0001) or (not opening and u > last + 0.0001):
			return "u went backwards (%.3f after %.3f)" % [u, last]
		last = u
		var pips := int(pip.visible) + int(meadow_pip.is_visible_in_tree())
		if pips != 1:
			return "u %.3f: %d Pips visible" % [u, pips]
		if not name_n.visible or not play.visible:
			return "u %.3f: name / Play hidden" % u
		if not card.visible and not ground.is_visible_in_tree():
			return "u %.3f: neither the card nor the meadow is drawn" % u
		if card.visible and ground.is_visible_in_tree():
			return "u %.3f: card and meadow bands both drawn (double edges)" % u
	await _frames(2)
	if frames < 3:
		return "transition too short (%d frames)" % frames
	return ""


func _run() -> void:
	V = load("res://scripts/visual/ui_home_v3.gd")
	_backup = CampSmokeUtil.backup_save()
	var gs := _gs()
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.call("clear_owned_paid_seasons")
	var unlocked: Array = gs.get("unlocked_seasons")
	unlocked.append("frost_orchard")
	unlocked.append("lantern_meadow")
	gs.call("set_active_season", "lantern_meadow")
	gs.call("set_free_strip_focus", "lantern_meadow")
	gs.call("set_home_band", "free")
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 320)
	gs.set("garden_crystal_stash", {"midnight_lotus": 14})
	gs.set("discovered_blooms", {})
	gs.set("last_daily_chest_day", "")

	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	await _frames(16)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(12)
	var swipe: Node = hub.get_node("RootVBox/SwipePager")
	var home: Control = swipe.call("get_pages_host").get_node("Page_%d" % MetaHubPages.MAIN) as Control
	var stage: Control = home.get_node("%SeasonStage") as Control
	_page_origin = home.get_global_rect().position
	home.call("refresh_for_meta_hub")
	await _frames(4)

	var tabs := stage.get_node("%SeasonTabs") as Control
	var card := stage.get_node("%SeasonCard") as Control
	var prev := stage.get_node("%PrevSeason") as Control
	var next := stage.get_node("%NextSeason") as Control
	var play := stage.get_node("%PlayButton") as Control
	var name_n := stage.get_node("%SeasonName") as Control
	var pip := stage.get_node("%TravelPip") as Control
	var field := stage.get_node("%SeasonField") as Control
	var clip := stage.get_node("%FieldClip") as Control

	# --- 1. raspored 1:1 s HomeScreen.dc.html ---
	if not _rect_is(_page_rect(tabs), V.TABS_RECT):
		_fail("SeasonTabs expected %s got %s" % [V.TABS_RECT, _page_rect(tabs)]); return
	if not _rect_is(_page_rect(card), V.CARD_RECT):
		_fail("SeasonCard expected %s got %s" % [V.CARD_RECT, _page_rect(card)]); return
	if not _rect_is(_page_rect(play), V.PLAY_CARD["rect"]):
		_fail("PlayButton expected 520 x 180 at (280, 1413) got %s" % _page_rect(play)); return
	if not _rect_is(_page_rect(prev), V.PREV_RECT) or not _rect_is(_page_rect(next), V.NEXT_RECT):
		_fail("arrows expected (52, 852) / (908, 852) 120"); return
	if str(stage.call("viewed_id")) != "lantern_meadow" or str(stage.call("current_tab")) != "free":
		_fail("Home should open on the playing season (Lantern, Free tab)"); return
	if str(stage.call("card_status")) != "active" or not pip.visible:
		_fail("season you play: Pip on the card"); return
	if str(home.call("home_play_action")) != "field" or str(play.get("mode")) != "play":
		_fail("season you play: Play opens the field"); return
	if field.is_visible_in_tree() and clip.visible:
		_fail("meadow should be hidden on the season picker"); return

	# --- 2. strelice: pravi klik mijenja sezonu i NE otvara polje (runda 1, I1) ---
	await _click((V.NEXT_RECT as Rect2).get_center())
	await _settle(stage)
	if bool(gs.get("home_season_field_open")):
		_fail("tap on › must not open the field"); return
	if str(stage.call("viewed_id")) != "amber_canopy":
		_fail("› should show Amber Canopy, got %s" % stage.call("viewed_id")); return
	if str(stage.call("card_status")) != "locked" or pip.visible:
		_fail("Amber: locked (chips), no Pip"); return
	var content: Object = stage.call("get_card_content")
	if (content.call("chip_rects") as Array).size() != 2 or not bool(content.call("has_roster_lock")):
		_fail("locked card: two need chips + one lock over the flowers"); return
	# Runda 3, R1: sest diskova, tacno na mjerama iz ROSTER6.
	var discs: Array = content.call("disc_rects")
	if discs.size() != 6:
		_fail("card should carry all six flowers, got %d" % discs.size()); return
	for i in 6:
		if not _rect_is(discs[i], V.ROSTER6[i]):
			_fail("disc %d expected %s got %s" % [i, V.ROSTER6[i], discs[i]]); return
	# Runda 3, R2: veo na svih sest, nijedan crtez, tacno jedan katanac.
	if _veiled(content) != 6 or _arts_drawn(content) != 0:
		_fail("locked season: the veil must hide every flower"); return
	if not (content.call("name_boxes") as Array).is_empty():
		_fail("locked season: no flower name may show"); return
	if str(content.call("coin_text")) != "320 / 500" or str(content.call("star_text")) != "14 / 20":
		_fail("need chips expected 320 / 500 and 14 / 20 got %s / %s" % [str(content.call("coin_text")), str(content.call("star_text"))]); return
	if str(home.call("home_play_action")) != "focus" or str(play.get("mode")) != "back":
		_fail("browsing locked: Play = Back"); return
	if next.visible:
		_fail("last free season: › hidden"); return
	await _click((V.PREV_RECT as Rect2).get_center())
	await _settle(stage)
	await _click((V.PREV_RECT as Rect2).get_center())
	await _settle(stage)
	if str(stage.call("viewed_id")) != "frost_orchard" or bool(gs.get("home_season_field_open")):
		_fail("‹ ‹ should show Frost Orchard without opening"); return
	if str(stage.call("card_status")) != "open" or pip.visible:
		_fail("Frost (unlocked, not playing): gate, no Pip (runda 1, I4)"); return
	if (content.call("part_rect", PART_GATE) as Rect2).size.x < 149.0:
		_fail("open gate should be 150 px"); return
	if str(gs.get("active_season_id")) != "lantern_meadow":
		_fail("browsing must not change the active season"); return

	# --- 3. Play = Back vraca karticu na sezonu u kojoj se igra ---
	await _click((V.PLAY_CARD["rect"] as Rect2).get_center())
	await _settle(stage)
	if str(stage.call("viewed_id")) != "lantern_meadow" or bool(gs.get("home_season_field_open")):
		_fail("Back should return to Lantern without opening"); return

	# --- 3b. runde 3 i 4: sest cvjetova i sest imena stanu na svaku karticu ---
	if str(stage.call("card_status")) != "active":
		_fail("should be on the playing season"); return
	if _veiled(content) != 0 or _arts_drawn(content) != 6:
		_fail("playable season: six flowers, no veil"); return
	if bool(content.call("has_roster_lock")):
		_fail("playable season: no lock"); return
	# Ime nosi svaki vidljivi cvijet, i onaj koji je igrac vec nasao.
	if (content.call("name_boxes") as Array).size() != (content.call("name_boxes", true) as Array).size():
		_fail("playable season: every flower carries its name, not only the missing ones"); return
	# Najgori slucaj je nova igra: svih sest imena odjednom. Mjeri se na SVAKOJ
	# sezoni, jer imena su sadrzaj i nova sezona ih lako prelije jedno na drugo.
	var catalog: GDScript = load("res://scripts/seasons/season_catalog.gd")
	var min_gap := INF
	var min_gap_where := ""
	for def in catalog.all_defs():
		var sid := str(def.get("id"))
		stage.call("show_season", sid, false)
		await _frames(2)
		var discs2: Array = content.call("disc_rects")
		var boxes: Array = content.call("name_boxes", true)
		if boxes.size() < 6 or boxes.size() > 12:
			_fail("%s: expected 6 names in at most 2 lines each, got %d boxes" % [sid, boxes.size()]); return
		for r: Rect2 in boxes:
			if r.size.x > V.MISSING_NAME_CONTENT_MAX_W + TOL:
				_fail("%s: a name line is %.0f px wide, the content rule is %.0f" % [
					sid, r.size.x, V.MISSING_NAME_CONTENT_MAX_W]); return
			if r.end.y > V.STATUS_TOP:
				_fail("%s: a name reaches %.0f, the status row starts at %.0f" % [sid, r.end.y, V.STATUS_TOP]); return
			for arrow: Rect2 in [V.PREV_RECT, V.NEXT_RECT]:
				if _on_page(r).intersects(arrow):
					_fail("%s: a name runs into the arrow %s" % [sid, arrow]); return
			for d: Rect2 in discs2:
				if r.intersects(d):
					_fail("%s: a name runs into the disc %s" % [sid, d]); return
		# Nijedno ime ne dodiruje susjedno — ovo je greska koju je playtest nasao.
		for i in boxes.size():
			for j in range(i + 1, boxes.size()):
				var a: Rect2 = boxes[i]
				var b: Rect2 = boxes[j]
				if a.intersects(b):
					_fail("%s: two names overlap (%s and %s)" % [sid, a, b]); return
				if absf(a.position.y - b.position.y) > 1.0:
					continue
				var gap: float = maxf(b.position.x - a.end.x, a.position.x - b.end.x)
				if gap < min_gap:
					min_gap = gap
					min_gap_where = sid
	if min_gap < 14.0:
		_fail("names come within %.1f px of each other (%s)" % [min_gap, min_gap_where]); return
	stage.call("show_season", "lantern_meadow", false)
	await _frames(2)

	# --- 4. swipe po kartici lista; kratak drag se vrati (runda 1, I2) ---
	await _drag(Vector2(800, 900), Vector2(600, 900))
	await _settle(stage)
	if str(stage.call("viewed_id")) != "amber_canopy":
		_fail("swipe left 200 px should show the next season"); return
	await _drag(Vector2(300, 900), Vector2(520, 900))
	await _settle(stage)
	if str(stage.call("viewed_id")) != "lantern_meadow":
		_fail("swipe right should show the previous season"); return
	await _drag(Vector2(540, 900), Vector2(510, 900), 4)
	await _settle(stage)
	if str(stage.call("viewed_id")) != "lantern_meadow" or bool(gs.get("home_season_field_open")):
		_fail("short drag must snap back and not open the field"); return
	if absf(_page_rect(card).position.x - V.CARD_RECT.position.x) > TOL:
		_fail("card should snap back to x 24"); return

	# --- 5. tabovi (pravi klik) ---
	await _click(V.TABS_RECT.position + Vector2(8 + 508 + 254, 62))
	await _settle(stage)
	if str(stage.call("current_tab")) != "premium" or str(stage.call("viewed_id")) != "moonlit_warren":
		_fail("Premium tab should open on Moonlit Warren"); return
	if str(stage.call("card_status")) != "buy" or (content.call("part_rect", PART_BUY) as Rect2).size.y < 139.0:
		_fail("Moonlit: price button"); return
	# Runda 3: premium se kupuje, pa pokazuje sta se kupuje — sest cvjetova u
	# boji, bez vela i bez katanca (zlato kaze „nije tvoje").
	if _veiled(content) != 0 or _arts_drawn(content) != 6 or bool(content.call("has_roster_lock")):
		_fail("premium on sale: six flowers in colour, no veil, no lock"); return
	stage.call("show_season", "ember_fen", false)
	await _frames(2)
	if str(stage.call("card_status")) != "soon":
		_fail("Ember Fen: coming soon"); return
	if _veiled(content) != 0 or _arts_drawn(content) != 6 or not bool(content.call("is_dim")):
		_fail("coming soon: six flowers at 50 %, no veil"); return
	await _click(V.TABS_RECT.position + Vector2(8 + 254, 62))
	await _settle(stage)
	if str(stage.call("current_tab")) != "free" or str(stage.call("viewed_id")) != "lantern_meadow":
		_fail("Free tab should open on the playing season"); return

	# --- 6. hub swipe: kontrole blokiraju, prazan pojas uz Play ne ---
	for c in [card, tabs, prev, next, play]:
		if not bool(swipe.call("should_block_hub_swipe_at", (c as Control).get_global_rect().get_center())):
			_fail("%s should block the hub swipe" % c.name); return
	for zone in V.HUB_SWIPE_ZONES:
		if bool(swipe.call("should_block_hub_swipe_at", (zone as Rect2).get_center() + _page_origin)):
			_fail("hub swipe zone %s must stay free" % str(zone)); return

	# --- 7. biranje nema loopa ---
	if bool(home.call("is_basket_attention_active")):
		_fail("season picker must not run a loop"); return

	# --- 8. prelaz: Play na sezoni u kojoj se igra otvara polje ---
	await _click((V.PLAY_CARD["rect"] as Rect2).get_center())
	if not bool(stage.call("is_field_transitioning")):
		_fail("Play should start the open transition"); return
	# Unos zakljucan dok traje prelaz (runda 1, I3).
	await _click(V.TABS_RECT.position + Vector2(8 + 508 + 254, 62))
	await _click((V.NEXT_RECT as Rect2).get_center())
	if str(stage.call("current_tab")) != "free" or str(stage.call("viewed_id")) != "lantern_meadow":
		_fail("tabs / arrows must be locked during the transition"); return
	var tw: Tween = stage.get("_field_tween")
	tw.pause()
	var card_surf: Control = card
	for i in 21:
		var u := float(i) / 20.0
		stage.call("_set_u", u)
		var e: float = V.ease_t(u)
		# P1: ime, Pip i Play vidljivi u svakom kadru.
		if not name_n.visible or str(name_n.get("text")).is_empty():
			_fail("u %.2f: SeasonName must be visible" % u); return
		if not pip.visible and u < 1.0:
			_fail("u %.2f: Pip must be visible" % u); return
		if not play.visible:
			_fail("u %.2f: Play must be visible" % u); return
		# P2–P4: jedan objekat na istom eased t.
		var want_play: Rect2 = V.play_params(e)["rect"]
		if not _rect_is(_page_rect(play), want_play):
			_fail("u %.2f: Play rect %s expected %s" % [u, _page_rect(play), want_play]); return
		if absf(float(name_n.get("top")) - lerpf(244.0, 36.0, e)) > 0.01:
			_fail("u %.2f: SeasonName top off the eased t" % u); return
		# P5 (Season Kit faza 2): kartica i livada crtaju ISTI recept — Lantern ima kit.
		if u < 1.0 and not bool(card_surf.call("has_kit")):
			_fail("u %.2f: Lantern card should draw the kit recipe" % u); return
		var ground := field.get_node("MeadowGround") as Control
		if ground.visible != (u >= 1.0):
			_fail("u %.2f: meadow draws only at u = 1 (card IS the meadow)" % u); return
	if not bool(field.call("has_kit")):
		_fail("Lantern field should draw the kit recipe (same as the card)"); return
	if field.get_node_or_null("MeadowGround/MeadowSky") != null:
		_fail("old meadow bands (MeadowSky) should be gone"); return
	tw.kill()
	stage.call("_on_field_tween_finished")
	await _frames(3)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("home_season_field_id")) != "lantern_meadow":
		_fail("field should be open on Lantern"); return
	if str(home.call("home_play_action")) != "run":
		_fail("field open: Play starts the run"); return
	if not _rect_is(_page_rect(play), V.PLAY_FIELD["rect"]):
		_fail("field: Play should be FieldPlayButton 432 x 140 at (324, 1461)"); return
	var meadow_pip := stage.get_node("%MeadowPip") as Control
	if pip.visible or not meadow_pip.visible:
		_fail("u = 1: the meadow takes Pip over"); return
	if not _rect_is(meadow_pip.get_global_rect(), Rect2(V.pip_field_pos(Vector2(UiHomeField.PIP_DEFAULT_BASE)) + _page_origin, Vector2(190, 190))):
		_fail("meadow Pip should land on the home feet (756, 1404)"); return
	if not bool(field.call("is_pip_alive")):
		_fail("Pip should walk once the transition is done"); return

	# --- 9. zatvaranje: Pip krece sa stopala gdje je odsetao ---
	field.call("_stop_wander")
	meadow_pip.position = Vector2(300.0 - 95.0, 1330.0 - 190.0)
	stage.call("close_season_field")
	tw = stage.get("_field_tween")
	tw.pause()
	stage.call("_set_u", 1.0)
	var walked := Rect2(Vector2(205, 1140), Vector2(190, 190))
	if not pip.visible or not (pip.get("rect") as Rect2).is_equal_approx(walked):
		_fail("close: Pip should start from its walked feet, got %s" % str(pip.get("rect"))); return
	if meadow_pip.visible:
		_fail("close: the meadow hands Pip back"); return
	tw.kill()
	stage.call("_on_field_tween_finished")
	await _frames(3)
	if bool(gs.get("home_season_field_open")) or not card.visible or clip.visible:
		_fail("close should end on the card"); return
	if str(stage.call("viewed_id")) != "lantern_meadow" or str(name_n.get("text")) != "Lantern Meadow":
		_fail("close should land on the playing season"); return

	# --- 10. kapija na otkljucanoj sezoni otvara njeno polje i ona postaje aktivna ---
	stage.call("show_season", "frost_orchard", false)
	await _frames(2)
	stage.call("press_part", PART_GATE)
	await _settle(stage)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("active_season_id")) != "frost_orchard":
		_fail("gate should open Frost and make it the playing season"); return
	stage.call("close_season_field", false)
	await _frames(2)

	# --- 11. Unlock (500 + 20 ★3) ---
	gs.set("wallet_coins", 1250)
	gs.set("garden_crystal_stash", {"midnight_lotus": 20})
	gs.call("set_active_season", "lantern_meadow")
	home.call("refresh_for_meta_hub")
	stage.call("show_season", "amber_canopy", false)
	await _frames(2)
	if str(stage.call("card_status")) != "unlock":
		_fail("Amber with 500 + 20: Unlock button"); return
	if _veiled(content) != 6 or bool(content.call("has_roster_lock")):
		_fail("unlock state: veil on all six, lock only on the Unlock button"); return
	stage.call("press_part", PART_UNLOCK)
	await _frames(2)
	if not bool(gs.call("is_season_playable", "amber_canopy")) or str(stage.call("card_status")) != "active":
		_fail("Unlock should make Amber the playing season"); return
	if str(stage.call("get_toast_text")) != "Unlocked" or not pip.visible:
		_fail("Unlock: toast + Pip on the card"); return
	# Runda 3, R2: veo se dize disk po disk — prvi disk ide prije zadnjeg.
	if not bool(content.call("is_revealing")):
		_fail("Unlock should lift the veil disc by disc"); return
	await _wait(0.12)
	var mid: PackedFloat32Array = content.call("veil_alphas")
	if mid[0] >= mid[5] or mid[0] >= 0.999:
		_fail("reveal should start at the first disc, got %s" % str(mid)); return
	await _wait(V.REVEAL_SEC + 6.0 * V.REVEAL_STAGGER + 0.2)
	if bool(content.call("is_revealing")) or _veiled(content) != 0 or _arts_drawn(content) != 6:
		_fail("after the reveal all six flowers are visible"); return

	# --- 12. pravi tween (realno vrijeme): invarijante u SVAKOM frameu ---
	stage.call("show_season", str(gs.get("active_season_id")), false)
	await _frames(2)
	var inv_err := await _run_live(stage, field, card, pip, play, name_n, true)
	if not inv_err.is_empty():
		_fail("live open: %s" % inv_err); return
	await _wait(1.2)
	inv_err = await _run_live(stage, field, card, pip, play, name_n, false)
	if not inv_err.is_empty():
		_fail("live close: %s" % inv_err); return

	# --- 13. prva sesija: hint oko Playa, bez loopa na biranju ---
	gs.set("tutorial_complete", false)
	home.call("refresh_for_meta_hub")
	await _frames(2)
	var hint := home.get_node("%StageHint") as Control
	if not hint.visible or not _rect_is(Rect2(hint.get("target")), V.PLAY_CARD["rect"]):
		_fail("first session: StageHint rings the new Play"); return
	gs.set("tutorial_complete", true)

	CampSmokeUtil.restore_save(self, _backup)
	print("season_home_smoke OK")
	quit(0)
