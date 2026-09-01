extends SceneTree

## SEED-C — hashed palette frost ≠ clover; pour queue catalog ∩ bag.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("seed_draw_pour_smoke: %s" % msg)
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


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()

	var frost_pal: Dictionary = SeedVisualConfig.palette("frost_snowdrop")
	var clover_pal: Dictionary = SeedVisualConfig.palette("clover")
	if frost_pal.petal == clover_pal.petal and frost_pal.center == clover_pal.center:
		_restore_save(backup)
		_fail("frost_snowdrop palette matches clover")
		return

	gs.set("seed_bag", {"frost_snowdrop": 4, "clover": 4})
	var pulled: Array = gs.call("pull_seeds_to_arena", 40, {})
	if (
		pulled.size() != 8
		or _count_pulled(pulled, "clover") != 4
		or _count_pulled(pulled, "frost_snowdrop") != 4
		or _bag_n(gs, "clover") != 0
		or _bag_n(gs, "frost_snowdrop") != 0
	):
		_restore_save(backup)
		_fail("4 frost + 4 clover should pour both, pulled=%d clover=%d frost=%d" % [
			pulled.size(),
			_count_pulled(pulled, "clover"),
			_count_pulled(pulled, "frost_snowdrop"),
		])
		return
	for i in 4:
		if str(pulled[i].get("type_id", "")) != "clover":
			_restore_save(backup)
			_fail("catalog order: first 4 must be clover, index %d was %s" % [i, str(pulled[i])])
			return
	for i in range(4, 8):
		if str(pulled[i].get("type_id", "")) != "frost_snowdrop":
			_restore_save(backup)
			_fail("catalog order: last 4 must be frost_snowdrop, index %d was %s" % [i, str(pulled[i])])
			return

	gs.set("seed_bag", {"frost_snowdrop": 3, "clover": 4})
	pulled = gs.call("pull_seeds_to_arena", 40, {})
	if (
		pulled.size() != 4
		or _count_pulled(pulled, "clover") != 4
		or _count_pulled(pulled, "frost_snowdrop") != 0
		or _bag_n(gs, "clover") != 0
		or _bag_n(gs, "frost_snowdrop") != 3
	):
		_restore_save(backup)
		_fail("frost 3 must stay, clover 4 pour; pulled=%d frost_bag=%d" % [
			pulled.size(),
			_bag_n(gs, "frost_snowdrop"),
		])
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("seed_draw_pour_smoke OK")
	quit(0)
