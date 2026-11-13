extends SceneTree

## FIX-TEL-2 (2026-11-12) — run:
##  1. kontakt glavom: coin / sjeme / prepreka se „pikne" kad dotakne Pipovu GLAVU (crtež seže
##     71 px ispred sredine), a ne tek tijelo; predmet koji još nije stigao do glave se ne broji;
##  2. „Keep running": meni se zatvori, ide 3 → 2 → 1, staza stoji dok ne završi; pauza usred
##     odbrojavanja ga prekida; Android back na pauzi radi isto što i dugme.

var _backup: String = ""
var _failed: bool = false
var _hits: int = 0


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_test")


func _fail(msg: String) -> void:
	push_error("run_head_contact_smoke: %s" % msg)
	_failed = true


func _quit() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("run_head_contact_smoke OK")
	quit(1 if _failed else 0)


func _physics(n: int) -> void:
	for _i in n:
		await physics_frame
	await process_frame


func _test() -> void:
	await process_frame
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene did not load")
		_quit()
		return
	for _i in 20:
		await process_frame
	var run := current_scene
	var player := run.get_node("Player") as Area2D
	var world := run.get_node("World") as Node2D
	# Staza stoji (pauza bez menija): predmete postavljamo ručno.
	run.set("_state", 2)
	run.call("_clear_world_entities")
	await _physics(2)

	# Oblik Pipa: od vrha glave (−64) do starog donjeg ruba (+28).
	var pshape := player.get_node("CollisionShape2D") as CollisionShape2D
	var prect := pshape.shape as RectangleShape2D
	var top := pshape.position.y - prect.size.y * 0.5
	var bottom := pshape.position.y + prect.size.y * 0.5
	if absf(top + 64.0) > 0.5 or absf(bottom - 28.0) > 0.5 or absf(prect.size.x - 56.0) > 0.5:
		_fail("Pip collision should span y −64…+28, w 56 (got %.0f…%.0f, w %.0f)" % [top, bottom, prect.size.x])
	# Glava crteža: nos na −47,5 % kutije (box 150 → −71 px). Kolizija mora stići do glave.
	if top > -60.0:
		_fail("Pip collision does not reach the head")

	var coin_scene := load("res://scenes/run/coin.tscn") as PackedScene
	var seed_scene := load("res://scenes/run/seed_pickup.tscn") as PackedScene
	var obstacle_scene := load("res://scenes/run/obstacle.tscn") as PackedScene
	var at := player.position

	# 1a · coin tik ispred glave (crtež još ne dodiruje nos) → ne broji se.
	var c0 := int(run.get("coin_count"))
	var far := coin_scene.instantiate() as Area2D
	far.position = at + Vector2(0.0, -125.0)
	far.connect("collected", Callable(run, "_on_coin_collected"))
	world.add_child(far)
	await _physics(4)
	if int(run.get("coin_count")) != c0:
		_fail("a coin still ahead of the head was collected")
	# 1b · coin na glavi (centar 96 px ispred sredine: daleko od starog tijela 28 + r 18) → broji se.
	far.position = at + Vector2(0.0, -96.0)
	await _physics(4)
	if int(run.get("coin_count")) != c0 + 1:
		_fail("a coin touching the head was not collected")

	# 1c · sjeme na glavi.
	var s0 := int(run.get("_pending_seeds"))
	var seed := seed_scene.instantiate() as Area2D
	seed.position = at + Vector2(0.0, -86.0)
	if seed.has_method("setup"):
		seed.call("setup", "clover", 1)
	seed.connect("collected", Callable(run, "_on_seed_collected"))
	world.add_child(seed)
	await _physics(4)
	var seeds: Dictionary = run.get("seeds_by_type")
	if seeds.is_empty() and int(run.get("_pending_seeds")) == s0:
		_fail("a seed touching the head was not collected")

	# 1d · prepreka: ispred glave ne udara, na glavi udara. Signal brojimo sami (kontroler bi
	# završio run), pa prvo otkačimo njegov handler.
	for conn in player.get_signal_connection_list("hit_obstacle"):
		player.disconnect("hit_obstacle", conn["callable"])
	player.connect("hit_obstacle", func() -> void: _hits += 1)
	var ob := obstacle_scene.instantiate() as Area2D
	ob.position = at + Vector2(0.0, -150.0)
	world.add_child(ob)
	await _physics(4)
	if _hits != 0:
		_fail("an obstacle still ahead of the head counted as a hit")
	# Donji rub nacrtanog tijela (+69) je tada na −46: glava (do −71) ga dodiruje.
	ob.position = at + Vector2(0.0, -115.0)
	await _physics(4)
	if _hits != 1:
		_fail("an obstacle touching the head did not hit (hits %d)" % _hits)
	# Prepreka u susjednoj stazi nikad ne udara.
	_hits = 0
	ob.position = at + Vector2(270.0, -40.0)
	await _physics(4)
	if _hits != 0:
		_fail("an obstacle in the next lane hit Pip")
	run.call("_clear_world_entities")
	await _physics(2)

	# 2 · odbrojavanje poslije pauze.
	run.set("_state", 0)
	run.call("_on_pause_pressed")
	if not bool(run.call("is_paused")):
		_fail("pause did not open")
	run.call("_on_keep_running")
	var cd = run.get("resume_countdown")
	if bool(run.call("is_paused")) or not bool(run.call("is_resuming")) or int(cd.call("shown_number")) != 3:
		_fail("Keep running should close the menu and show 3 (shown %d)" % int(cd.call("shown_number")))
	var e0 := float(run.get("elapsed"))
	var seen := {}
	var total := float(cd.call("total_sec"))
	var t := 0.0
	while t < total - 0.05:
		run.call("_process", 0.05)
		t += 0.05
		seen[int(cd.call("shown_number"))] = true
	if not (seen.has(3) and seen.has(2) and seen.has(1)):
		_fail("countdown should show 3, 2, 1 (saw %s)" % str(seen.keys()))
	if not bool(run.call("is_resuming")) or absf(float(run.get("elapsed")) - e0) > 0.001:
		_fail("the run must stand still during the countdown")
	run.call("_process", 0.1)
	if bool(run.call("is_resuming")) or bool(run.call("is_paused")) or cd.visible:
		_fail("the run should resume when the countdown ends")
	run.call("_process", 0.05)
	if float(run.get("elapsed")) <= e0:
		_fail("the run clock should move again after the countdown")
	# Pauza usred odbrojavanja → nazad na meni; Back = Keep running.
	run.call("_on_pause_pressed")
	run.call("_on_keep_running")
	run.call("_process", 0.3)
	run.call("_on_pause_pressed")
	if not bool(run.call("is_paused")) or cd.visible:
		_fail("pausing during the countdown should bring the menu back")
	run.call("_notification", Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	if not bool(run.call("is_resuming")):
		_fail("Android back on pause should start the countdown")
	run.call("_on_quit_to_camp")
	_quit()
