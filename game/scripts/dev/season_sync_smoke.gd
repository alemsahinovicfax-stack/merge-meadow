extends SceneTree

## Komunikacija sezona između sekcija (2026-10-12: „Home i polje jedna sezona, Arena druga",
## „Camp link ne primijeni sezonu", „kupljena premium sezona kasnije nije moja").
## Pravi hub sa svih 5 stranica i pravi save; NE postavlja skip_debug_season_unlock (hub u
## debug buildu je ranije sam brisao kupljene sezone). Posle svakog koraka _check():
## - aktivna sezona je igriva; otvoreno polje na Homeu = aktivna sezona;
## - Home kartica svake sezone se slaže s GameState (igriva / zaključana / kupi);
## - IAP vlasništvo i Shop kartica svake plaćene sezone = owned_paid_seasons;
## - Arena livada = aktivna sezona kad joj se priđe;
## - save na disku nosi istu aktivnu, otključane i kupljene sezone.
## Koraci: start S1 + S2 → polje S2, pa S1 → Camp link otključa S3 → Home kupi P1 →
## polje S1 + Shop kupi P2 → Camp „otvori polje" → run iz polja i povratak (novi hub) →
## ponovo učitan save → Shop „Play" P1 dok je otvoreno polje P2 → otključavanje na Home
## kartici → Endless iz polja i povratak → Settings · Developer „Reset seasons" + „Reset
## tutorial" (prva sezona svuda, i u Areni i runu).
## Pokretanje: godot --headless --path game -s res://scripts/dev/season_sync_smoke.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const CARD := "res://scripts/ui/home_v3_card_content.gd"
const SAVE_PATH := "user://player_save.json"
const HUB_SCENE := "res://scenes/meta/meta_hub.tscn"
const RUN_SCENE := "res://scenes/run/run_scene.tscn"
## Bez statičkih referenci na klase koje traže autoload (-s skripta se kompajlira prije njih).
const ARENA_UI := "res://scripts/visual/ui_arena_v2.gd"
const S1 := "country_bloom"
const S2 := "frost_orchard"
const S3 := "lantern_meadow"

var _backup := ""
var _st: Script
var _step := ""


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node("GameState")


func _iap() -> Node:
	return get_root().get_node("IAPManager")


func _fail(msg: String) -> void:
	push_error("season_sync_smoke [%s]: %s" % [_step, msg])
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


## Čeka dok `cond` ne vrati true (najviše `sec` sekundi).
func _until(cond: Callable, sec: float) -> bool:
	var end := Time.get_ticks_msec() + int(sec * 1000.0)
	while Time.get_ticks_msec() < end:
		if cond.call():
			return true
		await process_frame
	return bool(cond.call())


func _hub() -> Node:
	var hubs := get_nodes_in_group("meta_hub")
	return hubs[0] if not hubs.is_empty() else null


func _page(index: int) -> Node:
	var hub := _hub()
	if hub == null:
		return null
	return hub.get_node("RootVBox/SwipePager").call("get_pages_host").get_node_or_null("Page_%d" % index)


func _go(index: int) -> void:
	_hub().call("go_to_page", index, false)
	await _frames(8)


func _stage() -> Node:
	return _page(MetaHubPages.MAIN).get_node("%SeasonStage")


func _active() -> String:
	return str(_gs().get("active_season_id"))


func _paid_ids() -> Array[String]:
	var out: Array[String] = []
	for def in SeasonCatalog.paid_defs():
		if not def.iap_product_id.is_empty() and not bool(_gs().call("is_test_locked_season", def.id)):
			out.append(def.id)
	return out


