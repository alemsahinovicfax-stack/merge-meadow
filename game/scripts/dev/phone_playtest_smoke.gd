extends SceneTree

## Phone playtest (2026-11): tall-screen stretch, run bunny atlas, hub chrome after
## Arena „Play a run", and the Play hint only on a real Play button.
##   godot --headless --path game -s res://scripts/dev/phone_playtest_smoke.gd

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _run() -> void:
	var design := Vector2i(1080, 1920)
	if not SafeAreaHelper.wants_expand(Vector2i(1080, 2400), design):
		_fail("a 20:9 phone should expand past the 16:9 design")
		return
	if not SafeAreaHelper.wants_expand(Vector2i(1080, 2340), design):
		_fail("a 19.5:9 phone should expand past the 16:9 design")
		return
	if SafeAreaHelper.wants_expand(Vector2i(1080, 1920), design):
		_fail("16:9 must keep the design viewport")
		return
	if SafeAreaHelper.wants_expand(Vector2i(1920, 1920), design) or SafeAreaHelper.wants_expand(Vector2i(0, 0), design):
		_fail("a wider or headless window must not expand the viewport")
		return
	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	if preset.is_empty() or preset.contains("screen/edge_to_edge=false"):
		_fail("Android export must be edge-to-edge (target SDK 36 letterboxes otherwise)")
		return
	if not preset.contains("screen/edge_to_edge=true"):
		_fail("Android export is missing edge_to_edge")
		return
	if RewardTray.STAMP_PAD_L < 32.0:
		_fail("Kept half pill still starts inside the round cap")
		return

	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		_fail("run scene failed to load")
		return
	for _i in 45:
		await process_frame
	var pip := root.find_child("PipVisual", true, false)
	var actor := pip.get_node_or_null("Actor") if pip else null
	if actor == null or not _has_textured_sprite(actor):
		_fail("run bunny has no textured sprite (only the magnet ring would show)")
		return

	var gs := root.get_node("GameState")
	gs.tutorial_complete = false
	gs.home_season_field_open = false
	gs.meta_hub_pending_page = 2
	err = change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub failed to load")
		return
	for _i in 8:
		await process_frame
	var home := root.find_child("Page_2", true, false)
	var hint := home.get_node_or_null("%StageHint") if home else null
	if hint == null or not hint.visible:
		_fail("first session on the active season should show Tap Play")
		return
	var stage := home.get_node_or_null("%SeasonStage")
	stage.call("show_season", "moonlit_warren", false)
	home.call("refresh_play_chip")
	await process_frame
	if hint.visible:
		_fail("Tap Play hint must hide on a locked theme (Moonlit Warren)")
		return
	stage.call("show_season", "country_bloom", false)
	home.call("refresh_play_chip")
	await process_frame
	if not hint.visible:
		_fail("Tap Play hint should return on Country Bloom")
		return

	gs.tutorial_complete = true
	gs.home_season_field_open = true
	gs.home_season_field_id = "country_bloom"
	gs.meta_hub_pending_page = 4
	err = change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub reload failed")
		return
	for _i in 8:
		await process_frame
	var hub := root.find_child("MetaHub", true, false)
	if hub == null:
		_fail("hub node missing")
		return
	hub.call("go_to_page", 3, false)
	await process_frame
	await process_frame
	hub.call("go_to_page", 4, false)
	await process_frame
	await process_frame
	hub.call("go_to_page", 2, false)
	for _i in 6:
		await process_frame
	if not _chrome_ok("after Camp → Arena → Home"):
		return

	var arena := root.find_child("Page_4", true, false)
	if arena == null:
		_fail("arena page missing")
		return
	arena.set("_gate_play_run", true)
	arena.call("_on_back_to_camp_pressed")
	for _i in 8:
		await process_frame
	if root.find_child("MetaHub", true, false) == null:
		_fail("Play a run left the hub (standalone Home has no header or nav)")
		return
	if int(hub.call("current_page_index")) != 2:
		_fail("Play a run should land on the Home tab, got %d" % int(hub.call("current_page_index")))
		return
	if not _chrome_ok("after Play a run"):
		return

	CampSmokeUtil.restore_save(self, _backup)
	print("phone_playtest_smoke OK")
	quit(0)


func _chrome_ok(where: String) -> bool:
	var top := root.find_child("TopBar", true, false) as Control
	var foot := root.find_child("PageIndicator", true, false) as Control
	var page := root.find_child("Page_2", true, false) as Control
	var view := root.get_viewport().get_visible_rect().size
	if top == null or foot == null or page == null or not top.visible or not foot.visible:
		_fail("%s: header or nav missing" % where)
		return false
	var tg := top.get_global_rect()
	var fg := foot.get_global_rect()
	var pg := page.get_global_rect()
	if tg.size.y < 100.0 or tg.position.y > 2.0:
		_fail("%s: header not at the top (%s)" % [where, tg])
		return false
	if fg.size.y < 100.0 or fg.end.y < view.y - 2.0:
		_fail("%s: nav not at the bottom (%s view %s)" % [where, fg, view])
		return false
	if pg.position.y < tg.end.y - 2.0 or pg.end.y > fg.position.y + 2.0:
		_fail("%s: Home page covers chrome (page %s header %s nav %s)" % [where, pg, tg, fg])
		return false
	return true


func _has_textured_sprite(n: Node) -> bool:
	if n is Sprite2D:
		var s := n as Sprite2D
		if s.texture != null and s.texture.get_width() > 8:
			return true
	for c in n.get_children():
		if _has_textured_sprite(c):
			return true
	return false


func _fail(msg: String) -> void:
	push_error("phone_playtest_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)
