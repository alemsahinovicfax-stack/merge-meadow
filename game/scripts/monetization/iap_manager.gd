extends Node

## IAP — stub on desktop/editor; Google Play Billing 3.x (GodotGooglePlayBilling) on Android.

signal purchase_completed(sku: String)
signal purchase_failed(sku: String, reason: String)
## Vlasništvo vraćeno bez kupovine u ovoj sesiji (start, Restore, kupovina koja je čekala).
## Odvojeno od purchase_completed da start igre ne svira „kupljeno" ni ne pokazuje toast.
signal purchase_restored(sku: String)
signal catalog_updated()
signal restore_completed()

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")
## Plugin 3.x je GDScript `class_name BillingClient` — ClassDB ga ne vidi, zato load() po putanji.
const BILLING_SCRIPT := "res://addons/GodotGooglePlayBilling/BillingClient.gd"

# BillingClient enumi (plugin 3.3.0); kopija da skripta radi i bez plugina na desktopu.
const _PRODUCT_TYPE_INAPP := 0
const _RESPONSE_OK := 0
const _RESPONSE_USER_CANCELED := 1
const _RESPONSE_ITEM_ALREADY_OWNED := 7
const _RESPONSE_SERVICE_DISCONNECTED := -1
const _PURCHASE_STATE_PURCHASED := 1
const _PURCHASE_STATE_PENDING := 2

## Play kupovina čeka igrača (kartica, 3-D Secure); poslije ovoga Shop se otključa,
## a zakašnjeli rezultat i dalje stiže kroz on_purchase_updated.
const BUSY_TIMEOUT_SEC := 120.0
const RECONNECT_DELAYS: Array[float] = [2.0, 4.0, 8.0, 16.0, 32.0, 60.0]


## store = Play billing spreman. unavailable = Android bez veze s Playom (ne daruj).
## stub = editor / Windows / debug APK bez plugina — Shop i smoke testovi rade bez Playa.
## Debug APK s pluginom više ne pada na stub kad veza pukne (stvari bi bile besplatne).
static func purchase_route(
	on_android: bool, billing_ready: bool, debug_or_editor: bool, has_billing_plugin: bool = false
) -> String:
	if on_android and billing_ready:
		return "store"
	if on_android and (has_billing_plugin or not debug_or_editor):
		return "unavailable"
	return "stub"


## Consumable se završava consume-om. Acknowledge bi ga zaključao kao owned.
static func store_finish_action(consumable: bool) -> String:
	return "consume" if consumable else "acknowledge"


## Neuspjeh iz Play purchase toka -> razlog za purchase_failed (Shop ga prevodi u UiShopV2.status_for).
static func purchase_result_reason(response_code: int) -> String:
	match response_code:
		_RESPONSE_USER_CANCELED:
			return "purchase_cancelled"
		_RESPONSE_ITEM_ALREADY_OWNED:
			return "already_owned"
		_RESPONSE_SERVICE_DISCONNECTED:
			return "billing_disconnected"
	return "billing_error_%d" % response_code


## Plugin daje product_ids kao PackedStringArray; stari testovi kao Array.
static func first_product_id(purchase: Dictionary) -> String:
	var ids: Variant = purchase.get("product_ids", [])
	if ids is PackedStringArray and not (ids as PackedStringArray).is_empty():
		return str((ids as PackedStringArray)[0])
	if ids is Array and not (ids as Array).is_empty():
		return str((ids as Array)[0])
	return ""


var _busy: bool = false
var _busy_serial: int = 0
var _restore_pending: bool = false
var _billing_client: Object = null
var _billing_ready: bool = false
var _has_billing_plugin: bool = false
var _product_details_loaded: bool = false
var _reconnect_attempt: int = 0
var _reconnect_scheduled: bool = false
## GUT: store ruta i na desktopu, s lažnim klijentom (attach_billing_client).
var _force_store_route: bool = false
var _store_prices: Dictionary = {}
var _pending_purchase_sku: String = ""
## token -> {sku, user}. user = kupljeno sada (toast + zvuk); inače vraćeno vlasništvo.
var _pending_ack_tokens: Dictionary = {}
## Zadnji Loot Burst {flower, added} — Shop iz njega pravi toast „+5 <cvijet>".
var last_loot_burst: Dictionary = {}


