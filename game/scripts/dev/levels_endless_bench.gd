extends SceneTree

## Dev: cijena frejma za design_handoff_leveli_endless (A/B: pusti na starom i novom kodu, isti
## uslovi). Pip je neranjiv. CPU vrijeme frejma (prosjek, p95, najgori) u µs — headless mjeri
## skripte + pripremu crtanja (efekti paketa su transformi i sprite-ovi, GPU dio je zanemariv).
##   1. level 20 (Lantern Meadow) na 60 s — parovi, nalet svakih 15 s;
##   2. kraj levela 6 (Frost Orchard) — zadnjih 4,5 s: cilj vozi i prolaz;
##   3. Endless 7:00 (Amber Canopy) — nova stepenica na 7:00 (Pace + nalet) i novi rekord;
##   4. Level Path (Country Bloom, Pip na 12) — 2 spremna sanduka u petlji.
## Pokretanje: godot --headless --path game -s res://scripts/dev/levels_endless_bench.gd
## Save se vraća na kraju (CampSmokeUtil).

const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const SECONDS := 4.5

var _backup := ""
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _run() -> void:
	Engine.max_fps = 0
	_gs = get_root().get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("reduce_motion", false)
	var lp = _gs.get("level_path_domain")
	await _run_case("level 20", "lantern_meadow", 20, 60.0, 0.0)
	await _run_case("level 6 end", "frost_orchard", 6, -4.5, 0.0)
	lp.endless_best["amber_canopy"] = 422.0
	await _run_case("endless 7:00", "amber_canopy", 0, 418.0, 0.0)
	await _path_case()
	await _micro()
	_gs.set("run_is_endless", false)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


## `at` < 0 = toliko s prije kraja levela.
func _run_case(label: String, season: String, level: int, at: float, _unused: float) -> void:
	_gs.call("set_active_season", season)
	if level == 0:
		_gs.call("begin_endless_run")
	else:
		_gs.set("run_level", level)
		_gs.call("begin_campaign_run")
	change_scene_to_file(RUN_SCENE)
	for _i in 40:
		await process_frame
	var run := current_scene
	var hit := Callable(run, "_on_player_hit_obstacle")
	if run.get_node("Player").is_connected("hit_obstacle", hit):
		run.get_node("Player").disconnect("hit_obstacle", hit)
	var start_at := at if at >= 0.0 else float(_gs.call("get_run_duration")) + at
	run.set("elapsed", start_at)
	await _measure(label, SECONDS if at >= 0.0 else -at - 0.05)


func _path_case() -> void:
	change_scene_to_file(RUN_SCENE)
	for _i in 10:
		await process_frame
	var lp = _gs.get("level_path_domain")
	lp.claimed.erase("country_bloom")
	lp.set_level("country_bloom", 12)
	var view = load("res://scripts/ui/level_path_view.gd").new()
	get_root().add_child(view)
	for _i in 5:
		await process_frame
	view.show_season("country_bloom")
	await _measure("path 2 ready chests", SECONDS)
	view.queue_free()


func _measure(label: String, seconds: float) -> void:
	var times: Array[int] = []
	var start := Time.get_ticks_usec()
	var last := start
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		await process_frame
		var now := Time.get_ticks_usec()
		times.append(now - last)
		last = now
	if times.is_empty():
		return
	var n := times.size()
	var sum := 0
	for t in times:
		sum += t
	times.sort()
	print("BENCH %-20s frames %5d  avg %6.0f µs  p95 %6d µs  max %6d µs" % [
		label, n, float(sum) / float(n), times[int(n * 0.95)], times[n - 1]])


## Cijena po pozivu (µs) za ono što paket dodaje po frejmu — manje osjetljivo na opterećenje
## mašine od cijelog frejma. Najbolje od 5 serija po N poziva.
func _micro() -> void:
	change_scene_to_file(RUN_SCENE)
	for _i in 20:
		await process_frame
	var run := current_scene
	run.set("_state", 2)
	var gust = run.get("gust_fx")
	_bench("gust _process (1 frame)", func() -> void:
		gust.play(1.0)
		gust.call("_process", 1.0 / 60.0), 2000)
	gust.stop()
	var fx = run.get("endless_fx")
	fx.play_pace(5, 0.0)
	fx.play_best(Rect2(40, 60, 380, 128), null)
	_bench("pace pill + record _process", func() -> void:
		fx.set("_pace_t", 0.3)
		fx.set("_best_t", 0.3)
		fx.call("_process", 1.0 / 60.0), 2000)
	_bench("pace + record trigger (once)", func() -> void:
		fx.play_pace(5, 0.0)
		fx.play_best(Rect2(40, 60, 380, 128), null), 500)
	var chip = run.get("endless_chip")
	_bench("endless chip set_state (1/s)", func() -> void:
		chip.set_state(randi() % 3600, 7, 265.0, false), 500)
	var gate = load("res://scripts/run/run_finish_gate.gd").new()
	gate.setup("frost_orchard", 1.0)
	run.get_node("World").add_child(gate)
	gate.pass_through(run.get_node("HUD/FlyLayer"), Vector2(540, 1574))
	_bench("finish gate _process (pass)", func() -> void:
		gate.set("_t", 0.3)
		gate.call("_process", 1.0 / 60.0), 2000)
	_bench("remaining_distance(dur) per frame", func() -> void:
		run.call("remaining_distance", 120.0), 5000)
	_bench("GameState.get_run_duration()", func() -> void:
		_gs.call("get_run_duration"), 5000)
	var intro = run.get("level_intro")
	_bench("level intro _process", func() -> void:
		intro.set("_t", 0.5)
		intro.call("_process", 1.0 / 60.0), 2000)
	intro.stop()
	var lp = _gs.get("level_path_domain")
	lp.claimed.erase("country_bloom")
	lp.set_level("country_bloom", 12)
	var view = load("res://scripts/ui/level_path_view.gd").new()
	get_root().add_child(view)
	for _i in 3:
		await process_frame
	view.show_season("country_bloom")
	_bench("path _process (2 ready chests)", func() -> void:
		view.call("_process", 1.0 / 60.0), 2000)
	view.queue_free()


func _bench(label: String, fn: Callable, n: int) -> void:
	var best := INF
	for _r in 5:
		var t0 := Time.get_ticks_usec()
		for _i in n:
			fn.call()
		best = minf(best, float(Time.get_ticks_usec() - t0) / float(n))
	print("MICRO %-32s %7.2f µs / poziv" % [label, best])
