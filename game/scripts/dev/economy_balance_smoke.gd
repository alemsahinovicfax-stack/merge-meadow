extends SceneTree

## Balans ciklus 1 (2026-10-21) — pravila koja simulacija (economy_sim.gd) pretpostavlja:
##  1. leveli 1–20: duži (60 → 120 s), brži, više prepreka i parova, više plijena i rijetkog
##     sjemena — svaki level barem kao prethodni;
##  2. Endless: lagan start, stepenice svakih 20 s samo teže, bez tajmera, granice prepreka;
##  3. sjeme po rijetkosti: ★1 > ★2 > ★3 (udio iz RunBalance = stvarni izbor, 30 000 izvlačenja);
##  4. Endless sezone se otključa poslije levela 15; rekord po sezoni; pad u Endlessu čuva cijeli
##     plijen, pad u levelu pola;
##  5. par prepreka uvijek ostavi slobodnu stazu; max magnet dohvata susjednu stazu;
##  6. cijene: sezone i nadogradnje rastu, dugme nadogradnje stane i za najveću cijenu;
##  7. run u Endlessu: stepenica se primijeni na run, sat u čipu; pred kraj levela nema spawna
##     koji ne bi stigao do Pipa (u Endlessu uvijek ima).
## Pokretanje: godot --headless --path game -s res://scripts/dev/economy_balance_smoke.gd

var _backup := ""
var _failed := false
var _gs: Node
var _rll: Node


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _fail(msg: String) -> void:
	_failed = true
	push_error("economy_balance_smoke: " + msg)


func _finish() -> void:
	CampSmokeUtil.restore_save(self, _backup)
	if not _failed:
		print("economy_balance_smoke OK")
	quit(1 if _failed else 0)


func _frames(n: int) -> void:
	for _i in n:
		await process_frame


func _run() -> void:
	await _frames(2)
	_gs = get_root().get_node("GameState")
	_rll = get_root().get_node("RunLevelLibrary")
	_check_levels()
	_check_endless_ramp()
	_check_seed_weights()
	_check_endless_unlock_and_loot()
	_check_pairs_and_magnet()
	_check_prices()
	await _check_endless_run()
	_finish()


func _check_levels() -> void:
	var prev = null
	for n in range(1, 21):
		var c = _rll.call("get_level", n)
		if int(c.id) != n:
			_fail("level %d missing from levels.json" % n)
			return
		if prev != null:
			for f in ["duration_sec", "scroll_speed_mult", "speed_ramp", "obstacle_chance", "pair_chance",
					"pickup_seed_chance", "rare2_mult", "rare3_mult", "spawn_chance"]:
				if float(c.get(f)) < float(prev.get(f)) - 1e-6:
					_fail("level %d %s %.3f < level %d %.3f" % [n, f, float(c.get(f)), n - 1, float(prev.get(f))])
			if float(c.spawn_interval) > float(prev.spawn_interval) + 1e-6:
				_fail("level %d spawns slower than level %d" % [n, n - 1])
			if float(c.duration_sec) <= float(prev.duration_sec):
				_fail("level %d is not longer than level %d" % [n, n - 1])
		prev = c
	var l1 = _rll.call("get_level", 1)
	var l20 = _rll.call("get_level", 20)
	if float(l1.duration_sec) < 60.0 or float(l20.duration_sec) < 2.0 * float(l1.duration_sec) - 1.0:
		_fail("levels should run 60 s → 120 s, got %.0f → %.0f" % [l1.duration_sec, l20.duration_sec])
	for n in range(1, 6):
		if float(_rll.call("get_level", n).pair_chance) > 0.0:
			_fail("level %d should not have obstacle pairs yet" % n)
	if int(_rll.call("get_level", 57).id) != 20:
		_fail("levels above 20 should clamp to 20 (complete path replays 20)")


func _check_endless_ramp() -> void:
	var prev = null
	var tier_sec := float((_rll.get_script() as Script).get_script_constant_map().get("ENDLESS_TIER_SEC", 20.0))
	for i in 60:
		var t := i * tier_sec
		var c = _rll.call("get_endless_config_at", t + tier_sec * 0.5)
		if int(_rll.call("endless_tier", t + 0.1)) != i:
			_fail("endless tier at %.0f s should be %d" % [t, i])
		if not is_inf(float(c.duration_sec)) or float(c.speed_ramp) != 0.0:
			_fail("endless has no timer and steps speed only by tier")
		if prev != null:
			for f in ["scroll_speed_mult", "obstacle_chance", "pair_chance", "spawn_chance", "rare3_mult"]:
				if float(c.get(f)) < float(prev.get(f)) - 1e-6:
					_fail("endless %s drops at %.0f s" % [f, t])
			if float(c.spawn_interval) > float(prev.spawn_interval) + 1e-6:
				_fail("endless spawns slower at %.0f s" % t)
		if float(c.obstacle_chance) > 0.45 + 1e-6 or float(c.pair_chance) > 0.45 + 1e-6:
			_fail("endless obstacle caps broken at %.0f s" % t)
		if not (1.0 > float(c.rare2_mult) and float(c.rare2_mult) > float(c.rare3_mult)):
			_fail("endless at %.0f s: weights should stay ★1 > ★2 > ★3" % t)
		prev = c
	var start = _rll.call("get_endless_config_at", 0.0)
	var l3 = _rll.call("get_level", 3)
	if float(start.obstacle_chance) > float(l3.obstacle_chance) + 0.02 or float(start.pair_chance) > 0.0:
		_fail("endless should start easy (≈ level 2–3)")
	var late = _rll.call("get_endless_config_at", 600.0)
	var l20 = _rll.call("get_level", 20)
	if float(late.scroll_speed_mult) <= float(l20.scroll_speed_mult) or float(late.obstacle_chance) <= float(l20.obstacle_chance):
		_fail("endless after 10 min should be harder than level 20")


