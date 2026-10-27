## RET-01 — ActivityLog: dani od prvog pokretanja, sesije, vrijeme igre, save i Copy red.
## Vrijeme se daje izvana (datum + unix), pa ponoć, vremenske zone i sat unazad idu bez čekanja.
extends GutTest

const D0 := "2026-10-26"
const D1 := "2026-10-27"
const D2 := "2026-10-28"
const D3 := "2026-10-29"
const T0 := 1_800_000_000

var _log: ActivityLog


func before_each() -> void:
	_log = ActivityLog.new()


func _dashes(n: int) -> String:
	return "-".repeat(n)


func test_new_player_starts_on_day_zero() -> void:
	_log.start(D0, T0, 0)
	assert_eq(_log.first_day, D0)
	assert_eq(_log.since, 0)
	assert_eq(_log.day_index(D0), 0)
	assert_eq(_log.total_sessions, 1)
	assert_true(_log.played_on(0))
	assert_eq(_log.days_string(D0), "1" + _dashes(30))


func test_next_day_counts_as_d1_and_missed_day_as_zero() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 60)
	_log.resume(D1, T0 + 90_000)
	assert_eq(_log.total_sessions, 2)
	assert_eq(_log.days_string(D1), "11" + _dashes(29))
	_log.pause(D1, T0 + 90_100)
	_log.resume(D3, T0 + 260_000)
	assert_eq(_log.days_string(D3), "1101" + _dashes(27), "day 2 was missed")
	assert_eq(_log.days_played(), 3)


func test_short_background_is_same_session() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 60)
	_log.resume(D0, T0 + 100)
	assert_eq(_log.total_sessions, 1, "40 s away is the same session")
	_log.pause(D0, T0 + 200)
	_log.resume(D0, T0 + 200 + ActivityLog.SESSION_GAP_SEC)
	assert_eq(_log.total_sessions, 2, "5 min away starts a new session")
	assert_eq(int(_log.days[0].s), 2)


func test_clock_jump_back_in_background_is_new_session() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 5000)
	_log.resume(D0, T0 + 4000)
	assert_eq(_log.total_sessions, 2)


func test_tick_caps_each_step() -> void:
	_log.start(D0, T0, 0)
	_log.tick(D0, T0 + 30)
	assert_eq(_log.total_sec, 30)
	_log.tick(D0, T0 + 5000)
	assert_eq(_log.total_sec, 30 + ActivityLog.MAX_TICK_SEC, "a jump of hours adds at most one step")
	_log.tick(D0, T0 + 4000)
	assert_eq(_log.total_sec, 30 + ActivityLog.MAX_TICK_SEC, "clock going back adds nothing")


func test_paused_log_does_not_count_time() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 20)
	_log.tick(D0, T0 + 50)
	assert_eq(_log.total_sec, 20)


func test_midnight_carries_the_session_into_the_new_day() -> void:
	_log.start(D0, T0, 0)
	_log.tick(D1, T0 + 30)
	assert_eq(_log.total_sessions, 1)
	assert_true(_log.played_on(1))
	assert_eq(int(_log.days[1].s), 1)
	assert_eq(int(_log.days[1].sec), 30)


func test_timezone_hop_back_and_forth_does_not_duplicate() -> void:
	_log.start(D0, T0, 0)
	_log.tick(D1, T0 + 30)
	_log.tick(D0, T0 + 60)
	_log.tick(D1, T0 + 90)
	assert_eq(_log.days.size(), 2)
	assert_eq(_log.total_sessions, 1)
	assert_eq(_log.last_day, 1)


func test_clock_before_first_day_is_ignored() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 10)
	_log.resume("2026-10-20", T0 + 1000)
	assert_eq(_log.day_index("2026-10-20"), -1)
	assert_eq(_log.days.size(), 1)
	assert_eq(_log.days_string(D0), "1" + _dashes(30))


func test_clock_back_marks_an_earlier_day_once() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 10)
	_log.resume(D3, T0 + 1000)
	_log.pause(D3, T0 + 1010)
	_log.resume(D1, T0 + 2000)
	_log.pause(D1, T0 + 2010)
	_log.resume(D1, T0 + 3000)
	assert_eq(_log.days.keys().size(), 3)
	assert_eq(_log.last_day, 3)
	assert_eq(_log.days_string(D3), "1101" + _dashes(27))


func test_after_day_30_only_late_days_are_counted() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 10)
	_log.resume("2026-11-26", T0 + 100_000)
	_log.pause("2026-11-26", T0 + 100_010)
	_log.resume("2026-12-05", T0 + 200_000)
	_log.pause("2026-12-05", T0 + 200_010)
	_log.resume("2026-12-05", T0 + 300_000)
	assert_eq(_log.late_days, 2)
	assert_eq(_log.days.size(), 1)
	assert_eq(_log.days_played(), 3)
	assert_eq(_log.days_string("2026-12-05").length(), ActivityLog.TRACKED_DAYS)


func test_first_merge_is_recorded_once_in_play_seconds() -> void:
	_log.start(D0, T0, 0)
	_log.tick(D0, T0 + 60)
	_log.note_merge(D0, T0 + 90)
	assert_eq(_log.first_merge_sec, 90)
	_log.tick(D0, T0 + 120)
	_log.note_merge(D0, T0 + 150)
	assert_eq(_log.first_merge_sec, 90)