func _ready() -> void:
	if _try_init_billing():
		_billing_client.call("start_connection")
	elif OS.get_name() == "Android":
		push_warning("IAPManager: BillingClient missing — IAP unavailable on this build.")


func _notification(what: int) -> void:
	# Kupovina koja je čekala (gotovina, spora kartica) može se završiti dok je igra u pozadini.
	if what == NOTIFICATION_APPLICATION_RESUMED and _billing_client != null:
		if _billing_ready:
			_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)
		else:
			_schedule_reconnect()


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
		CONFIG.SKU_BOOSTER_MERGE_HINT:
			return GameState.merge_hint_owned
	var season_id := CONFIG.season_id_for_sku(sku)
	if not season_id.is_empty():
		return GameState.owned_paid_seasons.has(season_id)
	var cosmetic_id := CONFIG.cosmetic_for_sku(sku)
	if not cosmetic_id.is_empty():
		return GameState.owns_cosmetic(cosmetic_id)
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
	var season_id := CONFIG.season_id_for_sku(sku)
	if GameState.is_test_locked_season(season_id):
		purchase_failed.emit(sku, "test_locked")
		return
	if owns_product(sku):
		purchase_failed.emit(sku, "already_owned")
		return
	if sku == CONFIG.SKU_STARTER_PACK and GameState.is_starter_pack_expired():
		purchase_failed.emit(sku, "expired")
		return
	if sku == CONFIG.SKU_BOOSTER_LOOT_BURST and not GameState.can_buy_loot_burst():
		purchase_failed.emit(sku, "unavailable")
		return
	var route := purchase_route(
		OS.get_name() == "Android" or _force_store_route,
		_billing_ready,
		OS.is_debug_build() or OS.has_feature("editor"),
		_has_billing_plugin
	)
	match route:
		"store":
			_set_busy(sku)
			_purchase_android(sku)
		"stub":
			_set_busy(sku)
			_purchase_stub(sku)
		_:
			if _billing_client != null:
				_schedule_reconnect()
			purchase_failed.emit(sku, "unavailable")


func restore_purchases() -> void:
	if _busy:
		return
	if is_stub_mode():
		if _billing_client != null:
			_schedule_reconnect()
		restore_completed.emit()
		return
	_set_busy("")
	_restore_pending = true
	_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)


func reset_purchases_for_dev() -> void:
	if not is_stub_mode():
		return
	GameState.ads_removed = false
	GameState.starter_pack_owned = false
	GameState.merge_hint_owned = false
	GameState.clear_owned_paid_seasons()
	GameState.revoke_iap_cosmetics()
	GameState.save_player_save()
	catalog_updated.emit()


func _try_init_billing() -> bool:
	if OS.get_name() != "Android":
		return false
	if not ResourceLoader.exists(BILLING_SCRIPT):
		return false
	_has_billing_plugin = true
	var client := _make_billing_client()
	if client == null:
		return false
	attach_billing_client(client)
	return true


## Seam za GUT: pravi klijent iz plugina; test ubacuje lažni preko attach_billing_client().
func _make_billing_client() -> Object:
	var script: Script = load(BILLING_SCRIPT)
	if script == null:
		return null
	return script.new()


func attach_billing_client(client: Object) -> void:
	_billing_client = client
	if client is Node and (client as Node).get_parent() == null:
		add_child(client as Node)
	_connect_billing_signal("connected", _on_billing_connected)
	_connect_billing_signal("disconnected", _on_billing_disconnected)
	_connect_billing_signal("connect_error", _on_billing_connect_error)
	_connect_billing_signal("query_product_details_response", _on_query_product_details_response)
	_connect_billing_signal("query_purchases_response", _on_query_purchases_response)
	_connect_billing_signal("on_purchase_updated", _on_purchase_updated)
	_connect_billing_signal("acknowledge_purchase_response", _on_acknowledge_purchase_response)
	_connect_billing_signal("consume_purchase_response", _on_consume_purchase_response)


