extends SceneTree

## Dev: renderuje hub u SubViewport 1080 x 1920 i snima PNG za scene iz
## design_handoff_home_v2 (mid, midNext, ready, premium, soon, owned, new, field).
## Pokretanje bez --headless (treba renderer). PNG ide u %TEMP%/mm_design/.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")

var _backup := ""
var _svp: SubViewport
var _out := ""


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	img.save_png(_out.path_join("godot_%s.png" % name))
	print("captured ", name)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	var gs := get_root().get_node("GameState")
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.call("clear_owned_paid_seasons")
	var unlocked: Array = gs.get("unlocked_seasons")
	unlocked.append("frost_orchard")
	gs.call("set_active_season", "frost_orchard")
	gs.call("set_free_strip_focus", "frost_orchard")
	gs.call("set_home_band", "free")
	gs.set("tutorial_complete", true)
	gs.set("wallet_coins", 320)
	gs.set("wallet_diamonds", 12)
	gs.set("seed_bag", {"frost_snowdrop": 340})
	gs.set("garden_crystal_stash", {"crystal_peony": 12})
	gs.set("last_daily_chest_day", "")

	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	var hub: Node = (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _frames(6)
	await _capture("mid")

	stage.call("tap_card", "lantern_meadow")
	await _wait(0.5)
	await _capture("midNext")

	gs.set("wallet_coins", 540)
	gs.set("garden_crystal_stash", {"crystal_peony": 22})
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _frames(6)
	await _capture("ready")

	var lantern: Node = stage.call("get_card", "lantern_meadow")
	lantern.emit_signal("unlock_pressed", "lantern_meadow")
	await _wait(0.12)
	await _capture("unlocking")
	await _wait(0.6)
	await _capture("after")
	gs.call("reset_seasons_to_s1")
	var again: Array = gs.get("unlocked_seasons")
	again.append("frost_orchard")
	gs.call("set_active_season", "frost_orchard")
	gs.call("set_free_strip_focus", "frost_orchard")
	gs.call("set_home_band", "free")
	stage.set("_known_ready", false)

	gs.set("wallet_coins", 320)
	gs.set("garden_crystal_stash", {"crystal_peony": 12})
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	stage.call("tap_card", "moonlit_warren")
	await _wait(3.0)
	await _capture("premium")
	var moon: Node = stage.call("get_card", "moonlit_warren")
	moon.emit_signal("cta_pressed", "moonlit_warren")
	await _wait(0.2)
	await _capture("purchasing")
	await _wait(1.2)
	get_root().get_node("IAPManager").call("reset_purchases_for_dev")
	gs.call("set_active_season", "frost_orchard")
	stage.set("_known_ready", false)
	home.call("refresh_for_meta_hub")
	await _wait(2.8)

	stage.call("tap_card", "ember_fen")
	await _wait(0.5)
	await _capture("soon")

	stage.call("tap_card", "amber_canopy")
	await _wait(0.12)
	await _capture("farTap")

	await _wait(0.4)
	stage.call("tap_card", "frost_orchard")
	await _wait(0.5)
	await _capture("mid_back")

	var owned: Array = gs.get("owned_paid_seasons")
	owned.append("moonlit_warren")
	gs.call("set_active_season", "moonlit_warren")
	gs.call("set_paid_strip_focus", "moonlit_warren")
	gs.call("set_home_band", "paid")
	home.call("refresh_for_meta_hub")
	await _wait(0.4)
	await _capture("owned")

	gs.call("reset_seasons_to_s1")
	gs.call("clear_owned_paid_seasons")
	gs.set("tutorial_complete", false)
	gs.set("wallet_coins", 140)
	gs.set("garden_crystal_stash", {"pumpkin": 3})
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _wait(3.0)
	await _capture("new")

	gs.set("tutorial_complete", true)
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		(gs.get("unlocked_seasons") as Array).append(id)
	gs.call("set_active_season", "amber_canopy")
	gs.call("set_free_strip_focus", "amber_canopy")
	gs.set("wallet_coins", 1240)
	stage.set("_known_ready", false)
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _wait(0.5)
	await _capture("all4")

	gs.set("tutorial_complete", true)
	home.call("refresh_for_meta_hub")
	stage.call("open_season_field", "country_bloom")
	await _wait(1.2)
	await _capture("field")

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
