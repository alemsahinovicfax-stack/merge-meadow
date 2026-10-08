extends SceneTree

## Dev: snima Camp v3 stanja u igri (design_handoff_camp_v3) za poređenje s paketom:
## polje sezone s pločicom nadogradnji (3 reda), sheet nadogradnji (Magnet 2 · Loot 0 ·
## Twin max), vrata Arene ispod 50 (sa i bez modala) i na 50+, Camp Seeds s oznakom.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/camp_v3_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/). Save se vraća na kraju (CampSmokeUtil).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	_svp.get_texture().get_image().save_png(_out.path_join("campv3_%s.png" % shot))
	print("captured ", shot)


func _page(hub: Node, index: int) -> Node:
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	return host.get_node_or_null("Page_%d" % index)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.call("reset_seasons_to_s1")
	_gs.set("wallet_coins", 30)
	var flower := str(_gs.call("star3_type_id_for_season", "country_bloom"))
	_gs.set("garden_crystal_stash", {flower: 3})
	_gs.set("season_upgrades", {"country_bloom": {"magnet": 2, "loot": 0, "twin": 4}})
	_gs.call("apply_active_upgrade_levels")
	_gs.set("seed_bag", {"clover": 13, "daisy": 3, "buttercup": 20})
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var home := _page(hub, MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.call("open_season_field")
	await create_timer(1.3).timeout
	await _capture("01_field_tile")
	home.call("_open_upgrades_sheet")
	await create_timer(0.6).timeout
	await _capture("02_upgrades_sheet")
	home.call("_close_upgrades_sheet")
	await _frames(4)

	hub.call("go_to_page", MetaHubPages.ARENA, false)
	await create_timer(1.0).timeout
	var arena := _page(hub, MetaHubPages.ARENA)
	# Stranica Arene je ili sam kontroler ili ga nosi kao dijete.
	var ctrl: Node = arena
	if ctrl != null and not ctrl.has_method("_on_bag_clicked"):
		ctrl = null
		for n in arena.find_children("*", "", true, false):
			if n.has_method("_on_bag_clicked"):
				ctrl = n
				break
	await _capture("03_arena_gate_short")
	if ctrl != null and ctrl.has_method("_on_bag_clicked"):
		ctrl.call("_on_bag_clicked")
		await create_timer(0.5).timeout
		await _capture("04_arena_gate_modal")
		if ctrl.has_method("_hide_need_more_overlay"):
			ctrl.call("_hide_need_more_overlay")
		_gs.set("seed_bag", {"clover": 13, "daisy": 3, "buttercup": 40})
		if ctrl.has_method("_refresh_bag"):
			ctrl.call("_refresh_bag")
		await create_timer(0.5).timeout
		await _capture("05_arena_gate_open")

	_gs.set("seed_bag", {"clover": 13, "daisy": 3, "buttercup": 4})
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await create_timer(0.8).timeout
	var camp := _page(hub, MetaHubPages.CAMP)
	if camp and camp.has_method("refresh_for_meta_hub"):
		camp.call("refresh_for_meta_hub")
	await _frames(12)
	await _capture("06_camp_seeds")
	camp.call("_on_seed_chip_pressed", "buttercup")
	await _frames(12)
	await _capture("07_camp_seeds_four")

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