func _connect_billing_signal(signal_name: String, callable: Callable) -> void:
	if _billing_client.has_signal(signal_name) and not _billing_client.is_connected(signal_name, callable):
		_billing_client.connect(signal_name, callable)


func _on_billing_connected() -> void:
	_billing_ready = true
	_reconnect_attempt = 0
	_reconnect_scheduled = false
	_query_product_details()
	_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)


func _query_product_details() -> void:
	var play_ids: PackedStringArray = []
	for sku in CONFIG.all_skus():
		play_ids.append(CONFIG.get_play_product_id(sku))
	_billing_client.call("query_product_details", play_ids, _PRODUCT_TYPE_INAPP)


func _on_billing_disconnected() -> void:
	_billing_ready = false
	_drop_in_flight("billing_disconnected")
	_schedule_reconnect()


func _on_billing_connect_error(response_code: int, debug_message: String) -> void:
	_billing_ready = false
	push_warning("IAPManager: billing connect error %d — %s" % [response_code, debug_message])
	_drop_in_flight("billing_disconnected")
	_schedule_reconnect()


## Play servis pukao usred kupovine / restore-a: otključaj Shop, javi neuspjeh.
## Ako je kupovina ipak prošla, sljedeći query_purchases je vrati (purchase_restored).
func _drop_in_flight(reason: String) -> void:
	if _restore_pending:
		_restore_pending = false
		_clear_busy()
		restore_completed.emit()
	elif _busy:
		_fail_purchase(_pending_purchase_sku, reason)


func _schedule_reconnect() -> void:
	if _reconnect_scheduled or _billing_client == null or _billing_ready:
		return
	if not is_inside_tree():
		return
	_reconnect_scheduled = true
	var delay: float = RECONNECT_DELAYS[mini(_reconnect_attempt, RECONNECT_DELAYS.size() - 1)]
	_reconnect_attempt += 1
	get_tree().create_timer(delay).timeout.connect(func() -> void:
		_reconnect_scheduled = false
		if _billing_client != null and not _billing_ready:
			_billing_client.call("start_connection")
	, CONNECT_ONE_SHOT)


func _on_query_product_details_response(query_result: Dictionary) -> void:
	if int(query_result.get("response_code", -1)) != _RESPONSE_OK:
		push_warning(
			"IAPManager: product query failed (%s)" % query_result.get("debug_message", "unknown")
		)
		return
	var details_list: Variant = query_result.get("product_details", [])
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
	var unfetched: Variant = query_result.get("unfetched_products", [])
	if unfetched is Array and not (unfetched as Array).is_empty():
		push_warning("IAPManager: Play has no product for %s" % str(unfetched))
	_product_details_loaded = true
	catalog_updated.emit()


func _on_query_purchases_response(query_result: Dictionary) -> void:
	if int(query_result.get("response_code", -1)) != _RESPONSE_OK:
		if _restore_pending:
			_restore_pending = false
			_clear_busy()
			restore_completed.emit()
		return
	var purchases: Variant = query_result.get("purchases", [])
	if purchases is Array:
		for purchase in purchases:
			if purchase is Dictionary:
				_process_purchase(purchase, false)
	_maybe_finish_restore()


## Restore javlja kraj tek kad su ack / consume iz tog upita gotovi — inače Settings
## pokaže „ništa za vratiti" a stvar stigne sekundu kasnije.
func _maybe_finish_restore() -> void:
	if not _restore_pending:
		return
	for entry in _pending_ack_tokens.values():
		if not bool((entry as Dictionary).get("user", false)):
			return
	_restore_pending = false
	_clear_busy()
	restore_completed.emit()


func _on_purchase_updated(result: Dictionary) -> void:
	var code := int(result.get("response_code", -1))
	if code != _RESPONSE_OK:
		if code == _RESPONSE_ITEM_ALREADY_OWNED and _billing_ready:
			# Kupljeno ranije (drugi uređaj / reinstall): vrati vlasništvo umjesto greške.
			_billing_client.call("query_purchases", _PRODUCT_TYPE_INAPP)
		_fail_purchase(_pending_purchase_sku, purchase_result_reason(code))
		return
	var purchases: Variant = result.get("purchases", [])
	if not purchases is Array or (purchases as Array).is_empty():
		_fail_purchase(_pending_purchase_sku, "purchase_empty")
		return
	for purchase in purchases:
		if purchase is Dictionary:
			_process_purchase(purchase, true)


