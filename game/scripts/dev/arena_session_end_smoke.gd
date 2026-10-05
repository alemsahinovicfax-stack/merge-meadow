extends SceneTree

## Arena bez HUD-a i Done dugmeta (2026-09-24): tap vrece otvara sesiju i cisti pour
## lockove, sesija se sama zatvara kad polje ostane prazno (commit, combo 0, swipe
## slobodan), a Merge Hint booster svoju poruku dobija u oblacicu iznad vrece.

const SAVE_PATH := "user://player_save.json"

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	_failed = true
	push_error("arena_session_end_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _field_chips(arena: Node) -> Array:
	var out: Array = []
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return out
	for child in playfield.get_children():
		if "pulse_highlight" in child and "type_id" in child and not child.is_queued_for_deletion():
			out.append(child)
	return out


func _backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	return FileAccess.get_file_as_string(SAVE_PATH)


func _finish(backup: String, gs: Node) -> void:
	if not backup.is_empty():
		var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if file:
			file.store_string(backup)
			file.close()
		if gs:
			gs.call("load_player_save")
	if _failed:
		quit(1)
		return
	print("arena_session_end_smoke OK")
	quit(0)


func _run() -> void:
	var gs := _gs()
	var backup := _backup_save()
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK or gs == null:
		_fail("arena load failed %d" % err)
		_finish(backup, gs)
		return
	await _frames(16)
	var arena := current_scene as Control
	if arena == null:
		_fail("arena scene missing")
		_finish(backup, gs)
		return

	# Sesija je zatvorena dok je polje prazno.
	if bool(arena.call("is_session_open")):
		_fail("session should start closed")
		_finish(backup, gs)
		return

	gs.call("lock_arena_pour_type", "daisy")
	gs.set("seed_bag", {"clover": 8})
	arena.call("_on_bag_clicked")
	await _frames(6)
	if _field_chips(arena).size() != 8:
		_fail("tap should pour 8 clover, got %d" % _field_chips(arena).size())
		_finish(backup, gs)
		return
	if not bool(arena.call("is_session_open")):
		_fail("pour should open the session")
		_finish(backup, gs)
		return
	if bool(gs.call("is_arena_pour_locked", "daisy")):
		_fail("a new session should clear pour locks")
		_finish(backup, gs)
		return

	arena.call("register_arena_combo_merge")
	arena.call("register_arena_combo_merge")
	if int(arena.call("get_combo_count")) != 2:
		_fail("combo should count during the session")
		_finish(backup, gs)
		return

	# Muncher pojede sve — polje ostaje prazno i sesija se gasi sama.
	var guard := 0
	while guard < 40:
		var chips := _field_chips(arena)
		if chips.is_empty():
			break
		arena.call("_pest_eat_chip", chips[0])
		guard += 1
		await _frames(2)
	# Zadnje sjemenke odlete natrag u vrecu (~0,4 s) — sesija pada kad slete.
	await create_timer(1.2).timeout
	if not _field_chips(arena).is_empty():
		_fail("muncher should clear the field")
		_finish(backup, gs)
		return
	if bool(arena.call("is_session_open")):
		_fail("empty field must close the session")
		_finish(backup, gs)
		return
	if int(arena.call("get_combo_count")) != 0:
		_fail("session end should clear the combo, got %d" % int(arena.call("get_combo_count")))
		_finish(backup, gs)
		return
	var chip_data: Dictionary = arena.get("_chip_data")
	if not chip_data.is_empty():
		_fail("session end should commit the chip data, %d left" % chip_data.size())
		_finish(backup, gs)
		return

	# Novi tap otvara novu sesiju.
	gs.set("seed_bag", {"clover": 4})
	arena.call("_on_bag_clicked")
	await _frames(6)
	if not bool(arena.call("is_session_open")):
		_fail("a second tap should open a new session")
		_finish(backup, gs)
		return
	arena.call("_clear_field_chips")
	await _frames(2)

	# Merge Hint (Shop v2, jednokratna kupovina): dok igrač drži sjemenku, najbliža ista
	# sjemenka dobije MergeHintMark; bez kupovine nema oznake; pustanjem oznaka nestaje.
	gs.set("seed_bag", {"clover": 4})
	arena.call("_on_bag_clicked")
	await _frames(8)
	var chips: Array = arena.get("_chips")
	if chips.size() < 3:
		_fail("need at least 3 clover chips for the hint check, got %d" % chips.size())
		_finish(backup, gs)
		return
	var held: Control = chips[0]
	gs.set("merge_hint_owned", false)
	held.set("_dragging", true)
	await _frames(3)
	if arena.call("get_merge_hint_target") != null:
		_fail("no Merge Hint mark without the purchase")
		_finish(backup, gs)
		return
	gs.set("merge_hint_owned", true)
	await _frames(3)
	var target: Node = arena.call("get_merge_hint_target")
	var nearest: Node = null
	var best := INF
	for c in chips:
		if c == held:
			continue
		var d: float = (held.call("get_center") as Vector2).distance_to(c.call("get_center"))
		if d < best:
			best = d
			nearest = c
	if target == null or target != nearest:
		_fail("Merge Hint should mark the nearest matching seed")
		_finish(backup, gs)
		return
	held.set("_dragging", false)
	await _frames(12)
	if arena.call("get_merge_hint_target") != null:
		_fail("Merge Hint mark should go away on release")
		_finish(backup, gs)
		return
	await create_timer(0.3).timeout
	if bool(arena.call("is_merge_hint_visible")):
		_fail("Merge Hint brackets should be hidden after release")
		_finish(backup, gs)
		return

	# Spoj: držana i označena sjemenka nestanu (oslobođena meta je `== null` u 4.7) —
	# zagrade ne smiju ostati visjeti na mjestu spojenog para.
	held.set("_dragging", true)
	await _frames(3)
	target = arena.call("get_merge_hint_target")
	if target == null:
		_fail("Merge Hint should mark a seed again")
		_finish(backup, gs)
		return
	chips.erase(target)
	chips.erase(held)
	target.free()
	held.free()
	await _frames(12)
	await create_timer(0.3).timeout
	if bool(arena.call("is_merge_hint_visible")):
		_fail("Merge Hint brackets stayed on screen after the marked pair merged")
		_finish(backup, gs)
		return

	# Kraj sesije sa zagradama na ekranu: polje se isprazni → oznaka mora otići.
	held = chips[0]
	held.set("_dragging", true)
	await _frames(3)
	if not bool(arena.call("is_merge_hint_visible")):
		_fail("Merge Hint should show for the remaining pair")
		_finish(backup, gs)
		return
	arena.call("_clear_field_chips")
	await _frames(1)
	arena.call("_end_session_if_settled")
	await _frames(2)
	if bool(arena.call("is_merge_hint_visible")) or bool(arena.call("is_session_open")):
		_fail("Merge Hint brackets should be gone when the session ends")
		_finish(backup, gs)
		return
	gs.set("merge_hint_owned", false)
	_finish(backup, gs)
