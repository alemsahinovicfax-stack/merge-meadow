extends SceneTree

## Dev: slike za FIX-TEL-2 (2026-11-12) u stvarnom prozoru (omjer telefona).
## BEZ --headless, s APPDATA kopijom:
##   godot --path game --rendering-driver opengl3 --resolution 405x900 -s res://scripts/dev/fix_tel2_capture.gd
## MM_SHOTS = lista dijelova odvojena zarezom (home, wardrobe, sheets, run, arena, journal, camp);
## prazno = sve. PNG ide u $MM_OUT (ili %TEMP%/mm_fix_tel2).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _out := ""
var _gs: Node
var _want: PackedStringArray = []


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _shot(shot: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _on(part: String) -> bool:
	return _want.is_empty() or _want.has(part)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_fix_tel2")
	DirAccess.make_dir_recursive_absolute(_out)
	var shots := OS.get_environment("MM_SHOTS")
	if not shots.is_empty():
		_want = shots.split(",")
	_gs = root.get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("reduce_motion", false)
	if _on("home") or _on("wardrobe") or _on("sheets") or _on("arena") or _on("journal") or _on("camp"):
		await _hub()
	if _on("run"):
		await _run_shots()
	print("fix_tel2_capture OK")
	quit(0)


func _hub() -> void:
	_gs.set("wallet_coins", 8450)
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await create_timer(2.5).timeout
	var hub: Node = current_scene
	var page: Node = hub.find_child("Page_%d" % MetaHubPages.MAIN, true, false)
	var stage: Node = page.get_node_or_null("%SeasonStage") if page else null
	if stage != null and (_on("home") or _on("wardrobe") or _on("sheets")):
		stage.call("open_season_field", str(_gs.get("active_season_id")))
		var tw: Tween = stage.get("_field_tween")
		if tw:
			tw.kill()
		stage.call("_set_u", 1.0)
		stage.call("_on_field_tween_finished")
		await create_timer(1.2).timeout
		if _on("home"):
			await _shot("home_field")
		var menu: Node = page
		if not menu.has_method("_open_wardrobe"):
			menu = page.find_child("MainMenu", true, false)
		if _on("wardrobe") and menu != null:
			menu.call("_open_wardrobe")
			await create_timer(0.2).timeout
			await _shot("wardrobe_opening")
			await create_timer(0.8).timeout
			await _shot("wardrobe_pip")
			var sheet: Node = menu.get("wardrobe_sheet")
			var scroll := sheet.call("grid_scroll") as ScrollContainer
			scroll.scroll_vertical = 300
			await create_timer(0.3).timeout
			await _shot("wardrobe_pip_scrolled")
			for sid in CosmeticCatalog.slot_ids():
				if sid == CosmeticCatalog.SLOT_PIP_SKIN:
					continue
				sheet.call("select_slot", sid)
				await create_timer(0.4).timeout
				await _shot("wardrobe_%s" % sid)
			sheet.call("close", false)
			await _frames(4)
		if _on("sheets") and menu != null:
			menu.call("_open_upgrades_sheet")
			await create_timer(0.7).timeout
			await _shot("sheet_boosts")
			menu.call("_close_upgrades_sheet")
			menu.call("_open_basket_picker")
			await create_timer(0.7).timeout
			await _shot("sheet_basket")
			menu.call("_close_basket_picker")
	if _on("camp"):
		hub.call("go_to_page", MetaHubPages.CAMP, false)
		await create_timer(1.6).timeout
		await _shot("camp")
	if _on("journal"):
		hub.call("go_to_page", MetaHubPages.COLLECTION, false)
		for i in 6:
			await _frames(2)
			await _shot("journal_%d" % i)
		await create_timer(2.0).timeout
		await _shot("journal_done")
		# Skrol do kraja učitanog: sljedeće tri sezone kreću s kosturom „Loading…".
		var jpage: Node = hub.find_child("Page_%d" % MetaHubPages.COLLECTION, true, false)
		var jscroll := jpage.find_child("ListScroll", true, false) as ScrollContainer if jpage else null
		if jscroll != null:
			jscroll.scroll_vertical = 100000
			await _frames(3)
			jscroll.scroll_vertical = 100000
			await _frames(6)
			await _shot("journal_loading_a")
			await _frames(10)
			await _shot("journal_loading_b")
	if _on("arena"):
		hub.call("go_to_page", MetaHubPages.ARENA, false)
		await create_timer(1.6).timeout
		await _shot("arena_gate_below")
		_gs.set("seed_bag", {"clover": 24, "daisy": 16, "buttercup": 12, "tulip": 12, "sunflower": 8})
		get_nodes_in_group("meta_hub")[0].call("refresh_top_bar")
		var arena: Node = hub.find_child("Page_%d" % MetaHubPages.ARENA, true, false)
		if arena != null and arena.has_method("refresh_for_meta_hub"):
			arena.call("refresh_for_meta_hub")
		await create_timer(0.8).timeout
		await _shot("arena_gate_open")
		_gs.set("seed_bag", {"clover": 96, "daisy": 80, "buttercup": 64, "tulip": 40, "sunflower": 24})
		if arena != null and arena.has_method("refresh_for_meta_hub"):
			arena.call("refresh_for_meta_hub")
		await create_timer(0.8).timeout
		await _shot("arena_gate_full")


func _run_shots() -> void:
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	await create_timer(1.5).timeout
	var run: Node = current_scene
	var player := run.get_node("Player") as Area2D
	var world := run.get_node("World") as Node2D
	run.set("_state", 2)
	run.call("_clear_world_entities")
	await _frames(3)
	var lanes: Array = run.get("lane_x_positions")
	var y := player.position.y
	var k := float(run.call("_ui_scale"))
	# Tri staze: predmet tik prije dodira glave (granica kolizije + 4 px).
	var coin := (load("res://scenes/run/coin.tscn") as PackedScene).instantiate() as Node2D
	coin.position = Vector2(float(lanes[1]), y - 104.0)
	world.add_child(coin)
	var ob := (load("res://scenes/run/obstacle.tscn") as PackedScene).instantiate() as Node2D
	ob.position = Vector2(float(lanes[0]), y - 128.0)
	world.add_child(ob)
	var seed := (load("res://scenes/run/seed_pickup.tscn") as PackedScene).instantiate() as Node2D
	seed.position = Vector2(float(lanes[2]), y - 94.0)
	if seed.has_method("setup"):
		seed.call("setup", "clover", 1)
	world.add_child(seed)
	# Pip po redu u svaku stazu, bez tweena.
	for lane in 3:
		player.set("lane_index", lane)
		player.call("_apply_lane", false)
		# Kolizija ne smije okinuti dok slikamo: predmeti su 4 px ispred granice.
		await _frames(6)
		await _shot("run_contact_lane%d" % lane)
	print("ui scale ", k)
	run.call("_clear_world_entities")
	run.set("_state", 0)
	await _frames(2)
	run.call("_on_pause_pressed")
	await create_timer(0.6).timeout
	await _shot("run_pause")
	run.call("_on_keep_running")
	for n in 3:
		await create_timer(0.3).timeout
		await _shot("run_countdown_%d" % (3 - n))
		await create_timer(0.4).timeout
