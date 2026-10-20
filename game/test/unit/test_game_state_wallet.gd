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
	super.after_each()
	if not _gs.load_player_save():
		_gs.wallet_coins = _coins_before


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


func test_add_and_spend_coins() -> void:
	_gs.wallet_coins = 10
	_gs._add_coins(4)
	assert_eq(_gs.wallet_coins, 14)
	assert_true(_gs._try_spend_coins(6))
	assert_eq(_gs.wallet_coins, 8)
	assert_false(_gs._try_spend_coins(9))
	assert_eq(_gs.wallet_coins, 8)
	_gs._add_coins(0)
	assert_eq(_gs.wallet_coins, 8)


func test_successful_coin_unlock_advances_chain() -> void:
	if SeedUnlockConfig.chain_size() < 2:
		fail_test("seed chain needs at least two entries")
		return
	_gs.seed_unlock_index = 0
	var cost: int = SeedUnlockConfig.coin_cost_to_unlock_index(1)
	_gs.wallet_coins = cost
	var result: String = _gs.try_coin_unlock_next_seed()
	assert_false(result.begins_with("Need"), result)
	assert_eq(_gs.seed_unlock_index, 1)
	assert_eq(_gs.wallet_coins, 0)


func test_revive_clawback_does_not_go_negative() -> void:
	_gs.last_failed = false
	_gs.revive_used_this_run = false
	_gs.loot_doubled = false
	_gs.wallet_coins = 10
	assert_false(_gs._apply_revive_clawback())
	assert_eq(_gs.wallet_coins, 10)
	_gs.last_failed = true
	_gs.last_run_coins = 4
	assert_true(_gs._apply_revive_clawback())
	assert_eq(_gs.wallet_coins, 6)
	assert_true(_gs.revive_used_this_run)
	assert_false(_gs._apply_revive_clawback())
	_gs.revive_used_this_run = false
	_gs.last_failed = true
	_gs.wallet_coins = 2
	_gs.last_run_coins = 5
	assert_true(_gs._apply_revive_clawback())
	assert_eq(_gs.wallet_coins, 0)


func test_deposit_loot_moves_bag_and_clears_carry() -> void:
	var before: int = int(_gs.seed_bag.get("clover", 0))
	_gs.last_seed_bag = {"clover": 3}
	var deposited: int = _gs.deposit_loot_to_camp()
	assert_eq(deposited, 3)
	assert_eq(int(_gs.seed_bag.get("clover", 0)), before + 3)
	assert_eq(_gs.last_seed_bag.size(), 0)
