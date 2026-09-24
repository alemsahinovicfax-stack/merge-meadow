extends SceneTree

## ARENA-01 DAILY-A — one local-day arena task, badge claim, no loot.


const SAVE_PATH := "user://player_save.json"


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("arena_daily_smoke: %s" % msg)
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


func _today() -> String:
	var d := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var backup := _backup_save()
	gs.set("wallet_coins", 77)
	gs.set("arena_daily_day", "2000-01-01")
	gs.set("arena_daily_kind", "merge_t2")
	gs.set("arena_daily_progress", 2)
	gs.set("arena_daily_goal", 3)
	gs.set("arena_daily_claimed_day", "")
	gs.set("arena_daily_streak", 4)
	gs.call("ensure_arena_daily_task")
	if str(gs.get("arena_daily_day")) != _today():
		_restore_save(backup)
		_fail("ensure should roll today, got %s" % str(gs.get("arena_daily_day")))
		return
	if int(gs.get("arena_daily_progress")) != 0:
		_restore_save(backup)
		_fail("new day progress expected 0")
		return
	var kind := str(gs.get("arena_daily_kind"))
	if kind != "merge_t2" and kind != "make_t3" and kind != "combo_5":
		_restore_save(backup)
		_fail("unexpected kind %s" % kind)
		return
	var goal := int(gs.get("arena_daily_goal"))
	if kind == "merge_t2" and goal != 3:
		_restore_save(backup)
		_fail("merge_t2 goal expected 3")
		return
	if kind != "merge_t2" and goal != 1:
		_restore_save(backup)
		_fail("%s goal expected 1" % kind)
		return
	var wallet := int(gs.get("wallet_coins"))
	for _i in goal:
		gs.call("note_arena_daily_event", kind)
	if int(gs.get("arena_daily_progress")) != goal:
		_restore_save(backup)
		_fail("progress expected %d got %d" % [goal, int(gs.get("arena_daily_progress"))])
		return
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("note must not change wallet")
		return
	if not bool(gs.call("can_claim_arena_daily")):
		_restore_save(backup)
		_fail("should be claimable after goal")
		return
	var streak_before := int(gs.get("arena_daily_streak"))
	var claim_msg := str(gs.call("claim_arena_daily"))
	if int(gs.get("arena_daily_streak")) != streak_before + 1:
		_restore_save(backup)
		_fail("claim should bump streak")
		return
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("claim must not change wallet")
		return
	if not claim_msg.begins_with("Arena streak"):
		_restore_save(backup)
		_fail("claim message expected streak, got %s" % claim_msg)
		return
	var streak_after := int(gs.get("arena_daily_streak"))
	var second := str(gs.call("claim_arena_daily"))
	if int(gs.get("arena_daily_streak")) != streak_after:
		_restore_save(backup)
		_fail("second claim must not change streak")
		return
	if int(gs.get("wallet_coins")) != wallet:
		_restore_save(backup)
		_fail("second claim must not change wallet")
		return
	if second.is_empty():
		_restore_save(backup)
		_fail("second claim should return a no-op message")
		return
	gs.set("arena_daily_day", _today())
	gs.set("arena_daily_kind", "combo_5")
	gs.set("arena_daily_goal", 1)
	gs.set("arena_daily_progress", 0)
	gs.call("note_arena_daily_event", "combo_5")
	if int(gs.get("arena_daily_progress")) != 1:
		_restore_save(backup)
		_fail("combo_5 note expected 1/1")
		return
	gs.call("note_arena_daily_event", "combo_5")
	if int(gs.get("arena_daily_progress")) != 1:
		_restore_save(backup)
		_fail("combo_5 extra note should stay 1")
		return
	var err := change_scene_to_file("res://scenes/camp/merge_arena.tscn")
	if err != OK:
		_restore_save(backup)
		_fail("arena load failed %d" % err)
		return
	for _f in 16:
		await process_frame
	var arena: Node = current_scene
	if arena == null:
		_restore_save(backup)
		_fail("arena scene missing")
		return
	if not arena.has_method("_end_session_to_camp"):
		_restore_save(backup)
		_fail("session exit missing")
		return
	# HUD pilula dnevnog zadatka uklonjena 2026-09-24 — logika mora raditi i bez prikaza.
	if arena.get_node_or_null("RootVBox/ArenaHud") != null:
		_restore_save(backup)
		_fail("ArenaHud row should be gone")
		return
	_restore_save(backup)
	if FileAccess.file_exists(SAVE_PATH):
		gs.call("load_player_save")
	print("arena_daily_smoke OK")
	quit(0)
