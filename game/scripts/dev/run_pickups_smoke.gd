extends SceneTree

## design_handoff_run_pickups (dio A): pickupi u runu.
##  1. idle: coin = 3 sprite-a (sjena, novčić, iskrica); sjeme ★1 / ★2 / ★3 = broj sprite-ova iz
##     pickup_fx.json (oreol + iskrice samo za ★2 / ★3); ništa ne crta po frejmu (_draw);
##  2. dodir: collect() broji ODMAH, ali broj na čipu raste tek kad pilula stigne; let do Pipa
##     traje 0,12–0,2 s; događaj počinje poslije leta (touch_started), pa pill_arrived;
##  3. niz coina ≤ 0,6 s → coin_n1 … coin_n5, pa ostaje n5; pauza > 0,6 s vraća n1;
##  4. twin +2 → seed_rX_twin, pilula „+2"; ★3 → pickup_seed_rare;
##  5. Pip prioritet: coin ne prekida rare dok traje;
##  6. budžet: ≤ 8 sprite-ova po dodiru (s pilulom), 3 dodira ≤ 24; poslije svega bazen je prazan
##     (svi sprite-ovi sakriveni, nema novih čvorova po dodiru kad je bazen zagrijan);
##  7. magnet krug: tačkice, vrti se, trzne se pri hvatanju.
## Pokretanje: godot --headless --path game -s scripts/dev/run_pickups_smoke.gd

const RUN_SCENE := "res://scenes/run/run_scene.tscn"

var _failed: bool = false
var _backup: String = ""
var _gs: Node
var _events: Array[String] = []
var _arrived: Array[String] = []


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _fail(msg: String) -> void:
	_failed = true
	push_error("run_pickups_smoke: " + msg)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _wait(sec: float) -> void:
	await create_timer(sec).timeout


func _run() -> void:
	_gs = get_root().get_node("GameState")
	_gs.set("skip_debug_season_unlock", true)
	_gs.set("tutorial_complete", true)
	_gs.set("active_season_id", "country_bloom")
	_gs.call("begin_campaign_run")
	_check_data()
	var run := (load(RUN_SCENE) as PackedScene).instantiate()
	get_root().add_child(run)
	await _frames(40)
	var player: Node2D = run.get_node("Player")
	var hit := Callable(run, "_on_player_hit_obstacle")
	if player.is_connected("hit_obstacle", hit):
		player.disconnect("hit_obstacle", hit)
	run.set_process(false)
	for c in run.get_node("World").get_children():
		c.free()
	var fx: PickupFx = run.get("_pickup_fx")
	if fx == null:
		_fail("run has no PickupFx")
		_quit(1)
		return
	if fx.get_index() != player.get_index() + 1 or run.get_node("PickupFxUnder").get_index() != player.get_index() - 1:
		_fail("PickupFx must sit right after Player and PickupFxUnder right before it")
	if fx.z_index <= int(player.get_node("PipVisual").z_index):
		_fail("over layer must draw above Pip (z %d vs %d)" % [fx.z_index, player.get_node("PipVisual").z_index])
	fx.touch_started.connect(func(t: PickupFx.Touch) -> void: _events.append(t.ev_id))
	fx.pill_arrived.connect(func(t: PickupFx.Touch) -> void: _arrived.append(t.ev_id))
	await _check_idle(run)
	await _check_coin_flow(run, fx, player)
	await _check_streak(run, fx, player)
	await _check_seeds(run, fx, player)
	await _check_priority(run, fx, player)
	await _check_budget(run, fx, player)
	await _check_magnet(run, fx, player)
	var peak := fx.max_sprites()
	run.queue_free()
	await _frames(3)
	if _failed:
		_quit(1)
		return
	print("run_pickups_smoke OK (max %d sprites live)" % peak)
	_quit(0)


func _check_data() -> void:
	var d := PickupArt.data()
	for id in ["coin_n1", "coin_n5", "seed_r1", "seed_r2_twin", "seed_r3", "seed_r3_twin"]:
		if not d["events"].has(id):
			_fail("pickup_fx.json missing event %s" % id)
	for ev in d["events"].values():
		var n := (ev["sprites"] as Array).size() + 1
		if n > 8:
			_fail("%s has %d sprites with the pill (budget 8)" % [ev["id"], n])
		if float(ev["len"]) > 0.4 + 0.001:
			_fail("%s lasts %.2f s (budget 0.4)" % [ev["id"], float(ev["len"])])
	for r in d["regions"]:
		if PickupArt.tex(str(r)) == null:
			_fail("atlas region %s does not load" % r)
	var anims: Dictionary = {}
	for a in (JSON.parse_string(FileAccess.get_file_as_string("res://data/pip/animations.json")) as Dictionary)["list"]:
		anims[str(a["id"])] = a
	for id in ["pickup_coin", "pickup_seed", "pickup_seed_rare", "pickup_twin"]:
		if not anims.has(id):
			_fail("Pip animation %s missing" % id)
		elif str(anims[id]["layer"]) != "overlay" or float(anims[id]["length"]) > 0.4:
			_fail("Pip %s must be an overlay ≤ 0.4 s" % id)
		elif not is_equal_approx(float(anims[id]["length"]), float(UiRun.PIP_PICKUP_LEN.get(id, -1.0))):
			_fail("UiRun.PIP_PICKUP_LEN[%s] out of sync with animations.json" % id)


