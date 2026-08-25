---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, hit-targets, plan, prompt]
povezano:
  - ideje-home-hit-targets
  - ideje-home-hit-targets-gesta
  - ideje-home-hit-targets-tehnika
  - ideje-home-hit-targets-pitanja
  - ideje-home-polish
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-02 — HIT-P0 docs → HIT-A mouse_filter hit-through."
---

# Plan promptovi — HOME-02 hit targets

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.  
> **Redoslijed:** **HIT-P0 → HIT-A**  
> **Ideje:** [[../03-content/ideje-home-hit-targets|hub]] · [[../03-content/ideje-home-hit-targets-gesta|gesta]] · [[../03-content/ideje-home-hit-targets-tehnika|tehnika]] · [[../03-content/ideje-home-hit-targets-pitanja|pitanja]]

**HIT-P0** urađen 2026-08-19. **HIT-A** urađen 2026-08-19. Track zatvoren — sljedeće D0-P / playtest.

## Freeze defaulti

| # | Odluka |
|---|--------|
| P16–P27 | HOME-01 ostaje (free-only strip, P19 semantika, no wrap, badge, …) |
| **P28** | Hit-through: kartice nisu barijera (`IGNORE` na `Row` stablu) |
| P29 | Gap tap = Browser |
| P30 | `SWIPE_LOCK_PX` 20 |
| P31 | Locked desno tap = Unlock sheet (P11) |
| P32 | `_ignore_hits` samo `Row`; Browser/sheet STOP |
| P33 | Swipe na lock = bounce/cycle, ne sheet |
| P34 | Centar tap = postojeći Season Browser (free + paid dolje) |
| P35 | Tap unlocked bok = `set_active` + strip fokus |

Fair F2P: samo gesta. Paid i dalje nisu Home slotovi.

Ne dirati: unique S2 seed ID-evi, Play Console SKU, Shop IAP redovi, final art, `debug_unlock_all_seasons`.

---

## Prompt — HIT-P0 (Docs freeze) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-02 Home hit targets — docs freeze.

HIT-P0:
Dokumentiraj ideju: paneli sezona na Homeu gutaju swipe/tap; traka mora biti klikabilna i swipeable preko kartica. Tap centar = postojeći Browser (paid dolje). Tap bok unlocked = ta sezona trenutna. Semantika P19 ostaje; uzrok je mouse_filter STOP.

Relevantno: ideje-home-hit-targets*.md, ideje-home-polish*.md, season_stage.tscn/.gd, CHECKPOINT.md, changelog.md, plan-prompts-home-hit-targets.md.

Freeze:
- P28 hit-through
- P29–P35 defaulti u pitanjima
- Nema game/ code u P0

U planu:
- Opširni scratch + pitanja + copy-paste HIT-A
- CHECKPOINT sljedeci_korak → Plan mode HIT-A
```

---

## Prompt — HIT-A (Hit-through kod)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-02 hit targets.

HIT-A:
Season Stage kartice (Left/Center/Right + naslovi + Row) ne smiju gutati input. Cijela traka: swipe cycle (P16/P20/P23) i tap mapa P19/P28–P35. Uzrok: mouse_filter STOP na PanelContainerima; Stage gui_input nikad ne vidi prst na kartici.

Relevantno: game/scripts/ui/season_stage.gd, game/scenes/ui/season_stage.tscn, season_home_smoke.gd, ideje-home-hit-targets-tehnika.md, ideje-home-hit-targets-gesta.md, ideje-home-hit-targets-pitanja.md.

Default:
- Stage ostaje MOUSE_FILTER_STOP + postojeći _on_stage_gui_input
- _ignore_hits(row) rekurzivno IGNORE na Control djeci Row; NE na SeasonBrowser / SeasonUnlockSheet
- Ne mijenjati _handle_tap / cycle_free_strip semantiku osim ako hit-test pukne
- Ne Button na slotovima
- Ne dirati Shop, IAP, unique seeds, debug unlock, Play badge logiku
- P31 locked R tap = sheet; P33 swipe na lock ≠ sheet
- P34 postojeći Browser, ne novi dropdown

U planu:
- _ready ignore + opcionalno tscn mouse_filter = 2
- Smoke: postojeći season_home_smoke + assert slot/Row IGNORE i Stage STOP
- Headless OpenGL; na kraju .\scripts\godot-run.ps1 jednom
- CHECKPOINT HIT-A ✅; changelog; sljedeci_korak natrag D0-P playtest
- Ako potrošiš vrijeme na isti bug: greske-katalog unos

Acceptance:
- Swipe počinje na srednjoj i bočnim karticama
- Tap centar = Browser (paid dolje)
- Tap unlocked bok = ta sezona current
- Hub swipe izvan Stagea radi; na Stageu block_hub_swipe
```

---

## Redoslijed i DoD

1. HIT-P0 docs — ✅ 2026-08-19  
2. HIT-A IGNORE na Row + smoke assert — ✅ 2026-08-19  

Nakon A: **HOME-03** chrome ([[plan-prompts-home-chrome|plan-prompts-home-chrome]]). Nema HIT-B.

## Povezano

- [[../03-content/ideje-home-hit-targets|HOME-02 hub]]
- [[plan-prompts-home-polish|HOME-01 prompti]] (P0–C zatvoreno; hit je ovaj track)
- [[plan-prompts-home-chrome|HOME-03 chrome]]
- [[CHECKPOINT|CHECKPOINT]]
