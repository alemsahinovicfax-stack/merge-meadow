extends SceneTree

## Dev: cijena frejma u runu po sezoni (CPU vrijeme frejma, draw pozivi, primitivi) i koliko
## nosi svaki dio (pozadina, svijet, Pip, HUD). Sezone: MM_SEASONS (zarezom), inače 4 različite
## (pruge, trag sanki, zvjezdana prašina + najviše čestica, daske).
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_perf_bench.gd
## Save se vraća na kraju (CampSmokeUtil).

const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const DEFAULT_SEASONS := ["country_bloom", "frost_orchard", "starfall_glade", "ember_fen"]
## Mjeri se po vremenu (spawn prepreka i pickupa traje), ne po broju frejmova.
var SECONDS := float(OS.get_environment("MM_SECONDS")) if OS.get_environment("MM_SECONDS") != "" else 8.0

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	var seasons: Array = DEFAULT_SEASONS
	if OS.get_environment("MM_SEASONS") != "":
		seasons = Array(OS.get_environment("MM_SEASONS").split(","))
	for id in seasons:
		gs.set("active_season_id", str(id))
		change_scene_to_file(RUN_SCENE)
		for _i in 40:
			await process_frame
		await _measure("run %s" % id)
		await _breakdown()
	_quit(0)


func _measure(label: String) -> void:
	var total := 0
	var worst := 0
	var calls := 0.0
	var prims := 0.0
	var frames := 0
	var start := Time.get_ticks_usec()
	var last := start
	while Time.get_ticks_usec() - start < int(SECONDS * 1000000.0):
		await process_frame
		frames += 1
		var now := Time.get_ticks_usec()
		var dt := now - last
		last = now
		total += dt
		worst = maxi(worst, dt)
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	var world := current_scene.get_node_or_null("World") if current_scene else null
	print("BENCH %-28s avg %6.2f ms  worst %6.2f ms  draw calls %5.0f  primitives %7.0f  world nodes %d" % [
		label, total / 1000.0 / frames, worst / 1000.0, calls / frames, prims / frames, world.get_child_count() if world else 0
	])


## Koliko primitiva / draw poziva nosi svaki dio (sakrij ga i oduzmi).
func _breakdown() -> void:
	var run := current_scene
	if run == null:
		return
	var full := await _prims()
	var full_ms := await _avg_ms()
	var line := ""
	for part in ["Background", "World", "Player", "HUD"]:
		var n := run.get_node_or_null(part)
		if n == null or not ("visible" in n):
			continue
		n.visible = false
		var p := await _prims()
		var ms := await _avg_ms()
		n.visible = true
		line += "  %s %.0f/%.0f %.2fms" % [part, full.x - p.x, full.y - p.y, full_ms - ms]
	print("PART primitives/draw calls/frame ms:%s  (total %.0f/%.0f %.2fms)" % [line, full.x, full.y, full_ms])


## Prosjek frejma (ms) preko 150 frejmova — razlika sa sakrivenim dijelom = njegova cijena.
func _avg_ms() -> float:
	await process_frame
	var start := Time.get_ticks_usec()
	for _i in 150:
		await process_frame
	return (Time.get_ticks_usec() - start) / 1000.0 / 150.0


func _prims() -> Vector2:
	for _i in 3:
		await process_frame
	var p := 0.0
	var c := 0.0
	for _i in 10:
		await process_frame
		p += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
		c += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	return Vector2(p / 10.0, c / 10.0)
