## LAUNCH-PREP B — Play Billing 3.3.0 tok s lažnim BillingClientom:
## connect → katalog → purchase → acknowledge / consume → grant; pending, cancel, disconnect, restore.
## Tok kupovine pravim novcem mora raditi i kad je v1 bez nje (IAP_ENABLED = false) — zato
## iap_override = 1 (merchant se jednom vrati).
extends "res://test/unit/game_state_test_base.gd"

const IAP_SCRIPT := preload("res://scripts/monetization/iap_manager.gd")
const CONFIG := preload("res://scripts/monetization/monetization_config.gd")


## Isti signali i metode kao BillingClient.gd iz plugina; bilježi pozive, odgovore šalje test.
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

	var calls: Array[String] = []
	var acked: Array[String] = []
	var consumed: Array[String] = []
	var purchase_result: Dictionary = {"response_code": 0}

	func start_connection() -> void:
		calls.append("start_connection")

	func query_product_details(_ids: PackedStringArray, _type: int) -> void:
		calls.append("query_product_details")

	func query_purchases(_type: int, _include_suspended: bool = false) -> void:
		calls.append("query_purchases")

	func purchase(product_id: String, _option := "", _offer := "", _personalized := false) -> Dictionary:
		calls.append("purchase:" + product_id)
		return purchase_result

	func acknowledge_purchase(token: String) -> void:
		acked.append(token)

	func consume_purchase(token: String) -> void:
		consumed.append(token)


var _iap: Node
var _fake: FakeBillingClient
var _ads_before: bool
var _hint_before: bool
var _events: Array[String] = []


func before_each() -> void:
	super.before_each()
	CONFIG.iap_override = 1
	_iap = get_node("/root/IAPManager")
	_ads_before = _gs.ads_removed
	_hint_before = _gs.merge_hint_owned
	_events.clear()
	_fake = FakeBillingClient.new()
	_iap._has_billing_plugin = true
	_iap._force_store_route = true
	_iap.attach_billing_client(_fake)
	_iap.purchase_completed.connect(_on_completed)
	_iap.purchase_failed.connect(_on_failed)
	_iap.purchase_restored.connect(_on_restored)
	_iap.restore_completed.connect(_on_restore_done)


func after_each() -> void:
	_iap.purchase_completed.disconnect(_on_completed)
	_iap.purchase_failed.disconnect(_on_failed)
	_iap.purchase_restored.disconnect(_on_restored)
	_iap.restore_completed.disconnect(_on_restore_done)
	_iap._billing_client = null
	_iap._billing_ready = false
	_iap._has_billing_plugin = false
	_iap._force_store_route = false
	_iap._product_details_loaded = false
	_iap._restore_pending = false
	_iap._reconnect_attempt = 0
	_iap._store_prices.clear()
	_iap._pending_ack_tokens.clear()
	_iap._clear_busy()
	_fake.queue_free()
	_gs.ads_removed = _ads_before
	_gs.merge_hint_owned = _hint_before
	CONFIG.iap_override = -1
	super.after_each()
	_gs.load_player_save()


func _on_completed(sku: String) -> void:
	_events.append("completed:" + sku)


func _on_failed(sku: String, reason: String) -> void:
	_events.append("failed:%s:%s" % [sku, reason])


func _on_restored(sku: String) -> void:
	_events.append("restored:" + sku)


func _on_restore_done() -> void:
	_events.append("restore_done")


func _connect_store() -> void:
	_fake.connected.emit()
	_fake.query_product_details_response.emit({
		"response_code": 0,
		"debug_message": "",
		"product_details": [{
			"product_id": "remove_ads",
			"one_time_purchase_offer_details_list": [{"formatted_price": "3,99 KM"}],
		}],
		"unfetched_products": [],
	})


func _purchase_dict(play_id: String, token: String, state: int = 1, acknowledged: bool = false) -> Dictionary:
	return {
		"purchase_state": state,
		"product_ids": PackedStringArray([play_id]),
		"purchase_token": token,
		"is_acknowledged": acknowledged,
	}


func test_route_matrix_with_plugin() -> void:
	assert_eq(IAP_SCRIPT.purchase_route(true, true, true, true), "store")
	assert_eq(IAP_SCRIPT.purchase_route(true, false, true, true), "unavailable",
		"debug APK with plugin but no Play connection must not hand out items")
	assert_eq(IAP_SCRIPT.purchase_route(true, false, true, false), "stub")
	assert_eq(IAP_SCRIPT.purchase_route(false, false, true, false), "stub")


func test_connect_queries_catalog_and_owned_purchases() -> void:
	_connect_store()
	assert_true(_fake.calls.has("query_product_details"))
	assert_true(_fake.calls.has("query_purchases"))
	assert_false(_iap.is_stub_mode())
	assert_eq(_iap.get_price_label("remove_ads"), "3,99 KM", "3.3.0 offer list price")


func test_purchase_acknowledge_grants_once() -> void:
	_gs.ads_removed = false
	_connect_store()
	_iap.purchase("remove_ads")
	assert_true(_fake.calls.has("purchase:remove_ads"))
	assert_true(_iap.is_busy())
	_fake.on_purchase_updated.emit({"response_code": 0, "purchases": [_purchase_dict("remove_ads", "tok-ads")]})
	assert_eq(_fake.acked, ["tok-ads"])
	assert_false(_gs.ads_removed, "no grant before Play confirms acknowledge")
	_fake.acknowledge_purchase_response.emit({"response_code": 0, "token": "tok-ads"})
	assert_true(_gs.ads_removed)
	assert_false(_iap.is_busy())
	assert_eq(_events, ["completed:remove_ads"])
	_fake.acknowledge_purchase_response.emit({"response_code": 0, "token": "tok-ads"})
	assert_eq(_events.size(), 1, "duplicate ack response is ignored")


