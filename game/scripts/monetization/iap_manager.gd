extends Node

## IAP — stub on desktop/editor; Google Play Billing on Android when plugin is installed.

signal purchase_completed(sku: String)
signal purchase_failed(sku: String, reason: String)
signal catalog_updated()
signal restore_completed()

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

# Mirrors BillingClient enums when the Android plugin is not loaded in the editor.
const _PRODUCT_TYPE_INAPP := 0
const _RESPONSE_OK := 0
const _PURCHASE_STATE_PURCHASED := 1

var _busy: bool = false
var _restore_pending: bool = false
var _billing_client: Object = null
var _billing_ready: bool = false
var _store_prices: Dictionary = {}
var _pending_purchase_sku: String = ""
var _pending_ack_tokens: Dictionary = {}


func _ready() -> void:
	if _try_init_billing():
		_billing_client.call("start_connection")
	elif OS.get_name() == "Android":
		push_warning("IAPManager: BillingClient missing — stub IAP on Android until plugin is installed.")


func is_stub_mode() -> bool:
	return _billing_client == null or not _billing_ready


func is_busy() -> bool:
	return _busy


func owns_product(sku: String) -> bool:
	if CONFIG.is_consumable(sku):
		return false
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			return GameState.ads_removed
		CONFIG.SKU_STARTER_PACK:
			return GameState.starter_pack_owned
	return false


func get_price_label(sku: String) -> String:
	var store_price := str(_store_prices.get(sku, ""))
	if not store_price.is_empty():
		return store_price
	var product: Dictionary = CONFIG.IAP_PRODUCTS.get(sku, {})
	return str(product.get("price_label", "—"))


func purchase(sku: String) -> void:
	if _busy:
		purchase_failed.emit(sku, "busy")
		return
	if not CONFIG.IAP_PRODUCTS.has(sku):
		purchase_failed.emit(sku, "unknown_sku")
		return
	if owns_product(sku):
		purchase_failed.emit(sku, "already_owned")
		return
	_busy = true
	_pending_purchase_sku = sku
	if OS.get_name() == "Android" and _billing_ready:
		_purchase_android(sku)
	else:
		_purchase_stub(sku)


func restore_purchases() -> void:
	if _busy:
		return
	if is_stub_mode():
		restore_completed.emit()
		return
	_busy = true
	_restore_pending = true
	_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)


func reset_purchases_for_dev() -> void:
	if not is_stub_mode():
		return
	GameState.ads_removed = false
	GameState.starter_pack_owned = false
	GameState.save_player_save()
	catalog_updated.emit()


func _try_init_billing() -> bool:
	if OS.get_name() != "Android":
		return false
	if not ClassDB.class_exists("BillingClient"):
		return false
	_billing_client = ClassDB.instantiate("BillingClient")
	if _billing_client == null:
		return false
	_connect_billing_signal("connected", _on_billing_connected)
	_connect_billing_signal("disconnected", _on_billing_disconnected)
	_connect_billing_signal("connect_error", _on_billing_connect_error)
	_connect_billing_signal("query_product_details_response", _on_query_product_details_response)
	_connect_billing_signal("query_purchases_response", _on_query_purchases_response)
	_connect_billing_signal("on_purchase_updated", _on_purchase_updated)
	_connect_billing_signal("on_purchases_updated", _on_purchase_updated)
	_connect_billing_signal("acknowledge_purchase_response", _on_acknowledge_purchase_response)
	return true


func _connect_billing_signal(signal_name: String, callable: Callable) -> void:
	if _billing_client.has_signal(signal_name):
		_billing_client.connect(signal_name, callable)


func _on_billing_connected() -> void:
	_billing_ready = true
	var play_ids: PackedStringArray = []
	for sku in CONFIG.all_skus():
		play_ids.append(CONFIG.get_play_product_id(sku))
	_billing_client.call("query_product_details", play_ids, _PRODUCT_TYPE_INAPP)
	_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)


func _on_billing_disconnected() -> void:
	_billing_ready = false


func _on_billing_connect_error(_response_code: int, debug_message: String) -> void:
	push_warning("IAPManager: billing connect error — %s" % debug_message)


func _on_query_product_details_response(query_result: Dictionary) -> void:
	if int(query_result.get("response_code", -1)) != _RESPONSE_OK:
		push_warning(
			"IAPManager: product query failed (%s)" % query_result.get("debug_message", "unknown")
		)
		return
	var details_list: Variant = query_result.get("product_details", query_result.get("result_array", []))
	if not details_list is Array:
		return
	for raw_details in details_list:
		if not raw_details is Dictionary:
			continue
		var details: Dictionary = raw_details
		var play_id := str(details.get("product_id", ""))
		if play_id.is_empty():
			continue
		var sku := CONFIG.sku_for_play_product_id(play_id)
		var price := _extract_formatted_price(details)
		if not price.is_empty():
			_store_prices[sku] = price
	catalog_updated.emit()


