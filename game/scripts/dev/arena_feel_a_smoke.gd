extends SceneTree

## ARENA-01 FEEL-A — Pip on playfield edge; session meadow tint.


const SAVE_PATH := "user://player_save.json"
const BG_BASE := Color(0.16, 0.24, 0.18, 1.0)


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_feel_a_smoke: %s" % msg)
	quit(1)


func _backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _restore_save(backup: String) -> void:
	if backup.is_empty():
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(SAVE_PATH)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(backup)


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _i in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null:
		_restore_save(backup)
		_fail("arena scene missing")
		return
	var pip := arena.get_node_or_null("RootVBox/Playfield/ArenaPip")
	if pip == null:
		_restore_save(backup)
		_fail("ArenaPip missing")
		return
	if int(pip.get("mouse_filter")) != Control.MOUSE_FILTER_IGNORE:
		_restore_save(backup)
		_fail("ArenaPip must IGNORE mouse")
		return
	var edible: Array = arena.call("_get_edible_chips_for_pest")
	if edible.has(pip):
		_restore_save(backup)
		_fail("Pip must not be a pest eat target")
		return
	var bg := arena.get_node_or_null("Bg") as ColorRect
	if bg == null:
		_restore_save(backup)
		_fail("Bg missing")
		return
	if not bg.color.is_equal_approx(BG_BASE):
		_restore_save(backup)
		_fail("Bg should start at base meadow color")
		return
	if not arena.has_method("get_session_t3_count"):
		_restore_save(backup)
		_fail("get_session_t3_count missing")
		return
	if int(arena.call("get_session_t3_count")) != 0:
		_restore_save(backup)
		_fail("session T3 count should start at 0")
		return
	arena.call("_add_session_t3")
	arena.call("_add_session_t3")
	if int(arena.call("get_session_t3_count")) != 2:
		_restore_save(backup)
		_fail("session T3 count expected 2")
		return
	if bg.color.is_equal_approx(BG_BASE):
		_restore_save(backup)
		_fail("Bg tint should move after T3s")
		return
	arena.call("_reset_session_feel")
	if int(arena.call("get_session_t3_count")) != 0:
		_restore_save(backup)
		_fail("reset should clear T3 count")
		return
	if not bg.color.is_equal_approx(BG_BASE):
		_restore_save(backup)
		_fail("reset should restore base Bg color")
		return
	arena.call("register_arena_combo_merge")
	arena.call("register_arena_combo_merge")
	if int(arena.call("get_combo_count")) != 2:
		_restore_save(backup)
		_fail("two merges expected combo 2")
		return
	if not is_instance_valid(pip):
		_restore_save(backup)
		_fail("Pip should remain after combo react")
		return
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_feel_a_smoke OK")
	quit(0)
