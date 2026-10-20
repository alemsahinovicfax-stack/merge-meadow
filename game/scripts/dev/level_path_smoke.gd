extends SceneTree

## design_handoff_level_path: Level Path po sezoni.
##  1. domena: stanja kamenja i sanduka, Claim 5/10/15/20 (★3 sezone + coini), jednom;
##  2. save: season_levels / season_level_rewards; stari "run_level" prelazi na aktivnu sezonu;
##  3. finish_run: uspjeh pomjera level AKTIVNE sezone (+ skok), neuspjeh ne; 21 = complete;
##  4. raspored i recepti: 8 sezona, ≤ 21 sloj, ruta, Pip u kadru na otvaranju za 1…21;
##  5. Home: Play u polju → put (Play = run), ‹ Field nazad; zaključan sanduk → toast;
##     reward_ready → popup → Claim → let u bar; badge na Play; skok Pipa poslije runa;
##     budžet efekata (≤ 6 sprite-ova skoka, ≤ 16 / 24 letača popupa).
## Pokretanje: godot --headless --path game -s scripts/dev/level_path_smoke.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const SEASONS: Array[String] = [
	"country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen",
]

var _backup: String = ""
var _failed: bool = false
var _gs: Node


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("level_path_smoke: %s" % msg)


func _quit() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("level_path_smoke OK")
	quit(1 if _failed else 0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
		await process_frame


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_gs = get_root().get_node("GameState")
	_check_domain()
	_check_save()
	_check_finish_run()
	_check_layout()
	await _check_home()
	_quit()


func _domain() -> LevelPathDomain:
	return _gs.get("level_path_domain") as LevelPathDomain


func _check_domain() -> void:
	var d := _domain()
	d.reset()
	var id := "frost_orchard"
	if d.level_of(id) != 1:
		_fail("fresh season should start at level 1")
	d.set_level(id, 7)
	if LevelPathDomain.cp_state(6, 7) != "done" or LevelPathDomain.cp_state(7, 7) != "current" or LevelPathDomain.cp_state(8, 7) != "locked":
		_fail("cp states wrong")
	if d.reward_state(id, 5) != "reward_ready" or d.reward_state(id, 10) != "reward_locked":
		_fail("reward states at level 7 wrong")
	d.set_level(id, 5)
	if d.reward_state(id, 5) != "reward_locked":
		_fail("level 5 current must keep reward 5 locked")
	d.set_level(id, 16)
	if d.ready_list(id) != [5, 10, 15]:
		_fail("ready list at 16 should be [5, 10, 15], got %s" % str(d.ready_list(id)))
	var flower := str(_gs.call("star3_type_id_for_season", id))
	var stash: Dictionary = _gs.get("garden_crystal_stash")
	var before_f := int(stash.get(flower, 0))
	var before_c := int(_gs.get("wallet_coins"))
	var got: Dictionary = _gs.call("claim_level_reward", id, 10)
	if int(got.get("flowers", 0)) != 4 or int(got.get("coins", 0)) != 400 or str(got.get("flower", "")) != flower:
		_fail("claim 10 should give 4 × %s + 400, got %s" % [flower, str(got)])
	stash = _gs.get("garden_crystal_stash")
	if int(stash.get(flower, 0)) != before_f + 4 or int(_gs.get("wallet_coins")) != before_c + 400:
		_fail("claim 10 did not reach stash / wallet")
	if not (_gs.call("claim_level_reward", id, 10) as Dictionary).is_empty():
		_fail("second claim of 10 must give nothing")
	if not (_gs.call("claim_level_reward", id, 20) as Dictionary).is_empty():
		_fail("locked reward 20 must not be claimable")
	if d.reward_state(id, 10) != "reward_claimed":
		_fail("claimed reward should read reward_claimed")
	var kept: Dictionary = _gs.get("collection_kept_tiers")
	if int(kept.get(flower, 0)) < 3:
		_fail("claimed ★3 should be in the Album")
	if d.level_of("lantern_meadow") != 1:
		_fail("progress must be per season")


func _check_save() -> void:
	var d := _domain()
	var saved := d.to_save_dict()
	var e := LevelPathDomain.new(_gs)
	e.apply_from_save(saved)
	if e.level_of("frost_orchard") != 16 or e.claimed_of("frost_orchard") != [10]:
		_fail("save roundtrip lost progress: %s" % str(saved))
	var legacy := LevelPathDomain.new(_gs)
	legacy.apply_from_save({"run_level": 12, "active_season_id": "amber_canopy"})
	if legacy.level_of("amber_canopy") != 12 or legacy.level_of("country_bloom") != 1:
		_fail("old run_level should move to the active season only")
	legacy.apply_from_save({"run_level": 57, "active_season_id": "amber_canopy"})
	if legacy.level_of("amber_canopy") != LevelPathDomain.COMPLETE:
		_fail("old run_level above 20 should mean complete")
	legacy.apply_from_save({"season_levels": {"coral_tide": 99}, "season_level_rewards": {"coral_tide": [5, 5, 7, 20]}})
	if legacy.level_of("coral_tide") != 21 or legacy.claimed_of("coral_tide") != [5, 20]:
		_fail("bad save values must be clamped / filtered")


func _check_finish_run() -> void:
	var d := _domain()
	d.reset()
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", "country_bloom")
	_gs.set("run_is_endless", false)
	d.set_level("country_bloom", 4)
	if int(_gs.get("run_level")) != 4:
		_fail("run_level should read the active season level")
	_gs.call("finish_run", {}, 0, false, 30.0)
	if d.level_of("country_bloom") != 5:
		_fail("successful run should advance the active season to 5")
	var hop: Dictionary = _gs.get("level_path_hop")
	if int(hop.get("from", 0)) != 4 or int(hop.get("to", 0)) != 5 or str(hop.get("season", "")) != "country_bloom":
		_fail("finish_run should leave a hop 4 → 5, got %s" % str(hop))
	if not (_gs.call("take_level_path_hop", "frost_orchard") as Dictionary).is_empty():
		_fail("hop must only be taken by its own season")
	_gs.call("take_level_path_hop", "country_bloom")
	_gs.call("finish_run", {}, 0, true, 30.0)
	if d.level_of("country_bloom") != 5:
		_fail("failed run must not advance")
	d.set_level("country_bloom", 20)
	_gs.call("finish_run", {}, 0, false, 30.0)
	if d.level_of("country_bloom") != 21 or int(_gs.get("run_level")) != 20:
		_fail("passing 20 → complete (21), Play repeats 20")
	_gs.set("level_path_hop", {})
	_gs.call("finish_run", {}, 0, false, 30.0)
	if d.level_of("country_bloom") != 21 or not (_gs.get("level_path_hop") as Dictionary).is_empty():
		_fail("complete path must stay complete without a hop")
	_gs.set("run_is_endless", true)
	d.set_level("country_bloom", 3)
	_gs.call("finish_run", {}, 0, false, 30.0)
	if d.level_of("country_bloom") != 3:
		_fail("endless run must not move the path")
	_gs.set("run_is_endless", false)
	if d.level_of("frost_orchard") != 1:
		_fail("finish_run touched another season")


func _check_layout() -> void:
	if LevelPathKit.cp_count() != 20:
		_fail("layout should have 20 checkpoints")
	if LevelPathKit.route().size() < 200:
		_fail("route is too short")
	if LevelPathKit.cp(1).y <= LevelPathKit.cp(20).y:
		_fail("level 1 must be at the bottom, 20 at the top")
	for lv in range(1, 22):
		var claimed: Array = []
		var s := LevelPathKit.open_scroll(lv, [])
		var feet_y := LevelPathKit.pip_feet(lv).y - s
		if feet_y < LevelPathKit.VIEW_SAFE.x or feet_y > LevelPathKit.VIEW_SAFE.y:
			_fail("level %d: Pip at page y %.0f is out of view on open" % [lv, feet_y])
		if s < 0.0 or s > LevelPathKit.SCROLL_MAX:
			_fail("scroll out of range for %d" % lv)
		claimed.clear()
	# reward 5 ready while Pip is on 6..: the chest must be above the bottom row
	var s6 := LevelPathKit.open_scroll(6, [5])
	var ch5: Vector2 = LevelPathKit.chest(5)["pos"]
	if ch5.y + 100.0 - s6 > LevelPathKit.VIEW_SAFE.y:
		_fail("ready reward 5 below Pip should be visible above the row on open")
	for id in SEASONS:
		var r := LevelPathKit.path_recipe(id)
		if r.is_empty():
			_fail("%s has no path recipe" % id)
			continue
		if (r.get("layers", []) as Array).size() > 21:
			_fail("%s path recipe has %d layers" % [id, (r["layers"] as Array).size()])
		var sc := LevelPathKit.scene(id)
		if sc.is_empty() or (sc.get("chunks", []) as Array).is_empty():
			_fail("%s path scene is empty" % id)
		for st in ["locked", "done", "current"]:
			if LevelPathKit.stone_tex(id, st) == null:
				_fail("%s missing checkpoint_%s" % [id, st])
		var locked := LevelPathKit.number_color(id, "locked")
		var face := UiSeasons.col(str(LevelPathKit.stone_spec(id).get("locked", {}).get("face", "#ffffff")))
		if UiSeasons.contrast(locked, face) < 4.5:
			_fail("%s locked number contrast %.2f < 4.5" % [id, UiSeasons.contrast(locked, face)])
	for st in ["reward_locked", "reward_ready", "reward_claimed", "open"]:
		for big in [false, true]:
			if LevelPathKit.chest_tex(st, big) == null:
				_fail("missing chest %s big=%s" % [st, str(big)])
	for fx in ["hop_dust", "land_ring", "ready_spark", "reward_burst", "confetti_peach", "confetti_mint", "confetti_lav"]:
		if LevelPathKit.fx_tex(fx) == null:
			_fail("missing fx %s" % fx)


func _check_home() -> void:
	var d := _domain()
	d.reset()
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.call("reset_seasons_to_s1")
	_gs.call("set_active_season", "country_bloom")
	_gs.set("level_path_hop", {})
	d.set_level("country_bloom", 7)
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(8)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.call("show_season", "country_bloom", false)
	await _frames(2)
	if not bool(stage.call("has_badge")):
		_fail("season card should carry the badge (reward 5 ready)")
	if not bool(stage.call("open_season_field", "country_bloom", false)):
		_fail("field did not open")
		return
	await _frames(4)
	if str(stage.call("play_action")) != "path":
		_fail("Play in the field should open the path, got %s" % stage.call("play_action"))
	if not bool(stage.call("has_badge")):
		_fail("Play in the field should carry the badge")
	stage.call("_on_play_pressed")
	await _wait(0.75)
	var path = stage.get("level_path")
	if not bool(stage.call("is_level_path_open")) or bool(stage.call("is_path_transitioning")):
		_fail("path should be open after 0.56 s")
		return
	if str(stage.call("play_action")) != "run":
		_fail("Play on the path should start the run")
	if bool(stage.call("has_badge")):
		_fail("badge on Play is only in the field")
	var seasons_btn = home.get_node("%SeasonsRowButton")
	if seasons_btn.label_text != "Field":
		_fail("left button should read Field on the path, got %s" % seasons_btn.label_text)
	var top := home.get_node("%TopChrome") as Control
	if top.visible:
		_fail("field chrome (Gift / Basket / Upgrades) should be gone on the path")
	if path.stone_state(7) != "current" or path.stone_state(6) != "done" or path.stone_state(8) != "locked":
		_fail("stones at 7 wrong")
	if path.chest_state(5) != "reward_ready" or path.chest_state(10) != "reward_locked":
		_fail("chests at 7 wrong")
	if path.title_text().find("7 / 20") < 0:
		_fail("title should show 7 / 20, got %s" % path.title_text())
	var feet: Vector2 = path.pip_page_feet()
	if feet.y < LevelPathKit.VIEW_SAFE.x or feet.y > LevelPathKit.VIEW_SAFE.y:
		_fail("Pip out of view on open (y %.0f)" % feet.y)
	if path.passed_point_count() != LevelPathKit.cp_index(7) + 1:
		_fail("passed road should end at stone 7")
	# zaključana nagrada → toast, bez popupa
	path.tap_reward(10)
	await _frames(2)
	if path.get_popup().is_open():
		_fail("locked reward must not open the popup")
	if not "Finish level 10 to claim" in path.toast_texts():
		_fail("locked reward toast missing: %s" % str(path.toast_texts()))
	await _wait(0.35)
	# lokator: skrol daleko → pojavi se; tap → nazad na Pipa
	path.set_scroll(0.0)
	if not path.is_locator_visible():
		_fail("Pip locator should show when Pip is off screen")
	path.scroll_to_pip()
	await _wait(0.5)
	if path.is_locator_visible():
		_fail("locator should hide after scrolling back to Pip")
	# claim nagrade 5
	var coins0 := int(_gs.get("wallet_coins"))
	var flower := str(_gs.call("star3_type_id_for_season", "country_bloom"))
	var f0 := int((_gs.get("garden_crystal_stash") as Dictionary).get(flower, 0))
	path.tap_reward(5)
	await _wait(0.3)
	var popup = path.get_popup()
	if not popup.is_open() or popup.title_text() != "Level 5 reward!":
		_fail("ready reward should open the popup")
	popup.claim()
	if int(_gs.get("wallet_coins")) != coins0 + 200 or int((_gs.get("garden_crystal_stash") as Dictionary).get(flower, 0)) != f0 + 2:
		_fail("claim 5 should add 200 coins and 2 × %s" % flower)
	await _wait(0.3)
	var fly = popup.get_node("RewardFly")
	if fly.get_child_count() > 16:
		_fail("popup flyers over budget: %d" % fly.get_child_count())
	if fly.get_child_count() != 7:
		_fail("reward 5 should launch 3 flowers + 4 coins, got %d" % fly.get_child_count())
	await _wait(1.0)
	if popup.is_busy() or fly.get_child_count() != 0:
		_fail("fly should be finished after 1 s")
	if path.chest_state(5) != "reward_claimed":
		_fail("chest 5 should be claimed")
	# skok poslije runa (kao povratak iz runa: put ostaje otvoren)
	_gs.call("finish_run", {}, 0, false, 30.0)
	if (_gs.get("level_path_hop") as Dictionary).is_empty():
		_fail("finish_run should queue the hop")
	stage.call("_restore_level_path")
	await _frames(2)
	if path.stone_state(7) != "current":
		_fail("hop should start from stone 7")
	await _wait(1.6)
	if path.stone_state(8) != "current" or path.stone_state(7) != "done":
		_fail("after the hop Pip should stand on 8")
	if path.fx_sprite_count() > 5:
		_fail("hop fx over budget: %d sprites (+ Pip ≤ 6)" % path.fx_sprite_count())
	# nagrada 20 i complete
	d.set_level("country_bloom", 21)
	_gs.set("level_path_hop", {"season": "country_bloom", "from": 20, "to": 21})
	stage.call("_restore_level_path")
	await _wait(2.0)
	if not path.is_banner_visible() or path.title_text().find("20 / 20") < 0:
		_fail("complete: banner and 20 / 20 expected")
	if path.chest_state(20) != "reward_ready":
		_fail("reward 20 should be ready after completing")
	path.tap_reward(20)
	await _wait(0.4)
	if not popup.is_open() or popup.title_text() != "Level 20 reward!":
		_fail("reward 20 popup should be open")
	popup.claim()
	await _wait(0.3)
	if fly.get_child_count() != 10:
		_fail("reward 20 should launch 5 + 5 flyers, got %d" % fly.get_child_count())
	await _wait(1.3)
	# ‹ Field nazad
	home.call("_on_seasons_row_pressed")
	await _wait(0.6)
	if bool(stage.call("is_level_path_open")) or bool(_gs.get("level_path_open")):
		_fail("Field button should close the path")
	if not bool(_gs.get("home_season_field_open")):
		_fail("closing the path must leave the field open")
	if seasons_btn.label_text != "Seasons":
		_fail("left button should read Seasons again, got %s" % seasons_btn.label_text)
	if not top.visible or top.modulate.a < 0.99:
		_fail("field chrome should be back")
	# tutorijal: Play u polju i dalje direktno run
	_gs.set("tutorial_complete", false)
	if str(stage.call("play_action")) != "run":
		_fail("during the tutorial Play in the field still runs")
	_gs.set("tutorial_complete", true)
	# polje zatvoreno izvana dok je put otvoren (Camp, Shop): put nestane bez prelaza
	stage.call("open_level_path", false)
	await _frames(3)
	stage.call("close_season_field", false)
	await _frames(3)
	if bool(_gs.get("level_path_open")) or path.visible:
		_fail("closing the field must close the path too")
	if not top.visible:
		_fail("field chrome must be restored after an external close")
	# povratak iz runa: novi hub, put ostaje otvoren i Pip skoči
	stage.call("open_season_field", "country_bloom", false)
	await _frames(3)
	stage.call("open_level_path", false)
	await _frames(3)
	d.set_level("country_bloom", 3)
	_gs.set("level_path_hop", {"season": "country_bloom", "from": 2, "to": 3})
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub reload failed")
		return
	await _frames(20)
	hub = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(6)
	host = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	home = host.get_node("Page_%d" % MetaHubPages.MAIN)
	stage = home.get_node("%SeasonStage")
	path = stage.get("level_path")
	if not bool(stage.call("is_level_path_open")):
		_fail("after a run the path should still be open")
		return
	if str(home.get_node("%SeasonsRowButton").get("label_text")) != "Field":
		_fail("after a run the left button should read Field")
	await _wait(1.6)
	if path.stone_state(3) != "current" or path.stone_state(2) != "done":
		_fail("after a run Pip should have hopped 2 → 3")
