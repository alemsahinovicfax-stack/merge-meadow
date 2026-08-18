extends SceneTree

## Bug-027 — mid-page host offset must snap back to full page.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("swipe_snap_smoke: hub load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		push_error("swipe_snap_smoke: no meta_hub")
		quit(1)
		return
	var hub: Node = hubs[0]
	var pager: Control = hub.get_node_or_null("RootVBox/SwipePager") as Control
	if pager == null or not pager.has_method("get_pages_host"):
		push_error("swipe_snap_smoke: SwipePager missing")
		quit(1)
		return
	if not pager.has_method("ensure_aligned"):
		push_error("swipe_snap_smoke: ensure_aligned missing")
		quit(1)
		return

	var host: Control = pager.call("get_pages_host") as Control
	if host == null:
		push_error("swipe_snap_smoke: pages host missing")
		quit(1)
		return

	var page_width: float = pager.size.x
	if page_width < 1.0:
		push_error("swipe_snap_smoke: page_width invalid")
		quit(1)
		return

	var current: int = int(pager.get("current_page"))
	var base_x := -float(current) * page_width

	# Simulate interrupted snap: host stuck 40% toward next page.
	host.position.x = base_x - page_width * 0.4
	if absf(host.position.x - base_x) < 1.0:
		push_error("swipe_snap_smoke: failed to set mid offset")
		quit(1)
		return

	pager.call("ensure_aligned", false)
	await process_frame

	var aligned_x: float = host.position.x
	var expected := -float(int(pager.get("current_page"))) * page_width
	if absf(aligned_x - expected) >= 1.0:
		push_error(
			"swipe_snap_smoke: host.x=%.2f expected=%.2f"
			% [aligned_x, expected]
		)
		quit(1)
		return

	# Second path: mid offset + go_to_page same index should re-align.
	host.position.x = expected - page_width * 0.35
	hub.call("go_to_page", current, false)
	await process_frame
	if absf(host.position.x - expected) >= 1.0:
		push_error(
			"swipe_snap_smoke: go_to_page same page did not align (x=%.2f)"
			% host.position.x
		)
		quit(1)
		return

	print("swipe_snap_smoke OK")
	quit(0)
