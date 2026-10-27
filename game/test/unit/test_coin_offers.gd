## v1 samo s reklamama (2026-10-26): stvari koje su se prodavale pravim novcem kupuju se coinima
## (IAPManager.buy_with_coins) kroz isti grant kao Play; Remove Ads i Starter Pack se ne nude.
extends "res://test/unit/game_state_test_base.gd"

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
const HINT := "booster_merge_hint"
const BURST := "booster_loot_burst"
const MOONLIT := "season_pack_moonlit_warren"
const EMBER := "season_pack_ember_fen"
const KNIGHT := "pip_knight"


## Isti signali i metode kao BillingClient.gd iz plugina (vidi test_iap_billing_flow.gd).
class FakeBillingClient:
	extends Node

	signal connected
	signal disconnected
	signal connect_error(response_code: int, debug_message: String)
	signal query_product_details_response(response: Dictionary)
	signal query_purchases_response(response: Dictionary)
	signal on_purchase_updated(response: Dictionary)
	signal consume_purchase_response(response: Dictionary)
	signal acknowledge_purchase_response(response: Dictionary)

	func start_connection() -> void:
		pass

	func query_product_details(_ids: PackedStringArray, _type: int) -> void:
		pass

	func query_purchases(_type: int, _include_suspended: bool = false) -> void:
		pass

	func purchase(_product_id: String, _option := "", _offer := "", _personalized := false) -> Dictionary:
		return {"response_code": 0}

	func acknowledge_purchase(_token: String) -> void:
		pass

	func consume_purchase(_token: String) -> void:
		pass


var _iap: Variant
var _fake: FakeBillingClient
var _events: Array[String] = []


func before_each() -> void:
	super.before_each()
	_iap = get_node("/root/IAPManager")
	_events.clear()
	CONFIG.iap_override = 0
	_iap.purchase_completed.connect(_on_completed)
	_iap.purchase_failed.connect(_on_failed)


func after_each() -> void:
	_iap.purchase_completed.disconnect(_on_completed)
	_iap.purchase_failed.disconnect(_on_failed)
	if _fake != null:
		_iap._billing_client = null
		_iap._billing_ready = false
		_iap._has_billing_plugin = false
		_iap._force_store_route = false
		_iap._product_details_loaded = false
		_iap._restore_pending = false
		_iap._pending_ack_tokens.clear()
		_iap._clear_busy()
		_fake.queue_free()
		_fake = null
	CONFIG.iap_override = -1
	super.after_each()
	_gs.load_player_save()


func _on_completed(sku: String) -> void:
	_events.append("completed:" + sku)


func _on_failed(sku: String, reason: String) -> void:
	_events.append("failed:%s:%s" % [sku, reason])


func _price(sku: String) -> int:
	return int(_iap.get_coin_price(sku))


## Stanje bez ijedne stvari koja se prodavala pravim novcem.
func _fresh_owner(coins: int) -> void:
	_gs.merge_hint_owned = false
	_gs.clear_owned_paid_seasons()
	_gs.revoke_iap_cosmetics()
	_gs.reset_seasons_to_s1()
	_gs.wallet_coins = coins


func test_coin_prices_cover_former_iap_items() -> void:
	assert_eq(CONFIG.coin_price("remove_ads"), 0, "Remove Ads: ads are the only income")
	assert_eq(CONFIG.coin_price("starter_pack"), 0, "Starter Pack gives coins and has a timer")
	for sku in [HINT, BURST, MOONLIT, "season_pack_coral_tide", "season_pack_starfall_glade", EMBER, KNIGHT]:
		assert_gt(CONFIG.coin_price(sku), 0, "%s needs a coin price" % sku)


func test_coin_offer_only_without_iap() -> void:
	CONFIG.iap_override = 0
	assert_true(CONFIG.sells_for_coins(HINT))
	assert_true(_iap.is_coin_offer(MOONLIT))
	assert_eq(_iap.get_price_label(MOONLIT), "", "no € label anywhere without IAP")
	CONFIG.iap_override = 1
	assert_false(CONFIG.sells_for_coins(HINT), "with IAP on everything is sold as today")
	assert_false(_iap.is_coin_offer(MOONLIT))
	assert_eq(_iap.get_coin_price(MOONLIT), 0)
	assert_string_contains(str(_iap.get_price_label(MOONLIT)), "€")


