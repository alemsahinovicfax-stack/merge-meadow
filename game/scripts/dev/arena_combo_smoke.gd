extends SceneTree

## ARENA-01 COMB-A — combo HUD, daily coin cap, pair pulse, pest does not reset.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_combo_smoke: %s" % msg)
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


func _run_grant_cap(gs: Node) -> bool:
	gs.set("wallet_coins", 100)
	gs.set("combo_coin_day", "")
	gs.set("combo_coins_granted_today", 0)
	var g1 := int(gs.call("try_grant_arena_combo_coins"))
	if g1 != 2:
		_fail("first grant expected 2 got %d" % g1)
		return false
	var g2 := int(gs.call("try_grant_arena_combo_coins"))
	if g2 != 2:
		_fail("second grant expected 2 got %d" % g2)
		return false
	if int(gs.get("wallet_coins")) != 104:
		_fail("wallet after two grants expected 104 got %d" % int(gs.get("wallet_coins")))
		return false
	if int(gs.get("combo_coins_granted_today")) != 4:
		_fail("granted_today expected 4")
		return false
	gs.set("combo_coins_granted_today", 9)
	var g3 := int(gs.call("try_grant_arena_combo_coins"))
	if g3 != 1:
		_fail("partial cap grant expected 1 got %d" % g3)
		return false
	gs.set("combo_coins_granted_today", 10)
	var g4 := int(gs.call("try_grant_arena_combo_coins"))
	if g4 != 0:
		_fail("at cap expected 0 got %d" % g4)
		return false
	return true


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	if not _run_grant_cap(gs):
		_restore_save(backup)
		return
	gs.set("combo_coin_day", "")
	gs.set("combo_coins_granted_today", 0)
	gs.set("wallet_coins", 50)
	gs.set("seed_bag", {"clover": 6, "daisy": 2})
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _i in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null or not arena.has_method("register_arena_combo_merge"):
		_restore_save(backup)
		_fail("arena controller missing combo API")
		return
	arena.call("register_arena_combo_merge")
	arena.call("register_arena_combo_merge")
	if int(arena.call("get_combo_count")) != 2:
		_restore_save(backup)
		_fail("two merges expected combo 2")
		return
	if not bool(arena.call("is_combo_hud_visible")):
		_restore_save(backup)
		_fail("HUD should show from combo 2")
		return
	await create_timer(2.0).timeout
	if int(arena.call("get_combo_count")) != 0:
		_restore_save(backup)
		_fail("timeout should clear combo")
		return
	if bool(arena.call("is_combo_hud_visible")):
		_restore_save(backup)
		_fail("HUD should hide after timeout")
		return
	var wallet_before := int(gs.get("wallet_coins"))
	for _n in 5:
		arena.call("register_arena_combo_merge")
	if int(arena.call("get_combo_count")) != 5:
		_restore_save(backup)
		_fail("fifth merge expected combo 5")
		return
	if int(gs.get("wallet_coins")) != wallet_before + 2:
		_restore_save(backup)
		_fail("combo 5 should grant 2 coins")
		return
	arena.call("register_arena_combo_merge")
	if int(gs.get("wallet_coins")) != wallet_before + 2:
		_restore_save(backup)
		_fail("combo 6 should not grant again this streak")
		return
	arena.call("_clear_combo")
	arena.call("register_arena_combo_merge")
	arena.call("register_arena_combo_merge")
	arena.call("register_arena_combo_merge")
	if int(arena.call("get_combo_count")) != 3:
		_restore_save(backup)
		_fail("expected combo 3 before eat")
		return
	arena.call("_spawn_poured_chips", [
		{"chip_id": 9101, "type_id": "clover", "tier": 1},
		{"chip_id": 9102, "type_id": "clover", "tier": 1},
		{"chip_id": 9103, "type_id": "daisy", "tier": 1},
	])
	for _j in 4:
		await process_frame
	var chips := _field_chips(arena)
	if chips.size() < 3:
		_restore_save(backup)
		_fail("expected 3 spawned chips, got %d" % chips.size())
		return
	var eat_target: Node = chips[2]
	arena.call("_pest_eat_chip", eat_target)
	for _k in 2:
		await process_frame
	if int(arena.call("get_combo_count")) != 3:
		_restore_save(backup)
		_fail("pest eat must not reset combo")
		return
	chips = _field_chips(arena)
	var clovers: Array = []
	var daisy: Node = null
	for chip in chips:
		if str(chip.get("type_id")) == "clover" and int(chip.get("tier")) == 1:
			clovers.append(chip)
		elif str(chip.get("type_id")) == "daisy":
			daisy = chip
	if clovers.size() < 2:
		_restore_save(backup)
		_fail("need two clover T1 for pulse")
		return
	arena.call("_on_chip_drag_started", clovers[0])
	if not bool(clovers[1].get("pulse_highlight")):
		_restore_save(backup)
		_fail("partner clover T1 should pulse")
		return
	if bool(clovers[0].get("pulse_highlight")):
		_restore_save(backup)
		_fail("held chip should not pulse itself")
		return
	if daisy != null and bool(daisy.get("pulse_highlight")):
		_restore_save(backup)
		_fail("daisy should not pulse for clover drag")
		return
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_combo_smoke OK")
	quit(0)
