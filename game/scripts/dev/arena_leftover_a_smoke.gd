extends SceneTree

## ARENA-03 SORT-A — pour all T1 by CHAIN if >=4; skip locked; cap 40; refill 12.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_leftover_a_smoke: %s" % msg)
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


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()

	gs.set("seed_bag", {"clover": 6})
	var pulled: Array = gs.call("pull_seeds_to_arena", 40, {})
	if pulled.size() != 6 or _bag_n(gs, "clover") != 0:
		_restore_save(backup)
		_fail("6 clover → 6 pulled 0 bag, got pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "clover")])
		return

	gs.set("seed_bag", {"daisy": 3})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if not pulled.is_empty() or _bag_n(gs, "daisy") != 3:
		_restore_save(backup)
		_fail("3 daisy should stay in bag, pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "daisy")])
		return

	gs.set("seed_bag", {"tulip": 8})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if pulled.size() != 8 or _bag_n(gs, "tulip") != 0:
		_restore_save(backup)
		_fail("8 tulip → 8 pulled, got pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "tulip")])
		return

	gs.set("seed_bag", {"clover": 6, "daisy": 3})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if (
		pulled.size() != 6
		or _count_pulled(pulled, "clover") != 6
		or _bag_n(gs, "clover") != 0
		or _bag_n(gs, "daisy") != 3
	):
		_restore_save(backup)
		_fail("mixed 6 clover + 3 daisy should pour 6 clover, daisy stay 3")
		return

	gs.set("seed_bag", {"pumpkin": 6})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if pulled.size() != 6 or _bag_n(gs, "pumpkin") != 0:
		_restore_save(backup)
		_fail("mythic pumpkin 6 → 6 pulled, got pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "pumpkin")])
		return

	gs.set("seed_bag", {"clover": 3, "daisy": 4})
	pulled = gs.call("pull_seeds_to_arena", 40, {"clover": 1})
	if (
		pulled.size() != 4
		or _count_pulled(pulled, "daisy") != 4
		or _bag_n(gs, "clover") != 3
		or _bag_n(gs, "daisy") != 0
	):
		_restore_save(backup)
		_fail("S4: must not pour 3 clover, got pulled=%s clover_bag=%d" % [
			str(pulled),
			_bag_n(gs, "clover"),
		])
		return

	gs.set("seed_bag", {"clover": 8})
	pulled = gs.call("pull_seeds_to_arena", 3, {})
	if pulled.size() != 3 or _bag_n(gs, "clover") != 5:
		_restore_save(backup)
		_fail("pull(3) must pour 3, pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "clover")])
		return

	gs.set("seed_bag", {"daisy": 31, "buttercup": 30})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if (
		pulled.size() != 40
		or _count_pulled(pulled, "daisy") != 31
		or _count_pulled(pulled, "buttercup") != 9
		or _bag_n(gs, "daisy") != 0
		or _bag_n(gs, "buttercup") != 21
	):
		_restore_save(backup)
		_fail("31 daisy + 30 buttercup → 31+9, bag daisy 0 buttercup 21")
		return
	for i in 31:
		if str(pulled[i].get("type_id", "")) != "daisy":
			_restore_save(backup)
			_fail("CHAIN order: first 31 must be daisy, index %d was %s" % [i, str(pulled[i])])
			return
	for i in range(31, 40):
		if str(pulled[i].get("type_id", "")) != "buttercup":
			_restore_save(backup)
			_fail("CHAIN order: last 9 must be buttercup, index %d was %s" % [i, str(pulled[i])])
			return

	gs.set("seed_bag", {"clover": 3, "daisy": 8})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if (
		pulled.size() != 8
		or _count_pulled(pulled, "daisy") != 8
		or _bag_n(gs, "clover") != 3
		or _bag_n(gs, "daisy") != 0
	):
		_restore_save(backup)
		_fail("clover 3 + daisy 8 → 8 daisy, clover stay 3")
		return

	gs.set("seed_bag", {"daisy": 3})
	gs.set("_arena_pour_locked_types", {"daisy": true})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if not pulled.is_empty() or _bag_n(gs, "daisy") != 3:
		_restore_save(backup)
		gs.set("_arena_pour_locked_types", {})
		_fail("locked daisy 3 must not pour, pulled=%d bag=%d" % [pulled.size(), _bag_n(gs, "daisy")])
		return
	gs.set("_arena_pour_locked_types", {})

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

	gs.set("seed_bag", {"clover": 8})
	arena.call("_try_auto_refill")
	for _j in 8:
		await process_frame
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("empty field must not auto-pour, got %d chips" % _field_chips(arena).size())
		return

	var spawn: Array = []
	for i in 8:
		spawn.append({"chip_id": 9400 + i, "type_id": "clover", "tier": 1})
	gs.set("seed_bag", {"daisy": 3})
	arena.call("_spawn_poured_chips", spawn)
	for _k in 4:
		await process_frame
	var remainder_before := _field_chips(arena).size()
	if remainder_before != 8:
		_restore_save(backup)
		_fail("expected 8 spawned chips, got %d" % remainder_before)
		return
	arena.call("_try_auto_refill")
	for _m in 16:
		await process_frame
	if _field_chips(arena).size() != 8:
		_restore_save(backup)
		_fail("remainder bag must not spawn chips, got %d" % _field_chips(arena).size())
		return
	if _bag_n(gs, "daisy") != 3:
		_restore_save(backup)
		_fail("remainder daisy should stay 3, got %d" % _bag_n(gs, "daisy"))
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_leftover_a_smoke OK")
	quit(0)
