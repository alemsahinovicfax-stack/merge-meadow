---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, checklist, d0, polish]
povezano:
  - CHECKPOINT
  - scope-i-granice
  - troskovi-launcha
  - ideje-roadmap-implementacije
  - ../02-design/spec-vertical-slice
ai_sažetak: "Checklist Faze 1 — što je gotovo vs što još treba prije Play 25 USD; usklađeno sa scope IN + F8 idejama."
---

# D0 — Pre-launch checklist (Faza 1)

> **Cilj:** Sve stavke u tablici **✅** → tek onda [[troskovi-launcha|Faza 2]] (25 USD + Play upload).  
> **Izvor:** [[scope-i-granice|scope IN]] + [[ideje-roadmap-implementacije|F8 build order]] + stanje koda (`game/`).

## Sažetak (2026-07-11)

| Kategorija | Gotovo | Djelomično | Nedostaje |
|------------|--------|------------|-----------|
| Core gameplay | 6 | 1 | 1 |
| UX / flow | 7 | 2 | 0 |
| Monetizacija | 2 | 3 | 1 |
| Tech / audio / art | 3 | 4 | 3 |
| Launch infra (Faza 2) | 3 | 1 | 3 |
| **iOS (Faza 4)** | — | — | odgođeno |

**Procjena:** ~**55%** v1 IN scopea implementirano ili djelomično; **Faza 1** još traje.

## Timeline i projekcija Android launcha

> Ažurirano **2026-07-11**. Launch = **Faza 2** (D0 ✅ + Play **25 USD** + internal test → production).

### Od kada radimo?

| Datum | Događaj |
|-------|---------|
| **2026-06-30** | Početak projekta — dokumentacija, Gate M5 ✅, spreman greybox |
| **2026-07-03** | Prvi git commit + **`game/`** kod (M6 greybox isti dan) |
| **2026-07-03–05** | M7 vertical slice — loop, kamp vrt, tutorial F6–F7 |
| **2026-07-06–07** | C2 art (Pip), C3 monetizacija stub, D1–D2 (100 runova, endless) |
| **2026-07-09–10** | D3–D4 shop/IAP hooks, store screenshotovi, Android tooling |
| **2026-07-11** | Plan objave, D0 checklist (~45% v1) |

**Kalendarski rad:** ~**12 dana** od starta docs (30.6.) · ~**8 dana** od prvog koda (3.7.)  
**Git:** 10 commitova (intenzivan burst 3.–10.7.)

### Tempo (do sada)

| Metrika | Vrijednost |
|---------|------------|
| Milestonei | M5½ → M6 → M7 → **M8 djelomično** za ~1,5 tjedna koda |
| v1 launch scope | **0% → ~45%** u ~8–11 kalendarskih dana |
| Preostalo (D0) | **~55%** — 15 većih stavki (Blok A–E) |
| Planirani kapacitet (docs) | **5–8 h/tj.** — burst u srpnju vjerojatno iznad toga |

**Napomena:** Prvih 8 dana koda bilo je **najbrže** (greybox → pun loop → 100 levela). Preostali posao (art po tipu, SFX, plugini, daily chest) obično traje **duže po featureu** nego raniji sistemski koraci.

### Procjena datuma Android launcha (ovim tempom)

| Scenarij | Pretpostavka | D0 gotov | **Android launch (Faza 2)** |
|----------|--------------|----------|----------------------------|
| **A — nastavi srpanjski burst** | ~15–20 h/tj. još 3–4 tj. | **2026-08-04 – 2026-08-18** | **2026-08-11 – 2026-08-25** |
| **B — realistično (student)** | ~6–10 h/tj., povremeni ispiti | **2026-09-15 – 2026-10-31** | **2026-10-01 – 2026-11-15** |
| **C — sporije (ispiti + pauza)** | ~3–5 h/tj. | **2026-11 – 2027-01** | **2026-12 – 2027-02** |

**Centar težine (scenarij B):** **kraj listopada – sredina studenog 2026.** (~**3,5–4,5 mjeseca** od starta projekta, ~**3–4 mjeseca** od prvog koda).

Faza 2 dodaje **~1 tjedan** nakon D0 (25 USD, Play forme, internal test, release AAB) — uračunato u tablicu.

### Što ubrzava / usporava

| Ubrzava | Usporava |
|---------|----------|
| Loop i store prep već gotovi | 15 D0 stavki, ne 2–3 |
| Cursor + spec-driven workflow | Art (7–10 spriteova) = više sati nego jedan GDScript |
| Jedan blok po sesiji (CHECKPOINT pravilo) | AdMob/Billing plugin debug na uređaju |
| | Fakultet / ispitni rokovi (TBD u docs) |

