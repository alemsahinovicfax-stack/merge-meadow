## MEAD-6 — atomarni save i odbijanje pokvarenog JSON-a.
extends "res://test/unit/game_state_test_base.gd"

const LIVE := "user://player_save.json"
const BAK := "user://player_save.json.bak"
const TMP := "user://player_save.json.tmp"


func after_each() -> void:
	super.after_each()
	for path in [BAK, TMP]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	_gs._save_unreadable = false
	_gs.load_player_save()


func test_save_replaces_live_file_and_keeps_backup() -> void:
	_gs._save_unreadable = false
	_gs.wallet_coins = 4242
	_gs.save_player_save()
	var text := FileAccess.get_file_as_string(LIVE)
	var parsed: Variant = JSON.parse_string(text)
	assert_true(parsed is Dictionary)
	assert_eq(int(parsed["wallet_coins"]), 4242)
	assert_true(FileAccess.file_exists(BAK))
	assert_false(FileAccess.file_exists(TMP))


func test_unreadable_save_is_not_overwritten() -> void:
	if FileAccess.file_exists(BAK):
		DirAccess.remove_absolute(BAK)
	var f := FileAccess.open(LIVE, FileAccess.WRITE)
	f.store_string("{")
	f.close()
	assert_false(_gs.load_player_save())
	_gs.wallet_coins = 7777
	_gs.save_player_save()
	assert_eq(FileAccess.get_file_as_string(LIVE), "{")
	# Očekivani šum: JSON parse + odbijanje upisa. Bez ovoga GUT tretira push_error kao pad.
	assert_engine_error_count(1, "corrupt json parse")
	assert_push_error_count(2, "unreadable load and blocked save")
