---
type: dizajn
status: aktivan
milestone: M8
tags: [simulacija, ekonomija, balans, monetizacija, coini]
povezano:
  - ekonomija-brojevi
  - balans-ciklus-1b-simulacija
  - ads-only-coini-izvjestaj
ai_sažetak: "Izlaz coin_offer_sim.gd (2026-10-27): koliko dana treba do svake stvari koja se prije kupovala pravim novcem i koliko Loot Burst za coine ubrzava besplatne sezone — Merge Hint 1500 dohvatljiv za 1,2–2,1 dana, teme / Sir Pip u normalnoj igri poslije besplatnih sezona, Loot Burst 500 → casual Frost 37 % ranije, od 1000 → 0 %."
---

# Coin ponude bez kupovina — simulacija (sirovi izlaz)

> Roditelj: [[_index|02-design]] · Cijene i zaključci: [[ekonomija-brojevi#Coin cijene bez kupovina (v1, 2026-10-26)|ekonomija-brojevi]] · Izvještaj: [[../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · Isti model igrača kao [[balans-ciklus-1b-simulacija|balans-ciklus-1b-simulacija]].

**Sažetak.** Merge Hint (1500 C) igrač može kupiti za 1,2 (skilled) – 2,1 (casual) dana ako mu je to prvi cilj; kupljen odmah odgodi besplatne sezone za 3–32 %. Teme i Sir Pip (3000–3500 C) su prosječnom igraču dostupni oko 3. dana ako štedi samo za njih, a u normalnoj igri dolaze tek poslije sve četiri besplatne sezone (average 37.–42. dan, skilled 28.–33., casual 60+). Loot Burst je po početnom prijedlogu (500 C) prejeftin: casual igrač, kojem coini dođu prije zadnjih ★3, jednim Burstom otključa Frost Orchard 37 % ranije (8,3 → 5,3 dana); na 750 C još 27 %. Od **1000 C** ubrzanje je 0 % za sve profile, a kupovanje „čim fali ★3" uvijek usporava. Konačne cijene: Merge Hint 1500, Loot Burst 1000, Moonlit / Starfall / Sir Pip 3000, Coral / Ember 3500.

Pokretanje (po profilu paralelno, APPDATA kopija):

```
godot --headless --path game -s res://scripts/dev/coin_offer_sim.gd -- --reps=10 --profiles=casual --burst-prices=500,750,1000,1250,1500 --out=…
```


## Profil: casual

### D1. Prva kupovina — dan kad zarada prvi put dostigne cijenu

Politika rush (štedi za sljedeću besplatnu sezonu, kupuje nadogradnje); broji se UKUPNA zarada od prvog runa — igrač kojem je ta stvar prvi cilj ima je tog dana. Medijan dana, u zagradi runova.

| Stvar | Cijena | casual |
|---|---|---|
| Merge Hint | 1500 | 2.1 (44) |
| Moonlit Warren | 3000 | 5.3 (126) |
| Starfall Glade | 3000 | 5.3 (126) |
| Sir Pip | 3000 | 5.3 (126) |
| Coral Tide Garden | 3500 | 7.0 (174) |
| Loot Burst (1×) | 1000 | 1.0 (18) |

Merge Hint (1500 C): casual 2.1 dana (cilj ≤ 3) ✓.

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).



| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 2.1 (44) | — | — |
| frost_orchard otključan | 9.0 (228) | 8.3 | +0.7 dana (+8 %) |
| lantern_meadow otključan | 19.5 (506) | 18.9 | +0.6 dana (+3 %) |
| amber_canopy otključan | 35.7 (964) | 33.4 | +2.3 dana (+7 %) |
| kupljeno: Moonlit Warren (3000) | 60.1 (1669) | — | — |
| kupljeno: Starfall Glade (3000) | 78.1 (2272) | — | — |
| kupljeno: Sir Pip (3000) | — (5 / 10) | — | — |
| kupljeno: Coral Tide Garden (3500) | — (5 / 10) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).



| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 8.3 (210) | 18.9 (495) | 33.4 (888) | — | 0 | 0 |
| 500 | pametno | 5.3 (126) · -37 % | 15.7 (392) · -17 % | 32.0 (855) · -4 % | 37 % | 1 | 500 |
| 500 | sve | 7.0 (178) · -16 % | 22.1 (602) · +17 % | 44.0 (1221) · +32 % | 16 % | 9 | 4500 |
| 750 | pametno | 6.1 (153) · -27 % | 16.4 (421) · -13 % | 33.2 (884) · +0 % | 27 % | 1 | 750 |
| 750 | sve | 8.7 (221) · +5 % | 24.7 (692) · +31 % | 49.0 (1381) · +47 % | 0 % | 8 | 6000 |
| 1000 | pametno | 8.3 (210) · +0 % | 18.9 (495) · +0 % | 33.4 (888) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 10.2 (265) · +23 % | 27.0 (725) · +43 % | 49.9 (1364) · +50 % | 0 % | 7 | 7000 |
| 1250 | pametno | 8.3 (210) · +0 % | 18.9 (495) · +0 % | 33.4 (888) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 12.0 (322) · +45 % | 28.8 (789) · +52 % | 51.1 (1419) · +53 % | 0 % | 6 | 7500 |
| 1500 | pametno | 8.3 (210) · +0 % | 18.9 (495) · +0 % | 33.4 (888) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 9.0 (232) · +8 % | 29.1 (803) · +54 % | 51.0 (1391) · +53 % | 0 % | 5 | 7500 |

**Kriterij po cijeni:**

- 500 C: najveće ubrzanje casual 37 % → ✗
- 750 C: najveće ubrzanje casual 27 % → ✗
- 1000 C: najveće ubrzanje casual 0 % → ✓
- 1250 C: najveće ubrzanje casual 0 % → ✓
- 1500 C: najveće ubrzanje casual 0 % → ✓

Najniža cijena iz sweepa koja ispunjava kriterij: **1000 C** (u podacima sada 1000 C).


## Profil: average

### D1. Prva kupovina — dan kad zarada prvi put dostigne cijenu

Politika rush (štedi za sljedeću besplatnu sezonu, kupuje nadogradnje); broji se UKUPNA zarada od prvog runa — igrač kojem je ta stvar prvi cilj ima je tog dana. Medijan dana, u zagradi runova.

| Stvar | Cijena | average |
|---|---|---|
| Merge Hint | 1500 | 1.5 (24) |
| Moonlit Warren | 3000 | 2.9 (51) |
| Starfall Glade | 3000 | 2.9 (51) |
| Sir Pip | 3000 | 2.9 (51) |
| Coral Tide Garden | 3500 | 2.9 (51) |
| Loot Burst (1×) | 1000 | 1.0 (16) |

Merge Hint (1500 C): average 1.5 dana (cilj ≤ 2) ✓.

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).



| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 1.5 (24) | — | — |
| frost_orchard otključan | 3.5 (59) | 2.9 | +0.6 dana (+19 %) |
| lantern_meadow otključan | 8.5 (150) | 7.1 | +1.4 dana (+20 %) |
| amber_canopy otključan | 15.5 (260) | 13.9 | +1.6 dana (+11 %) |
| kupljeno: Moonlit Warren (3000) | 37.3 (509) | — | — |
| kupljeno: Starfall Glade (3000) | 38.8 (522) | — | — |
| kupljeno: Sir Pip (3000) | 40.1 (535) | — | — |
| kupljeno: Coral Tide Garden (3500) | 42.1 (555) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).



| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 2.9 (51) | 7.1 (130) | 13.9 (245) | — | 0 | 0 |
| 500 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 13.9 (245) · +0 % | 0 % | 0 | 0 |
| 500 | sve | 2.9 (51) · +0 % | 9.2 (155) · +30 % | 19.4 (301) · +40 % | 0 % | 9 | 4500 |
| 750 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 13.9 (245) · +0 % | 0 % | 0 | 0 |
| 750 | sve | 3.5 (59) · +19 % | 10.8 (182) · +53 % | 21.2 (321) · +52 % | 0 % | 8 | 6000 |
| 1000 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 13.9 (245) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 4.1 (65) · +42 % | 11.5 (183) · +63 % | 21.3 (314) · +53 % | 0 % | 6 | 6000 |
| 1250 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 13.9 (245) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 4.7 (70) · +62 % | 12.0 (189) · +70 % | 22.2 (328) · +60 % | 0 % | 6 | 7500 |
| 1500 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 13.9 (245) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 3.5 (59) · +19 % | 12.5 (192) · +77 % | 22.9 (324) · +65 % | 0 % | 4 | 6000 |