func _check_idle(run: Node) -> void:
	var lanes: Array = run.get("lane_x_positions")
	var coin: Node2D = (run.get("_coin_scene") as PackedScene).instantiate()
	coin.position = Vector2(float(lanes[0]), 400)
	run.get_node("World").add_child(coin)
	var seeds: Array[Node] = []
	for r in [1, 2, 3]:
		var s: Node2D = (run.get("_seed_scene") as PackedScene).instantiate()
		s.position = Vector2(float(lanes[1]), 300 + r * 200)
		s.call("setup", "clover", r)
		run.get_node("World").add_child(s)
		seeds.append(s)
	await _frames(3)
	var cv: Node = coin.get_node("CoinVisual")
	if cv.get_child_count() != 3:
		_fail("coin idle should be 3 sprites, got %d" % cv.get_child_count())
	var idle: Dictionary = PickupArt.data()["idle"]["seed"]
	for i in 3:
		var want := (idle[str(i + 1)]["sprites"] as Array).size()
		var got := seeds[i].get_node("SeedVisual").find_children("*", "Sprite2D", true, false).size()
		if got != want:
			_fail("seed ★%d idle should be %d sprites, got %d" % [i + 1, want, got])
	for v in [cv, seeds[0].get_node("SeedVisual")]:
		for c in (v as Node).get_children():
			if not (c is Sprite2D):
				_fail("idle child %s is not a Sprite2D" % c.name)
	# Idle je živ: novčić se vremenom okrene (frejm coin_edge) a sadnica se njiše.
	var saw_edge := false
	var sap: Sprite2D = seeds[0].get_node("SeedVisual").get_child(2) as Sprite2D
	var r0 := sap.rotation
	var t_end := Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < t_end:
		await process_frame
		if (cv.get_child(1) as Sprite2D).texture == PickupArt.tex("coin_edge"):
			saw_edge = true
	if not saw_edge:
		_fail("coin idle never flips to coin_edge")
	if is_equal_approx(sap.rotation, r0):
		_fail("sapling does not sway")
	for c in run.get_node("World").get_children():
		c.free()


func _spawn_coin(run: Node, pos: Vector2) -> Node:
	var coin: Node2D = (run.get("_coin_scene") as PackedScene).instantiate()
	coin.position = pos
	coin.connect("collected", Callable(run, "_on_coin_collected"))
	run.get_node("World").add_child(coin)
	return coin


func _spawn_seed(run: Node, pos: Vector2, type_id: String) -> Node:
	var s: Node2D = (run.get("_seed_scene") as PackedScene).instantiate()
	s.position = pos
	s.call("setup", type_id, int(_gs.call("get_seed_rarity", type_id)))
	s.connect("collected", Callable(run, "_on_seed_collected"))
	run.get_node("World").add_child(s)
	return s


func _label_int(run: Node, path: String) -> int:
	return int((run.get(path) as Label).text)


func _check_coin_flow(run: Node, fx: PickupFx, player: Node2D) -> void:
	_events.clear()
	_arrived.clear()
	var before := int(run.get("coin_count"))
	var shown := _label_int(run, "coin_counter_label")
	_spawn_coin(run, player.position + Vector2(0, -120)).call("collect")
	if int(run.get("coin_count")) != before + 1:
		_fail("coin must count at collect()")
	if _label_int(run, "coin_counter_label") != shown:
		_fail("coin chip must not change before the pill arrives")
	await _wait(0.08)
	if not _events.is_empty():
		_fail("event started during the magnet flight")
	await _wait(0.6)
	if _events != ["coin_n1"]:
		_fail("single coin should play coin_n1, got %s" % str(_events))
	if _arrived != ["coin_n1"]:
		_fail("pill did not arrive, got %s" % str(_arrived))
	if _label_int(run, "coin_counter_label") != shown + 1:
		_fail("coin chip should show +1 after arrival")
	if fx.active_touches() != 0:
		_fail("touch not cleaned up")
	await _wait(0.7)


func _check_streak(run: Node, fx: PickupFx, player: Node2D) -> void:
	_events.clear()
	for i in 6:
		_spawn_coin(run, player.position + Vector2(0, -60)).call("collect")
		await _wait(0.15)
	await _wait(0.8)
	var want := ["coin_n1", "coin_n2", "coin_n3", "coin_n4", "coin_n5", "coin_n5"]
	if _events != want:
		_fail("coin streak should rise to n5, got %s" % str(_events))
	_events.clear()
	_spawn_coin(run, player.position + Vector2(0, -60)).call("collect")
	await _wait(0.6)
	if _events != ["coin_n1"]:
		_fail("streak must reset after > 0.6 s, got %s" % str(_events))
	await _wait(0.5)


