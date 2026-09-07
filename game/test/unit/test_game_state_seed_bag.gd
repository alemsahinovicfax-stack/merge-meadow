## Characterizes GameState's current seed-bag behavior (game_state.gd ~1911-1948)
## BEFORE the Stage 4.3 Seed-bag domain extraction (plan-arhitektura-refaktor.md).
extends "res://test/unit/game_state_test_base.gd"

var _seed_bag_before: Dictionary


func before_each() -> void:
	super.before_each()
	_seed_bag_before = _gs.seed_bag.duplicate()
	_gs.seed_bag = {}


func after_each() -> void:
	_gs.seed_bag = _seed_bag_before
	super.after_each()


func test_add_seeds_to_bag_adds_new_type() -> void:
	var added: int = _gs.add_seeds_to_bag("clover", 5)
	assert_eq(added, 5, "should report how many were actually added")
	assert_eq(int(_gs.seed_bag.get("clover", 0)), 5)


func test_add_seeds_to_bag_respects_soft_cap() -> void:
	# SEED_BAG_SOFT_CAP is 40 (game_state.gd:29) at time of writing this test.
	var cap: int = _gs.SEED_BAG_SOFT_CAP
	_gs.add_seeds_to_bag("clover", cap - 2)
	var added: int = _gs.add_seeds_to_bag("daisy", 10)
	assert_eq(added, 2, "should only add up to remaining capacity, not the full request")
	assert_eq(_gs.seed_bag_remaining_capacity(), 0)


func test_add_seeds_to_bag_ignores_non_positive_count() -> void:
	assert_eq(_gs.add_seeds_to_bag("clover", 0), 0)
	assert_eq(_gs.add_seeds_to_bag("clover", -3), 0)
	assert_false(_gs.seed_bag.has("clover"), "a non-positive add must not create the key at all")


func test_add_seeds_to_bag_unbounded_ignores_soft_cap() -> void:
	var cap: int = _gs.SEED_BAG_SOFT_CAP
	_gs.add_seeds_to_bag("clover", cap)
	var added: int = _gs.add_seeds_to_bag_unbounded("clover", 25)
	assert_eq(added, 25, "unbounded add must add the full amount even over the soft cap")
	assert_eq(int(_gs.seed_bag.get("clover", 0)), cap + 25)


func test_take_seeds_from_bag_removes_partial_amount() -> void:
	_gs.seed_bag = {"clover": 10}
	var ok: bool = _gs.take_seeds_from_bag("clover", 4)
	assert_true(ok)
	assert_eq(int(_gs.seed_bag.get("clover", 0)), 6)


func test_take_seeds_from_bag_erases_key_when_emptied() -> void:
	_gs.seed_bag = {"clover": 4}
	_gs.take_seeds_from_bag("clover", 4)
	assert_false(_gs.seed_bag.has("clover"), "taking the exact remaining count should erase the key")


func test_take_seeds_from_bag_fails_when_insufficient() -> void:
	_gs.seed_bag = {"clover": 2}
	var ok: bool = _gs.take_seeds_from_bag("clover", 5)
	assert_false(ok)
	assert_eq(int(_gs.seed_bag.get("clover", 0)), 2, "a failed take must not partially remove")


func test_take_seed_from_bag_is_take_one() -> void:
	_gs.seed_bag = {"clover": 1}
	assert_true(_gs.take_seed_from_bag("clover"))
	assert_false(_gs.seed_bag.has("clover"))
