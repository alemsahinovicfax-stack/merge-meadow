extends SceneTree

## ARENA-01 FLOW-A — no bloom panel; stranded T2 → 2× T1; pair-chance keeps T2.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_flow_a_smoke: %s" % msg)
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


func _count_tier(chips: Array, type_id: String, tier: int) -> int:
	var n := 0
	for chip in chips:
		if str(chip.get("type_id")) == type_id and int(chip.get("tier")) == tier:
			n += 1
	return n


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
	if arena == null or not arena.has_method("_resolve_stranded_t2"):
		_restore_save(backup)
		_fail("arena controller missing leftover API")
		return
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield != null and playfield.get_node_or_null("BloomActionPanel") != null:
		_restore_save(backup)
		_fail("BloomActionPanel should not exist")
		return

	gs.set("seed_bag", {})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9201, "type_id": "clover", "tier": 2},
	])
	for _a in 4:
		await process_frame
	arena.call("_resolve_stranded_t2")
	for _b in 2:
		await process_frame
	if _count_tier(_field_chips(arena), "clover", 2) != 0:
		_restore_save(backup)
		_fail("stranded T2 should recycle")
		return
	if int(gs.get("seed_bag").get("clover", 0)) != 2:
		_restore_save(backup)
		_fail("recycle should add 2 T1, bag=%s" % str(gs.get("seed_bag")))
		return

	arena.call("_clear_field_chips")
	gs.set("seed_bag", {"clover": 1})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9202, "type_id": "clover", "tier": 2},
	])
	for _c in 4:
		await process_frame
	arena.call("_resolve_stranded_t2")
	if _count_tier(_field_chips(arena), "clover", 2) != 1:
		_restore_save(backup)
		_fail("T2 should stay when bag can pour that type")
		return

	arena.call("_clear_field_chips")
	gs.set("seed_bag", {})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9203, "type_id": "clover", "tier": 2},
		{"chip_id": 9204, "type_id": "clover", "tier": 2},
	])
	for _d in 4:
		await process_frame
	arena.call("_resolve_stranded_t2")
	if _count_tier(_field_chips(arena), "clover", 2) != 2:
		_restore_save(backup)
		_fail("two same-type T2 should keep each other")
		return

	arena.call("_clear_field_chips")
	gs.set("seed_bag", {})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9205, "type_id": "clover", "tier": 2},
		{"chip_id": 9206, "type_id": "clover", "tier": 1},
		{"chip_id": 9207, "type_id": "clover", "tier": 1},
	])
	for _e in 4:
		await process_frame
	arena.call("_resolve_stranded_t2")
	if _count_tier(_field_chips(arena), "clover", 2) != 1:
		_restore_save(backup)
		_fail("T2 should stay when field has 2 T1 of same type")
		return
	if _count_tier(_field_chips(arena), "clover", 1) != 2:
		_restore_save(backup)
		_fail("odd T1 must not auto-recycle")
		return

	arena.call("_clear_field_chips")
	gs.set("seed_bag", {})
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9208, "type_id": "clover", "tier": 1},
	])
	for _f in 4:
		await process_frame
	arena.call("_resolve_stranded_t2")
	if _count_tier(_field_chips(arena), "clover", 1) != 1:
		_restore_save(backup)
		_fail("single T1 leftover stays until Done")
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_flow_a_smoke OK")
	quit(0)
