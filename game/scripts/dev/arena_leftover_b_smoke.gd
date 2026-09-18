extends SceneTree

## ARENA-02 LEFTOVER-B — stuck bag overlay n/4; tap → Camp; auto-refill does not open it.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	print("arena_leftover_b_smoke FAIL: %s" % msg)
	push_error("arena_leftover_b_smoke: %s" % msg)
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


func _overlay_of(arena: Node) -> Control:
	return arena.get_node_or_null("NeedMoreSeedsOverlay") as Control


func _boot_arena(backup: String) -> Node:
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return null
	for _i in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null or not arena.has_method("_on_bag_clicked"):
		_restore_save(backup)
		_fail("arena missing bag API")
		return null
	return arena


func _run() -> void:
	print("arena_leftover_b_smoke start")
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	var arena := await _boot_arena(backup)
	if arena == null:
		return
	if not arena.has_method("_on_done_pressed"):
		_restore_save(backup)
		_fail("Done path missing")
		return
	var overlay := _overlay_of(arena)
	if overlay == null:
		_restore_save(backup)
		_fail("NeedMoreSeedsOverlay missing")
		return

	gs.set("seed_bag", {"clover": 4})
	arena.call("_on_bag_clicked")
	for _n in 6:
		await process_frame
	if _field_chips(arena).size() != 4:
		_restore_save(backup)
		_fail("4 clover should pour, got %d chips" % _field_chips(arena).size())
		return
	if overlay.visible:
		_restore_save(backup)
		_fail("successful pour must not show overlay")
		return

	arena = await _boot_arena(backup)
	if arena == null:
		return
	overlay = _overlay_of(arena)
	var spawn: Array = []
	for i in 8:
		spawn.append({"chip_id": 9500 + i, "type_id": "clover", "tier": 1})
	gs.set("seed_bag", {"daisy": 3})
	arena.call("_spawn_poured_chips", spawn)
	for _q in 4:
		await process_frame
	arena.call("_try_auto_refill")
	for _r in 12:
		await process_frame
	if overlay != null and overlay.visible:
		_restore_save(backup)
		_fail("auto-refill must not open overlay")
		return
	if _field_chips(arena).size() != 8:
		_restore_save(backup)
		_fail("auto remainder should keep 8 chips, got %d" % _field_chips(arena).size())
		return

	gs.set("seed_bag", {})
	arena.call("_on_bag_clicked")
	for _s in 2:
		await process_frame
	if overlay != null and overlay.visible:
		_restore_save(backup)
		_fail("empty bag must not open overlay")
		return

	arena = await _boot_arena(backup)
	if arena == null:
		return
	overlay = _overlay_of(arena)
	var full_spawn: Array = []
	for i in 40:
		full_spawn.append({"chip_id": 9600 + i, "type_id": "clover", "tier": 1})
	gs.set("seed_bag", {"daisy": 3})
	arena.call("_spawn_poured_chips", full_spawn)
	for _u in 4:
		await process_frame
	arena.call("_on_bag_clicked")
	for _v in 2:
		await process_frame
	if overlay != null and overlay.visible:
		_restore_save(backup)
		_fail("arena full must not open overlay")
		return

	arena = await _boot_arena(backup)
	if arena == null:
		return
	overlay = _overlay_of(arena)
	gs.set("wallet_coins", 17)
	gs.set("seed_bag", {"clover": 3, "daisy": 2, "tulip": 1})
	arena.call("_on_bag_clicked")
	for _j in 4:
		await process_frame
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("remainder tap must not spawn chips, got %d" % _field_chips(arena).size())
		return
	if overlay == null or not overlay.visible:
		_restore_save(backup)
		_fail("stuck bag should show overlay")
		return
	var title: Label = arena.get_node_or_null("NeedMoreSeedsOverlay/Panel/VBox/NeedMoreSeedsTitle")
	if title == null or not title.text.contains("You need more seeds"):
		_restore_save(backup)
		_fail("title should contain You need more seeds, got %s" % (title.text if title else "null"))
		return
	var list: VBoxContainer = arena.get_node_or_null(
		"NeedMoreSeedsOverlay/Panel/VBox/NeedMoreSeedsScroll/NeedMoreSeedsList"
	)
	if list == null or list.get_child_count() != 3:
		_restore_save(backup)
		_fail("list should have 3 rows, got %s" % (str(list.get_child_count()) if list else "null"))
		return
	var clover_chip: Node = null
	for i in list.get_child_count():
		var row := list.get_child(i)
		if row.has_method("get_type_id") and str(row.call("get_type_id")) == "clover":
			clover_chip = row
			break
	if clover_chip == null:
		_restore_save(backup)
		_fail("clover row missing from need-more list")
		return
	var count_text := ""
	if clover_chip.has_method("get_count_label_text"):
		count_text = str(clover_chip.call("get_count_label_text"))
	if not count_text.contains("3/4"):
		_restore_save(backup)
		_fail("clover quota should be 3/4, got %s" % count_text)
		return
	if int(gs.get("wallet_coins")) != 17:
		_restore_save(backup)
		_fail("wallet must not change on overlay, got %d" % int(gs.get("wallet_coins")))
		return
	# Redizajn (design_handoff_merge_arena): overlay se zatvara samo preko "Back to Camp".
	var back_btn := arena.get_node_or_null("NeedMoreSeedsOverlay/Panel/VBox/BackToCampButton") as Control
	if back_btn == null or not back_btn.is_visible_in_tree():
		_restore_save(backup)
		_fail("overlay should offer a Back to Camp CTA")
		return
	if not overlay.get_signal_connection_list("gui_input").is_empty():
		_restore_save(backup)
		_fail("overlay must not close on any tap — only Back to Camp")
		return
	arena.call("_on_back_to_camp_pressed")
	if overlay.visible:
		_restore_save(backup)
		_fail("Back to Camp should hide the overlay")
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_leftover_b_smoke OK")
	quit(0)
