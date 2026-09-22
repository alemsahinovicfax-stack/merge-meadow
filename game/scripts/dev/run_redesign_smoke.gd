extends SceneTree

## Run redizajn (smjer A, design_handoff_run) na 1080×1920:
## fiksan TimerChip, brojevi ≥ 44, Pause ≥ 120, lane field, magnet 0 vs 2,
## kolizije netaknute, stump+stone, Quit = fail loot bez revivea.

const SAVE_PATH := "user://player_save.json"
const TOLERANCE := 2.0

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var gs := get_root().get_node_or_null("GameState")
	var backup := _backup_save()
	if gs == null:
		_fail("GameState missing")
		_finish(backup, null)
		return
	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		_fail("run load failed %d" % err)
		_finish(backup, gs)
		return
	for _i in 20:
		await process_frame
	var run := current_scene
	if run == null or not str(run.scene_file_path).ends_with("run_scene.tscn"):
		_fail("wrong scene")
		_finish(backup, gs)
		return
	_check_rules(run, gs)
	_check_layout(run)
	_check_timer_stable(run, gs)
	_check_collisions()
	_check_obstacles(run)
	_check_lanes(run)
	_check_magnet(run, gs)
	await _check_collect(run)
	await _check_pause_quit(run, gs)
	_finish(backup, gs)


func _check_rules(run: Node, gs: Node) -> void:
	var run_map: Dictionary = run.get_script().get_script_constant_map()
	_expect_eq("scroll", run_map.get("BASE_SCROLL_SPEED", -1), 400.0)
	_expect_eq("spawn interval", run_map.get("SPAWN_INTERVAL", -1), 1.2)
	_expect_eq("spawn chance", run_map.get("SPAWN_CHANCE", -1), 0.7)
	_expect_eq("obstacle chance", run_map.get("OBSTACLE_CHANCE", -1), 0.25)
	_expect_eq("seed chance", run_map.get("PICKUP_SEED_CHANCE", -1), 0.30)
	_expect_eq("diamond ratio", run_map.get("DIAMOND_SEED_RATIO", -1), 300)
	var player := run.get_node_or_null("Player")
	if player == null:
		_fail("player missing")
		return
	var player_map: Dictionary = player.get_script().get_script_constant_map()
	_expect_eq("swipe tween", player_map.get("LANE_TWEEN_DURATION", -1), 0.12)
	_expect_eq("swipe threshold", player_map.get("SWIPE_THRESHOLD", -1), 50.0)
	_expect_eq("magnet 0", float(gs.call("get_magnet_radius_for_level", 0)), 40.0)
	_expect_eq("magnet 2", float(gs.call("get_magnet_radius_for_level", 2)), 136.0)
	_expect_eq("magnet 4", float(gs.call("get_magnet_radius_for_level", 4)), 232.0)
	if UiRun.FAIL_TOTAL > 0.5:
		_fail("fail beat %.2f exceeds 0.5s" % UiRun.FAIL_TOTAL)
	var lanes: Array = run.get("lane_x_positions")
	if lanes.size() != 3:
		_fail("expected 3 lanes, got %d" % lanes.size())


func _check_layout(run: Node) -> void:
	var chip := run.get_node_or_null("HUD/TopHud/TimerChip") as Control
	if chip == null:
		_fail("TimerChip missing")
		return
	var scale := _scale(run)
	_expect_near("TimerChip w", chip.size.x, UiRun.TIMER_RECT.size.x * scale)
	_expect_near("TimerChip h", chip.size.y, UiRun.TIMER_RECT.size.y * scale)
	var pause := run.get_node_or_null("HUD/TopHud/PauseButton") as Control
	if pause == null or pause.size.x < 120.0 * scale - TOLERANCE or pause.size.y < 120.0 * scale - TOLERANCE:
		_fail("Pause hit %.1f×%.1f < 120" % [pause.size.x if pause else -1, pause.size.y if pause else -1])
	var seconds := run.get_node_or_null("HUD/TopHud/TimerChip/Row/TextCol/SecondsLabel") as Label
	var mode := run.get_node_or_null("HUD/TopHud/TimerChip/Row/TextCol/ModeLabel") as Label
	var coin := run.get_node_or_null("HUD/TopHud/PickupBar/CoinChip/Row/CoinLabel") as Label
	if seconds == null or mode == null or coin == null:
		_fail("timer or counter labels missing")
		return
	if seconds.get_theme_font_size("font_size") < 44:
		_fail("seconds font %d < 44" % seconds.get_theme_font_size("font_size"))
	if mode.get_theme_font_size("font_size") < 38:
		_fail("mode font %d < 38" % mode.get_theme_font_size("font_size"))
	if coin.get_theme_font_size("font_size") < 44:
		_fail("counter font %d < 44" % coin.get_theme_font_size("font_size"))
	var guides := run.get_node_or_null("LaneGuides") as CanvasItem
	if guides == null or guides.visible:
		_fail("LaneGuides should stay hidden; lanes are the background")
	var feed := run.get_node_or_null("HUD/TopHud/PickupFeed")
	if feed == null or feed is Label:
		_fail("PickupFeed should be the toast control, not a text dump")


