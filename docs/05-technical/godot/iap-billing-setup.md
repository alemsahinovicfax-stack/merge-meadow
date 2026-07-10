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

## 2. Play Console proizvodi

Kreiraj **managed products** (non-consumable) s ID-evima iz koda:

| Product ID | Tip | Cijena |
|------------|-----|--------|
| `remove_ads` | Non-consumable | €3.99 |
| `starter_pack` | Non-consumable | €1.99 |

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
