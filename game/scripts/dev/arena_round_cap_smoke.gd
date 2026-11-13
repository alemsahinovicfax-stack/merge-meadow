extends SceneTree

## FIX-TEL-2 (2026-11-12) — Arena: najviše 200 sjemenki po merge rundi.
##  · pilula iznad vreće: ispod praga „N / 50" (krem), od praga „N / 200" (najviše 200, mint, puls);
##  · runda dolije iz vreće najviše UiCamp.GATE_MAX sjemenki; kad ih potroši, vreća više ne
##    sipa (ni na tap ni sama), ostatak čeka u vreći;
##  · nova runda (prazno polje) opet kreće od nule.

var _backup: String = ""
var _failed: bool = false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	_failed = true
	push_error("arena_round_cap_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("arena_round_cap_smoke OK")
	quit(1 if _failed else 0)


func _run() -> void:
	var gs := _gs()
	gs.set("tutorial_complete", true)
	gs.set("seed_bag", {"clover": 24, "daisy": 12})
	if change_scene_to_file("res://scenes/camp/merge_arena.tscn") != OK:
		_fail("arena did not load")
		_finish()
		return
	await _frames(16)
	var arena := current_scene
	var cap := int(UiCamp.GATE_MAX)
	if cap != 200:
		_fail("round cap should be 200, got %d" % cap)

	# Pilula: 36 < 50 → „36 / 50", bez pulsa.
	arena.call("_refresh_bag")
	await _frames(2)
	if str(arena.call("get_gate_text")) != "36 / 50" or bool(arena.call("is_gate_pulsing")):
		_fail("below the gate the pill should read '36 / 50' and stay still, got '%s'" % str(arena.call("get_gate_text")))
	# 120 ≥ 50 → „120 / 200", puls.
	gs.set("seed_bag", {"clover": 80, "daisy": 40})
	arena.call("_refresh_bag")
	await _frames(2)
	if str(arena.call("get_gate_text")) != "120 / 200" or not bool(arena.call("is_gate_pulsing")):
		_fail("above the gate the pill should read '120 / 200' and pulse, got '%s' (pulse %s)" % [
			str(arena.call("get_gate_text")), str(arena.call("is_gate_pulsing"))])
	# Više od capa → „200 / 200".
	gs.set("seed_bag", {"clover": 200, "daisy": 160})
	arena.call("_refresh_bag")
	await _frames(2)
	if str(arena.call("get_gate_text")) != "200 / 200":
		_fail("above the cap the pill should read '200 / 200', got '%s'" % str(arena.call("get_gate_text")))

	# Runda: sipaj dok ide; polje se prazni ručno (kao da je sve spojeno).
	var before := int(gs.call("sum_seed_bag_only"))
	arena.call("_on_bag_clicked")
	await _frames(4)
	if not bool(arena.call("is_session_open")):
		_fail("the first tap should open the round")
	var guard := 0
	while int(arena.call("round_cap_left")) > 0 and guard < 40:
		guard += 1
		arena.call("_clear_field_chips")
		arena.set("_chip_data", {})
		await _frames(2)
		arena.call("_pour_available_seeds")
		await _frames(2)
	var poured := int(arena.call("get_session_poured"))
	if poured != cap:
		_fail("one round should pour exactly %d seeds, poured %d" % [cap, poured])
	if before - int(gs.call("sum_seed_bag_only")) != cap:
		_fail("the bag should be %d seeds lighter, is %d" % [cap, before - int(gs.call("sum_seed_bag_only"))])
	# Cap je potrošen: ni tap ni auto dolijevanje više ne sipaju.
	arena.call("_clear_field_chips")
	arena.set("_chip_data", {})
	await _frames(2)
	if int(arena.call("_pour_available_seeds")) != 0:
		_fail("a capped round poured again")
	var bag_left := int(gs.call("sum_seed_bag_only"))
	arena.call("_try_auto_refill")
	await _frames(2)
	if int(gs.call("sum_seed_bag_only")) != bag_left:
		_fail("auto refill ignored the round cap")
	if bag_left != 160:
		_fail("160 seeds should wait for the next round, got %d" % bag_left)

	# Nova runda kreće od nule.
	arena.call("_end_session_if_settled")
	await _frames(4)
	if bool(arena.call("is_session_open")):
		_fail("an empty field should close the round")
	arena.call("_on_bag_clicked")
	await _frames(4)
	if int(arena.call("get_session_poured")) <= 0 or int(arena.call("get_session_poured")) > 30:
		_fail("a new round should start counting from zero (poured %d)" % int(arena.call("get_session_poured")))
	arena.call("_clear_field_chips")
	arena.set("_chip_data", {})
	_finish()
