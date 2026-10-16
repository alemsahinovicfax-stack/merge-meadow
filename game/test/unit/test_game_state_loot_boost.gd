## Loot Boost i Twin Seeds (2026-10-16): matematika plijena na kraju runa.
## Integracija u pravom runu: scripts/dev/loot_boost_twin_smoke.gd.
extends "res://test/unit/game_state_test_base.gd"

const SINGLES := {"clover": 1, "daisy": 1, "tulip": 1, "sunflower": 1, "buttercup": 1}


func after_each() -> void:
	super.after_each()
	# Save fajl je vraćen — vrati i stanje u memoriji (nivoi, novčanik, carry).
	_gs.load_player_save()


func _sum(d: Dictionary) -> int:
	var t := 0
	for k in d:
		t += int(d[k])
	return t


func test_multiplier_values_per_level() -> void:
	var want := [1.0, 1.25, 1.5, 1.75, 2.0]
	for level in want.size():
		assert_almost_eq(float(_gs.get_loot_multiplier_for_level(level)), float(want[level]), 0.0001)


func test_five_single_seeds_get_the_bonus() -> void:
	# Ranije (po tipu): 1 × 1,25 = 1 za svaki tip → 5, bez ikakvog bonusa.
	var out: Dictionary = _gs.scale_loot_seeds(SINGLES, 1.25)
	assert_eq(_sum(out), 6)


func test_scaled_total_is_exact_and_no_type_loses() -> void:
	var cases := [SINGLES, {"clover": 3, "daisy": 1}, {"clover": 7, "daisy": 2, "tulip": 1}, {"clover": 1}]
	for mult in [1.0, 1.25, 1.5, 1.75, 2.0]:
		for c in cases:
			var out: Dictionary = _gs.scale_loot_seeds(c, mult)
			var total := _sum(c)
			assert_eq(_sum(out), maxi(total, int(round(float(total) * mult))), "%s × %s" % [str(c), str(mult)])
			for t in c:
				assert_true(int(out.get(t, 0)) >= int(c[t]), "type %s must not lose seeds" % t)


func test_scale_is_identity_at_one() -> void:
	var c := {"clover": 4, "daisy": 2}
	assert_eq(_gs.scale_loot_seeds(c, 1.0), c)
	assert_eq(_gs.scale_loot_coins(9, 1.0), 9)


func test_scale_ignores_empty_types() -> void:
	var out: Dictionary = _gs.scale_loot_seeds({"clover": 0, "daisy": 2}, 1.5)
	assert_false(out.has("clover"))
	assert_eq(int(out.get("daisy", 0)), 3)


func test_coins_round_once() -> void:
	assert_eq(_gs.scale_loot_coins(10, 1.25), 13)
	assert_eq(_gs.scale_loot_coins(7, 1.5), 11)
	assert_eq(_gs.scale_loot_coins(0, 2.0), 0)


func test_finish_run_success_applies_boost_once() -> void:
	_gs.multiplier_level = 1
	_gs.wallet_coins = 0
	_gs.finish_run(SINGLES.duplicate(), 10, false, 30.0, 2)
	assert_eq(_sum(_gs.last_seed_bag), 6)
	assert_eq(_gs.last_run_coins, 13)
	assert_eq(_gs.wallet_coins, 13)
	assert_almost_eq(float(_gs.last_loot_multiplier), 1.25, 0.0001)
	assert_eq(_gs.last_run_twins, 2)


func test_finish_run_fail_keeps_half_of_boosted() -> void:
	_gs.multiplier_level = 2
	_gs.finish_run({"clover": 3, "daisy": 1}, 10, true, 12.0)
	# ×1,5 na 4 = 6 (clover 5, daisy 1); pola gore: 3 + 1. Coini: 15 → 8.
	assert_eq(int(_gs.carry_seed_bag.get("clover", 0)), 5)
	assert_eq(int(_gs.carry_seed_bag.get("daisy", 0)), 1)
	assert_eq(int(_gs.last_seed_bag.get("clover", 0)), 3)
	assert_eq(int(_gs.last_seed_bag.get("daisy", 0)), 1)
	assert_eq(_gs.carry_coins, 15)
	assert_eq(_gs.last_run_coins, 8)


func test_fail_keeps_raw_carry_for_revive() -> void:
	_gs.multiplier_level = 2
	_gs.finish_run({"clover": 2, "daisy": 1, "tulip": 0}, 10, true, 12.0, 1)
	assert_eq(_gs.carry_raw_seed_bag, {"clover": 2, "daisy": 1})
	assert_eq(_gs.carry_raw_coins, 10)
	assert_eq(_gs.carry_twins, 1)


func test_begin_fresh_run_clears_raw_carry() -> void:
	_gs.finish_run({"clover": 2}, 5, true, 3.0, 1)
	_gs.begin_fresh_run()
	assert_eq(_gs.carry_raw_seed_bag, {})
	assert_eq(_gs.carry_raw_coins, 0)
	assert_eq(_gs.carry_twins, 0)


func test_twin_chance_steps() -> void:
	var want := [0.0, 0.08, 0.16, 0.24, 0.32]
	for level in want.size():
		assert_almost_eq(UiCamp.twin_chance(level), float(want[level]), 0.0001)
	assert_almost_eq(UiCamp.twin_chance(9), 0.32, 0.0001, "clamped at max level")
