extends SceneTree

## Bug-021/026 — journal rows: three tier icons; lock/color; kept_tier=2 and =3.
## 2026-10-06: redoslijed sezona (aktivna, djelimične, potpune, prazne), punjenje po 3
## sezone pri skrolu do kraja, izlazak ostavi 3, ★3 iz Loot Bursta je u Albumu i popravka
## starih saveova (★3 u stashu bez Albuma).


var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _bloom_rows(list: Node) -> Array:
	var out: Array = []
	_collect_rows(list, out)
	return out


func _collect_rows(n: Node, out: Array) -> void:
	for child in n.get_children():
		if child.has_method("get_tier_icon"):
			out.append(child)
		else:
			_collect_rows(child, out)


func _assert_catalog_album(gs: Node, journal: Node, list: VBoxContainer) -> String:
	var entries: Array = gs.call("get_collection_journal_entries")
	var catalog_ids: Array = SeedCatalog.all_type_ids()
	if entries.size() != catalog_ids.size():
		return "entries %d != catalog %d" % [entries.size(), catalog_ids.size()]
	var total := int(journal.call("total_season_count"))
	var loaded := int(journal.call("loaded_season_count"))
	if total != 8 or loaded != 3:
		return "first visit should load 3 of 8 seasons, got %d of %d" % [loaded, total]
	var rows := _bloom_rows(list)
	if rows.size() != loaded * 6:
		return "list rows %d != %d (3 seasons x 6)" % [rows.size(), loaded * 6]
	var frost_state := ""
	for entry_any in entries:
		var entry: Dictionary = entry_any
		if str(entry.get("type_id", "")) == "frost_snowdrop":
			frost_state = str(entry.get("state", ""))
			break
	if frost_state.is_empty():
		return "missing frost_snowdrop entry"
	if frost_state != "locked":
		return "frost_snowdrop state %s expected locked" % frost_state
	return ""


## Aktivna sezona prva, pa djelimično otključane, pa potpune, pa bez ijednog cvijeta.
func _assert_order(gs: Node, journal: Node) -> String:
	var entries: Array = gs.call("get_collection_journal_entries")
	var unlocked := {}
	var total := {}
	for e in entries:
		var sid := SeedCatalog.season_id_for(str(e["type_id"]))
		total[sid] = int(total.get(sid, 0)) + 1
		if str(e["state"]) != "locked":
			unlocked[sid] = int(unlocked.get(sid, 0)) + 1
	var order: Array = journal.call("season_order")
	var active := str(gs.get("active_season_id"))
	if order.is_empty() or str(order[0]) != active:
		return "active season %s should be first, order %s" % [active, str(order)]
	var last_rank := 0
	for sid in order:
		var u := int(unlocked.get(sid, 0))
		var rank := 0 if sid == active else (1 if u > 0 and u < int(total[sid]) else (2 if u > 0 else 3))
		if rank < last_rank:
			return "season %s (rank %d) after rank %d: %s" % [sid, rank, last_rank, str(order)]
		last_rank = rank
	return ""


func _wait_built(journal: Node) -> void:
	for _i in 240:
		await process_frame
		if not bool(journal.call("is_building")):
			break
	await process_frame
	await process_frame


## Red cvijeta po tipu; ako sezona još nije učitana, skrola do kraja dok se ne pojavi.
func _find_row(journal: Node, list: Node, type_id: String) -> Node:
	for _round in 4:
		for r in _bloom_rows(list):
			if str(r.call("get_type_id")) == type_id:
				return r
		await _scroll_to_end(journal)
	return null


