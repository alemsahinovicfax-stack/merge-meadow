extends SceneTree

## Dev: reference za leveli-endless-cd-brief (balans ciklus 1, 2026-10-21) — run na levelu 1 / 10 /
## 20, Endless na startu / ~3 min / ~7 min (Pip neranjiv, vrijeme ubrzano), zaključan Endless u polju
## i na Level Pathu (toast), pauza i Loot ekran poslije Endlessa. Save se vraća na kraju.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/balance_capture.gd
## JPG ide u $MM_OUT (ili %TEMP%/mm_design/balance/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const FAST := 6.0

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
	_svp.get_texture().get_image().save_jpg(_out.path_join("%s.jpg" % shot), 0.86)
	print("captured ", shot)


func _clear() -> void:
	Engine.time_scale = 1.0
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)


## Run do `target_sec` (igra ubrzana, Pip ne može pasti), pa sačeka kadar u kojem se vidi bar
## `need` prepreka (i par kad `pair`) u gornjem dijelu staze — najviše 40 s igre — pa zamrzne i snimi.
func _run_shot(name: String, season: String, level: int, endless: bool, target_sec: float, pause: bool = false,
		need: int = 1, pair: bool = false) -> Node:
	await _clear()
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", season)
	if endless:
		_gs.call("begin_endless_run")
	else:
		_gs.set("run_level", level)
		_gs.call("begin_campaign_run")
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(30)
	var player := run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	Engine.time_scale = FAST
	while float(run.get("elapsed")) < target_sec and is_instance_valid(run):
		await process_frame
	# Nikad do kraja levela (inače run završi i Level Path dobije skok Pipa).
	var give_up := target_sec + 40.0
	if not endless:
		give_up = minf(give_up, float(_gs.call("get_run_duration")) - 4.0)
	while is_instance_valid(run) and float(run.get("elapsed")) < give_up and not _frame_ok(run, need, pair):
		await process_frame
	Engine.time_scale = 1.0
	if pause:
		run.call("_on_pause_pressed")
		await create_timer(0.5).timeout
	else:
		run.set("_state", 2)
		await _frames(4)
	await _capture(name)
	return run


## Kraj levela: run do kraja (Pip neranjiv), pa kadar s banerom „Time!" i praznom stazom ispred Pipa.
func _finish_shot() -> void:
	await _clear()
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", "frost_orchard")
	_gs.set("run_level", 5)
	_gs.call("begin_campaign_run")
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(30)
	var hit := Callable(run, "_on_player_hit_obstacle")
	if run.get_node("Player").is_connected("hit_obstacle", hit):
		run.get_node("Player").disconnect("hit_obstacle", hit)
	Engine.time_scale = FAST
	while is_instance_valid(run) and int(run.get("_state")) != 1:
		await process_frame
	Engine.time_scale = 1.0
	await create_timer(0.5).timeout
	await _capture("e11_level_end_frost_orchard")
	_gs.set("level_path_hop", {})


func _frame_ok(run: Node, need: int, pair: bool) -> bool:
	var ys: Array[float] = []
	for c in run.get_node("World").get_children():
		if c.is_in_group("obstacle") and c.position.y > 260.0 and c.position.y < 1300.0:
			ys.append(c.position.y)
	if ys.size() < need:
		return false
	if not pair:
		return true
	for i in ys.size():
		for j in range(i + 1, ys.size()):
			if absf(ys[i] - ys[j]) < 1.0:
				return true
	return false


func _home_shots() -> void:
	await _clear()
	_gs.call("set_active_season", "country_bloom")
	_gs.set("run_level", 7)
	_gs.set("level_path_hop", {})
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.set("_known_ready", false)
	home.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	stage.call("show_season", "country_bloom", false)
	await _frames(4)
	stage.call("open_season_field", "country_bloom")
	var tw: Tween = stage.get("_field_tween")
	if tw:
		tw.kill()
	stage.call("_set_u", 1.0)
	stage.call("_on_field_tween_finished")
	stage.get_node("%SeasonField").call("_stop_wander")
	await _frames(6)
	home.call("_on_endless_play_pressed")
	await create_timer(0.45).timeout
	await _capture("e07_field_endless_locked")
	await create_timer(3.2).timeout
	stage.call("_on_play_pressed")
	await create_timer(0.9).timeout
	home.call("_on_endless_play_pressed")
	await create_timer(0.45).timeout
	await _capture("e08_path_endless_locked")
	# Toast nestane, sanduk 5 čeka nagradu (bez pilule „Claim", skok + klimanje).
	await create_timer(3.2).timeout
	await _capture("e12_path_chest_ready")