---

Legenda: ✅ gotovo · 🟡 djelomično · ❌ nedostaje · ⏸ odgođeno (plan)

---

## Core gameplay

| # | Stavka (scope IN) | Status | Napomena / fajl |
|---|-------------------|--------|-----------------|
| G1 | Lane run — swipe, prepreke, auto-scroll | ✅ | `run_controller.gd`, `player.gd` |
| G2 | 100 konfiguriranih runova | ✅ | `RunLevelLibrary`, `levels_1_10.json` |
| G3 | Endless mode (Easy/Normal/Hard) | ✅ | `main_menu.gd`, `game_state.gd` |
| G4 | Merge kamp 2→1, **min 3 tiera** | ✅ | T1→T2→T3 (`MAX_MERGE_TIER := 3`) |
| G5 | Upgrade **magnet** (min 4 levela) | ✅ | Sprinkler/magnet 0–4 (`MAGNET_MAX_LEVEL`) |
| G6 | Upgrade **množitelj** (min 4 levela) | ✅ | Loot Boost 0–4, T3 donate, ×1.0–×2.0 |
| G7 | 2 ljubimca — Pip + 1 unlock | ✅ | Pip + **Mochi** (kamp Lv 2, companion picker) |
| G8 | Vrt 6+ gredica + staklenik | ✅ | 9 garden + 2 greenhouse (`camp_controller.gd`) |
| G9 | Loadout koš (1 slot) | ✅ | `loadout_type_id`, spawn bonus |
| G10 | Raznovrsnost sjemena u runu | ✅ | Linear unlock chain; spawn = unlocked types only |

---

## UX / flow

| # | Stavka | Status | Napomena |
|---|--------|--------|----------|
| U1 | Splash → tutorial → main menu | 🟡 | Tutorial ✅; **nema in-game splash** scene; Android system splash default |
| U2 | Loot: ×2 rewarded, revive, retry, kamp | ✅ | `loot_screen.gd` + revive resume |
| U3 | Kamp: merge, upgrade, Keep, auto-plant | ✅ | Keep oslobađa gredicu; torba soft cap 40 |
| U4 | **Daily chest** | ✅ | `claim_daily_chest()`, save v4, kamp gumb |
| U5 | Shop: remove ads + starter pack | ✅ | `shop_screen.gd`, `IAPManager` |
| U6 | Shop: **booster consumables** | ✅ | Merge Hint + Loot Burst IAP; inventory + Use u shopu |
| U7 | Shop / kamp kozmetika (3–5 itema) | ✅ | 5 coin itema u shopu (`cosmetic_catalog.gd`) |
| U8 | **Dnevnik kolekcije** (lista otkrića) | ✅ | `collection_journal.tscn`, 📖 u kamp top baru, NEW badge |
| U9 | Settings ekran | 🟡 | Placeholder handleri (hub/camp/menu); puni ekran **D0-P** |
| U10 | EN UI copy | ✅ | Store + in-game EN |

---

## Monetizacija

| # | Stavka | Status | Napomena |
|---|--------|--------|----------|
| M1 | AdMob rewarded (×2 loot, revive) | 🟡 | `AdManager` **stub**; nema `addons/` Poing plugin |
| M2 | Interstitial na loot (Retry) | 🟡 | Hook u `loot_screen.gd`; plugin pending |
| M3 | IAP remove ads + starter pack | 🟡 | Billing hook; **stub** dok nema plugina na uređaju |
| M4 | Offline igra; IAP treba mrežu | ✅ | Dizajn OK |
| M5 | Production AdMob unit ID-evi | ❌ | Još test ID u configu |
| M6 | Play Console IAP product ID match | ❌ | Tek u Fazi 2 nakon $25 |

---

## Tech / audio / art

| # | Stavka | Status | Napomena |
|---|--------|--------|----------|
| T1 | Flat cartoon art (ne greybox) | 🟡 | Pip SVG, lane BG, Kenney UI; biljke procedural (`camp_plant_draw.gd`) |
| T2 | **10 tipova sjemena** — distinct T1/T2 sprite | 🟡 | 7 tipova procedural (camp T1/T2/T3 + run pickup); PNG kasnije |
| T3 | **SFX** — pickup, merge, fail | ❌ | Nema `AudioStreamPlayer` / audio assets |
| T4 | Muzika (opcionalno kamp) | ❌ | Opcionalno po scopeu — nice-to-have |
| T5 | Set bonus (2 seta) | ❌ | F8.11 — ideje launch 🟡 |
| T6 | `DEBUG_DEV_RESOURCES := true` | ❌ | **Isključiti** prije release builda (`game_state.gd`) |
| T7 | Release AAB + keystore | ❌ | Faza 2 — debug APK postoji |
| T8 | Branded splash / app icon 512 | 🟡 | `icon.svg` default; export splash prazan |
| T9 | Vanjski playtest 5 min bez vođenja | ❌ | M7 exit kriterij — ponoviti prije launcha |
| T10 | Balans pass (100 runova + ekonomija) | 🟡 | Brojke u docs; puni pass nije rađen |