func test_purchase_before_catalog_asks_for_catalog() -> void:
	_fake.connected.emit()
	_fake.calls.clear()
	_iap.purchase("remove_ads")
	assert_true(_fake.calls.has("query_product_details"))
	assert_false(_fake.calls.has("purchase:remove_ads"))
	assert_eq(_events, ["failed:remove_ads:store_not_ready"])
	assert_false(_iap.is_busy())


func test_cancel_and_error_reasons() -> void:
	_connect_store()
	_iap.purchase("remove_ads")
	_fake.on_purchase_updated.emit({"response_code": 1, "debug_message": "user"})
	_fake.purchase_result = {"response_code": 3, "debug_message": "billing unavailable"}
	_iap.purchase("remove_ads")
	assert_eq(_events, ["failed:remove_ads:purchase_cancelled", "failed:remove_ads:billing_error_3"])
	assert_false(_iap.is_busy())


func test_already_owned_syncs_instead_of_error_sound() -> void:
	_gs.ads_removed = false
	_connect_store()
	_iap.purchase("remove_ads")
	_fake.calls.clear()
	_fake.on_purchase_updated.emit({"response_code": 7})
	assert_true(_fake.calls.has("query_purchases"))
	assert_eq(_events, ["failed:remove_ads:already_owned"])
	_fake.query_purchases_response.emit({"response_code": 0, "purchases": [_purchase_dict("remove_ads", "old", 1, true)]})
	assert_true(_gs.ads_removed)
	assert_eq(_events.back(), "restored:remove_ads")


func test_pending_purchase_grants_only_when_paid() -> void:
	_gs.merge_hint_owned = false
	_connect_store()
	_iap._product_details_loaded = true
	_iap.purchase("booster_merge_hint")
	_fake.on_purchase_updated.emit({"response_code": 0, "purchases": [_purchase_dict("booster_merge_hint", "tok-p", 2)]})
	assert_false(_gs.merge_hint_owned, "pending must not grant")
	assert_eq(_fake.acked.size(), 0)
	assert_eq(_events, ["failed:booster_merge_hint:purchase_pending"])
	# Uplata prošla dok je igra bila u pozadini — Play javi isti token kao PURCHASED.
	_fake.on_purchase_updated.emit({"response_code": 0, "purchases": [_purchase_dict("booster_merge_hint", "tok-p", 1)]})
	_fake.acknowledge_purchase_response.emit({"response_code": 0, "token": "tok-p"})
	assert_true(_gs.merge_hint_owned)
	assert_eq(_events.back(), "completed:booster_merge_hint")


func test_consumable_consumes_and_grants_once_per_token() -> void:
	_connect_store()
	var before: int = _gs.granted_purchase_tokens.size()
	_iap._process_purchase(_purchase_dict("booster_loot_burst", "tok-lb"), true)
	assert_eq(_fake.consumed, ["tok-lb"])
	assert_eq(_fake.acked.size(), 0, "consumable is consumed, never acknowledged")
	_fake.consume_purchase_response.emit({"response_code": 0, "token": "tok-lb"})
	assert_eq(_gs.granted_purchase_tokens.size(), before + 1)
	_iap._process_purchase(_purchase_dict("booster_loot_burst", "tok-lb"), false)
	assert_eq(_fake.consumed, ["tok-lb"], "already granted token is not consumed again")
	assert_eq(_gs.granted_purchase_tokens.size(), before + 1)


func test_disconnect_frees_shop_and_schedules_reconnect() -> void:
	_connect_store()
	_iap.purchase("remove_ads")
	assert_true(_iap.is_busy())
	_fake.calls.clear()
	_fake.disconnected.emit()
	assert_false(_iap.is_busy())
	assert_eq(_events, ["failed:remove_ads:billing_disconnected"])
	assert_true(_iap._reconnect_scheduled)
	_iap.purchase("remove_ads")
	assert_eq(_events.back(), "failed:remove_ads:unavailable", "no stub grant while Play is away")


func test_restore_waits_for_acknowledge() -> void:
	_gs.ads_removed = false
	_connect_store()
	_iap.restore_purchases()
	_fake.query_purchases_response.emit({"response_code": 0, "purchases": [_purchase_dict("remove_ads", "tok-r")]})
	assert_false(_events.has("restore_done"), "restore must wait for the pending acknowledge")
	_fake.acknowledge_purchase_response.emit({"response_code": 0, "token": "tok-r"})
	assert_true(_gs.ads_removed)
	assert_eq(_events, ["restored:remove_ads", "restore_done"])
	assert_false(_iap.is_busy())


func test_startup_sync_does_not_claim_a_new_purchase() -> void:
	_gs.ads_removed = false
	_connect_store()
	_fake.query_purchases_response.emit({"response_code": 0, "purchases": [_purchase_dict("remove_ads", "tok-s", 1, true)]})
	assert_true(_gs.ads_removed)
	assert_eq(_events, ["restored:remove_ads"], "owned item on start is restored, not 'purchase completed'")
