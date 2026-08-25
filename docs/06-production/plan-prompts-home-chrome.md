---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, chrome, plan, prompt]
povezano:
  - ideje-home-chrome
  - ideje-home-chrome-layout
  - ideje-home-chrome-endless
  - ideje-home-chrome-gesta
  - ideje-home-chrome-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-03 — CHROME-P0 docs → A chrome+Hard → B center Browser → C strip slide."
---

# Plan promptovi — HOME-03 Home chrome

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **CHROME-P0 → A → B → C**  
> **Ideje:** [[../03-content/ideje-home-chrome|hub]] · [[../03-content/ideje-home-chrome-layout|layout]] · [[../03-content/ideje-home-chrome-endless|endless]] · [[../03-content/ideje-home-chrome-gesta|gesta]] · [[../03-content/ideje-home-chrome-pitanja|pitanja]]

**CHROME-P0–C** urađeni 2026-08-19. Track zatvoren — sljedeće D0-P / playtest.

## Freeze

| # | Odluka |
|---|--------|
| P16–P28, P30–P35 | Ostaju (free strip, hit-through, P19 L/R, …) |
| **P36** | Nema HomeTitle Merge Meadow; Pip ostaje |
| **P37** | Samo Play + Play Endless |
| **P38** | Endless uvijek Hard |
| P39 | Endless tema = `active_season_id` |
| **P40** | Browser samo srednja kartica |
| **P41** | Gap tap no-op |
| P42 | Snap-slide ~220ms, ne follow-finger u C v1 |
| P43 | PlayThemeBadge ostaje |
| P44 | Endless poslije tutoriala |

Ne dirati: Shop IAP, unique seeds, Play Console, wrap, paid na traci, Easy/Normal u `RunLevelLibrary` (samo UI).

---

## Prompt — CHROME-P0 (Docs) — urađeno

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow, HOME-03 chrome — docs freeze.

Dokumentiraj: dva gumba; bez Merge Meadow / Endless label / difficulty; Browser samo centar; Endless Hard + ista sezona; smooth strip slide.

Relevantno: ideje-home-chrome*.md, main_menu.tscn, season_stage.gd, CHECKPOINT, plan-prompts-home-chrome.md.

Nema game/ u P0.
```

---

## Prompt — CHROME-A (Chrome + Hard)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-03 chrome.

CHROME-A:
Home: ukloniti Merge Meadow title; ukloniti Endless label i Easy/Normal/Hard red. Ostaju Pip, traka, Play, Play Endless (isti min width). Endless visible tek tutorial_complete. Play Endless → begin_endless_run(HARD). Tema već active_season_id — ne drugi picker. PlayThemeBadge ostaje.

Relevantno: game/scenes/main_menu.tscn, main_menu.gd, game_state.begin_endless_run, ideje-home-chrome-layout.md, ideje-home-chrome-endless.md.

U planu:
- Scene + gd handleri; grep EasyButton / _on_easy_pressed / EndlessTitle
- Smoke/tools koji diraju difficulty UI
- Headless OpenGL; godot-run.ps1 jednom
- Ne dirati season_stage tap mapu (to je B) ni slide (C)
- Ne dirati Shop/IAP/HIT-A mouse_filter

Acceptance: Home ima dva CTA; nema difficulty red; Endless start Hard.
```

---

## Prompt — CHROME-B (Browser samo centar)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-03 gesta tap.

CHROME-B:
_handle_tap: Browser samo ako release u CenterSlot rect. L/R unlocked select; R locked sheet. Gap/pad = no-op (ne Browser). HIT-A IGNORE ostaje. Ne Button na slotovima.

Relevantno: season_stage.gd, ideje-home-chrome-gesta.md P40–P41.

U planu:
- Eksplicitni C hit-test (ne else Browser)
- season_home_smoke: ne assertati gap; locked sheet i dalje
- Headless + godot-run.ps1 jednom
- Ne slide tween (C)

Acceptance: tap sredine = Browser; tap praznine ništa; tap bok = fokus.
```

---

## Prompt — CHROME-C (Strip slide)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-03 smooth strip.

CHROME-C:
Vizualni horizontalni slide pri uspješnom cycle_free_strip (~220ms ease-out) preko holder Control (HBox ne sme pregaziti x). Na kraju refresh + x=0. Bounce na locked/rubu, ne wrap. Ne follow-finger. Zadrži Row IGNORE / Stage STOP (HIT-A).

Relevantno: season_stage.tscn/.gd, ideje-home-chrome-gesta.md P42.

U planu:
- Wrapper %StripMotion ili ekvivalent; tween pa commit
- Smoke await ~0.3s; hub page ne skoči
- Headless OpenGL; godot-run.ps1 jednom
- Ne dirati Shop, IAP, chrome A gumbe

Acceptance: swipe na kartici klizi, ne samo fade; struktura 3 slota ista.
```

---

## Redoslijed i DoD

1. CHROME-P0 docs — ✅ 2026-08-19  
2. A chrome + Hard — ✅ 2026-08-19  
3. B center-only Browser — ✅ 2026-08-19  
4. C snap-slide — ✅ 2026-08-19  

Nakon C: D0-P playtest. Nema CHROME-D u ovom tracku.

## Povezano

- [[../03-content/ideje-home-chrome|HOME-03 hub]]
- [[plan-prompts-home-polish|HOME-01]] · [[plan-prompts-home-hit-targets|HOME-02]] · [[plan-prompts-home-paid|HOME-04]]
- [[CHECKPOINT|CHECKPOINT]]
