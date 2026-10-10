extends SceneTree

## Run HUD v2 (design_handoff_run_hud_v2): header u jednom redu (Level · coin · seed · pauza),
## tekst za level / Endless / tutorial, traka napretka (0 / 50 / 90 / 100 %, sakrivena u Endlessu),
## bez dijamanata (izbačeni 2026-10-09), nagradni grm (šav 405 / 675, prvi posle 6 s, jedan na ekranu,
## nikad u tutorial runu 1, fer razmak ±300 px, pokupi se samo prelazom — magnet ga ignoriše,
## nagrada 3–5 coina / 1–2 sjemena, burst ≤ 12 spriteova).
## Tipovi RewardBush / RunProgressRail se ne spominju statički (zavise od GameState autoloada).

const TOL := 2.0

var _backup := ""
var _failed := false
var _gs: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("run_hud_v2_smoke: " + msg)


func _near(what: String, got: float, want: float, tol: float = TOL) -> void:
	if absf(got - want) > tol:
		_fail("%s: got %.1f expected %.1f" % [what, got, want])


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _physics(n: int) -> void:
	for _i in n:
		await physics_frame


func _run() -> void:
	_gs = get_root().get_node("GameState")
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("begin_campaign_run")
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene failed to load")
		_finish()
		return
	await _frames(20)
	var run := current_scene
	if run == null or not run.has_method("start_run"):
		_fail("run scene missing")
		_finish()
		return
	# Zamrzni sat i svijet (paused) — testovi pomjeraju traku i grm ručno.
	run.set("_state", 2)
	_check_header(run)
	_check_modes(run)
	_check_rail(run)
	_check_no_diamonds(run)
	_check_bush_rules(run)
	await _check_bush_cross(run)
	await _check_bush_magnet(run)
	_finish()


func _check_header(run: Node) -> void:
	var want := {
		"HUD/TopHud/LevelChip": UiRun.LEVEL_CHIP_RECT,
		"HUD/TopHud/CoinChip": UiRun.COIN_CHIP_RECT,
		"HUD/TopHud/SeedChip": UiRun.SEED_CHIP_RECT,
		"HUD/TopHud/PauseButton": UiRun.PAUSE_RECT,
	}
	for path in want:
		var c := run.get_node_or_null(path) as Control
		var r: Rect2 = want[path]
		if c == null:
			_fail("%s missing" % path)
			continue
		_near(path + " x", c.position.x, r.position.x)
		_near(path + " y", c.position.y, float(UiRun.TOP_HUD_Y))
		_near(path + " h", c.size.y, float(UiRun.TOP_HUD_H))
		if path != "HUD/TopHud/LevelChip":
			_near(path + " w", c.size.x, r.size.x)
	var level := run.get_node("HUD/TopHud/LevelChip") as Control
	if level.size.x < UiRun.LEVEL_CHIP_RECT.size.x - TOL or level.size.x > UiRun.LEVEL_CHIP_MAX_W + TOL:
		_fail("LevelChip width %.1f outside 200–464" % level.size.x)
	if level.position.x + level.size.x > UiRun.COIN_CHIP_RECT.position.x:
		_fail("LevelChip overlaps CoinChip")
	# Label mora nositi cijeli tekst (playtest capture: overrun ga je sveo na širinu 0).
	var ml := run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	var font := ml.get_theme_font("font")
	var tw := font.get_string_size(ml.text, HORIZONTAL_ALIGNMENT_LEFT, -1, ml.get_theme_font_size("font_size")).x
	if ml.text.is_empty() or ml.size.x + 1.0 < tw:
		_fail("ModeLabel '%s' is %.1f wide, text needs %.1f" % [ml.text, ml.size.x, tw])
	for gone in ["HUD/TopHud/TimerChip", "HUD/TopHud/CompanionChip", "HUD/TopHud/BasketBadge",
			"HUD/TopHud/PickupBar"]:
		if run.get_node_or_null(gone) != null:
			_fail("%s should be deleted" % gone)
	for lbl in ["HUD/TopHud/CoinChip/Row/CoinLabel", "HUD/TopHud/SeedChip/Row/SeedLabel"]:
		var l := run.get_node(lbl) as Label
		if l.get_theme_font_size("font_size") != UiRun.FONT_COUNTER:
			_fail("%s font %d != 56" % [lbl, l.get_theme_font_size("font_size")])
	var feed := run.get_node("HUD/TopHud/PickupFeed") as Control
	_near("PickupFeed toast center x", feed.position.x + 344.0, 806.0)
	_near("PickupFeed y", feed.position.y, 214.0)


func _mode(run: Node) -> Array:
	run.call("_update_hud")
	var label := run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	var flag := run.get_node("HUD/TopHud/LevelChip/Row/FlagIcon") as CanvasItem
	var rail := run.get_node("HUD/TopHud/ProgressRail") as CanvasItem
	return [label.text, flag.visible, rail.visible, label.get_theme_font_size("font_size"), label.clip_text]


