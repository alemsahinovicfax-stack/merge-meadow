## MEAD-2/3/5 — acknowledge grant, release ruta, consumable finish.
extends "res://test/unit/game_state_test_base.gd"

const IAP_SCRIPT := preload("res://scripts/monetization/iap_manager.gd")
const AD_SCRIPT := preload("res://scripts/monetization/ad_manager.gd")

var _iap: Variant
var _ads_before: bool
var _starter_before: bool
var _coins_before: int


func before_each() -> void:
	super.before_each()
	_iap = get_node("/root/IAPManager")
	_ads_before = _gs.ads_removed
	_starter_before = _gs.starter_pack_owned
	_coins_before = _gs.wallet_coins


func after_each() -> void:
	_gs.ads_removed = _ads_before
	_gs.starter_pack_owned = _starter_before
	_gs.wallet_coins = _coins_before
	_iap._pending_ack_tokens.clear()
	super.after_each()
	_gs.load_player_save()


func test_purchase_route_matrix() -> void:
	assert_eq(IAP_SCRIPT.purchase_route(true, true, false), "store")
	assert_eq(IAP_SCRIPT.purchase_route(true, false, false), "unavailable")
	assert_eq(IAP_SCRIPT.purchase_route(true, false, true), "stub")
	assert_eq(IAP_SCRIPT.purchase_route(false, false, false), "stub")


func test_store_finish_action() -> void:
	assert_eq(IAP_SCRIPT.store_finish_action(true), "consume")
	assert_eq(IAP_SCRIPT.store_finish_action(false), "acknowledge")


func test_reward_route_fails_closed_on_android_release() -> void:
	assert_eq(AD_SCRIPT.reward_route(true, false), "fail")
	assert_eq(AD_SCRIPT.reward_route(true, true), "stub")
	assert_eq(AD_SCRIPT.reward_route(false, false), "stub")


func test_acknowledge_grants_remove_ads_once() -> void:
	_gs.ads_removed = false
	_iap._pending_ack_tokens["tok-ads"] = "remove_ads"
	_iap._on_acknowledge_purchase_response({"response_code": 0, "token": "tok-ads"})
	assert_true(_gs.ads_removed, "ack must grant Remove Ads")
	assert_false(_iap._pending_ack_tokens.has("tok-ads"))
	_iap._on_acknowledge_purchase_response({"response_code": 0, "token": "tok-ads"})
	assert_true(_gs.ads_removed)


func test_acknowledge_grants_starter_once() -> void:
	_gs.starter_pack_owned = false
	_gs.wallet_coins = 0
	_iap._pending_ack_tokens["tok-starter"] = "starter_pack"
	_iap._on_acknowledge_purchase_response({"response_code": 0, "token": "tok-starter"})
	assert_true(_gs.starter_pack_owned)
	var coins_after: int = _gs.wallet_coins
	assert_gt(coins_after, 0, "starter pack adds coins")
	_iap._on_acknowledge_purchase_response({"response_code": 0, "token": "tok-starter"})
	assert_eq(_gs.wallet_coins, coins_after, "second ack must not grant again")


func test_loot_burst_token_grants_once() -> void:
	var first: bool = _iap._try_grant_loot_burst("tok-burst", true)
	var second: bool = _iap._try_grant_loot_burst("tok-burst", true)
	assert_true(first)
	assert_false(second)