func _scroll_to_end(journal: Node) -> void:
	var scroll := journal.get_node("RootVBox/ListScroll") as ScrollContainer
	await process_frame
	scroll.scroll_vertical = 1000000
	await process_frame
	await _wait_built(journal)


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
		_quit(1)
		return

	# --- kept_tier=2 ---
	gs.set("discovered_blooms", {"clover": true})
	gs.set("collection_kept_tiers", {"clover": 2})
	gs.set("collection_journal_pending", {})
	var err := change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal load failed %d" % err)
		_quit(1)
		return
	for _w in 3:
		await process_frame
	var journal := current_scene as Control
	if journal != null:
		await _wait_built(journal)
	if journal == null:
		push_error("collection_journal_smoke: journal scene missing")
		_quit(1)
		return
	var list := journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or _bloom_rows(list).is_empty():
		push_error("collection_journal_smoke: journal list empty")
		_quit(1)
		return
	var catalog_msg := _assert_catalog_album(gs, journal, list)
	if not catalog_msg.is_empty():
		push_error("collection_journal_smoke (catalog): %s" % catalog_msg)
		_quit(1)
		return
	var order_msg := _assert_order(gs, journal)
	if not order_msg.is_empty():
		push_error("collection_journal_smoke (order): %s" % order_msg)
		_quit(1)
		return
	var clover_row: Node = await _find_row(journal, list, "clover")
	if clover_row == null or not clover_row.has_method("get_tier_icon"):
		push_error("collection_journal_smoke: first row missing get_tier_icon")
		_quit(1)
		return
	var msg := _assert_clover_tiers(clover_row, 2)
	if not msg.is_empty():
		push_error("collection_journal_smoke (kept=2): %s" % msg)
		_quit(1)
		return

	# --- kept_tier=3: rebuild journal ---
	gs.set("collection_kept_tiers", {"clover": 3})
	err = change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal reload failed %d" % err)
		_quit(1)
		return
	for _w in 3:
		await process_frame
	journal = current_scene as Control
	await _wait_built(journal)
	list = journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or _bloom_rows(list).is_empty():
		push_error("collection_journal_smoke: journal list empty after reload")
		_quit(1)
		return
	clover_row = await _find_row(journal, list, "clover")
	msg = _assert_clover_tiers(clover_row, 3)
	if not msg.is_empty():
		push_error("collection_journal_smoke (kept=3): %s" % msg)
		_quit(1)
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
		_quit(1)
		return
	err = change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	if err != OK:
		push_error("collection_journal_smoke: journal reload after stash failed %d" % err)
		_quit(1)
		return
	for _w in 3:
		await process_frame
	journal = current_scene as Control
	await _wait_built(journal)
	list = journal.get_node_or_null("RootVBox/ListScroll/List") as VBoxContainer
	if list == null or _bloom_rows(list).is_empty():
		push_error("collection_journal_smoke: journal list empty after stash")
		_quit(1)
		return
	clover_row = await _find_row(journal, list, "clover")
	msg = _assert_clover_tiers(clover_row, 3)
	if not msg.is_empty():
		push_error("collection_journal_smoke (stash→T3): %s" % msg)
		_quit(1)
		return

	# Ponovni ulazak s istim podacima NE smije rusiti i graditi prve tri sezone iznova —
	# to je bilo steckanje pri svakom swipeu na Journal.
	journal.call("on_meta_page_left")
	await process_frame
	journal.call("refresh_for_meta_hub")
	await _wait_built(journal)
	var before: Array[int] = []
	for r in _bloom_rows(list):
		before.append(r.get_instance_id())
	journal.call("on_meta_page_left")
	await process_frame
	journal.call("refresh_for_meta_hub")
	await _wait_built(journal)
	var after: Array[int] = []
	for r in _bloom_rows(list):
		after.append(r.get_instance_id())
	if before.size() != 18 or before != after:
		push_error(
			"collection_journal_smoke: revisit rebuilt the list (%d -> %d rows, same ids: %s)"
			% [before.size(), after.size(), str(before == after)]
		)
		_quit(1)
		return

	# Skrol do kraja učitanog → sljedeće tri sezone, pa preostale dvije.
	for want in [6, 8]:
		await _scroll_to_end(journal)
		if int(journal.call("loaded_season_count")) != want:
			push_error("collection_journal_smoke: scroll to end should load %d seasons, got %d" % [want, int(journal.call("loaded_season_count"))])
			_quit(1)
			return
	if _bloom_rows(list).size() != 48:
		push_error("collection_journal_smoke: all seasons loaded should show 48 rows, got %d" % _bloom_rows(list).size())
		_quit(1)
		return
	# Izlazak ostavi prve tri; sljedeći ulazak opet puni po tri.
	journal.call("on_meta_page_left")
	await process_frame
	if int(journal.call("loaded_season_count")) != 3:
		push_error("collection_journal_smoke: leaving should keep 3 seasons, got %d" % int(journal.call("loaded_season_count")))
		_quit(1)
		return

	# Loot Burst (Shop): ★3 ide u stash I u Album (bug Crystal Peony 2026-10-06).
	gs.call("reset_seasons_to_s1")
	gs.set("collection_kept_tiers", {})
	gs.set("collection_journal_pending", {})
	gs.set("garden_crystal_stash", {})
	var burst: Dictionary = gs.get("boosters").call("grant_loot_burst")
	var flower := str(burst.get("flower", ""))
	var kept_burst: Dictionary = gs.get("collection_kept_tiers")
	if flower.is_empty() or int(kept_burst.get(flower, 0)) != 3:
		push_error("collection_journal_smoke: Loot Burst %s should be kept T3 in the Album, got %s" % [flower, str(kept_burst)])
		_quit(1)
		return
	if not (gs.get("collection_journal_pending") as Dictionary).has(flower):
		push_error("collection_journal_smoke: Loot Burst flower should be NEW in the Journal")
		_quit(1)
		return
	# Stari save: ★3 u stashu bez Albuma → popravi se pri učitavanju.
	gs.set("collection_kept_tiers", {})
	gs.set("garden_crystal_stash", {"crystal_peony": 5})
	gs.call("_repair_album_from_stash")
	if int((gs.get("collection_kept_tiers") as Dictionary).get("crystal_peony", 0)) != 3:
		push_error("collection_journal_smoke: stash ★3 without Album should be repaired to T3")
		_quit(1)
		return
	# ★3 potrošen na otključavanje (stash prazan): otključan Lantern znači da je igrač
	# imao Crystal Peony (Frost ★3), a otključan Frost — Pumpkin (CB ★3).
	var unlocked_ids: Array[String] = ["country_bloom", "frost_orchard", "lantern_meadow"]
	gs.set("unlocked_seasons", unlocked_ids)
	gs.set("collection_kept_tiers", {})
	gs.set("garden_crystal_stash", {})
	gs.call("_repair_album_from_stash")
	var repaired: Dictionary = gs.get("collection_kept_tiers")
	if int(repaired.get("crystal_peony", 0)) != 3 or int(repaired.get("pumpkin", 0)) != 3:
		push_error("collection_journal_smoke: unlocked seasons should put the spent ★3 in the Album, got %s" % str(repaired))
		_quit(1)
		return

	print("collection_journal_smoke OK")
	_quit(0)