## Sve sekcije pričaju isto. Vraća "" ili opis prve greške.
func _check(expect_active: String) -> String:
	var gs := _gs()
	var active := _active()
	if not expect_active.is_empty() and active != expect_active:
		return "active is %s, expected %s" % [active, expect_active]
	if not bool(gs.call("is_season_playable", active)):
		return "active %s is not playable" % active
	var field_open := bool(gs.get("home_season_field_open"))
	if field_open and str(gs.get("home_season_field_id")) != active:
		return "Home field shows %s while active is %s" % [gs.get("home_season_field_id"), active]
	var stage := _stage()
	if field_open and str(stage.call("viewed_id")) != active:
		return "Home stage views %s on an open field, active %s" % [stage.call("viewed_id"), active]
	var field: Node = stage.get_node("%SeasonField")
	if field_open and str(field.get("_open_season_id")) != active:
		return "Home field draws %s, active %s" % [field.get("_open_season_id"), active]
	var playable_states := [_st.ST_ACTIVE, _st.ST_OPEN, _st.ST_OWNED]
	for def in SeasonCatalog.all_defs():
		var status := str(stage.call("card_status", def.id))
		var playable := bool(gs.call("is_season_playable", def.id))
		if playable != playable_states.has(status):
			return "Home card %s says '%s' but playable=%s" % [def.id, status, str(playable)]
		if (def.id == active) != (status == _st.ST_ACTIVE):
			return "Home card %s says '%s' (active is %s)" % [def.id, status, active]
	var owned: Array = gs.get("owned_paid_seasons")
	var shop := _page(MetaHubPages.SHOP)
	for id in _paid_ids():
		var def: SeasonDef = SeasonCatalog.get_def(id)
		var has := owned.has(id)
		if bool(_iap().call("owns_product", def.iap_product_id)) != has:
			return "IAP owns %s = %s, owned_paid has it = %s" % [id, str(not has), str(has)]
		if shop != null:
			shop.call("refresh_shop")
			var card: Node = shop.call("get_season_card", def.iap_product_id)
			if card != null and (str(card.call("get_state")) == "play") != has:
				return "Shop card %s state '%s', owned=%s" % [id, card.call("get_state"), str(has)]
	return _check_disk()


func _check_disk() -> String:
	var gs := _gs()
	gs.call("flush_save_soon")
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if not data is Dictionary:
		return "save unreadable"
	if str(data.get("active_season_id", "")) != _active():
		return "save active %s, game %s" % [data.get("active_season_id", ""), _active()]
	for key in ["unlocked_seasons", "owned_paid_seasons"]:
		var disk: Array = (data.get(key, []) as Array).duplicate()
		var mem: Array = (gs.get(key) as Array).duplicate()
		disk.sort()
		mem.sort()
		if disk != mem:
			return "save %s %s, game %s" % [key, str(disk), str(mem)]
	return ""


## Arena livada kad igrač dođe na Arenu.
func _check_arena() -> String:
	await _go(MetaHubPages.ARENA)
	var arena := _page(MetaHubPages.ARENA)
	if arena == null:
		return "Arena page missing"
	var bg: Node = arena.get("meadow_bg")
	var want := _active() if (load(ARENA_UI).FIELDS as Dictionary).has(_active()) else S1
	if bg == null or str(bg.get("_season_id")) != want:
		return "Arena meadow %s, active %s" % [bg.get("_season_id") if bg else "null", _active()]
	await _go(MetaHubPages.MAIN)
	return ""


func _ok(step: String, expect_active: String, arena: bool = true) -> bool:
	_step = step
	var err := _check(expect_active)
	if err.is_empty() and arena:
		err = await _check_arena()
		if err.is_empty():
			err = _check(expect_active)
	if not err.is_empty():
		_fail(err)
		return false
	print("season_sync: %s OK (active %s)" % [step, _active()])
	return true


func _wait_hub() -> bool:
	return await _until(func() -> bool:
		var hub := _hub()
		return hub != null and _page(MetaHubPages.MAIN) != null and _page(MetaHubPages.ARENA) != null \
			and _page(MetaHubPages.SHOP) != null and _page(MetaHubPages.CAMP) != null, 40.0)


