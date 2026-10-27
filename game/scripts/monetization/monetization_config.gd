class_name MonetizationConfig
extends RefCounted

## Public test IDs and SKUs — safe for git (see sigurnost.md).

# --- KUPOVINE PRAVIM NOVCEM (IAP) — jedan prekidač ----------------------------------------
# false = v1 samo s reklamama (BiH nije Google Play merchant zemlja — play-console-sutra § 0;
#   odluka 2026-10-26). Ono što se prodavalo pravim novcem kupuje se COINIMA iz igre
#   (`coin_price` u IAP_PRODUCTS, isti grant kao Play — IAPManager.buy_with_coins):
#   - Shop: tabovi Seasons · Looks (Sir Pip) · Boosters, dva tapa kao kozmetika; nema taba Support;
#   - Home: tab Premium s temama za coine; Camp: kartica sljedeće teme za coine; Ormar: Sir Pip;
#   - Remove Ads i Starter Pack (coin_price 0) se ne nude; Settings nema Purchases (Restore);
#   - Google Play Billing se ne spaja, a za v1 je i plugin isključen (project.godot) — AAB nema
#     dozvolu BILLING. Ember (test-zaključan) ima cijenu, ali se ne nudi dok sezona nije u igri.
# true = sve kupovine pravim novcem kao do sada (€ iz Playa). Povratak: true + plugin uključen +
#   proizvodi u Play Consoleu. Što je igrač kupio coinima ostaje njegovo (Play restore ne oduzima).
const IAP_ENABLED := false
## Samo za testove (GUT / smoke): -1 = IAP_ENABLED, 0 = isključeno, 1 = uključeno.
static var iap_override: int = -1


static func iap_enabled() -> bool:
	if iap_override >= 0:
		return iap_override == 1
	return IAP_ENABLED


## Smije li se igraču pokazati stvar koja se prodavala pravim novcem: uvijek kad su kupovine
## uključene; bez njih kad je već njegova ili se prodaje za coine (`sku` s coin cijenom).
static func shows_paid_offer(already_owned: bool, sku: String = "") -> bool:
	return iap_enabled() or already_owned or sells_for_coins(sku)


## Cijena u coinima iz IAP_PRODUCTS (0 = nema coin varijante — Remove Ads, Starter Pack).
static func coin_price(sku: String) -> int:
	return maxi(0, int(IAP_PRODUCTS.get(sku, {}).get("coin_price", 0)))


## Prodaje li se SKU za coine: samo kad su kupovine pravim novcem isključene i ima coin cijenu.
static func sells_for_coins(sku: String) -> bool:
	return not iap_enabled() and coin_price(sku) > 0

# Google AdMob TEST ID-evi (javni) — https://developers.google.com/admob/android/test-ads
const ADMOB_TEST_APP_ID_ANDROID := "ca-app-pub-3940256099942544~3347511713"
const ADMOB_TEST_REWARDED_ANDROID := "ca-app-pub-3940256099942544/5224354917"
const ADMOB_TEST_INTERSTITIAL_ANDROID := "ca-app-pub-3940256099942544/1033173712"

# --- PRODUCTION IDS (TODO Alem) -------------------------------------------------------------
# AdMob konzola → Apps → Merge Meadow:
#   1) App ID (ima „~") → ADMOB_APP_ID_ANDROID_PROD **i** project.godot `admob/general/android/app_id`
#      (Project Settings → AdMob; plugin ga upisuje u AndroidManifest, test_ad_manager provjerava da su
#      isti). Dok je tamo test ID, plugin postavku ne snima u project.godot — to je normalno.
#   2) Ad units → Rewarded i Interstitial (imaju „/") → dvije konstante ispod.
# ID-evi nisu tajni (stoje u svakom APK-u), smiju u git. Dok su prazni, i release koristi test reklame
# (scripts/android-export.ps1 na to upozori) — za Play produkciju moraju biti popunjeni.
const ADMOB_APP_ID_ANDROID_PROD := ""
const ADMOB_REWARDED_ANDROID_PROD := ""
const ADMOB_INTERSTITIAL_ANDROID_PROD := ""
# ---------------------------------------------------------------------------------------------


## Prod ID samo u release buildu i samo kad je upisan; debug build uvijek test (AdMob politika:
## vlastite reklame se ne klikaju tokom razvoja).
static func pick_ad_unit(prod_id: String, test_id: String, release_build: bool) -> String:
	if release_build and not prod_id.is_empty():
		return prod_id
	return test_id


static func rewarded_unit_id() -> String:
	return pick_ad_unit(ADMOB_REWARDED_ANDROID_PROD, ADMOB_TEST_REWARDED_ANDROID, not OS.is_debug_build())


