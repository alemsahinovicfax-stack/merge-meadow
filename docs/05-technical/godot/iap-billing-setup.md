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
  - play-console-sutra
ai_sažetak: "GodotGooglePlayBilling 3.3.0 je u game/addons (od 2026-10-23), za v1 (samo reklame, 2026-10-26) isključen u project.godot; IAPManager ga učitava po putanji (GDScript class_name, ne ClassDB): connect → katalog → purchase → acknowledge/consume → grant, reconnect, pending, restore; proizvodi u Play Consoleu još ne postoje."
---

# Google Play Billing setup (Godot 4.7)

> **Stanje 2026-10-26 (v1 samo s reklamama):** `MonetizationConfig.IAP_ENABLED = false` i plugin je **isključen** u `project.godot` → `[editor_plugins]` (fajlovi ostaju u `addons/`), pa AAB nema `.aar` ni dozvolu `com.android.vending.BILLING`. Stvari iz tabele ispod kupuju se coinima (`IAPManager.buy_with_coins`, isti grant). **Povratak IAP-a:** Project Settings → Plugins → GodotGooglePlayBilling on, `IAP_ENABLED := true`, proizvodi u Play Consoleu, novi AAB.
>
> **Stanje 2026-10-23 (LAUNCH-PREP B):** plugin **3.3.0** je instaliran u `game/addons/GodotGooglePlayBilling/` i uključen u `project.godot`. `IAPManager` radi pravi Play tok na Androidu, a stub na desktopu / u editoru. **Netestirano s pravim Playom** — proizvodi u Play Consoleu još ne postoje (vidi [[../../06-production/play-console-sutra|play-console-sutra]] § 0: BiH nije merchant zemlja).

## 1. Plugin

