extends SceneTree

## Dev: sirovi kadrovi za Play Store (store-assets-cd-brief) — 1080 x 1920 PNG, bez dev teksta:
##   run u 4 sezone (usred akcije), Endless novi rekord, loot, Arena merge + combo, Home polje,
##   Level Path, Camp, Journal, Shop teme, Ormar. Pip neranjiv, vrijeme ubrzano do kadra.
## Save se vraća na kraju. Pokretanje BEZ --headless (APPDATA kopija):
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/store_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/store/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const FAST := 6.0
const SEED_BAG := {"clover": 18, "daisy": 16, "buttercup": 12, "tulip": 14, "sunflower": 10}

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
	_svp.get_texture().get_image().save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _clear() -> void:
	Engine.time_scale = 1.0
	for c in _svp.get_children():
		c.queue_free()
	await _frames(3)


func _rich_state() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("reduce_motion", false)
	_gs.set("wallet_coins", 8450)
	_gs.set("seed_bag", SEED_BAG.duplicate())
	_gs.set("seed_unlock_index", 4)
	var discovered: Dictionary = _gs.get("discovered_blooms")
	for type_id in SEED_BAG:
		discovered[str(type_id)] = true
	_gs.set("discovered_blooms", discovered)
	var unlocked: Array = _gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	_gs.set("unlocked_seasons", unlocked)
	_gs.call("clear_owned_paid_seasons")
	_gs.call("grant_paid_season", "moonlit_warren")
	_gs.call("grant_paid_season", "starfall_glade")
	var lp = _gs.get("level_path_domain")
	for id in ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy", "moonlit_warren", "starfall_glade"]:
		lp.set_level(id, 12)
	lp.claimed["country_bloom"] = [5, 10]
	var cs = _gs.get("crystal_stash_domain")
	for id in ["country_bloom", "starfall_glade", "moonlit_warren"]:
		for t in _gs.call("star3_type_ids_for_season", id):
			cs.grown[str(t)] = 60
		var def: SeasonDef = _gs.call("get_season_def", id)
		for t in def.seed_type_ids:
			cs.grown[str(t)] = 60
	for t in _gs.call("star3_type_ids_for_season", "country_bloom"):
		cs.stash[str(t)] = 12
	_gs.call("mark_arena_pest_tutorial_shown")


