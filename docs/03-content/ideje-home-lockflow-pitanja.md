---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, roster, unlock, sezone, scratch]
povezano:
  - ideje-home-lockflow
  - plan-prompts-home-lockflow
  - ideje-home-barfit
  - ideje-home-cardfit-pitanja
  - ideje-home-incard-pitanja
  - ideje-home-unlock-pitanja
ai_sažetak: "HOME-10 pitanja P115–P128 — locked-free poster (ime + 500/20 barovi + gold Unlock); roster skriven dok locked, širi desno bez ellipsisa; wash + midpoint; Lantern+Amber locked bez TEST_LOCK."
---

# IDEJE — HOME-10 pitanja (P115–P128)

> [[ideje-home-lockflow|hub]]. Freeze 2026-08-26.  
> P1–P114 ostaju osim overridea označenih dolje (P109 širina, P110 gate kut, P90/P108 alpha, HOME-08 roster+gate zajedno, JSON 80/5 · 150/8 · 220/12).

P81–P83, P85–P89, P91–P102, P103–P108, P111–P114 (select, bounce, next-lock cycle, inline gate, Seeds = T3, 48 stubova, paid bez coin Unlock, parent u kartici, L/R in-place, `seed_type_ids`, Amber off TEST_LOCK, naslov sredina, Ember paid lock, debug skip Lantern+Amber) **ne dirati** osim layouta/troška/wash navedenih ovdje.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P115** | Gdje su barovi i Unlock? | **Donja polovica** `CenterFill`, horizontalno **centrirano**, ispod imena. Override P110 (donji desni kut). Ime ostaje full-rect H+V CENTER (P107). Ne gurati naslov gore. |
| **P116** | Roster na locked kartici? | **Skriven** dok je hero next-lock i nije playable. Nakon `unlock_free` roster te sezone. Override HOME-08 „roster+gate zajedno na Lanternu“. |
| **P117** | Koliko coins / T3? | **500 coins + 20 bilo kojeg T3** za Frost, Lantern, Amber u `seasons.json`. Bloom 0. UI čita `def.coins_cost` / `def.t3_flowers_required`. Override 80/5, 150/8, 220/12. |
| **P118** | Unlock gumb? | Sivi / `subtle` / IGNORE dok `not can_unlock_free`. **Gold** + STOP kad može. Tamni ink na zlatu (Amber je jantar — `primary` breskva nije dovoljna). |
| **P119** | Lantern i Amber? | **Zaključane** (nisu u `unlocked_seasons`). **Nisu** TEST_LOCK. Selectable kad su next-lock. Ember ostaje paid TEST_LOCK (P124). |
| **P120** | Skače li lanac? | **Ne.** Isti chrome na svakoj next-lock free. `previous_free_id` ostaje. After Lantern unlock → Amber dobije isti poster. |
| **P121** | Roster širina i imena? | Širi **desno** (`anchor_right` ~0.78–0.88). Min ne smije pobijediti sidro i rasti lijevo. Puna imena, **bez** ellipsisa; autowrap 2 reda ako treba. Override P109 (0.42–0.50 / min 320 / ellipsis fallback). |
| **P122** | Boja panela / swipe glitch? | **Niska alpha wash** mooda (~0.20–0.35), ne opaque 0.88 + darkened 0.55. `apply_season` na morph **midpointu**. Override P108 samo za alpha/darken, ne za izvor palete. |
| **P123** | Paid roster? | Isti wash + širina + no-ellipsis. **Bez** Unlock gatea. |
| **P124** | Ember? | **Ostaje** paid TEST_LOCK / IAP. Nema coin Unlock. |
| **P125** | Što ne dirati? | Band 20/80, L/R in-place (osim midpoint `apply_season`), Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager, `seed_type_ids`, 48 stubova. |
| **P126** | Što su Seeds? | T3 garden count (`t3_flower_count`), P86/P98. Ne seed bag. |
| **P127** | Debug / postojeći save? | `debug_unlock_all` skipa Lantern **i** Amber (i Ember). A smije **debug/smoke strip** ta dva id-a iz `unlocked_seasons`. **Ne** brisati produkcijski save slijepo. **Ne** TEST_LOCK. |
| **P128** | Milestone? | **v1.1+**, nije launch blocker. |

## Zašto ove odluke

### P115 / P116 — poster, ne kut

Playtest: ime na sredini, ispod dva bara, Unlock na kraju. P110 (donji desni) i HOME-08 (roster lijevo + gate desno na **istoj** locked kartici) daju „naljepnice u kutovima“, ne locked sezonu. Ime ostaje geometrijski centar (P107); barovi zauzimaju donju polovicu da se ne preklapaju s naslovom kao jedan VBox koji gura ime gore.