func _check_modes(run: Node) -> void:
	_gs.set("run_level", 12)
	var m := _mode(run)
	if m[0] != "Level 12" or not m[1] or not m[2] or m[3] != 48:
		_fail("level mode → %s" % str(m))
	_gs.set("run_is_endless", true)
	for d in [0, 1, 2]:
		_gs.set("endless_difficulty", d)
		m = _mode(run)
		var want := "Endless · %s" % ["Easy", "Normal", "Hard"][d]
		if m[0] != want or m[1] or m[2] or m[3] != 42 or m[4]:
			_fail("endless %d → %s (want text, no flag, no rail, 42 px, not clipped)" % [d, str(m)])
	_gs.set("run_is_endless", false)
	_gs.set("tutorial_complete", false)
	m = _mode(run)
	if m[0] != "Practice" or not m[1] or not m[2]:
		_fail("tutorial run → %s (want Practice + flag + rail)" % str(m))
	_gs.set("tutorial_complete", true)
	_mode(run)


func _check_rail(run: Node) -> void:
	var rail := run.get_node("HUD/TopHud/ProgressRail") as Control
	_near("rail x", rail.position.x, UiRun.RAIL_RECT.position.x)
	_near("rail y", rail.position.y, UiRun.RAIL_RECT.position.y)
	if rail.position.x + rail.size.x > float(UiRun.TRACK_LEFT):
		_fail("rail reaches into the lanes (ends %.1f, lanes from %d)" % [rail.position.x + rail.size.x, UiRun.TRACK_LEFT])
	var marker := rail.get_node("ProgressPip") as Control
	var fill := rail.get_node("RailTrack/RailFill") as Control
	var ring := rail.get_node("FinishRing") as CanvasItem
	rail.call("reset")
	for p in [0.0, 0.5, 0.9, 1.0]:
		rail.call("set_progress", p)
		var cy := rail.position.y + marker.position.y + marker.size.y * 0.5
		_near("pip center y @%.0f%%" % (p * 100.0), cy, 1700.0 - 1400.0 * p)
		_near("pip center x", rail.position.x + marker.position.x + marker.size.x * 0.5, UiRun.RAIL_PIP_CENTER_X)
		var low := bool(rail.call("is_low"))
		if low != (p >= 0.9):
			_fail("rail fill colour @%.0f%% low=%s" % [p * 100.0, str(low)])
	_near("fill full height", fill.size.y, 1388.0)
	if ring.visible:
		_fail("finish ring should wait for finish()")
	rail.call("finish")
	if not ring.visible:
		_fail("finish ring should show at 100 %")
	rail.call("reset")
	if ring.visible or not is_zero_approx(fill.size.y):
		_fail("reset should clear the finish ring and the fill")


## Dijamanti su izbačeni iz igre (2026-10-09): nema pickupa, popa ni walleta.
func _check_no_diamonds(run: Node) -> void:
	if run.get_node_or_null("HUD/DiamondPop") != null or run.has_method("_on_diamond_collected"):
		_fail("run still has a diamond pickup / pop")
	if _gs.has_method("get_diamonds") or "wallet_diamonds" in _gs:
		_fail("GameState still has a diamond wallet")
	if ResourceLoader.exists("res://assets/ui/chrome/icon_diamond.svg"):
		_fail("icon_diamond.svg should be deleted")


func _clear_world(run: Node) -> void:
	for child in run.get_node("World").get_children():
		child.free()
	run.set("_bush", null)