**Kriterij po cijeni:**

- 500 C: najveće ubrzanje average 0 % → ✓
- 750 C: najveće ubrzanje average 0 % → ✓
- 1000 C: najveće ubrzanje average 0 % → ✓
- 1250 C: najveće ubrzanje average 0 % → ✓
- 1500 C: najveće ubrzanje average 0 % → ✓

Najniža cijena iz sweepa koja ispunjava kriterij: **500 C** (u podacima sada 1000 C).


## Profil: skilled

### D1. Prva kupovina — dan kad zarada prvi put dostigne cijenu

Politika rush (štedi za sljedeću besplatnu sezonu, kupuje nadogradnje); broji se UKUPNA zarada od prvog runa — igrač kojem je ta stvar prvi cilj ima je tog dana. Medijan dana, u zagradi runova.

| Stvar | Cijena | skilled |
|---|---|---|
| Merge Hint | 1500 | 1.2 (18) |
| Moonlit Warren | 3000 | 2.2 (36) |
| Starfall Glade | 3000 | 2.2 (36) |
| Sir Pip | 3000 | 2.2 (36) |
| Coral Tide Garden | 3500 | 2.2 (36) |
| Loot Burst (1×) | 1000 | 0.8 (12) |

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).



| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 1.2 (18) | — | — |
| frost_orchard otključan | 2.6 (39) | 2.2 | +0.4 dana (+20 %) |
| lantern_meadow otključan | 5.8 (80) | 4.4 | +1.4 dana (+32 %) |
| amber_canopy otključan | 11.2 (137) | 9.5 | +1.6 dana (+17 %) |
| kupljeno: Moonlit Warren (3000) | 28.4 (282) | — | — |
| kupljeno: Starfall Glade (3000) | 29.9 (290) | — | — |
| kupljeno: Sir Pip (3000) | 31.0 (299) | — | — |
| kupljeno: Coral Tide Garden (3500) | 32.6 (310) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).



| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 2.2 (36) | 4.4 (66) | 9.5 (120) | — | 0 | 0 |
| 500 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 500 | sve | 2.2 (36) · +0 % | 7.0 (91) · +58 % | 14.1 (163) · +48 % | 0 % | 9 | 4500 |
| 750 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 750 | sve | 2.6 (39) · +20 % | 8.0 (96) · +82 % | 15.6 (173) · +64 % | 0 % | 8 | 6000 |
| 1000 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 3.2 (42) · +47 % | 8.6 (102) · +94 % | 16.0 (178) · +68 % | 0 % | 6 | 6000 |
| 1250 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 3.7 (47) · +70 % | 9.5 (109) · +115 % | 17.6 (182) · +84 % | 0 % | 6 | 7500 |
| 1500 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 2.6 (39) · +20 % | 7.4 (92) · +67 % | 14.3 (159) · +50 % | 0 % | 3 | 4500 |

**Kriterij po cijeni:**

- 500 C: najveće ubrzanje skilled 0 % → ✓
- 750 C: najveće ubrzanje skilled 0 % → ✓
- 1000 C: najveće ubrzanje skilled 0 % → ✓
- 1250 C: najveće ubrzanje skilled 0 % → ✓
- 1500 C: najveće ubrzanje skilled 0 % → ✓

Najniža cijena iz sweepa koja ispunjava kriterij: **500 C** (u podacima sada 1000 C).

## Coin cijene u podacima (MonetizationConfig.IAP_PRODUCTS · coin_price)

- remove_ads: 0 C
- starter_pack: 0 C
- booster_merge_hint: 1500 C
- booster_loot_burst: 1000 C
- season_pack_moonlit_warren: 3000 C
- season_pack_coral_tide: 3500 C
- season_pack_starfall_glade: 3000 C
- season_pack_ember_fen: 3500 C
- pip_knight: 3000 C

