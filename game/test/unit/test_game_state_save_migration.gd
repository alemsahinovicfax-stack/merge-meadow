## Characterizes GameState's current _apply_save_dict()/migration behavior
## (game_state.gd ~836-903, SAVE_VERSION=12) BEFORE the Stage 5 SaveManager
## extraction (plan-arhitektura-refaktor.md). _apply_save_dict is the single
## highest-risk function in the whole file (populates ~35 vars from one dict) —
## these tests lock in today's exact defaulting/migration behavior, bugs included,
## so Stage 5 can prove it changed nothing.
##
## NOTE: a save dict with version < SAVE_VERSION triggers _migrate_legacy_beds_to_inbox(),
## which calls push_bloom_inbox() internally, which calls save_player_save() —
## i.e. this test path DOES write to disk. The base class backs up/restores the
## real user://player_save.json around every test for exactly this reason.
extends "res://test/unit/game_state_test_base.gd"


func after_each() -> void:
	super.after_each()
	if _save_existed:
		# Re-sync the live singleton's in-memory state from the just-restored
		# real save file, so later test files in this suite run don't see the
		# mutations _apply_save_dict made to ~35 vars during this file's tests.
		_gs.load_player_save()


func test_apply_save_dict_rejects_version_below_1() -> void:
	var wallet_before: int = _gs.wallet_coins
	var ok: bool = _gs.call("_apply_save_dict", {"version": 0, "wallet_coins": 999})
	assert_false(ok, "version 0 (or missing) must be rejected")
	assert_eq(_gs.wallet_coins, wallet_before, "a rejected dict must not mutate any state")


func test_apply_save_dict_defaults_missing_fields() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {"version": 1})
	assert_true(ok)
	assert_eq(_gs.wallet_coins, 0)
	assert_eq(_gs.wallet_diamonds, 0)
	assert_eq(_gs.seed_bag, {})
	assert_eq(_gs.magnet_level, 0)
	assert_eq(_gs.multiplier_level, 0)
	assert_eq(_gs.get_active_companion_id(), _gs.COMPANION_PIP, "unknown/missing companion must fall back to Pip")
	assert_eq(_gs.active_season_id, SeasonCatalog.DEFAULT_SEASON_ID)


func test_apply_save_dict_clamps_magnet_level_above_max() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {"version": 1, "magnet_level": 999})
	assert_true(ok)
	assert_eq(_gs.magnet_level, _gs.MAGNET_MAX_LEVEL, "magnet_level must clamp to MAGNET_MAX_LEVEL, not store 999")


func test_apply_save_dict_clears_greenhouse_beds_unconditionally() -> void:
	# Characterizes existing (surprising) behavior: _clear_legacy_beds() runs on
	# every load regardless of version, and only garden_beds gets re-padded by
	# _ensure_garden_bed_capacity() afterward — greenhouse_beds stays empty.
	var ok: bool = _gs.call("_apply_save_dict", {
		"version": 1,
		"greenhouse_beds": [{"type_id": "clover", "tier": 1}],
	})
	assert_true(ok)
	assert_eq(_gs.greenhouse_beds.size(), 0, "greenhouse_beds is always cleared on load today")
	assert_eq(_gs.garden_beds.size(), _gs.get_garden_bed_capacity(), "garden_beds is re-padded to capacity after clearing")
	for bed in _gs.garden_beds:
		assert_null(bed)


func test_legacy_t2_plus_beds_migrate_to_bloom_inbox_on_old_version() -> void:
	var old_beds: Array = [null, null, null, null, null, null, null, null, null]
	old_beds[0] = {"type_id": "clover", "tier": 2}
	var ok: bool = _gs.call("_apply_save_dict", {
		"version": 1,
		"garden_beds": old_beds,
		"bloom_inbox": [],
	})
	assert_true(ok)
	assert_eq(_gs.count_bloom_inbox(2), 1, "the tier-2 legacy bed should have migrated into bloom_inbox")
	var entries: Array = _gs.get_bloom_inbox_entries()
	assert_eq(str(entries[0].get("type_id", "")), "clover")
	assert_eq(int(entries[0].get("tier", 0)), 2)


func test_legacy_t1_beds_do_not_migrate_to_bloom_inbox() -> void:
	var old_beds: Array = [null, null, null, null, null, null, null, null, null]
	old_beds[0] = {"type_id": "clover", "tier": 1}
	_gs.call("_apply_save_dict", {"version": 1, "garden_beds": old_beds, "bloom_inbox": []})
	assert_eq(_gs.count_bloom_inbox(1), 0, "tier-1 beds are below the tier>=2 migration threshold")


func test_apply_save_dict_does_not_migrate_when_version_is_current() -> void:
	var old_beds: Array = [null, null, null, null, null, null, null, null, null]
	old_beds[0] = {"type_id": "clover", "tier": 2}
	_gs.call("_apply_save_dict", {
		"version": _gs.SAVE_VERSION,
		"garden_beds": old_beds,
		"bloom_inbox": [],
	})
	assert_eq(_gs.count_bloom_inbox(2), 0, "a save already at the current version must not re-run bed migration")