func _buy_wait(season_id: String) -> bool:
	return await _until(func() -> bool:
		return (_gs().get("owned_paid_seasons") as Array).has(season_id) and not bool(_iap().call("is_busy")), 5.0)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_st = load(CARD)
	var gs := _gs()
	gs.set("tutorial_complete", true)
	gs.call("reset_seasons_to_s1")
	var unlocked: Array = gs.get("unlocked_seasons")
	unlocked.append(S2)
	gs.set("wallet_coins", 5000)
	gs.call("close_home_season_field")
	gs.call("set_active_season", S1)
	gs.call("save_player_save")
	var paid := _paid_ids()
	if paid.size() < 2:
		_fail("need two buyable paid seasons, got %s" % str(paid))
		return
	var p1 := paid[0]
	var p2 := paid[1]

	change_scene_to_file(HUB_SCENE)
	if not await _wait_hub():
		_step = "boot"
		_fail("hub pages did not load")
		return
	await _frames(10)
	if not await _ok("1 boot", S1):
		return
	if (gs.get("unlocked_seasons") as Array).size() != 2 or not (gs.get("owned_paid_seasons") as Array).is_empty():
		_fail("hub boot changed seasons: unlocked %s, paid %s" % [gs.get("unlocked_seasons"), gs.get("owned_paid_seasons")])
		return

	# 2. Home: polje S2, zatvori, pa polje S1; listanje kartice ne mijenja aktivnu.
	var stage := _stage()
	stage.call("open_season_field", S2, false)
	await _frames(6)
	if not await _ok("2a field S2", S2):
		return
	stage.call("close_season_field", false)
	stage.call("show_season", S1, false)
	await _frames(6)
	if not await _ok("2b browse S1 (field closed)", S2):
		return
	stage.call("open_season_field", S1, false)
	await _frames(6)
	if not await _ok("2c field S1", S1):
		return

	# 3. Camp link otključa S3 (sredstva iz debug pomoći).
	gs.call("debug_grant_unlock_test_funds")
	await _go(MetaHubPages.CAMP)
	var camp := _page(MetaHubPages.CAMP)
	camp.call("refresh_for_meta_hub")
	await _frames(4)
	var link: Node = camp.get_node("%SeasonLinkCard")
	if str(gs.call("next_locked_free_id")) != S3 or not bool(gs.call("can_unlock_free", S3)):
		_step = "3 camp link"
		_fail("S3 should be unlockable, next %s" % gs.call("next_locked_free_id"))
		return
	link.call("_on_unlock_clicked")
	var done := await _until(func() -> bool:
		return not bool(link.get("_unlocking")) and int(_hub().call("current_page_index")) == MetaHubPages.MAIN, 6.0)
	if not done:
		_step = "3 camp link"
		_fail("unlock did not finish on Home (page %s)" % _hub().call("current_page_index"))
		return
	await _frames(6)
	if not (gs.get("unlocked_seasons") as Array).has(S3):
		_step = "3 camp link"
		_fail("S3 not unlocked")
		return
	if str(_stage().call("viewed_id")) != S3:
		_step = "3 camp link"
		_fail("Home card shows %s after Camp unlock of S3" % _stage().call("viewed_id"))
		return
	if not await _ok("3 Camp link unlock S3", S3):
		return

	# 4. Home premium: kupi P1 (stub IAP; v1 bez kupovina pravim novcem: za coine, dva tapa), pa
	# prebacuj tabove.
	stage = _stage()
	stage.call("show_season", p1, false)
	await _frames(4)
	if not MonetizationConfig.iap_enabled():
		gs.set("wallet_coins", 100000)
		stage.call("_buy", p1)
	stage.call("_buy", p1)
	if not await _buy_wait(p1):
		_step = "4 Home buy"
		_fail("P1 %s not owned after purchase" % p1)
		return
	await _frames(6)
	if not await _ok("4a Home buy %s" % p1, p1):
		return
	stage.call("show_season", S1, false)
	await _frames(4)
	stage.call("show_season", p1, false)
	await _frames(4)
	if str(stage.call("card_status", p1)) != _st.ST_ACTIVE:
		_step = "4b tabs"
		_fail("P1 card after tab switch: %s" % stage.call("card_status", p1))
		return
	if not await _ok("4b tabs back and forth", p1, false):
		return

	# 5. Polje S1 otvoreno, Shop kupi P2 → polje se zatvara, aktivna P2 svuda.
	stage.call("open_season_field", S1, false)
	await _frames(6)
	if not await _ok("5a field S1 before Shop buy", S1, false):
		return
	await _go(MetaHubPages.SHOP)
	var shop := _page(MetaHubPages.SHOP)
	if MonetizationConfig.iap_enabled():
		shop.call("_on_money_buy", SeasonCatalog.get_def(p2).iap_product_id)
	else:
		shop.call("_on_coin_buy_confirmed", SeasonCatalog.get_def(p2).iap_product_id)
	if not await _buy_wait(p2):
		_step = "5 Shop buy"
		_fail("P2 %s not owned after Shop purchase" % p2)
		return
	await _frames(4)
	if bool(gs.get("home_season_field_open")):
		_step = "5 Shop buy"
		_fail("Home field still open on %s after buying %s" % [gs.get("home_season_field_id"), p2])
		return
	await _go(MetaHubPages.MAIN)
	await _frames(6)
	if not await _ok("5b Shop buy %s" % p2, p2):
		return

	# 6. Camp „otvori polje" (prazna vreća) → polje aktivne sezone na Homeu.
	await _go(MetaHubPages.CAMP)
	_page(MetaHubPages.CAMP).call("_open_current_season_field")
	await _frames(10)
	if not bool(gs.get("home_season_field_open")) or str(gs.get("home_season_field_id")) != p2:
		_step = "6 Camp opens field"
		_fail("Camp should open the %s field, got open=%s id=%s" % [p2, gs.get("home_season_field_open"), gs.get("home_season_field_id")])
		return
	if not await _ok("6 Camp opens field", p2):
		return

	# 7. Run iz polja, pa povratak u (novi) hub kao posle Loota.
	var before := {"unlocked": (gs.get("unlocked_seasons") as Array).duplicate(), "paid": (gs.get("owned_paid_seasons") as Array).duplicate()}
	_page(MetaHubPages.MAIN).call("_start_run")
	var in_run := await _until(func() -> bool:
		return current_scene != null and current_scene.scene_file_path == RUN_SCENE, 6.0)
	if not in_run:
		_step = "7 run"
		_fail("run did not start")
		return
	await _frames(20)
	if _active() != p2:
		_step = "7 run"
		_fail("run plays %s, field was %s" % [_active(), p2])
		return
	gs.call("go_to_meta_hub", MetaHubPages.MAIN)
	await _frames(4)
	if not await _wait_hub():
		_step = "7 back"
		_fail("hub did not come back after the run")
		return
	await _frames(10)
	for key in ["unlocked", "paid"]:
		var now: Array = (gs.get("unlocked_seasons" if key == "unlocked" else "owned_paid_seasons") as Array).duplicate()
		var was: Array = before[key]
		now.sort()
		was.sort()
		if now != was:
			_step = "7 back"
			_fail("%s seasons changed by returning to the hub: %s -> %s" % [key, str(was), str(now)])
			return
	if not await _ok("7 run and back to hub", p2):
		return

	# 8. Ponovo učitan save (kao novo pokretanje igre).
	gs.call("load_player_save")
	_stage().call("refresh")
	await _frames(6)
	if not await _ok("8 reload save", p2):
		return

	# 9. Shop „Play" na kupljenoj P1 dok je otvoreno polje P2 → polje P1, aktivna P1.
	if not bool(gs.get("home_season_field_open")):
		_stage().call("open_season_field", p2, false)
		await _frames(6)
	await _go(MetaHubPages.SHOP)
	_page(MetaHubPages.SHOP).call("_on_open_on_home", p1)
	await _frames(10)
	if int(_hub().call("current_page_index")) != MetaHubPages.MAIN:
		_step = "9 Shop Play"
		_fail("Shop Play did not go to Home")
		return
	if not await _ok("9 Shop Play %s over an open %s field" % [p1, p2], p1):
		return

	# 10. Otključavanje sljedeće free sezone na Home kartici (ne preko Campa).
	var s4 := str(gs.call("next_locked_free_id"))
	if not s4.is_empty() and not bool(gs.call("is_test_locked_season", s4)):
		gs.call("debug_grant_unlock_test_funds")
		stage = _stage()
		stage.call("close_season_field", false)
		stage.call("show_season", s4, false)
		await _frames(4)
		if str(stage.call("card_status", s4)) != _st.ST_UNLOCK:
			_step = "10 Home unlock"
			_fail("%s card should offer Unlock, says %s" % [s4, stage.call("card_status", s4)])
			return
		stage.call("_unlock", s4)
		await _frames(6)
		if not await _ok("10 Home card unlock %s" % s4, s4):
			return

	# 11. Endless iz polja S1, pa povratak. Endless sezone je zaključan dok level 15 nije pređen
	# (balans ciklus 1) — prvo tap na zaključan ne smije pokrenuti run.
	var lp: LevelPathDomain = gs.get("level_path_domain")
	lp.set_level(S1, LevelPathDomain.ENDLESS_UNLOCK_LEVEL)
	_stage().call("open_season_field", S1, false)
	await _frames(6)
	_page(MetaHubPages.MAIN).call("_on_endless_play_pressed")
	await _frames(6)
	if current_scene != null and current_scene.scene_file_path == RUN_SCENE:
		_step = "11 Endless locked"
		_fail("locked Endless must not start a run")
		return
	var home_main := _page(MetaHubPages.MAIN)
	# design_handoff_leveli_endless · B1: krem + prsten „14 / 15" + katanac, toast „Beat Level 15…".
	var face = home_main.get("endless_face")
	if face == null or bool(face.get("unlocked")) or str(face.call("progress_text")) != "14 / 15" \
			or str(home_main.call("field_toast_text")).find("Beat Level 15") < 0:
		_step = "11 Endless locked"
		_fail("locked Endless should show the lock + 14 / 15 and explain level 15 (face %s unlocked %s anim %s, toast '%s')" % [
			str(face.call("progress_text")) if face else "none", str(face.get("unlocked")) if face else "-",
			str(face.call("is_animating")) if face else "-", str(home_main.call("field_toast_text"))])
		return
	lp.set_level(S1, LevelPathDomain.ENDLESS_UNLOCK_LEVEL + 1)
	_page(MetaHubPages.MAIN).call("_on_endless_play_pressed")
	var endless := await _until(func() -> bool:
		return current_scene != null and current_scene.scene_file_path == RUN_SCENE, 6.0)
	if not endless or _active() != S1:
		_step = "11 Endless"
		_fail("Endless did not start on %s (in run %s, active %s)" % [S1, str(endless), _active()])
		return
	await _frames(10)
	gs.call("go_to_meta_hub", MetaHubPages.MAIN)
	await _frames(4)
	if not await _wait_hub():
		_step = "11 back"
		_fail("hub did not come back after Endless")
		return
	await _frames(10)
	if not await _ok("11 Endless and back", S1):
		return

	# 12. Settings · Developer: Reset seasons + Reset tutorial → prva sezona svuda.
	_hub().call("_on_settings_pressed")
	await create_timer(0.6).timeout
	var settings: Node = _hub().get_node_or_null("SettingsScreen")
	if settings == null:
		_step = "12 dev reset"
		_fail("Settings did not open")
		return
	settings.call("_dev_reset_seasons")
	settings.call("_dev_reset_tutorial")
	settings.call("close")
	await create_timer(0.6).timeout
	var left_unlocked: Array = gs.get("unlocked_seasons")
	if left_unlocked.size() != 1 or str(left_unlocked[0]) != S1 or not (gs.get("owned_paid_seasons") as Array).is_empty():
		_step = "12 dev reset"
		_fail("reset should leave only %s, got %s / paid %s" % [S1, left_unlocked, gs.get("owned_paid_seasons")])
		return
	if bool(gs.get("home_season_field_open")):
		_step = "12 dev reset"
		_fail("reset should close the Home field")
		return
	if str(_stage().call("viewed_id")) != S1:
		_step = "12 dev reset"
		_fail("Home card shows %s after the reset" % _stage().call("viewed_id"))
		return
	if not await _ok("12 dev reset seasons + tutorial", S1):
		return
	gs.set("tutorial_complete", true)

	print("season_sync_smoke OK")
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
