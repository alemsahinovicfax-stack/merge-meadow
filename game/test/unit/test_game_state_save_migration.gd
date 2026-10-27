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


## Dijamanti su izbačeni (2026-10-09): stari save s "wallet_diamonds" se učita, ključ se ignoriše.
func test_old_save_with_diamonds_still_loads() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {"version": 1, "wallet_coins": 12, "wallet_diamonds": 7})
	assert_true(ok, "a save that still carries wallet_diamonds must load")
	assert_eq(_gs.wallet_coins, 12)
	assert_false("wallet_diamonds" in _gs, "GameState must not keep a diamond wallet")


func test_apply_save_dict_defaults_missing_fields() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {"version": 1})
	assert_true(ok)
	assert_eq(_gs.wallet_coins, 0)
	assert_eq(_gs.seed_bag, {})
	assert_eq(_gs.magnet_level, 0)
	assert_eq(_gs.multiplier_level, 0)
	assert_eq(_gs.get_active_companion_id(), _gs.COMPANION_PIP, "unknown/missing companion must fall back to Pip")
	assert_eq(_gs.active_season_id, SeasonCatalog.DEFAULT_SEASON_ID)


func test_apply_save_dict_clamps_magnet_level_above_max() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {"version": 1, "magnet_level": 999})
	assert_true(ok)
	assert_eq(_gs.magnet_level, _gs.MAGNET_MAX_LEVEL, "magnet_level must clamp to MAGNET_MAX_LEVEL, not store 999")


func test_apply_save_dict_clears_legacy_beds_unconditionally() -> void:
	# Characterizes existing behavior: _clear_legacy_beds() runs on every load
	# regardless of save version. garden_beds/greenhouse_beds only survive as a
	# landing pad for _migrate_legacy_beds_to_inbox() (see that test below) — the
	# bed-merge gameplay itself was removed as dead code in
	# plan-arhitektura-refaktor.md Stage 4.4 (2026-09-07).
	var ok: bool = _gs.call("_apply_save_dict", {
		"version": 1,
		"garden_beds": [{"type_id": "clover", "tier": 1}],
		"greenhouse_beds": [{"type_id": "clover", "tier": 1}],
	})
	assert_true(ok)
	assert_eq(_gs.garden_beds.size(), 0, "garden_beds is always cleared on load")
	assert_eq(_gs.greenhouse_beds.size(), 0, "greenhouse_beds is always cleared on load")


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
	var entries: Array = _gs.bloom_inbox
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


## RET-01: save bez "activity" (sve do 2026-10-26) se učita bez promjene SAVE_VERSION; brojač
## počne od danas, a prvi dan ostaje pravi (iz first_launch_unix), raniji dani nepoznati.
func test_save_without_activity_starts_log_with_unknown_past() -> void:
	var first_launch := int(Time.get_unix_time_from_system()) - 5 * 86400
	var ok: bool = _gs.call("_apply_save_dict", {"version": _gs.SAVE_VERSION, "first_launch_unix": first_launch})
	assert_true(ok)
	var act: ActivityLog = _gs.activity
	assert_eq(act.first_day, "", "headless GameState does not start the log by itself")
	var today: String = _gs.call("_today_key")
	act.start(today, int(Time.get_unix_time_from_system()), _gs.first_launch_unix)
	assert_eq(act.first_day, ActivityLog.local_day_key(first_launch))
	assert_gt(act.since, 0, "days before the log existed are unknown")


func test_activity_round_trips_through_save_dict() -> void:
	var ok: bool = _gs.call("_apply_save_dict", {
		"version": _gs.SAVE_VERSION,
		"activity": {"v": 1, "first_day": "2026-10-26", "since": 0, "days": [{"d": 0, "s": 2, "sec": 300, "r": 4, "lv": 3, "se": "country_bloom"}], "tot": {"s": 2, "sec": 300, "r": 4}},
	})
	assert_true(ok)
	var act: ActivityLog = _gs.activity
	assert_eq(act.first_day, "2026-10-26")
	assert_eq(act.total_runs, 4)
	_gs.save_player_save()
	var saved: Variant = JSON.parse_string(FileAccess.get_file_as_string(PLAYER_SAVE_PATH))
	assert_true(saved is Dictionary and (saved as Dictionary).has("activity"), "save must carry the activity key")
	assert_eq(str(saved.activity.first_day), "2026-10-26")
	assert_eq(int(saved.activity.tot.r), 4)
