extends SceneTree

## Bug-010 — arena session locks hub nav; Done unlocks.


const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


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
	if arena.has_method("_on_done_pressed"):
		arena.call("_on_done_pressed")
	for _n in 8:
		await process_frame
	if hub.has_method("is_nav_locked") and bool(hub.call("is_nav_locked")):
		push_error("arena_nav_lock_smoke: hub still locked after Done")
		quit(1)
		return
	print("arena_nav_lock_smoke OK")
	quit(0)