func _start_run(season: String, level: int) -> Node:
	await _clear()
	_gs.call("set_active_season", season)
	if level == 0:
		_gs.call("begin_endless_run")
	else:
		_gs.set("run_level", level)
		_gs.call("begin_campaign_run")
	var run := (load("res://scenes/run/run_scene.tscn") as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(2)
	var player := run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	return run


func _fast_to(run: Node, sec: float) -> void:
	Engine.time_scale = FAST
	while is_instance_valid(run) and float(run.get("elapsed")) < sec and int(run.get("_state")) == 0:
		await process_frame
	Engine.time_scale = 1.0


## Plijen na stazi: coin niz u jednoj stazi, sjeme ★1–★3 u drugim, ispred Pipa (stvarni pickupi).
func _stage_pickups(run: Node, coins: int, seeds: Dictionary) -> void:
	var world := run.get_node("World")
	for c in world.get_children():
		if not c.is_in_group("obstacle"):
			c.free()
	var lanes: Array = run.get("lane_x_positions")
	var types: Array = _gs.call("get_active_season_spawn_types")
	var by_r := {}
	for t in types:
		by_r[int(_gs.call("get_seed_rarity", t))] = str(t)
	var player: Node2D = run.get_node("Player")
	var lane_pip := 0
	for i in lanes.size():
		if absf(float(lanes[i]) - player.position.x) < absf(float(lanes[lane_pip]) - player.position.x):
			lane_pip = i
	var side := (lane_pip + 1) % 3
	var other := (lane_pip + 2) % 3
	for k in 6:
		var coin: Node2D = (run.get("_coin_scene") as PackedScene).instantiate()
		coin.position = Vector2(float(lanes[lane_pip]), player.position.y - 260.0 - 150.0 * k)
		world.add_child(coin)
	var plan := [[side, 1, 620.0], [side, 2, 1000.0], [other, 3, 760.0], [other, 1, 420.0], [side, 1, 300.0]]
	for it in plan:
		var sp: Node2D = (run.get("_seed_scene") as PackedScene).instantiate()
		sp.call("setup", str(by_r.get(int(it[1]), types[0])), int(it[1]))
		sp.position = Vector2(float(lanes[int(it[0])]), float(it[2]))
		world.add_child(sp)
	run.set("coin_count", coins)
	run.set("seeds_by_type", seeds)
	run.call("_update_hud")


func _run_shot(season: String, level: int, at: float, shot: String) -> void:
	var run := await _start_run(season, level)
	await _fast_to(run, at)
	run.set("_state", 2)
	var types: Array = _gs.call("get_active_season_spawn_types")
	await _frames(2)
	_stage_pickups(run, 74 + level * 3, {str(types[0]): 9, str(types[1]): 4})
	await _frames(12)
	await _capture(shot)


func _run_shots() -> void:
	await _run_shot("country_bloom", 8, 18.0, "s01_run_country_bloom")
	await _run_shot("starfall_glade", 12, 30.0, "s02_run_starfall_glade")
	await _run_shot("frost_orchard", 14, 24.0, "s03_run_frost_orchard")
	await _run_shot("moonlit_warren", 10, 22.0, "s04_run_moonlit_warren")
	# Endless: novi rekord (Amber Canopy, rekord 4:25).
	var lp = _gs.get("level_path_domain")
	lp.set_level("amber_canopy", 16)
	lp.endless_best["amber_canopy"] = 265.0
	var run := await _start_run("amber_canopy", 0)
	run.set("elapsed", 262.0)
	await _fast_to(run, 264.6)
	await create_timer(0.62).timeout
	run.set("_state", 2)
	await _capture("s05_endless_new_best_amber")


func _loot_shot() -> void:
	await _clear()
	_gs.call("set_active_season", "country_bloom")
	_gs.set("run_is_endless", false)
	_gs.call("finish_run", {"clover": 14, "daisy": 9, "tulip": 4, "sunflower": 2}, 186, false, 75.0)
	var loot := (load("res://scenes/ui/loot_screen.tscn") as PackedScene).instantiate()
	_svp.add_child(loot)
	await create_timer(1.6).timeout
	await _capture("s06_loot_country_bloom")


func _hub(page: int) -> Array:
	await _clear()
	_gs.call("set_active_season", "country_bloom")
	_gs.set("level_path_hop", {})
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(40)
	hub.call("go_to_page", page, false)
	await _frames(20)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var node: Node = host.get_node("Page_%d" % page)
	if node.has_method("refresh_for_meta_hub"):
		node.call("refresh_for_meta_hub")
	hub.call("refresh_top_bar")
	await _frames(10)
	return [hub, node]


func _hub_shots() -> void:
	# Home: kartica sezone, pa otvoreno polje, pa Level Path.
	var h: Array = await _hub(MetaHubPages.MAIN)
	var stage: Node = (h[1] as Node).get_node("%SeasonStage")
	stage.call("refresh")
	stage.call("show_season", "country_bloom", false)
	await _frames(10)
	await _capture("s07_home_country_bloom")
	stage.call("show_season", "starfall_glade", false)
	await _frames(10)
	await _capture("s08_home_starfall_glade")
	stage.call("show_season", "country_bloom", false)
	await _frames(4)
	stage.call("open_season_field", "country_bloom")
	var tw: Tween = stage.get("_field_tween")
	if tw:
		tw.kill()
	stage.call("_set_u", 1.0)
	stage.call("_on_field_tween_finished")
	await create_timer(1.2).timeout
	await _capture("s09_field_country_bloom")
	stage.call("_on_play_pressed")
	await create_timer(1.2).timeout
	await _capture("s10_level_path_country_bloom")
	# Arena: puno polje u tri tiera, potez usred merga, pa combo.
	h = await _hub(MetaHubPages.ARENA)
	var arena: Node = h[1]
	arena.call("_on_bag_clicked")
	await create_timer(1.6).timeout
	var chips: Array = arena.get("_chips")
	var data: Dictionary = arena.get("_chip_data")
	for i in chips.size():
		var chip: Node = chips[i]
		var tier := 1
		if i % 5 == 1 or i % 7 == 3:
			tier = 2
		elif i % 9 == 4:
			tier = 3
		var kinds := ["clover", "daisy", "buttercup", "tulip", "sunflower"]
		var kind: String = kinds[(i * 3) % kinds.size()]
		chip.set("type_id", kind)
		data[int(chip.get("chip_id"))]["type_id"] = kind
		chip.call("set_tier", tier)
		chip.call("_redraw")
		data[int(chip.get("chip_id"))]["tier"] = tier
	await create_timer(0.8).timeout
	await _capture("s11_arena_full")
	var held: Control = null
	var partner: Control = null
	for a in chips:
		for b in chips:
			var bx: float = (b as Control).global_position.x
			if a != b and a.get("type_id") == b.get("type_id") and int(a.get("tier")) == 2 and int(b.get("tier")) == 2 and bx > 200.0 and bx < 700.0:
				held = a
				partner = b
				break
		if held:
			break
	if held:
		held.call("_begin_drag", held.size * 0.5)
		held.global_position = partner.global_position + Vector2(95, -70)
		await create_timer(0.5).timeout
		await _capture("s12_arena_merge_drag")
	for _i in 5:
		arena.call("register_arena_combo_merge", Vector2(540, 900))
	await _frames(8)
	await _capture("s13_arena_combo")
	# Camp, Journal, Shop.
	_gs.set("seed_bag", SEED_BAG.duplicate())
	h = await _hub(MetaHubPages.CAMP)
	await create_timer(0.8).timeout
	await _capture("s14_camp")
	h = await _hub(MetaHubPages.COLLECTION)
	await create_timer(0.8).timeout
	await _capture("s15_journal")
	h = await _hub(MetaHubPages.SHOP)
	await create_timer(0.8).timeout
	await _capture("s16_shop_seasons")
	(h[1] as Node).call("select_tab", "looks", false)
	await create_timer(0.6).timeout
	await _capture("s17_shop_looks")


func _run() -> void:
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("store")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_rich_state()
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	await _run_shots()
	await _loot_shot()
	await _hub_shots()
	await _clear()
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
