extends SceneTree

## FIX-TEL-3 (2026-11-12) — Home · Level Path i hub:
##  · vodoravan potez prstom preko otvorenog puta mijenja stranicu huba (Home → Camp / Journal);
##  · uspravan potez i dalje skrola put, stranica ostaje Home;
##  · kad igrač ode s Homea, put se ugasi: povratak pokazuje polje (ne put);
##  · kratak tap na putu ne mijenja stranicu.
## Šalje PRAVE InputEventScreenTouch / ScreenDrag kroz viewport (kao touch_scroll_smoke).

var _backup := ""
var _failed := false


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("level_path_swipe_smoke: %s" % msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _touch(pos: Vector2, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.position = pos
	ev.pressed = pressed
	root.push_input(ev, true)


func _drag(from: Vector2, to: Vector2, steps: int = 8) -> void:
	var prev := from
	for i in range(1, steps + 1):
		var p := from.lerp(to, float(i) / float(steps))
		var ev := InputEventScreenDrag.new()
		ev.index = 0
		ev.position = p
		ev.relative = p - prev
		ev.velocity = (p - prev) * 60.0
		root.push_input(ev, true)
		prev = p
		await process_frame


func _swipe(from: Vector2, delta: Vector2) -> void:
	_touch(from, true)
	await process_frame
	await _drag(from, from + delta)
	_touch(from + delta, false)
	await create_timer(0.9).timeout


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("level_path_swipe_smoke OK")
	quit(1 if _failed else 0)


func _run() -> void:
	var gs: Node = root.get_node("GameState")
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.call("reset_seasons_to_s1")
	gs.call("set_active_season", "country_bloom")
	gs.set("level_path_hop", {})
	if change_scene_to_file("res://scenes/meta/meta_hub.tscn") != OK:
		_fail("hub load failed")
		_finish()
		return
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(8)
	var pager: Control = hub.get_node("RootVBox/SwipePager")
	var host: Node = pager.call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	if not bool(stage.call("open_season_field", "country_bloom", false)):
		_fail("field did not open")
		_finish()
		return
	await _frames(4)
	if not bool(stage.call("open_level_path", false)):
		_fail("level path did not open")
		_finish()
		return
	await _frames(6)
	var rect := pager.get_global_rect()
	var mid := rect.get_center()
	var path: Node = stage.get("level_path")

	# 1 · kratak tap: stranica ostaje Home, put otvoren.
	_touch(mid, true)
	await process_frame
	_touch(mid, false)
	await create_timer(0.5).timeout
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN or not bool(gs.get("level_path_open")):
		_fail("a tap on the path must not change the page or close the path")

	# 2 · uspravan potez: put skrola, stranica ostaje Home.
	var scroll_before := float(path.call("get_scroll"))
	await _swipe(mid, Vector2(0.0, 260.0))
	var scroll_after := float(path.call("get_scroll"))
	if int(hub.call("current_page_index")) != MetaHubPages.MAIN:
		_fail("a vertical drag on the path must not change the hub page")
	await _swipe(mid, Vector2(0.0, -260.0))
	var scroll_back := float(path.call("get_scroll"))
	if is_equal_approx(scroll_before, scroll_after) and is_equal_approx(scroll_after, scroll_back):
		_fail("the path should still scroll vertically (scroll stayed %.1f)" % scroll_before)

	# 3 · vodoravan potez ulijevo: Home → Camp.
	await _swipe(mid + Vector2(rect.size.x * 0.25, 0.0), Vector2(-rect.size.x * 0.55, 0.0))
	if int(hub.call("current_page_index")) != MetaHubPages.CAMP:
		_fail("a left swipe on the open path should go to Camp, page is %d" % int(hub.call("current_page_index")))
	# Put se gasi kad Home izađe iz vida.
	await create_timer(0.6).timeout
	if bool(gs.get("level_path_open")) or bool(stage.call("is_level_path_open")):
		_fail("leaving Home must close the level path")
	if not bool(gs.get("home_season_field_open")):
		_fail("leaving Home must keep the season field open")

	# 4 · povratak na Home: polje, ne put.
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	if bool(gs.get("level_path_open")) or (path as CanvasItem).visible:
		_fail("back on Home the field should show, not the path")
	var field: CanvasItem = stage.get("season_field")
	if field == null or not field.visible:
		_fail("back on Home the season field must be visible")

	# 5 · vodoravan potez udesno s puta: Home → Journal.
	stage.call("open_level_path", false)
	await _frames(6)
	await _swipe(mid - Vector2(rect.size.x * 0.25, 0.0), Vector2(rect.size.x * 0.55, 0.0))
	if int(hub.call("current_page_index")) != MetaHubPages.COLLECTION:
		_fail("a right swipe on the open path should go to Journal, page is %d" % int(hub.call("current_page_index")))
	await create_timer(0.6).timeout
	if bool(gs.get("level_path_open")):
		_fail("leaving Home to Journal must close the level path")

	# 6 · brz povratak (prije nego što Home izađe iz vida) ne gasi put.
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(8)
	stage.call("open_level_path", false)
	await _frames(6)
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(2)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await create_timer(0.7).timeout
	if not bool(gs.get("level_path_open")):
		_fail("coming straight back to Home should keep the path open")
	_finish()
