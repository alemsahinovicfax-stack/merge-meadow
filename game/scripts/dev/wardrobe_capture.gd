extends SceneTree

## Dev: renderuje hub u SubViewport 1080 x 1920 i snima PNG stanja Ormara
## (design_handoff_wardrobe · Specs §8.1): polje s pločicom Looks, sheet po slotu,
## prazno stanje, toast, 8 slotova (demo katalog), ApplyMoment. Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/wardrobe_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const DEMO := preload("res://scripts/dev/wardrobe_demo_catalog.gd")

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node
var _hub: Node
var _home: Node
var _stage: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	img.save_png(_out.path_join("wardrobe_%s.png" % shot))
	print("captured ", shot)


func _base_state(season: String) -> void:
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("reset_seasons_to_s1")
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "moonlit_warren"]:
		if not unlocked.has(id):
			unlocked.append(id)
	_gs.call("set_active_season", season)
	_gs.set("tutorial_complete", true)
	_gs.set("wallet_coins", 1250)
	var cos: Cosmetics = _gs.get("cosmetics")
	cos.owned = {"pip_blossom": true, "meadow_sunset": true, "meadow_lavender": true, "journal_gold": true}
	cos.equipped = {"meadow_bg": "meadow_sunset", "journal_frame": "journal_gold"}
	cos.wardrobe_seen = 1
	var stash := {}
	var def: SeasonDef = _gs.call("get_season_def", season)
	for t in def.seed_type_ids:
		stash[t] = 6
	_gs.set("garden_crystal_stash", stash)


## Bez statičkog tipa: -s skripta se kompajlira prije autoloada (GameState).
func _wardrobe() -> Node:
	return _home.get("wardrobe_sheet") as Node


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_base_state("country_bloom")

	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	_hub = (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(_hub)
	await _frames(30)
	_hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = _hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	_home = host.get_node("Page_%d" % MetaHubPages.MAIN)
	_stage = _home.get_node("%SeasonStage")
	_home.call("refresh_for_meta_hub")
	_stage.call("open_season_field", "country_bloom", false)
	await _frames(20)
	var field := _stage.get_node("%SeasonField")
	field.call("_stop_wander")
	field.call("_place_pip_home")
	await _frames(4)
	await _capture("01_field_country")

	var w := _wardrobe()
	w.call("open", "country_bloom", false)
	await _frames(6)
	await _capture("02_sheet_pip")
	w.call("select_slot", "meadow_bg")
	await _frames(4)
	await _capture("03_sheet_meadow")
	w.call("select_slot", "journal_frame")
	await _frames(4)
	await _capture("04_sheet_album")
	w.call("select_slot", "pip_skin")
	w.call("pick", "pip_skin", "pip_blossom")
	await _frames(20)
	await _capture("05_sheet_pick_blossom")
	w.call("close", false)
	await _frames(4)
	(_stage.get_node("%SeasonField").get_node("MeadowPip") as Control).set("_hop_k", 0.5)
	(_stage.get_node("%SeasonField").get_node("MeadowPip") as Control).set("_ring_a", 0.7)
	(_stage.get_node("%SeasonField").get_node("MeadowPip") as Control).set("_ring_r", 150.0)
	(_stage.get_node("%SeasonField").get_node("MeadowPip") as Control).queue_redraw()
	await _frames(2)
	await _capture("06_apply_hop")
	await create_timer(1.0).timeout
	await _capture("07_field_blossom")

	# Prazno stanje
	var cos: Cosmetics = _gs.get("cosmetics")
	cos.owned = {}
	cos.equipped = {}
	w.call("open", "country_bloom", false)
	await _frames(6)
	await _capture("08_sheet_empty")
	w.call("close", false)
	await _frames(4)

	# Toast (slot koji se ne vidi na polju)
	cos.owned = {"meadow_sunset": true}
	w.call("open", "country_bloom", false)
	w.call("select_slot", "meadow_bg")
	w.call("pick", "meadow_bg", "meadow_sunset")
	w.call("close", false)
	await _frames(20)
	await _capture("09_toast")

	# Proširenje: 8 slotova, 12 Pip skinova (demo katalog), jedan pod velom, jedan New.
	CosmeticCatalog.load_from_dict(DEMO.catalog())
	cos.owned = DEMO.owned()
	cos.equipped = {}
	cos.wardrobe_seen = 1
	w.call("open", "country_bloom", false)
	w.call("select_slot", "pip_skin")
	await _frames(6)
	await _capture("10_extra_pip")
	(w.call("grid_scroll") as ScrollContainer).scroll_vertical = 400
	await _frames(4)
	await _capture("10b_extra_pip_scrolled")
	w.call("select_slot", "combo_ring")
	await _frames(4)
	await _capture("11_extra_last_tab")
	w.call("close", false)
	CosmeticCatalog.reload()

	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
