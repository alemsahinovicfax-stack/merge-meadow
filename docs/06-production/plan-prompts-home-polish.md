---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, polish, plan, prompt]
povezano:
  - ideje-home-polish
  - ideje-home-polish-pitanja
  - ideje-home-polish-layout
  - ideje-home-polish-carousel
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-01 — P0 docs → A layout → B carousel → C polish."
---

# Plan promptovi — HOME-01 Home polish

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.  
> **Redoslijed:** **P0 → A → B → C**  
> **Ideje:** [[../03-content/ideje-home-polish|hub]] · [[../03-content/ideje-home-polish-pitanja|pitanja]] · [[../03-content/ideje-home-polish-layout|layout]] · [[../03-content/ideje-home-polish-carousel|carousel]]

**HOME-P0 (docs)** urađen 2026-08-19. Sljedeći kod-korak = **HOME-A**.

## Freeze defaulti

| # | Odluka |
|---|--------|
| P16 | Home swipe traka = **samo free** sezone; paid samo Browser/Shop |
| P17 | Ukinuti cijeli centrirani `Panel` na Homeu |
| P18 | Compact Pip+title iznad trake (default) |
| P19 | Tap centar = Browser; L / R unlocked = select; R locked = Unlock sheet (P11) |
| P20 | Nema wrapa na krajevima |
| P21 | Play badge kad `active` paid ≠ strip focus |
| P22 | Centar ~1.35× side; side peek |
| P23 | Snap ~180ms; locked swipe = bounce |
| P24 | Endless ispod Play |
| P11–P15 | SEZ freeze ostaje (sheet, auto-switch, EN names, art reskin) |

Fair F2P: traka ne prodaje snagu; paid nije na Home swipeu.

Ne dirati: unique S2 seed ID-evi, Play Console SKU, final thumbnail art (ColorRect/mood OK).

---

## Prompt — HOME-P0 (Docs freeze) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-01 Home polish — docs freeze.

HOME-P0:
Dokumentiraj ideju: ukinuti veliki Home Panel; srednja swipe traka samo po free sezonama (3 slota: prev unlocked | focus veći | next locked ili unlocked). Paid ostaje Browser/Shop.

Relevantno: ideje-home-polish*.md, ideje-sezone-ux-home.md, ideje-sezone-pitanja.md, CHECKPOINT.md, changelog.md, plan-prompts-home-polish.md.

Freeze:
- P16 free-only strip; paid active mismatch OK; swipe free postavlja active
- P17 kill cijeli Panel
- P18–P27 defaulti u pitanjima

U planu:
- Opširni scratch + pitanja + copy-paste prompti A–C
- CHECKPOINT sljedeci_korak → Plan mode HOME-A
- Acceptance: docs; Nema game/ code u P0
```

---

## Prompt — HOME-A (Ubiti Panel / flatten Home)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-01 layout.

HOME-A:
Ukinuti centrirani Panel u game/scenes/main_menu.tscn. Otvoreni Home: HomeTopStack (chest/basket) gore, compact header (P18), postojeći SeasonStage privremeno u sredini, Play + Endless dolje. Bez novog 640×720 okvira.

Relevantno: main_menu.tscn / main_menu.gd, meta hub SwipePager, ideje-home-polish-layout.md, safe_area_helper.

Default:
- P17 kill Panel; P18 compact Pip+title; P24 Endless ispod Play
- TutorialHint samo dok tutorial nije complete
- SeasonStage ostaje funkcionalan (SEZ-C) dok HOME-B ne zamijeni unutrašnjost
- block_hub_swipe i dalje SAMO na Stage, ne na cijelom Homeu
- Ne dirati Shop/Camp/IAP/season math

U planu:
- Scene reparent; node path update u main_menu.gd i smokes koji traže Panel/VBox
- Headless: meta_hub_flow_smoke i/ili season_home_smoke i dalje loada Home
- Acceptance: nema Panel chrome; Play radi; hub page swipe radi van Stagea
- Ne implementirati 3-slot carousel (to je HOME-B)
```

---

## Prompt — HOME-B (Free 3-slot carousel)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-01 carousel.

HOME-B:
Zamijeni Season Stage ActiveCard+Teaser linear 3-slot trakom samo za free sezone. Centar veći; lijevo previous unlocked pune boje; desno next locked (sivo+lock, P11 sheet) ili next unlocked (puna boja, manja). Unlock S2 → S2 u centar, S1 lijevo.

Relevantno: season_stage.tscn/.gd, game_state season API, SeasonCatalog.free_defs_sorted, season_home_smoke.gd, ideje-home-polish-carousel.md.

Default:
- P16 paid nikad na traci; strip_focus_id (save) odvojeno od active kad je active paid
- P12 unlock_free i dalje auto-switch active + strip_focus na tu free
- grant_paid_season NE mijenja strip_focus
- Swipe/tap free → set_active + strip_focus
- P20 no wrap; P22 ~1.35×; P23 ~180ms snap + bounce na locked
- P19: tap centar još može ostati Browser (ako C nije u istom PR-u, ostavi signal)
- Ne dirati IAP grant math, Shop rows, run spawn

U planu:
- Refactor season_stage layout + input; save migrate ako treba strip_focus_id
- Smoke: new game L hidden C S1 R locked S2; after S2 unlock L S1 C S2 R locked S3; paid grant ne stavlja Moonlit u centar
- Acceptance: free-only; previous not grey; hub swipe isolation
- Ne raditi P21 badge polish (HOME-C) osim ako trivial
```

---

## Prompt — HOME-C (Sync, badge, gesta polish)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-01 polish.

HOME-C:
Dovrši Home traku: tap centar = Browser; P21 Play badge kad active paid ≠ strip_focus; tween/bounce; provjeri P11 sheet vs Browser; season_home_smoke + po potrebi sitni hub smoke.

Relevantno: season_stage.gd, main_menu.gd Play label, season_browser.gd, ideje-home-polish-pitanja.md P19/P21/P23.

Default:
- Badge EN, samo mismatch, nije paywall copy
- Ne final art; ColorRect mood OK
- Ne unique seeds; ne Play Console

U planu:
- Badge + Browser tap + animacija ako B nije stigao
- Smoke: mismatch badge path (grant paid, strip ostaje S1, Play label sadrži theme name) opcionalno ako izvedivo headless
- Acceptance: Browser s centra; locked desno i dalje sheet; hub swipe OK
```

---

## Redoslijed i DoD

1. P0 docs — ✅ 2026-08-19  
2. A flatten Home — nema prozora  
3. B 3-slot free traka + smoke  
4. C badge + tap map + tween  

Nakon C: natrag na D0-P playtest; sezone art ostaje zaseban track.

## Povezano

- [[../03-content/ideje-home-polish|HOME-01 hub]]
- [[plan-prompts-sez-01|SEZ-01 prompti]] (P0–E zatvoreno; C Stage UX superseded)
- [[CHECKPOINT|CHECKPOINT]]
