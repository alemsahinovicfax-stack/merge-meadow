## Dev prekidač „Test seeds" (user://dev_flags.cfg): isključen test-bag ne smije dirati tutorijal ni
## vreću na pokretanju / Areni (playtest kao novi igrač); bez fajla je uključen kao prije.
extends "res://test/unit/game_state_test_base.gd"

var _had_file := false
var _old := ""


func before_each() -> void:
	super.before_each()
	_had_file = FileAccess.file_exists(GameStateDebug.DEV_FLAGS_PATH)
	_old = FileAccess.get_file_as_string(GameStateDebug.DEV_FLAGS_PATH) if _had_file else ""


func after_each() -> void:
	if _had_file:
		var f := FileAccess.open(GameStateDebug.DEV_FLAGS_PATH, FileAccess.WRITE)
		f.store_string(_old)
		f.close()
	elif FileAccess.file_exists(GameStateDebug.DEV_FLAGS_PATH):
		DirAccess.remove_absolute(GameStateDebug.DEV_FLAGS_PATH)
	super.after_each()
	_gs.load_player_save()


func test_off_keeps_new_player_state() -> void:
	GameStateDebug.set_test_bag_enabled(false)
	assert_false(GameStateDebug.test_bag_enabled())
	_gs.debug.set("_leftover_bag_applied", false)
	_gs.tutorial_complete = false
	_gs.seed_bag = {}
	assert_false(_gs.apply_debug_leftover_test_bag())
	assert_false(_gs.tutorial_complete, "tutorial must stay open")
	assert_eq(_gs.seed_bag.size(), 0, "no test seeds")


func test_on_by_default_without_file() -> void:
	if FileAccess.file_exists(GameStateDebug.DEV_FLAGS_PATH):
		DirAccess.remove_absolute(GameStateDebug.DEV_FLAGS_PATH)
	assert_true(GameStateDebug.test_bag_enabled())
	GameStateDebug.set_test_bag_enabled(false)
	GameStateDebug.set_test_bag_enabled(true)
	assert_true(GameStateDebug.test_bag_enabled())