func _loot_shot() -> void:
	await _clear()
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", "frost_orchard")
	_gs.call("begin_endless_run")
	_gs.call("finish_run", {"frost_snowdrop": 9, "ice_crocus": 7, "winter_camellia": 3, "crystal_peony": 1}, 61, true, 154.0)
	var loot := (load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(loot)
	await create_timer(1.4).timeout
	await _capture("e09_loot_endless")
	_gs.set("run_is_endless", false)


## Kontrola cijena (nije za CD): Shop Looks, Camp kartica sljedeće sezone, sheet nadogradnji —
## da 4-cifrene cijene stanu. Ide u $MM_CHECK (ili isti folder s prefiksom check_).
func _price_shots() -> void:
	var check := OS.get_environment("MM_CHECK")
	var dir := check if not check.is_empty() else _out
	var keep := _out
	_out = dir
	await _clear()
	_gs.call("reset_seasons_to_s1")
	_gs.set("wallet_coins", 1830)
	_gs.set("garden_crystal_stash", {"pumpkin": 9, "clover": 4})
	(_gs.get("cosmetics") as Object).set("owned", {})
	var shop := (load("res://scenes/ui/shop_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(shop)
	await _frames(30)
	shop.call("select_tab", "looks", false)
	await _frames(10)
	await _capture("check_shop_looks")
	await _clear()
	var camp := (load("res://scenes/camp/camp_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(camp)
	await _frames(30)
	await _capture("check_camp_season_link")
	await _clear()
	_gs.set("wallet_coins", 640)
	_gs.set("garden_crystal_stash", {"pumpkin": 2})
	_gs.set("season_upgrades", {"country_bloom": {"magnet": 3, "loot": 1, "twin": 0}})
	_gs.call("apply_active_upgrade_levels")
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.MAIN, false)
	await _frames(10)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var home: Node = host.get_node("Page_%d" % MetaHubPages.MAIN)
	var stage: Node = home.get_node("%SeasonStage")
	stage.call("show_season", "country_bloom", false)
	await _frames(4)
	stage.call("open_season_field", "country_bloom")
	var tw: Tween = stage.get("_field_tween")
	if tw:
		tw.kill()
	stage.call("_set_u", 1.0)
	stage.call("_on_field_tween_finished")
	await _frames(6)
	home.call("_open_upgrades_sheet")
	await create_timer(0.8).timeout
	await _capture("check_upgrades_sheet")
	_out = keep


## RunTelemetry u pravom runu (radi samo bez --headless): level 1 do kraja (ubrzano, Pip neranjiv)
## mora dodati jedan red u user://balance_log.csv. Log se poslije vrati kakav je bio.
func _telemetry_check() -> void:
	await _clear()
	var path := RunTelemetry.PATH
	var before := FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", "country_bloom")
	_gs.set("run_level", 1)
	_gs.call("begin_campaign_run")
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(30)
	var hit := Callable(run, "_on_player_hit_obstacle")
	if run.get_node("Player").is_connected("hit_obstacle", hit):
		run.get_node("Player").disconnect("hit_obstacle", hit)
	Engine.time_scale = 8.0
	while is_instance_valid(run) and int(run.get("_state")) != 1:
		await process_frame
	Engine.time_scale = 1.0
	var after := FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else ""
	var lines := after.strip_edges().split("\n")
	var last := lines[lines.size() - 1].split(",") if not lines.is_empty() else PackedStringArray()
	var head := lines[0].split(",") if not lines.is_empty() else PackedStringArray()
	var ok := lines.size() >= 2 and after.length() > before.length() and last.size() == RunTelemetry.FIELDS.size()
	if ok:
		var row := {}
		for i in head.size():
			row[head[i]] = last[i]
		ok = row.mode == "level" and row.level == "1" and row.end == "finish" and int(row.pickups_collected) > 0 \
			and int(row.coins_spawned) > 0 and float(row.avg_speed) >= 400.0
		print("telemetry row: ", row)
	print("telemetry ", "OK" if ok else "FAIL")
	if before.is_empty():
		DirAccess.remove_absolute(path)
	else:
		FileAccess.open(path, FileAccess.WRITE).store_string(before)


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("balance")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	var unlocked: Array = _gs.get("unlocked_seasons")
	for id in ["frost_orchard", "lantern_meadow", "amber_canopy"]:
		if not unlocked.has(id):
			unlocked.append(id)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	# MM_ONLY=telemetry: samo provjera telemetrije, bez snimaka.
	if OS.get_environment("MM_ONLY") == "telemetry":
		await _telemetry_check()
		await _clear()
		CampSmokeUtil.restore_save(self, _backup)
		quit(0)
		return
	await _run_shot("e01_level01_country_bloom", "country_bloom", 1, false, 20.0)
	await _run_shot("e02_level10_frost_orchard", "frost_orchard", 10, false, 40.0, false, 2)
	await _run_shot("e03_level20_lantern_meadow", "lantern_meadow", 20, false, 70.0, false, 3, true)
	await _run_shot("e04_endless_start_amber", "amber_canopy", 0, true, 10.0)
	await _run_shot("e05_endless_3min_amber", "amber_canopy", 0, true, 185.0, false, 3, true)
	await _run_shot("e06_endless_7min_amber", "amber_canopy", 0, true, 425.0, false, 3, true)
	await _run_shot("e10_pause_endless_amber", "amber_canopy", 0, true, 75.0, true)
	await _finish_shot()
	await _loot_shot()
	await _home_shots()
	await _price_shots()
	await _telemetry_check()
	await _clear()
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
