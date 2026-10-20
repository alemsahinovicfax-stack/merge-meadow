extends SceneTree

## Dev: CPU cijena skripti pickupa (design_handoff_run_pickups), bez GPU šuma: _process idle
## vizuala i PickupFx se zovu ručno, sat je ručni (1/60 s). Laptop jako šeta (termika), zato
## svaka varijanta ide REPS puta naizmjenično i ispisuje se minimum (+ medijan). Varijante:
##   ref         — referentni posao (1000 × sin), da se vidi koliko je laptop „brz" taj čas
##   idle10      — 10 pickupa na stazi (4 coina, 2 × ★1, 2 × ★2, 2 × ★3), µs / frejm
##   fx_typical  — 1 coin svakih 0,5 s (magnet L4, normalan run)
##   fx_worst    — 3 dodira svakih 0,2 s (★3 twin + ★2 + coin) — 15 / s, ~10 istovremeno
## Headless:  godot --headless --path game -s scripts/dev/run_pickups_cpu_bench.gd

const RUN_SCENE := "res://scenes/run/run_scene.tscn"
const FRAMES := 300
const REPS := 5
const DT := 1.0 / 60.0

var _backup := ""
var _results: Dictionary = {}


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	var gs := get_root().get_node("GameState")
	gs.set("skip_debug_season_unlock", true)
	gs.set("tutorial_complete", true)
	gs.set("active_season_id", "country_bloom")
	gs.call("begin_campaign_run")
	var run := (load(RUN_SCENE) as PackedScene).instantiate()
	get_root().add_child(run)
	await _frames(30)
	run.set_process(false)
	for c in run.get_node("World").get_children():
		c.free()
	var lanes: Array = run.get("lane_x_positions")
	for i in 10:
		var p: Node2D
		if i % 5 <= 1:
			p = (run.get("_coin_scene") as PackedScene).instantiate()
		else:
			p = (run.get("_seed_scene") as PackedScene).instantiate()
			p.call("setup", "clover", i % 5 - 1)
		p.position = Vector2(float(lanes[i % 3]), 260.0 + float(i / 3) * 170.0)
		run.get_node("World").add_child(p)
	await _frames(3)
	var visuals: Array[Node] = []
	for p in run.get_node("World").get_children():
		var v: Node = p.get_child(0)
		v.set_process(false)
		visuals.append(v)
	var fx: PickupFx = run.get("_pickup_fx")
	fx.set_process(false)
	var player: Node2D = run.get_node("Player")
	var at := (run as Node2D).to_global(player.position + Vector2(0, -150))
	for _r in REPS:
		_add("ref", _ref())
		_add("idle10", _idle(visuals))
		_add("fx_typical", _fx(fx, at, 30, false))
		_add("fx_worst", _fx(fx, at, 12, true))
		await process_frame
	for k in ["ref", "idle10", "fx_typical", "fx_worst"]:
		var arr: Array = _results[k]
		arr.sort()
		print("CPU %-11s min %7.1f µs  median %7.1f µs" % [k, float(arr[0]), float(arr[arr.size() / 2])])
	print("CPU fx peak sprites live: %d" % fx.max_sprites())
	run.queue_free()
	await _frames(3)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)


func _add(key: String, v: float) -> void:
	if not _results.has(key):
		_results[key] = []
	(_results[key] as Array).append(v)


func _ref() -> float:
	var a := Time.get_ticks_usec()
	var acc := 0.0
	for i in 1000:
		acc += sin(float(i) * 0.01)
	return float(Time.get_ticks_usec() - a)


func _idle(visuals: Array[Node]) -> float:
	var a := Time.get_ticks_usec()
	for _f in FRAMES:
		for v in visuals:
			v.call("_process", DT)
	return float(Time.get_ticks_usec() - a) / float(FRAMES)


func _fx(fx: PickupFx, at: Vector2, every: int, worst: bool) -> float:
	var total := 0
	for f in FRAMES:
		if f % every == 0:
			if worst:
				fx.start_seed("clover", 3, 2, at)
				fx.start_seed("clover", 2, 1, at)
			fx.start_coin(at)
		var a := Time.get_ticks_usec()
		fx.call("_process", DT)
		total += Time.get_ticks_usec() - a
	fx.clear()
	return float(total) / float(FRAMES)
