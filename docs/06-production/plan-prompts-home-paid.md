---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, shop, paid, plan, prompt]
povezano:
  - ideje-home-paid
  - ideje-home-paid-shop
  - ideje-home-paid-layout
  - ideje-home-paid-gesta
  - ideje-home-paid-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-04 — PAID-P0 → A shop → B dual-band → C swap+izolacija (sve ✅)."
---

# Plan promptovi — HOME-04 Paid dual-band + shop packs

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **PAID-P0 → A → B → C**  
> **Ideje:** [[../03-content/ideje-home-paid|hub]] · [[../03-content/ideje-home-paid-shop|shop]] · [[../03-content/ideje-home-paid-layout|layout]] · [[../03-content/ideje-home-paid-gesta|gesta]] · [[../03-content/ideje-home-paid-pitanja|pitanja]]

**PAID-P0** urađen 2026-08-20 (docs). **PAID-A** urađen 2026-08-20 (Shop 2-col, bez Select). **PAID-B** urađen 2026-08-20 (dual-band layout). **PAID-C** urađen 2026-08-20 (swap tween + izolirani swipe).

## Freeze

| # | Odluka |
|---|--------|
| P1–P15, P17–P28, P30–P44 | Ostaju (free math, HIT-A, P40 hero, slide, Endless Hard, …) |
| **P16** | Override: paid **jesu** na Homeu, ali samo **PaidBand** gore. FreeBand i dalje samo free. |
| **P45** | Sve paid kartice; unowned sivo; tap preview unowned = swap u paid-fokus |
| **P46** | Browser ostaje; hero centar = Browser; preview centar = swap |
| **P47** | Shop owned = Owned, no-op (nema Select) |
| **P48** | Grant P12 active da; `home_band` ne skače u Shopu |
| **P49** | Persist `home_band` + `paid_strip_focus_id` |
| **P50** | Unowned paid centar: Play = zadnji playable + badge |
| **P51** | Paid order = `paid_defs()` array |
| **P52** | Band visina tween u **C** (~220–280ms) |
| **P53** | Browser paid ostaje horizontalni; shared kartica |
| **P54** | Nema inline IAP na Home hero u C v1 |
| **P55** | Preview traka statična (nema swipe cycle) |
| **P56** | Nema Shop → Home deep-link u A |
| **P57** | Nema reduce-motion / haptics u ovom tracku |
| **P58** | Nema novog tutorial koraka |
| **P59** | Home paid ostaje 3-slot prozor |

Ne dirati: unique S2 seed ID-evi, Play Console, AdMob, wrap, Easy/Normal u `RunLevelLibrary`, free coins/T3 gate, hub pager **stranice**.

---

## Prompt — PAID-P0 (Docs) — urađeno

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow, HOME-04 paid dual-band + shop packs — docs freeze.

Dokumentiraj: Shop 2-col Browser-like kartice bez Select; Home PaidBand top / FreeBand bottom; 20/80 uz min visine; preview statičan; tap samo okvir sezone za swap; hero swipe izoliran; Browser ostaje na hero centru; P45 sve paid (unowned sivo); P16 override samo zasebna paid traka.

Relevantno: ideje-home-paid*.md, shop_screen.gd, season_browser.gd, season_stage.gd, CHECKPOINT, plan-prompts-home-paid.md.

Nema game/ u P0.
```

---

## Prompt — PAID-A (Shop packs) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-04 shop Season packs.

PAID-A:
U shopu ukloniti Select theme / Selected i set_active_season s owned pack tap-a. Kartice vizualno kao Season Browser paid prozori (~168×120, ime + cijena ili Owned), ne full-width 72px gumbi. Layout GridContainer 2 stupca; treći pack wrapa u novi red. Unowned tap = IAP purchase. Owned tap = no-op, label Owned. Hint Cosmetic themes ostaje. P12 grant na uspješnu kupnju i dalje smije postaviti active_season_id — to nije shop Select. Shared widget s Browserom (Browser owned tap i dalje select+close). home_band ne dirati iz Shopa.

Relevantno: game/scripts/ui/shop_screen.gd, game/scenes/ui/shop_screen.tscn, season_browser.gd, monetization_config.gd, ideje-home-paid-shop.md, P47 P48 P53 P56.

U planu:
- Zamjena SeasonPacksList VBox → 2-col grid; factory/shared card
- Grep Select theme / _on_season_pack_pressed set_active
- season_iap_smoke + shop smoke: owned drugi tap ne prepisuje active; 2 kartice u retku
- Headless OpenGL; godot-run.ps1 jednom na kraju
- Ne dirati SeasonStage dual-band (to je B/C)
- Ne dirati free unlock math, remove-ads, boosters osim typography ako grid treba

Acceptance: Shop pokazuje 2 pack prozora u retku; owned nema Select; kupnja i restore i dalje grantaju.
```

