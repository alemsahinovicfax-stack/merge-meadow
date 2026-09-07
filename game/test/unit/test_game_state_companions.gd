## Characterizes GameState's current companion-unlock behavior (extracted into
## Companions at plan-arhitektura-refaktor.md Stage 4.1). Mochi unlocks at
## MOCHI_UNLOCK_CAMP_LEVEL camp progress (magnet_level + multiplier_level).
extends "res://test/unit/game_state_test_base.gd"

var _magnet_before: int
var _multiplier_before: int
var _active_before: String
var _mochi_seen_before: bool


func before_each() -> void:
	super.before_each()
	_magnet_before = _gs.magnet_level
	_multiplier_before = _gs.multiplier_level
	_active_before = _gs.get_active_companion_id()
	_mochi_seen_before = _gs.companions.mochi_unlock_seen


func after_each() -> void:
	_gs.magnet_level = _magnet_before
	_gs.multiplier_level = _multiplier_before
	_gs.companions.active_id = _active_before
	_gs.companions.mochi_unlock_seen = _mochi_seen_before
	super.after_each()


func test_pip_is_always_unlocked() -> void:
	assert_true(_gs.is_companion_unlocked(_gs.COMPANION_PIP))


func test_mochi_locked_below_camp_progress() -> void:
	_gs.magnet_level = 0
	_gs.multiplier_level = 0
	assert_false(_gs.is_companion_unlocked(_gs.COMPANION_MOCHI))


func test_mochi_unlocked_at_camp_progress_threshold() -> void:
	_gs.magnet_level = _gs.MOCHI_UNLOCK_CAMP_LEVEL
	_gs.multiplier_level = 0
	assert_true(_gs.is_companion_unlocked(_gs.COMPANION_MOCHI))


func test_get_active_companion_id_falls_back_to_pip_if_locked() -> void:
	_gs.magnet_level = 0
	_gs.multiplier_level = 0
	_gs.companions.active_id = _gs.COMPANION_MOCHI
	assert_eq(_gs.get_active_companion_id(), _gs.COMPANION_PIP)


func test_try_set_active_companion_succeeds_when_unlocked() -> void:
	_gs.magnet_level = _gs.MOCHI_UNLOCK_CAMP_LEVEL
	var result: String = _gs.try_set_active_companion(_gs.COMPANION_MOCHI)
	assert_eq(_gs.get_active_companion_id(), _gs.COMPANION_MOCHI)
	assert_true(result.contains("Mochi"))


func test_try_set_active_companion_rejects_when_locked() -> void:
	_gs.magnet_level = 0
	_gs.multiplier_level = 0
	_gs.companions.active_id = _gs.COMPANION_PIP
	_gs.try_set_active_companion(_gs.COMPANION_MOCHI)
	assert_eq(_gs.get_active_companion_id(), _gs.COMPANION_PIP, "a locked companion must not become active")