---

## Launch infra (Faza 2 — ne plaća se dok D0 nije ✅)

| # | Stavka | Status | Napomena |
|---|--------|--------|----------|
| L1 | Privacy policy URL | ✅ | GitHub Pages live |
| L2 | Store listing + 8 screenshotova | ✅ | `marketing/store/` |
| L3 | Play developer **25 USD** | ❌ | Namjerno čeka D0 |
| L4 | AdMob + Billing plugin u exportu | ❌ | Instalirati Poing plugine |
| L5 | Internal test upload | ❌ | [[play-internal-test|D5 runbook]] |
| L6 | Data safety + content rating | ❌ | Play Console forma |

---

## Odgođeno (ne ulazi u Fazu 1)

| Stavka | Faza | Razlog |
|--------|------|--------|
| iOS export + TestFlight | **4** | ~99 USD Apple Developer |
| Mac / GHA iOS test na iPhoneu | **4** | C4 checkbox ostaje otvoren |
| CPI test 50–100 € | **3** | Nakon Android launcha |
| Level generator | v1.1 | Scope OUT za launch |

---

## Preporučeni redoslijed rada

Prioritet = **igra radi ispravno i balansirano** prije VFX/visual/sound polish i store naknade.

### D0-F — Funkcionalnost (sada, prije polish)

1. **F1** — puni audit svih ekrana (meta hub ulaz) → [[d0-functional-audit|d0-functional-audit]]
2. **F2** — debug + regression fixevi (greske-katalog, bug lista)
3. **F3** — popravke mehanika + sync spec s merge arena modelom
4. **F4** — balans pass + 5-min playtest + `ekonomija-brojevi`

### Blok A — Gameplay (gotovo ✅)
1. **G4** — merge T3 ✅
2. **G6** — množitelj upgrade ✅
3. **G10** — spawn pool almanac ✅
4. **U4** — daily chest ✅

### Blok B — Sadržaj (djelomično)
5. **T2 / F8.1** — spriteovi sjemena — 🟡 procedural, PNG **D0-P**
6. **G7 / F8.9** — Mochi ✅
7. **U8** — dnevnik ✅
8. **U7 / U6** — shop kozmetika + boosteri ✅

### D0-P — Feel i polish *(nakon F4)*
9. **T3** — SFX set
10. **T1** — kamp/run art pass
11. **U1** — splash / branded export
12. **U9** — settings ekran
13. **T6** — debug resursi off; release AAB test

### D0-M — Monetizacija production *(nakon F4)*
14. **M1–M3** — Poing AdMob + Billing
15. **M5** — production ad unit ID-evi

### Blok E — Gate prije $25 *(nakon D0-P/M)*
16. **T9** — vanjski playtest (F4 uključuje 5-min gate)
17. **T7** — release AAB, keystore
18. Sve checkboxove ✅ → **Faza 2**

---

## Parking — v1.1 (ne D0)

| ID | Stavka | Doc |
|----|--------|-----|
| MA-01 | Merge Arena (zamjena gredica) | [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] |
| DG-01 | Daily Goals (3 zadatka + bonus) | isti |

Trenutni D0 koristi **meta hub + merge arena + seed bag** — grid kamp zamijenjen u M8.

---

## Kako ažurirati ovaj doc

- Kad stavka završi: promijeni status u tablici + `[x]` u [[CHECKPOINT|CHECKPOINT]] D0
- Jedan blok (A/B/C…) po sesiji — ne preskači redoslijed osim bugfixa
- iOS stavke **ne dodavati** ovdje — vidi [[troskovi-launcha|troskovi-launcha]] Faza 4

## Povezano

- [[CHECKPOINT#Sekcija D|Sekcija D]] — operativni checkboxovi
- [[scope-i-granice|scope-i-granice]] — IN/OUT
- [[ideje-roadmap-implementacije#F8 — v1 launch|F8 roadmap]]
- [[play-internal-test|play-internal-test]] — nakon D0