func test_buy_with_enough_coins_uses_iap_grant() -> void:
	var total := _price(HINT) + _price(MOONLIT) + _price(KNIGHT)
	_fresh_owner(total + 7)
	assert_true(str(_iap.buy_with_coins(HINT)).begins_with("Purchased"))
	assert_true(_gs.merge_hint_owned, "Merge Hint: same save field as Play")
	assert_true(str(_iap.buy_with_coins(MOONLIT)).begins_with("Purchased"))
	assert_true(_gs.owned_paid_seasons.has("moonlit_warren"))
	assert_eq(_gs.active_season_id, "moonlit_warren", "same unlock as Play: the bought season is active")
	assert_true(str(_iap.buy_with_coins(KNIGHT)).begins_with("Purchased"))
	assert_true(_gs.owns_cosmetic(KNIGHT))
	assert_eq(_gs.get_equipped_cosmetic("pip_skin"), KNIGHT, "bought Sir Pip is worn right away")
	assert_eq(_gs.wallet_coins, 7, "exactly the coin prices are spent")
	assert_eq(_events, ["completed:" + HINT, "completed:" + MOONLIT, "completed:" + KNIGHT])
	_gs.load_player_save()
	assert_true(_gs.merge_hint_owned and _gs.owned_paid_seasons.has("moonlit_warren") and _gs.owns_cosmetic(KNIGHT),
		"coin purchases are saved")
	assert_eq(_gs.wallet_coins, 7)


func test_not_enough_coins_gives_nothing() -> void:
	_fresh_owner(_price(MOONLIT) - 1)
	var result := str(_iap.buy_with_coins(MOONLIT))
	assert_eq(result, "Need %d coins." % _price(MOONLIT))
	assert_false(_gs.owned_paid_seasons.has("moonlit_warren"))
	assert_eq(_gs.wallet_coins, _price(MOONLIT) - 1, "coins stay")
	assert_eq(_events, ["failed:%s:need_coins" % MOONLIT])
	_gs.wallet_coins = 0
	_iap.buy_with_coins(HINT)
	assert_false(_gs.merge_hint_owned)


func test_permanent_item_bought_once() -> void:
	_fresh_owner(_price(HINT) * 3)
	_iap.buy_with_coins(HINT)
	var result := str(_iap.buy_with_coins(HINT))
	assert_false(result.begins_with("Purchased"))
	assert_eq(_gs.wallet_coins, _price(HINT) * 2, "second tap must not charge again")
	assert_eq(_events, ["completed:" + HINT, "failed:%s:already_owned" % HINT])


func test_loot_burst_repeats_toward_next_free_season() -> void:
	_fresh_owner(_price(BURST) * 2)
	var target: Dictionary = _gs.get_loot_burst_target()
	assert_false(target.is_empty(), "first free season locked → Loot Burst has a target")
	var flower := str(target["flower"])
	var stash_before := int(_gs.garden_crystal_stash.get(flower, 0))
	var grown_before := int(_gs.star3_grown_count(flower))
	_iap.buy_with_coins(BURST)
	assert_eq(str(_iap.last_loot_burst.get("flower", "")), flower, "toast data for the Shop")
	_iap.buy_with_coins(BURST)
	assert_eq(int(_gs.garden_crystal_stash.get(flower, 0)), stash_before + 2 * CONFIG.LOOT_BURST_STAR3)
	assert_eq(int(_gs.star3_grown_count(flower)), grown_before + 2 * CONFIG.LOOT_BURST_STAR3,
		"same grant as Play: counts as grown")
	assert_eq(_gs.wallet_coins, 0)
	assert_eq(_events, ["completed:" + BURST, "completed:" + BURST])


func test_loot_burst_without_target_is_refused() -> void:
	_fresh_owner(_price(BURST) * 2)
	for def in SeasonCatalog.free_defs_sorted():
		if not _gs.unlocked_seasons.has(def.id):
			_gs.unlocked_seasons.append(def.id)
	assert_true(_gs.get_loot_burst_target().is_empty())
	var bag_before: int = _gs.sum_seed_bag(_gs.seed_bag)
	_iap.buy_with_coins(BURST)
	assert_eq(_gs.wallet_coins, _price(BURST) * 2, "no target → no sale, coins stay")
	assert_eq(_gs.sum_seed_bag(_gs.seed_bag), bag_before)
	assert_eq(_events, ["failed:%s:unavailable" % BURST])