func _on_acknowledge_purchase_response(result: Dictionary) -> void:
	_finish_store_action(result, "ack_failed")


func _on_consume_purchase_response(result: Dictionary) -> void:
	_finish_store_action(result, "consume_failed")


## Grant tek kad Play potvrdi acknowledge / consume (MEAD-2). Prije toga UI je javljao
## uspjeh bez predmeta, a neacknowledge-ovanu kupovinu Play sam refundira za 3 dana.
func _finish_store_action(result: Dictionary, fail_reason: String) -> void:
	var token := str(result.get("token", ""))
	if not _pending_ack_tokens.has(token):
		return
	var entry: Dictionary = _pending_ack_tokens[token]
	_pending_ack_tokens.erase(token)
	var sku := str(entry.get("sku", ""))
	var from_user := bool(entry.get("user", false))
	if int(result.get("response_code", -1)) != _RESPONSE_OK:
		push_warning("IAPManager: %s for %s" % [fail_reason, sku])
		if from_user:
			_fail_purchase(sku, fail_reason)
		_maybe_finish_restore()
		return
	_grant_product(sku, token, from_user)
	if from_user:
		_complete_purchase(sku)
	else:
		_announce_restored(sku)
	_maybe_finish_restore()


func _purchase_android(sku: String) -> void:
	if not _product_details_loaded:
		# Play traži query_product_details prije purchase(); prvi pokušaj samo napuni katalog.
		_query_product_details()
		_fail_purchase(sku, "store_not_ready")
		return
	var play_id := CONFIG.get_play_product_id(sku)
	var result: Variant = _billing_client.call("purchase", play_id)
	if result is Dictionary and int((result as Dictionary).get("response_code", -1)) != _RESPONSE_OK:
		_fail_purchase(sku, purchase_result_reason(int((result as Dictionary).get("response_code", -1))))


func _purchase_stub(sku: String) -> void:
	var timer := get_tree().create_timer(0.9)
	timer.timeout.connect(func() -> void:
		_grant_product(sku)
		_complete_purchase(sku)
	, CONNECT_ONE_SHOT)


func _process_purchase(purchase: Dictionary, from_user_flow: bool) -> void:
	var state := int(purchase.get("purchase_state", -1))
	if state != _PURCHASE_STATE_PURCHASED:
		# PENDING: Play još čeka uplatu — ne daruj. Kad prođe, stiže ponovo kao PURCHASED
		# (on_purchase_updated ili query_purchases na resume / sljedećem startu).
		if from_user_flow:
			_fail_purchase(_pending_purchase_sku, "purchase_pending")
		return
	var play_id := first_product_id(purchase)
	if play_id.is_empty():
		if from_user_flow:
			_fail_purchase(_pending_purchase_sku, "missing_product_id")
		return
	var sku := CONFIG.sku_for_play_product_id(play_id)
	if not CONFIG.IAP_PRODUCTS.has(sku):
		push_warning("IAPManager: unknown Play product %s" % play_id)
		return
	if from_user_flow:
		_pending_purchase_sku = sku
	var token := str(purchase.get("purchase_token", ""))
	if CONFIG.is_consumable(sku):
		_finish_consumable(sku, token, from_user_flow)
		return
	if bool(purchase.get("is_acknowledged", false)):
		var had := owns_product(sku)
		_grant_product(sku, token, from_user_flow)
		if from_user_flow:
			_complete_purchase(sku)
		elif not had:
			_announce_restored(sku)
		return
	if token.is_empty():
		if from_user_flow:
			_fail_purchase(sku, "missing_token")
		return
	if _pending_ack_tokens.has(token):
		return
	_pending_ack_tokens[token] = {"sku": sku, "user": from_user_flow}
	_billing_client.call("acknowledge_purchase", token)


