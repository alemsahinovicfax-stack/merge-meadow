extends SceneTree

## Dev: cijena frejma u runu po težini (balans ciklus 1) — level 1, level 20 (~90 s) i Endless na
## ~8 min (najbrže i najgušće: parovi, 920 px/s). Pip je neranjiv da run ne stane. CPU vrijeme
## frejma (prosjek, p95, najgori), draw pozivi i primitivi u kadru.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/balance_perf_bench.gd
## Save se vraća na kraju (CampSmokeUtil).

const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const WARMUP := 3.0
const SECONDS := 6.0
## [oznaka, sezona, level (0 = Endless), elapsed na startu mjerenja]
const CASES := [
	["level 1", "country_bloom", 1, 5.0],
	["level 20", "lantern_meadow", 20, 90.0],
	["endless 8 min", "amber_canopy", 0, 480.0],
]

var _backup := ""
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_gs = get_root().get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	for c in CASES:
		_gs.call("set_active_season", str(c[1]))
		if int(c[2]) == 0:
			_gs.call("begin_endless_run")
		else:
			_gs.set("run_level", int(c[2]))
			_gs.call("begin_campaign_run")
		change_scene_to_file(RUN_SCENE)
		for _i in 40:
			await process_frame
		var run := current_scene
		var hit := Callable(run, "_on_player_hit_obstacle")
		if run.get_node("Player").is_connected("hit_obstacle", hit):
			run.get_node("Player").disconnect("hit_obstacle", hit)
		run.set("elapsed", float(c[3]))
		await _measure(str(c[0]), run, WARMUP, false)
		await _measure(str(c[0]), run, SECONDS, true)
	_gs.set("run_is_endless", false)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _measure(label: String, run: Node, seconds: float, report: bool) -> void:
	var times: Array[int] = []
	var calls := 0.0
	var prims := 0.0
	var start := Time.get_ticks_usec()
	var last := start
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		await process_frame
		var now := Time.get_ticks_usec()
		times.append(now - last)
		last = now
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	if not report or times.is_empty():
		return
	var n := times.size()
	var sum := 0
	for t in times:
		sum += t
	times.sort()
	var obstacles := 0
	for ch in run.get_node("World").get_children():
		if ch.is_in_group("obstacle"):
			obstacles += 1
	print("balance_perf %-14s avg %.2f ms · p95 %.2f ms · worst %.2f ms · draw %.0f · prims %.0f · speed %d px/s · obstacles on screen %d · frames %d" % [
		label, sum / 1000.0 / n, times[int(n * 0.95)] / 1000.0, times[n - 1] / 1000.0, calls / n, prims / n,
		roundi(float(run.get("scroll_speed"))), obstacles, n,
	])
