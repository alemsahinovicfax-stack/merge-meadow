## Characterizes GameState's current wallet behavior (game_state.gd ~1496-1524)
## BEFORE the Stage 1 Economy-indirection refactor (plan-arhitektura-refaktor.md).
## These must still pass, unchanged, after Stage 1 — only the internal
## implementation (direct += vs. _add_coins()/_try_spend_coins()) should move.
extends "res://test/unit/game_state_test_base.gd"

var _coins_before: int


func before_each() -> void:
	super.before_each()
	_coins_before = _gs.wallet_coins


func after_each() -> void:
	_gs.wallet_coins = _coins_before
	super.after_each()


func test_try_coin_unlock_next_seed_reports_missing_funds() -> void:
	# Characterizes the "not enough coins" message path without depending on
	# exact SeedUnlockConfig costs — only that spending is blocked below the
	# required cost and wallet_coins is left untouched.
	if not _gs.has_pending_seed_unlock():
		pass_test("no pending seed unlock in current chain state — nothing to characterize")
		return
	_gs.wallet_coins = 0
	var index_before: int = _gs.seed_unlock_index
	var result: String = _gs.try_coin_unlock_next_seed()
	assert_true(result.begins_with("Need"), "0 coins should never be enough to unlock")
	assert_eq(_gs.seed_unlock_index, index_before, "failed unlock must not advance the chain")
	assert_eq(_gs.wallet_coins, 0, "failed unlock must not spend coins")