static func interstitial_unit_id() -> String:
	return pick_ad_unit(ADMOB_INTERSTITIAL_ANDROID_PROD, ADMOB_TEST_INTERSTITIAL_ANDROID, not OS.is_debug_build())

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
## Premium Pip skin (design_handoff_muncher_premium_pip): non-consumable, samo izgled.
const SKU_PIP_KNIGHT := "pip_knight"

const BOOSTER_MERGE_HINT := "merge_hint"
const BOOSTER_LOOT_BURST := "loot_burst"

## Starter Pack (Shop v2): coini + Pip Blossom + po 10 sjemenki prvih 5 tipova Country Bloom;
## nudi se 7 dana od prvog pokretanja. Merge Hint više nije u paketu. Coini 100 → 1000 uz nove
## cijene (balans ciklus 1) — opis proizvoda u Play Consoleu treba isto ažurirati.
const STARTER_PACK_COINS := 1000
const STARTER_PACK_COSMETIC := "pip_blossom"
const STARTER_PACK_SEED_TYPES: Array[String] = ["clover", "daisy", "buttercup", "tulip", "sunflower"]
const STARTER_PACK_SEEDS_EACH := 10
const STARTER_PACK_DAYS := 7

## Loot Burst: +5 ★3 cvjetova sezone koja otključava sljedeću besplatnu.
const LOOT_BURST_STAR3 := 5

## price_label = rezervna € cijena (s IAP-om, dok Play ne javi pravu). coin_price = cijena u coinima
## kad su kupovine pravim novcem isključene (v1, 2026-10-26); 0 = ne nudi se za coine. Cijene i
## zašto: docs/02-design/ekonomija-brojevi.md § Coin cijene bez kupovina (coin_offer_sim.gd).
const IAP_PRODUCTS := {
	SKU_REMOVE_ADS: {
		"title": "Remove Ads",
		"description": "Turn off interstitial ads between runs. Rewarded videos stay optional.",
		"price_label": "€3.99",
		"coin_price": 0,
		"play_product_id": "remove_ads",
		"consumable": false,
	},
	SKU_STARTER_PACK: {
		"title": "Starter Pack",
		"description": "1,000 coins, Pip Blossom and 10 of each first five seeds. 7 days only.",
		"price_label": "€1.99",
		"coin_price": 0,
		"play_product_id": "starter_pack",
		"consumable": false,
	},
	SKU_BOOSTER_MERGE_HINT: {
		"title": "Merge Hint",
		"description": "Marks the closest match while you hold a seed in the Arena. Yours for good.",
		"price_label": "€0.99",
		"coin_price": 1500,
		"play_product_id": "booster_merge_hint",
		"consumable": false,
		"booster_id": BOOSTER_MERGE_HINT,
	},
	SKU_BOOSTER_LOOT_BURST: {
		"title": "Loot Burst",
		"description": "+5 ★3 flowers toward the next free season.",
		"price_label": "€0.99",
		"coin_price": 500,
		"play_product_id": "booster_loot_burst",
		"consumable": true,
		"booster_id": BOOSTER_LOOT_BURST,
	},
	SKU_SEASON_MOONLIT: {
		"title": "Moonlit Warren",
		"description": "Unlock the Moonlit Warren theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€2.99",
		"coin_price": 3000,
		"play_product_id": "season_pack_moonlit_warren",
		"consumable": false,
		"season_id": "moonlit_warren",
	},
	SKU_SEASON_CORAL: {
		"title": "Coral Tide Garden",
		"description": "Unlock the Coral Tide Garden theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€3.49",
		"coin_price": 3500,
		"play_product_id": "season_pack_coral_tide",
		"consumable": false,
		"season_id": "coral_tide",
	},
	SKU_SEASON_STARFALL: {
		"title": "Starfall Glade",
		"description": "Unlock the Starfall Glade theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€2.99",
		"coin_price": 3000,
		"play_product_id": "season_pack_starfall_glade",
		"consumable": false,
		"season_id": "starfall_glade",
	},
	SKU_SEASON_EMBER: {
		"title": "Ember Fen",
		"description": "Unlock the Ember Fen theme. Cosmetic only — no extra loot or magnet power.",
		"price_label": "€3.49",
		"coin_price": 3500,
		"play_product_id": "season_pack_ember_fen",
		"consumable": false,
		"season_id": "ember_fen",
	},
	## Cijena = prijedlog paketa (€3,99, iznad impulsnih €1,99, ispod €4,99); konačnu daje vlasnik.
	SKU_PIP_KNIGHT: {
		"title": "Sir Pip",
		"description": "Meadow Knight armour for Pip. Looks only — no gameplay effect.",
		"price_label": "€3.99",
		"coin_price": 3000,
		"play_product_id": "pip_knight",
		"consumable": false,
		"cosmetic_id": "pip_knight",
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


## Kozmetika koju SKU daje ("" ako nije kozmetika).
static func cosmetic_for_sku(sku: String) -> String:
	return str(IAP_PRODUCTS.get(sku, {}).get("cosmetic_id", ""))
