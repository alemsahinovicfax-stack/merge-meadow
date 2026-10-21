## Balans ciklus 1 (2026-10-21): rijetkost sjemena, par prepreka, Endless otključavanje / rekord i
## plijen poslije pada. Krivulja levela i Endless rampa: scripts/dev/economy_balance_smoke.gd.
extends "res://test/unit/game_state_test_base.gd"

const POOL: Array[String] = ["a", "b", "c", "d", "e", "f"]
const RAR: Array[int] = [1, 1, 1, 2, 2, 3]


func after_each() -> void:
	super.after_each()
	_gs.run_is_endless = false
	_gs.load_player_save()


func _shares(r2: float, r3: float, n: int) -> Dictionary:
	var counts := {1: 0, 2: 0, 3: 0}
	for i in n:
		var t := RunBalance.pick_weighted(POOL, RAR, r2, r3, (float(i) + 0.5) / n)
		var r: int = RAR[POOL.find(t)]
		counts[r] = int(counts[r]) + 1
	return counts


func test_weighted_pick_matches_formula() -> void:
	var counts := _shares(0.4, 0.12, 10000)
	for r in [1, 2, 3]:
		var want := RunBalance.rarity_share(RAR, r, 0.4, 0.12)
		assert_almost_eq(float(counts[r]) / 10000.0, want, 0.005, "★%d share" % r)


func test_star3_rarer_than_any_single_star1_type() -> void:
	# Ravnomjerno (stari izbor) je ★3 bio 1/6 = isto kao svaki ★1 tip.
	var star3 := RunBalance.rarity_share(RAR, 3, RunBalance.BASE_RARE2, RunBalance.BASE_RARE3)
	var one_star1 := RunBalance.rarity_share(RAR, 1, RunBalance.BASE_RARE2, RunBalance.BASE_RARE3) / 3.0
	assert_lt(star3, one_star1 / 3.0)
	assert_lt(star3, 1.0 / 6.0)


func test_uniform_weights_keep_old_behaviour() -> void:
	assert_almost_eq(RunBalance.rarity_share(RAR, 3, 1.0, 1.0), 1.0 / 6.0, 0.0001)


func test_pick_edges() -> void:
	assert_eq(RunBalance.pick_weighted([] as Array[String], [] as Array[int], 1.0, 1.0, 0.3), "")
	assert_eq(RunBalance.pick_weighted(POOL, RAR, 0.4, 0.12, 0.0), "a")
	assert_eq(RunBalance.pick_weighted(POOL, RAR, 0.4, 0.12, 0.999999), "f")


func test_pair_lane_is_always_another_lane() -> void:
	for lane in 3:
		var seen := {}
		for k in 20:
			var other := RunBalance.pair_lane(lane, float(k) / 20.0)
			assert_ne(other, lane)
			assert_between(other, 0, 2)
			seen[other] = true
		assert_eq(seen.size(), 2, "both other lanes should be possible from %d" % lane)


func test_endless_unlocks_after_level_15_per_season() -> void:
	var d: LevelPathDomain = _gs.level_path_domain
	d.set_level("lantern_meadow", LevelPathDomain.ENDLESS_UNLOCK_LEVEL)
	d.set_level("amber_canopy", LevelPathDomain.ENDLESS_UNLOCK_LEVEL + 1)
	assert_false(_gs.is_endless_unlocked("lantern_meadow"))
	assert_true(_gs.is_endless_unlocked("amber_canopy"))
	d.set_level("lantern_meadow", LevelPathDomain.COMPLETE)
	assert_true(_gs.is_endless_unlocked("lantern_meadow"))


func test_endless_best_keeps_longest_and_saves() -> void:
	var d: LevelPathDomain = _gs.level_path_domain
	d.endless_best.erase("coral_tide")
	assert_true(d.record_endless("coral_tide", 120.0))
	assert_false(d.record_endless("coral_tide", 90.0))
	assert_true(d.record_endless("coral_tide", 121.5))
	var copy := LevelPathDomain.new(_gs)
	copy.apply_from_save(d.to_save_dict())
	assert_almost_eq(copy.endless_best_of("coral_tide"), 121.5, 0.001)


func test_endless_fall_keeps_all_loot_level_fall_keeps_half() -> void:
	_gs.tutorial_complete = true
	_gs.multiplier_level = 0
	_gs.run_is_endless = false
	_gs.begin_fresh_run()
	_gs.finish_run({"clover": 7}, 9, true, 40.0)
	assert_eq(_gs.last_run_coins, 5)
	assert_eq(int(_gs.last_seed_bag.get("clover", 0)), 4)
	_gs.run_is_endless = true
	_gs.begin_fresh_run()
	_gs.finish_run({"clover": 7}, 9, true, 140.0)
	assert_eq(_gs.last_run_coins, 9)
	assert_eq(int(_gs.last_seed_bag.get("clover", 0)), 7)
	assert_true(_gs.last_run_endless)
	assert_almost_eq(float(_gs.last_endless_sec), 140.0, 0.001)
