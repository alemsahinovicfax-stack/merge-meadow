extends SceneTree

## Arena v2 (design_handoff_arena_v2): svih 8 livada kao recept (slojevi <= 4, vrste 3-6,
## bez teksture, svi poligoni triangulisani, crtanje na nivou 0 i 4), SeedBase na sjemenci,
## korpa (300 x 280, usta, gomila 0/1/12), combo na polju (×N, talas, svjetlo, povratak),
## muncher prolazi sve poze.

const SAVE_PATH := "user://player_save.json"

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var backup := _backup_save()
	await _check_fields()
	if not _failed:
		_check_tokens()
	if not _failed:
		await _check_arena()
	_restore_save(backup)
	if not _failed:
		print("arena_v2_fields_smoke OK")
		quit(0)


func _check_fields() -> void:
	var bg: Control = load("res://scripts/camp/arena_meadow_bg.gd").new()
	bg.size = Vector2(1080.0, 1633.0)
	get_root().add_child(bg)
	await process_frame
	for id in UiArenaV2.FIELDS:
		var field: Dictionary = UiArenaV2.FIELDS[id]
		var layers: Array = field["layers"]
		var scatter: Array = field["scatter"]
		if layers.size() > 4:
			_fail("%s: %d layers > 4" % [id, layers.size()])
			return
		if scatter.size() < 3 or scatter.size() > 6:
			_fail("%s: %d scatter kinds outside 3-6" % [id, scatter.size()])
			return
		if JSON.stringify(field).to_lower().contains(".png"):
			_fail("%s: recipe references a texture" % id)
			return
		for s in scatter:
			if not UiArenaV2.SHAPES.has(str(s["shape"])):
				_fail("%s: unknown shape %s" % [id, s["shape"]])
				return
		bg.call("set_season", id)
		if str(bg.call("get_season_id")) != id:
			_fail("%s: set_season did not apply" % id)
			return
		if not bool(bg.call("all_layers_triangulated")):
			_fail("%s: a layer polygon failed to triangulate" % id)
			return
		for level in [0.0, 4.0]:
			bg.call("set_t3_level", level, false)
			bg.queue_redraw()
			await process_frame
	bg.queue_free()
	await process_frame


func _check_tokens() -> void:
	for pair in [[0, 0], [1, 1], [40, 12], [20, 6]]:
		if UiArenaV2.basket_visible(pair[0]) != pair[1]:
			_fail("basket_visible(%d) expected %d" % [pair[0], pair[1]])
			return
	var ui_arena: GDScript = load("res://scripts/visual/ui_arena.gd")
	var base: StyleBoxFlat = ui_arena.call("chip_base_style", 1)
	if not base.bg_color.is_equal_approx(UiArenaV2.SEED_BASE):
		_fail("SeedBase color mismatch")
		return
	var base_t2: StyleBoxFlat = ui_arena.call("chip_base_style", 2)
	if base_t2.corner_radius_top_left != UiArenaV2.SEED_BASE_T2_RADIUS:
		_fail("SeedBase T2 corner should be 42")
		return
	if UiArenaV2.combo_step(1) != {} or float(UiArenaV2.combo_step(9)["light"]) != 0.13:
		_fail("combo_step table wrong")
		return


func _check_arena() -> void:
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_fail("arena load failed %d" % err)
		return
	for _i in 8:
		await process_frame
	var arena := current_scene as Control
	var bag := arena.get_node_or_null("RootVBox/Playfield/SeedBag") as Control
	if bag == null or not bag.size.is_equal_approx(UiArenaV2.BASKET_HIT):
		_fail("basket missing or not 300 x 280")
		return
	var mouth: Vector2 = bag.call("get_mouth_position")
	if not mouth.is_equal_approx(Vector2(bag.call("get_base_position")) + UiArenaV2.BASKET_MOUTH):
		_fail("basket mouth should be opening center")
		return
	bag.call("set_state", 0, false, [])
	if int(bag.call("get_visible_pile")) != 0:
		_fail("empty basket should show no pile")
		return
	bag.call("set_state", 40, true, ["clover", "daisy"])
	if int(bag.call("get_visible_pile")) != 12:
		_fail("40 seeds should show 12 flowers")
		return
	await process_frame

	var bg := arena.get_node("Bg")
	var center := Vector2(540.0, 800.0)
	arena.call("register_arena_combo_merge", center)
	arena.call("register_arena_combo_merge", center)
	var mark := arena.call("get_combo_mark") as Label
	if mark == null or mark.text != "×2":
		_fail("combo 2 should show ×2 mark")
		return
	if arena.get_node_or_null("RootVBox/Playfield/ComboRipple0") == null:
		_fail("combo ripple missing")
		return
	for _i in 3:
		arena.call("register_arena_combo_merge", center)
	if mark.text != "×5":
		_fail("combo 5 mark expected")
		return
	await create_timer(0.3).timeout
	var light := float(bg.call("get_combo_light_alpha"))
	if light < 0.1:
		_fail("combo 5 light should be ~0.13, got %.3f" % light)
		return
	await create_timer(1.8).timeout
	if int(arena.call("get_combo_count")) != 0:
		_fail("combo should clear after window")
		return
	if float(bg.call("get_combo_light_alpha")) > 0.01:
		_fail("combo light should return to 0")
		return

	var pest := arena.get_node_or_null("RootVBox/Playfield/MuncherPest")
	if pest == null:
		_fail("muncher missing")
		return
	if str(pest.call("get_pose_key")) != "sleep":
		_fail("muncher should sleep in nest")
		return
	pest.call("on_t3_created")
	await process_frame
	if str(pest.call("get_pose_key")) != "frozen":
		_fail("T3 should freeze muncher")
		return
	pest.call("reset_to_nest")
	var segs: Array = pest.call("get_segment_positions")
	if segs.size() != 3:
		_fail("muncher needs 3 segments")
		return
	await process_frame


func _fail(msg: String) -> void:
	if _failed:
		return
	_failed = true
	push_error("arena_v2_fields_smoke: %s" % msg)
	quit(1)


func _backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	return file.get_as_text() if file != null else ""


func _restore_save(backup: String) -> void:
	if backup.is_empty():
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(SAVE_PATH)
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(backup)
