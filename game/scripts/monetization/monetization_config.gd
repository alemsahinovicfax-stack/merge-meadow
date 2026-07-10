class_name MonetizationConfig
extends RefCounted

## Public test IDs and SKUs — safe for git (see sigurnost.md).

# Google AdMob test rewarded (Android) — https://developers.google.com/admob/android/test-ads
const ADMOB_TEST_REWARDED_ANDROID := "ca-app-pub-3940256099942544/5224354917"

const PLACEMENT_DOUBLE_LOOT := "double_loot"
const PLACEMENT_REVIVE := "revive"
const PLACEMENT_LOOT_RETRY := "loot_retry"

const SKU_REMOVE_ADS := "remove_ads"
const SKU_STARTER_PACK := "starter_pack"

const STARTER_PACK_COINS := 15
const STARTER_PACK_SEEDS := 8

const IAP_PRODUCTS := {
	SKU_REMOVE_ADS: {
		"title": "Remove Ads",
		"description": "Turn off interstitial ads between runs. Rewarded videos stay optional.",
		"price_label": "€3.99",
		"play_product_id": "remove_ads",
		"consumable": false,
	},
	SKU_STARTER_PACK: {
		"title": "Starter Pack",
		"description": "One-time boost: +15 coins and +8 clover seeds.",
		"price_label": "€1.99",
		"play_product_id": "starter_pack",
		"consumable": false,
	},
}


static func all_skus() -> Array[String]:
	var out: Array[String] = []
	for sku in IAP_PRODUCTS:
		out.append(str(sku))
	return out


static func get_play_product_id(sku: String) -> String:
	var product: Dictionary = IAP_PRODUCTS.get(sku, {})
	var play_id := str(product.get("play_product_id", sku))
	return play_id if not play_id.is_empty() else sku


static func sku_for_play_product_id(play_product_id: String) -> String:
	for sku in IAP_PRODUCTS:
		if get_play_product_id(str(sku)) == play_product_id:
			return str(sku)
	return play_product_id


static func get_product_title(sku: String) -> String:
	return str(IAP_PRODUCTS.get(sku, {}).get("title", sku))


static func get_product_description(sku: String) -> String:
	return str(IAP_PRODUCTS.get(sku, {}).get("description", ""))