func _check_seed_weights() -> void:
	var pool: Array[String] = ["a1", "b1", "c1", "d2", "e2", "f3"]
	var rar: Array[int] = [1, 1, 1, 2, 2, 3]
	for n in [1, 10, 20]:
		var c = _rll.call("get_level", n)
		var r2 := float(c.rare2_mult)
		var r3 := float(c.rare3_mult)
		var counts := {1: 0, 2: 0, 3: 0}
		var draws := 30000
		for i in draws:
			var t := RunBalance.pick_weighted(pool, rar, r2, r3, (float(i) + 0.5) / draws)
			var r := rar[pool.find(t)]
			counts[r] = int(counts[r]) + 1
		for r in [1, 2, 3]:
			var want := RunBalance.rarity_share(rar, r, r2, r3)
			var got := float(counts[r]) / draws
			if absf(got - want) > 0.01:
				_fail("level %d ★%d share %.3f, formula %.3f" % [n, r, got, want])
		# Po tipu: svaki ★1 tip češći od svakog ★2, a ★2 od ★3.
		if not (1.0 > r2 and r2 > r3):
			_fail("level %d weights should be ★1 > ★2 > ★3 (1 / %.2f / %.2f)" % [n, r2, r3])
		if RunBalance.rarity_share(rar, 3, r2, r3) > 0.09:
			_fail("level %d: ★3 should be rare (≤ 9 %% of seeds)" % n)
	if not RunBalance.pick_weighted([] as Array[String], [] as Array[int], 1.0, 1.0, 0.5).is_empty():
		_fail("empty pool should give empty type")


func _check_endless_unlock_and_loot() -> void:
	var d: LevelPathDomain = _gs.get("level_path_domain")
	d.set_level("frost_orchard", LevelPathDomain.ENDLESS_UNLOCK_LEVEL)
	if bool(_gs.call("is_endless_unlocked", "frost_orchard")):
		_fail("Endless must stay locked while level 15 is not passed")
	d.set_level("frost_orchard", LevelPathDomain.ENDLESS_UNLOCK_LEVEL + 1)
	if not bool(_gs.call("is_endless_unlocked", "frost_orchard")):
		_fail("Endless should unlock once level 15 is passed")
	if bool(_gs.call("is_endless_unlocked", "lantern_meadow")) and d.level_of("lantern_meadow") <= 15:
		_fail("Endless unlock must be per season")
	# save round trip rekorda
	d.endless_best["frost_orchard"] = 0.0
	if not d.record_endless("frost_orchard", 91.5) or d.record_endless("frost_orchard", 80.0):
		_fail("record_endless should keep only a longer run")
	var copy := LevelPathDomain.new(_gs)
	copy.apply_from_save(d.to_save_dict())
	if absf(copy.endless_best_of("frost_orchard") - 91.5) > 0.01:
		_fail("endless best should survive save / load")
	# pad: level → pola, Endless → sve
	_gs.set("tutorial_complete", true)
	_gs.call("set_active_season", "country_bloom")
	_gs.set("multiplier_level", 0)
	_gs.set("run_is_endless", false)
	_gs.call("begin_fresh_run")
	_gs.call("finish_run", {"clover": 10}, 20, true, 30.0)
	if int(_gs.get("last_run_coins")) != 10 or int((_gs.get("last_seed_bag") as Dictionary).get("clover", 0)) != 5:
		_fail("level fail should keep half (10 coins, 5 seeds)")
	_gs.set("run_is_endless", true)
	var lvl_before := d.level_of("country_bloom")
	_gs.call("begin_fresh_run")
	_gs.call("finish_run", {"clover": 10}, 20, true, 75.0)
	if int(_gs.get("last_run_coins")) != 20 or int((_gs.get("last_seed_bag") as Dictionary).get("clover", 0)) != 10:
		_fail("Endless fall should keep everything (20 coins, 10 seeds)")
	if not bool(_gs.get("last_run_endless")) or absf(float(_gs.get("last_endless_sec")) - 75.0) > 0.01:
		_fail("finish_run should remember the Endless time")
	if d.level_of("country_bloom") != lvl_before:
		_fail("Endless must not move the Level Path")
	_gs.set("run_is_endless", false)
	_gs.call("begin_fresh_run")