func _check_timer_stable(run: Node, gs: Node) -> void:
	var was_endless: bool = bool(gs.get("run_is_endless"))
	var was_diff: int = int(gs.get("endless_difficulty"))
	var chip := run.get_node_or_null("HUD/TopHud/TimerChip") as Control
	var mode := run.get_node_or_null("HUD/TopHud/TimerChip/Row/TextCol/ModeLabel") as Label
	gs.set("run_is_endless", true)
	gs.set("endless_difficulty", 2)
	run.call("_update_hud")
	var h_endless := chip.size.y
	if mode.text != "Endless · Hard":
		_fail("endless mode line got '%s'" % mode.text)
	if mode.get_minimum_size().x > mode.size.x + 4.0:
		_fail("Endless · Hard does not fit (min %.1f > width %.1f)" % [mode.get_minimum_size().x, mode.size.x])
	gs.set("run_is_endless", false)
	run.call("_update_hud")
	if absf(chip.size.y - h_endless) > TOLERANCE:
		_fail("TimerChip jumped %.1f → %.1f when leaving endless" % [h_endless, chip.size.y])
	gs.set("run_is_endless", was_endless)
	gs.set("endless_difficulty", was_diff)
	run.call("_update_hud")
	gs.set("wallet_diamonds", 0)
	run.call("_update_hud")
	var diamond := run.get_node_or_null("HUD/TopHud/PickupBar/DiamondChip") as CanvasItem
	if diamond == null or diamond.visible:
		_fail("diamond counter should hide at 0")
	gs.set("wallet_diamonds", 2)
	run.call("_update_hud")
	if diamond == null or not diamond.visible:
		_fail("diamond counter should show when wallet > 0")
	gs.set("wallet_diamonds", 0)
	run.call("_update_hud")


func _check_collisions() -> void:
	var obstacle := (load("res://scenes/run/obstacle.tscn") as PackedScene).instantiate()
	var shape := obstacle.get_node("CollisionShape2D").shape as RectangleShape2D
	if shape == null or shape.size != Vector2(64, 64):
		_fail("obstacle collision changed from 64×64")
	obstacle.free()
	var coin := (load("res://scenes/run/coin.tscn") as PackedScene).instantiate()
	var coin_shape := coin.get_node("CollisionShape2D").shape as CircleShape2D
	if coin_shape == null or not is_equal_approx(coin_shape.radius, 18.0):
		_fail("coin collision radius changed")
	coin.free()
	var seed := (load("res://scenes/run/seed_pickup.tscn") as PackedScene).instantiate()
	var seed_shape := seed.get_node("CollisionShape2D").shape as CircleShape2D
	if seed_shape == null or not is_equal_approx(seed_shape.radius, 26.0):
		_fail("seed collision radius changed")
	seed.free()
	var diamond := (load("res://scenes/run/diamond_pickup.tscn") as PackedScene).instantiate()
	var diamond_shape := diamond.get_node("CollisionShape2D").shape as CircleShape2D
	if diamond_shape == null or not is_equal_approx(diamond_shape.radius, 18.0):
		_fail("diamond collision radius changed")
	diamond.free()


func _check_obstacles(run: Node) -> void:
	for child in run.get_node("World").get_children():
		child.free()
	run.set("_next_obstacle_stump", false)
	run.call("_spawn_obstacle_at_lane", 0)
	run.call("_spawn_obstacle_at_lane", 2)
	var kinds: Array[String] = []
	for child in run.get_node("World").get_children():
		if not child.is_in_group("obstacle") or not ("kind" in child):
			continue
		kinds.append(str(child.kind))
		if str(child.kind) == "hay":
			_fail("hay should not spawn in v1")
	if kinds.size() != 2 or kinds[0] != "stone" or kinds[1] != "stump":
		_fail("v1 obstacles should alternate stone then stump, got %s" % str(kinds))


