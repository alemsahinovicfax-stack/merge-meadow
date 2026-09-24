extends SceneTree

## ARENA-01 FEEL-B — clear-field VFX, no loot.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_feel_b_smoke: %s" % msg)
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
	gs.set("seed_bag", {})
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
	if not arena.has_method("is_clear_of_pairs"):
		_restore_save(backup)
		_fail("is_clear_of_pairs missing")
		return
	if not arena.has_method("_end_session_to_camp"):
		_restore_save(backup)
		_fail("session exit missing")
		return
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9201, "type_id": "clover", "tier": 1},
		{"chip_id": 9202, "type_id": "daisy", "tier": 1},
		{"chip_id": 9203, "type_id": "tulip", "tier": 1},
	])
	for _j in 4:
		await process_frame
	if not bool(arena.call("is_clear_of_pairs")):
		_restore_save(backup)
		_fail("3 different T1 should be clear of pairs")
		return
	var wallet := int(gs.get("wallet_coins"))
	arena.call("_maybe_play_clear_vfx")
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("clear VFX must not grant coins")
		return
	if not bool(arena.call("did_play_clear_vfx_this_pour")):
		_restore_save(backup)
		_fail("latch should be set after clear VFX")
		return
	arena.call("_maybe_play_clear_vfx")
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("second clear VFX must not grant coins")
		return
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9204, "type_id": "clover", "tier": 1},
		{"chip_id": 9205, "type_id": "clover", "tier": 1},
	])
	for _k in 4:
		await process_frame
	if bool(arena.call("is_clear_of_pairs")):
		_restore_save(backup)
		_fail("2 matching T1 should not be clear of pairs")
		return
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("spawn matching pair must not change wallet")
		return
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_feel_b_smoke OK")
	quit(0)