func _check_pairs_and_magnet() -> void:
	for lane in 3:
		for k in 10:
			var other := RunBalance.pair_lane(lane, float(k) / 10.0)
			if other == lane or other < 0 or other > 2:
				_fail("pair lane %d → %d must be another lane" % [lane, other])
	var max_lv := int((_gs.get_script() as Script).get_script_constant_map().get("MAGNET_MAX_LEVEL", 4))
	var max_r := float(_gs.call("get_magnet_radius_for_level", max_lv))
	if max_r + 18.0 < 270.0:
		_fail("max magnet %.0f px should reach the next lane (270 px)" % max_r)
	if float(_gs.call("get_magnet_radius_for_level", max_lv - 1)) + 26.0 >= 270.0:
		_fail("only max magnet should reach the next lane")


func _check_prices() -> void:
	var prev := 0
	for def in SeasonCatalog.free_defs_sorted():
		if def.coins_cost <= 0:
			continue
		if def.coins_cost <= prev:
			_fail("free season %s should cost more than the one before" % def.id)
		if def.t3_flowers_required < 20:
			_fail("free season %s needs ≥ 20 ★3" % def.id)
		prev = def.coins_cost
	for lv in UiCamp.UP_LEVELS - 1:
		if UiCamp.upgrade_coin_cost(lv + 1) <= UiCamp.upgrade_coin_cost(lv) or UiCamp.upgrade_flower_cost(lv + 1) < UiCamp.upgrade_flower_cost(lv):
			_fail("upgrade level %d should cost more than %d" % [lv + 1, lv])
	if UiCamp.upgrade_state(2, 2, 100000) != UiCamp.UP_SHORT_FLOWER:
		_fail("level 3 upgrade needs %d ★3, 2 should be short" % UiCamp.upgrade_flower_cost(2))
	# Najskuplje dugme nadogradnje (cvijet + „×3" + coin + cijena) stane u 340 px. PopupButton se
	# učitava tek ovdje — zavisi od autoloada (SceneRouter), pa se ne smije spomenuti statički.
	var btn: Control = (load("res://scripts/ui/popup/popup_button.gd") as GDScript).new()
	btn.call("configure", "primary", "×%d" % UiCamp.upgrade_flower_cost(UiCamp.UP_LEVELS - 1))
	btn.call("set_art", "pumpkin", 3, 64.0)
	btn.set("coin_text", str(UiCamp.upgrade_coin_cost(UiCamp.UP_LEVELS - 1)))
	var w := float(btn.call("content_width"))
	if w > 340.0 - 24.0:
		_fail("upgrade button content %.0f px does not fit 340" % w)
	btn.free()


func _check_endless_run() -> void:
	_gs.set("tutorial_complete", true)
	_gs.set("skip_debug_season_unlock", true)
	_gs.call("begin_endless_run")
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene failed to load")
		return
	await _frames(20)
	var run := current_scene
	if run == null or not run.has_method("endless_tier"):
		_fail("run scene missing")
		return
	run.set("_state", 2)
	if int(run.call("endless_tier")) != 0:
		_fail("Endless should start on tier 0, got %d" % int(run.call("endless_tier")))
	if is_finite(float(_gs.call("get_run_duration"))):
		_fail("Endless must not have a timer")
	run.set("elapsed", 65.0)
	run.call("_update_endless_tier")
	var cfg = _rll.call("get_endless_config_at", 65.0)
	if int(run.call("endless_tier")) != 3 or absf(float(run.get("_obstacle_chance")) - float(cfg.obstacle_chance)) > 1e-6:
		_fail("tier 3 config should be live in the run at 65 s")
	if absf(float(run.get("_pair_chance")) - float(cfg.pair_chance)) > 1e-6:
		_fail("Endless pairs should follow the tier")
	run.call("_update_hud")
	var label := run.get_node("HUD/TopHud/LevelChip/Row/ModeLabel") as Label
	if label.text != "Endless · 1:05" or label.clip_text:
		_fail("Endless chip should show the clock, got '%s'" % label.text)
	run.set("elapsed", 3599.0)
	run.call("_update_hud")
	if label.text != "Endless · 59:59" or label.clip_text:
		_fail("long Endless clock should fit the chip, got '%s' clip %s" % [label.text, str(label.clip_text)])
	if not bool(run.call("_spawn_reaches_pip")):
		_fail("Endless has no end — spawns must never stop")
	# Kraj levela: ništa što ne bi stiglo do Pipa prije kraja (put 1654 px / 500 px/s ≈ 3,3 s).
	_gs.set("run_is_endless", false)
	_gs.set("run_level", 10)
	var dur := float(_gs.call("get_run_duration"))
	run.set("scroll_speed", 500.0)
	for row in [[10.0, true], [dur - 4.0, true], [dur - 2.0, false], [dur - 0.5, false]]:
		run.set("elapsed", float(row[0]))
		if bool(run.call("_spawn_reaches_pip")) != bool(row[1]):
			_fail("level end: at %.1f / %.0f s spawn open should be %s" % [float(row[0]), dur, str(row[1])])
