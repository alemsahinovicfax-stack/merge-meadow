extends SceneTree

## ARENA-01 FLOW-B — auto-refill at 10; pour prefers field orphans.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_flow_b_smoke: %s" % msg)
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


func _field_chips(arena: Node) -> Array:
	var out: Array = []
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return out
	for child in playfield.get_children():
		if "pulse_highlight" in child and "type_id" in child:
			out.append(child)
	return out


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	gs.set("seed_bag", {"clover": 2, "daisy": 2})
	var pulled: Array = gs.call("pull_seeds_to_arena", 1, {"clover": 1})
	if pulled.is_empty() or str(pulled[0].get("type_id", "")) != "clover":
		_restore_save(backup)
		_fail("orphan prefer should pour clover first, got %s" % str(pulled))
		return

	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _i in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null or not arena.has_method("_try_auto_refill"):
		_restore_save(backup)
		_fail("arena missing auto-refill API")
		return
	if not arena.has_method("_on_done_pressed"):
		_restore_save(backup)
		_fail("Done path missing")
		return

	var spawn: Array = []
	for i in 11:
		spawn.append({"chip_id": 9300 + i, "type_id": "clover", "tier": 1})
	gs.set("seed_bag", {"clover": 20})
	arena.call("_spawn_poured_chips", spawn)
	for _j in 4:
		await process_frame
	var before_count := _field_chips(arena).size()
	if before_count < 11:
		_restore_save(backup)
		_fail("expected 11 spawned chips, got %d" % before_count)
		return
	var bag_before := int(gs.get("seed_bag").get("clover", 0))
	var chips := _field_chips(arena)
	chips[0].call("set_center", chips[1].call("get_center") + Vector2(8.0, 0.0))
	arena.call("_on_chip_released", chips[0])
	for _k in 8:
		await process_frame
	var after_count := _field_chips(arena).size()
	var bag_after := int(gs.get("seed_bag").get("clover", 0))
	if after_count <= 10:
		_restore_save(backup)
		_fail("auto-refill should grow field after merge-to-10, got %d" % after_count)
		return
	if bag_after >= bag_before:
		_restore_save(backup)
		_fail("auto-refill should shrink bag")
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_flow_b_smoke OK")
	quit(0)
