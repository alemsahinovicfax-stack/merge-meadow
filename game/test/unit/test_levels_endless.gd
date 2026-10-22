## design_handoff_leveli_endless (2026-10-22): pojasevi težine, napredak prema Endlessu, trenutak
## otključavanja (jednom po sezoni, u saveu) i rekord kroz Revive. Izgled i run: levels_endless_smoke.
extends "res://test/unit/game_state_test_base.gd"


func after_each() -> void:
	super.after_each()
	_gs.run_is_endless = false
	_gs.load_player_save()


func test_band_of_level() -> void:
	var want := {1: 1, 5: 1, 6: 2, 10: 2, 11: 3, 15: 3, 16: 4, 20: 4, 21: 4, 0: 1}
	for lv in want:
		assert_eq(UiLevels.band_of(lv), int(want[lv]), "level %d" % lv)
	for lv in [5, 10, 15, 20]:
		assert_true(UiLevels.is_peak(lv), "peak %d" % lv)
	assert_false(UiLevels.is_peak(14))


func test_pace_heat_bands() -> void:
	assert_eq(UiLevels.pace_band(0), 1)
	assert_eq(UiLevels.pace_band(3), 2)
	assert_eq(UiLevels.pace_band(6), 3)
	assert_eq(UiLevels.pace_band(9), 4)
	assert_eq(UiLevels.pace_band(40), 4)


func test_endless_progress_counts_passed_levels() -> void:
	var lp: LevelPathDomain = _gs.level_path_domain
	lp.reset()
	assert_eq(lp.endless_progress("frost_orchard"), 0)
	lp.set_level("frost_orchard", 9)
	assert_eq(lp.endless_progress("frost_orchard"), 8)
	lp.set_level("frost_orchard", 21)
	assert_eq(lp.endless_progress("frost_orchard"), 15)


func test_unlock_moment_once_and_saved() -> void:
	var lp: LevelPathDomain = _gs.level_path_domain
	lp.reset()
	lp.set_level("coral_tide", 15)
	assert_false(lp.take_endless_unlock_moment("coral_tide"), "still locked on 15")
	lp.set_level("coral_tide", 16)
	assert_true(lp.take_endless_unlock_moment("coral_tide"))
	assert_false(lp.take_endless_unlock_moment("coral_tide"), "only once")
	var copy := LevelPathDomain.new(_gs)
	copy.apply_from_save(lp.to_save_dict())
	assert_true(copy.endless_seen.has("coral_tide"))
	assert_false(copy.take_endless_unlock_moment("coral_tide"))


func test_record_through_revive_compares_with_run_start() -> void:
	_gs.tutorial_complete = true
	_gs.set_active_season("country_bloom")
	_gs.level_path_domain.endless_best["country_bloom"] = 265.0
	_gs.begin_endless_run()
	_gs.finish_run({}, 2, true, 300.0, 0)
	assert_true(_gs.last_endless_new_best)
	assert_almost_eq(_gs.last_endless_prev_best, 265.0, 0.001)
	assert_true(_gs._apply_revive_clawback())
	_gs.finish_run({}, 2, true, 305.0, 0)
	assert_true(_gs.last_endless_new_best, "still a record over 4:25")
	assert_almost_eq(_gs.last_endless_prev_best, 265.0, 0.001, "Was 4:25, not the first fall")
	assert_almost_eq(_gs.endless_best_sec("country_bloom"), 305.0, 0.001)


func test_revive_below_old_record_is_not_new_best() -> void:
	_gs.tutorial_complete = true
	_gs.set_active_season("country_bloom")
	_gs.level_path_domain.endless_best["country_bloom"] = 265.0
	_gs.begin_endless_run()
	_gs.finish_run({}, 2, true, 200.0, 0)
	assert_false(_gs.last_endless_new_best)
	assert_true(_gs._apply_revive_clawback())
	_gs.finish_run({}, 2, true, 250.0, 0)
	assert_false(_gs.last_endless_new_best)
	assert_almost_eq(_gs.endless_best_sec("country_bloom"), 265.0, 0.001)
