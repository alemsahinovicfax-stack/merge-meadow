extends SceneTree

## ARENA-02 LEFTOVER-C — hide overlay before Camp; title readable on dark panel.


const SAVE_PATH := "user://player_save.json"
const UI_TEXT_INK := Color("#4A4A4A")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	print("arena_leftover_c_smoke FAIL: %s" % msg)
	push_error("arena_leftover_c_smoke: %s" % msg)
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


func _list_of(arena: Node) -> VBoxContainer:
	return arena.get_node_or_null(
		"NeedMoreSeedsOverlay/Panel/VBox/NeedMoreSeedsScroll/NeedMoreSeedsList"
	) as VBoxContainer


func _title_of(arena: Node) -> Label:
	return arena.get_node_or_null("NeedMoreSeedsOverlay/Panel/VBox/NeedMoreSeedsTitle") as Label


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


func _show_stuck_overlay(arena: Node, gs: Node) -> void:
	gs.set("seed_bag", {"clover": 3, "daisy": 2, "tulip": 1})
	arena.call("_on_bag_clicked")
	for _j in 4:
		await process_frame


func _run() -> void:
	print("arena_leftover_c_smoke start")
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	var arena := await _boot_arena(backup)
	if arena == null:
		return
	if not arena.has_method("_hide_need_more_overlay"):
		_restore_save(backup)
		_fail("hide helper missing")
		return
	if not arena.has_method("_on_done_pressed"):
		_restore_save(backup)
		_fail("Done path missing")
		return

	await _show_stuck_overlay(arena, gs)
	var overlay := _overlay_of(arena)
	if overlay == null or not overlay.visible:
		_restore_save(backup)
		_fail("stuck bag should show overlay")
		return
	var title := _title_of(arena)
	if title == null or not title.text.contains("You need more seeds"):
		_restore_save(backup)
		_fail("title should contain You need more seeds")
		return
	if title.modulate.a < 0.9:
		_restore_save(backup)
		_fail("title modulate too faint %s" % str(title.modulate.a))
		return
	var font_color: Color = title.get_theme_color("font_color")
	if font_color.is_equal_approx(UI_TEXT_INK):
		_restore_save(backup)
		_fail("title font_color must not be UI_TEXT ink, got %s" % str(font_color))
		return

	arena.call("set_arena_page_active", false)
	overlay = _overlay_of(arena)
	var list := _list_of(arena)
	if overlay == null or overlay.visible:
		_restore_save(backup)
		_fail("page inactive must hide overlay")
		return
	if list == null or list.get_child_count() != 0:
		_restore_save(backup)
		_fail("page inactive hide must clear list")
		return

	arena.call("set_arena_page_active", true)
	await _show_stuck_overlay(arena, gs)
	overlay = _overlay_of(arena)
	if overlay == null or not overlay.visible:
		_restore_save(backup)
		_fail("stuck bag should show overlay again")
		return

	arena.call("_on_done_pressed")
	overlay = _overlay_of(arena)
	list = _list_of(arena)
	if overlay == null or overlay.visible:
		_restore_save(backup)
		_fail("Done must hide overlay before Camp")
		return
	if list == null or list.get_child_count() != 0:
		_restore_save(backup)
		_fail("hide must clear list, got %s" % (str(list.get_child_count()) if list else "null"))
		return
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("Done should leave 0 chips, got %d" % _field_chips(arena).size())
		return
	arena.call("set_arena_page_active", true)
	overlay = _overlay_of(arena)
	if overlay == null or overlay.visible:
		_restore_save(backup)
		_fail("return to arena tab must keep overlay hidden")
		return
	if not _field_chips(arena).is_empty():
		_restore_save(backup)
		_fail("return to arena tab must keep empty field")
		return

	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_leftover_c_smoke OK")
	quit(0)
