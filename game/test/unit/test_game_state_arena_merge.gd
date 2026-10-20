## MEAD-8 — merge čipova bez scene.
extends "res://test/unit/game_state_test_base.gd"


func after_each() -> void:
	super.after_each()
	_gs.load_player_save()


func _pair(tier_a: int, tier_b: int, same_type: bool) -> Dictionary:
	return {
		1: {"chip_id": 1, "type_id": "clover", "tier": tier_a, "pos": Vector2.ZERO},
		2: {
			"chip_id": 2,
			"type_id": "clover" if same_type else "daisy",
			"tier": tier_b,
			"pos": Vector2(8, 0),
		},
	}


func test_t1_plus_t1_becomes_t2() -> void:
	var chips := _pair(1, 1, true)
	var result: Dictionary = _gs.try_merge_arena_chips(1, 2, chips)
	assert_true(bool(result.get("ok", false)))
	assert_eq(int(result.get("new_tier", 0)), 2)
	assert_false(bool(result.get("crystal", false)))
	assert_false(chips.has(2))
	assert_eq(int(chips[1]["tier"]), 2)


func test_t2_plus_t2_becomes_crystal() -> void:
	var chips := _pair(2, 2, true)
	var result: Dictionary = _gs.try_merge_arena_chips(1, 2, chips)
	assert_true(bool(result.get("ok", false)))
	assert_eq(int(result.get("new_tier", 0)), 3)
	assert_true(bool(result.get("crystal", false)))
	assert_true(bool(_gs.discovered_blooms.get("clover", false)))


func test_different_types_do_not_merge() -> void:
	var chips := _pair(1, 1, false)
	var result: Dictionary = _gs.try_merge_arena_chips(1, 2, chips)
	assert_false(bool(result.get("ok", false)))
	assert_true(chips.has(1))
	assert_true(chips.has(2))


func test_same_chip_does_not_merge() -> void:
	var chips := _pair(1, 1, true)
	var result: Dictionary = _gs.try_merge_arena_chips(1, 1, chips)
	assert_false(bool(result.get("ok", false)))
	assert_true(chips.has(2))


func test_t3_plus_t3_does_not_merge() -> void:
	var chips := _pair(3, 3, true)
	var result: Dictionary = _gs.try_merge_arena_chips(1, 2, chips)
	assert_false(bool(result.get("ok", false)))
	assert_eq(chips.size(), 2)