| | |
|--|--|
| Izvor | [godot-google-play-billing 3.3.0](https://github.com/godot-sdk-integrations/godot-google-play-billing/releases/tag/3.3.0) (`godot-google-play-billing.zip`, Billing Library 9.1.0) |
| Folder | `game/addons/GodotGooglePlayBilling/` — ime je hard-codirano u `export_plugin.gd` |
| Uključen | `project.godot` → `[editor_plugins]` |
| Export | radi samo s **Gradle buildom** (`gradle_build/use_gradle_build=true` u sva tri Android preseta) |

**Zašto ne `ClassDB`:** od 3.0 `BillingClient` je GDScript `class_name` (`BillingClient.new()`), ne engine klasa. `ClassDB.class_exists("BillingClient")` je uvijek `false` → stari kod je na Androidu ostajao u stubu ([[greske-katalog|greške #54]]). Sada: `ResourceLoader.exists(BILLING_SCRIPT)` → `load(...).new()` → `add_child`.

## 2. Play Console proizvodi

Play više nema tip „consumable" na proizvodu — igra odlučuje: `consume_purchase` za Loot Burst, `acknowledge_purchase` za sve ostalo. Product ID mora biti identičan kodu (`game/scripts/monetization/monetization_config.gd`, `play_product_id`).

| Product ID | U igri | Rezervna cijena u kodu |
|------------|--------|--------|
| `remove_ads` | trajno | €3.99 |
| `starter_pack` | trajno, jednom | €1.99 |
| `booster_merge_hint` | trajno | €0.99 |
| `booster_loot_burst` | **potrošno** | €0.99 |
| `season_pack_moonlit_warren` | trajno | €2.99 |
| `season_pack_coral_tide` | trajno | €3.49 |
| `season_pack_starfall_glade` | trajno | €2.99 |
| `season_pack_ember_fen` | trajno (tek kad Ember izađe) | €3.49 |
| `pip_knight` | trajno (Sir Pip skin) | €3.99 |

„Rezervna cijena" je `price_label` i vidi se samo dok Play ne vrati pravu (`one_time_purchase_offer_details_list[0].formatted_price`, u valuti igrača). Gotovi nazivi i opisi za Play: [[../../06-production/play-console-sutra|play-console-sutra]] § 6. Pillar 2: bez tajmera, popusta i „limited".

## 3. Kod

| Fajl | Uloga |
|------|--------|
| `scripts/monetization/iap_manager.gd` | autoload `IAPManager`: BillingClient, katalog, purchase, acknowledge/consume, restore, reconnect |
| `scripts/monetization/monetization_config.gd` | SKU-ovi, Play product ID-evi, rezervne cijene |
| `scripts/ui/shop_screen.gd` + `visual/ui_shop_v2.gd` | Shop UI; `status_for(reason)` prevodi razloge neuspjeha |
| `scripts/ui/settings_screen.gd` | Restore purchases (20 s timeout) |
| `test/unit/test_iap_billing_flow.gd` | GUT s `FakeBillingClient` (isti signali / metode kao plugin) |

## 4. Tok

1. **Start (Android + plugin):** `start_connection()` → `connected` → `query_product_details(play_ids, INAPP)` + `query_purchases(INAPP)`.
2. **Kupovina:** `purchase(play_id)` (tek kad je katalog učitan — inače `store_not_ready` i ponovni upit) → `on_purchase_updated` → `acknowledge_purchase` / `consume_purchase` → **grant tek kad Play potvrdi** → `purchase_completed`.
3. **Pending** (`purchase_state == 2`, npr. gotovina, spora kartica): ništa se ne daje, Shop pokaže „Pending". Kad Play javi `PURCHASED` (isti token, `on_purchase_updated` ili `query_purchases` na resume), dođe grant.
4. **Vraćeno vlasništvo** (start, Restore, reinstall, `ITEM_ALREADY_OWNED`): `purchase_restored(sku)` + `catalog_updated` — **ne** `purchase_completed`, pa start igre ne svira „kupljeno" ni ne pokazuje toast.
5. **Restore:** Settings / Shop → `restore_purchases()` → `query_purchases`; `restore_completed` tek kad su svi ack/consume iz tog upita gotovi.
6. **Veza puca:** `disconnected` / `connect_error` → Shop se otključa (`billing_disconnected`), reconnect s backoffom 2 → 4 → … → 60 s; `NOTIFICATION_APPLICATION_RESUMED` → novi upit kupovina.
7. **Ruta (`purchase_route`):** `store` (Play spreman) · `unavailable` (Android s pluginom bez veze, ili release bez plugina — nikad besplatno) · `stub` (desktop / editor / debug APK bez plugina).
8. **Busy timeout:** 120 s bez odgovora → Shop se otključa (`timeout`); zakašnjeli rezultat i dalje stiže.
9. **Loot Burst (consumable):** svaki `purchase_token` daje jednom (`GameState.granted_purchase_tokens`, u saveu).

Razlozi u `purchase_failed`: `purchase_cancelled`, `purchase_pending`, `already_owned`, `store_not_ready`, `billing_disconnected`, `billing_error_<code>`, `ack_failed`, `consume_failed`, `timeout`, `unavailable` (+ stari `busy`, `test_locked`, `expired`, `unknown_sku`).

**Nema server verifikacije** — igra vjeruje Playu na uređaju (token se ne šalje nigdje). Za malu igru prihvatljivo; server (Play Developer API) se može dodati kasnije.

## 5. Test plan

### Desktop / editor (stub)

1. `scripts/gut-run.ps1` — `test_iap_billing_flow`, `test_iap_grant`
2. `scripts/smoke-all.ps1 -Filter "iap|shop|settings|loot_logic"`
3. Ručno: Shop → kupi Remove Ads / Starter Pack → status, toast, coini

### Android (kad postoje proizvodi u Play Consoleu)

1. Play Console → **License testing** → dodaj svoj Gmail (kupovine bez naplate).
2. Upload AAB na **internal test** (`scripts/android-export.ps1 -Preset Aab`), instaliraj **s Play Store linka** (sideload APK ne dobija billing).
3. Shop pokazuje Play cijene (npr. „3,99 KM") umjesto rezervnih.
4. Kupi svaki tip: trajni (Remove Ads), potrošni (Loot Burst ×2), sezonu, Sir Pip.
5. Test kartica „Slow test card, approves after a few minutes" → Pending → grant poslije.
6. Deinstaliraj / instaliraj → Restore → sve se vrati (bez toasta).
7. Avionski mod usred kupovine → Shop se otključa, poslije reconnecta kupovina stigne.

## Povezano

- [[admob-setup|admob-setup]]
- [[dev-workflow|dev-workflow]]
- [[../02-design/monetizacija|monetizacija]]
- [[../../06-production/play-console-sutra|play-console-sutra]]
