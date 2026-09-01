extends SceneTree

## ARENA-03 VAC-F — leftover flies to bag as ghost, not ArenaSeedChip.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_vacuum_fly_smoke: %s" % msg)
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


func _field_chips(arena: Node) -> Array:
	var out: Array = []
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return out
	for child in playfield.get_children():
		if "pulse_highlight" in child and "type_id" in child:
			out.append(child)
	return out


func _count_tier(chips: Array, type_id: String, tier: int) -> int:
	var n := 0
	for chip in chips:
		if str(chip.get("type_id")) == type_id and int(chip.get("tier")) == tier:
			n += 1
	return n


func _ghost_count(arena: Node) -> int:
	var n := 0
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return 0
	for child in playfield.get_children():
		var script: Variant = child.get_script()
		if script != null and str(script.resource_path).ends_with("arena_vacuum_fly.gd"):
			n += 1
	return n


func _spawn_t1(arena: Node, type_id: String, count: int, id_base: int) -> void:
	var spawn: Array = []
	for i in count:
		spawn.append({"chip_id": id_base + i, "type_id": type_id, "tier": 1})
	arena.call("_spawn_poured_chips", spawn)


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
	if arena == null or not arena.has_method("_vacuum_fly_chip"):
		_restore_save(backup)
		_fail("arena missing fly helper")
		return

	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "clover", 3, 9900)
	for _a in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _b in 2:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 0:
		_restore_save(backup)
		_fail("VAC-F: field chips must be 0, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("VAC-F: bag clover 3 immediately, got %d" % _bag_n(gs, "clover"))
		return
	if not bool(gs.call("is_arena_pour_locked", "clover")):
		_restore_save(backup)
		_fail("VAC-F: clover should lock")
		return
	var ghosts := _ghost_count(arena)
	if ghosts < 1:
		_restore_save(backup)
		_fail("VAC-F: expected VacuumFly ghosts in flight, got %d" % ghosts)
		return

	gs.call("clear_arena_pour_locks")
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_vacuum_fly_smoke OK")
	quit(0)
