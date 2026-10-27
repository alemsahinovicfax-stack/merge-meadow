---
type: dizajn
status: aktivan
milestone: M8
tags: [simulacija, ekonomija, balans, monetizacija, coini]
povezano:
  - ekonomija-brojevi
  - balans-ciklus-1b-simulacija
  - ads-only-coini-izvjestaj
ai_sažetak: "Izlaz coin_offer_sim.gd (2026-10-27, poslije teme 10000 C i ★3 ×2 uz ★3 tip uvijek rjeđi od ★2 tipa): Merge Hint 1500 dohvatljiv za 1,2–2,1 dana; teme 10000 C prosječnom igraču za 9 dana štednje, u normalnoj igri 41.–50. dan; dupli ★3 skraćuje casual put do Frost Orcharda 8,3 → 5,9 dana; Loot Burst 1000 C i dalje 0 % ubrzanja."
---

# Coin ponude bez kupovina — simulacija (sirovi izlaz)

> Roditelj: [[_index|02-design]] · Cijene i zaključci: [[ekonomija-brojevi#Coin cijene bez kupovina (v1, 2026-10-26)|ekonomija-brojevi]] · Izvještaj: [[../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · Isti model igrača kao [[balans-ciklus-1b-simulacija|balans-ciklus-1b-simulacija]].

**Sažetak (2026-10-27, drugi krug).** Dvije izmjene na zahtjev: sve plaćene (premium) teme koštaju **10000 C** (ranije 3000 / 3500) i ★3 sjeme pada **dvostruko češće** (`rare3_mult` ×2, `RunBalance.BASE_RARE3` 0,12 → 0,24). Svaki ★3 tip ipak ostaje rjeđi od svakog ★2 tipa, pa je od levela 8 i u Endlessu od 1 min ★3 = ★2 − 0,01 (manje od ×2, npr. L20 0,59 umjesto 0,75).

- **Dupli ★3** najviše pomaže casual igraču, kojem je ★3 bio usko grlo: Frost Orchard 8,3 → 5,9 dana (−29 %), Lantern Meadow 18,9 → 14,1 (−25 %), Amber Canopy 33,4 → 30,9 (−7 %). Average i skilled se praktično ne mijenjaju (njih koči nagrada staze na L20 i coini, ne ★3).
- **Teme 10000 C**: ako štedi samo za jednu temu, average je ima 9,0. dana, skilled 6,7., casual 19. U normalnoj igri (prvo sve besplatne sezone) teme dolaze average 41.–50. dan, skilled 32.–40., casual 88.+ (treća tek kod 5 / 10 casual putovanja u horizontu simulacije). Sir Pip (3000) ostaje prva „premium" stvar: average 36,0. dan, skilled 27,6.
- **Merge Hint 1500** i dalje: D1 average 1,5 dana, casual 2,1 ✓. Kupljen odmah casual igraču sada odgodi Frost za +2,9 dana (+49 %) — ne zato što je Merge Hint skuplji, nego zato što je put bez njega kraći (coini su sada usko grlo, ne ★3). To je svjestan izbor igrača, ne zid.
- **Loot Burst 1000**: 0 % ubrzanja za sve profile. Kriterij bi prošao i na 750 C (500 C: casual 11 % > 10 %), ali cijena se nije mijenjala — 1000 ostaje (sigurnije, korisnik nije tražio promjenu).

Prvi krug (teme 3000 / 3500, ★3 ×1): casual Frost 8,3 dana, Loot Burst 500 → 37 % ubrzanja (zato 1000). Sirovi izlaz prvog kruga je u git historiji ovog fajla (commit fac312b).

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
| Sir Pip | 3000 | 5.3 (126) |
| Moonlit Warren | 10000 | 19.0 (478) |
| Coral Tide Garden | 10000 | 19.0 (478) |
| Starfall Glade | 10000 | 19.0 (478) |
| Loot Burst (1×) | 1000 | 1.0 (18) |

Merge Hint (1500 C): casual 2.1 dana (cilj ≤ 3) ✓.

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).

| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 2.1 (44) | — | — |
| frost_orchard otključan | 8.8 (223) | 5.9 | +2.9 dana (+49 %) |
| lantern_meadow otključan | 19.0 (485) | 14.1 | +4.9 dana (+34 %) |
| amber_canopy otključan | 36.0 (962) | 30.9 | +5.1 dana (+16 %) |
| kupljeno: Sir Pip (3000) | 78.3 (2134) | — | — |
| kupljeno: Moonlit Warren (10000) | 87.7 (2308) | — | — |
| kupljeno: Coral Tide Garden (10000) | 94.8 (2487) | — | — |
| kupljeno: Starfall Glade (10000) | — (5 / 10) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).

| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 5.9 (159) | 14.1 (370) | 30.9 (813) | — | 0 | 0 |
| 500 | pametno | 5.3 (126) · -11 % | 15.5 (392) · +10 % | 33.0 (870) · +7 % | 11 % | 1 | 500 |
| 500 | sve | 7.0 (178) · +18 % | 21.3 (571) · +51 % | 43.7 (1190) · +41 % | 0 % | 8 | 4000 |
| 750 | pametno | 5.9 (152) · +0 % | 14.1 (370) · +0 % | 30.9 (813) · +0 % | 0 % | 0 | 0 |
| 750 | sve | 8.8 (223) · +49 % | 24.0 (641) · +70 % | 48.2 (1309) · +56 % | 0 % | 7 | 5250 |
| 1000 | pametno | 5.9 (159) · +0 % | 14.1 (370) · +0 % | 30.9 (813) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 10.2 (267) · +72 % | 27.5 (742) · +95 % | 51.2 (1368) · +65 % | 0 % | 6 | 6000 |
| 1250 | pametno | 5.9 (159) · +0 % | 14.1 (370) · +0 % | 30.9 (813) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 12.0 (314) · +102 % | 27.1 (762) · +92 % | 52.0 (1419) · +68 % | 0 % | 6 | 7500 |
| 1500 | pametno | 5.9 (159) · +0 % | 14.1 (370) · +0 % | 30.9 (813) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 8.8 (223) · +49 % | 24.0 (641) · +70 % | 51.1 (1389) · +65 % | 0 % | 4 | 6000 |

**Kriterij po cijeni:**

- 500 C: najveće ubrzanje casual 11 % → ✗
- 750 C: najveće ubrzanje casual 0 % → ✓
- 1000 C: najveće ubrzanje casual 0 % → ✓
- 1250 C: najveće ubrzanje casual 0 % → ✓
- 1500 C: najveće ubrzanje casual 0 % → ✓

Najniža cijena iz sweepa koja ispunjava kriterij: **750 C** (u podacima sada 1000 C).


## Profil: average

### D1. Prva kupovina — dan kad zarada prvi put dostigne cijenu

Politika rush (štedi za sljedeću besplatnu sezonu, kupuje nadogradnje); broji se UKUPNA zarada od prvog runa — igrač kojem je ta stvar prvi cilj ima je tog dana. Medijan dana, u zagradi runova.

| Stvar | Cijena | average |
|---|---|---|
| Merge Hint | 1500 | 1.5 (24) |
| Sir Pip | 3000 | 2.9 (51) |
| Moonlit Warren | 10000 | 9.0 (168) |
| Coral Tide Garden | 10000 | 9.0 (168) |
| Starfall Glade | 10000 | 9.0 (168) |
| Loot Burst (1×) | 1000 | 1.0 (16) |

Merge Hint (1500 C): average 1.5 dana (cilj ≤ 2) ✓.

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).

| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 1.5 (24) | — | — |
| frost_orchard otključan | 3.5 (59) | 2.9 | +0.6 dana (+19 %) |
| lantern_meadow otključan | 8.5 (151) | 7.1 | +1.5 dana (+21 %) |
| amber_canopy otključan | 15.7 (270) | 14.1 | +1.7 dana (+12 %) |
| kupljeno: Sir Pip (3000) | 36.0 (494) | — | — |
| kupljeno: Moonlit Warren (10000) | 40.7 (533) | — | — |
| kupljeno: Coral Tide Garden (10000) | 45.4 (574) | — | — |
| kupljeno: Starfall Glade (10000) | 50.2 (615) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).

| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 2.9 (51) | 7.1 (130) | 14.1 (244) | — | 0 | 0 |
| 500 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 14.1 (244) · +0 % | 0 % | 0 | 0 |
| 500 | sve | 2.9 (51) · +0 % | 9.3 (153) · +31 % | 18.0 (283) · +28 % | 0 % | 8 | 4000 |
| 750 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 14.1 (244) · +0 % | 0 % | 0 | 0 |
| 750 | sve | 3.5 (59) · +19 % | 10.5 (173) · +49 % | 20.3 (316) · +44 % | 0 % | 7 | 5250 |
| 1000 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 14.1 (244) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 4.1 (65) · +42 % | 11.6 (183) · +65 % | 21.2 (304) · +51 % | 0 % | 6 | 6000 |
| 1250 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 14.1 (244) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 3.3 (59) · +13 % | 11.5 (184) · +63 % | 22.2 (339) · +58 % | 0 % | 5 | 6250 |
| 1500 | pametno | 2.9 (51) · +0 % | 7.1 (130) · +0 % | 14.1 (244) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 3.5 (59) · +19 % | 10.5 (182) · +49 % | 20.1 (316) · +43 % | 0 % | 3 | 4500 |

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
| Sir Pip | 3000 | 2.2 (36) |
| Moonlit Warren | 10000 | 6.7 (99) |
| Coral Tide Garden | 10000 | 6.7 (99) |
| Starfall Glade | 10000 | 6.7 (99) |
| Loot Burst (1×) | 1000 | 0.8 (12) |

### D2. Normalna igra — rush + Merge Hint čim ga može platiti; teme i Sir Pip poslije besplatnih sezona

Kašnjenje = koliko kasnije se otključa besplatna sezona nego u čistom rushu (isti seedovi).

| Milestone | Dan (runova) | rush dan | Kašnjenje |
|---|---|---|---|
| kupljeno: Merge Hint (1500) | 1.2 (18) | — | — |
| frost_orchard otključan | 2.8 (39) | 2.2 | +0.6 dana (+27 %) |
| lantern_meadow otključan | 6.0 (80) | 4.4 | +1.6 dana (+36 %) |
| amber_canopy otključan | 11.3 (137) | 9.5 | +1.8 dana (+18 %) |
| kupljeno: Sir Pip (3000) | 27.6 (272) | — | — |
| kupljeno: Moonlit Warren (10000) | 31.8 (298) | — | — |
| kupljeno: Coral Tide Garden (10000) | 36.1 (321) | — | — |
| kupljeno: Starfall Glade (10000) | 40.4 (350) | — | — |

### D3. Loot Burst za coine — koliko ranije se otključaju besplatne sezone

+5 ★3 cvijeta sezone koja otključava sljedeću besplatnu. pametno = kupi samo kad coini za sezonu već postoje (fali samo ★3); sve = kupi čim fali ★3. Ubrzanje = koliko ranije od rusha (medijan dana). Kriterij: najveće ubrzanje ≤ 10 % (average i casual).

| Cijena | Način | frost_orchard | lantern_meadow | amber_canopy | Najveće ubrzanje | Burstova | Coina u Burst |
|---|---|---|---|---|---|---|---|
| — | rush | 2.2 (36) | 4.4 (66) | 9.5 (120) | — | 0 | 0 |
| 500 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 500 | sve | 2.2 (36) · +0 % | 7.0 (91) · +59 % | 13.9 (161) · +45 % | 0 % | 8 | 4000 |
| 750 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 750 | sve | 2.8 (39) · +27 % | 7.5 (92) · +70 % | 15.2 (166) · +60 % | 0 % | 7 | 5250 |
| 1000 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1000 | sve | 3.1 (42) · +45 % | 8.7 (103) · +97 % | 16.4 (179) · +72 % | 0 % | 6 | 6000 |
| 1250 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1250 | sve | 3.7 (47) · +70 % | 9.5 (110) · +115 % | 16.7 (188) · +76 % | 0 % | 5 | 6250 |
| 1500 | pametno | 2.2 (36) · +0 % | 4.4 (66) · +0 % | 9.5 (120) · +0 % | 0 % | 0 | 0 |
| 1500 | sve | 2.8 (39) · +27 % | 7.5 (92) · +70 % | 14.7 (166) · +54 % | 0 % | 3 | 4500 |

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
- season_pack_moonlit_warren: 10000 C
- season_pack_coral_tide: 10000 C
- season_pack_starfall_glade: 10000 C
- season_pack_ember_fen: 10000 C
- pip_knight: 3000 C
