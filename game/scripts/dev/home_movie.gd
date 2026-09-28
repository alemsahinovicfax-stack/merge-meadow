extends SceneTree

## Dev: kratak video Home v3 (Movie Maker, fiksni FPS) — pravi klikovi kroz GUI:
## strelice, swipe, tabovi, Back, Play → livada, Pip hoda, Seasons → kartica.
##   godot --path game --rendering-driver opengl3 --fixed-fps 60 \
##     --write-movie /tmp/mm/frame.png -s scripts/dev/home_movie.gd
## (bez --headless; PNG sekvenca se poslije spoji u video).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""
var _origin := Vector2.ZERO
var V: GDScript


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await _frames(roundi(sec * 60.0))


func _click(page_pos: Vector2) -> void:
	var p := page_pos + _origin
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = p
	down.global_position = p
	get_root().push_input(down, true)
	await _frames(6)
	var up := down.duplicate() as InputEventMouseButton
	up.pressed = false
	get_root().push_input(up, true)
	await _frames(2)


func _drag(from: Vector2, to: Vector2) -> void:
	var a := from + _origin
	var b := to + _origin
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = a
	down.global_position = a
	get_root().push_input(down, true)
	for i in 14:
		await process_frame
		var m := InputEventMouseMotion.new()
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		m.position = a.lerp(b, float(i + 1) / 14.0)
		m.global_position = m.position
		get_root().push_input(m, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = b
	up.global_position = b
	get_root().push_input(up, true)
	await _frames(2)


func _run() -> void:
	V = load("res://scripts/visual/ui_home_v3.gd")
	_backup = CampSmokeUtil.backup_save()
	var gs := get_root().get_node("GameState")
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.call("clear_owned_paid_seasons")
	var unlocked: Array = gs.get("unlocked_seasons")
	unlocked.append("frost_orchard")
	gs.call("set_active_season", "country_bloom")
	gs.call("set_free_strip_focus", "country_bloom")
	gs.call("set_home_band", "free")
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 320)
	gs.set("garden_crystal_stash", {
		"clover": 7, "daisy": 5, "buttercup": 6, "tulip": 3, "sunflower": 2, "pumpkin": 14,
	})
	gs.set("discovered_blooms", {"clover": true, "tulip": true, "pumpkin": true})
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await _frames(20)
	var hub: Node = get_nodes_in_group("meta_hub")[0]
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var home: Control = hub.get_node("RootVBox/SwipePager").call("get_pages_host").get_node("Page_%d" % MetaHubPages.MAIN)
	_origin = home.get_global_rect().position
	home.call("refresh_for_meta_hub")
	await _wait(0.8)

	await _click((V.NEXT_RECT as Rect2).get_center())        # › Frost (otkljucana, kapija)
	await _wait(0.7)
	await _click((V.NEXT_RECT as Rect2).get_center())        # › Lantern (zakljucana, cipovi)
	await _wait(0.7)
	await _drag(Vector2(300, 900), Vector2(600, 900))    # swipe → Frost
	await _wait(0.7)
	await _click((V.TABS_RECT as Rect2).position + Vector2(770, 62))   # Premium
	await _wait(0.9)
	await _click((V.PLAY_CARD["rect"] as Rect2).get_center()) # Back → Country Bloom
	await _wait(0.8)
	await _click((V.PLAY_CARD["rect"] as Rect2).get_center()) # Play → livada
	await _wait(3.2)
	var bottom := home.get_node("%SeasonsRowButton") as Control
	var seasons_center := bottom.get_global_rect().get_center() - _origin
	await _click(seasons_center)                          # Seasons → kartica
	await _wait(1.2)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
