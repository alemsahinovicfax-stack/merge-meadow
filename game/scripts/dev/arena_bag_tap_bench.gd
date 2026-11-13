extends SceneTree

## Dev mjerenje (FIX-TEL-3 2026-11-12): „kad kliknem vreću dok se sjemenke bacaju po areni,
## baš šteka". Mjeri cijenu samog tapa (poziv) i najduži frejm poslije njega u tri stanja:
##   A  prvi tap na prazno polje (sipa 30)
##   B  tap dok sjemenke lete, polje puno (odbijen tap)
##   C  tap dok sjemenke lete, a polje ima mjesta (dosipanje usred leta)
## Headless = samo skripta (bez crtanja); s prozorom = cijeli frejm.
##   godot --headless --path game -s res://scripts/dev/arena_bag_tap_bench.gd
##   godot --path game --rendering-driver opengl3 -s res://scripts/dev/arena_bag_tap_bench.gd

const SAVE_PATH := "user://player_save.json"
var SLOW_MS := 14.0 if DisplayServer.get_name() == "headless" else 25.0
const PARTS := [
	"_refresh_bag", "_layout_bag", "_repel_chips_from_bag", "_punch_seed_bag",
	"_resolve_t3_starved_types", "_resolve_stranded_t2", "_update_tutorial_cue",
	"_arena_slots_available", "_field_type_counts", "_try_auto_refill", "_sync_hub_nav_lock",
	"_apply_magnet_pull", "_update_merge_hint",
]

var _backup := ""
var _headless := DisplayServer.get_name() == "headless"


func _initialize() -> void:
	call_deferred("_run")


func _bag() -> Dictionary:
	return {"clover": 60, "daisy": 60, "buttercup": 60, "tulip": 40, "sunflower": 40}


func _run() -> void:
	if not _headless:
		Engine.max_fps = 0
		OS.low_processor_usage_mode = false
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if FileAccess.file_exists(SAVE_PATH):
		_backup = FileAccess.get_file_as_string(SAVE_PATH)
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("reduce_motion", false)
	gs.set("seed_bag", _bag())
	var svp := SubViewport.new()
	svp.size = Vector2i(1080, 1633)
	svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(svp)
	var arena: Control = load("res://scenes/camp/merge_arena.tscn").instantiate()
	svp.add_child(arena)
	for _i in 20:
		await process_frame
	print("mode: %s" % ("headless (script only)" if _headless else "windowed (full frame)"))
	await _idle(arena, "idle, empty field")
	# A · prvi tap
	await _tap_series(arena, "A first tap (pours 30)", 1, 110, false)
	for round in 3:
		await _reset(arena, gs)
		await _tap_series(arena, "A warm tap (pours 30) #%d" % round, 1, 110, false)
	await _pour_parts(arena, gs)
	await _median_report(arena, gs)
	await _idle(arena, "idle, 30 chips resting")
	# B · tap usred leta, polje puno
	for round in 3:
		await _reset(arena, gs)
		arena.call("_on_bag_clicked")
		await _tap_series(arena, "B tap while flying, field full #%d" % round, 12, 6, false)
	# C · tap usred leta, polje ima mjesta
	for round in 3:
		await _reset(arena, gs)
		arena.call("_on_bag_clicked")
		await _tap_series(arena, "C tap while flying, room on field #%d" % round, 12, 6, true)
	# Dijelovi (30 sjemenki na polju, mirno).
	await _reset(arena, gs)
	arena.call("_on_bag_clicked")
	for _i in 150:
		await process_frame
	for m in PARTS:
		if arena.has_method(m):
			var t0 := Time.get_ticks_usec()
			for _i in 20:
				arena.call(m)
			print("part arena.%-28s %7.3f ms" % [m, float(Time.get_ticks_usec() - t0) / 20000.0])
	var t1 := Time.get_ticks_usec()
	for _i in 5:
		gs.call("save_player_save")
	print("part gs.%-31s %7.3f ms" % ["save_player_save", float(Time.get_ticks_usec() - t1) / 5000.0])
	if _backup.is_empty():
		DirAccess.remove_absolute(SAVE_PATH)
	else:
		FileAccess.open(SAVE_PATH, FileAccess.WRITE).store_string(_backup)
	print("arena_bag_tap_bench OK")
	quit(0)


func _reset(arena: Node, gs: Node) -> void:
	arena.call("_clear_field_chips")
	arena.set("_session_open", false)
	gs.set("seed_bag", _bag())
	for _i in 12:
		await process_frame


func _idle(_arena: Node, label: String) -> void:
	var worst := 0.0
	var sum := 0.0
	var last := Time.get_ticks_usec()
	for _i in 120:
		await process_frame
		var now := Time.get_ticks_usec()
		var ms := float(now - last) / 1000.0
		last = now
		sum += ms
		worst = maxf(worst, ms)
	print("BENCH %-44s frame avg %6.2f  worst %6.2f ms" % [label, sum / 120.0, worst])


