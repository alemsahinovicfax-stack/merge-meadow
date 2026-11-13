extends SceneTree

## FIX-TEL-3 (2026-11-12) — Journal i tierovi:
##  · sjeme pokupljeno u runu odmah upisuje ★T1 te vrste (stanje „seen", oznaka NEW) — i za
##    sezone van lanca Country Blooma (prijava: „otključam novu sezonu, uzmem prva sjemena, a
##    Journal se ne updejtuje");
##  · T2 se upisuje prvim spajanjem u T2 u Areni, T3 prvim spajanjem u T3;
##  · stari save: vrsta s pokupljenim sjemenom dobija T1 pri učitavanju (bez NEW).

var _backup := ""
var _failed := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("journal_run_seed_smoke: %s" % msg)


func _entry(gs: Node, type_id: String) -> Dictionary:
	for e in gs.call("get_collection_journal_entries"):
		if str(e.get("type_id", "")) == type_id:
			return e
	return {}


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	await process_frame
	var seed_id := "frost_snowdrop"
	gs.set("discovered_blooms", {})
	gs.set("collection_kept_tiers", {})
	gs.set("collection_journal_pending", {})
	gs.set("lifetime_seeds_collected", {})

	if str(_entry(gs, seed_id).get("state", "")) != "locked":
		_fail("%s should start locked in the Journal, got %s" % [seed_id, _entry(gs, seed_id).get("state", "")])

	# 1 · run: jedno sjeme → T1 odmah.
	gs.call("record_seed_pickup_lifetime", seed_id, 1)
	var e := _entry(gs, seed_id)
	if str(e.get("state", "")) != "seen":
		_fail("a seed picked up in a run should show as tier 1 at once, state is %s" % e.get("state", ""))
	if not bool(e.get("is_new", false)) or int(e.get("new_tier", 0)) != 1:
		_fail("the first pickup should mark the Journal entry NEW (tier 1)")
	if str(e.get("display_name", "???")) == "???":
		_fail("a seen seed must show its name")
	# Drugo sjeme iste vrste ne dira oznaku (igrač ju je možda već pogledao).
	gs.call("mark_collection_journal_viewed")
	gs.call("record_seed_pickup_lifetime", seed_id, 1)
	if bool(_entry(gs, seed_id).get("is_new", false)):
		_fail("a second pickup of the same seed must not mark NEW again")
	if int(_entry(gs, seed_id).get("kept_tier", 0)) != 0:
		_fail("run pickups must not unlock tier 2 or 3")

	# 2 · Arena: T1 + T1 → T2 upisuje T2.
	var chips := {
		1: {"chip_id": 1, "type_id": seed_id, "tier": 1, "pos": Vector2(100, 100)},
		2: {"chip_id": 2, "type_id": seed_id, "tier": 1, "pos": Vector2(140, 100)},
		3: {"chip_id": 3, "type_id": seed_id, "tier": 2, "pos": Vector2(300, 100)},
	}
	var r: Dictionary = gs.call("try_merge_arena_chips", 1, 2, chips)
	if not bool(r.get("ok", false)) or int(r.get("new_tier", 0)) != 2:
		_fail("T1 + T1 should merge to T2")
	e = _entry(gs, seed_id)
	if str(e.get("state", "")) != "album_t2" or int(e.get("new_tier", 0)) != 2:
		_fail("the first T2 merge should unlock tier 2 in the Journal (state %s, new %s)" % [e.get("state", ""), e.get("new_tier", 0)])

	# 3 · T2 + T2 → T3 upisuje T3 (kontroler zove stash_garden_crystal).
	r = gs.call("try_merge_arena_chips", 1, 3, chips)
	if not bool(r.get("ok", false)) or int(r.get("new_tier", 0)) != 3:
		_fail("T2 + T2 should merge to T3")
	gs.call("stash_garden_crystal", seed_id)
	e = _entry(gs, seed_id)
	if str(e.get("state", "")) != "album_t3":
		_fail("the first T3 should unlock tier 3 in the Journal, state is %s" % e.get("state", ""))

	# 4 · stari save: pokupljeno sjeme bez upisa → T1 pri učitavanju, bez NEW.
	var old_id := "ice_crocus"
	gs.set("discovered_blooms", {})
	gs.set("collection_journal_pending", {})
	gs.set("lifetime_seeds_collected", {old_id: 7})
	if not bool(gs.call("_repair_album_from_lifetime")):
		_fail("an old save with collected seeds should be repaired")
	e = _entry(gs, old_id)
	if str(e.get("state", "")) != "seen" or bool(e.get("is_new", false)):
		_fail("old save: collected seed should be tier 1 without NEW (state %s)" % e.get("state", ""))
	if bool(gs.call("_repair_album_from_lifetime")):
		_fail("the repair must be idempotent")

	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("journal_run_seed_smoke OK")
	quit(1 if _failed else 0)
