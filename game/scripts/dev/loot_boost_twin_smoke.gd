extends SceneTree

## Loot Boost i Twin Seeds od kupovine do kraja runa (2026-10-16, playtest: „kao da mi se ne
## aplicira"):
##  1. bonus na UKUPNO sjeme — ×1,25 na 5 različitih sjemenki = 6 (ranije po tipu: 5, bez bonusa);
##     nijedan tip ne gubi; coini round(raw × m); svih 5 nivoa;
##  2. kupovina na polju sezone diže multiplikator i twin nivo AKTIVNE sezone (run ih čita),
##     druga sezona ima svoje nivoe;
##  3. pravi run: pickupi → kraj runa → plijen = boost primijenjen jednom; Twin na nivou 0 nikad,
##     na nivou 4 ~32 % sjemenki; nagradni grm nije Twin; brojač twinova ide u kraj runa;
##  4. revive: run nastavlja sa sirovim brojevima, pa je boost na kraju primijenjen jednom
##     (ranije dvaput na sve prije pada);
##  5. loot ekran: zlatni pečat „Loot Boost ×1.25 · N twins", chipovi = plijen s boostom.

var _backup := ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("loot_boost_twin_smoke: %s" % msg)
	CampSmokeUtil.restore_save(self, _backup)
	quit(1)


func _sum(d: Dictionary) -> int:
	var t := 0
	for k in d:
		t += int(d[k])
	return t


## Očekivani ukupni broj poslije boosta.
func _boosted(total: int, mult: float) -> int:
	return maxi(total, int(round(float(total) * mult)))


