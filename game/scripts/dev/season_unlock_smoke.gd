extends SceneTree

## SEZ-B — SeasonDef catalog + GameState unlock/active/paid API.

const SAVE_PATH := "user://player_save.json"
const S1 := "country_bloom"
const S2 := "frost_orchard"
const S3 := "lantern_meadow"
const PAID := "moonlit_warren"


## Cijene besplatnih sezona (seasons.json): S2 = Frost, S3 = Lantern, a = Amber.
var c2 := 0
var f2 := 0
var c3 := 0
var f3 := 0
var ca := 0
var fa := 0
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
	push_error("season_unlock_smoke: %s" % msg)
	_quit(1)


func _reset_new_game(gs: Node) -> void:
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.call("reset_seasons_to_s1")


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	var defs: Array = SeasonCatalog.all_defs()
	if defs.size() != 8:
		_fail("catalog size %d expected 8" % defs.size())
		return
	var roster_ids: Dictionary = {}
	var roster_total := 0
	for def_any in defs:
		var def_row: SeasonDef = def_any
		if def_row.roster.size() != 6:
			_fail("%s roster size %d expected 6" % [def_row.id, def_row.roster.size()])
			return
		for entry in def_row.roster:
			var rid := str(entry.get("id", ""))
			if rid.is_empty() or roster_ids.has(rid):
				_fail("roster id missing or duplicate: %s" % rid)
				return
			roster_ids[rid] = true
			roster_total += 1
	if roster_total != 48:
		_fail("roster total %d expected 48" % roster_total)
		return
	var s1_def: SeasonDef = SeasonCatalog.get_def(S1)
	if s1_def == null or s1_def.seed_type_ids.size() != 6:
		_fail("S1 seed pool not 6 types")
		return
	if str(s1_def.seed_type_ids[0]) != "clover" or str(s1_def.seed_type_ids[5]) != "pumpkin":
		_fail("S1 seed pool mismatch")
		return
	if s1_def.seed_type_ids.has("watermelon"):
		_fail("S1 pool must not include watermelon")
		return
	# Cijene su iz seasons.json (balans ciklus 1): svaka sljedeća besplatna sezona skuplja, ≥ 20 ★3.
	var s3_def: SeasonDef = SeasonCatalog.get_def(S3)
	var s2_def: SeasonDef = SeasonCatalog.get_def(S2)
	var amber_def: SeasonDef = SeasonCatalog.get_def("amber_canopy")
	if s2_def == null or s3_def == null or amber_def == null:
		_fail("free season defs missing")
		return
	if not (0 < s2_def.coins_cost and s2_def.coins_cost < s3_def.coins_cost and s3_def.coins_cost < amber_def.coins_cost):
		_fail("free season coin costs should rise S2 < S3 < Amber")
		return
	for d in [s2_def, s3_def, amber_def]:
		if d.t3_flowers_required < 20:
			_fail("%s should need ≥ 20 star-3" % d.id)
			return
	c2 = s2_def.coins_cost
	f2 = s2_def.t3_flowers_required
	c3 = s3_def.coins_cost
	f3 = s3_def.t3_flowers_required
	ca = amber_def.coins_cost
	fa = amber_def.t3_flowers_required
	if s1_def.roster.is_empty() or str(s1_def.roster[0].get("id", "")) != "clover":
		_fail("Bloom roster id 0 expected clover")
		return
	if s2_def.seed_type_ids.size() != 6 or str(s2_def.seed_type_ids[0]) != "frost_snowdrop":
		_fail("Frost seed_type_ids expected 6 starting frost_snowdrop")
		return
	var catalog_ids: Array = SeedCatalog.all_type_ids()
	if catalog_ids.size() != 48:
		_fail("SeedCatalog size %d expected 48" % catalog_ids.size())
		return
	var catalog_seen: Dictionary = {}
	for tid_any in catalog_ids:
		var tid := str(tid_any)
		if catalog_seen.has(tid):
			_fail("SeedCatalog duplicate %s" % tid)
			return
		catalog_seen[tid] = true
	if not catalog_ids.has("clover") or not catalog_ids.has("frost_snowdrop"):
		_fail("SeedCatalog missing clover or frost_snowdrop")
		return
	if str(SeedCatalog.season_id_for("frost_snowdrop")) != S2:
		_fail("frost_snowdrop season_id_for expected frost_orchard")
		return
	if catalog_ids.has("watermelon"):
		_fail("SeedCatalog must not include watermelon")
		return
	if SeedCatalog.rarity("pumpkin") != 3:
		_fail("pumpkin rarity expected 3")
		return
	for def_any in defs:
		var star_def: SeasonDef = def_any
		var star3_n := 0
		for entry in star_def.roster:
			if int(entry.get("rarity", 1)) == 3:
				star3_n += 1
		if star3_n != 1:
			_fail("%s should have exactly 1 rarity-3, got %d" % [star_def.id, star3_n])
			return
	if str(gs.call("star3_type_id_for_season", S1)) != "pumpkin":
		_fail("Bloom star-3 should be pumpkin")
		return

	_reset_new_game(gs)
	if str(gs.get("active_season_id")) != S1:
		_fail("new game active not S1")
		return
	var unlocked: Array = gs.get("unlocked_seasons")
	if unlocked.size() != 1 or str(unlocked[0]) != S1:
		_fail("new game should unlock only S1")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("S2 should not be playable on new game")
		return
	if bool(gs.call("is_season_playable", PAID)):
		_fail("paid should not be playable before grant")
		return
	if bool(gs.call("set_active_season", S2)):
		_fail("set_active S2 should fail")
		return
	if str(gs.get("active_season_id")) != S1:
		_fail("active changed after failed set_active")
		return

	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with 0 coins/T3 should fail")
		return
	gs.set("wallet_coins", c2 - 1)
	gs.set("garden_crystal_stash", {"pumpkin": f2})
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with %d coins should fail" % (c2 - 1))
		return
	if int(gs.get("wallet_coins")) != c2 - 1:
		_fail("coins spent on failed coin gate")
		return
	gs.set("wallet_coins", c2)
	gs.set("garden_crystal_stash", {})
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with coins but 0 T3 should fail")
		return
	if int(gs.get("wallet_coins")) != c2:
		_fail("coins spent on failed T3 gate")
		return

	gs.set("wallet_coins", c2)
	gs.set("garden_crystal_stash", {"clover": f2})
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with clover T3 (not star-3) should fail")
		return
	if int(gs.get("wallet_coins")) != c2:
		_fail("coins spent on clover T3 gate")
		return
	gs.set("wallet_coins", c2)
	gs.set("garden_crystal_stash", {"pumpkin": f2})
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 unlock before S2 should fail")
		return
	if int(gs.get("wallet_coins")) != c2:
		_fail("coins spent on blocked S3")
		return
	var stash_before: Dictionary = gs.get("garden_crystal_stash")
	if int(stash_before.get("pumpkin", 0)) != f2:
		_fail("T3 stash mutated on blocked S3")
		return

	if not bool(gs.call("grant_paid_season", PAID)):
		_fail("grant_paid_season failed")
		return
	if not bool(gs.call("is_season_playable", PAID)):
		_fail("paid not playable after grant without S2")
		return
	if str(gs.get("active_season_id")) != PAID:
		_fail("P12 auto-switch paid failed")
		return
	if bool(gs.call("is_season_playable", S2)):
		_fail("grant paid should not unlock free S2")
		return

	_reset_new_game(gs)
	gs.set("wallet_coins", c2)
	gs.set("garden_crystal_stash", {"clover": 3, "daisy": 2})
	if int(gs.call("t3_flower_count")) != 5:
		_fail("t3_flower_count expected 5")
		return
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with 5 T3 should fail")
		return
	gs.set("garden_crystal_stash", {"clover": 12, "daisy": 8})
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with non-star-3 T3 should fail")
		return
	gs.set("garden_crystal_stash", {"pumpkin": f2})
	if not bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock should succeed")
		return
	if int(gs.get("wallet_coins")) != 0:
		_fail("S2 should spend %d coins" % c2)
		return
	stash_before = gs.get("garden_crystal_stash")
	if int(stash_before.get("pumpkin", 0)) != 0:
		_fail("S2 should spend %d pumpkin star-3" % f2)
		return
	if str(gs.get("active_season_id")) != S2:
		_fail("P12 auto-switch S2 failed")
		return

	gs.set("wallet_coins", 0)
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 after S2 still needs %d coins" % c3)
		return
	gs.set("wallet_coins", c3)
	gs.set("garden_crystal_stash", {"pumpkin": f3 - 1})
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 after S2 still needs %d star-3 from Frost" % f3)
		return
	gs.set("garden_crystal_stash", {"crystal_peony": f3 - 1})
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 after S2 still needs %d T3" % f3)
		return

	gs.set("active_season_id", S1)
	gs.set("wallet_coins", 99)
	if not bool(gs.call("load_player_save")):
		_fail("load after S2 save failed")
		return
	if str(gs.get("active_season_id")) != S2:
		_fail("save round-trip active expected S2")
		return
	unlocked = gs.get("unlocked_seasons")
	if not unlocked.has(S2):
		_fail("save round-trip missing S2")
		return

	gs.set("wallet_coins", c3)
	gs.set("garden_crystal_stash", {"crystal_peony": f3})
	if not bool(gs.call("can_unlock_free", S3)):
		_fail("S3 should be unlockable after S2 + %d coins + %d Frost star-3" % [c3, f3])
		return
	if not bool(gs.call("unlock_free", S3)):
		_fail("S3 unlock should succeed")
		return
	if not bool(gs.call("is_season_playable", S3)):
		_fail("S3 should be playable after unlock")
		return
	if bool(gs.call("is_test_locked_season", "amber_canopy")):
		_fail("amber_canopy must not be test-locked")
		return
	if not bool(gs.call("is_free_selectable", "amber_canopy")):
		_fail("amber_canopy should be selectable as next-lock after lantern")
		return
	if not bool(gs.call("is_test_locked_season", "ember_fen")):
		_fail("ember_fen must stay test-locked")
		return
	gs.set("wallet_coins", ca)
	gs.set("garden_crystal_stash", {"midnight_lotus": fa})
	if not bool(gs.call("can_unlock_free", "amber_canopy")):
		_fail("can_unlock_free(amber) should work after lantern + %dc/%d Lantern star-3" % [ca, fa])
		return
	if not bool(gs.call("unlock_free", "amber_canopy")):
		_fail("amber unlock should succeed")
		return
	if not bool(gs.call("is_season_playable", "amber_canopy")):
		_fail("amber should be playable after unlock")
		return

	_reset_new_game(gs)
	gs.set("wallet_coins", c2)
	gs.set("garden_crystal_stash", {"pumpkin": f2})
	if not bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock before debug skip test failed")
		return
	gs.call("debug_unlock_all_seasons")
	if bool(gs.call("is_season_playable", S3)):
		_fail("debug_unlock_all must skip lantern_meadow")
		return
	if not bool(gs.call("is_free_selectable", S3)):
		_fail("lantern_meadow should be selectable as next-lock")
		return
	if bool(gs.call("is_free_selectable", "amber_canopy")):
		_fail("amber_canopy must not be selectable")
		return
	if bool(gs.call("is_season_playable", "amber_canopy")):
		_fail("debug_unlock_all must skip amber_canopy")
		return
	gs.set("wallet_coins", c3)
	gs.set("garden_crystal_stash", {"crystal_peony": f3})
	if not bool(gs.call("can_unlock_free", S3)):
		_fail("can_unlock_free(lantern) should still work")
		return

	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var migrate := {
		"version": 8,
		"tutorial_complete": true,
		"wallet_coins": 4,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_fail("could not write migrate save")
		return
	file.store_string(JSON.stringify(migrate))
	file.close()
	if not bool(gs.call("load_player_save")):
		_fail("v8 migrate load failed")
		return
	if str(gs.get("active_season_id")) != S1:
		_fail("v8 migrate active not S1")
		return
	unlocked = gs.get("unlocked_seasons")
	if unlocked.size() != 1 or str(unlocked[0]) != S1:
		_fail("v8 migrate unlocked not S1 only")
		return
	var owned: Array = gs.get("owned_paid_seasons")
	if owned.size() != 0:
		_fail("v8 migrate paid not empty")
		return

	print("season_unlock_smoke OK")
	_quit(0)
