extends SceneTree

## Dev: cijena pickupa u runu (design_handoff_run_pickups) — idle na stazi, dodiri sa Pipom,
## niz coina, magnet L4. Pravi run 1080 × 1920 u SubViewportu, vsync isključen. Isti
## scenariji rade i na starom kodu (A/B): pickupi se prave iz scena runa i zovu `collect()`.
## Scenariji (MM_ONLY filtrira po početku imena):
##   pk_empty      — kontroler stoji, nema pickupa (osnovica)
##   pk_idle10     — 10 pickupa stoji na ekranu (4 coina, 2 × ★1, 2 × ★2, 2 × ★3)
##   pk_idle20     — 20 pickupa (dvostruko više od budžeta) — rezerva
##   pk_coin_x3    — 3 coina odjednom svakih 0,2 s (15 / s, niz do n5) — najgori slučaj
##   pk_seed_mix   — sjeme ★1 / ★2 / ★3 naizmjence svakih 0,15 s (+ twin kad padne)
##   pk_magnet_l4  — pravi run, magnet nivo 4 (232 px), spawn svakih 0,25 s, promjena staze
## Sezone: MM_SEASONS (zarezom), inače country_bloom i starfall_glade.
## Pokretanje BEZ --headless:
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_pickups_bench.gd

const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const DEFAULT_SEASONS := ["country_bloom", "starfall_glade"]

var _backup := ""
var _svp: SubViewport
var _vp_rid: RID
var _gs: Node
var _only: PackedStringArray = []
var _rows: Array[String] = []
var _seed_ids: Array[String] = []


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _wants(name: String) -> bool:
	if _only.is_empty():
		return true
	for o in _only:
		if name.begins_with(o):
			return true
	return false


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _sample(label: String, seconds: float, step: Callable = Callable()) -> void:
	var dts: Array[float] = []
	var start := Time.get_ticks_usec()
	var last := start
	var calls := 0.0
	var nodes := 0.0
	var cpu := 0.0
	var proc := 0.0
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		if step.is_valid():
			step.call(float(Time.get_ticks_usec() - start) / 1000000.0)
		await process_frame
		var now := Time.get_ticks_usec()
		dts.append(float(now - last) / 1000.0)
		last = now
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		nodes += Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
		cpu += RenderingServer.viewport_get_measured_render_time_cpu(_vp_rid)
		proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var n := dts.size()
	var sorted := dts.duplicate()
	sorted.sort()
	var total := 0.0
	var over16 := 0
	for d in dts:
		total += d
		if d > 16.7:
			over16 += 1
	var row := "PERF %-32s avg %5.2f  p95 %5.2f  p99 %6.2f  max %6.2f  >16ms %3d  n %4d  draw %5.1f  nodes %5.0f  script %5.2f  cpu %5.2f" % [
		label, total / n, sorted[int(n * 0.95)], sorted[mini(n - 1, int(n * 0.99))], sorted[n - 1],
		over16, n, calls / n, nodes / n, proc / n, cpu / n
	]
	print(row)
	_rows.append(row)


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var only := OS.get_environment("MM_ONLY")
	if not only.is_empty():
		_only = only.split(",")
	var seasons: Array = DEFAULT_SEASONS
	if OS.get_environment("MM_SEASONS") != "":
		seasons = Array(OS.get_environment("MM_SEASONS").split(","))
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_svp = SubViewport.new()
	_svp.size = Vector2i(1080, 1920)
	_svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(_svp)
	_vp_rid = _svp.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(_vp_rid, true)
	for season in seasons:
		await _season_suite(str(season))
	print("---- PERF SUMMARY ----")
	for r in _rows:
		print(r)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _new_run(season: String) -> Node:
	_gs.set("active_season_id", season)
	_gs.call("begin_campaign_run")
	var run := (load(RUN_SCENE) as PackedScene).instantiate()
	_svp.add_child(run)
	await _frames(40)
	var player: Node = run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	_seed_ids.clear()
	for id in _gs.call("run_seed_pool_ids") if _gs.has_method("run_seed_pool_ids") else []:
		_seed_ids.append(str(id))
	if _seed_ids.is_empty():
		for i in 6:
			_seed_ids.append(str(_gs.call("pick_random_run_seed_type")))
	return run


