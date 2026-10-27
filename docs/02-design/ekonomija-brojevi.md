---
type: dizajn
status: aktivan
milestone: M7
tags: [dizajn, ekonomija, balans, brojevi, source-of-truth]
povezano:
  - ekonomija
  - spec-vertical-slice
  - mehanike/_archive/merge-kamp
  - CHECKPOINT
ai_sažetak: "Sve balans-konstante na jednom mjestu (run, loot, kamp, nadogradnje, cijene) + gdje su u kodu. Balans ciklus 1 (2026-10-21): leveli 1–20 u levels.json, sjeme po rijetkosti, Endless rampa, nove cijene."
---

# Ekonomija — brojevi (live tablica)

## Sažetak

Konkretne konstante za feel i balans. [[ekonomija|ekonomija]] = *zašto*; ovaj doc = *koliko* + **gdje u kodu**.

> Greybox draft — mijenja se nakon playtesta.

## Run (`scripts/run/run_controller.gd` + `data/run_levels/levels.json`)

> **Balans ciklus 1 (2026-10-21):** leveli 1–20 i Endless su u `levels.json` (tabela i zašto: [[balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]], [[../03-content/nivoi/_index|nivoi]]). Konstante ispod važe samo za tutorial runove.

| Konstanta | Vrijednost | Značenje |
|-----------|-----------|----------|
| Level 1 → 20 (ciklus 1b) | 60 → 120 s · start 432 → 550 px/s · ubrzanje 2,4 → 3,9 % / 15 s · udio prepreka 10,8 → 37,4 % · parovi 4 → 40 % (od L1) · sjeme 28 → 34 % — težina = stari level N+5 | `levels.json` → `RunLevelLibrary.get_level` |
| Tok prepreka | redova / min = 60 / spawn_interval × spawn_chance × obstacle_chance × **3** (`obstacle_rate_mult`); razmak ≥ 300 px; L1 ≈ 9, L10 ≈ 27, L20 ≈ 80 prepreka / min | `run_controller._update_obstacle_stream` |
| Endless | stepenica svakih 20 s (`ENDLESS_TIER_SEC`), težina 60 s ispred sata (`difficulty_offset_sec`), ključevi 0 / 1 / 2 / 3 / 5 / 8 min, poslije +4 % brzine po stepenici; prepreke i parovi ≤ 45 %; prepreke 3× | `levels.json` → `get_endless_config_at` |
| `BASE_SCROLL_SPEED` | `400.0` px/s | ×`scroll_speed_mult` levela |
| `RAMP_STEP` | `0.05` | samo tutorial; level / Endless nose `speed_ramp` |
| `RAMP_EVERY` | `15.0` s | `RunBalance.RAMP_EVERY` |
| `SPAWN_INTERVAL` / `SPAWN_CHANCE` / `OBSTACLE_CHANCE` / `PICKUP_SEED_CHANCE` | `1.2` / `0.7` / `0.25` / `0.30` | samo tutorial runovi |

### Sjeme po rijetkosti (`scripts/run/run_balance.gd`)

| Pravilo | Vrijednost |
|---------|-----------|
| Izbor tipa | težinski: ★1 = 1, ★2 = `rare2_mult`, ★3 = `rare3_mult` (iz levela / Endless stepenice) |
| Level 1 → 20 | ★2 0,40 → 0,60 · ★3 **0,30 → 0,59** (2026-10-27 ×2 na zahtjev, ali najviše ★2 − 0,01; ciklus 1b 0,15 → 0,375; ciklus 1 0,12 → 0,30) → ★3 = **7,3 → 12,3 %** sjemena (sezona s 3 ★1, 2 ★2, 1 ★3) |
| Endless | ★3 0,376 (0 min) → 0,69 (8 min) — uvijek rjeđi od ★2 → ★3 8,8 → 13,6 % sjemena |
| ★3 ×2 i ★2 | svaki ★3 tip uvijek rjeđi od svakog ★2 tipa: L1–7 puni ×2, od levela 8 i u Endlessu od 1 min ★3 = ★2 − 0,01 (npr. L20 0,59 umjesto 0,75) |
| Van runa (Loot Burst bez cilja, dnevni poklon) i tutorijal runovi | `BASE_RARE2` 0,40 · `BASE_RARE3` **0,24** (bilo 0,12) |
| Čuva | `economy_balance_smoke`: težina ★1 > ★2 > ★3 po tipu u svakom levelu i Endless koraku, ★3 ≤ 13 % u levelima, L1 ★3 ≥ 6 % |

