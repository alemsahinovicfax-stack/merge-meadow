---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, unlock, roster, plan, prompt]
povezano:
  - ideje-home-unlock
  - ideje-home-unlock-gesta
  - ideje-home-unlock-gate
  - ideje-home-unlock-roster
  - ideje-home-unlock-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-07 — UNLOCK-P0 → A select/next-lock → B gate → C roster."
---

# Plan promptovi — HOME-07 Unlock + roster

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **UNLOCK-P0 → A → B → C** — **sve ✅**  
> **Layout korekcija:** [[plan-prompts-home-incard|HOME-08 INCARD]] (roster/gate u prozoru).  
> **Cardfit korekcija:** [[plan-prompts-home-cardfit|HOME-09 CARDFIT]] (Amber off TEST_LOCK; naslov sredina; roster kontrast).  
> **Ideje:** [[../03-content/ideje-home-unlock|hub]] · [[../03-content/ideje-home-unlock-pitanja|pitanja]]

## Freeze

P81–P91 (select dolje; gore bounce; next-lock; lantern skip debug; inline Unlock; T3 progres; 48 stubova; T3+stars+ime; paid swipe roster; okvir; run seed_type_ids ostaju).

Ne dirati: band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager.

---

## Prompt — UNLOCK-P0 (Docs)

```
MODE: Plan only — ne implementiraj.
Projekt: Merge Meadow HOME-07 docs freeze.
Dokumentiraj P81–P91, 48 roster, next-lock vs further, lantern test.
Nema game/ u P0.
```

---

## Prompt — UNLOCK-A (Select + next-lock)

```
MODE: Plan only — ne implementiraj. Detaljan plan.

UNLOCK-A:
_on_vertical_swipe dy>0 = set_active(focus) ako playable, inače zadnji playable. Ne swap_home_band. dy<0 bounce.
is_free_selectable = playable ili next_locked (ne TEST_LOCK). cycle_free_strip smije next-lock bez set_active.
debug_unlock_all skip lantern + amber + ember. is_test_locked samo amber/ember.
Tap desno next-lock = cycle ne sheet. Further bounce.
Preview tap i dalje band swap.

Acceptance: swipe dolje na Bloom set_active; cycle na lantern radi; lantern nije playable nakon debug.
```

---

## Prompt — UNLOCK-B (Inline gate)

```
MODE: Plan only — ne implementiraj.

UNLOCK-B:
Kad hero-centar next-lock free: coins + T3 ProgressBar + Unlock gumb (disabled dok !can_unlock_free). Tap unlock_free.
Browser next-lock: close + Home fokus, ne sheet. Paid: nema gate. Unlock STOP; HIT-A ostaje.

Acceptance: Lantern centar pokazuje sivi Unlock; s 150c/8 T3 se pali i grant-a.
```

---

## Prompt — UNLOCK-C (Roster)

```
MODE: Plan only — ne implementiraj.

UNLOCK-C:
SeasonDef.roster 6 unosa po sezoni (48 unique). Panel dolje-lijevo: T3 draw_fitted_plant + stars + name, tamni okvir. Hash paleta. Prati hero centar. Paid locked swipe+roster. seed_type_ids ne dirati.
godot-run.ps1 jednom na kraju.

Acceptance: Bloom pokazuje Harvest Pumpkin ★★★; Coral unowned vidi Coral roster.
```