func _finish_consumable(sku: String, token: String, from_user_flow: bool) -> void:
	if token.is_empty():
		if from_user_flow:
			_fail_purchase(sku, "missing_token")
		return
	if GameState.has_granted_purchase_token(token):
		if from_user_flow:
			_complete_purchase(sku)
		return
	if _billing_client == null or not _billing_client.has_method("consume_purchase"):
		push_error("IAPManager: consume_purchase missing — Loot Burst not granted")
		if from_user_flow:
			_fail_purchase(sku, "consume_unavailable")
		return
	if _pending_ack_tokens.has(token):
		return
	_pending_ack_tokens[token] = {"sku": sku, "user": from_user_flow}
	_billing_client.call("consume_purchase", token)


func _grant_product(sku: String, purchase_token: String = "", from_user_flow: bool = true) -> void:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			GameState.ads_removed = true
		CONFIG.SKU_STARTER_PACK:
			if GameState.starter_pack_owned:
				return
			GameState.grant_starter_pack()
		CONFIG.SKU_BOOSTER_MERGE_HINT:
			GameState.merge_hint_owned = true
		CONFIG.SKU_BOOSTER_LOOT_BURST:
			if not _try_grant_loot_burst(purchase_token, from_user_flow):
				return
		_:
			var season_id := CONFIG.season_id_for_sku(sku)
			if not season_id.is_empty():
				GameState.grant_paid_season(season_id)
			var cosmetic_id := CONFIG.cosmetic_for_sku(sku)
			if not cosmetic_id.is_empty():
				# Kupljen u Shopu = odmah ga nosi; restore / billing connect samo vrati vlasništvo.
				GameState.grant_iap_cosmetic(cosmetic_id, from_user_flow)
	GameState.save_player_save()


## Loot Burst je potrošan: svaki purchase_token jednom. Restore bez tokena ne smije
## kovati +5 na svakom billing connectu. Prava kupovina (from_user_flow) i dalje daje.
func _try_grant_loot_burst(token: String, from_user_flow: bool) -> bool:
	if token.is_empty():
		if not from_user_flow:
			return false
	elif GameState.has_granted_purchase_token(token):
		return false
	last_loot_burst = GameState.boosters.grant_loot_burst()
	if not token.is_empty():
		GameState.record_granted_purchase_token(token)
	return true


func _announce_restored(sku: String) -> void:
	purchase_restored.emit(sku)
	catalog_updated.emit()


func _set_busy(sku: String) -> void:
	_busy = true
	_pending_purchase_sku = sku
	_busy_serial += 1
	var serial := _busy_serial
	if not is_inside_tree():
		return
	get_tree().create_timer(BUSY_TIMEOUT_SEC).timeout.connect(func() -> void:
		if _busy and serial == _busy_serial:
			push_warning("IAPManager: store did not answer in %d s" % int(BUSY_TIMEOUT_SEC))
			if _restore_pending:
				_restore_pending = false
				_clear_busy()
				restore_completed.emit()
			else:
				_fail_purchase(_pending_purchase_sku, "timeout")
	, CONNECT_ONE_SHOT)


func _clear_busy() -> void:
	_busy = false
	_pending_purchase_sku = ""
	_busy_serial += 1


func _complete_purchase(sku: String) -> void:
	_clear_busy()
	purchase_completed.emit(sku)


func _fail_purchase(sku: String, reason: String) -> void:
	var failed_sku := sku if not sku.is_empty() else _pending_purchase_sku
	_clear_busy()
	if failed_sku.is_empty():
		return
	purchase_failed.emit(failed_sku, reason)


func _extract_formatted_price(details: Dictionary) -> String:
	# 3.3.0: one_time_purchase_offer_details_list (Billing 8+ više ponuda); stariji pluginovi: jedan dict.
	var offers: Variant = details.get("one_time_purchase_offer_details_list", [])
	if offers is Array:
		for offer in offers:
			if offer is Dictionary:
				var formatted := str((offer as Dictionary).get("formatted_price", ""))
				if not formatted.is_empty():
					return formatted
	var one_time: Variant = details.get("one_time_purchase_offer_details", {})
	if one_time is Dictionary:
		var formatted := str((one_time as Dictionary).get("formatted_price", ""))
		if not formatted.is_empty():
			return formatted
	for key in ["formatted_price", "price", "price_text"]:
		var value := str(details.get(key, ""))
		if not value.is_empty():
			return value
	return ""
