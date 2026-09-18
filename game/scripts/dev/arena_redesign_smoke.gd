extends SceneTree

## Merge Arena redizajn (smjer B, design_handoff_merge_arena) na visini hub stranice (1597):
## budzet HUD/hint/Done, Done ne dira NavLockPill, 30 sjemenki bez preklapanja i van keepout
## zona (rešetka), T3 kristal stize u StashCounter, najduza poruka staje u 2 reda.

const SAVE_PATH := "user://player_save.json"
const HUB_PAGE := Vector2(1080.0, 1597.0)
const TOLERANCE := 1.5
const LONG_HINT := "Paper Lantern Bloom crystal → stash. Muncher frozen 2s."

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var gs := get_root().get_node_or_null("GameState")
	var backup := _backup_save()
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK or gs == null:
		_fail("arena load failed %d" % err)
		_finish(backup, gs)
		return
	for _i in 8:
		await process_frame
	var arena := current_scene as Control
	arena.set_anchors_preset(Control.PRESET_TOP_LEFT)
	arena.size = HUB_PAGE
	for _i in 8:
		await process_frame
	_check_layout(arena)
	await _check_hint(arena)
	await _check_full_pour(arena, gs)
	await _check_t3_moment(arena, gs)
	_finish(backup, gs)


func _check_layout(arena: Control) -> void:
	if arena.get_node_or_null("RootVBox/TopBar") != null:
		_fail("old TopBar/title should be gone")
	_expect_near("ArenaHud height", _h(arena, "RootVBox/ArenaHud"), UiArena.HUD_H)
	_expect_near("HintLine height", _h(arena, "RootVBox/HintLine"), UiArena.HINT_H)
	var done := arena.get_node_or_null("RootVBox/DoneRow/DoneButton") as Control
	if done == null:
		_fail("DoneButton missing")
		return
	if done.size.y < UiArena.DONE_H - TOLERANCE:
		_fail("Done hit height %.1f < %d" % [done.size.y, UiArena.DONE_H])
	var gap: float = HUB_PAGE.y - (done.get_global_rect().end.y - arena.global_position.y)
	if gap < UiArena.DONE_GAP_BOTTOM - TOLERANCE:
		_fail("Done must keep %d px above the footer (pill zone), got %.1f" % [UiArena.DONE_GAP_BOTTOM, gap])
	var expected_field := HUB_PAGE.y - UiArena.HUD_H - UiArena.HINT_H \
		- (UiArena.DONE_GAP_TOP + UiArena.DONE_H + UiArena.DONE_GAP_BOTTOM)
	_expect_near("Playfield height", _h(arena, "RootVBox/Playfield"), expected_field)


func _check_hint(arena: Control) -> void:
	arena.call("_set_hint", LONG_HINT)
	for _i in 3:
		await process_frame
	var pill := arena.get_node_or_null("RootVBox/HintLine/HintPill") as Control
	if pill == null:
		_fail("HintPill missing")
		return
	if pill.size.y > UiArena.HINT_H + 8.0:
		_fail("longest hint should fit 2 lines in %d px, pill is %.1f" % [UiArena.HINT_H, pill.size.y])


func _check_full_pour(arena: Control, gs: Node) -> void:
	arena.call("_clear_field_chips")
	gs.set("seed_bag", {"clover": 8, "daisy": 8, "buttercup": 8, "tulip": 8})
	arena.call("_on_bag_clicked")
	for _i in 6:
		await process_frame
	var chips := _field_chips(arena)
	# Autoload ime (GameState) se ne smije pojaviti u SceneTree smoke skripti — povuce SceneRouter.
	var max_chips := int(gs.get_script().get_script_constant_map().get("ARENA_MAX_CHIPS", 30))
	if chips.size() != max_chips:
		_fail("full pour expected %d chips, got %d" % [max_chips, chips.size()])
	var min_dist := INF
	for i in chips.size():
		for j in range(i + 1, chips.size()):
			var d: float = chips[i].get_center().distance_to(chips[j].get_center())
			min_dist = minf(min_dist, d)
	if min_dist < 140.0:
		_fail("chips overlap after full pour (min center distance %.1f)" % min_dist)
	var zones: Array = arena.call("_physical_keepouts")
	for chip in chips:
		var center: Vector2 = chip.get_center()
		for zone in zones:
			var rect: Rect2 = zone
			if rect.has_point(center):
				_fail("chip %s sits inside a keepout zone" % chip.type_id)
				return


func _check_t3_moment(arena: Control, gs: Node) -> void:
	arena.call("_clear_field_chips")
	var before := int(gs.call("get_garden_crystal_total"))
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9101, "type_id": "clover", "tier": 2},
		{"chip_id": 9102, "type_id": "clover", "tier": 2},
	])
	var chips := _field_chips(arena)
	if chips.size() != 2:
		_fail("T3 setup expected 2 chips, got %d" % chips.size())
		return
	chips[0].call("set_center", chips[1].get_center() + Vector2(8.0, 0.0))
	arena.call("_on_chip_released", chips[0])
	await create_timer(1.0).timeout
	var after := int(gs.call("get_garden_crystal_total"))
	if after != before + 1:
		_fail("T3 should add 1 crystal to the stash (%d → %d)" % [before, after])
	var stash := arena.get_node_or_null("RootVBox/ArenaHud/Row/StashCounter/HBox/StashLabel") as Label
	if stash == null or stash.text != UiChrome.format_count(after):
		_fail("StashCounter should show %d after the crystal lands, got %s" % [after, stash.text if stash else "null"])
	if int(arena.get("_stash_pending")) != 0:
		_fail("no crystal should still be in flight")
	for child in arena.get_children():
		if child.name.begins_with("VacuumFly"):
			_fail("T3 ghost left behind after landing")
			return


func _field_chips(arena: Control) -> Array:
	var out: Array = []
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return out
	for child in playfield.get_children():
		if "pulse_highlight" in child and "type_id" in child and not child.is_queued_for_deletion():
			out.append(child)
	return out


func _h(arena: Control, path: String) -> float:
	var node := arena.get_node_or_null(path) as Control
	return node.size.y if node else -1.0


func _expect_near(what: String, got: float, want: float) -> void:
	if absf(got - want) > TOLERANCE:
		_fail("%s: got %.1f expected %.1f" % [what, got, want])


func _fail(msg: String) -> void:
	_failed = true
	push_error("arena_redesign_smoke: " + msg)


func _backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	return FileAccess.get_file_as_string(SAVE_PATH)


func _finish(backup: String, gs: Node) -> void:
	if not backup.is_empty():
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_string(backup)
			f.close()
		if gs:
			gs.call("load_player_save")
	if _failed:
		quit(1)
		return
	print("arena_redesign_smoke OK")
	quit(0)
