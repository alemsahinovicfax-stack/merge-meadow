class_name MonetizationConfig
extends RefCounted

## Javni test ID-evi i SKU-ovi — sigurno za git (vidi sigurnost.md).

# Google AdMob test rewarded (Android) — https://developers.google.com/admob/android/test-ads
const ADMOB_TEST_REWARDED_ANDROID := "ca-app-pub-3940256099942544/5224354917"

const PLACEMENT_DOUBLE_LOOT := "double_loot"
const PLACEMENT_REVIVE := "revive"

const SKU_REMOVE_ADS := "remove_ads"
const SKU_STARTER_PACK := "starter_pack"

const IAP_PRODUCTS := {
	SKU_REMOVE_ADS: {
		"title": "Remove Ads",
		"price_label": "€3.99",
		"consumable": false,
	},
	SKU_STARTER_PACK: {
		"title": "Starter Pack",
		"price_label": "€1.99",
		"consumable": false,
	},
}

const STARTER_PACK_COINS := 15
const STARTER_PACK_SEEDS := 8
