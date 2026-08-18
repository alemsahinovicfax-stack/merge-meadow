extends SceneTree

## Bug-021/026 — journal rows: three tier icons; lock/color; kept_tier=2 and =3.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _assert_clover_tiers(row: Node, kept: int) -> String:
	for tier in [1, 2, 3]:
		var icon: Node = row.call("get_tier_icon", tier)
		if icon == null:
			return "missing TierIcon %d" % tier
	var t1: Node = row.call("get_tier_icon", 1)
	var t2: Node = row.call("get_tier_icon", 2)
	var t3: Node = row.call("get_tier_icon", 3)
	if bool(t1.get("dim_locked")):
		return "T1 should be unlocked"
	if kept >= 2:
		if bool(t2.get("dim_locked")):
			return "T2 should be unlocked for kept_tier=%d" % kept
		if int(t2.get("plant_tier")) != 2:
			return "T2 plant_tier expected 2"
	else:
		if not bool(t2.get("dim_locked")):
			return "T2 should be locked"
	if kept >= 3:
		if bool(t3.get("dim_locked")):
			return "T3 should be unlocked for kept_tier=3"
		if int(t3.get("plant_tier")) != 3:
			return "T3 plant_tier expected 3"
	else:
		if not bool(t3.get("dim_locked")):
			return "T3 should stay locked for kept_tier=%d" % kept
		if int(t3.get("plant_tier")) != 0:
			return "locked T3 plant_tier should be 0"
	if int(t1.get("plant_tier")) != 1:
		return "T1 plant_tier expected 1"
	return ""


func _run() -> void:
	var gs := _gs()
	if gs == null:
		push_error("collection_journal_smoke: GameState missing")
		quit(1)
		return

	# --- kept_tier=2 ---
	gs.set("discovered_blooms", {"clover": true})
	gs.set("collection_kept_tiers", {"clover": 2})
	gs.set("collection_journal_pending", {})
	var err := change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var journal := current_scene as Control
	if journal == null:
		push_error("collection_journal_smoke: journal scene missing")
		quit(1)
		return
	var list := journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or list.get_child_count() < 1:
		push_error("collection_journal_smoke: journal list empty")
		quit(1)
		return
	var clover_row: Node = list.get_child(0)
	if clover_row == null or not clover_row.has_method("get_tier_icon"):
		push_error("collection_journal_smoke: first row missing get_tier_icon")
		quit(1)
		return
	var msg := _assert_clover_tiers(clover_row, 2)
	if not msg.is_empty():
		push_error("collection_journal_smoke (kept=2): %s" % msg)
		quit(1)
		return

	# --- kept_tier=3: rebuild journal ---
	gs.set("collection_kept_tiers", {"clover": 3})
	err = change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal reload failed %d" % err)
		quit(1)
		return
	for _j in 12:
		await process_frame
	journal = current_scene as Control
	list = journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or list.get_child_count() < 1:
		push_error("collection_journal_smoke: journal list empty after reload")
		quit(1)
		return
	clover_row = list.get_child(0)
	msg = _assert_clover_tiers(clover_row, 3)
	if not msg.is_empty():
		push_error("collection_journal_smoke (kept=3): %s" % msg)
		quit(1)
		return

	# --- Bug-028: stash_garden_crystal bumps kept_tier to 3 ---
	gs.set("discovered_blooms", {"clover": true})
	gs.set("collection_kept_tiers", {"clover": 2})
	gs.set("collection_journal_pending", {})
	gs.set("garden_crystal_stash", {})
	gs.call("stash_garden_crystal", "clover")
	var kept_after: Dictionary = gs.get("collection_kept_tiers")
	if int(kept_after.get("clover", 0)) != 3:
		push_error(
			"collection_journal_smoke: stash should set kept_tier=3 got %s"
			% str(kept_after.get("clover"))
		)
		quit(1)
		return
	err = change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal reload after stash failed %d" % err)
		quit(1)
		return
	for _k in 12:
		await process_frame
	journal = current_scene as Control
	list = journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or list.get_child_count() < 1:
		push_error("collection_journal_smoke: journal list empty after stash")
		quit(1)
		return
	clover_row = list.get_child(0)
	msg = _assert_clover_tiers(clover_row, 3)
	if not msg.is_empty():
		push_error("collection_journal_smoke (stash→T3): %s" % msg)
		quit(1)
		return

	print("collection_journal_smoke OK")
	quit(0)
