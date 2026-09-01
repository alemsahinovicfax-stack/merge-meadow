extends SceneTree

## ARENA-03 SORT-B — vacuum when t1_eq < 4; lock pour until Done.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_sort_b_smoke: %s" % msg)
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


func _count_pulled(pulled: Array, type_id: String) -> int:
	var n := 0
	for entry in pulled:
		if str(entry.get("type_id", "")) == type_id:
			n += 1
	return n


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

	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "clover", 3, 9700)
	for _a in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _b in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 0:
		_restore_save(backup)
		_fail("3 clover T1 should vacuum, field=%d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("3 clover vacuum → bag 3, got %d" % _bag_n(gs, "clover"))
		return
	if not bool(gs.call("is_arena_pour_locked", "clover")):
		_restore_save(backup)
		_fail("vacuum should lock clover")
		return
	var pulled: Array = gs.call("pull_seeds_to_arena", 40, {})
	if not pulled.is_empty() or _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("locked clover must not pour, pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "clover")])
		return

	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "clover", 5, 9710)
	for _c in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _d in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 5:
		_restore_save(backup)
		_fail("5 clover T1 must stay, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 0:
		_restore_save(backup)
		_fail("5 clover must not vacuum to bag, bag=%d" % _bag_n(gs, "clover"))
		return
	if bool(gs.call("is_arena_pour_locked", "clover")):
		_restore_save(backup)
		_fail("5 clover must not lock")
		return

	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	_spawn_t1(arena, "clover", 4, 9720)
	for _e in 4:
		await process_frame
	var eat_chips := _field_chips(arena)
	if eat_chips.size() != 4:
		_restore_save(backup)
		_fail("expected 4 spawned clover, got %d" % eat_chips.size())
		return
	arena.call("_pest_eat_chip", eat_chips[0])
	for _f in 8:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 1) != 0:
		_restore_save(backup)
		_fail("eat 1 of 4 should vacuum rest, field=%d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 3:
		_restore_save(backup)
		_fail("eat 1 of 4 → bag 3, got %d" % _bag_n(gs, "clover"))
		return
	if not bool(gs.call("is_arena_pour_locked", "clover")):
		_restore_save(backup)
		_fail("eat vacuum should lock clover")
		return

	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {"daisy": 3, "buttercup": 8})
	gs.call("lock_arena_pour_type", "daisy")
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if (
		_count_pulled(pulled, "buttercup") != 8
		or _count_pulled(pulled, "daisy") != 0
		or _bag_n(gs, "daisy") != 3
		or _bag_n(gs, "buttercup") != 0
	):
		_restore_save(backup)
		_fail("locked daisy 3 + buttercup 8 should pour only buttercup")
		return

	arena.call("_clear_field_chips")
	gs.call("clear_arena_pour_locks")
	gs.set("seed_bag", {})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9730, "type_id": "clover", "tier": 2},
		{"chip_id": 9731, "type_id": "clover", "tier": 1},
		{"chip_id": 9732, "type_id": "clover", "tier": 1},
	])
	for _g in 4:
		await process_frame
	arena.call("_resolve_t3_starved_types")
	for _h in 4:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 2) != 1:
		_restore_save(backup)
		_fail("t1_eq 4 must keep T2, got %d" % _count_tier(_field_chips(arena), "clover", 2))
		return
	if _count_tier(_field_chips(arena), "clover", 1) != 2:
		_restore_save(backup)
		_fail("t1_eq 4 must keep 2 T1, got %d" % _count_tier(_field_chips(arena), "clover", 1))
		return
	if _bag_n(gs, "clover") != 0:
		_restore_save(backup)
		_fail("t1_eq 4 must not vacuum, bag=%d" % _bag_n(gs, "clover"))
		return

	gs.call("clear_arena_pour_locks")
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_sort_b_smoke OK")
	quit(0)
