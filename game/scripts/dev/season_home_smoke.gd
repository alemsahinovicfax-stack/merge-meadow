extends SceneTree

## SEZ-C — Home Stage + teaser unlock sheet; hub swipe isolation.

const SAVE_PATH := "user://player_save.json"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("season_home_smoke: %s" % msg)
	quit(1)


func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("wallet_coins", 0)
	gs.set("garden_crystal_stash", {})
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)

	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	for _i in 16:
		await process_frame

	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub: Node = hubs[0]
	if hub.has_method("go_to_page"):
		hub.call("go_to_page", MetaHubPages.MAIN, false)
	for _j in 12:
		await process_frame

	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	if swipe == null:
		_fail("SwipePager missing")
		return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("expected Home page")
		return

	var host: Node = swipe.call("get_pages_host") if swipe.has_method("get_pages_host") else null
	var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN) if host else null
	if home == null:
		_fail("Home page missing")
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return
	var title: Label = stage.get_node_or_null("%StageTitle") as Label
	if title == null or title.text.find("Country Bloom") < 0:
		_fail("Stage title expected Country Bloom got '%s'" % (title.text if title else "null"))
		return
	var teaser: Label = stage.get_node_or_null("%TeaserTitle") as Label
	if teaser == null or teaser.text.find("Frost Orchard") < 0:
		_fail("Teaser expected Frost Orchard got '%s'" % (teaser.text if teaser else "null"))
		return

	if stage.has_method("cycle_playable"):
		stage.call("cycle_playable", 1)
	await process_frame
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("hub page changed after cycle_playable")
		return

	var stage_ctrl := stage as Control
	if stage_ctrl and swipe.has_method("should_block_hub_swipe_at"):
		var mid := stage_ctrl.get_global_rect().get_center()
		if not bool(swipe.call("should_block_hub_swipe_at", mid)):
			_fail("Stage rect should block hub swipe")
			return

	gs.set("wallet_coins", 80)
	gs.set("garden_crystal_stash", {"clover": 5})
	if not stage.has_method("open_unlock_sheet"):
		_fail("open_unlock_sheet missing")
		return
	stage.call("open_unlock_sheet", "frost_orchard")
	await process_frame
	var sheet: Node = stage.get_node_or_null("%SeasonUnlockSheet")
	if sheet == null or not bool(sheet.get("visible")):
		_fail("Unlock sheet should be visible")
		return
	var browser: Node = stage.get_node_or_null("%SeasonBrowser")
	if browser and bool(browser.get("visible")):
		_fail("P11: Browser must stay closed on teaser/sheet open")
		return
	if sheet.has_method("_on_unlock_pressed"):
		sheet.call("_on_unlock_pressed")
	for _k in 6:
		await process_frame
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("unlock did not auto-switch active")
		return
	if title.text.find("Frost Orchard") < 0:
		_fail("Stage title after unlock expected Frost Orchard got '%s'" % title.text)
		return
	if teaser.text.find("Lantern Meadow") < 0:
		_fail("Teaser after S2 expected Lantern Meadow got '%s'" % teaser.text)
		return
	if int(swipe.get("current_page")) != MetaHubPages.MAIN:
		_fail("hub page changed after unlock")
		return

	print("season_home_smoke OK")
	quit(0)