func test_runs_levels_and_progress() -> void:
	_log.start(D0, T0, 0)
	_log.note_run(D0, T0 + 60, 0, "country_bloom")
	_log.note_progress(D0, false, false, "country_bloom", 0)
	assert_eq(_log.tutorial_day, -1)
	_log.note_run(D0, T0 + 120, 5, "country_bloom")
	_log.note_run(D0, T0 + 180, 3, "country_bloom")
	_log.note_progress(D0, true, false, "frost_orchard", 2)
	assert_eq(_log.total_runs, 3)
	assert_eq(int(_log.days[0].r), 3)
	assert_eq(int(_log.days[0].lv), 5)
	assert_eq(_log.tutorial_day, 0)
	assert_eq(_log.endless_day, -1)
	assert_eq(_log.best_season, "frost_orchard")
	assert_eq(_log.best_level, 2)
	_log.pause(D0, T0 + 200)
	_log.resume(D2, T0 + 200_000)
	_log.note_progress(D2, true, true, "frost_orchard", 1)
	assert_eq(_log.endless_day, 2)
	assert_eq(_log.tutorial_day, 0, "tutorial day stays the first one")
	assert_eq(_log.best_level, 2, "best level never goes down in the same season")


func test_save_round_trip_through_json() -> void:
	_log.start(D0, T0, 0)
	_log.note_run(D0, T0 + 60, 4, "country_bloom")
	_log.note_progress(D0, true, false, "country_bloom", 3)
	_log.note_merge(D0, T0 + 70)
	_log.pause(D0, T0 + 80)
	_log.resume(D2, T0 + 200_000)
	var parsed: Variant = JSON.parse_string(JSON.stringify(_log.to_save_dict()))
	assert_true(parsed is Dictionary)
	var back := ActivityLog.new()
	back.apply_from_save(parsed)
	assert_eq(back.csv_row("0.1.0", D2), _log.csv_row("0.1.0", D2))
	assert_eq_deep(back.to_save_dict(), _log.to_save_dict())


func test_old_save_without_log_starts_today_with_unknown_past() -> void:
	var first_launch := T0 - 6 * 86400
	var legacy_day := ActivityLog.local_day_key(first_launch)
	var today := ActivityLog.local_day_key(T0)
	_log.apply_from_save({"version": 12})
	assert_eq(_log.first_day, "")
	_log.start(today, T0, first_launch)
	assert_eq(_log.first_day, legacy_day)
	assert_eq(_log.since, 6)
	assert_eq(_log.days_string(today), _dashes(6) + "1" + _dashes(24))
	assert_false(_log.is_known(3))


func test_new_game_with_first_launch_today_has_no_unknown_days() -> void:
	_log.start(ActivityLog.local_day_key(T0), T0, T0)
	assert_eq(_log.since, 0)


func test_broken_save_key_gives_empty_log() -> void:
	_log.apply_from_save({"activity": "nope"})
	assert_eq(_log.first_day, "")
	_log.apply_from_save({"activity": {"first_day": "2026-13-40", "since": 3}})
	assert_eq(_log.first_day, "")
	assert_eq(_log.since, 0)
	_log.apply_from_save({"activity": {
		"first_day": D0, "since": -5,
		"days": ["x", {"d": 99, "s": 1}, {"d": 2, "s": "3", "sec": -10, "r": 1.0}],
		"tot": "bad", "best": [],
	}})
	assert_eq(_log.first_day, D0)
	assert_eq(_log.since, 0)
	assert_eq(_log.days.keys(), [2])
	assert_eq(int(_log.days[2].s), 3)
	assert_eq(int(_log.days[2].sec), 0)
	assert_eq(_log.total_sessions, 0)


func test_csv_row_matches_header() -> void:
	_log.start(D0, T0, 0)
	_log.tick(D0, T0 + 90)
	_log.note_progress(D0, true, false, "country_bloom", 1)
	var row := _log.csv_row("0.1.0", D0)
	var cells := row.split(",")
	assert_eq(cells.size(), ActivityLog.CSV_HEADER.split(",").size())
	assert_eq(cells[0], ActivityLog.CSV_TAG)
	assert_eq(cells[2], D0)
	assert_eq(cells[3], "1" + _dashes(30))
	assert_eq(cells[5], "2", "90 s rounds to 2 minutes")
	assert_eq(row, "mm1,0.1.0,2026-10-26,1%s,1,2,0,country_bloom,1,0,-1,-1,0,0" % _dashes(30))


func test_snapshot_counts() -> void:
	_log.start(D0, T0, 0)
	_log.pause(D0, T0 + 600)
	_log.resume(D2, T0 + 200_000)
	var s := _log.snapshot(D2)
	assert_eq(int(s.today_day), 2)
	assert_eq(int(s.days_played), 2)
	assert_eq(int(s.days_total), 3)
	assert_eq(int(s.minutes), 2, "one tick of 90 s at pause is the only counted play")
	assert_eq(str(s.days), "101" + _dashes(28))
