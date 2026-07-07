extends Node

## IAP stub — desktop/editor simulacija; Google Play Billing na Androidu (M8 production).

signal purchase_completed(sku: String)
signal purchase_failed(sku: String, reason: String)

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

var _busy: bool = false


func is_stub_mode() -> bool:
	return not _billing_plugin_ready()


func owns_product(sku: String) -> bool:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			return GameState.ads_removed
		CONFIG.SKU_STARTER_PACK:
			return GameState.starter_pack_owned
	return false


func get_price_label(sku: String) -> String:
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
	if OS.get_name() == "Android" and _billing_plugin_ready():
		_purchase_android(sku)
	else:
		_purchase_stub(sku)


func _billing_plugin_ready() -> bool:
	# Godot Google Play Billing addon — hook u M8.
	return Engine.has_singleton("GodotGooglePlayBilling")


func _purchase_stub(sku: String) -> void:
	var timer := get_tree().create_timer(0.9)
	timer.timeout.connect(func() -> void:
		_grant_product(sku)
		_busy = false
		purchase_completed.emit(sku)
	, CONNECT_ONE_SHOT)


func _purchase_android(sku: String) -> void:
	push_warning("IAPManager: billing plugin not wired — stub purchase for %s" % sku)
	_purchase_stub(sku)


func _grant_product(sku: String) -> void:
	match sku:
		CONFIG.SKU_REMOVE_ADS:
			GameState.ads_removed = true
		CONFIG.SKU_STARTER_PACK:
			GameState.starter_pack_owned = true
			GameState.wallet_coins += CONFIG.STARTER_PACK_COINS
			GameState.add_seeds_to_bag(GameState.SEED_TYPE_CLOVER, CONFIG.STARTER_PACK_SEEDS)
	GameState.save_player_save()
