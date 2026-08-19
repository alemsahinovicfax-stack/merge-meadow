extends SceneTree

## SEZ-B — SeasonDef catalog + GameState unlock/active/paid API.

const SAVE_PATH := "user://player_save.json"
const S1 := "country_bloom"
const S2 := "frost_orchard"
const S3 := "lantern_meadow"
const PAID := "moonlit_warren"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("season_unlock_smoke: %s" % msg)
	quit(1)


func _reset_new_game(gs: Node) -> void:
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.call("reset_seasons_to_s1")


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	var defs: Array = SeasonCatalog.all_defs()
	if defs.size() != 5:
		_fail("catalog size %d expected 5" % defs.size())
		return
	var s1_def: SeasonDef = SeasonCatalog.get_def(S1)
	if s1_def == null or s1_def.seed_type_ids.size() != 7:
		_fail("S1 seed pool not 7 types")
		return
	if str(s1_def.seed_type_ids[0]) != "clover" or str(s1_def.seed_type_ids[6]) != "watermelon":
		_fail("S1 seed pool mismatch")
		return
	var s3_def: SeasonDef = SeasonCatalog.get_def(S3)
	if s3_def == null or s3_def.t3_flowers_required != 8 or s3_def.coins_cost != 150:
		_fail("S3 costs expected 150 coins + 8 T3")
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
	gs.set("wallet_coins", 80)
	gs.set("garden_crystal_stash", {})
	if bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock with coins but 0 T3 should fail")
		return
	if int(gs.get("wallet_coins")) != 80:
		_fail("coins spent on failed T3 gate")
		return

	gs.set("wallet_coins", 150)
	gs.set("garden_crystal_stash", {"clover": 8})
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 unlock before S2 should fail")
		return
	if int(gs.get("wallet_coins")) != 150:
		_fail("coins spent on blocked S3")
		return
	var stash_before: Dictionary = gs.get("garden_crystal_stash")
	if int(stash_before.get("clover", 0)) != 8:
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
	gs.set("wallet_coins", 80)
	gs.set("garden_crystal_stash", {"clover": 3, "daisy": 2})
	if int(gs.call("t3_flower_count")) != 5:
		_fail("t3_flower_count expected 5")
		return
	if not bool(gs.call("unlock_free", S2)):
		_fail("S2 unlock should succeed")
		return
	if int(gs.get("wallet_coins")) != 0:
		_fail("S2 should spend 80 coins")
		return
	stash_before = gs.get("garden_crystal_stash")
	if int(stash_before.get("clover", 0)) != 3 or int(stash_before.get("daisy", 0)) != 2:
		_fail("T3 check-only violated")
		return
	if str(gs.get("active_season_id")) != S2:
		_fail("P12 auto-switch S2 failed")
		return

	gs.set("wallet_coins", 0)
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 after S2 still needs 150 coins")
		return
	gs.set("wallet_coins", 150)
	gs.set("garden_crystal_stash", {"clover": 7})
	if bool(gs.call("unlock_free", S3)):
		_fail("S3 after S2 still needs 8 T3")
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
	quit(0)