func test_loot_burst_grant_without_target_gives_seeds() -> void:
	# Zajednički grant (stari saveovi / restore): bez cilja daje 5 sjemenki — ništa se ne gubi.
	_fresh_owner(0)
	for def in SeasonCatalog.free_defs_sorted():
		if not _gs.unlocked_seasons.has(def.id):
			_gs.unlocked_seasons.append(def.id)
	var bag_before: int = _gs.sum_seed_bag(_gs.seed_bag)
	_iap._grant_product(BURST, "", true)
	assert_eq(_gs.sum_seed_bag(_gs.seed_bag), bag_before + CONFIG.LOOT_BURST_STAR3)


func test_remove_ads_and_starter_pack_stay_hidden() -> void:
	_fresh_owner(100000)
	_gs.ads_removed = false
	_gs.starter_pack_owned = false
	for sku in ["remove_ads", "starter_pack"]:
		assert_false(_iap.is_coin_offer(sku), "%s is not sold for coins" % sku)
		_iap.buy_with_coins(sku)
	assert_false(_gs.ads_removed)
	assert_false(_gs.starter_pack_owned)
	assert_eq(_gs.wallet_coins, 100000)
	assert_false(UiShopV2.visible_tabs().has("support"), "no Support tab (Remove Ads, Starter Pack, Restore)")


func test_ember_hidden_while_not_in_game() -> void:
	if not _gs.is_test_locked_season("ember_fen"):
		pass_test("Ember is in the game — sold like the other themes")
		return
	assert_gt(CONFIG.coin_price(EMBER), 0, "price is ready for when Ember ships")
	assert_false(_iap.is_coin_offer(EMBER), "Ember stays hidden while it is not in the game")
	_fresh_owner(100000)
	_iap.buy_with_coins(EMBER)
	assert_false(_gs.owned_paid_seasons.has("ember_fen"))
	assert_eq(_gs.wallet_coins, 100000)


func test_coin_purchase_refused_with_iap_on() -> void:
	_fresh_owner(100000)
	CONFIG.iap_override = 1
	_iap.buy_with_coins(HINT)
	assert_false(_gs.merge_hint_owned)
	assert_eq(_gs.wallet_coins, 100000)
	assert_eq(_events, ["failed:%s:unavailable" % HINT])


## IAP se jednom vrati (merchant): coin stvari ostaju, Play restore ih ne dira, prikazuju se kao tvoje.
func test_iap_on_keeps_coin_items_owned() -> void:
	_fresh_owner(_price(HINT) + _price(MOONLIT) + _price(KNIGHT))
	_gs.ads_removed = false
	for sku in [HINT, MOONLIT, KNIGHT]:
		_iap.buy_with_coins(sku)
	CONFIG.iap_override = 1
	for sku in [HINT, MOONLIT, KNIGHT]:
		assert_true(_iap.owns_product(sku), "%s owned with IAP on" % sku)
	assert_eq(UiShopV2.money_state(HINT, "", false, false), UiShopV2.OWNED_STATE)
	assert_eq(UiShopV2.money_state(KNIGHT, "", false, false), UiShopV2.OWNED_STATE)
	assert_eq(UiShopV2.season_state(SeasonCatalog.get_def("moonlit_warren"), "", false, false), UiShopV2.PLAY_STATE)
	_fake = FakeBillingClient.new()
	_iap._has_billing_plugin = true
	_iap._force_store_route = true
	_iap.attach_billing_client(_fake)
	_fake.connected.emit()
	_iap.restore_purchases()
	_fake.query_purchases_response.emit({"response_code": 0, "purchases": []})
	_iap.restore_purchases()
	_fake.query_purchases_response.emit({"response_code": 0, "purchases": [{
		"purchase_state": 1, "product_ids": PackedStringArray(["remove_ads"]),
		"purchase_token": "tok-ads", "is_acknowledged": true,
	}]})
	assert_true(_gs.ads_removed, "Play restore still works")
	assert_true(_gs.merge_hint_owned and _gs.owned_paid_seasons.has("moonlit_warren") and _gs.owns_cosmetic(KNIGHT),
		"restore never takes coin purchases away")
	_events.clear()
	_iap._product_details_loaded = true
	_iap.purchase(MOONLIT)
	assert_eq(_events, ["failed:%s:already_owned" % MOONLIT], "no second (paid) purchase of a coin item")
	CONFIG.iap_override = 0
	assert_true(_iap.owns_product(MOONLIT) and _iap.owns_product(HINT) and _iap.owns_product(KNIGHT))
