extends SceneTree

## Bug-010 — arena session locks hub nav. Done dugmeta vise nema (2026-09-24):
## lock pada sam kad polje ostane prazno (sve spojeno ili pojedeno).


const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _field_chips(arena: Node) -> Array:
	var out: Array = []
	var playfield := arena.get_node_or_null("RootVBox/Playfield")
	if playfield == null:
		return out
	for child in playfield.get_children():
		if "pulse_highlight" in child and "type_id" in child and not child.is_queued_for_deletion():
			out.append(child)
	return out


func _run() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("arena_nav_lock_smoke: hub load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		push_error("arena_nav_lock_smoke: no meta_hub")
		quit(1)
		return
	var hub: Node = hubs[0]
	var gs := _gs()
	if gs == null:
		push_error("arena_nav_lock_smoke: GameState missing")
		quit(1)
		return
	gs.set("seed_bag", {"clover": 6, "daisy": 4})
	gs.set("wallet_coins", 10)
	if hub.has_method("go_to_page"):
		hub.go_to_page(MetaHubPages.ARENA, false)
	for _j in 10:
		await process_frame
	var host: Node = null
	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	if swipe and swipe.has_method("get_pages_host"):
		host = swipe.get_pages_host()
	var arena: Node = host.get_node_or_null("Page_%d" % MetaHubPages.ARENA) if host else null
	if arena == null:
		push_error("arena_nav_lock_smoke: arena page missing")
		quit(1)
		return
	if arena.has_method("set_arena_page_active"):
		arena.call("set_arena_page_active", true)
	# Pour seeds onto field via controller API path.
	if arena.has_method("_on_bag_clicked"):
		arena.call("_on_bag_clicked")
	for _k in 8:
		await process_frame
	var locked := false
	if hub.has_method("is_nav_locked"):
		locked = bool(hub.call("is_nav_locked"))
	elif swipe and swipe.has_method("is_swipe_enabled"):
		locked = not bool(swipe.call("is_swipe_enabled"))
	if not locked:
		push_error("arena_nav_lock_smoke: expected hub nav locked after pour")
		quit(1)
		return
	var pill := hub.get_node_or_null("RootVBox/PageIndicator/NavPanel/Content/NavLockPill") as Control
	if pill == null or not pill.visible:
		push_error("arena_nav_lock_smoke: NavLockPill should show while nav locked")
		quit(1)
		return
	# Tabs must not switch away while locked.
	var page_before := MetaHubPages.ARENA
	if hub.has_method("go_to_page"):
		hub.go_to_page(MetaHubPages.CAMP, false)
	for _m in 4:
		await process_frame
	if swipe and "current_page" in swipe:
		if int(swipe.get("current_page")) != page_before:
			push_error("arena_nav_lock_smoke: page changed while nav locked")
			quit(1)
			return
	# Muncher pojede polje do kraja — sesija se mora zatvoriti sama, bez Done dugmeta.
	var guard := 0
	while guard < 60:
		var chips: Array = _field_chips(arena)
		if chips.is_empty():
			break
		arena.call("_pest_eat_chip", chips[0])
		guard += 1
		for _e in 2:
			await process_frame
	# Vacuum let traje ~0,4 s; sesija se gasi tek kad sjemenke slete u vrecu.
	await create_timer(1.2).timeout
	if not _field_chips(arena).is_empty():
		push_error("arena_nav_lock_smoke: field should be empty after the muncher clears it")
		quit(1)
		return
	if bool(arena.call("is_session_open")):
		push_error("arena_nav_lock_smoke: empty field must close the session")
		quit(1)
		return
	if hub.has_method("is_nav_locked") and bool(hub.call("is_nav_locked")):
		push_error("arena_nav_lock_smoke: hub should unlock itself once the field is empty")
		quit(1)
		return
	if pill.visible:
		push_error("arena_nav_lock_smoke: NavLockPill should hide with the session")
		quit(1)
		return
	print("arena_nav_lock_smoke OK")
	quit(0)
