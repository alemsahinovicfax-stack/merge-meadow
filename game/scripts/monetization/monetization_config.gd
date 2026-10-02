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
const SKU_BOOSTER_MERGE_HINT := "booster_merge_hint"
const SKU_BOOSTER_LOOT_BURST := "booster_loot_burst"
const SKU_SEASON_MOONLIT := "season_pack_moonlit_warren"
const SKU_SEASON_CORAL := "season_pack_coral_tide"
const SKU_SEASON_STARFALL := "season_pack_starfall_glade"
const SKU_SEASON_EMBER := "season_pack_ember_fen"

const BOOSTER_MERGE_HINT := "merge_hint"
const BOOSTER_LOOT_BURST := "loot_burst"

## Starter Pack (Shop v2): 100 coina + Pip Blossom + po 10 sjemenki prvih 5 tipova
## Country Bloom; nudi se 7 dana od prvog pokretanja. Merge Hint više nije u paketu.
const STARTER_PACK_COINS := 100
const STARTER_PACK_COSMETIC := "pip_blossom"
const STARTER_PACK_SEED_TYPES: Array[String] = ["clover", "daisy", "buttercup", "tulip", "sunflower"]
const STARTER_PACK_SEEDS_EACH := 10
const STARTER_PACK_DAYS := 7

## Loot Burst: +5 ★3 cvjetova sezone koja otključava sljedeću besplatnu.
const LOOT_BURST_STAR3 := 5

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
		"description": "100 coins, Pip Blossom and 10 of each first five seeds. 7 days only.",
		"price_label": "€1.99",
		"play_product_id": "starter_pack",
		"consumable": false,
	},
	SKU_BOOSTER_MERGE_HINT: {
		"title": "Merge Hint",
		"description": "Marks the closest match while you hold a seed in the Arena. Yours for good.",
		"price_label": "€0.99",
		"play_product_id": "booster_merge_hint",
		"consumable": false,
		"booster_id": BOOSTER_MERGE_HINT,
	},
	SKU_BOOSTER_LOOT_BURST: {
		"title": "Loot Burst",
		"description": "+5 ★3 flowers toward the next free season.",
		"price_label": "€0.99",
		"play_product_id": "booster_loot_burst",
		"consumable": true,
		"booster_id": BOOSTER_LOOT_BURST,
	},
	SKU_SEASON_MOONLIT: {
		"title": "Moonlit Warren",
		"description": "Unlock the Moonlit Warren theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€2.99",
		"play_product_id": "season_pack_moonlit_warren",
		"consumable": false,
		"season_id": "moonlit_warren",
	},
	SKU_SEASON_CORAL: {
		"title": "Coral Tide Garden",
		"description": "Unlock the Coral Tide Garden theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€3.49",
		"play_product_id": "season_pack_coral_tide",
		"consumable": false,
		"season_id": "coral_tide",
	},
	SKU_SEASON_STARFALL: {
		"title": "Starfall Glade",
		"description": "Unlock the Starfall Glade theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€2.99",
		"play_product_id": "season_pack_starfall_glade",
		"consumable": false,
		"season_id": "starfall_glade",
	},
	SKU_SEASON_EMBER: {
		"title": "Ember Fen",
		"description": "Unlock the Ember Fen theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€3.49",
		"play_product_id": "season_pack_ember_fen",
		"consumable": false,
		"season_id": "ember_fen",
	},
}


static func all_booster_ids() -> Array[String]:
	return [BOOSTER_MERGE_HINT, BOOSTER_LOOT_BURST]


static func booster_sku(booster_id: String) -> String:
	for sku in IAP_PRODUCTS:
		var product: Dictionary = IAP_PRODUCTS[sku]
		if str(product.get("booster_id", "")) == booster_id:
			return str(sku)
	return ""


static func sku_booster_id(sku: String) -> String:
	return str(IAP_PRODUCTS.get(sku, {}).get("booster_id", ""))


static func is_consumable(sku: String) -> bool:
	return bool(IAP_PRODUCTS.get(sku, {}).get("consumable", false))


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


static func is_season_sku(sku: String) -> bool:
	return not season_id_for_sku(sku).is_empty()


static func season_id_for_sku(sku: String) -> String:
	return str(IAP_PRODUCTS.get(sku, {}).get("season_id", ""))
