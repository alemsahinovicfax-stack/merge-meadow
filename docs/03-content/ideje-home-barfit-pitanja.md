---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-barfit
  - plan-prompts-home-barfit
  - ideje-home-lockflow-pitanja
ai_sažetak: "HOME-11 pitanja P129–P136 — gate niže ispod 🔒+ime; bez wash okvira; debug 500c (+20 T3) za test Unlock; naslov CENTER ostaje."
---

# IDEJE — HOME-11 pitanja (P129–P136)

> [[ideje-home-barfit|hub]]. Freeze 2026-08-26.  
> P1–P128 ostaju. Override samo P115 **geometrije** (`anchor_top` 0.48 → niže) i gate `make_frame` (P122 wash ostaje na **rosteru**, ne na locked gateu).

P107 (naslov sredina), P116 (roster hidden), P117 (JSON 500/20), P118 (gold), P119 (Lantern+Amber nisu TEST_LOCK), P120 (sequential), P121–P123 (roster širina/wash/paid), P124 (Ember), P125 (ne dirati band/shop/ads), P126 (Seeds = T3), P127 (debug skip, ne brisati save) **ne dirati**.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P129** | Gdje su barovi sad? | **Niže.** `UnlockGate.anchor_top` ~**0.62** (raspon 0.58–0.70). Ispod bloka `🔒` + ime. Horizontala 0.12–0.88 ostaje. Override samo broj iz P115 (0.48), ne „donja polovica centrirano“ kao ideju. |
| **P130** | Okvir gate panela? | **Skinuti.** Nema `make_frame` wash+border na `UnlockGate`. Empty / alpha 0 + margin. ProgressBar i Unlock gumb ostaju. Roster frame ostaje. |
| **P131** | Ime i katanac? | Ostaju. `CenterTitle` full-rect H+V CENTER. Locked tekst i dalje `🔒\n{ime}`. **Ne** gurati naslov gore. **Ne** vaditi 🔒 u zaseban node u ovom sliceu. |
| **P132** | 500 coins po defaultu? | **Da, samo debug.** `wallet_coins = max(wallet, 500)` uz `debug_unlock_all` (isti `OS.is_debug_build()` + ne `skip_debug_season_unlock`). Persist save. **Ne** produkcijski start. **Ne** mijenjati JSON cost. |
| **P133** | I 20 T3, da gumb bude zlatan? | **Da, isti debug helper.** `can_unlock_free` je AND. Bez T3 playtest vidi pun Coins bar i sivi Unlock — to nije „testiram dugme“. Floor 20 clover (ili postojeći stash), ne brisati ostale kristale. Smoke i dalje sam seta 0/499/500. |
| **P134** | Što ne dirati? | JSON 500/20, gold variant, hide roster, TEST_LOCK Ember, debug skip lantern+amber, roster 0.85 / ellipsis / wash / midpoint, band 20/80, L/R mehanika, Shop, AdMob, SAVE_VERSION, `seed_type_ids`, 48 stubova, naslov sidro. |
| **P135** | Milestone? | **v1.1+**, nije launch blocker. |
| **P136** | Save / migracija? | **Ne** SAVE_VERSION. **Ne** slijepo brisati `user://player_save.json`. Grant samo diže floor; ne resetira bogatiji wallet. |

## Zašto ove odluke

### P129 — spusti gate, ne ime

P107 je playtest: ime u sredini. P115 je stavio gate na `0.48` misleći da je to „ispod imena“. Naslov je CENTER, pa 48% **jest** ime. Katanac je prvi red tog labela. Jedini potez koji ne krši P107: `anchor_top` dolje.

`grow_vertical` both/min.y može opet rasti gore — paziti u A.

### P130 — okvir je druga kartica na kartici

Wash na rosteru (P122) ostaje jer lista treba ploču. Locked poster **jest** kartica; barovi su sadržaj, ne HUD u prozoru. Border 1 px + 0.28 fill čini „naljepnicu“.

### P131 — 🔒 ostaje u title stringu

Nije ovaj slice za novi LockIcon node. Pokrivanje se rješava geometrijom gatea.

### P132 / P133 — debug fixture, ne ekonomija

„500 po defaultu“ = HP laptop playtest, `debug_unlock_all` već mijenja sezone. Wallet floor je isti duh. Produkcija 0 coins. Fair F2P.

T3 uz coins: inače zlatni gumb **ne postoji** u playtestu osim ako save slučajno ima 20 kristala.

### P134–P136 — freeze HOME-10

Ovaj slice je uzak. Svaki JSON/roster/TEST_LOCK diff je regressija A/B.

## Otvoreno (ne blokira BARFIT-A)

Agent **ne** mora pitati da krene. Ako treba izbor, koristi preporuku.

1. **Točan `anchor_top`.** Preporuka **0.62**. Ako ime još diraju barovi: 0.66. Ako je rupa ružna: 0.58. Nikad ≤ 0.55.
2. **Empty vs transparent Flat.** Preporuka `StyleBoxFlat` alpha 0, border 0, content margin 8 — PanelContainer layout ostaje.
3. **T3 tip.** Preporuka dodati u `garden_crystal_stash["clover"]` dok `t3_flower_count() >= 20`. Ne 20 različitih vrsta.
4. **Ime helpera.** `debug_grant_unlock_test_funds` ili slično. Debug-only early return.

## Nije otvoreno (namjerno)

- Produkcijski starting 500 coins.
- Smanjiti `coins_cost` u JSON da se lakše testira.
- Coin Unlock na paid / Ember.
- Naslov gore, gate desni kut, TEST_LOCK na Lantern/Amber.
- Vraćanje `make_frame` na gate „radi kontrasta“.
- SAVE_VERSION, brisanje savea, grant lantern/amber kroz `debug_unlock_all`.
- Roster chrome u istom kod promptu.

## Override mapa (brzi lookup)

| Staro | Novo |
|-------|------|
| P115 `anchor_top` 0.48 | P129 ~0.62, ispod 🔒+ime |
| Gate `make_frame` wash (P122 na gateu) | P130 frameless; P122 ostaje na rosteru |
| Debug boot samo `debug_unlock_all` | P132/P133 + floor 500c / 20 T3 |
| P107 naslov CENTER | ostaje |

## Povezano

- [[ideje-home-lockflow-pitanja|P115–P128]]
- [[ideje-home-cardfit-pitanja|P103–P114]]
- [[../06-production/plan-prompts-home-barfit|prompti]]