---

## Prompt — PAID-B (Dual-band layout) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-04 Home dual-band layout.

PAID-B:
SeasonStage split: PaidBand uvijek gore, FreeBand uvijek dolje. Default home_band=free: paid preview ~20% (min ~100–140px), free hero ~80% (min ~280–340px) — 20/80 je omjer Stagea uz min visine, ne 60px od starog stripa. Obje trake 3-slot (isti algoritam kao free; paid prozor nad paid_defs; 2 paid = [—][A★][B]). P45: crtaj sve paid, unowned sivo+lock/cijena, unowned smije biti centar. Free traka i dalje samo free (P16 override nije jedan karusel). Save: home_band + paid_strip_focus_id (P49); new game free+S1. Pip/Play/Endless van Stagea. HIT-A IGNORE na djece obje Row. B smije instant visine (tween je C). Smiješ već povezati instant swap na tap preview okvira da se oba stanja vide.

Relevantno: season_stage.tscn/.gd, game_state.gd save, ideje-home-paid-layout.md, ideje-home-polish-carousel.md.

U planu:
- Node PaidBand/FreeBand; stretch ratio; clamp visina
- GameState paid_strip_focus_id + home_band migrate
- season_home_smoke: new game paid visible, free centar S1; grant paid ne mijenja free centar ni home_band
- Headless OpenGL; godot-run.ps1 jednom
- Ne hero swipe izolacija / visina tween kao gotov C (ako instant swap postoji, C ga zamijeni tweenom)
- Ne Shop grid (A)

Acceptance: Home pokazuje mini paid gore i veliki free dolje; sve paid kartice; Play/Pip nisu u traci.
```

---

## Prompt — PAID-C (Swap + izolirani swipe) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-04 gesta dual-band.

PAID-C:
Preview traka statična (P55): nema cycle. Tap SAMO na okvir sezone u preview → band swap (paid ostaje top, free bottom; samo visine 20↔80, tween ~220–280ms P52). Hero traka: postojeći CHROME-C slide + bounce, izolirano — swipe free ne pomiče paid i obrnuto. Hero centar tap = Browser (P40/P46). Preview centar tap = swap, NE Browser. Gap no-op obje trake (P41). Locked free u preview: swap u free-hero + Unlock sheet, locked nije centar. Unowned paid preview: swap, ta kartica hero centar, bez set_active (P50). HIT-A IGNORE ostaje. block_hub_swipe na Stage root. Tijekom band tweena lock input. P54: nema inline IAP na Home.

Relevantno: season_stage.gd, ideje-home-paid-gesta.md, P45–P46 P52 P54 P55.

U planu:
- press_band state; odvojeni cycle_free / cycle_paid
- Hit-test po traci; eksplicitni hero C vs preview C
- Smoke: cycle_free ne mijenja paid_strip_focus_id; API swap_home_band; Browser nije na preview; await tween ~0.3s; hub page ne skoči
- Headless OpenGL; godot-run.ps1 jednom
- Ne dirati Shop A, unique seeds, follow-finger

Acceptance: swipe na donjem hero ne miče gornji preview; tap paid okvira gore prebacuje paid u 80%; tap free okvira dolje vraća default; Browser samo s hero centra.
```

---

## Redoslijed i DoD

1. PAID-P0 docs — ✅ 2026-08-20  
2. A Shop 2-col + bez Select — ✅ 2026-08-20  
3. B Dual-band layout + save — ✅ 2026-08-20  
4. C Tap-swap + izolirani swipe + visina tween — ✅ 2026-08-20  

Nakon C: playtest dual-band. Nema PAID-D u ovom tracku (follow-finger, Browser 2-col, inline IAP, Shop deep-link).

## Povezano

- [[../03-content/ideje-home-paid|HOME-04 hub]]
- [[plan-prompts-home-chrome|HOME-03]] · [[plan-prompts-home-polish|HOME-01]] · [[plan-prompts-sez-01|SEZ-01]]
- [[CHECKPOINT|CHECKPOINT]]
