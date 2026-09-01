---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, sezone, meadow, scratch]
povezano:
  - ideje-home-meadow
  - ideje-seed-pool-pitanja
  - plan-prompts-home-meadow
  - ideje-home-barfit-pitanja
ai_sažetak: "HOME-12 pitanja P137–P158 — sva playable polja; jedan apply_season shell; Play dual; Seasons; P141 Bloom-only povučen."
---

# IDEJE — HOME-12 pitanja (P137–P158)

> [[ideje-home-meadow|hub]]. Freeze **2026-09-01** + **override isti dan** (sva playable, jedan shell).  
> P1–P136 ostaju. Dual-band / UnlockGate / roster / Endless Hard kad meadow **nije** otvoren.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P137** | Kako u polje? | Tap na **središnji prozor** hero sezone **ili** gumb **Play**, ako je ta sezona **playable**. |
| **P138** | Play dual? | Karusel + playable fokus, meadow zatvoren → Play **otvara polje**. Meadow otvoren → Play = **campaign run**. |
| **P139** | Play Endless? | **Uvijek** endless Hard. Nema dual funkcije. |
| **P140** | Natrag? | Gumb **Seasons** (samo meadow) → karusel. Nije swipe L/R. |
| **P141** | Koja sezona? (staro) | **Povučen.** Zamjena **P153–P154**. |
| **P142** | Ostale sezone? (staro) | **Povučen.** Playable Frost/Lantern/paid owned **isti** shell. |
| **P143** | Locked / unowned? | **Ne** ulaze. UnlockGate / stari tap. Paid **owned** playable **da**. |
| **P144** | Chrome Home? | Header, footer, Daily gift, Basket, Play, Play Endless. Samo `SeasonStage` zona. |
| **P145** | Polje = igra? | **Ne.** `IGNORE`. Nije merge. |
| **P146** | Save? | `home_season_field_open` + `home_season_field_id` session-only. Nema `SAVE_VERSION`. Restart = karusel. |
| **P147** | Browser? | Playable hero-centar → **polje**, ne `open_browser` (HOME-03 override za **sve** playable). Browser ostaje locked/unowned + Shop. Nema Catalog gumba u meadowu. |
| **P148** | Swipe na polju? | Ne ciklus. Ne Back. Root `STOP`. |
| **P149** | Art reuse? | `pip_visual` / `camp_plant_draw`, ArenaPip IGNORE. Tint `apply_season(id)`. Ne `merge_arena_controller`. Ne `ArenaSeedChip` drag. |
| **P150** | Milestone? | **v1.1+**. |
| **P151** | Druge sezone kasnije? (staro) | **Povučen.** Sada u ovom tracku, data-driven. |
| **P152** | Što meadow **ne** dira? | Shop, AdMob, Unlock JSON 500/20, band 20/80 kad karusel, SAVE_VERSION, CAMP-01 spend, leftover/vacuum pravila, hub pager. JSON `seed_type_ids` = **SEED-A**, ne MEADOW-A. |
| **P153** | 8 scena ili jedan Control? | **Jedan** `SeasonField`. `apply_season(season_id)` restylira. Nema `frost_field.tscn`. |
| **P154** | `can_open`? | `is_season_playable(home_hero_center_id())`. |
| **P155** | Koji id je otvoren? | `home_season_field_id` = hero center u trenutku open. Ponovni open druge sezone prepisuje id + apply. |
| **P156** | Paid hero playable? | **Da**, isti shell. |
| **P157** | Cvijeće (B)? | Iz `seed_type_ids` **tog** field id-a (nakon SEED-A to su unique tipovi). 6–10, IGNORE. |
| **P158** | Ovisnost o SEED-01? | MEADOW-A **ne** čeka SeedCatalog (samo tint). MEADOW-B **nakon** SEED-A. |

## Zašto override

Bloom-only shell bi hardkodirao `country_bloom` u `can_open` i dimnu Frost. Jedan `apply_season` je isti ulaz za 8 sezona.

Locked i dalje poster (P143): polje je „uđi u svijet“, ne preview locka.

## Otvoreno (preporuka)

1. Flag imena: `home_season_field_open`, `home_season_field_id`.  
2. Seasons gumb: child fielda, gore, `UiClickButton`.  
3. Hero id: `home_hero_center_id()`, ne samo `active_season_id`.  
4. Field pastel ako `bg_modulate` = WHITE — lokalno na FieldGround, ne run tablica.  
5. B cvjetova: 6–10; ako pool ima 6 tipova, ponovi s T1/T2 mix.

## Nije otvoreno

- Osam tscn polja. Play s karusela = run za playable. Endless → meadow. Swipe = Back. Merge na polju. SAVE_VERSION. IAP na ulaz.

## Override mapa

| Staro | Novo |
|-------|------|
| P141 samo Bloom | P153–P154 sve playable, jedan shell |
| P142 Frost = Browser + run | Playable Frost = polje |
| P147 samo Bloom centar | P147 svi playable centri |
| P151 kasnije | Povučeno |
| Play → run | P138 dual |
| Center → Browser | P147 polje ako playable |

## Povezano

- [[ideje-home-barfit-pitanja|P129–P136]] · [[ideje-seed-pool-pitanja|SEED pitanja]]
- [[../06-production/plan-prompts-home-meadow|HOME-12 stub]] · [[ideje-home-meadow-chrome-pitanja|HOME-13 P159+]]