## `taps` tapova, `gap` frejmova između. `free_slots`: prije svakog tapa skloni 4 sjemenke s polja
## (kao da ih je igrač upravo spojio), pa tap ima šta dosuti.
func _tap_series(arena: Node, label: String, taps: int, gap: int, free_slots: bool) -> void:
	var call_sum := 0.0
	var call_worst := 0.0
	var frame_sum := 0.0
	var frame_worst := 0.0
	var first_frame_worst := 0.0
	var frames := 0
	for _t in taps:
		if free_slots:
			var chips: Array = arena.get("_chips")
			for _k in mini(4, chips.size()):
				arena.call("_remove_chip", chips[0])
		var t0 := Time.get_ticks_usec()
		arena.call("_on_bag_clicked")
		var ms := float(Time.get_ticks_usec() - t0) / 1000.0
		call_sum += ms
		call_worst = maxf(call_worst, ms)
		var last := Time.get_ticks_usec()
		for f in gap:
			await process_frame
			var now := Time.get_ticks_usec()
			var fms := float(now - last) / 1000.0
			last = now
			frame_sum += fms
			frame_worst = maxf(frame_worst, fms)
			if fms > SLOW_MS:
				print("    slow frame +%d after tap: %.1f ms (chips %d, flies %d)" % [
					f, fms, (arena.get("_chips") as Array).size(), (arena.get("_vacuum_flies") as Array).size()])
			if f == 0:
				first_frame_worst = maxf(first_frame_worst, fms)
			frames += 1
	print("BENCH %-44s call avg %6.2f worst %6.2f | frame avg %6.2f worst %6.2f (first after tap %6.2f) | chips %d" % [
		label, call_sum / float(taps), call_worst, frame_sum / float(frames), frame_worst, first_frame_worst,
		(arena.get("_chips") as Array).size(),
	])


## Sipanje 30 sjemenki, korak po korak (isti redoslijed kao _pour_available_seeds).
func _pour_parts(arena: Node, gs: Node) -> void:
	for round in 2:
		await _reset(arena, gs)
		arena.call("_start_session_if_needed")
		var t := Time.get_ticks_usec()
		var pulled: Array = gs.call("pull_seeds_to_arena", 30, {})
		var a := Time.get_ticks_usec()
		var spawned: Array = arena.call("_spawn_poured_chips", pulled)
		var b := Time.get_ticks_usec()
		arena.call("_animate_pour", spawned)
		var c := Time.get_ticks_usec()
		arena.call("_repel_chips_from_bag")
		var pest: Object = arena.get("_pest")
		if pest:
			pest.call("on_seeds_poured", true)
		var d := Time.get_ticks_usec()
		arena.call("_resolve_t3_starved_types")
		arena.call("_resolve_stranded_t2")
		arena.call("_update_tutorial_cue")
		var e := Time.get_ticks_usec()
		arena.call("_refresh_bag")
		var f := Time.get_ticks_usec()
		print("pour parts #%d: pull %.2f | spawn %.2f | animate %.2f | repel+pest %.2f | resolve %.2f | refresh %.2f ms" % [
			round, (a - t) / 1000.0, (b - a) / 1000.0, (c - b) / 1000.0, (d - c) / 1000.0, (e - d) / 1000.0, (f - e) / 1000.0])
		var last := Time.get_ticks_usec()
		var line := ""
		for i in 8:
			await process_frame
			var now := Time.get_ticks_usec()
			line += "%.1f " % ((now - last) / 1000.0)
			last = now
		print("  next frames: %s" % line)


static func _median(v: Array) -> float:
	if v.is_empty():
		return 0.0
	var a := v.duplicate()
	a.sort()
	return float(a[a.size() / 2])


## Medijan kroz više rundi (laptop šumi): poziv tapa, prvi frejm poslije i najgori frejm leta.
func _median_report(arena: Node, gs: Node) -> void:
	var calls: Array = []
	var firsts: Array = []
	var worsts: Array = []
	for _r in 9:
		await _reset(arena, gs)
		var t0 := Time.get_ticks_usec()
		arena.call("_on_bag_clicked")
		calls.append(float(Time.get_ticks_usec() - t0) / 1000.0)
		var last := Time.get_ticks_usec()
		var worst := 0.0
		for f in 100:
			await process_frame
			var now := Time.get_ticks_usec()
			var ms := float(now - last) / 1000.0
			last = now
			if f == 0:
				firsts.append(ms)
			else:
				worst = maxf(worst, ms)
		worsts.append(worst)
	print("MEDIAN A pour 30: call %.2f ms | first frame %.2f ms | worst flight frame %.2f ms" % [
		_median(calls), _median(firsts), _median(worsts)])
	var c_calls: Array = []
	var c_firsts: Array = []
	for _r in 5:
		await _reset(arena, gs)
		arena.call("_on_bag_clicked")
		for _t in 10:
			var chips: Array = arena.get("_chips")
			for _k in mini(4, chips.size()):
				arena.call("_remove_chip", chips[0])
			var t0 := Time.get_ticks_usec()
			arena.call("_on_bag_clicked")
			c_calls.append(float(Time.get_ticks_usec() - t0) / 1000.0)
			var last := Time.get_ticks_usec()
			for f in 6:
				await process_frame
				if f == 0:
					c_firsts.append(float(Time.get_ticks_usec() - last) / 1000.0)
	print("MEDIAN C top-up 4 mid-flight: call %.2f ms | first frame %.2f ms" % [_median(c_calls), _median(c_firsts)])
	var idle: Array = []
	var last2 := Time.get_ticks_usec()
	for _i in 200:
		await process_frame
		var now2 := Time.get_ticks_usec()
		idle.append(float(now2 - last2) / 1000.0)
		last2 = now2
	print("MEDIAN idle frame %.2f ms" % _median(idle))
