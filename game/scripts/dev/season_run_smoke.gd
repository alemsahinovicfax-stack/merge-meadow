extends SceneTree

## SEZ-D — season spawn pool + BG tint; shared levels.

const SAVE_PATH := "user://player_save.json"
const UnlockCfg := preload("res://scripts/progression/seed_unlock_config.gd")


var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("season_run_smoke: %s" % msg)
	_quit(1)


func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.call("reset_seasons_to_s1")
	gs.set("seed_unlock_index", UnlockCfg.chain_size() - 1)
	gs.set("loadout_type_id", "")
	gs.set("wallet_coins", 80)
	gs.set("garden_crystal_stash", {"clover": 5})

	var s1_pool: Array = gs.call("get_active_season_spawn_types")
	if not s1_pool.has("clover") or not s1_pool.has("pumpkin"):
		_fail("S1 pool should include clover and pumpkin")
		return
	if s1_pool.has("watermelon"):
		_fail("S1 pool must not include watermelon")
		return

	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"pumpkin": 20})
	if not bool(gs.call("unlock_free", "frost_orchard")):
		_fail("could not unlock frost_orchard")
		return
	var frost_pool: Array = gs.call("get_active_season_spawn_types")
	if not frost_pool.has("frost_snowdrop"):
		_fail("frost pool missing frost_snowdrop")
		return
	if frost_pool.has("clover") or frost_pool.has("watermelon") or frost_pool.has("pumpkin"):
		_fail("frost pool should not include clover/watermelon/pumpkin")
		return
	if frost_pool.size() == 3 and frost_pool.has("daisy") and frost_pool.has("buttercup"):
		_fail("frost pool still Bloom clover-daisy-buttercup")
		return

	gs.set("loadout_type_id", "pumpkin")
	for _i in 40:
		var picked := str(gs.call("pick_random_run_seed_type"))
		if picked == "watermelon" or picked == "pumpkin":
			_fail("frost+pumpkin loadout spawned Bloom type %s" % picked)
			return
		if not frost_pool.has(picked):
			_fail("pick outside frost pool: %s" % picked)
			return

	gs.call("reset_seasons_to_s1")
	gs.set("seed_unlock_index", UnlockCfg.chain_size() - 1)
	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		_fail("run_scene load failed %d" % err)
		return
	for _j in 16:
		await process_frame
	var run := current_scene
	var bg: Node = run.get_node_or_null("Background") if run else null
	if bg == null or not bg.has_method("apply_theme"):
		_fail("Background apply_theme missing")
		return
	# Season Kit faza 2: sezona je u kitu runa (tlo, materijal staze), ne u tintu —
	# modulate je samo kozmetika i ostaje isti; mijenja se run kita.
	var m1: Color = bg.get("modulate")
	var run1: Dictionary = bg.get("_run")
	gs.set("wallet_coins", 500)
	gs.set("garden_crystal_stash", {"pumpkin": 20})
	if not bool(gs.call("unlock_free", "frost_orchard")):
		_fail("frost unlock before kit compare failed")
		return
	bg.call("apply_theme")
	await process_frame
	var m2: Color = bg.get("modulate")
	var run2: Dictionary = bg.get("_run")
	if not m1.is_equal_approx(m2):
		_fail("BG modulate is cosmetic only — must not change with the season")
		return
	if not bool(bg.call("has_kit")) or str(run1.get("ground", "")) == str(run2.get("ground", "")):
		_fail("run kit should change S1 vs frost (ground %s → %s)" % [run1.get("ground"), run2.get("ground")])
		return
	if str((run2.get("material", {}) as Dictionary).get("kind", "")) != "rut":
		_fail("frost run material should be the sled rut")
		return
	if run.get_node_or_null("HUD/TopHud/CoinChip") == null or run.get_node_or_null("HUD/TopHud/SeedChip") == null:
		_fail("Coin/Seed chips missing (run HUD v2 layout)")
		return

	print("season_run_smoke OK")
	_quit(0)
