---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, store, aso, marketing]
povezano:
  - CHECKPOINT
  - ../01-vision/pitch
  - ../04-experience/art-direction
  - ../05-technical/privacy-policy-draft
  - store-screenshots
ai_sažetak: "Copy-paste EN tekst za Google Play i App Store (hook Run. Merge. Bloom., 7 livada, 140 levela, bez kupovina) + ASO keywords; gotovi grafički materijali su u marketing/store/ (Claude Design, 2026-10-29)."
---

# Store listing (EN)

> **D4 deliverable.** Kopiraj polja u Play Console / App Store Connect. Gotova grafika (Claude Design round 3, 2026-10-29) je u `marketing/store/` — vidi § Grafika niže i `marketing/store/README.md`.
>
> Činjenice u tekstu prate [[../04-experience/design-drafts/store-assets-cd-brief|store-assets-cd-brief]] §1: 7 livada, 20 levela po livadi = 140, Endless poslije levela 15, bez kupovina pravim novcem, bez energije i tajmera. **Ne pisati** „100 levels", Easy/Normal/Hard, „pets".

## App identity

| Polje | Tekst |
|-------|--------|
| **App name** | Merge Meadow |
| **Subtitle** (App Store, 30 znakova max) | Run. Merge. Bloom. |
| **Developer name** | *(tvoj Play / Apple dev account)* |
| **Category** | Games → Casual |
| **Content rating** | Everyone / PEGI 3 *(nakon upitnika)* |
| **Privacy policy URL** | *(hostaj [[../05-technical/privacy-policy-draft\|privacy-policy-draft]] prije submita)* |

---

## Google Play

### Short description (max 80 znakova)

```
Run for seeds, merge them into crystal flowers, and grow your cozy meadow.
```

*(74 znaka — prijedlog Claude Designa)*

### Full description

```
Run. Merge. Bloom.

Merge Meadow is a cozy little loop: dash through the meadow with Pip, merge the seeds you bring home into crystal flowers, and watch your field come alive.

🏃 RUN
Swipe across three lanes, grab coins and seeds, and dodge logs and hay bales. Each level is a short, snappy run that fits a coffee break.

🌱 MERGE
Shake your seed bag into the Arena and drag two of a kind together. ★1 becomes ★2, ★2 becomes a glowing ★3 crystal flower. Chain merges for combos, and keep an eye on the hungry Muncher.

🌸 BLOOM
Every ★3 flower blooms on your home field. Fill the meadow, open chests along the level path, and unlock the next season.

✨ LOTS TO EXPLORE
• 7 meadows, from Country Bloom to Starfall Glade, each its own little world
• 140 levels with rewards along the way
• Endless runs in every season — beat your best
• A Bloom Album to fill and looks for Pip to unlock

💛 FAIR AND RELAXED
• No energy, no timers — play as long as you like
• No purchases: themes, looks and boosters are all earned with coins from playing
• Ads are optional (double loot or a second chance), plus an occasional short break ad

Download Merge Meadow — run today, bloom tomorrow.
```

### ASO keywords (ugraditi u opis + za App Store)

Primary: `merge game`, `casual runner`, `cozy game`, `flower merge`, `lane runner`  
Secondary: `cute bunny`, `pastel`, `garden`, `crystal flowers`

> Play više nema zasebno polje „promo text"; kratki opis + feature graphic nose hook.

---

## App Store Connect

### Subtitle (30 znakova max)

```
Run. Merge. Bloom.
```

*(18 znakova)*

### Promotional text (170 znakova, bez reviewa)

```
Dash for seeds, merge them into crystal flowers and grow your cozy meadow. 7 meadows, 140 levels and Endless runs. No energy, no timers.
```

### Description

Koristi isti **Full description** kao Google Play (gornji blok). App Store dopušta duži tekst; emoji su OK u opisu.

### Keywords (100 znakova max, comma-separated, bez razmaka nakon zareza)

```
merge,runner,casual,cozy,cute,bunny,pastel,flower,garden,crystal,bloom,lane,arcade
```

*(82 znaka)*

---

## Grafika (gotovo — Claude Design round 3, 2026-10-29)

| Play polje | Fajl | Napomena |
|---|---|---|
| App icon 512×512 | `marketing/store/app-icon-512.png` | ista ikona je u igri (launcher, adaptivna, mono) — `make_app_icons.gd` |
| Feature graphic 1024×500 | `marketing/store/feature-graphic.png` | svijetla (Country Bloom); tamna rezerva `feature-graphic-dark.png` |
| Phone screenshots (8) | `marketing/store/screenshots/01_…08_*.png` | 1080×1920, redoslijed = brojevi u imenu |
| Promo (nije Play polje) | `marketing/store/promo-1200x630.png` | testeri, GitHub stranica, privacy page |

Pregled svega: otvori `marketing/store/design/store_preview.html` u browseru.

---

## Kontakt i legal (store forma)

| Polje | Vrijednost |
|-------|------------|
| Support email | mergemeadow.support@gmail.com |
| Website | *(opcionalno — GitHub Pages ili landing)* |
| Ads | Yes (AdMob rewarded + optional interstitial) |
| In-app purchases | **No** (v1 samo s reklamama, 2026-10-26 — teme, Sir Pip i boosteri se kupuju coinima iz igre; kad se IAP vrati, ovaj red i blok „Fair free to play" se mijenjaju) |

---

## Prije submita (checklist)

- [ ] Privacy policy na javnom URL-u
- [x] 8 screenshot PNG (1080×1920) — `marketing/store/screenshots/` (2026-10-29)
- [x] Feature graphic 1024×500 — `marketing/store/feature-graphic.png` (2026-10-29)
- [x] App icon 512×512 — `marketing/store/app-icon-512.png` (2026-10-29)
- [ ] Developer name upisan (Play Console)
- [ ] Short + full description copy-paste iz ovog doca
- [ ] Content rating upitnik (Play + Apple)

## Povezano

- [[store-screenshots|store-screenshots]] — redoslijed i capture
- [[../01-vision/pitch|pitch]] — izvor hooka
- [[CHECKPOINT|CHECKPOINT]] — D4