func _check_lanes(run: Node) -> void:
	var bg := run.get_node_or_null("Background")
	if bg == null or not bg.has_method("add_scroll") or not bg.has_method("apply_theme"):
		_fail("lane field missing add_scroll/apply_theme")
		return
	var before := float(bg.get("_scroll_px"))
	bg.call("add_scroll", 124.0)
	var after := float(bg.get("_scroll_px"))
	if is_equal_approx(before, after):
		_fail("lane stripes should scroll with scroll_speed")


func _check_magnet(run: Node, gs: Node) -> void:
	var player := run.get_node("Player")
	var pip := player.get_node("PipVisual")
	var saved := int(gs.get("magnet_level"))
	gs.set("magnet_level", 0)
	player.call("set_magnet_radius", gs.call("get_magnet_radius"))
	var r0 := float(pip.get("_magnet_radius"))
	gs.set("magnet_level", 2)
	player.call("set_magnet_radius", gs.call("get_magnet_radius"))
	var r2 := float(pip.get("_magnet_radius"))
	gs.set("magnet_level", saved)
	player.call("set_magnet_radius", gs.call("get_magnet_radius"))
	if not is_equal_approx(r0, 40.0) or r2 <= r0 + 40.0:
		_fail("magnet ring should grow from level 0 (%.1f) to level 2 (%.1f)" % [r0, r2])
	var collision := player.get_node("MagnetField/CollisionShape2D").shape as CircleShape2D
	if collision == null or not is_equal_approx(collision.radius, float(gs.call("get_magnet_radius"))):
		_fail("magnet collision must stay on the formula, not the pulse")


func _check_collect(run: Node) -> void:
	for child in run.get_node("World").get_children():
		child.free()
	var coins_before := int(run.get("coin_count"))
	var coin := (load("res://scenes/run/coin.tscn") as PackedScene).instantiate()
	coin.position = Vector2(540, 400)
	coin.collected.connect(run._on_coin_collected)
	run.get_node("World").add_child(coin)
	coin.collect()
	var seed := (load("res://scenes/run/seed_pickup.tscn") as PackedScene).instantiate()
	seed.position = Vector2(270, 500)
	seed.setup("clover", 3)
	seed.collected.connect(run._on_seed_collected)
	run.get_node("World").add_child(seed)
	seed.collect()
	for _i in 6:
		await process_frame
	if int(run.get("coin_count")) != coins_before + 1:
		_fail("coin collect did not increment the run counter")
	var bag: Dictionary = run.get("seeds_by_type")
	if int(bag.get("clover", 0)) < 1:
		_fail("seed collect did not enter the run bag")


func _check_pause_quit(run: Node, gs: Node) -> void:
	var rev_before := bool(gs.get("revive_used_this_run"))
	run.call("_on_pause_pressed")
	if int(run.get("_state")) != 2:
		_fail("pause did not freeze the run")
		return
	var elapsed_before := float(run.get("elapsed"))
	for _i in 8:
		await process_frame
	if not is_equal_approx(float(run.get("elapsed")), elapsed_before):
		_fail("paused run kept the clock running")
	run.call("_on_quit_to_camp")
	await create_timer(1.0).timeout
	for _i in 10:
		await process_frame
	if bool(gs.get("revive_used_this_run")) != rev_before:
		_fail("quit must not spend a revive")
	if not bool(gs.get("last_failed")):
		_fail("quit should resolve as a failed run (50% loot)")
	var scene := current_scene
	if scene == null or not str(scene.scene_file_path).ends_with("loot_screen.tscn"):
		_fail("quit should open the loot scene")


func _scale(run: Node) -> float:
	return run.get_viewport().get_visible_rect().size.x / 1080.0


func _expect_eq(what: String, got: Variant, want: Variant) -> void:
	if got != want:
		_fail("%s: got %s expected %s" % [what, str(got), str(want)])


func _expect_near(what: String, got: float, want: float) -> void:
	if absf(got - want) > TOLERANCE:
		_fail("%s: got %.1f expected %.1f" % [what, got, want])


func _fail(msg: String) -> void:
	_failed = true
	push_error("run_redesign_smoke: " + msg)


func _backup_save() -> String:
	if not FileAccess.file_exists(SAVE_PATH):
		return ""
	return FileAccess.get_file_as_string(SAVE_PATH)


func _finish(backup: String, gs: Node) -> void:
	if not backup.is_empty():
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_string(backup)
			f.close()
		if gs:
			gs.call("load_player_save")
	elif gs:
		gs.call("load_player_save")
	if _failed:
		quit(1)
		return
	print("run_redesign_smoke OK")
	quit(0)