## Loot (`game_state.gd → finish_run`)

| Pravilo | Formula |
|---------|---------|
| Finish | 100% sjemena + novčića |
| Fail | `ceil(50%)` oba (novčići + sjeme) — **ne u Endlessu** (`ENDLESS_KEEPS_FULL_LOOT`): pad / izlazak čuva sve |
| Double | ×2 **samo loot trenutnog runa** (`last_*`); wallet + bonus jednom za ovaj run |
| Revive | nastavi run, ne dira loot |
| To Camp | sjemena → `seed_bag`; novčići već u `wallet_coins` pri `finish_run` |
| **Fail vs finish UI** | crvena/zelena traka + naslov; status `X → Y` na failu (50%) |

## Novčići (`wallet_coins`)

| Pravilo | Vrijednost / napomena |
|---------|----------------------|
| Izvor: run pickup | ~70% spawnova (balans **niski prioritet** do shopa) |
| Izvor: exchange | Seed: ★1=`1` / ★2=`2` / ★3=`4` C po sjemeniu × take (1–3); Flower/crystal: ★1=`5` / ★2=`10` / ★3=`20` po komadu |
| Izvor: rewarded ×2 | ×2 `last_run_coins` / `last_seed_bag` (samo ovaj run) |
| Sink v1 | **samo kozmetika** (shop M8) — ne magnet, ne loadout |
| Magnet upgrade | **T2 bloom donate** — novčići ne utječu na snagu |
| Wallet u kampu | ✅ label `Wallet: X coins` |
| Set bonus coins | **v1.1+** (Meadow Starter +5%) |
| Debug playtest | `DEBUG_DEV_RESOURCES` → **20 coins + 20 Clover** na boot / ulaz u kamp |
| Loadout (F5) | 1 slot, `LOADOUT_SPAWN_BONUS` **+5%** šanse za sjeme u runu |

### Shop cijene (balans ciklus 1, 2026-10-21)

| Item | Cijena (coins) | Ranije |
|------|----------------|--------|
| Golden Album | 800 | 120 |
| Sunset Meadow | 1000 | 150 |
| Lavender Meadow | 1200 | 180 |
| Pip Sky | 2000 | 200 |
| Pip Blossom | 2500 | 250 |

### Sezone (`data/seasons/seasons.json`)

| Sezona | Coini | ★3 prethodne sezone | Ranije |
|--------|-------|---------------------|--------|
| Frost Orchard | 2500 | 22 Harvest Pumpkin | 500 + 20 |
| Lantern Meadow | 4500 | 26 Crystal Peony | 500 + 20 |
| Amber Canopy | 6500 | 30 Midnight Lotus | 500 + 20 |

### Coin cijene bez kupovina (v1, 2026-10-26)

v1 izlazi samo s reklamama (`MonetizationConfig.IAP_ENABLED = false`): stvari koje su se prodavale pravim novcem kupuju se coinima kroz isti grant (`coin_price` u `IAP_PRODUCTS`, `IAPManager.buy_with_coins`). Simulacija: [[coin-ponude-simulacija|coin-ponude-simulacija]] (`game/scripts/dev/coin_offer_sim.gd`, model igrača iz `economy_sim.gd`, 10 putovanja po profilu, 25 min igre = 1 dan).

| Stvar | SKU | Coini | € s IAP-om | Ponašanje |
|-------|-----|-------|------------|-----------|
| Merge Hint | `booster_merge_hint` | **1500** | €0.99 | trajno |
| Loot Burst | `booster_loot_burst` | **1000** (početni prijedlog 500) | €0.99 | više puta, +5 ★3 sezone koja otključava sljedeću besplatnu; bez cilja se ne nudi |
| Moonlit Warren | `season_pack_moonlit_warren` | **10000** (do 2026-10-27: 3000) | €2.99 | trajno |
| Coral Tide Garden | `season_pack_coral_tide` | **10000** (do 2026-10-27: 3500) | €3.49 | trajno |
| Starfall Glade | `season_pack_starfall_glade` | **10000** (do 2026-10-27: 3000) | €2.99 | trajno |
| Ember Fen | `season_pack_ember_fen` | **10000** (do 2026-10-27: 3500) | €3.49 | ne nudi se dok sezona nije u igri (test-zaključana) |
| Sir Pip | `pip_knight` | **3000** | €3.99 | trajno |
| Remove Ads · Starter Pack | `remove_ads` · `starter_pack` | — (0) | €3.99 · €1.99 | ne nude se (reklame su jedina zarada; paket daje coine i ima tajmer) |

