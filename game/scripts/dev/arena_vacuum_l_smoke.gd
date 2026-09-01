extends SceneTree

## ARENA-03 VAC-L — leftover ≥4 pours again; lock only while bag < 4.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_vacuum_l_smoke: %s" % msg)
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

	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"sunflower": 3})
	gs.call("lock_arena_pour_type", "sunflower")
	var pulled: Array = gs.call("pull_seeds_to_arena", 40, {})
	if not pulled.is_empty() or _bag_n(gs, "sunflower") != 3:
		_restore_save(backup)
		_fail("S4/S31: locked sunflower 3 must not pour")
		return
	if not bool(gs.call("is_arena_pour_locked", "sunflower")):
		_restore_save(backup)
		_fail("sunflower 3 should stay locked")
		return

	gs.set("seed_bag", {"sunflower": 6})
	if bool(gs.call("is_arena_pour_locked", "sunflower")):
		_restore_save(backup)
		_fail("sunflower 6 must not count as locked")
		return
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if pulled.size() != 6 or _bag_n(gs, "sunflower") != 0:
		_restore_save(backup)
		_fail("S31: bag 6 should pour 6, pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "sunflower")])
		return

	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"daisy": 20})
	gs.call("lock_arena_pour_type", "daisy")
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if pulled.size() != 20:
		_restore_save(backup)
		_fail("VAC-L: daisy 20 must pour even if lock dict set, got %d" % pulled.size())
		return

	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _i in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null or not arena.has_method("_resolve_t3_starved_types"):
		_restore_save(backup)
		_fail("arena missing vacuum API")
		return

	# Remainder 3 in bag + 3 on field → vacuum then S32 pour 6.
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"sunflower": 3})
	_spawn_t1(arena, "sunflower", 3, 9910)
	for _a in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _b in 8:
		await process_frame
	if bool(gs.call("is_arena_pour_locked", "sunflower")):
		_restore_save(backup)
		_fail("3+3 remainder must unlock")
		return
	if _bag_n(gs, "sunflower") != 0:
		_restore_save(backup)
		_fail("S32: leftover 6 should pour, bag=%d" % _bag_n(gs, "sunflower"))
		return
	if _count_tier(_field_chips(arena), "sunflower", 1) != 6:
		_restore_save(backup)
		_fail("S32: expected 6 sunflower on field, got %d" % _count_tier(_field_chips(arena), "sunflower", 1))
		return

	# Two waves: first leftover locks at 3; second vacuum makes 6 and pours.
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "sunflower", 3, 9920)
	for _c in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _d in 4:
		await process_frame
	if _bag_n(gs, "sunflower") != 3:
		_restore_save(backup)
		_fail("wave1: bag 3, got %d" % _bag_n(gs, "sunflower"))
		return
	if not bool(gs.call("is_arena_pour_locked", "sunflower")):
		_restore_save(backup)
		_fail("wave1: sunflower 3 should lock")
		return
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("wave1: field should be empty")
		return
	_spawn_t1(arena, "sunflower", 3, 9930)
	for _e in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _f in 8:
		await process_frame
	if _count_tier(_field_chips(arena), "sunflower", 1) != 6:
		_restore_save(backup)
		_fail("wave2: S32 should pour 6, field=%d" % _count_tier(_field_chips(arena), "sunflower", 1))
		return
	if _bag_n(gs, "sunflower") != 0:
		_restore_save(backup)
		_fail("wave2: bag should be 0 after S32, got %d" % _bag_n(gs, "sunflower"))
		return

	# Empty field + pourable bag: manual refill still 0 (S3).
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"clover": 8})
	arena.call("_try_auto_refill")
	for _g in 8:
		await process_frame
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("S3: empty field must not auto-pour, got %d" % _field_chips(arena).size())
		return
	if _bag_n(gs, "clover") != 8:
		_restore_save(backup)
		_fail("S3: clover 8 should stay in bag, got %d" % _bag_n(gs, "clover"))
		return

	gs.call("clear_arena_pour_locks")
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_vacuum_l_smoke OK")
	quit(0)