Roster na locked kartici krade širinu i pažnju. Lista cvijeća je nagrada za Unlock.

### P117 — 500 / 20 fiksno za sada

Playtest: „za sada stavi fiksno.“ Ista mehanika za sve sljedeće free. Ne hardkodirati u UI — JSON da `can_unlock_free` i trake ostanu jedan izvor. Frost 500/20 vrijedi za novog igrača; playtest fixture (Bloom+Frost already playable) vidi 500/20 na Lanternu pa Amberu.

### P118 — zlato, ne breskva

`primary` je peach. Na Amber (`E8C48A`) i na svijetlim karticama „ispunjeno“ se ne čita kao spremno. Zlato + tamni tekst. Sivi dok barovi nisu puni — ne „ugaseno zlato“.

### P119 / P127 — locked ≠ TEST_LOCK

HOME-09: Amber TEST_LOCK = swipe bounce + gate hidden = „Unlock nije napravljen.“ Lantern i Amber moraju ostati **otključivi** next-lock kartice. Fixture: nisu u `unlocked_seasons`. Debug skip ostaje. Strip samo u debug/smoke, ne SAVE_VERSION migracija.

### P120 — sequential

„Isti princip prelazi na sljedeću“ ≠ otključaj koju hoćeš. Amber gate postoji kad je Lantern već playable.

### P121 — sidro, ne veći min na uskom sidru

CARDFIT-B min 320 + `anchor_right` 0.48 → overflow lijevo + clip. Playtest: raširi **desno**. Ellipsis nije fallback.

### P122 — wash, ne nova paleta

Glitch je timing (midpoint kartica vs end roster) **plus** opaque darkened frame. Transparentna wash čini lag manje vidljivim; midpoint `apply_season` ga gasi.

### P124 / P125 — Fair F2P i freeze

Ember IAP. Ne dirati band, shop, ads, save version, seed ids.

## Otvoreno (ne blokira LOCKFLOW-A/B)

Agent **ne** mora pitati da krene. Ako treba izbor, koristi preporuku.

1. **Gold hex.** Preporuka: fill ~`E8C44A` / `D4A017`, ink `1A1A14`, border outline @ 0.25. Hover lighten 0.06. Ne cream na zlatu.
2. **`FRAME_ALPHA`.** Preporuka **0.28**. Raspon 0.20–0.35. Ako imena nestanu na Bloomu, malo podigni darken (~0.15) prije nego vratiš 0.88.
3. **Autowrap vs još širi panel.** Prvo `anchor_right` ~0.85. Ako `Paper Lantern Bloom` i dalje ne staje na uskom windowu: 2-red wrap, ne ellipsis, ne font < 22.
4. **Grow.** `grow_horizontal` begin (0) ili end — **ne** both dok min može biti > sidro.
5. **Debug-strip API.** Preporuka: smoke/setup zove postojeći unlock list mutator; nema novi save key.

## Nije otvoreno (namjerno)

- Coin Unlock na paid / Ember.
- TEST_LOCK na Lantern ili Amber.
- Gate na L/R ili preview.
- Naslov gore da „oslobodi“ barove.
- Follow-finger, wrap strip, band 20/80, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager.
- Mijenjanje 48 imena / rarity / `seed_type_ids`.
- Slijepo brisanje `user://player_save.json`.
- Grant Lantern ili Amber kroz `debug_unlock_all`.

## Override mapa (brzi lookup)

| Staro | Novo |
|-------|------|
| P110 gate donji desni | P115 donja polovica, centrirano |
| HOME-08 roster+gate na locked | P116 roster hidden dok locked |
| JSON 80/5 · 150/8 · 220/12 | P117 **500 / 20** |
| Unlock `primary` (breskva) | P118 **gold** |
| P109 0.42–0.50 / min 320 / ellipsis fallback | P121 ~0.78–0.88, sidro ≥ min, **nema** ellipsis |
| P108 opaque darkened 0.88 | P122 wash 0.20–0.35 + midpoint apply |
| P84/P104 Amber off TEST_LOCK | ostaje; P119 Lantern+Amber **locked u saveu**, nisu TEST_LOCK |

## Povezano

- [[ideje-home-unlock-pitanja|P81–P91]]
- [[ideje-home-incard-pitanja|P92–P102]]
- [[ideje-home-cardfit-pitanja|P103–P114]]
- [[../06-production/plan-prompts-home-lockflow|prompti]]