**Simulacija (medijan dana, u zagradi runova; drugi krug 2026-10-27 — teme 10000, ★3 ×2 uz ★3 tip rjeđi od ★2 tipa):**

| | casual | average | skilled |
|---|---|---|---|
| Merge Hint 1500 — kad zarada prvi put dostigne cijenu (cilj ≤ 3 / ≤ 2 dana) | 2,1 (44) ✓ | 1,5 (24) ✓ | 1,2 (18) |
| Sir Pip 3000 — isto | 5,3 (126) | 2,9 (51) | 2,2 (36) |
| Tema 10000 — isto | 19,0 (478) | 9,0 (168) | 6,7 (99) |
| Besplatne sezone u čistom rushu (Frost / Lantern / Amber) | 5,9 / 14,1 / 30,9 (prije ★3 ×2: 8,3 / 18,9 / 33,4) | 2,9 / 7,1 / 14,1 (prije: 2,9 / 7,4 / 14,1) | 2,2 / 4,4 / 9,5 (prije: 9,6) |
| Sir Pip i teme u normalnoj igri (rush, kupuje ih poslije sve 4 besplatne sezone) | Sir Pip 78, Moonlit 88, Coral 95; Starfall 5 / 10 putovanja do 2500 runova | Sir Pip 36, teme 41 / 45 / 50 | Sir Pip 28, teme 32 / 36 / 40 |
| Merge Hint kupljen odmah → besplatne sezone kasne | +16–49 % (Frost 5,9 → 8,8 d) | +12–21 % | +18–36 % |
| Loot Burst 500 — najveće ubrzanje besplatne sezone (kupuje kad coini za sezonu već postoje) | 11 % (prvi krug, ★3 ×1: **37 %**) | 0 % | 0 % |
| Loot Burst 750 — isto | 0 % (prvi krug: 27 %) | 0 % | 0 % |
| **Loot Burst 1000** — isto | **0 %** | 0 % | 0 % |

Dupli ★3 skraćuje casual put (★3 mu je bio usko grlo); average i skilled koče coini i nagrada staze na L20, pa se skoro ne mijenjaju. Zato Merge Hint casual igraču sada „košta" više dana: coini su postali usko grlo. Loot Burst bi sa duplim ★3 prošao kriterij i na 750 C (500 C: casual 11 %), ali ostaje 1000 (cijena nije tražena za promjenu). Kupovina Burstova „čim fali ★3" nikad ne ubrza (troši coine koji trebaju za sezonu: do +97 % kasnije). Plaćene teme imaju svoj Level Path (2200 C + 22 ★3 njihovog cvijeta + Endless), pa tema kupljena coinima igranjem vrati dio cijene — zato nisu jeftinije od najskupljeg izgleda (2500). Granice čuva `economy_balance_smoke` (Merge Hint < prva sezona, teme ≥ najskuplji izgled, Loot Burst ≥ 200 C po ★3).

### Otvoreni targeti (playtest — F4 pass 1, 2026-07-29)

| Parametar | Measured | Napomena |
|-----------|----------|----------|
| Prosječno coins / run (simulacija 5× `finish_run`) | **~8** | `balance_snapshot.gd`; stvarni runovi variraju s levelom |
| Prosječno seeds / run (simulacija) | **~8** | fail 50% na alternirajućim runovima uključen |
| Fine-tune shop cijena | pending | nakon 5-min vanjskog playtesta |
| Vrijeme do prvog mergea (onboarding) | pending | test bez `DEBUG_DEV_RESOURCES` |