func _on_query_purchases_response(query_result: Dictionary) -> void:
	var was_restore := _restore_pending
	_restore_pending = false
	if int(query_result.get("response_code", -1)) != _RESPONSE_OK:
		if was_restore:
			_busy = false
			restore_completed.emit()
		return
	var purchases: Variant = query_result.get("purchases", query_result.get("result_array", []))
	if purchases is Array:
		for purchase in purchases:
			if purchase is Dictionary:
				_process_purchase(purchase, false)
	if was_restore:
		_busy = false
		restore_completed.emit()


func _on_purchase_updated(result: Dictionary) -> void:
	if int(result.get("response_code", -1)) != _RESPONSE_OK:
		_fail_purchase(_pending_purchase_sku, "purchase_cancelled")
		return
	var purchases: Variant = result.get("purchases", result.get("result_array", []))
	if not purchases is Array:
		_fail_purchase(_pending_purchase_sku, "purchase_empty")
		return
	for purchase in purchases:
		if purchase is Dictionary:
			_process_purchase(purchase, true)


func _on_acknowledge_purchase_response(result: Dictionary) -> void:
	var token := str(result.get("token", ""))
	if int(result.get("response_code", -1)) != _RESPONSE_OK:
		push_warning("IAPManager: acknowledge failed for token %s" % token)
		_fail_purchase(_pending_ack_tokens.get(token, _pending_purchase_sku), "ack_failed")
		return
	var sku := str(_pending_ack_tokens.get(token, ""))
	_pending_ack_tokens.erase(token)
	if sku.is_empty():
		return
	_complete_purchase(sku)


func _purchase_android(sku: String) -> void:
	var play_id := CONFIG.get_play_product_id(sku)
	var result: Variant = _billing_client.call("purchase", play_id)
	if result is Dictionary and int(result.get("response_code", -1)) != _RESPONSE_OK:
		_fail_purchase(sku, "billing_flow_failed")


func _purchase_stub(sku: String) -> void:
	var timer := get_tree().create_timer(0.9)
	timer.timeout.connect(func() -> void:
		_grant_product(sku)
		_complete_purchase(sku)
	, CONNECT_ONE_SHOT)


func _process_purchase(purchase: Dictionary, from_user_flow: bool) -> void:
	if int(purchase.get("purchase_state", -1)) != _PURCHASE_STATE_PURCHASED:
		if from_user_flow:
			_fail_purchase(_pending_purchase_sku, "purchase_pending")
		return
	var product_ids: Variant = purchase.get("product_ids", [])
	if not product_ids is Array or product_ids.is_empty():
		if from_user_flow:
			_fail_purchase(_pending_purchase_sku, "missing_product_id")
		return
	var play_id := str(product_ids[0])
	var sku := CONFIG.sku_for_play_product_id(play_id)
	if from_user_flow:
		_pending_purchase_sku = sku
	if bool(purchase.get("is_acknowledged", false)):
		_grant_product(sku)
		if from_user_flow:
			_complete_purchase(sku)
		return
	var token := str(purchase.get("purchase_token", ""))
	if token.is_empty():
		if from_user_flow:
			_fail_purchase(sku, "missing_token")
		return
	_pending_ack_tokens[token] = sku
	_billing_client.call("acknowledge_purchase", token)


func _grant_product(sku: String) -> void:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			GameState.ads_removed = true
		CONFIG.SKU_STARTER_PACK:
			if GameState.starter_pack_owned:
				return
			GameState.starter_pack_owned = true
			GameState.wallet_coins += CONFIG.STARTER_PACK_COINS
			GameState.add_seeds_to_bag(GameState.SEED_TYPE_CLOVER, CONFIG.STARTER_PACK_SEEDS)
			GameState.add_booster(CONFIG.BOOSTER_MERGE_HINT, CONFIG.STARTER_PACK_BOOSTERS)
		_:
			var booster_id := CONFIG.sku_booster_id(sku)
			if not booster_id.is_empty():
				GameState.add_booster(booster_id, 1)
	GameState.save_player_save()


func _complete_purchase(sku: String) -> void:
	_busy = false
	_pending_purchase_sku = ""
	purchase_completed.emit(sku)


func _fail_purchase(sku: String, reason: String) -> void:
	var failed_sku := sku if not sku.is_empty() else _pending_purchase_sku
	_busy = false
	_pending_purchase_sku = ""
	if failed_sku.is_empty():
		return
	purchase_failed.emit(failed_sku, reason)


func _extract_formatted_price(details: Dictionary) -> String:
	var one_time: Variant = details.get("one_time_purchase_offer_details", {})
	if one_time is Dictionary:
		var formatted := str(one_time.get("formatted_price", ""))
		if not formatted.is_empty():
			return formatted
	for key in ["formatted_price", "price", "price_text"]:
		var value := str(details.get(key, ""))
		if not value.is_empty():
			return value
	return ""
