---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, store, screenshots, marketing]
povezano:
  - store-listing-en
  - CHECKPOINT
  - ../04-experience/art-direction
ai_sažetak: "8 screenshotova portrait 1080×1920 — redoslijed, caption overlay, capture preko emulatora ili Godot prozora."
---

# Store screenshots — plan i capture

> **Output folder:** `marketing/store/screenshots/`  
> **Format:** PNG, **1080×1920** (portrait, 9:16)

## Priprema savea (jednom)

```powershell
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path "game" --script "res://tools/setup_store_screenshot_state.gd"
```

Postavlja tutorial complete, kamp s cvijećem, magnet Lv2, run level 12 — spremno za lijep kadrove.

---

## Redoslijed (8 kadrova)

| # | Fajl | Scena | Što prikazati | Caption overlay (EN) |
|---|------|-------|---------------|----------------------|
| 1 | `01-run-lane.png` | Run | Pip u laneu, puno orbova, Lv u HUD-u | **Sprint & collect!** |
| 2 | `02-loot-double.png` | Loot (win) | Run complete + Double Loot gumb | **Double your loot** |
| 3 | `03-camp-merge.png` | Camp | Garden s T2 cvijećem, seed bag | **Merge at camp** |
| 4 | `04-main-menu.png` | Main menu | Play + Endless + Camp + Shop | **100 levels + Endless** |
| 5 | `05-shop.png` | Shop | Remove Ads + Starter Pack | **Fair F2P shop** |
| 6 | `06-endless.png` | Main menu | Endless Easy/Normal/Hard odabrano | **Endless challenge** |
| 7 | `07-magnet-upgrade.png` | Camp | Sprinkler / magnet upgrade UI | **Grow every run** |
| 8 | `08-collection.png` | Camp | Collection label + greenhouse | **Discover blooms** |

Caption overlay — opcionalno u **Figma** (font soft charcoal `#4A4A4A`, pastel pill pozadina). Store dopušta tekst na screenshotu.

---

## Capture — Android emulator (preporučeno)

1. Export debug APK → instaliraj na **Pixel_4** AVD
2. Pokreni igru, navigiraj na scenu iz tablice
3. Snimi:

```powershell
.\scripts\capture-store-screenshot.ps1 -Name "01-run-lane"
```

Skripta sprema u `marketing/store/screenshots/`. Ponovi za svaki kadar.

---

## Capture — Godot desktop prozor

1. `.\scripts\godot-run.ps1`
2. Prozor je 540×960 (viewport 1080×1920) — **F12** u Godotu ne radi u exportu; koristi:
   - **Windows:** Win+Shift+S → crop portrait
   - Ili emulator (bolja kvaliteta, točne dimenzije)

Za pixel-perfect 1080×1920: emulator ili Godot **Image grab** u budućem toolu.

---

## Minimalni set (4 screenshota)

Ako žuriš na internal test (D5), minimum za Play:

1. `01-run-lane.png` — hook
2. `03-camp-merge.png` — merge diferencijator
3. `04-main-menu.png` — scope (levels + endless)
4. `05-shop.png` — monetizacija transparentna

---

## Checklist

- [ ] `setup_store_screenshot_state.gd` pokrenut
- [ ] 4–8 PNG u `marketing/store/screenshots/`
- [ ] Nema dev teksta ("stub", "test") u kadru
- [ ] Copy u [[store-listing-en|store-listing-en]] copy-paste u konzolu

## Povezano

- [[store-listing-en|store-listing-en]]
- [[../05-technical/platforme|platforme]]
