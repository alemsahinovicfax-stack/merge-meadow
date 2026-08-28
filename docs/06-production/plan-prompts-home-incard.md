---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, roster, unlock, plan, prompt]
povezano:
  - ideje-home-incard
  - ideje-home-incard-roster
  - ideje-home-incard-gate
  - ideje-home-incard-pitanja
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-08 — INCARD-P0 docs → A roster u prozoru → B gate u prozoru."
---

# Plan promptovi — HOME-08 in-card roster + Unlock

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **INCARD-P0 → A → B** — **sve ✅**  
> **Chrome korekcija:** [[plan-prompts-home-cardfit|HOME-09 CARDFIT]] ✅ · [[plan-prompts-home-lockflow|HOME-10 LOCKFLOW]].  
> **Ideje:** [[../03-content/ideje-home-incard|hub]] · [[../03-content/ideje-home-incard-pitanja|pitanja]]

## Freeze

P92–P102 (roster child hero-centar slota, donje-lijevo; L/R i preview bez; veći tip; paid roster bez coin Unlock; gate dolje-desno na next-lock free; Unlock sivo→primary; Seeds = T3 count; Lantern P84 + vizual na prozoru; naslov gore; in-place L/R; `seed_type_ids` ostaju).

P81–P91 ostaju (select, bounce, next-lock, lantern debug skip, 48 stubova).

Ne dirati: band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager.

---

## Prompt — INCARD-P0 (Docs)

```
MODE: Plan only — ne implementiraj.
Projekt: Merge Meadow HOME-08 docs freeze.
Dokumentiraj P92–P102: roster i Unlock u hero-centar prozoru sezone (ne Stage overlay), veći tip, paid+free roster, Lantern gate na kartici.
Nema game/ u P0.
```

---

## Prompt — INCARD-A (Roster u prozoru)

```
MODE: Plan only — ne implementiraj. Detaljan plan.

INCARD-A:
Makni Stage-level SeasonRoster overlay iz season_stage.tscn.
Stavi roster panel kao child %CenterSlot (free-hero) i %PaidCenterSlot (paid-hero), sidro donji lijevi kut tog panela, clip_contents, mouse_filter IGNORE.
Povećaj: ikona ~52px, ime font ~22, zvijezde ~18, red ~56px. Tamni okvir ostaje.
apply_season(home_hero_center_id()). L/R side i preview 20% bez rostera.
Naslov sezone ostaje gore. 48 stubova i seed_type_ids ne dirati.

Acceptance: Bloom hero — Harvest Pumpkin ★★★ čitljiv UNUTAR zelene kartice, ne na dnu Stagea. Coral paid-hero — Reef Crown u koraljnom prozoru.
```

---

## Prompt — INCARD-B (Gate u prozoru)

```
MODE: Plan only — ne implementiraj.

INCARD-B:
Makni Stage-level UnlockGate overlay. Gate child %CenterSlot, donji desni kut, samo kad je free-hero i centar = next_locked_free_id() (Lantern) i nije TEST_LOCK.
Coins + Seeds (t3_flower_count) progress. Unlock: sivo/disabled/IGNORE dok !can_unlock_free; primary/STOP kad može; tap unlock_free.
Paid: nema gate. debug_unlock_all i dalje skip lantern. HIT-A ostaje.
Smokes: gate je dijete center slota; sivi Unlock na Lantern; 150c/8 T3 pali i grant-a; Coral bez gatea.
godot-run.ps1 jednom na kraju.

Acceptance: Lantern centar pokazuje trake i Unlock U ljubičastom prozoru; s resursima gumb postane ispunjen i klikabilan.
```
