---
type: tehnicko
status: aktivan
milestone: M8
tags: [tehnicko, godot, iap, billing, monetizacija]
povezano:
  - CHECKPOINT
  - ../02-design/monetizacija
  - admob-setup
  - sigurnost
ai_sažetak: "GodotGooglePlayBilling plugin — instalacija, Play Console product ID-evi, IAPManager production flow."
---

# Google Play Billing setup (Godot 4.7)

> **D3:** `IAPManager` autoload radi u **stub** modu na Windowsu/editoru. Za prave kupnje na Androidu instaliraj billing plugin i kreiraj proizvode u Play Console.

## 1. Instaliraj plugin

1. Preuzmi [GodotGooglePlayBilling](https://github.com/godot-sdk-integrations/godot-google-play-billing/releases) (Godot 4.2+).
2. Raspakiraj u `game/addons/GodotGooglePlayBilling/`.
3. **Project → Project Settings → Plugins** → uključi **GodotGooglePlayBilling**.
4. **Project → Export → Android** → uključi **Gradle Build** (`gradle/use_gradle_build`).

Vidi [Godot docs — Android IAP](https://docs.godotengine.org/en/stable/tutorials/platform/android/android_in_app_purchases.html).

> **Pažnja (2026-10-06):** zadnji plugin za Godot 4 je **3.3.0** (`godot-google-play-billing.zip`, 43 KB, Billing Library 9.1). Od 3.0.0 `BillingClient` više nije autoload singleton, nego GDScript klasa koja se pravi s `BillingClient.new()`, a 3.2.0 je promijenio potpis `purchase()`. `iap_manager.gd` (`_try_init_billing`) ga traži preko `ClassDB.class_exists` / `ClassDB.instantiate`, a to vidi samo klase iz engine-a, ne GDScript `class_name`. **Uz plugin zato ide i izmjena `_try_init_billing()` i poziva `purchase()`** po README-u plugina, inače IAP ostaje u stub modu i na Androidu.

## 2. Play Console proizvodi

Kreiraj **managed products** (non-consumable) s ID-evima iz koda:

| Product ID | Tip | Rezervna cijena u kodu |
|------------|-----|--------|
| `remove_ads` | Non-consumable | €3.99 |
| `starter_pack` | Non-consumable | €1.99 |
| `booster_merge_hint` | Non-consumable | €0.99 |
| `booster_loot_burst` | **Consumable** | €0.99 |
| `season_pack_moonlit_warren` | Non-consumable | €2.99 |
| `season_pack_coral_tide` | Non-consumable | €3.49 |
| `season_pack_starfall_glade` | Non-consumable | €2.99 |
| `season_pack_ember_fen` | Non-consumable (tek kad Ember izađe) | €3.49 |

„Rezervna cijena" je `price_label` i vidi se samo dok Play ne vrati pravu cijenu (`formatted_price` u valuti igrača). Kad odlučiš iznose, unesi ih u Play Console i isti EUR iznos u `price_label`. Pillar 2: bez tajmera, popusta i „limited".

ID-evi su u `game/scripts/monetization/monetization_config.gd` (`play_product_id`).

## 3. Kod u projektu

| Fajl | Uloga |
|------|--------|
| `scripts/monetization/iap_manager.gd` | BillingClient, purchase, acknowledge, restore |
| `scripts/monetization/monetization_config.gd` | SKU-ovi, Play product ID-evi, cijene fallback |
| `scripts/ui/shop_screen.gd` | Shop UI — remove ads, starter pack, restore |
| `scripts/monetization/ad_manager.gd` | Interstitial hook — poštuje `GameState.ads_removed` |

## 4. Flow

1. **Startup (Android + plugin):** `BillingClient.start_connection()` → query products → query purchases (sync owned).
2. **Purchase:** `purchase(play_product_id)` → `on_purchase_updated` → `acknowledge_purchase` → grant u `GameState`.
3. **Restore:** Shop → **Restore Purchases** → `query_purchases`.
4. **Remove ads:** gasi interstitiale (`AdManager.can_show_interstitial`); rewarded ×2/revive ostaje opcionalan (Pillar 2).

## 5. Test plan

### Desktop / editor (stub)

1. Main menu → **Shop**
2. Kupi **Remove Ads** → status + gumb disabled
3. Kupi **Starter Pack** → coins/seeds u save
4. Loot ekran → **Retry** — bez interstitiala nakon remove ads

### Android (internal test)

1. Instaliraj plugin + Gradle export
2. Play Console internal test track + test account
3. Shop prikazuje store cijene nakon `query_product_details`
4. Restore nakon reinstalla

## Povezano

- [[admob-setup|admob-setup]]
- [[dev-workflow|dev-workflow]]
- [[../02-design/monetizacija|monetizacija]]
