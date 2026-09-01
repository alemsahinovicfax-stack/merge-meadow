extends SceneTree

## ARENA-03 VAC-A — vacuum despite bag over cap; t1_eq ignores unpourable bag remainder.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_vacuum_stuck_smoke: %s" % msg)
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

	# H1: bag over soft cap must not block vacuum of another type.
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"daisy": 50})
	_spawn_t1(arena, "clover", 3, 9800)
	for _a in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _b in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 0:
		_restore_save(backup)
		_fail("H1: 3 clover over-cap bag should vacuum, field=%d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("H1: vacuum over cap → bag clover 3, got %d" % _bag_n(gs, "clover"))
		return
	if _bag_n(gs, "daisy") != 50:
		_restore_save(backup)
		_fail("H1: daisy bag must stay 50, got %d" % _bag_n(gs, "daisy"))
		return

	# H2: 3 field + 3 bag vacuum then S32 pours the new T3 set.
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"clover": 3})
	_spawn_t1(arena, "clover", 3, 9810)
	for _c in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _d in 8:
		await process_frame
	if bool(gs.call("is_arena_pour_locked", "clover")):
		_restore_save(backup)
		_fail("H2: bag 6 must not stay locked")
		return
	if _bag_n(gs, "clover") != 0:
		_restore_save(backup)
		_fail("H2: S32 should pour 6, bag=%d" % _bag_n(gs, "clover"))
		return
	if _count_tier(_field_chips(arena), "clover", 1) != 6:
		_restore_save(backup)
		_fail("H2: S32 should spawn 6 clover, field=%d" % _count_tier(_field_chips(arena), "clover", 1))
		return

	# H5 / S11: 5 T1 with room must stay.
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "clover", 5, 9820)
	for _e in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _f in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 5:
		_restore_save(backup)
		_fail("S11: 5 clover must stay, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 0:
		_restore_save(backup)
		_fail("S11: 5 clover must not vacuum, bag=%d" % _bag_n(gs, "clover"))
		return

	# 3 field + 8 bag is a real T3 path — do not vacuum.
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"clover": 8})
	_spawn_t1(arena, "clover", 3, 9830)
	for _g in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _h in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 3:
		_restore_save(backup)
		_fail("pourable bag 8 + field 3 must keep field, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 8:
		_restore_save(backup)
		_fail("pourable bag 8 must stay 8, got %d" % _bag_n(gs, "clover"))
		return

	# H3: leftover on field, pour other type (no merge) must still vacuum.
	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"daisy": 8})
	_spawn_t1(arena, "clover", 3, 9840)
	for _j in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 3:
		_restore_save(backup)
		_fail("H3 setup: expected 3 clover, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	arena.call("_pour_available_seeds")
	for _k in 8:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 0:
		_restore_save(backup)
		_fail("H3: pour should vacuum leftover clover, field=%d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("H3: clover should return to bag, got %d" % _bag_n(gs, "clover"))
		return

	gs.call("clear_arena_pour_locks")
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_vacuum_stuck_smoke OK")
	quit(0)