func _check_bush_rules(run: Node) -> void:
	_near("seam 0", UiRun.bush_seam_x(0, 1080.0), 405.0, 0.1)
	_near("seam 1", UiRun.bush_seam_x(1, 1080.0), 675.0, 0.1)
	for i in 10:
		for j in 10:
			var r := UiRun.roll_bush_reward(float(i) / 10.0, float(j) / 10.0)
			var n := int(r["amount"])
			if r["kind"] == "coin" and (n < 3 or n > 5):
				_fail("coin bush amount %d" % n)
			if r["kind"] == "seed" and (n < 1 or n > 2):
				_fail("seed bush amount %d" % n)
			if (r["kind"] == "coin") != (float(i) / 10.0 < 0.6):
				_fail("bush reward weight broke at roll %.1f" % (float(i) / 10.0))

	_clear_world(run)
	run.set("_next_bush_at", UiRun.BUSH_FIRST_AFTER)
	run.set("elapsed", 5.0)
	var spawned := int(run.get("bushes_spawned"))
	run.call("_update_bush_spawn")
	if int(run.get("bushes_spawned")) != spawned:
		_fail("bush spawned before 6 s")
	run.set("elapsed", 6.2)
	run.call("_update_bush_spawn")
	if int(run.get("bushes_spawned")) != spawned + 1:
		_fail("bush did not spawn after 6 s")
	var bush := run.get("_bush") as Node2D
	if bush == null or not (is_equal_approx(bush.position.x, 405.0) or is_equal_approx(bush.position.x, 675.0)):
		_fail("bush not on a seam: %s" % (str(bush.position) if bush else "null"))
	var gap := float(run.get("_next_bush_at")) - 6.2
	if gap < UiRun.BUSH_GAP_MIN - 0.01 or gap > UiRun.BUSH_GAP_MAX + 0.01:
		_fail("next bush gap %.2f outside 8–12 s" % gap)
	run.set("elapsed", 40.0)
	run.call("_update_bush_spawn")
	if int(run.get("bushes_spawned")) != spawned + 1:
		_fail("a second bush spawned while one is on screen")

	# Fer: prepreka u susjednoj stazi ±300 px blokira šav; grm blokira prepreke uz sebe.
	_clear_world(run)
	run.call("_spawn_obstacle_at_lane", 0)
	if not bool(run.call("_obstacle_near_seam", 0, -80.0)) or bool(run.call("_obstacle_near_seam", 1, -80.0)):
		_fail("obstacle in lane 0 should block seam 405 only")
	_clear_world(run)
	var b2: Node2D = run.call("_spawn_bush", 1, -80.0)
	if not bool(run.call("_bush_blocks_lane", 1, -80.0)) or not bool(run.call("_bush_blocks_lane", 2, 100.0)):
		_fail("bush at seam 675 should block lanes 1 and 2 within 300 px")
	if bool(run.call("_bush_blocks_lane", 0, -80.0)) or bool(run.call("_bush_blocks_lane", 2, 300.0)):
		_fail("bush should not block lane 0 or anything 300+ px away")
	if b2 == null or b2.get_node_or_null("Visual/Back") == null or b2.get_node_or_null("Visual/Front") == null:
		_fail("bush should have Back / Reward / Front parts")

	# Tutorial run 1: nikad.
	_clear_world(run)
	_gs.set("tutorial_complete", false)
	_gs.set("tutorial_step", 0)
	run.set("elapsed", 30.0)
	run.set("_next_bush_at", 6.0)
	spawned = int(run.get("bushes_spawned"))
	run.call("_update_bush_spawn")
	if int(run.get("bushes_spawned")) != spawned:
		_fail("bush spawned in tutorial run 1")
	_gs.set("tutorial_complete", true)


## Vidljivi dijelovi bursta (pool u HUD/FlyLayer/BushBurst).
func _fx_count(run: Node) -> int:
	var fx := run.get_node_or_null("HUD/FlyLayer/BushBurst")
	return int(fx.call("active_parts")) if fx else 0


func _check_bush_cross(run: Node) -> void:
	_clear_world(run)
	var player := run.get_node("Player") as Node2D
	player.call("reset_lane")
	var bush: Node2D = run.call("_spawn_bush", 0, player.position.y)
	bush.set("reward_kind", "coin")
	bush.set("reward_amount", 5)
	var coins := int(run.get("coin_count"))
	var collected := int(run.get("bushes_collected"))
	await _physics(6)
	if int(run.get("bushes_collected")) != collected:
		_fail("bush collected while Pip stayed in his lane")
		return
	player.set("lane_index", 0)
	player.call("_apply_lane", true)
	var fx := 0
	for _i in 30:
		await physics_frame
		fx = maxi(fx, _fx_count(run))
		if int(run.get("bushes_collected")) != collected:
			break
	await process_frame
	fx = maxi(fx, _fx_count(run))
	if int(run.get("bushes_collected")) != collected + 1:
		_fail("crossing the seam over the bush did not collect it")
		return
	if int(run.get("coin_count")) != coins + 5:
		_fail("coin bush should add 5 coins (got +%d)" % (int(run.get("coin_count")) - coins))
	if fx < 8 or fx > 12:
		_fail("bush burst sprites %d (want ring + 6 leaves + ≤ 4, max 12)" % fx)
	await create_timer(0.8).timeout
	if _fx_count(run) != 0:
		_fail("bush fx should clean up after ~0.6 s")


func _check_bush_magnet(run: Node) -> void:
	_clear_world(run)
	var player := run.get_node("Player") as Node2D
	player.call("reset_lane")
	await _physics(4)
	player.call("set_magnet_radius", 232.0)
	var collected := int(run.get("bushes_collected"))
	run.call("_spawn_bush", 0, player.position.y)
	await _physics(8)
	if int(run.get("bushes_collected")) != collected:
		_fail("magnet pulled the bush (it must ignore it)")
	player.call("set_magnet_radius", float(_gs.call("get_magnet_radius")))


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if _failed:
		quit(1)
		return
	print("run_hud_v2_smoke OK")
	quit(0)
