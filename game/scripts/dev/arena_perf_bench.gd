extends SceneTree

## Dev: mjeri cijenu frejma u Areni (CPU vrijeme frejma, draw pozivi, primitivi) u četiri
## stanja: mirno polje (muncher spava, korpa se klati), muncher lovi, combo talas + crossfade
## bujnosti, i sipanje sjemenki iz korpe (~30 sjemenki leti na polje, 3 puta).
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/arena_perf_bench.gd

const SAVE_PATH := "user://player_save.json"
var FRAMES := int(OS.get_environment("MM_FRAMES")) if OS.get_environment("MM_FRAMES") != "" else 240

var _backup := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if FileAccess.file_exists(SAVE_PATH):
		_backup = FileAccess.get_file_as_string(SAVE_PATH)
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("seed_bag", {"clover": 14, "daisy": 14, "buttercup": 12, "tulip": 12})
	var svp := SubViewport.new()
	svp.size = Vector2i(1080, 1633)
	svp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(svp)
	var arena: Control = load("res://scenes/camp/merge_arena.tscn").instantiate()
	svp.add_child(arena)
	for _i in 10:
		await process_frame
	var bg := arena.get_node("Bg")
	bg.call("set_season", "country_bloom")
	bg.call("set_t3_level", 4.0, false)
	arena.call("_on_bag_clicked")
	for _i in 60:
		await process_frame
	var pest := arena.get_node("RootVBox/Playfield/MuncherPest")
	pest.call("reset_to_nest")
	await _measure("idle (muncher asleep, basket wiggle)")
	pest.call("on_seeds_poured", true)
	for _i in 30:
		await process_frame
	await _measure("muncher hunting")
	await _measure_combo(arena, bg)
	await _measure_pour(arena, gs)
	await _breakdown(arena)
	if _backup.is_empty():
		DirAccess.remove_absolute(SAVE_PATH)
	else:
		FileAccess.open(SAVE_PATH, FileAccess.WRITE).store_string(_backup)
	quit(0)


func _measure(label: String) -> void:
	var total := 0
	var worst := 0
	var calls := 0.0
	var prims := 0.0
	var last := Time.get_ticks_usec()
	for _i in FRAMES:
		await process_frame
		var now := Time.get_ticks_usec()
		var dt := now - last
		last = now
		total += dt
		worst = maxi(worst, dt)
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	print("BENCH %-40s avg %6.2f ms  worst %6.2f ms  draw calls %6.0f  primitives %8.0f" % [
		label, total / 1000.0 / FRAMES, worst / 1000.0, calls / FRAMES, prims / FRAMES
	])


## Koliko primitiva nosi svaki dio (sakrij ga i oduzmi).
func _breakdown(arena: Node) -> void:
	pest_sleep(arena)
	var full := await _prims()
	var field := arena.get_node("RootVBox/Playfield")
	var parts := {"Bg": [arena.get_node("Bg")], "MuncherPest": [], "SeedBag": [], "ArenaPip": [], "chips": []}
	for c in field.get_children():
		if c.name in parts:
			parts[c.name].append(c)
		elif "type_id" in c:
			parts["chips"].append(c)
	for key in parts:
		for n in parts[key]:
			n.visible = false
		var p := await _prims()
		for n in parts[key]:
			n.visible = true
		print("PART %-12s primitives %7.0f  draw calls %5.0f" % [key, full.x - p.x, full.y - p.y])
	print("PART total        primitives %7.0f  draw calls %5.0f" % [full.x, full.y])


func pest_sleep(arena: Node) -> void:
	arena.get_node("RootVBox/Playfield/MuncherPest").call("reset_to_nest")


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


## Sipanje: prazno polje → tap na korpu → ~30 sjemenki leti iz korpe (0,42 s + 0,04 s razmak).
func _measure_pour(arena: Node, gs: Node) -> void:
	var total := 0
	var worst := 0
	var n := 0
	var calls := 0.0
	for _round in 3:
		arena.call("_clear_field_chips")
		arena.set("_session_open", false)
		for _i in 10:
			await process_frame
		gs.set("seed_bag", {"clover": 10, "daisy": 10, "buttercup": 10, "tulip": 10})
		var last := Time.get_ticks_usec()
		arena.call("_on_bag_clicked")
		for _i in 110:
			await process_frame
			var now := Time.get_ticks_usec()
			var dt := now - last
			last = now
			total += dt
			worst = maxi(worst, dt)
			calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			n += 1
	print("BENCH %-40s avg %6.2f ms  worst %6.2f ms  draw calls %6.0f  chips %d" % [
		"seed pour (30 chips fly in)", total / 1000.0 / n, worst / 1000.0, calls / n, (arena.get("_chips") as Array).size()
	])


func _measure_combo(arena: Node, bg: Node) -> void:
	var total := 0
	var worst := 0
	var last := Time.get_ticks_usec()
	for i in FRAMES:
		if i % 20 == 0:
			arena.call("register_arena_combo_merge", Vector2(540, 800))
			bg.call("set_t3_level", 4.0 if (i / 20) % 2 == 0 else 3.0, true)
		await process_frame
		var now := Time.get_ticks_usec()
		var dt := now - last
		last = now
		total += dt
		worst = maxi(worst, dt)
	print("BENCH %-40s avg %6.2f ms  worst %6.2f ms" % [
		"combo bow + lush crossfade", total / 1000.0 / FRAMES, worst / 1000.0
	])
