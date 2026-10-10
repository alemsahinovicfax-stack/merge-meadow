extends SceneTree

## Dev: cijena animacija Run HUD v2 (design_handoff_run_hud_v2) — prazan run, grm u mirovanju
## (1 Tween loop), burst grma svakih 0,6 s i svakih 0,15 s (pool se restartuje). Prosjek i najgori
## frejm. Run je pauziran (svijet stoji), pa razlika = samo grm i burst.
## Pokretanje BEZ --headless (treba renderer):
##   godot --path game --rendering-driver opengl3 -s scripts/dev/run_hud_perf_bench.gd
## Save se vraća na kraju (CampSmokeUtil).

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _avg(seconds: float, every: float, fx: Callable) -> Vector2:
	var start := Time.get_ticks_usec()
	var last := start
	var next := 0.0
	var frames := 0
	var worst := 0
	while Time.get_ticks_usec() - start < int(seconds * 1000000.0):
		var t := (Time.get_ticks_usec() - start) / 1000000.0
		if every > 0.0 and t >= next:
			fx.call()
			next = t + every
		await process_frame
		frames += 1
		var now := Time.get_ticks_usec()
		worst = maxi(worst, now - last)
		last = now
	return Vector2((Time.get_ticks_usec() - start) / 1000.0 / frames, worst / 1000.0)


func _run() -> void:
	Engine.max_fps = 0
	OS.low_processor_usage_mode = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("active_season_id", "country_bloom")
	change_scene_to_file("res://scenes/run/run_scene.tscn")
	for _i in 60:
		await process_frame
	var run := current_scene
	run.set("_state", 2)
	for c in run.get_node("World").get_children():
		c.free()
	var fx_node: Node = run.get_node("HUD/FlyLayer/BushBurst")
	var chip: Control = run.get_node("HUD/TopHud/CoinChip")
	var none := func() -> void: pass
	var a := await _avg(5.0, 0.0, none)
	run.call("_spawn_bush", 0, 900.0)
	var b := await _avg(5.0, 0.0, none)
	var burst := func() -> void:
		fx_node.call("play", Vector2(675, 1500), "country_bloom", "coin", 4, chip)
	var c := await _avg(5.0, 0.6, burst)
	var d := await _avg(5.0, 0.15, burst)
	print("BUSH empty avg %.3f ms worst %.2f" % [a.x, a.y])
	print("BUSH idle  avg %.3f ms worst %.2f" % [b.x, b.y])
	print("BUSH burst/0.6s avg %.3f ms worst %.2f" % [c.x, c.y])
	print("BUSH burst/0.15s (restart) avg %.3f ms worst %.2f" % [d.x, d.y])
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