func _wait_scene(script_has: String, frames: int = 400) -> Node:
	for _i in frames:
		await process_frame
		var cs := current_scene
		if cs != null and cs.has_method(script_has):
			if not ("_world_ready" in cs) or bool(cs.get("_world_ready")):
				return cs
	return null


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	var values: Array = gs.get("MULTIPLIER_VALUES")

	# ── 1. Skaliranje ─────────────────────────────────────────────────────────────────
	var cases := [
		{"clover": 1, "daisy": 1, "tulip": 1, "sunflower": 1, "buttercup": 1},
		{"clover": 3, "daisy": 1},
		{"clover": 7, "daisy": 2, "tulip": 1},
		{"clover": 1},
		{"clover": 12, "daisy": 9, "tulip": 4, "sunflower": 2},
	]
	for level in values.size():
		var mult := float(values[level])
		for c in cases:
			var out: Dictionary = gs.call("scale_loot_seeds", c, mult)
			var want := _boosted(_sum(c), mult)
			if _sum(out) != want:
				_fail("level %d %s: total %d, want %d" % [level, str(c), _sum(out), want])
				return
			for t in c:
				if int(out.get(t, 0)) < int(c[t]):
					_fail("level %d: type %s lost seeds (%d < %d)" % [level, t, int(out.get(t, 0)), int(c[t])])
					return
				if int(out.get(t, 0)) > int(ceil(float(c[t]) * mult)) + 1:
					_fail("level %d: type %s got too much (%d)" % [level, t, int(out.get(t, 0))])
					return
		for coins in [0, 1, 7, 10, 33]:
			var sc := int(gs.call("scale_loot_coins", coins, mult))
			if sc != _boosted(coins, mult):
				_fail("level %d coins %d → %d, want %d" % [level, coins, sc, _boosted(coins, mult)])
				return
	var five: Dictionary = gs.call("scale_loot_seeds", cases[0], float(values[1]))
	if _sum(five) != 6:
		_fail("×1.25 on 5 single seeds must give 6, got %d" % _sum(five))
		return
	var same: Dictionary = gs.call("scale_loot_seeds", cases[2], 1.0)
	if same != cases[2]:
		_fail("×1.0 must not change anything: %s" % str(same))
		return

	# ── 2. Kupovina na polju → aktivna sezona ─────────────────────────────────────────
	gs.call("reset_seasons_to_s1")
	gs.set("season_upgrades", {})
	gs.call("apply_active_upgrade_levels")
	var season := str(gs.get("active_season_id"))
	var flower := str(gs.call("star3_type_id_for_season", season))
	gs.set("garden_crystal_stash", {flower: 40})
	gs.set("wallet_coins", 10000)
	gs.set("home_season_field_open", true)
	gs.set("home_season_field_id", season)
	if not is_equal_approx(float(gs.call("get_loot_multiplier")), 1.0) or int(gs.call("get_twin_seeds_level")) != 0:
		_fail("fresh season should start at ×1.0 and twin 0")
		return
	for lvl in range(1, 5):
		if not bool(gs.call("try_upgrade_multiplier", "")):
			_fail("Loot Boost buy %d failed" % lvl)
			return
		if int(gs.get("multiplier_level")) != lvl or not is_equal_approx(float(gs.call("get_loot_multiplier")), float(values[lvl])):
			_fail("Loot Boost level %d should give ×%s, got level %s ×%s" % [lvl, values[lvl], gs.get("multiplier_level"), gs.call("get_loot_multiplier")])
			return
	if bool(gs.call("try_upgrade_multiplier", "")):
		_fail("Loot Boost must stop at max")
		return
	for lvl in range(1, 3):
		if not bool(gs.call("try_upgrade_twin")) or int(gs.call("get_twin_seeds_level")) != lvl:
			_fail("Twin buy %d failed" % lvl)
			return
	# Druga sezona ima svoje nivoe; povratak vraća ove.
	var unlocked: Array = gs.get("unlocked_seasons")
	if not unlocked.has("frost_orchard"):
		unlocked.append("frost_orchard")
	gs.set("unlocked_seasons", unlocked)
	gs.call("set_active_season", "frost_orchard")
	if int(gs.get("multiplier_level")) != 0 or int(gs.call("get_twin_seeds_level")) != 0:
		_fail("Frost must have its own (zero) levels")
		return
	gs.call("set_active_season", season)
	if int(gs.get("multiplier_level")) != 4 or int(gs.call("get_twin_seeds_level")) != 2:
		_fail("returning to %s must restore Loot 4 / Twin 2" % season)
		return

	# ── 3. Pravi run: pickupi, Twin, kraj ─────────────────────────────────────────────
	gs.set("tutorial_complete", true)
	gs.set("season_upgrades", {season: {"magnet": 0, "loot": 1, "twin": 0}})
	gs.call("apply_active_upgrade_levels")
	gs.set("resume_pending", false)
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene load failed")
		return
	var run: Node = await _wait_scene("_on_seed_collected")
	if run == null:
		_fail("run scene did not become ready")
		return
	run.set("_state", 2)  # pauza: spawn i prepreke stoje, pickupi se zovu ručno
	var types := ["clover", "daisy", "tulip", "sunflower", "buttercup"]
	seed(4242)
	for t in types:
		run.call("_on_seed_collected", t, Vector2(540, 1500))
	for _c in 7:
		run.call("_on_coin_collected", Vector2(540, 1500))
	if int(run.get("twin_count")) != 0 or _sum(run.get("seeds_by_type")) != 5:
		_fail("Twin level 0 must never double (twins %s, seeds %s)" % [run.get("twin_count"), str(run.get("seeds_by_type"))])
		return
	# Twin nivo 4 (32 %): 300 sjemenki.
	gs.set("season_upgrades", {season: {"magnet": 0, "loot": 1, "twin": 4}})
	seed(777)
	var before := _sum(run.get("seeds_by_type"))
	for i in 300:
		run.call("_on_seed_collected", types[i % types.size()], Vector2(540, 1500))
	var twins := int(run.get("twin_count"))
	var gained := _sum(run.get("seeds_by_type")) - before
	if twins < 66 or twins > 126:
		_fail("Twin level 4 should double ~32 %% of 300, got %d" % twins)
		return
	if gained != 300 + twins:
		_fail("each twin adds exactly 1 extra seed: gained %d, twins %d" % [gained, twins])
		return
	# Nagradni grm nije Twin.
	var bush: Node = run.call("_spawn_bush", 0, -80.0)
	var twins_before_bush := int(run.get("twin_count"))
	bush.set("reward_kind", "seed")
	bush.set("reward_amount", 3)
	var seeds_before_bush := _sum(run.get("seeds_by_type"))
	run.call("_on_bush_collected", bush)
	if int(run.get("twin_count")) != twins_before_bush or _sum(run.get("seeds_by_type")) != seeds_before_bush + 3:
		_fail("reward bush must add exactly its amount and never twin")
		return
	var raw_seeds: Dictionary = (run.get("seeds_by_type") as Dictionary).duplicate()
	var raw_coins := int(run.get("coin_count"))
	var mult1 := float(values[1])
	run.set("_state", 0)  # _STATE_RUNNING — _end_run ga prebaci u ENDED
	run.call("_end_run", false)
	var got_seeds: Dictionary = gs.get("last_seed_bag")
	if _sum(got_seeds) != _boosted(_sum(raw_seeds), mult1):
		_fail("run loot should be ×1.25 once: %d raw → %d, want %d" % [_sum(raw_seeds), _sum(got_seeds), _boosted(_sum(raw_seeds), mult1)])
		return
	if int(gs.get("last_run_coins")) != _boosted(raw_coins, mult1):
		_fail("run coins should be round(%d × 1.25) = %d, got %s" % [raw_coins, _boosted(raw_coins, mult1), gs.get("last_run_coins")])
		return
	if int(gs.get("last_run_twins")) != twins or not is_equal_approx(float(gs.get("last_loot_multiplier")), mult1):
		_fail("finish_run must record twins %d and ×1.25 for the loot screen" % twins)
		return

	# ── 5. Loot ekran: pečat i chipovi ────────────────────────────────────────────────
	var loot: Node = await _wait_scene("get_boost_stamp", 900)
	if loot == null:
		_fail("loot screen did not open after the run")
		return
	var stamp := str(loot.call("get_boost_stamp"))
	if stamp.find("Loot Boost ×1.25") < 0 or stamp.find("%d twins" % twins) < 0:
		_fail("loot stamp should show Loot Boost ×1.25 and %d twins, got '%s'" % [twins, stamp])
		return
	var all_text := str(loot.call("get_all_text"))
	if all_text.find("Loot Boost ×1.25") < 0:
		_fail("the boost stamp must be drawn on the tray: '%s'" % all_text)
		return
	var chip_total := 0
	for chip in loot.call("get_chips"):
		if str(chip.get("kind")) == "seed":
			chip_total += int(chip.get("count"))
	if chip_total != _sum(got_seeds):
		_fail("seed chips (%d) must show the boosted loot (%d)" % [chip_total, _sum(got_seeds)])
		return
	# Bez boosta i twinova nema pečata.
	gs.set("last_loot_multiplier", 1.0)
	gs.set("last_run_twins", 0)
	if not str(loot.call("get_boost_stamp")).is_empty():
		_fail("no boost and no twins → no gold stamp")
		return

	# ── 4. Revive: boost se primijeni jednom ──────────────────────────────────────────
	gs.call("begin_fresh_run")
	gs.set("season_upgrades", {season: {"magnet": 0, "loot": 2, "twin": 0}})
	gs.call("apply_active_upgrade_levels")
	gs.set("revive_used_this_run", false)
	gs.set("loot_doubled", false)
	gs.set("resume_pending", false)
	var mult2 := float(values[2])
	if change_scene_to_file("res://scenes/run/run_scene.tscn") != OK:
		_fail("run scene reload failed")
		return
	run = await _wait_scene("_on_seed_collected")
	if run == null:
		_fail("second run did not become ready")
		return
	run.set("_state", 2)
	for t in ["clover", "clover", "daisy"]:
		run.call("_on_seed_collected", t, Vector2(540, 1500))
	for _c2 in 10:
		run.call("_on_coin_collected", Vector2(540, 1500))
	var pre_seeds: Dictionary = (run.get("seeds_by_type") as Dictionary).duplicate()
	var pre_coins := int(run.get("coin_count"))
	run.set("_state", 0)  # _STATE_RUNNING — _end_run ga prebaci u ENDED
	run.call("_end_run", true)
	var raw_carry: Dictionary = gs.get("carry_raw_seed_bag")
	if raw_carry != pre_seeds or int(gs.get("carry_raw_coins")) != pre_coins:
		_fail("fail must keep the raw (unboosted) carry: %s / %s" % [str(raw_carry), gs.get("carry_raw_coins")])
		return
	await create_timer(0.3).timeout
	if not bool(gs.call("request_revive")):
		_fail("revive should be allowed")
		return
	run = await _wait_scene("_on_seed_collected", 900)
	if run == null or int(run.get("coin_count")) != pre_coins or run.get("seeds_by_type") != pre_seeds:
		_fail("revived run must continue from the raw counts (coins %s, seeds %s)" % [
			run.get("coin_count") if run else "?", str(run.get("seeds_by_type")) if run else "?"])
		return
	run.set("_state", 2)
	run.call("_on_seed_collected", "tulip", Vector2(540, 1500))
	for _c3 in 4:
		run.call("_on_coin_collected", Vector2(540, 1500))
	run.set("_state", 0)  # _STATE_RUNNING — _end_run ga prebaci u ENDED
	run.call("_end_run", false)
	var total_raw := _sum(pre_seeds) + 1
	if _sum(gs.get("last_seed_bag")) != _boosted(total_raw, mult2):
		_fail("revive: ×1.5 once on %d seeds = %d, got %d" % [total_raw, _boosted(total_raw, mult2), _sum(gs.get("last_seed_bag"))])
		return
	if int(gs.get("last_run_coins")) != _boosted(pre_coins + 4, mult2):
		_fail("revive: coins ×1.5 once on %d = %d, got %s" % [pre_coins + 4, _boosted(pre_coins + 4, mult2), gs.get("last_run_coins")])
		return

	print("loot_boost_twin_smoke OK (twins %d / 300 at level 4)" % twins)
	CampSmokeUtil.restore_save(self, _backup)
	quit(0)