> **5-min playtest gate:** koristi checklist u [[../06-production/d0-functional-audit#F4 — Balans bilješke|d0-functional-audit]] prije D0-P.

## Kamp / vrt (`game_state.gd`)

| Konstanta | Vrijednost | Značenje |
|-----------|-----------|----------|
| `CAMP_BED_COUNT` | **9** | gredice vrta (3×3) |
| `GREENHOUSE_SLOT_COUNT` | **2** | staklenik (★★★ only) |
| `MAX_MERGE_TIER` | `3` | T1→T2→T3 crystal |
| merge | 2× isti `type_id` + isti tier | T1+T1=T2 |
| T2 nakon mergea | leftover u areni → 2× T1; T3 ide u Flowers | CAMP-01: upgrade se plaća iz Flowers |
| `collection_kept_tiers` | po `type_id` → max tier | Keep ne drži cvijet na gredici |
| `SEED_BAG_SOFT_CAP` | ~~40~~ | **više nije limit (2026-10-16):** vreća prima sav plijen runa, ostatak Arene i poklon. Ranije se višak tiho gubio (playtest: „sjemena iz runa ne dođu u Camp"). 40 ostaje samo kao „puna korpa" u crtežu |
| auto-plant | pri ulasku u kamp + nakon Keep/chest | preskače tutorial CAMP1 |
| `CAMP_BED_BONUS` | **+3** gredice | kad je Sprinkler max (9→12) |
| `DAILY_CHEST_COINS` | **75** (bilo 8) | jednom dnevno (save `last_daily_chest_day`) |
| `DAILY_CHEST_SEEDS` | **5** (bilo 3) | random iz unlocked spawn poola |
| Arena combo | **5** coina, max **30** / dan (bilo 2 / 10) | `ArenaDomain.COMBO_COINS`, `COMBO_COIN_DAILY_CAP` |
| `discovered_blooms` | po `type_id` | priprema za dnevnik/setove |
| `sprinkler_donations` | 0–2 | legacy save polje; CAMP-01 B **ne** koristi za Upgrade |
| `EXCHANGE_SEED_COUNT` | `1` | sjemena po Trade tapu; držanje dugmeta trguje 10/s (`TRADE_HOLD_RATE`) i prelazi na sljedeći tip |
| `SEED_EXCHANGE_COINS_BY_RARITY` | ★1=`1`, ★2=`2`, ★3=`4` | C po sjemeniu |
| `CRYSTAL_EXCHANGE_COINS_BY_RARITY` | ★1=`5`, ★2=`10`, ★3=`20` | C po flower/crystal |
| rezervisano ★3 cvijeće (2026-09-15) | granica = `t3_flowers_required` sljedeće besplatne sezone (★3 tip prethodne; Frost Orchard: 20 Harvest Pumpkin) | Camp Trade: držanje staje prije nego tip padne ispod granice; tap prodaje po 1 i ispod nje. Sjemenke i stanje bez sljedeće sezone nemaju granicu. Uslov otključavanja: 500 C + 20 ★3 (`seasons.json`) |

### Rarity → gdje se sadi

| Rarity | Primjer | Lokacija |
|--------|---------|----------|
| ★–★★ | Clover, Tulip | vrt (gredice) |
| ★★★ | Pumpkin, Watermelon | staklenik (kad otključeno u lancu) |

## Seed unlock — Almanac (2026-07-11; Shop UI removed Bug-013)

> Kod: `scripts/progression/seed_unlock_config.gd` · `game_state.gd`  
> Unlock u v1 UI: **lifetime auto** u runovima (nema Shop Seed Almanac sekcije). Coin shortcut ostaje u GameState API bez Shop CTA.

| Pravilo | Vrijednost |
|---------|------------|
| Lanac (linearno) | Clover → Daisy → Buttercup → Tulip → Sunflower → Pumpkin → Watermelon |
| Unlock trigger | **Lifetime** skupljeno u runovima prethodnog tipa (ne troši torbe) |
| Pragovi | **8 / 8 / 8 / 6 / 6** (prethodni tip → sljedeći; bilo 10 / 10 / 10 / 12 / 12) — ★2 je rjeđe pa su pragovi niži; Harvest Pumpkin stiže oko levela 12–14 |
| Auto-unlock | Kad lifetime ≥ prag → sljedeći tip u **spawn poolu** odmah |
| Coins shortcut | 120 / 150 / 150 / 180 / 200 / 220 (API only — bez Shop UI u v1) |
| Run spawn | Samo **otključani** tipovi (+ loadout bias) |

## Sprinkler + Loot Boost (`game_state.gd`)

| Konstanta | Vrijednost |
|-----------|-----------|
| `MAGNET_MAX_LEVEL` | `4` |
| Cijena nivoa (Home polje, po sezoni) | `UiCamp.UP_COIN_COST` **100 / 250 / 500 / 800** C + `UP_FLOWER_COSTS` **2 / 2 / 3 / 3** ★3 sezone (bilo 10 / 20 / 40 / 60 + 2) |
| `UPGRADE_FLOWER_COST` | 2 — legacy (stari Camp donate API) |
| `MAGNET_COST_T2` | `2` — legacy broj za stari donate API; resurs upgradea je T3 |
| `MAGNET_BASE_RADIUS` | `40` px |
| `MAGNET_RADIUS_PER_LEVEL` | `55` px (bilo 48) — max 260 px dohvata susjednu stazu (270) |
| `MULTIPLIER_MAX_LEVEL` | `4` |
| `MULTIPLIER_COST_T3` | `2` — legacy donate broj; Loot Boost troši isti `UPGRADE_FLOWER_COST` |
| `MULTIPLIER_VALUES` | ×1.0, ×1.25, ×1.5, ×1.75, ×2.0 |
| Twin Seeds `UiCamp.TWIN_STEP` | **8 %** po nivou (0 / 8 / 16 / 24 / 32 %) — pokupljeno sjeme sa staze daje 2; nagradni grm nije Twin |

**Loot Boost — zaokruživanje (2026-10-16):**
- Coini: `max(raw, round(raw × m))`.
- Sjeme: cilj = `max(ukupno, round(ukupno × m))`; svaki tip dobije `floor(n × m)` (ne manje od n), ostatak do cilja ide tipovima s najvećim razlomkom (jednako → više skupljenih, pa ime). Primjer ×1,25 na 5 tipova po 1 = 6 (ranije po tipu = 5).
- Boost se računa **jednom**, na kraju runa (`finish_run`), i prije „Kept half" pri padu. Revive nastavlja sa sirovim brojevima.
- Nivoi su po sezoni (`season_upgrades`) — run čita aktivnu sezonu.

### Merge Arena — Muncher pest (MA-01b, v1.1)

| Konstanta | Vrijednost | Napomena |
|-----------|------------|----------|
| `ARENA_PEST_SPEED` | 85 px/s | @ 1080×1920 |
| `ARENA_PEST_EAT_RADIUS` | 36 px | |
| `ARENA_PEST_EAT_DURATION` | 0.5 s | |
| `ARENA_PEST_T3_FREEZE` | 2.0 s | nakon T3 mergea |
| `ARENA_PEST_WAKE_DELAY` | 0.3 s | prije lova |
| `ARENA_PEST_TARGET_REEVAL` | 0.25 s | |

### Provjera kapaciteta
- 9 gredica (+3 bonus na max Sprinkler) → merge workspace; kolekcija ide u **Keep**, ne zauzima gredicu.
- Staklenik odvaja ★★★ od vrta — manje zagušenja kad dođe više tipova.

## Balans pass 1 (2026-07-05)

| Promjena | Prije | Sada | Razlog |
|----------|-------|------|--------|
| Post-tutorial run | 20 s | **60 s** | 20 s prekratko za camp loop; 75 s ostaje M8 target |
| Spawn interval / chance | 1.2 / 0.7 | bez promjene | ~8–12 pickupa u 60 s — OK za prvi pass |
| Obstacle chance | 0.25 | bez promjene | dovoljno rizika bez frustracije |
| Magnet T2 cost | 2 donacije | **CAMP-01 B:** 2 T3 Flowers | arena više ne donira |

**Osjećaj:** 60 s daje prostor za loadout (+5% spawn) i sprinkler upgrade bez žurbe. Fine-tune nakon shop prototipa (F8.4).

## Odluke (2026-07-04)

- **E2 cilj igrača:** T3 Flowers za **Sprinkler / Loot Boost** (kamp spend) ili Exchange za coins. Arena ne donira.
- **Tierovi:** T1→T2→T3 crystal (v1).
- **Kamp UX:** torba + auto-plant + Keep oslobađa gredicu (A+C).

## Otvorena pitanja

- [x] `RUN_DURATION` post-tutorial — **60 s** (pass 1); 75 s ako M8 playtest traži
- [x] Exchange rate po rarity (seed 1/2/4; flower 5/10/20 — Bug-031)
- [ ] Set bonus brojke kad dnevnik uđe u kod

## Povezano

- [[ekonomija|ekonomija]]
- [[spec-vertical-slice|spec-vertical-slice]]
- [[../03-content/ideje-gameplay-ekonomija|ideje-gameplay-ekonomija]]
