extends SceneTree

## Prvo igranje (playtest 2026-10-22): tutorijal su dva vođena runa, pa Level 1.
##  1. novi save, Test seeds isključen: RUN1 = „Practice", bez prepreka;
##  2. „To Camp" s ~10 sjemenki vodi u Camp (Arena tek kad su vrata otvorena — 50 sjemenki);
##  3. RUN2 (bilo gdje da se pritisne Play) = prva prepreka; poslije njega tutorijal gotov, Level Path
##     ostaje na 1, sljedeći run je „Level 1" s najavom; korpa i put otključani;
##  4. s 50+ sjemenki „To Camp" vodi u Arenu i savjet za prvi spoj se pokazuje.
## Pokretanje: godot --headless --path game -s res://scripts/dev/tutorial_flow_smoke.gd

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const DEBUG_GD := "res://scripts/autoload/game_state_debug.gd"

var _backup := ""
var _flags_backup := ""
var _had_flags := false
var _failed := false
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("tutorial_flow_smoke: " + msg)


func _finish() -> void:
	var dbg = load(DEBUG_GD)
	if _had_flags:
		var f := FileAccess.open(dbg.DEV_FLAGS_PATH, FileAccess.WRITE)
		f.store_string(_flags_backup)
		f.close()
	elif FileAccess.file_exists(dbg.DEV_FLAGS_PATH):
		DirAccess.remove_absolute(dbg.DEV_FLAGS_PATH)
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("tutorial_flow_smoke OK")
	quit(1 if _failed else 0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(sec * 1000.0):
		await process_frame


func _run() -> void:
	await _frames(2)
	_gs = get_root().get_node("GameState")
	var dbg = load(DEBUG_GD)
	_had_flags = FileAccess.file_exists(dbg.DEV_FLAGS_PATH)
	_flags_backup = FileAccess.get_file_as_string(dbg.DEV_FLAGS_PATH) if _had_flags else ""
	dbg.set_test_bag_enabled(false)
	# Novi igrač.
	_gs.set("tutorial_complete", false)
	_gs.set("tutorial_step", 0)
	_gs.get("tutorial").set("merged", false)
	_gs.get("level_path_domain").reset()
	_gs.set("seed_bag", {})
	_gs.set("wallet_coins", 0)
	_gs.call("reset_seasons_to_s1")
	_gs.get("debug").set("_leftover_bag_applied", false)

	# 1 · RUN1: Practice, bez prepreka.
	_gs.call("begin_campaign_run")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	var run := current_scene
	run.set("_state", 2)
	var lbl := run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	if lbl.text != "Practice" or bool(_gs.call("obstacles_enabled_for_run")) or not bool(_gs.call("is_tutorial_run1")):
		_fail("run 1 should be Practice without obstacles (got '%s')" % lbl.text)
	if (run.get("level_intro") as Object).call("is_playing"):
		_fail("tutorial run must not show the level intro")
	_gs.call("finish_run", {"clover": 9}, 12, false, 45.0, 0)
	if not bool(_gs.call("is_tutorial_run2")) or int(_gs.call("season_level", "country_bloom")) != 1:
		_fail("after run 1: tutorial run 2 next, Level Path still on 1")

	# 2 · „To Camp" s ~10 sjemenki → Camp, ne Arena.
	if bool(_gs.call("should_offer_merge_arena")) or bool(_gs.call("should_prompt_merge_tutorial")):
		_fail("9 clovers must not open the Arena (gate needs 50)")
	_gs.call("go_to_camp")
	await _wait(1.5)
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("To Camp should land on the hub")
	else:
		var page := int(hubs[0].call("current_page_index"))
		if page != MetaHubPages.CAMP:
			_fail("To Camp with few seeds should open Camp, got page %d" % page)
	if bool(_gs.get("tutorial_complete")):
		_fail("hub / Arena boot must not finish the tutorial (Test seeds off)")

	# 3 · RUN2 s Homea (bez Campa): prepreka, pa kraj tutorijala.
	_gs.call("begin_campaign_run")
	if not bool(_gs.call("is_tutorial_run2")) or not bool(_gs.call("obstacles_enabled_for_run")):
		_fail("run 2 from Home should be the obstacle tutorial run")
	_gs.call("finish_run", {"clover": 4}, 8, true, 30.0, 0)
	if not bool(_gs.get("tutorial_complete")):
		_fail("the tutorial should end after the second run (even after a hit)")
	if int(_gs.call("season_level", "country_bloom")) != 1 or not _gs.get("level_path_hop").is_empty():
		_fail("finishing the tutorial must not move the Level Path")
	if not bool(_gs.call("loadout_enabled")):
		_fail("basket should unlock with the tutorial")

	# Sljedeći run = Level 1 s najavom.
	_gs.call("begin_campaign_run")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await _frames(12)
	run = current_scene
	run.set("_state", 2)
	lbl = run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	var intro = run.get("level_intro")
	if lbl.text != "Level 1" or not intro.is_playing() or intro.sub_text() != "Stroll · 1:00":
		_fail("first run after the tutorial should be 'Level 1' with the intro (got '%s')" % lbl.text)

	# 4 · S 50+ sjemenki → Arena + savjet za prvi spoj.
	_gs.set("seed_bag", {"clover": 30, "daisy": 24})
	if not bool(_gs.call("should_offer_merge_arena")) or not bool(_gs.call("should_prompt_merge_tutorial")):
		_fail("with 54 mergeable seeds To Camp should open the Arena with the merge tip")
	_finish()
