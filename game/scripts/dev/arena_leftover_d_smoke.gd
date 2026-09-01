extends SceneTree

## ARENA-02 LEFTOVER-D — debug leftover bag freeze 100 T1 once per process.


const SAVE_PATH := "user://player_save.json"
const EXPECTED := {
	"clover": 19,
	"daisy": 22,
	"buttercup": 13,
	"tulip": 28,
	"sunflower": 18,
}


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	print("arena_leftover_d_smoke FAIL: %s" % msg)
	push_error("arena_leftover_d_smoke: %s" % msg)
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


func _bag_n(gs: Node, type_id: String) -> int:
	return int(gs.get("seed_bag").get(type_id, 0))


func _bag_sum(gs: Node) -> int:
	var total := 0
	var bag: Dictionary = gs.get("seed_bag")
	for key in bag:
		total += int(bag[key])
	return total


func _bag_matches_freeze(gs: Node) -> bool:
	var bag: Dictionary = gs.get("seed_bag")
	if bag.size() != EXPECTED.size():
		return false
	for type_id in EXPECTED:
		if int(bag.get(type_id, -1)) != int(EXPECTED[type_id]):
			return false
	return true


func _run() -> void:
	print("arena_leftover_d_smoke start")
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()

	if int(gs.get("SEED_BAG_SOFT_CAP")) != 40:
		_restore_save(backup)
		_fail("SEED_BAG_SOFT_CAP must stay 40")
		return
	if int(gs.get("SAVE_VERSION")) != 12:
		_restore_save(backup)
		_fail("SAVE_VERSION must stay 12")
		return

	gs.set("_debug_leftover_bag_applied", false)
	var applied: bool = bool(gs.call("apply_debug_leftover_test_bag"))
	if not applied:
		_restore_save(backup)
		_fail("first apply should overwrite")
		return
	if not _bag_matches_freeze(gs) or _bag_sum(gs) != 100:
		_restore_save(backup)
		_fail("freeze bag mismatch, sum=%d bag=%s" % [_bag_sum(gs), str(gs.get("seed_bag"))])
		return
	if int(gs.get("seed_unlock_index")) != 4:
		_restore_save(backup)
		_fail("seed_unlock_index should be 4")
		return
	if not bool(gs.get("tutorial_complete")):
		_restore_save(backup)
		_fail("tutorial_complete should be true")
		return

	var bag: Dictionary = gs.get("seed_bag")
	bag["clover"] = 1
	gs.set("seed_bag", bag)
	applied = bool(gs.call("apply_debug_leftover_test_bag"))
	if applied:
		_restore_save(backup)
		_fail("second apply must no-op")
		return
	if _bag_n(gs, "clover") != 1:
		_restore_save(backup)
		_fail("second apply must keep clover=1, got %d" % _bag_n(gs, "clover"))
		return

	bag = gs.get("seed_bag")
	bag["daisy"] = 99
	gs.set("seed_bag", bag)
	applied = bool(gs.call("_try_apply_debug_leftover_test_bag", false))
	if applied:
		_restore_save(backup)
		_fail("dev_enabled false must no-op")
		return
	if _bag_n(gs, "daisy") != 99:
		_restore_save(backup)
		_fail("false apply must leave daisy=99, got %d" % _bag_n(gs, "daisy"))
		return

	gs.set("seed_bag", {"clover": 3})
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _i in 16:
		await process_frame
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("arena boot must not min-10 remainder, clover=%d" % _bag_n(gs, "clover"))
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_leftover_d_smoke OK")
	quit(0)
