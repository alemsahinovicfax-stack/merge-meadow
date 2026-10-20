extends SceneTree

## Dev: snimke za izvještaj paketa design_handoff_run_pickups — (A) pickupi na stazi i kadrovi
## dodira, (B) Camp kartice plaćenih sezona u stanjima price / buying / failed.
## BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_pickups_capture.gd
## PNG ide u $MM_OUT (ili %TEMP%/mm_design/pickups/).

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const PAID := ["moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]

var _backup := ""
var _svp: SubViewport
var _out := ""
var _gs: Node


func _initialize() -> void:
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _capture(shot: String, crop: Rect2i = Rect2i()) -> void:
	await RenderingServer.frame_post_draw
	var img := _svp.get_texture().get_image()
	if crop.size.x > 0:
		img = img.get_region(crop)
	img.save_png(_out.path_join("%s.png" % shot))
	print("captured ", shot)


func _run() -> void:
	_backup = CampSmokeUtil.backup_save()
	_out = OS.get_environment("MM_OUT")
	if _out.is_empty():
		_out = OS.get_environment("TEMP").path_join("mm_design").path_join("pickups")
	DirAccess.make_dir_recursive_absolute(_out)
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	for season in ["country_bloom", "starfall_glade"]:
		await _run_shots(season)
	await _camp_shots()
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _run_shots(season: String) -> void:
	_gs.set("active_season_id", season)
	_gs.call("begin_campaign_run")
	var run := (load(RUN_SCENE) as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	var player: Node2D = run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	run.set_process(false)
	for c in run.get_node("World").get_children():
		c.free()
	var lanes: Array = run.get("lane_x_positions")
	var types: Array = _gs.call("get_active_season_spawn_types")
	var by_r := {}
	for t in types:
		by_r[int(_gs.call("get_seed_rarity", t))] = str(t)
	# Idle: coin, ★1, ★2, ★3 po stazama.
	var row := 0
	for item in [["coin", 0], ["seed", 1], ["seed", 2], ["seed", 3]]:
		var p: Node2D
		if item[0] == "coin":
			p = (run.get("_coin_scene") as PackedScene).instantiate()
		else:
			p = (run.get("_seed_scene") as PackedScene).instantiate()
			p.call("setup", str(by_r.get(item[1], types[0])), int(item[1]))
		p.position = Vector2(float(lanes[row % 3]), 520.0 + float(row) * 230.0)
		run.get_node("World").add_child(p)
		row += 1
	await _frames(20)
	await _capture("p_idle_%s" % season)
	for c in run.get_node("World").get_children():
		c.free()
	var fx: PickupFx = run.get("_pickup_fx")
	var at := (run as Node2D).to_global(player.position + Vector2(0, -170))
	var crop := Rect2i(int(player.position.x) - 270, int(player.position.y) - 330, 540, 480)
	var cases := [["coin", 1, 1], ["seed", 1, 1], ["seed", 3, 1], ["seed", 2, 2]]
	for cs in cases:
		var label := "%s_r%d%s" % [cs[0], cs[1], "_twin" if int(cs[2]) == 2 else ""]
		if cs[0] == "coin":
			fx.start_coin(at)
		else:
			fx.start_seed(str(by_r.get(int(cs[1]), types[0])), int(cs[1]), int(cs[2]), at)
		var t0 := Time.get_ticks_msec()
		for k in [80, 200, 280, 380, 480]:
			while Time.get_ticks_msec() - t0 < k:
				await process_frame
			await _capture("p_touch_%s_%s_%03d" % [season, label, k], crop)
		await _frames(30)
	# Pilula u letu do čipa (cijeli ekran).
	fx.start_seed(str(by_r.get(1, types[0])), 1, 1, at)
	var t1 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t1 < 330:
		await process_frame
	await _capture("p_pill_%s" % season)
	run.queue_free()
	await _frames(10)


func _camp_shots() -> void:
	_gs.call("reset_seasons_to_s1")
	var unlocked: Array = _gs.get("unlocked_seasons")
	for def in SeasonCatalog.free_defs_sorted():
		if not unlocked.has(def.id):
			unlocked.append(def.id)
	_gs.set("unlocked_seasons", unlocked)
	_gs.call("clear_owned_paid_seasons")
	var hub := (load("res://scenes/meta/meta_hub.tscn") as PackedScene).instantiate()
	_svp.add_child(hub)
	await _frames(30)
	hub.call("go_to_page", MetaHubPages.CAMP, false)
	await _frames(20)
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	var camp: Node = host.get_node("Page_%d" % MetaHubPages.CAMP)
	var card: Control = camp.get_node("%SeasonLinkCard")
	for target in PAID:
		_gs.call("clear_owned_paid_seasons")
		for other in PAID:
			if other == target:
				break
			_gs.call("grant_paid_season", other)
		camp.call("refresh_for_meta_hub")
		await _frames(8)
		if str(_gs.call("next_unowned_paid_id")) != target:
			continue
		var r := Rect2i(card.get_global_rect().grow(16.0))
		await _capture("c_paid_%s_price" % target, r)
		var def: SeasonDef = _gs.call("get_season_def", target)
		card.set("_buying", true)
		card.call("_show_paid", def)
		await _frames(4)
		await _capture("c_paid_%s_buying" % target, r)
		card.call("_on_purchase_failed", def.iap_product_id, "cancelled")
		await _frames(4)
		await _capture("c_paid_%s_failed" % target, r)
		if target == PAID[0]:
			await _capture("c_paid_page_%s" % target)
	hub.queue_free()
	await _frames(5)
