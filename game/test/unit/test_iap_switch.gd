## MonetizationConfig.IAP_ENABLED — jedan prekidač za v1 samo s reklamama.
extends "res://test/unit/game_state_test_base.gd"

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

var _events: Array[String] = []


func after_each() -> void:
	CONFIG.iap_override = -1
	super.after_each()


func _on_failed(sku: String, reason: String) -> void:
	_events.append("%s:%s" % [sku, reason])


func test_override_beats_constant() -> void:
	CONFIG.iap_override = 0
	assert_false(CONFIG.iap_enabled())
	CONFIG.iap_override = 1
	assert_true(CONFIG.iap_enabled())
	CONFIG.iap_override = -1
	assert_eq(CONFIG.iap_enabled(), CONFIG.IAP_ENABLED)


func test_paid_offer_only_when_on_or_owned() -> void:
	CONFIG.iap_override = 0
	assert_false(CONFIG.shows_paid_offer(false), "IAP off hides what you don't own")
	assert_true(CONFIG.shows_paid_offer(true), "what you already own stays")
	CONFIG.iap_override = 1
	assert_true(CONFIG.shows_paid_offer(false))


func test_shop_tabs_follow_switch() -> void:
	CONFIG.iap_override = 0
	assert_eq(UiShopV2.visible_tabs(), ["looks"])
	CONFIG.iap_override = 1
	assert_eq(UiShopV2.visible_tabs(), UiShopV2.TABS)


func test_purchase_refused_when_off() -> void:
	var iap := get_node("/root/IAPManager")
	iap.purchase_failed.connect(_on_failed)
	CONFIG.iap_override = 0
	iap.purchase("remove_ads")
	iap.purchase_failed.disconnect(_on_failed)
	assert_eq(_events, ["remove_ads:unavailable"])
	assert_false(iap.is_busy())
