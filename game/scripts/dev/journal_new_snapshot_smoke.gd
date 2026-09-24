extends SceneTree

## HOME journal handoff — NEW ostaje na redu cijelu posjetu, tab se briše na
## otvaranje, a odlazak sa stranice gasi NEW.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("journal_new_snapshot_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _row(journal: Node) -> Node:
	var list := journal.get_node_or_null("%List")
	if list == null:
		return null
	return _find_row(list)


func _find_row(n: Node) -> Node:
	for child in n.get_children():
		if child.has_method("get_tier_icon"):
			return child
		var found := _find_row(child)
		if found:
			return found
	return null


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node_or_null("GameState")
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.set("discovered_blooms", {"clover": true})
	gs.set("collection_kept_tiers", {})
	gs.set("collection_journal_pending", {"clover": 1})
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		return
	await _frames(16)
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("hub missing")
		return
	var hub: Node = hubs[0]
	hub.call("go_to_page", MetaHubPages.COLLECTION, false)
	await _frames(20)
	if int(gs.call("count_collection_journal_news")) != 0:
		_fail("opening Journal must clear the tab badge")
		return
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var journal: Node = host.get_node_or_null("Page_%d" % MetaHubPages.COLLECTION)
	var row := _row(journal) if journal else null
	if row == null or not bool(row.call("is_new_visible")):
		_fail("NEW badge must stay visible after the Journal opens")
		return
	if str(row.call("get_caption_text")) != "New discovery!":
		_fail("NEW caption expected, got '%s'" % str(row.call("get_caption_text")))
		return
	if absf((row as Control).custom_minimum_size.y - 200.0) > 0.5:
		_fail("row height expected 200")
		return
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(8)
	if bool(row.call("is_new_visible")):
		_fail("leaving Journal must hide NEW")
		return
	hub.call("go_to_page", MetaHubPages.COLLECTION, false)
	await _frames(20)
	row = _row(journal)
	if row == null or bool(row.call("is_new_visible")):
		_fail("a later visit must not replay NEW")
		return
	var summary := journal.get_node_or_null("%SummaryLabel") as Label
	if summary == null or summary.text.find("kept") < 0:
		_fail("summary missing")
		return
	CampSmokeUtil.restore_save(self, _backup)
	print("journal_new_snapshot_smoke OK")
	quit(0)