## Kontroler stoji (nema skrola ni spawna); pickupi i Pip i dalje animiraju.
func _freeze(run: Node) -> void:
	run.set_process(false)
	for c in run.get_node("World").get_children():
		c.queue_free()


func _spawn_coin(run: Node, pos: Vector2) -> Node:
	var coin: Node2D = (run.get("_coin_scene") as PackedScene).instantiate()
	coin.position = pos
	coin.connect("collected", Callable(run, "_on_coin_collected"))
	run.get_node("World").add_child(coin)
	return coin


func _spawn_seed(run: Node, pos: Vector2, rarity: int, idx: int) -> Node:
	var seed: Node2D = (run.get("_seed_scene") as PackedScene).instantiate()
	seed.position = pos
	seed.call("setup", _seed_ids[idx % _seed_ids.size()], rarity)
	seed.connect("collected", Callable(run, "_on_seed_collected"))
	run.get_node("World").add_child(seed)
	return seed


func _lanes(run: Node) -> Array:
	return run.get("lane_x_positions")


func _place_idle(run: Node, count: int) -> void:
	var lanes := _lanes(run)
	for i in count:
		var lane := i % 3
		var y := 260.0 + float(i / 3) * 170.0
		var pos := Vector2(float(lanes[lane]), y)
		var kind := i % 5
		if kind <= 1:
			_spawn_coin(run, pos)
		else:
			_spawn_seed(run, pos, kind - 1, i)


func _season_suite(season: String) -> void:
	var run := await _new_run(season)
	var player: Node2D = run.get_node("Player")
	var lanes := _lanes(run)
	if _wants("pk_empty"):
		_freeze(run)
		await _frames(5)
		await _sample("pk_empty · %s" % season, 3.0)
	if _wants("pk_idle10"):
		_freeze(run)
		await _frames(2)
		_place_idle(run, 10)
		await _frames(10)
		await _sample("pk_idle10 · %s" % season, 4.0)
	if _wants("pk_idle20"):
		_freeze(run)
		await _frames(2)
		_place_idle(run, 20)
		await _frames(10)
		await _sample("pk_idle20 · %s" % season, 4.0)
	if _wants("pk_coin_x3"):
		_freeze(run)
		await _frames(2)
		var cs := {"next": 0.0}
		await _sample("pk_coin_x3 · %s" % season, 5.0, func(t: float) -> void:
			if t >= cs["next"]:
				cs["next"] = t + 0.2
				for k in 3:
					var c := _spawn_coin(run, player.position + Vector2(float(k - 1) * 30.0, -40.0))
					c.call("collect"))
	if _wants("pk_seed_mix"):
		_freeze(run)
		await _frames(2)
		var ss := {"next": 0.0, "i": 0}
		await _sample("pk_seed_mix · %s" % season, 5.0, func(t: float) -> void:
			if t >= ss["next"]:
				ss["next"] = t + 0.15
				var i := int(ss["i"])
				ss["i"] = i + 1
				var s := _spawn_seed(run, player.position + Vector2(0, -40), 1 + i % 3, i)
				s.call("collect"))
	run.queue_free()
	await _frames(5)
	if _wants("pk_magnet_l4"):
		_gs.set("magnet_level", 4)
		var run2 := await _new_run(season)
		var p2: Node = run2.get_node("Player")
		p2.call("set_magnet_radius", float(_gs.call("get_magnet_radius_for_level", 4)))
		run2.set("_spawn_chance", 1.0)
		run2.set("_spawn_interval", 0.25)
		run2.set("_obstacle_chance", 0.0)
		run2.set("_next_bush_at", 1.0)
		var ls := {"next": 0.0, "dir": 1}
		await _sample("pk_magnet_l4 · %s" % season, 8.0, func(t: float) -> void:
			if t >= ls["next"]:
				ls["next"] = t + 0.7
				var lane := int(p2.get("lane_index")) + int(ls["dir"])
				if lane < 0 or lane > 2:
					ls["dir"] = -int(ls["dir"])
					lane = int(p2.get("lane_index")) + int(ls["dir"])
				p2.set("lane_index", lane)
				p2.call("_apply_lane", true))
		run2.queue_free()
		_gs.set("magnet_level", 0)
		await _frames(5)
