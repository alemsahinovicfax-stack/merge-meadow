---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, google-play, d5]
povezano:
  - CHECKPOINT
  - store-listing-en
  - store-screenshots
  - ../05-technical/privacy-policy-draft
  - ../05-technical/godot/iap-billing-setup
ai_sažetak: "Korak-po-korak D5 — Google Play internal testing track (APK, listing, screenshots, testeri)."
---

# D5 — Google Play internal test

> **Build:** `game/merge_meadow_debug.apk` (export: Android Debug, x86_64 + arm64)  
> **Package:** `com.mergemeadow.game`  
> **Copy:** [[store-listing-en|store-listing-en]] · **Screenshots:** `marketing/store/screenshots/` (8× PNG)

## Prije uploada

- [ ] **Privacy policy URL** — `privacy/index.html` → GitHub Pages (vidi ispod)
- [ ] **Developer account** — Google Play Console ($25 one-time), app kreirana
- [ ] **Svjež export** (opcionalno): Godot → Export → `merge_meadow_debug.apk` ili release AAB

### Privacy policy — GitHub Pages (korak 1)

GitHub **ne objavljuje Pages na private repou** bez paid plana. Poruka *Upgrade or make this repository public* = normalno.

1. **Repo → Settings → General → Change visibility → Public**  
   *(Kod ostaje na GitHubu; igra se ne “skida” s interneta — samo je repo vidljiv. Ako ne želiš public, koristi Notion/Google Sites umjesto Pages.)*
2. **Settings → Pages → Build and deployment → Source: GitHub Actions**
3. Push `master` (workflow `Privacy policy Pages` deploya samo folder `privacy/`, ne cijeli vault)
4. URL za Play Console: **`https://alemsahinovicfax-stack.github.io/merge-meadow/`**
5. Provjeri u incognito prije submita

## Play Console — redoslijed

### 1. Create app

1. [Play Console](https://play.google.com/console) → **Create app**
2. Name: **Merge Meadow**, default language **English**, Games / Casual, Free

### 2. Internal testing release

1. **Testing → Internal testing → Create new release**
2. **Upload** `merge_meadow_debug.apk` (App bundle kasnije za production)
3. Release name: `0.1.0-internal-1`
4. Release notes (EN): `First internal build — lane run, camp merge, shop stub IAP.`

### 3. Store listing (Main store listing)

Kopiraj iz [[store-listing-en|store-listing-en]]:

| Polje | Izvor |
|-------|--------|
| App name | Merge Meadow |
| Short description | store-listing-en § Google Play |
| Full description | store-listing-en § Full description |
| App icon | 512×512 PNG *(TODO asset)* |
| Feature graphic | 1024×500 *(TODO asset)* |
| Phone screenshots | Upload `01`–`08` iz `marketing/store/screenshots/` |

### 4. App content (obavezno prije publish)

| Sekcija | Akcija |
|---------|--------|
| Privacy policy | URL s hostane policy |
| Ads | Yes — AdMob (rewarded + interstitial) |
| Content rating | IARC upitnik — casual, no violence |
| Target audience | General / 13+ prema ads policy |
| Data safety | Local save + ads ID + purchases (vidi privacy draft) |

### 5. Testeri

1. **Internal testing → Testers → Create email list**
2. Dodaj svoj Gmail
3. **Save → Publish** internal release
4. Otvori **opt-in link** na telefonu → Install

### 6. IAP (može nakon prvog internal builda)

Product ID-evi moraju odgovarati kodu:

| Play product ID | Tip | Cijena |
|-----------------|-----|--------|
| `remove_ads` | One-time | €3.99 |
| `starter_pack` | One-time | €1.99 |

Detalji: [[../05-technical/godot/iap-billing-setup|iap-billing-setup]] (billing plugin + license testers).

## Provjera nakon installa

- [ ] Run → loot → camp (fail **To Camp** ne smije auto-startati Play)
- [ ] Shop bez dev teksta / Reset (dev)
- [ ] Main menu → Endless → run
- [ ] Restore purchases (tek s billing pluginom)

## Povezano

- [[CHECKPOINT|CHECKPOINT]] — D5 checkbox
- [[store-screenshots|store-screenshots]]
- [[../05-technical/platforme|platforme]] — Pixel_4_API33 emulator