func _check_seeds(run: Node, fx: PickupFx, player: Node2D) -> void:
	_events.clear()
	_arrived.clear()
	var at := to_global_hack(run, player.position + Vector2(0, -80))
	fx.start_seed("clover", 3, 2, at)
	await _wait(0.75)
	if _events != ["seed_r3_twin"]:
		_fail("★3 twin should play seed_r3_twin, got %s" % str(_events))
	_events.clear()
	fx.start_seed("clover", 2, 1, at)
	await _wait(0.75)
	if _events != ["seed_r2"]:
		_fail("★2 should play seed_r2, got %s" % str(_events))
	_events.clear()
	var shown := _label_int(run, "seed_counter_label")
	var bag_before := int(run.call("_sum_run_seeds"))
	_spawn_seed(run, player.position + Vector2(0, -80), "clover").call("collect")
	var added := int(run.call("_sum_run_seeds")) - bag_before
	if added < 1:
		_fail("seed must count at collect()")
	if _label_int(run, "seed_counter_label") != shown:
		_fail("seed chip must wait for the pill")
	await _wait(0.8)
	if _label_int(run, "seed_counter_label") != shown + added:
		_fail("seed chip should rise by %d after arrival" % added)
	var toasts: PackedStringArray = (run.get("pickup_feed") as Node).call("get_toast_texts")
	if toasts.is_empty():
		_fail("seed name toast should pop on arrival")
	await _wait(0.4)


func to_global_hack(run: Node, local: Vector2) -> Vector2:
	return (run as Node2D).to_global(local)


func _check_priority(run: Node, fx: PickupFx, player: Node2D) -> void:
	var at := to_global_hack(run, player.position + Vector2(0, -50))
	fx.start_seed("clover", 3, 1, at)
	await _wait(0.2)
	if int(run.get("_pip_pick_prio")) != int(PickupArt.data()["pip_priority"]["pickup_seed_rare"]):
		_fail("★3 should play pickup_seed_rare")
	fx.start_coin(at)
	await _wait(0.2)
	if int(run.get("_pip_pick_prio")) != int(PickupArt.data()["pip_priority"]["pickup_seed_rare"]):
		_fail("coin must not interrupt pickup_seed_rare")
	await _wait(0.8)


func _count_visible(root: Node) -> int:
	var n := 0
	for layer in root.get_children():
		for s in layer.get_children():
			if s is Sprite2D and (s as Sprite2D).visible:
				n += 1
	return n


func _count_nodes(root: Node) -> int:
	var n := 0
	for layer in root.get_children():
		n += layer.get_child_count()
	return n


func _check_budget(run: Node, fx: PickupFx, player: Node2D) -> void:
	var under: Node = run.get_node("PickupFxUnder")
	var at := to_global_hack(run, player.position + Vector2(0, -50))
	# Zagrij: dva kruga najtežeg miksa, pa broj čvorova mora ostati isti.
	for pass_i in 3:
		if pass_i == 2:
			fx.set("_max_sprites", 0)
		var nodes_before := _count_nodes(fx) + _count_nodes(under)
		for k in 3:
			fx.start_seed("clover", 3, 2 if k == 0 else 1, at)
			fx.start_coin(at)
		var peak := 0
		for _i in 50:
			await process_frame
			peak = maxi(peak, _count_visible(fx) + _count_visible(under))
		await _wait(0.6)
		if pass_i == 2:
			if _count_nodes(fx) + _count_nodes(under) != nodes_before:
				_fail("warm pool still creates sprites per touch (%d → %d)" % [nodes_before, _count_nodes(fx) + _count_nodes(under)])
			if fx.max_sprites() > 48:
				_fail("6 concurrent touches used %d sprites (budget 8 each)" % fx.max_sprites())
	if _count_visible(fx) + _count_visible(under) != 0:
		_fail("sprites left visible after all touches ended")
	if fx.active_touches() != 0:
		_fail("touches left after budget run")


func _check_magnet(run: Node, fx: PickupFx, player: Node2D) -> void:
	var pv: Node2D = player.get_node("PipVisual")
	var ring: Node2D = pv.get_node("MagnetRing")
	var r0 := ring.rotation_degrees
	await _wait(0.3)
	if is_equal_approx(ring.rotation_degrees, r0):
		_fail("magnet ring should rotate 18°/s")
	fx.start_coin(to_global_hack(run, player.position + Vector2(0, -150)))
	var pulsed := false
	for _i in 6:
		await process_frame
		pulsed = pulsed or ring.scale.x > 1.0
	if not pulsed:
		print("debug pull ", fx.get_pull(), " pv fx ", pv.get("_pickup_fx"), " scale ", ring.scale)
		_fail("magnet ring should pulse when it catches a pickup")
	await _wait(0.8)
