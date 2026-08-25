---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, pitanja, chrome, scratch]
povezano:
  - ideje-home-chrome
  - ideje-home-chrome-layout
  - ideje-home-chrome-endless
  - ideje-home-chrome-gesta
  - ideje-home-polish-pitanja
  - plan-prompts-home-chrome
ai_sažetak: "HOME-03 pitanja — P36–P41 freeze chat 2026-08-19; P42–P44 defaulti za CHROME-C."
---

# IDEJE — HOME-03 pitanja

> [[ideje-home-chrome|HOME-03 hub]]. SEZ P1–P15, HOME P16–P28/P30–P35 ostaju osim overridea navedenih dolje.

## Kako koristiti

1. Pregledaj P36–P44. Override **prije** CHROME-A/B/C.
2. Kod: prompti **A → B → C** u [[../06-production/plan-prompts-home-chrome|plan-prompts-home-chrome]].
3. Ne re-otvaraj P16 (paid na traci) ni P28 (hit-through).

---

## P36 — Wordmark „Merge Meadow“

**Pitanje:** Pip + naslov, ili samo Pip?

**Odgovor (2026-08-19):** **Sakriti/ukloniti** `%HomeTitle`. **Pip ostaje.** Override P18 compact header.

---

## P37 — Endless chrome

**Pitanje:** Label „Endless“ i Easy/Normal/Hard red?

**Odgovor (2026-08-19):** **Obrisati.** Home ima **dva gumba:** Play i Play Endless. Endless ispod Play (P24 pozicija ostaje).

---

## P38 — Teškoća Endless

**Pitanje:** Igrač bira Easy/Normal/Hard?

**Odgovor (2026-08-19):** **Uvijek Hard.** UI picker nestaje. `begin_endless_run(HARD)`. Enum u `RunLevelLibrary` ostaje za alate.

---

## P39 — Endless vs sezona

**Pitanje:** Endless koristi strip fokus, active, ili zaseban ID?

**Default (preporuka, usklađeno s Play):** **`active_season_id`**. Spawn + BG već to rade. Nema drugog endless season pickera. Ako je active paid, Endless je ta paid tema (P21 badge i dalje objašnjava mismatch sa stripom).

---

## P40 — Tko otvara Browser

**Pitanje:** Gap, cijeli Stage, ili samo srednja kartica?

**Odgovor (2026-08-19):** **Samo okvir trenutne (srednje) sezone.** Postojeći Season Browser overlay (P34). Ne inline lista.

---

## P41 — Tap u praznini trake

**Pitanje:** Browser ili ništa?

**Odgovor (2026-08-19):** **No-op.** Override P29. Hub pager se ne pali (Stage i dalje block_hub_swipe na drag; kratki tap na gap ne otvara Browser niti mijenja page).

---

## P42 — Smooth swipe

**Pitanje:** Follow-finger, samo snap-slide, ili ostati fade?

**Default:** **Snap-slide 200–280ms** (cilj 220) na holder `position.x`, zatim refresh. **Ne** live follow u CHROME-C v1. Fade-only = nedovoljno.

---

## P43 — PlayThemeBadge

**Pitanje:** Skupa s „samo dva gumba“ maknuti badge?

**Default:** **Ostaje.** Nije treći CTA; samo mismatch copy. Tap i dalje no-op.

---

## P44 — Endless prije kraja tutoriala

**Pitanje:** Pokazati Play Endless odmah?

**Default:** **Ne.** `visible` tek kad `tutorial_complete` (kao danas EndlessSection).

---

## Sažetak

| # | Odluka | Freeze? |
|---|--------|---------|
| P36 | Bez Merge Meadow; Pip da | **Da** |
| P37 | Dva gumba; bez Endless label + difficulty | **Da** |
| P38 | Endless uvijek Hard | **Da** |
| P39 | Tema = `active_season_id` | Preporuka |
| P40 | Browser samo C kartica | **Da** |
| P41 | Gap tap no-op | **Da** |
| P42 | Snap-slide ~220ms, ne follow | Preporuka |
| P43 | Badge ostaje | Preporuka |
| P44 | Endless poslije tutoriala | Preporuka |

---

## Ne otvaramo ovdje

Wrap, IAP cijena, unique S2 seedovi, reduce-motion Settings, brisanje Easy iz library. Paid na Homeu (zaseban band) = [[ideje-home-paid|HOME-04]], ne isti swipe kao free.

## Povezano

- [[ideje-home-polish-pitanja|P16–P27]] · [[ideje-home-hit-targets-pitanja|P28–P35]] · [[ideje-home-paid-pitanja|P45–P59]]
- [[../06-production/plan-prompts-home-chrome|CHROME prompti]]
