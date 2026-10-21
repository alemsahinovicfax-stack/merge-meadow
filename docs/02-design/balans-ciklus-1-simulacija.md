---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ekonomija, balans, simulacija]
povezano:
  - balans-ciklus-1-izvjestaj
  - ekonomija-brojevi
ai_sažetak: "Sirovi izlaz economy_sim.gd za balans ciklus 1 (2026-10-21): PRIJE (stara pravila, HEAD 905c220) i POSLIJE — leveli 1–20 i Endless po profilu, vrijednost nadogradnji, put kroz 4 besplatne sezone (3 profila × 3 politike, 20 putovanja), cijene."
---

# Balans ciklus 1 — simulacija (sirovi izlaz)

> Generisano: `godot --headless --path game -s res://scripts/dev/economy_sim.gd -- --out=... --runs=400 --reps=20`. Sažetak i odluke: [[balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]]. Model igrača je pretpostavka (vidi izvještaj § Model).

- [POSLIJE (nova pravila)](#poslije)
- [PRIJE (stara pravila)](#prije)

## POSLIJE


Pravila: Endless rampa po stepenicama, plijen u Endlessu ostaje cijeli, sjeme po rijetkosti. Model: casual skuplja 55 %, rizik 1.00 % po prepreci; average skuplja 70 %, rizik 0.50 % po prepreci; skilled skuplja 85 %, rizik 0.25 % po prepreci.

### A. Leveli 1–20 i Endless (sezona sa svih 6 tipova, bez nadogradnji)

#### Profil: casual

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 98 | 16 | 5.5 | 19 | 3.4 | 16.2 | 5.5 | 1.6 | 1.02 | 1.4 |
| 2 | 64 | 98 | 18 | 6.3 | 20 | 3.8 | 16.3 | 5.9 | 2.0 | 1.03 | 1.4 |
| 3 | 66 | 97 | 17 | 6.3 | 21 | 3.8 | 15.7 | 5.7 | 2.3 | 1.03 | 1.5 |
| 4 | 70 | 97 | 19 | 6.5 | 22 | 3.9 | 16.1 | 5.5 | 2.6 | 1.03 | 1.5 |
| 5 | 72 | 95 | 20 | 6.9 | 22 | 3.5 | 16.3 | 5.7 | 3.0 | 1.05 | 1.6 |
| 6 | 76 | 96 | 21 | 7.6 | 23 | 4.4 | 16.3 | 5.9 | 3.6 | 1.04 | 1.6 |
| 7 | 78 | 93 | 21 | 8.0 | 24 | 4.7 | 16.0 | 6.1 | 4.3 | 1.07 | 1.7 |
| 8 | 82 | 88 | 23 | 8.1 | 22 | 4.6 | 16.4 | 5.8 | 4.9 | 1.13 | 1.8 |
| 9 | 86 | 88 | 24 | 8.8 | 23 | 4.5 | 16.0 | 6.0 | 5.6 | 1.13 | 1.9 |
| 10 | 88 | 86 | 24 | 8.9 | 24 | 4.8 | 15.9 | 5.9 | 6.5 | 1.16 | 2.0 |
| 11 | 92 | 85 | 26 | 9.7 | 25 | 5.0 | 16.0 | 6.2 | 7.4 | 1.17 | 2.1 |
| 12 | 94 | 78 | 26 | 10.3 | 23 | 5.3 | 15.2 | 6.2 | 8.7 | 1.29 | 2.2 |
| 13 | 98 | 76 | 28 | 10.7 | 24 | 5.7 | 15.7 | 6.2 | 9.5 | 1.32 | 2.3 |
| 14 | 102 | 69 | 28 | 11.3 | 26 | 6.0 | 15.1 | 6.1 | 11.1 | 1.46 | 2.6 |
| 15 | 104 | 62 | 30 | 11.5 | 24 | 5.2 | 15.4 | 6.1 | 12.2 | 1.61 | 2.8 |
| 16 | 108 | 62 | 31 | 11.9 | 25 | 7.0 | 15.0 | 6.1 | 13.7 | 1.62 | 2.9 |
| 17 | 110 | 59 | 31 | 12.6 | 27 | 6.5 | 14.6 | 6.3 | 14.8 | 1.69 | 3.0 |
| 18 | 114 | 53 | 33 | 13.3 | 27 | 7.3 | 14.5 | 6.2 | 16.5 | 1.89 | 3.4 |
| 19 | 116 | 41 | 34 | 13.1 | 27 | 6.3 | 13.6 | 5.8 | 18.5 | 2.42 | 4.1 |
| 20 | 120 | 39 | 33 | 14.1 | 28 | 7.2 | 13.1 | 5.9 | 20.9 | 2.58 | 4.3 |
| Endless | med 197 · p90 316 | — | 58 | 20.7 | 25 | 5.3 | 17.2 | 6.2 | 11.3 | — | — |

#### Profil: average

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 100 | 21 | 7.1 | 21 | 3.3 | 20.7 | 7.1 | 1.6 | 1.00 | 1.3 |
| 2 | 64 | 99 | 22 | 7.6 | 21 | 3.1 | 20.9 | 7.1 | 2.0 | 1.01 | 1.4 |
| 3 | 66 | 99 | 23 | 7.7 | 22 | 3.3 | 20.4 | 7.0 | 2.3 | 1.01 | 1.4 |
| 4 | 70 | 99 | 23 | 8.5 | 22 | 3.8 | 20.0 | 7.3 | 2.5 | 1.01 | 1.5 |
| 5 | 72 | 98 | 25 | 8.9 | 22 | 3.4 | 20.8 | 7.4 | 3.1 | 1.02 | 1.6 |
| 6 | 76 | 98 | 26 | 9.5 | 22 | 3.7 | 20.5 | 7.5 | 3.6 | 1.02 | 1.6 |
| 7 | 78 | 96 | 28 | 9.9 | 21 | 4.9 | 21.0 | 7.5 | 4.2 | 1.04 | 1.7 |
| 8 | 82 | 97 | 29 | 10.7 | 23 | 4.3 | 21.2 | 7.8 | 5.0 | 1.03 | 1.7 |
| 9 | 86 | 95 | 30 | 11.4 | 22 | 5.1 | 20.6 | 7.9 | 5.6 | 1.06 | 1.8 |
| 10 | 88 | 94 | 31 | 11.3 | 24 | 5.4 | 20.7 | 7.6 | 6.5 | 1.06 | 1.9 |
| 11 | 92 | 91 | 33 | 12.2 | 24 | 4.3 | 20.9 | 7.8 | 7.5 | 1.10 | 2.0 |
| 12 | 94 | 89 | 34 | 12.8 | 24 | 5.5 | 20.8 | 8.0 | 8.7 | 1.12 | 2.0 |
| 13 | 98 | 89 | 35 | 13.4 | 26 | 5.1 | 20.5 | 8.0 | 9.5 | 1.13 | 2.1 |
| 14 | 102 | 82 | 36 | 14.4 | 25 | 4.9 | 20.2 | 8.2 | 10.8 | 1.22 | 2.3 |
| 15 | 104 | 81 | 37 | 14.2 | 24 | 6.1 | 20.5 | 7.9 | 12.2 | 1.23 | 2.3 |
| 16 | 108 | 79 | 38 | 15.2 | 26 | 5.7 | 19.6 | 8.0 | 13.8 | 1.27 | 2.5 |
| 17 | 110 | 74 | 39 | 15.8 | 26 | 6.4 | 19.9 | 8.1 | 15.3 | 1.36 | 2.6 |
| 18 | 114 | 67 | 41 | 16.3 | 26 | 6.6 | 19.4 | 7.9 | 16.7 | 1.49 | 2.9 |
| 19 | 116 | 67 | 41 | 16.3 | 26 | 7.4 | 19.1 | 7.8 | 19.0 | 1.50 | 2.9 |
| 20 | 120 | 61 | 42 | 17.5 | 28 | 7.9 | 18.2 | 7.9 | 20.6 | 1.63 | 3.2 |
| Endless | med 265 · p90 411 | — | 95 | 35.6 | 26 | 6.4 | 21.5 | 8.0 | 14.6 | — | — |

#### Profil: skilled

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 100 | 25 | 8.6 | 21 | 2.5 | 25.2 | 8.6 | 1.7 | 1.01 | 1.3 |
| 2 | 64 | 99 | 27 | 9.4 | 20 | 3.2 | 25.4 | 8.8 | 1.9 | 1.01 | 1.4 |
| 3 | 66 | 100 | 28 | 9.4 | 22 | 3.7 | 25.3 | 8.5 | 2.2 | 1.01 | 1.4 |
| 4 | 70 | 100 | 29 | 10.1 | 22 | 3.8 | 24.9 | 8.6 | 2.5 | 1.01 | 1.5 |
| 5 | 72 | 99 | 31 | 10.7 | 22 | 4.0 | 25.4 | 8.9 | 3.2 | 1.01 | 1.5 |
| 6 | 76 | 98 | 33 | 11.3 | 21 | 4.8 | 25.5 | 8.9 | 3.7 | 1.02 | 1.6 |
| 7 | 78 | 98 | 33 | 12.0 | 22 | 3.9 | 25.5 | 9.2 | 4.2 | 1.02 | 1.7 |
| 8 | 82 | 97 | 36 | 12.8 | 23 | 4.7 | 26.1 | 9.3 | 5.0 | 1.03 | 1.7 |
| 9 | 86 | 97 | 37 | 13.6 | 23 | 4.8 | 25.8 | 9.4 | 5.8 | 1.03 | 1.8 |
| 10 | 88 | 96 | 37 | 13.9 | 23 | 5.4 | 25.0 | 9.4 | 6.5 | 1.04 | 1.8 |
| 11 | 92 | 93 | 40 | 14.9 | 24 | 5.2 | 25.2 | 9.6 | 7.4 | 1.08 | 2.0 |
| 12 | 94 | 96 | 41 | 15.4 | 24 | 5.0 | 25.7 | 9.7 | 8.7 | 1.04 | 1.9 |
| 13 | 98 | 95 | 42 | 16.4 | 25 | 6.0 | 25.2 | 9.9 | 9.7 | 1.06 | 2.0 |
| 14 | 102 | 92 | 44 | 17.1 | 25 | 5.2 | 25.5 | 9.9 | 10.8 | 1.09 | 2.1 |
| 15 | 104 | 93 | 46 | 17.3 | 26 | 5.4 | 26.0 | 9.9 | 12.1 | 1.08 | 2.2 |
| 16 | 108 | 88 | 47 | 18.5 | 24 | 6.8 | 25.3 | 10.0 | 13.7 | 1.14 | 2.3 |
| 17 | 110 | 87 | 47 | 18.7 | 25 | 6.0 | 25.0 | 9.9 | 15.1 | 1.16 | 2.4 |
| 18 | 114 | 85 | 50 | 19.7 | 26 | 6.0 | 25.3 | 10.1 | 17.0 | 1.17 | 2.4 |
| 19 | 116 | 80 | 50 | 20.9 | 27 | 6.7 | 24.5 | 10.3 | 18.5 | 1.25 | 2.6 |
| 20 | 120 | 74 | 51 | 20.8 | 28 | 7.1 | 23.5 | 9.8 | 21.2 | 1.35 | 2.8 |
| Endless | med 328 · p90 542 | — | 148 | 56.2 | 25 | 7.6 | 25.6 | 9.7 | 18.2 | — | — |

### A2. Vrijednost nadogradnji (average, level 20 i Endless)

| Nadogradnje | L20 coina / min | L20 sjem. / min | Endless coina / min | Endless sjem. / min |
|---|---|---|---|---|
| bez nadogradnji | 18.3 | 8.0 | 21.3 | 7.9 |
| Magnet max | 24.5 | 11.0 | 28.4 | 11.1 |
| Twin Seeds max | 18.8 | 9.9 | 21.2 | 10.0 |
| Loot Boost max | 37.2 | 15.2 | 42.9 | 15.9 |
| sve tri max | 50.8 | 27.9 | 56.8 | 28.1 |

### B. Put igrača kroz 4 besplatne sezone (medijan · p10–p90, 20 putovanja)

Dan = 25 min igre. rush štedi za sljedeću sezonu; boost kupuje nadogradnje čim može; looks prvo kupuje izgled iz Shopa (pa sezonu, pa nadogradnje).

#### casual · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.3 | 33 (28–40) | 19 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 16 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.2 | 29 (27–32) | 17 | 20 / 20 |
| country_bloom level 20 pređen | 1.9 | 47 (42–57) | 27 | 20 / 20 |
| country_bloom Endless otključan | 1.2 | 29 (27–32) | 17 | 20 / 20 |
| country_bloom prva nadogradnja | 12.1 | 302 (293–358) | 126 | 20 / 20 |
| country_bloom nadogradnje max | 34.0 | 850 (787–878) | 269 | 20 / 20 |
| frost_orchard otključan | 1.9 | 47 (43–58) | 27 | 20 / 20 |
| frost_orchard level 5 pređen | 2.2 | 55 (51–65) | 32 | 20 / 20 |
| frost_orchard level 10 pređen | 2.6 | 65 (59–74) | 37 | 20 / 20 |
| frost_orchard level 15 pređen | 3.0 | 76 (72–84) | 44 | 20 / 20 |
| frost_orchard level 20 pređen | 3.8 | 95 (86–104) | 55 | 20 / 20 |
| frost_orchard Endless otključan | 3.0 | 76 (72–84) | 44 | 20 / 20 |
| frost_orchard prva nadogradnja | 14.0 | 349 (299–379) | 148 | 20 / 20 |
| frost_orchard nadogradnje max | 35.1 | 879 (806–895) | 274 | 20 / 20 |
| lantern_meadow otključan | 4.9 | 123 (117–130) | 61 | 20 / 20 |
| lantern_meadow level 5 pređen | 5.2 | 130 (124–137) | 66 | 20 / 20 |
| lantern_meadow level 10 pređen | 5.6 | 139 (133–148) | 71 | 20 / 20 |
| lantern_meadow level 15 pređen | 6.1 | 152 (145–160) | 78 | 20 / 20 |
| lantern_meadow level 20 pređen | 6.7 | 168 (160–182) | 88 | 20 / 20 |
| lantern_meadow Endless otključan | 6.1 | 152 (145–160) | 78 | 20 / 20 |
| lantern_meadow prva nadogradnja | 11.8 | 295 (288–308) | 124 | 20 / 20 |
| lantern_meadow nadogradnje max | 35.6 | 890 (819–920) | 277 | 20 / 20 |
| amber_canopy otključan | 11.5 | 288 (283–301) | 119 | 20 / 20 |
| amber_canopy level 5 pređen | 11.8 | 296 (290–308) | 124 | 20 / 20 |
| amber_canopy level 10 pređen | 12.2 | 305 (299–317) | 131 | 20 / 20 |
| amber_canopy level 15 pređen | 12.7 | 318 (310–330) | 137 | 20 / 20 |
| amber_canopy level 20 pređen | 13.6 | 341 (329–347) | 148 | 20 / 20 |
| amber_canopy Endless otključan | 12.7 | 318 (310–330) | 137 | 20 / 20 |
| amber_canopy prva nadogradnja | 11.8 | 296 (290–308) | 124 | 20 / 20 |
| amber_canopy nadogradnje max | 36.2 | 905 (835–930) | 279 | 20 / 20 |
| izgled journal_gold (800) | 13.8 | 344 (317–410) | 148 | 20 / 20 |
| izgled meadow_sunset (1000) | 17.0 | 424 (407–456) | 168 | 20 / 20 |
| izgled meadow_lavender (1200) | 19.1 | 477 (453–511) | 181 | 20 / 20 |
| izgled pip_sky (2000) | 23.0 | 576 (542–626) | 205 | 20 / 20 |
| izgled pip_blossom (2500) | 28.9 | 721 (664–877) | 242 | 20 / 20 |
| sve besplatne nadogradnje max | 36.2 | 905 (835–930) | 280 | 20 / 20 |
| svi izgledi za coine | 28.9 | 721 (664–877) | 242 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 533 · coin: dnevni poklon 2666 · coin: prodaja cvijeća 11355 · coin: run 17995 · sjeme ★1 5247 · sjeme ★2 1859 · sjeme ★3 452 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 117 · ★3 cvijet: u nadogradnje 120

#### casual · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.4 | 34 (27–42) | 19 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (16–20) | 11 | 20 / 20 |
| country_bloom level 15 pređen | 1.2 | 30 (27–34) | 18 | 20 / 20 |
| country_bloom level 20 pređen | 1.9 | 48 (43–55) | 28 | 20 / 20 |
| country_bloom Endless otključan | 1.2 | 30 (27–34) | 18 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 3.3 | 82 (76–97) | 38 | 20 / 20 |
| frost_orchard otključan | 6.0 | 151 (145–179) | 54 | 20 / 20 |
| frost_orchard level 5 pređen | 6.3 | 159 (153–186) | 59 | 20 / 20 |
| frost_orchard level 10 pređen | 6.7 | 168 (162–195) | 65 | 20 / 20 |
| frost_orchard level 15 pređen | 7.3 | 182 (174–205) | 71 | 20 / 20 |
| frost_orchard level 20 pređen | 8.1 | 203 (189–228) | 78 | 20 / 20 |
| frost_orchard Endless otključan | 7.3 | 182 (174–205) | 71 | 20 / 20 |
| frost_orchard prva nadogradnja | 6.3 | 159 (153–186) | 59 | 20 / 20 |
| frost_orchard nadogradnje max | 8.8 | 220 (210–258) | 84 | 20 / 20 |
| lantern_meadow otključan | 12.6 | 314 (283–360) | 105 | 20 / 20 |
| lantern_meadow level 5 pređen | 12.9 | 322 (290–368) | 110 | 20 / 20 |
| lantern_meadow level 10 pređen | 13.2 | 330 (299–377) | 115 | 20 / 20 |
| lantern_meadow level 15 pređen | 13.7 | 343 (310–392) | 123 | 20 / 20 |
| lantern_meadow level 20 pređen | 14.5 | 362 (331–415) | 131 | 20 / 20 |
| lantern_meadow Endless otključan | 13.7 | 343 (310–392) | 123 | 20 / 20 |
| lantern_meadow prva nadogradnja | 12.9 | 322 (290–368) | 110 | 20 / 20 |
| lantern_meadow nadogradnje max | 15.5 | 387 (346–434) | 139 | 20 / 20 |
| amber_canopy otključan | 20.1 | 504 (447–540) | 161 | 20 / 20 |
| amber_canopy level 5 pređen | 20.4 | 511 (455–547) | 166 | 20 / 20 |
| amber_canopy level 10 pređen | 20.8 | 521 (464–556) | 171 | 20 / 20 |
| amber_canopy level 15 pređen | 21.3 | 531 (476–570) | 177 | 20 / 20 |
| amber_canopy level 20 pređen | 22.1 | 552 (490–596) | 189 | 20 / 20 |
| amber_canopy Endless otključan | 21.3 | 531 (476–570) | 177 | 20 / 20 |
| amber_canopy prva nadogradnja | 20.4 | 511 (455–548) | 166 | 20 / 20 |
| amber_canopy nadogradnje max | 23.2 | 581 (522–623) | 199 | 20 / 20 |
| izgled journal_gold (800) | 5.1 | 129 (121–132) | 46 | 20 / 20 |
| izgled meadow_sunset (1000) | 5.7 | 143 (137–286) | 51 | 20 / 20 |
| izgled meadow_lavender (1200) | 11.7 | 293 (157–474) | 98 | 20 / 20 |
| izgled pip_sky (2000) | 19.5 | 488 (320–561) | 160 | 20 / 20 |
| izgled pip_blossom (2500) | 23.1 | 578 (518–607) | 188 | 20 / 20 |
| sve besplatne nadogradnje max | 23.2 | 581 (522–623) | 199 | 20 / 20 |
| svi izgledi za coine | 23.1 | 578 (518–607) | 188 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 351 · coin: dnevni poklon 1755 · coin: prodaja cvijeća 12780 · coin: run 17558 · sjeme ★1 5925 · sjeme ★2 2057 · sjeme ★3 494 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 126 · ★3 cvijet: u nadogradnje 120

#### casual · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.3 | 32 (29–48) | 19 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 16 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 29 (27–32) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.9 | 48 (44–53) | 28 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 29 (27–32) | 16 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 4.7 | 118 (115–123) | 44 | 20 / 20 |
| frost_orchard otključan | 9.3 | 234 (230–240) | 68 | 20 / 20 |
| frost_orchard level 5 pređen | 9.7 | 242 (237–248) | 73 | 20 / 20 |
| frost_orchard level 10 pređen | 10.1 | 252 (247–258) | 79 | 20 / 20 |
| frost_orchard level 15 pređen | 10.6 | 264 (258–272) | 86 | 20 / 20 |
| frost_orchard level 20 pređen | 11.3 | 283 (277–291) | 95 | 20 / 20 |
| frost_orchard Endless otključan | 10.6 | 264 (258–272) | 86 | 20 / 20 |
| frost_orchard prva nadogradnja | 9.7 | 242 (237–248) | 73 | 20 / 20 |
| frost_orchard nadogradnje max | 12.5 | 312 (297–331) | 102 | 20 / 20 |
| lantern_meadow otključan | 16.2 | 404 (380–430) | 124 | 20 / 20 |
| lantern_meadow level 5 pređen | 16.5 | 411 (388–437) | 129 | 20 / 20 |
| lantern_meadow level 10 pređen | 16.8 | 420 (397–446) | 135 | 20 / 20 |
| lantern_meadow level 15 pređen | 17.2 | 430 (407–458) | 140 | 20 / 20 |
| lantern_meadow level 20 pređen | 18.0 | 449 (423–472) | 152 | 20 / 20 |
| lantern_meadow Endless otključan | 17.2 | 430 (407–458) | 140 | 20 / 20 |
| lantern_meadow prva nadogradnja | 16.5 | 411 (388–437) | 129 | 20 / 20 |
| lantern_meadow nadogradnje max | 18.9 | 472 (444–494) | 155 | 20 / 20 |
| amber_canopy otključan | 22.8 | 571 (536–630) | 177 | 20 / 20 |
| amber_canopy level 5 pređen | 23.1 | 578 (545–639) | 182 | 20 / 20 |
| amber_canopy level 10 pređen | 23.5 | 587 (554–648) | 188 | 20 / 20 |
| amber_canopy level 15 pređen | 24.0 | 600 (565–663) | 195 | 20 / 20 |
| amber_canopy level 20 pređen | 24.7 | 618 (584–683) | 204 | 20 / 20 |
| amber_canopy Endless otključan | 24.0 | 600 (565–663) | 195 | 20 / 20 |
| amber_canopy prva nadogradnja | 23.1 | 578 (545–639) | 182 | 20 / 20 |
| amber_canopy nadogradnje max | 25.7 | 643 (606–695) | 210 | 20 / 20 |
| izgled journal_gold (800) | 0.7 | 17 (16–27) | 11 | 20 / 20 |
| izgled meadow_sunset (1000) | 1.9 | 48 (45–53) | 28 | 20 / 20 |
| izgled meadow_lavender (1200) | 5.4 | 136 (129–139) | 48 | 20 / 20 |
| izgled pip_sky (2000) | 6.6 | 164 (161–169) | 53 | 20 / 20 |
| izgled pip_blossom (2500) | 8.0 | 199 (195–204) | 61 | 20 / 20 |
| sve besplatne nadogradnje max | 25.7 | 643 (606–695) | 210 | 20 / 20 |
| svi izgledi za coine | 8.0 | 199 (195–204) | 61 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 378 · coin: dnevni poklon 1890 · coin: prodaja cvijeća 14017 · coin: run 18990 · sjeme ★1 6301 · sjeme ★2 2255 · sjeme ★3 538 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 139 · ★3 cvijet: u nadogradnje 120

#### average · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.1 | 27 (22–33) | 16 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 16 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 29 (27–33) | 17 | 20 / 20 |
| country_bloom level 20 pređen | 1.7 | 43 (40–50) | 23 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 29 (27–33) | 17 | 20 / 20 |
| country_bloom prva nadogradnja | 10.0 | 250 (103–295) | 100 | 20 / 20 |
| country_bloom nadogradnje max | 26.3 | 659 (649–677) | 188 | 20 / 20 |
| frost_orchard otključan | 1.7 | 43 (41–50) | 23 | 20 / 20 |
| frost_orchard level 5 pređen | 2.0 | 51 (48–57) | 28 | 20 / 20 |
| frost_orchard level 10 pređen | 2.4 | 60 (57–66) | 34 | 20 / 20 |
| frost_orchard level 15 pređen | 2.8 | 71 (67–80) | 39 | 20 / 20 |
| frost_orchard level 20 pređen | 3.5 | 87 (81–98) | 47 | 20 / 20 |
| frost_orchard Endless otključan | 2.8 | 71 (67–80) | 39 | 20 / 20 |
| frost_orchard prva nadogradnja | 11.7 | 292 (247–316) | 118 | 20 / 20 |
| frost_orchard nadogradnje max | 26.9 | 672 (656–690) | 190 | 20 / 20 |
| lantern_meadow otključan | 4.0 | 99 (97–109) | 50 | 20 / 20 |
| lantern_meadow level 5 pređen | 4.3 | 107 (105–117) | 55 | 20 / 20 |
| lantern_meadow level 10 pređen | 4.7 | 117 (114–126) | 60 | 20 / 20 |
| lantern_meadow level 15 pređen | 5.1 | 128 (125–139) | 67 | 20 / 20 |
| lantern_meadow level 20 pređen | 5.8 | 144 (139–155) | 74 | 20 / 20 |
| lantern_meadow Endless otključan | 5.1 | 128 (125–139) | 67 | 20 / 20 |
| lantern_meadow prva nadogradnja | 9.6 | 240 (236–249) | 95 | 20 / 20 |
| lantern_meadow nadogradnje max | 27.2 | 680 (660–703) | 192 | 20 / 20 |
| amber_canopy otključan | 9.5 | 237 (232–242) | 92 | 20 / 20 |
| amber_canopy level 5 pređen | 9.8 | 245 (240–249) | 97 | 20 / 20 |
| amber_canopy level 10 pređen | 10.2 | 254 (248–258) | 102 | 20 / 20 |
| amber_canopy level 15 pređen | 10.6 | 264 (260–274) | 108 | 20 / 20 |
| amber_canopy level 20 pređen | 11.2 | 281 (275–294) | 117 | 20 / 20 |
| amber_canopy Endless otključan | 10.6 | 264 (260–274) | 108 | 20 / 20 |
| amber_canopy prva nadogradnja | 9.8 | 245 (240–249) | 97 | 20 / 20 |
| amber_canopy nadogradnje max | 27.7 | 692 (677–714) | 195 | 20 / 20 |
| izgled journal_gold (800) | 11.0 | 276 (259–337) | 115 | 20 / 20 |
| izgled meadow_sunset (1000) | 14.4 | 359 (333–397) | 131 | 20 / 20 |
| izgled meadow_lavender (1200) | 16.2 | 405 (378–446) | 140 | 20 / 20 |
| izgled pip_sky (2000) | 20.4 | 509 (477–529) | 159 | 20 / 20 |
| izgled pip_blossom (2500) | 28.7 | 717 (705–728) | 199 | 20 / 20 |
| sve besplatne nadogradnje max | 27.7 | 693 (678–714) | 195 | 20 / 20 |
| svi izgledi za coine | 28.7 | 717 (705–728) | 199 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 422 · coin: dnevni poklon 2111 · coin: prodaja cvijeća 11574 · coin: run 18162 · sjeme ★1 5238 · sjeme ★2 1906 · sjeme ★3 487 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 125 · ★3 cvijet: u nadogradnje 120

#### average · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.1 | 27 (23–33) | 15 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 27 (27–30) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.7 | 42 (41–46) | 22 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 27 (27–30) | 15 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 2.8 | 70 (67–75) | 27 | 20 / 20 |
| frost_orchard otključan | 5.1 | 126 (117–147) | 37 | 20 / 20 |
| frost_orchard level 5 pređen | 5.4 | 134 (125–155) | 42 | 20 / 20 |
| frost_orchard level 10 pređen | 5.7 | 143 (134–164) | 48 | 20 / 20 |
| frost_orchard level 15 pređen | 6.1 | 154 (147–176) | 54 | 20 / 20 |
| frost_orchard level 20 pređen | 6.8 | 169 (160–194) | 60 | 20 / 20 |
| frost_orchard Endless otključan | 6.1 | 154 (147–176) | 54 | 20 / 20 |
| frost_orchard prva nadogradnja | 5.4 | 134 (125–155) | 42 | 20 / 20 |
| frost_orchard nadogradnje max | 7.4 | 185 (176–210) | 63 | 20 / 20 |
| lantern_meadow otključan | 10.4 | 259 (241–286) | 77 | 20 / 20 |
| lantern_meadow level 5 pređen | 10.7 | 267 (249–293) | 82 | 20 / 20 |
| lantern_meadow level 10 pređen | 11.0 | 276 (258–302) | 87 | 20 / 20 |
| lantern_meadow level 15 pređen | 11.5 | 287 (268–314) | 93 | 20 / 20 |
| lantern_meadow level 20 pređen | 12.1 | 302 (284–329) | 100 | 20 / 20 |
| lantern_meadow Endless otključan | 11.5 | 287 (268–314) | 93 | 20 / 20 |
| lantern_meadow prva nadogradnja | 10.7 | 267 (249–293) | 82 | 20 / 20 |
| lantern_meadow nadogradnje max | 12.6 | 316 (294–346) | 103 | 20 / 20 |
| amber_canopy otključan | 16.1 | 403 (383–433) | 117 | 20 / 20 |
| amber_canopy level 5 pređen | 16.5 | 412 (390–442) | 122 | 20 / 20 |
| amber_canopy level 10 pređen | 16.8 | 421 (400–451) | 127 | 20 / 20 |
| amber_canopy level 15 pređen | 17.3 | 432 (411–462) | 132 | 20 / 20 |
| amber_canopy level 20 pređen | 17.9 | 448 (431–478) | 141 | 20 / 20 |
| amber_canopy Endless otključan | 17.3 | 432 (411–462) | 132 | 20 / 20 |
| amber_canopy prva nadogradnja | 16.5 | 412 (390–442) | 122 | 20 / 20 |
| amber_canopy nadogradnje max | 19.1 | 479 (459–521) | 145 | 20 / 20 |
| izgled journal_gold (800) | 4.5 | 111 (107–229) | 35 | 20 / 20 |
| izgled meadow_sunset (1000) | 9.4 | 236 (123–386) | 70 | 20 / 20 |
| izgled meadow_lavender (1200) | 15.6 | 389 (140–407) | 111 | 20 / 20 |
| izgled pip_sky (2000) | 19.1 | 477 (288–490) | 142 | 20 / 20 |
| izgled pip_blossom (2500) | 20.5 | 513 (504–526) | 150 | 20 / 20 |
| sve besplatne nadogradnje max | 19.1 | 479 (459–521) | 145 | 20 / 20 |
| svi izgledi za coine | 20.5 | 513 (504–526) | 150 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 302 · coin: dnevni poklon 1508 · coin: prodaja cvijeća 12809 · coin: run 17678 · sjeme ★1 5748 · sjeme ★2 2100 · sjeme ★3 529 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 135 · ★3 cvijet: u nadogradnje 120

#### average · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.1 | 27 (24–31) | 15 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 7 (7–9) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 28 (27–30) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.7 | 43 (40–49) | 23 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 28 (27–30) | 16 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–9) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 4.6 | 114 (96–122) | 34 | 20 / 20 |
| frost_orchard otključan | 8.2 | 205 (200–213) | 52 | 20 / 20 |
| frost_orchard level 5 pređen | 8.5 | 212 (207–221) | 57 | 20 / 20 |
| frost_orchard level 10 pređen | 8.9 | 221 (217–230) | 62 | 20 / 20 |
| frost_orchard level 15 pređen | 9.3 | 233 (227–241) | 68 | 20 / 20 |
| frost_orchard level 20 pređen | 10.0 | 249 (244–257) | 74 | 20 / 20 |
| frost_orchard Endless otključan | 9.3 | 233 (227–241) | 68 | 20 / 20 |
| frost_orchard prva nadogradnja | 8.5 | 213 (207–221) | 57 | 20 / 20 |
| frost_orchard nadogradnje max | 10.4 | 261 (255–278) | 77 | 20 / 20 |
| lantern_meadow otključan | 13.5 | 337 (320–364) | 90 | 20 / 20 |
| lantern_meadow level 5 pređen | 13.8 | 345 (328–371) | 95 | 20 / 20 |
| lantern_meadow level 10 pređen | 14.2 | 354 (337–380) | 100 | 20 / 20 |
| lantern_meadow level 15 pređen | 14.7 | 366 (349–391) | 105 | 20 / 20 |
| lantern_meadow level 20 pređen | 15.3 | 383 (366–405) | 113 | 20 / 20 |
| lantern_meadow Endless otključan | 14.7 | 366 (349–391) | 105 | 20 / 20 |
| lantern_meadow prva nadogradnja | 13.8 | 345 (328–371) | 95 | 20 / 20 |
| lantern_meadow nadogradnje max | 15.6 | 390 (379–418) | 115 | 20 / 20 |
| amber_canopy otključan | 19.2 | 480 (458–505) | 130 | 20 / 20 |
| amber_canopy level 5 pređen | 19.5 | 487 (466–513) | 135 | 20 / 20 |
| amber_canopy level 10 pređen | 19.9 | 496 (475–522) | 140 | 20 / 20 |
| amber_canopy level 15 pređen | 20.4 | 511 (486–532) | 146 | 20 / 20 |
| amber_canopy level 20 pređen | 21.0 | 525 (504–547) | 153 | 20 / 20 |
| amber_canopy Endless otključan | 20.4 | 511 (486–532) | 146 | 20 / 20 |
| amber_canopy prva nadogradnja | 19.5 | 487 (466–513) | 135 | 20 / 20 |
| amber_canopy nadogradnje max | 21.7 | 542 (516–572) | 156 | 20 / 20 |
| izgled journal_gold (800) | 0.7 | 17 (16–18) | 10 | 20 / 20 |
| izgled meadow_sunset (1000) | 1.7 | 42 (29–49) | 22 | 20 / 20 |
| izgled meadow_lavender (1200) | 4.2 | 105 (43–119) | 34 | 20 / 20 |
| izgled pip_sky (2000) | 5.7 | 143 (136–149) | 41 | 20 / 20 |
| izgled pip_blossom (2500) | 7.0 | 174 (170–180) | 47 | 20 / 20 |
| sve besplatne nadogradnje max | 21.7 | 542 (516–572) | 156 | 20 / 20 |
| svi izgledi za coine | 7.0 | 174 (170–180) | 47 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 317 · coin: dnevni poklon 1586 · coin: prodaja cvijeća 13518 · coin: run 18541 · sjeme ★1 6026 · sjeme ★2 2207 · sjeme ★3 544 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 138 · ★3 cvijet: u nadogradnje 120

#### skilled · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 0.9 | 24 (18–32) | 14 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 8 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (16–18) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 28 (27–30) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.6 | 41 (39–44) | 21 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 28 (27–30) | 16 | 20 / 20 |
| country_bloom prva nadogradnja | 8.3 | 208 (87–250) | 80 | 20 / 20 |
| country_bloom nadogradnje max | 22.3 | 557 (516–588) | 141 | 20 / 20 |
| frost_orchard otključan | 1.7 | 41 (40–44) | 21 | 20 / 20 |
| frost_orchard level 5 pređen | 2.0 | 49 (47–51) | 27 | 20 / 20 |
| frost_orchard level 10 pređen | 2.3 | 58 (56–61) | 32 | 20 / 20 |
| frost_orchard level 15 pređen | 2.7 | 69 (67–72) | 37 | 20 / 20 |
| frost_orchard level 20 pređen | 3.3 | 83 (80–87) | 43 | 20 / 20 |
| frost_orchard Endless otključan | 2.7 | 69 (67–72) | 37 | 20 / 20 |
| frost_orchard prva nadogradnja | 10.3 | 258 (217–274) | 100 | 20 / 20 |
| frost_orchard nadogradnje max | 22.6 | 564 (508–593) | 143 | 20 / 20 |
| lantern_meadow otključan | 3.4 | 86 (83–100) | 44 | 20 / 20 |
| lantern_meadow level 5 pređen | 3.7 | 93 (90–107) | 49 | 20 / 20 |
| lantern_meadow level 10 pređen | 4.1 | 102 (99–116) | 54 | 20 / 20 |
| lantern_meadow level 15 pređen | 4.5 | 113 (110–127) | 59 | 20 / 20 |
| lantern_meadow level 20 pređen | 5.1 | 127 (123–141) | 66 | 20 / 20 |
| lantern_meadow Endless otključan | 4.5 | 113 (110–127) | 59 | 20 / 20 |
| lantern_meadow prva nadogradnja | 8.2 | 204 (201–211) | 78 | 20 / 20 |
| lantern_meadow nadogradnje max | 22.7 | 567 (528–605) | 142 | 20 / 20 |
| amber_canopy otključan | 8.2 | 204 (200–211) | 77 | 20 / 20 |
| amber_canopy level 5 pređen | 8.5 | 212 (207–218) | 82 | 20 / 20 |
| amber_canopy level 10 pređen | 8.9 | 221 (217–227) | 88 | 20 / 20 |
| amber_canopy level 15 pređen | 9.3 | 232 (227–239) | 93 | 20 / 20 |
| amber_canopy level 20 pređen | 9.8 | 246 (241–253) | 99 | 20 / 20 |
| amber_canopy Endless otključan | 9.3 | 232 (227–239) | 93 | 20 / 20 |
| amber_canopy prva nadogradnja | 8.5 | 212 (207–218) | 82 | 20 / 20 |
| amber_canopy nadogradnje max | 22.2 | 555 (286–602) | 142 | 20 / 20 |
| izgled journal_gold (800) | 9.4 | 236 (221–326) | 98 | 20 / 20 |
| izgled meadow_sunset (1000) | 13.1 | 327 (294–382) | 111 | 20 / 20 |
| izgled meadow_lavender (1200) | 14.9 | 373 (345–534) | 118 | 20 / 20 |
| izgled pip_sky (2000) | 18.7 | 467 (429–576) | 132 | 20 / 20 |
| izgled pip_blossom (2500) | 24.2 | 606 (583–626) | 148 | 20 / 20 |
| sve besplatne nadogradnje max | 23.3 | 582 (549–605) | 145 | 20 / 20 |
| svi izgledi za coine | 24.2 | 606 (583–626) | 148 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 356 · coin: dnevni poklon 1781 · coin: prodaja cvijeća 12026 · coin: run 18387 · sjeme ★1 5295 · sjeme ★2 1988 · sjeme ★3 531 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 136 · ★3 cvijet: u nadogradnje 120

#### skilled · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 0.9 | 23 (19–31) | 13 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 8 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (17–17) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 28 (27–29) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.7 | 42 (40–44) | 21 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 28 (27–29) | 16 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 8 (8–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 2.5 | 63 (56–69) | 24 | 20 / 20 |
| frost_orchard otključan | 4.3 | 106 (100–134) | 30 | 20 / 20 |
| frost_orchard level 5 pređen | 4.6 | 115 (107–141) | 35 | 20 / 20 |
| frost_orchard level 10 pređen | 5.0 | 124 (117–150) | 40 | 20 / 20 |
| frost_orchard level 15 pređen | 5.4 | 135 (127–161) | 46 | 20 / 20 |
| frost_orchard level 20 pređen | 6.0 | 149 (140–177) | 52 | 20 / 20 |
| frost_orchard Endless otključan | 5.4 | 135 (127–161) | 46 | 20 / 20 |
| frost_orchard prva nadogradnja | 4.6 | 115 (108–141) | 35 | 20 / 20 |
| frost_orchard nadogradnje max | 6.2 | 156 (146–177) | 52 | 20 / 20 |
| lantern_meadow otključan | 8.5 | 211 (200–239) | 60 | 20 / 20 |
| lantern_meadow level 5 pređen | 8.8 | 220 (208–247) | 65 | 20 / 20 |
| lantern_meadow level 10 pređen | 9.1 | 229 (217–256) | 70 | 20 / 20 |
| lantern_meadow level 15 pređen | 9.6 | 240 (229–271) | 76 | 20 / 20 |
| lantern_meadow level 20 pređen | 10.1 | 254 (242–284) | 82 | 20 / 20 |
| lantern_meadow Endless otključan | 9.6 | 240 (229–271) | 76 | 20 / 20 |
| lantern_meadow prva nadogradnja | 8.8 | 220 (208–247) | 65 | 20 / 20 |
| lantern_meadow nadogradnje max | 10.8 | 270 (254–292) | 82 | 20 / 20 |
| amber_canopy otključan | 13.7 | 343 (322–365) | 93 | 20 / 20 |
| amber_canopy level 5 pređen | 14.0 | 351 (330–372) | 98 | 20 / 20 |
| amber_canopy level 10 pređen | 14.4 | 360 (339–383) | 103 | 20 / 20 |
| amber_canopy level 15 pređen | 14.8 | 371 (350–393) | 109 | 20 / 20 |
| amber_canopy level 20 pređen | 15.5 | 386 (368–410) | 115 | 20 / 20 |
| amber_canopy Endless otključan | 14.8 | 371 (350–393) | 109 | 20 / 20 |
| amber_canopy prva nadogradnja | 14.0 | 351 (330–372) | 98 | 20 / 20 |
| amber_canopy nadogradnje max | 16.4 | 410 (388–444) | 118 | 20 / 20 |
| izgled journal_gold (800) | 4.1 | 102 (96–333) | 31 | 20 / 20 |
| izgled meadow_sunset (1000) | 13.6 | 341 (110–361) | 94 | 20 / 20 |
| izgled meadow_lavender (1200) | 14.5 | 361 (228–415) | 103 | 20 / 20 |
| izgled pip_sky (2000) | 17.2 | 431 (381–439) | 119 | 20 / 20 |
| izgled pip_blossom (2500) | 18.4 | 459 (453–469) | 124 | 20 / 20 |
| sve besplatne nadogradnje max | 16.4 | 410 (388–444) | 118 | 20 / 20 |
| svi izgledi za coine | 18.4 | 459 (453–469) | 124 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 270 · coin: dnevni poklon 1350 · coin: prodaja cvijeća 13073 · coin: run 17814 · sjeme ★1 5676 · sjeme ★2 2146 · sjeme ★3 582 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 148 · ★3 cvijet: u nadogradnje 120

#### skilled · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 0.9 | 23 (21–30) | 13 | 20 / 20 |
| country_bloom level 5 pređen | 0.3 | 8 (7–8) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.7 | 17 (17–17) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 1.1 | 28 (27–30) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.6 | 41 (40–44) | 21 | 20 / 20 |
| country_bloom Endless otključan | 1.1 | 28 (27–30) | 15 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 8 (8–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 4.2 | 104 (103–109) | 30 | 20 / 20 |
| frost_orchard otključan | 7.5 | 187 (184–194) | 41 | 20 / 20 |
| frost_orchard level 5 pređen | 7.8 | 195 (191–201) | 46 | 20 / 20 |
| frost_orchard level 10 pređen | 8.2 | 204 (200–210) | 51 | 20 / 20 |
| frost_orchard level 15 pređen | 8.6 | 215 (211–221) | 56 | 20 / 20 |
| frost_orchard level 20 pređen | 9.1 | 229 (226–237) | 62 | 20 / 20 |
| frost_orchard Endless otključan | 8.6 | 215 (211–221) | 56 | 20 / 20 |
| frost_orchard prva nadogradnja | 7.8 | 195 (191–201) | 46 | 20 / 20 |
| frost_orchard nadogradnje max | 9.5 | 238 (229–251) | 64 | 20 / 20 |
| lantern_meadow otključan | 11.8 | 296 (283–318) | 71 | 20 / 20 |
| lantern_meadow level 5 pređen | 12.1 | 304 (290–326) | 76 | 20 / 20 |
| lantern_meadow level 10 pređen | 12.5 | 313 (299–336) | 81 | 20 / 20 |
| lantern_meadow level 15 pređen | 12.9 | 324 (311–348) | 87 | 20 / 20 |
| lantern_meadow level 20 pređen | 13.5 | 339 (326–361) | 92 | 20 / 20 |
| lantern_meadow Endless otključan | 12.9 | 324 (311–348) | 87 | 20 / 20 |
| lantern_meadow prva nadogradnja | 12.1 | 304 (290–326) | 76 | 20 / 20 |
| lantern_meadow nadogradnje max | 14.1 | 352 (339–371) | 95 | 20 / 20 |
| amber_canopy otključan | 17.1 | 429 (412–453) | 106 | 20 / 20 |
| amber_canopy level 5 pređen | 17.4 | 436 (420–460) | 111 | 20 / 20 |
| amber_canopy level 10 pređen | 17.8 | 445 (429–469) | 116 | 20 / 20 |
| amber_canopy level 15 pređen | 18.2 | 456 (439–480) | 121 | 20 / 20 |
| amber_canopy level 20 pređen | 18.7 | 469 (455–495) | 128 | 20 / 20 |
| amber_canopy Endless otključan | 18.2 | 456 (439–480) | 121 | 20 / 20 |
| amber_canopy prva nadogradnja | 17.4 | 436 (420–460) | 111 | 20 / 20 |
| amber_canopy nadogradnje max | 19.1 | 477 (463–505) | 129 | 20 / 20 |
| izgled journal_gold (800) | 0.7 | 17 (17–17) | 10 | 20 / 20 |
| izgled meadow_sunset (1000) | 1.1 | 28 (27–30) | 15 | 20 / 20 |
| izgled meadow_lavender (1200) | 1.7 | 42 (40–81) | 22 | 20 / 20 |
| izgled pip_sky (2000) | 5.1 | 128 (126–136) | 33 | 20 / 20 |
| izgled pip_blossom (2500) | 6.4 | 160 (154–166) | 37 | 20 / 20 |
| sve besplatne nadogradnje max | 19.1 | 477 (463–505) | 129 | 20 / 20 |
| svi izgledi za coine | 6.4 | 160 (154–166) | 37 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 279 · coin: dnevni poklon 1395 · coin: prodaja cvijeća 13310 · coin: run 18459 · sjeme ★1 5839 · sjeme ★2 2157 · sjeme ★3 582 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 148 · ★3 cvijet: u nadogradnje 120

### Cijene u igri (iz podataka)

- Sezone: frost_orchard 2500 C + 22 ★3, lantern_meadow 4500 C + 26 ★3, amber_canopy 6500 C + 30 ★3
- Nadogradnja po nivou (svaka od 3 staze, po sezoni): 100 C + 2 ★3 → 250 C + 2 ★3 → 500 C + 3 ★3 → 800 C + 3 ★3
- Izgledi za coine: journal_gold 800, meadow_sunset 1000, meadow_lavender 1200, pip_sky 2000, pip_blossom 2500
- Magnet radijus po nivou: 40, 95, 150, 205, 260
- Level Path nagrade: 5: 2 ★3 + 200 C, 10: 4 ★3 + 400 C, 15: 6 ★3 + 600 C, 20: 10 ★3 + 1000 C
- Dnevni poklon: 75 C + 5 sjemena

## PRIJE


Pravila: Endless s tajmerom (stari), plijen u Endlessu pola na padu (stari), sjeme ravnomjerno (stari). Model: casual skuplja 55 %, rizik 1.00 % po prepreci; average skuplja 70 %, rizik 0.50 % po prepreci; skilled skuplja 85 %, rizik 0.25 % po prepreci.

### A. Leveli 1–20 i Endless (sezona sa svih 6 tipova, bez nadogradnji)

#### Profil: casual

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 50 | 99 | 12 | 4.2 | 35 | 15.3 | 14.9 | 5.1 | 1.2 | 1.01 | 1.2 |
| 2 | 51 | 99 | 13 | 4.6 | 34 | 16.7 | 15.0 | 5.4 | 1.7 | 1.01 | 1.2 |
| 3 | 52 | 98 | 14 | 4.6 | 33 | 15.9 | 15.7 | 5.3 | 2.0 | 1.02 | 1.2 |
| 4 | 53 | 97 | 14 | 4.8 | 33 | 17.4 | 15.5 | 5.4 | 2.2 | 1.03 | 1.2 |
| 5 | 54 | 98 | 15 | 4.8 | 32 | 17.6 | 16.2 | 5.3 | 2.7 | 1.02 | 1.3 |
| 6 | 56 | 98 | 14 | 5.4 | 33 | 16.4 | 15.2 | 5.8 | 3.0 | 1.03 | 1.3 |
| 7 | 57 | 97 | 15 | 5.3 | 33 | 17.3 | 15.6 | 5.5 | 3.3 | 1.03 | 1.3 |
| 8 | 58 | 97 | 16 | 5.6 | 35 | 16.8 | 16.1 | 5.8 | 3.9 | 1.03 | 1.3 |
| 9 | 59 | 93 | 16 | 5.5 | 35 | 17.3 | 15.9 | 5.5 | 4.5 | 1.07 | 1.4 |
| 10 | 60 | 91 | 17 | 5.8 | 34 | 16.0 | 16.3 | 5.7 | 5.4 | 1.10 | 1.4 |
| 11 | 58 | 92 | 16 | 5.6 | 35 | 16.3 | 15.9 | 5.7 | 6.2 | 1.09 | 1.4 |
| 12 | 58 | 93 | 16 | 6.0 | 33 | 17.3 | 16.2 | 6.1 | 6.4 | 1.08 | 1.4 |
| 13 | 59 | 94 | 16 | 5.9 | 34 | 16.8 | 16.1 | 5.9 | 6.8 | 1.07 | 1.4 |
| 14 | 59 | 90 | 16 | 5.9 | 34 | 17.0 | 16.0 | 5.9 | 6.9 | 1.12 | 1.4 |
| 15 | 60 | 91 | 16 | 5.9 | 33 | 16.7 | 15.6 | 5.9 | 6.9 | 1.10 | 1.4 |
| 16 | 60 | 89 | 17 | 6.1 | 34 | 16.3 | 16.0 | 5.9 | 7.4 | 1.12 | 1.5 |
| 17 | 61 | 88 | 17 | 6.3 | 33 | 17.7 | 16.1 | 6.0 | 7.8 | 1.14 | 1.5 |
| 18 | 61 | 91 | 17 | 6.3 | 34 | 16.0 | 16.1 | 6.0 | 7.9 | 1.10 | 1.4 |
| 19 | 62 | 86 | 18 | 6.2 | 34 | 15.8 | 16.2 | 5.8 | 8.4 | 1.16 | 1.5 |
| 20 | 62 | 87 | 17 | 6.6 | 34 | 15.5 | 16.0 | 6.2 | 8.6 | 1.15 | 1.5 |
| Endless | med 51 · p90 89 | — | 9 | 3.5 | 33 | 15.9 | 10.5 | 4.0 | 27.1 | — | — |

#### Profil: average

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 50 | 99 | 16 | 5.3 | 34 | 16.7 | 19.2 | 6.3 | 1.2 | 1.01 | 1.2 |
| 2 | 51 | 99 | 17 | 5.6 | 35 | 15.5 | 19.6 | 6.6 | 1.7 | 1.01 | 1.2 |
| 3 | 52 | 100 | 17 | 6.2 | 33 | 17.5 | 20.0 | 7.1 | 1.9 | 1.01 | 1.2 |
| 4 | 53 | 99 | 18 | 5.9 | 34 | 16.9 | 20.0 | 6.7 | 2.2 | 1.01 | 1.2 |
| 5 | 54 | 98 | 18 | 6.5 | 33 | 16.6 | 20.1 | 7.2 | 2.8 | 1.02 | 1.3 |
| 6 | 56 | 98 | 19 | 6.9 | 33 | 17.0 | 20.7 | 7.4 | 3.0 | 1.02 | 1.3 |
| 7 | 57 | 99 | 19 | 6.9 | 34 | 15.9 | 20.2 | 7.2 | 3.1 | 1.02 | 1.3 |
| 8 | 58 | 99 | 20 | 7.2 | 32 | 16.6 | 20.7 | 7.5 | 3.9 | 1.01 | 1.3 |
| 9 | 59 | 98 | 20 | 7.2 | 32 | 18.0 | 20.3 | 7.3 | 4.5 | 1.03 | 1.3 |
| 10 | 60 | 96 | 21 | 7.4 | 33 | 16.2 | 20.6 | 7.4 | 5.6 | 1.04 | 1.4 |
| 11 | 58 | 96 | 20 | 7.5 | 33 | 18.1 | 20.7 | 7.7 | 6.2 | 1.04 | 1.3 |
| 12 | 58 | 96 | 21 | 7.2 | 33 | 16.1 | 21.6 | 7.4 | 6.4 | 1.04 | 1.3 |
| 13 | 59 | 94 | 21 | 7.7 | 32 | 17.1 | 20.7 | 7.7 | 6.7 | 1.06 | 1.4 |
| 14 | 59 | 95 | 20 | 7.6 | 34 | 16.7 | 19.8 | 7.6 | 7.0 | 1.06 | 1.4 |
| 15 | 60 | 95 | 21 | 7.4 | 32 | 15.3 | 20.8 | 7.3 | 7.2 | 1.06 | 1.4 |
| 16 | 60 | 94 | 21 | 7.7 | 34 | 15.9 | 20.6 | 7.6 | 7.5 | 1.06 | 1.4 |
| 17 | 61 | 95 | 22 | 7.6 | 35 | 16.4 | 21.0 | 7.4 | 7.5 | 1.06 | 1.4 |
| 18 | 61 | 93 | 22 | 7.6 | 34 | 15.5 | 21.1 | 7.3 | 8.0 | 1.07 | 1.4 |
| 19 | 62 | 96 | 22 | 7.7 | 34 | 16.1 | 20.9 | 7.4 | 8.1 | 1.04 | 1.4 |
| 20 | 62 | 94 | 23 | 7.8 | 34 | 15.5 | 21.5 | 7.5 | 8.7 | 1.06 | 1.4 |
| Endless | med 88 · p90 89 | — | 17 | 6.3 | 32 | 16.7 | 15.1 | 5.6 | 27.3 | — | — |

#### Profil: skilled

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 50 | 100 | 19 | 6.5 | 34 | 16.6 | 23.3 | 7.8 | 1.3 | 1.01 | 1.2 |
| 2 | 51 | 100 | 20 | 6.9 | 32 | 16.4 | 23.3 | 8.1 | 1.6 | 1.01 | 1.2 |
| 3 | 52 | 100 | 21 | 7.0 | 35 | 16.8 | 24.7 | 8.1 | 2.0 | 1.01 | 1.2 |
| 4 | 53 | 99 | 21 | 7.5 | 34 | 16.0 | 23.6 | 8.5 | 2.3 | 1.01 | 1.2 |
| 5 | 54 | 100 | 22 | 7.8 | 35 | 16.6 | 24.7 | 8.7 | 2.8 | 1.01 | 1.2 |
| 6 | 56 | 99 | 23 | 8.3 | 34 | 16.4 | 24.3 | 8.9 | 3.0 | 1.01 | 1.3 |
| 7 | 57 | 99 | 23 | 8.5 | 33 | 17.0 | 24.2 | 8.9 | 3.4 | 1.01 | 1.3 |
| 8 | 58 | 99 | 24 | 8.8 | 33 | 16.3 | 24.6 | 9.1 | 3.9 | 1.01 | 1.3 |
| 9 | 59 | 98 | 24 | 8.8 | 32 | 17.0 | 24.5 | 9.0 | 4.7 | 1.02 | 1.3 |
| 10 | 60 | 97 | 26 | 9.0 | 33 | 17.1 | 25.4 | 9.0 | 5.7 | 1.03 | 1.4 |
| 11 | 58 | 97 | 25 | 8.9 | 32 | 16.3 | 25.4 | 9.2 | 6.1 | 1.03 | 1.3 |
| 12 | 58 | 98 | 25 | 8.7 | 32 | 17.3 | 25.3 | 8.9 | 6.5 | 1.02 | 1.3 |
| 13 | 59 | 98 | 25 | 9.1 | 33 | 17.0 | 25.5 | 9.2 | 6.8 | 1.02 | 1.3 |
| 14 | 59 | 98 | 25 | 8.9 | 35 | 16.2 | 25.3 | 8.9 | 7.0 | 1.02 | 1.3 |
| 15 | 60 | 98 | 26 | 9.0 | 32 | 16.8 | 25.7 | 9.0 | 7.1 | 1.02 | 1.4 |
| 16 | 60 | 98 | 26 | 9.5 | 33 | 16.2 | 25.3 | 9.4 | 7.2 | 1.02 | 1.4 |
| 17 | 61 | 97 | 26 | 9.4 | 33 | 17.2 | 25.1 | 9.2 | 8.0 | 1.03 | 1.4 |
| 18 | 61 | 95 | 26 | 9.6 | 33 | 15.5 | 25.2 | 9.3 | 7.9 | 1.05 | 1.4 |
| 19 | 62 | 97 | 26 | 9.9 | 32 | 17.8 | 25.4 | 9.5 | 8.1 | 1.03 | 1.4 |
| 20 | 62 | 98 | 28 | 9.9 | 33 | 16.5 | 26.4 | 9.5 | 8.3 | 1.02 | 1.4 |
| Endless | med 89 · p90 89 | — | 26 | 9.2 | 32 | 17.4 | 20.3 | 7.2 | 27.3 | — | — |

### A2. Vrijednost nadogradnji (average, level 20 i Endless)

| Nadogradnje | L20 coina / min | L20 sjem. / min | Endless coina / min | Endless sjem. / min |
|---|---|---|---|---|
| bez nadogradnji | 21.4 | 7.5 | 15.6 | 5.6 |
| Magnet max | 21.6 | 8.3 | 16.2 | 6.2 |
| Twin Seeds max | 21.2 | 9.7 | 14.6 | 6.9 |
| Loot Boost max | 41.8 | 14.9 | 30.2 | 10.5 |
| sve tri max | 44.6 | 18.7 | 32.5 | 14.3 |

### B. Put igrača kroz 4 besplatne sezone (medijan · p10–p90, 20 putovanja)

Dan = 25 min igre. rush štedi za sljedeću sezonu; boost kupuje nadogradnje čim može; looks prvo kupuje izgled iz Shopa (pa sezonu, pa nadogradnje).

#### casual · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 5.3 | 132 (121–142) | 101 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (27–29) | 21 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 1.1 | 28 (27–29) | 21 | 20 / 20 |
| country_bloom nadogradnje max | 15.7 | 392 (350–414) | 306 | 20 / 20 |
| frost_orchard otključan | 1.1 | 28 (27–29) | 21 | 20 / 20 |
| frost_orchard level 5 pređen | 1.4 | 34 (33–36) | 26 | 20 / 20 |
| frost_orchard level 10 pređen | 1.6 | 41 (40–43) | 31 | 20 / 20 |
| frost_orchard level 15 pređen | 1.9 | 48 (47–50) | 37 | 20 / 20 |
| frost_orchard level 20 pređen | 2.2 | 56 (55–59) | 43 | 20 / 20 |
| frost_orchard Endless otključan | 1.2 | 29 (28–30) | 22 | 20 / 20 |
| frost_orchard prva nadogradnja | 2.2 | 56 (55–59) | 43 | 20 / 20 |
| frost_orchard nadogradnje max | 15.7 | 391 (352–422) | 306 | 20 / 20 |
| lantern_meadow otključan | 2.2 | 56 (55–59) | 43 | 20 / 20 |
| lantern_meadow level 5 pređen | 2.5 | 62 (61–65) | 48 | 20 / 20 |
| lantern_meadow level 10 pređen | 2.8 | 70 (68–72) | 54 | 20 / 20 |
| lantern_meadow level 15 pređen | 3.1 | 77 (74–80) | 59 | 20 / 20 |
| lantern_meadow level 20 pređen | 3.4 | 84 (81–87) | 64 | 20 / 20 |
| lantern_meadow Endless otključan | 2.3 | 57 (56–60) | 44 | 20 / 20 |
| lantern_meadow prva nadogradnja | 3.4 | 84 (81–87) | 64 | 20 / 20 |
| lantern_meadow nadogradnje max | 16.3 | 406 (357–430) | 315 | 20 / 20 |
| amber_canopy otključan | 3.4 | 84 (81–87) | 64 | 20 / 20 |
| amber_canopy level 5 pređen | 3.6 | 90 (88–93) | 69 | 20 / 20 |
| amber_canopy level 10 pređen | 3.9 | 97 (96–100) | 75 | 20 / 20 |
| amber_canopy level 15 pređen | 4.2 | 104 (102–109) | 80 | 20 / 20 |
| amber_canopy level 20 pređen | 4.5 | 112 (110–117) | 86 | 20 / 20 |
| amber_canopy Endless otključan | 3.4 | 85 (83–88) | 65 | 20 / 20 |
| amber_canopy prva nadogradnja | 3.6 | 91 (88–93) | 69 | 20 / 20 |
| amber_canopy nadogradnje max | 4.5 | 112 (110–117) | 86 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 16.3 | 406 (357–430) | 315 | 20 / 20 |
| svi izgledi za coine | 0.8 | 20 (20–21) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 78 · coin: dnevni poklon 124 · coin: prodaja cvijeća 2889 · coin: run 4728 · sjeme ★1 1060 · sjeme ★2 632 · sjeme ★3 299 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 75 · ★3 cvijet: u nadogradnje 96

#### casual · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.7 | 43 (38–51) | 33 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 21 (20–22) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (27–30) | 21 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 2.1 | 54 (49–60) | 41 | 20 / 20 |
| frost_orchard otključan | 4.6 | 116 (102–141) | 91 | 20 / 20 |
| frost_orchard level 5 pređen | 4.9 | 122 (108–147) | 97 | 20 / 20 |
| frost_orchard level 10 pređen | 5.1 | 129 (115–154) | 102 | 20 / 20 |
| frost_orchard level 15 pređen | 5.5 | 138 (124–161) | 107 | 20 / 20 |
| frost_orchard level 20 pređen | 5.8 | 145 (132–170) | 115 | 20 / 20 |
| frost_orchard Endless otključan | 4.7 | 117 (103–142) | 92 | 20 / 20 |
| frost_orchard prva nadogradnja | 4.9 | 122 (108–147) | 97 | 20 / 20 |
| frost_orchard nadogradnje max | 5.8 | 145 (132–171) | 115 | 20 / 20 |
| lantern_meadow otključan | 7.4 | 186 (177–235) | 149 | 20 / 20 |
| lantern_meadow level 5 pređen | 7.7 | 192 (183–241) | 154 | 20 / 20 |
| lantern_meadow level 10 pređen | 8.0 | 200 (190–248) | 159 | 20 / 20 |
| lantern_meadow level 15 pređen | 8.3 | 207 (199–255) | 164 | 20 / 20 |
| lantern_meadow level 20 pređen | 8.6 | 214 (206–263) | 169 | 20 / 20 |
| lantern_meadow Endless otključan | 7.5 | 187 (178–236) | 150 | 20 / 20 |
| lantern_meadow prva nadogradnja | 7.7 | 192 (183–241) | 154 | 20 / 20 |
| lantern_meadow nadogradnje max | 8.6 | 214 (206–263) | 169 | 20 / 20 |
| amber_canopy otključan | 11.0 | 274 (245–325) | 213 | 20 / 20 |
| amber_canopy level 5 pređen | 11.2 | 280 (251–331) | 218 | 20 / 20 |
| amber_canopy level 10 pređen | 11.5 | 288 (258–338) | 223 | 20 / 20 |
| amber_canopy level 15 pređen | 11.8 | 296 (265–345) | 231 | 20 / 20 |
| amber_canopy level 20 pređen | 12.1 | 303 (273–353) | 239 | 20 / 20 |
| amber_canopy Endless otključan | 11.0 | 276 (246–326) | 214 | 20 / 20 |
| amber_canopy prva nadogradnja | 11.2 | 280 (251–331) | 218 | 20 / 20 |
| amber_canopy nadogradnje max | 12.1 | 303 (273–353) | 239 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–15) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.8 | 21 (20–22) | 16 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 21 (20–22) | 16 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 21 (20–22) | 16 | 20 / 20 |
| sve besplatne nadogradnje max | 12.1 | 303 (273–353) | 239 | 20 / 20 |
| svi izgledi za coine | 0.8 | 21 (20–22) | 16 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 59 · coin: dnevni poklon 94 · coin: prodaja cvijeća 2861 · coin: run 4706 · sjeme ★1 1067 · sjeme ★2 663 · sjeme ★3 301 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 75 · ★3 cvijet: u nadogradnje 96

#### casual · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.7 | 42 (36–51) | 32 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–7) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 21 (20–22) | 16 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 29 (27–30) | 22 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.2 | 6 (6–8) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 2.0 | 51 (45–73) | 39 | 20 / 20 |
| frost_orchard otključan | 5.1 | 126 (100–146) | 97 | 20 / 20 |
| frost_orchard level 5 pređen | 5.3 | 132 (106–152) | 102 | 20 / 20 |
| frost_orchard level 10 pređen | 5.6 | 139 (113–159) | 107 | 20 / 20 |
| frost_orchard level 15 pređen | 5.8 | 146 (120–166) | 112 | 20 / 20 |
| frost_orchard level 20 pređen | 6.2 | 155 (128–174) | 118 | 20 / 20 |
| frost_orchard Endless otključan | 5.1 | 127 (102–147) | 98 | 20 / 20 |
| frost_orchard prva nadogradnja | 5.3 | 132 (107–152) | 102 | 20 / 20 |
| frost_orchard nadogradnje max | 6.2 | 155 (128–174) | 117 | 20 / 20 |
| lantern_meadow otključan | 7.9 | 199 (173–238) | 149 | 20 / 20 |
| lantern_meadow level 5 pređen | 8.2 | 205 (180–244) | 155 | 20 / 20 |
| lantern_meadow level 10 pređen | 8.5 | 212 (188–251) | 160 | 20 / 20 |
| lantern_meadow level 15 pređen | 8.8 | 220 (195–258) | 166 | 20 / 20 |
| lantern_meadow level 20 pređen | 9.2 | 229 (202–266) | 172 | 20 / 20 |
| lantern_meadow Endless otključan | 8.0 | 200 (174–239) | 150 | 20 / 20 |
| lantern_meadow prva nadogradnja | 8.2 | 205 (180–244) | 155 | 20 / 20 |
| lantern_meadow nadogradnje max | 9.2 | 229 (202–266) | 172 | 20 / 20 |
| amber_canopy otključan | 10.9 | 272 (252–314) | 214 | 20 / 20 |
| amber_canopy level 5 pređen | 11.1 | 278 (259–320) | 219 | 20 / 20 |
| amber_canopy level 10 pređen | 11.4 | 285 (266–327) | 224 | 20 / 20 |
| amber_canopy level 15 pređen | 11.7 | 292 (274–334) | 230 | 20 / 20 |
| amber_canopy level 20 pređen | 12.0 | 299 (281–341) | 235 | 20 / 20 |
| amber_canopy Endless otključan | 10.9 | 273 (253–315) | 215 | 20 / 20 |
| amber_canopy prva nadogradnja | 11.1 | 278 (259–320) | 219 | 20 / 20 |
| amber_canopy nadogradnje max | 12.0 | 299 (281–341) | 235 | 20 / 20 |
| izgled journal_gold (120) | 0.2 | 6 (6–7) | 5 | 20 / 20 |
| izgled meadow_sunset (150) | 0.3 | 6 (6–8) | 5 | 20 / 20 |
| izgled meadow_lavender (180) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled pip_sky (200) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 19 (17–21) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 12.0 | 299 (281–341) | 235 | 20 / 20 |
| svi izgledi za coine | 0.8 | 19 (17–21) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 58 · coin: dnevni poklon 93 · coin: prodaja cvijeća 2848 · coin: run 4718 · sjeme ★1 1094 · sjeme ★2 647 · sjeme ★3 301 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 76 · ★3 cvijet: u nadogradnje 96

#### average · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 4.8 | 121 (116–129) | 88 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (27–30) | 21 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 1.1 | 28 (27–30) | 21 | 20 / 20 |
| country_bloom nadogradnje max | 11.6 | 290 (264–299) | 198 | 20 / 20 |
| frost_orchard otključan | 1.1 | 28 (27–30) | 21 | 20 / 20 |
| frost_orchard level 5 pređen | 1.4 | 34 (33–36) | 26 | 20 / 20 |
| frost_orchard level 10 pređen | 1.6 | 41 (40–43) | 31 | 20 / 20 |
| frost_orchard level 15 pređen | 1.9 | 48 (47–50) | 36 | 20 / 20 |
| frost_orchard level 20 pređen | 2.2 | 56 (54–58) | 42 | 20 / 20 |
| frost_orchard Endless otključan | 1.2 | 29 (28–31) | 22 | 20 / 20 |
| frost_orchard prva nadogradnja | 2.2 | 56 (54–58) | 42 | 20 / 20 |
| frost_orchard nadogradnje max | 11.8 | 296 (271–303) | 200 | 20 / 20 |
| lantern_meadow otključan | 2.2 | 56 (54–57) | 42 | 20 / 20 |
| lantern_meadow level 5 pređen | 2.5 | 62 (60–64) | 47 | 20 / 20 |
| lantern_meadow level 10 pređen | 2.8 | 69 (67–71) | 52 | 20 / 20 |
| lantern_meadow level 15 pređen | 3.0 | 76 (74–78) | 57 | 20 / 20 |
| lantern_meadow level 20 pređen | 3.3 | 83 (81–86) | 63 | 20 / 20 |
| lantern_meadow Endless otključan | 2.3 | 57 (55–59) | 43 | 20 / 20 |
| lantern_meadow prva nadogradnja | 3.3 | 83 (81–86) | 63 | 20 / 20 |
| lantern_meadow nadogradnje max | 11.9 | 298 (273–311) | 203 | 20 / 20 |
| amber_canopy otključan | 3.3 | 83 (81–85) | 62 | 20 / 20 |
| amber_canopy level 5 pređen | 3.6 | 90 (87–91) | 67 | 20 / 20 |
| amber_canopy level 10 pređen | 3.9 | 97 (94–98) | 72 | 20 / 20 |
| amber_canopy level 15 pređen | 4.2 | 104 (102–106) | 78 | 20 / 20 |
| amber_canopy level 20 pređen | 4.5 | 111 (109–113) | 83 | 20 / 20 |
| amber_canopy Endless otključan | 3.4 | 85 (82–86) | 63 | 20 / 20 |
| amber_canopy prva nadogradnja | 3.6 | 90 (87–91) | 67 | 20 / 20 |
| amber_canopy nadogradnje max | 4.4 | 111 (109–113) | 83 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.8 | 20 (18–21) | 15 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 11.9 | 299 (273–311) | 203 | 20 / 20 |
| svi izgledi za coine | 0.8 | 20 (20–21) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 56 · coin: dnevni poklon 90 · coin: prodaja cvijeća 3005 · coin: run 5077 · sjeme ★1 1073 · sjeme ★2 663 · sjeme ★3 309 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 77 · ★3 cvijet: u nadogradnje 96

#### average · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.4 | 36 (29–46) | 25 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–23) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (27–31) | 21 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 1.8 | 45 (35–51) | 31 | 20 / 20 |
| frost_orchard otključan | 3.6 | 90 (75–100) | 60 | 20 / 20 |
| frost_orchard level 5 pređen | 3.9 | 97 (81–106) | 65 | 20 / 20 |
| frost_orchard level 10 pređen | 4.1 | 103 (88–113) | 70 | 20 / 20 |
| frost_orchard level 15 pređen | 4.4 | 111 (95–120) | 75 | 20 / 20 |
| frost_orchard level 20 pređen | 4.7 | 118 (103–128) | 80 | 20 / 20 |
| frost_orchard Endless otključan | 3.7 | 92 (76–101) | 61 | 20 / 20 |
| frost_orchard prva nadogradnja | 3.9 | 97 (81–105) | 65 | 20 / 20 |
| frost_orchard nadogradnje max | 4.7 | 118 (103–124) | 79 | 20 / 20 |
| lantern_meadow otključan | 5.9 | 147 (135–163) | 97 | 20 / 20 |
| lantern_meadow level 5 pređen | 6.1 | 153 (141–169) | 102 | 20 / 20 |
| lantern_meadow level 10 pređen | 6.4 | 160 (148–177) | 107 | 20 / 20 |
| lantern_meadow level 15 pređen | 6.7 | 167 (155–184) | 112 | 20 / 20 |
| lantern_meadow level 20 pređen | 7.0 | 174 (163–191) | 117 | 20 / 20 |
| lantern_meadow Endless otključan | 5.9 | 148 (136–164) | 98 | 20 / 20 |
| lantern_meadow prva nadogradnja | 6.1 | 153 (141–169) | 102 | 20 / 20 |
| lantern_meadow nadogradnje max | 7.0 | 174 (163–192) | 117 | 20 / 20 |
| amber_canopy otključan | 8.2 | 205 (189–238) | 136 | 20 / 20 |
| amber_canopy level 5 pređen | 8.4 | 211 (195–245) | 141 | 20 / 20 |
| amber_canopy level 10 pređen | 8.7 | 218 (202–252) | 146 | 20 / 20 |
| amber_canopy level 15 pređen | 9.0 | 225 (209–259) | 151 | 20 / 20 |
| amber_canopy level 20 pređen | 9.3 | 232 (217–266) | 157 | 20 / 20 |
| amber_canopy Endless otključan | 8.2 | 206 (190–240) | 137 | 20 / 20 |
| amber_canopy prva nadogradnja | 8.4 | 211 (195–245) | 141 | 20 / 20 |
| amber_canopy nadogradnje max | 9.3 | 232 (217–266) | 157 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.7 | 17 (16–19) | 13 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 20 (20–23) | 15 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 20 (20–23) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 9.3 | 232 (217–266) | 157 | 20 / 20 |
| svi izgledi za coine | 0.8 | 20 (20–23) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 45 · coin: dnevni poklon 71 · coin: prodaja cvijeća 2942 · coin: run 5007 · sjeme ★1 1137 · sjeme ★2 667 · sjeme ★3 305 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 76 · ★3 cvijet: u nadogradnje 96

#### average · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.3 | 33 (29–36) | 24 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (27–29) | 21 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 1.5 | 38 (33–44) | 26 | 20 / 20 |
| frost_orchard otključan | 3.2 | 81 (71–99) | 54 | 20 / 20 |
| frost_orchard level 5 pređen | 3.5 | 87 (77–105) | 59 | 20 / 20 |
| frost_orchard level 10 pređen | 3.8 | 94 (84–112) | 64 | 20 / 20 |
| frost_orchard level 15 pređen | 4.0 | 101 (91–119) | 70 | 20 / 20 |
| frost_orchard level 20 pređen | 4.3 | 109 (99–127) | 75 | 20 / 20 |
| frost_orchard Endless otključan | 3.3 | 82 (72–100) | 55 | 20 / 20 |
| frost_orchard prva nadogradnja | 3.5 | 87 (77–105) | 59 | 20 / 20 |
| frost_orchard nadogradnje max | 4.4 | 109 (99–127) | 75 | 20 / 20 |
| lantern_meadow otključan | 5.7 | 143 (130–160) | 95 | 20 / 20 |
| lantern_meadow level 5 pređen | 5.9 | 149 (136–166) | 100 | 20 / 20 |
| lantern_meadow level 10 pređen | 6.2 | 156 (143–173) | 105 | 20 / 20 |
| lantern_meadow level 15 pređen | 6.5 | 163 (150–180) | 110 | 20 / 20 |
| lantern_meadow level 20 pređen | 6.8 | 170 (158–188) | 115 | 20 / 20 |
| lantern_meadow Endless otključan | 5.7 | 144 (131–161) | 96 | 20 / 20 |
| lantern_meadow prva nadogradnja | 6.0 | 149 (136–166) | 100 | 20 / 20 |
| lantern_meadow nadogradnje max | 6.8 | 170 (158–187) | 115 | 20 / 20 |
| amber_canopy otključan | 8.2 | 206 (183–218) | 136 | 20 / 20 |
| amber_canopy level 5 pređen | 8.5 | 212 (189–224) | 141 | 20 / 20 |
| amber_canopy level 10 pređen | 8.7 | 219 (196–231) | 146 | 20 / 20 |
| amber_canopy level 15 pređen | 9.0 | 226 (203–239) | 152 | 20 / 20 |
| amber_canopy level 20 pređen | 9.3 | 233 (210–246) | 157 | 20 / 20 |
| amber_canopy Endless otključan | 8.3 | 207 (184–219) | 137 | 20 / 20 |
| amber_canopy prva nadogradnja | 8.5 | 212 (189–225) | 141 | 20 / 20 |
| amber_canopy nadogradnje max | 9.3 | 233 (210–246) | 157 | 20 / 20 |
| izgled journal_gold (120) | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| izgled meadow_sunset (150) | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| izgled meadow_lavender (180) | 0.5 | 13 (12–13) | 10 | 20 / 20 |
| izgled pip_sky (200) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled pip_blossom (250) | 0.6 | 16 (13–16) | 12 | 20 / 20 |
| sve besplatne nadogradnje max | 9.3 | 233 (210–246) | 157 | 20 / 20 |
| svi izgledi za coine | 0.6 | 16 (13–16) | 12 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 44 · coin: dnevni poklon 70 · coin: prodaja cvijeća 2944 · coin: run 5009 · sjeme ★1 1115 · sjeme ★2 678 · sjeme ★3 314 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 79 · ★3 cvijet: u nadogradnje 96

#### skilled · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 4.5 | 112 (24–121) | 81 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 27 (27–28) | 20 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 1.1 | 27 (27–29) | 20 | 20 / 20 |
| country_bloom nadogradnje max | 9.2 | 231 (211–258) | 150 | 20 / 20 |
| frost_orchard otključan | 1.1 | 27 (27–29) | 20 | 20 / 20 |
| frost_orchard level 5 pređen | 1.3 | 34 (33–35) | 25 | 20 / 20 |
| frost_orchard level 10 pređen | 1.6 | 41 (40–42) | 30 | 20 / 20 |
| frost_orchard level 15 pređen | 1.9 | 48 (47–49) | 36 | 20 / 20 |
| frost_orchard level 20 pređen | 2.2 | 56 (55–111) | 41 | 20 / 20 |
| frost_orchard Endless otključan | 1.1 | 29 (28–30) | 21 | 20 / 20 |
| frost_orchard prva nadogradnja | 2.2 | 56 (55–111) | 41 | 20 / 20 |
| frost_orchard nadogradnje max | 9.4 | 236 (216–260) | 152 | 20 / 20 |
| lantern_meadow otključan | 2.2 | 55 (53–56) | 41 | 20 / 20 |
| lantern_meadow level 5 pređen | 2.5 | 62 (60–62) | 46 | 20 / 20 |
| lantern_meadow level 10 pređen | 2.7 | 69 (67–69) | 51 | 20 / 20 |
| lantern_meadow level 15 pređen | 3.0 | 76 (74–77) | 56 | 20 / 20 |
| lantern_meadow level 20 pređen | 3.3 | 83 (81–111) | 62 | 20 / 20 |
| lantern_meadow Endless otključan | 2.3 | 56 (54–57) | 42 | 20 / 20 |
| lantern_meadow prva nadogradnja | 3.3 | 83 (81–111) | 62 | 20 / 20 |
| lantern_meadow nadogradnje max | 9.5 | 237 (218–262) | 153 | 20 / 20 |
| amber_canopy otključan | 3.3 | 83 (81–84) | 61 | 20 / 20 |
| amber_canopy level 5 pređen | 3.6 | 89 (87–90) | 66 | 20 / 20 |
| amber_canopy level 10 pređen | 3.9 | 96 (94–98) | 72 | 20 / 20 |
| amber_canopy level 15 pređen | 4.1 | 104 (101–105) | 77 | 20 / 20 |
| amber_canopy level 20 pređen | 4.4 | 111 (109–113) | 82 | 20 / 20 |
| amber_canopy Endless otključan | 3.4 | 84 (82–85) | 62 | 20 / 20 |
| amber_canopy prva nadogradnja | 3.6 | 89 (86–90) | 66 | 20 / 20 |
| amber_canopy nadogradnje max | 4.4 | 110 (108–113) | 80 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.6 | 16 (15–17) | 12 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 9.6 | 239 (222–262) | 153 | 20 / 20 |
| svi izgledi za coine | 0.8 | 20 (20–21) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 45 · coin: dnevni poklon 72 · coin: prodaja cvijeća 3108 · coin: run 5237 · sjeme ★1 1103 · sjeme ★2 687 · sjeme ★3 314 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 78 · ★3 cvijet: u nadogradnje 96

#### skilled · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.2 | 29 (23–39) | 21 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (28–29) | 20 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 1.4 | 35 (30–44) | 24 | 20 / 20 |
| frost_orchard otključan | 3.0 | 75 (66–88) | 46 | 20 / 20 |
| frost_orchard level 5 pređen | 3.3 | 81 (72–94) | 51 | 20 / 20 |
| frost_orchard level 10 pređen | 3.5 | 88 (79–101) | 56 | 20 / 20 |
| frost_orchard level 15 pređen | 3.8 | 96 (86–108) | 61 | 20 / 20 |
| frost_orchard level 20 pređen | 4.1 | 103 (94–116) | 67 | 20 / 20 |
| frost_orchard Endless otključan | 3.1 | 76 (67–89) | 47 | 20 / 20 |
| frost_orchard prva nadogradnja | 3.3 | 82 (72–94) | 51 | 20 / 20 |
| frost_orchard nadogradnje max | 4.1 | 102 (91–116) | 66 | 20 / 20 |
| lantern_meadow otključan | 5.0 | 126 (109–141) | 78 | 20 / 20 |
| lantern_meadow level 5 pređen | 5.3 | 132 (115–148) | 83 | 20 / 20 |
| lantern_meadow level 10 pređen | 5.6 | 139 (122–155) | 88 | 20 / 20 |
| lantern_meadow level 15 pređen | 5.9 | 146 (129–162) | 93 | 20 / 20 |
| lantern_meadow level 20 pređen | 6.2 | 154 (137–170) | 98 | 20 / 20 |
| lantern_meadow Endless otključan | 5.1 | 127 (110–143) | 79 | 20 / 20 |
| lantern_meadow prva nadogradnja | 5.3 | 132 (115–148) | 83 | 20 / 20 |
| lantern_meadow nadogradnje max | 6.2 | 154 (137–169) | 98 | 20 / 20 |
| amber_canopy otključan | 6.8 | 171 (158–195) | 108 | 20 / 20 |
| amber_canopy level 5 pređen | 7.1 | 177 (164–201) | 113 | 20 / 20 |
| amber_canopy level 10 pređen | 7.4 | 184 (171–208) | 118 | 20 / 20 |
| amber_canopy level 15 pređen | 7.7 | 191 (178–216) | 123 | 20 / 20 |
| amber_canopy level 20 pređen | 8.0 | 199 (186–223) | 128 | 20 / 20 |
| amber_canopy Endless otključan | 6.9 | 172 (159–196) | 109 | 20 / 20 |
| amber_canopy prva nadogradnja | 7.1 | 177 (164–201) | 113 | 20 / 20 |
| amber_canopy nadogradnje max | 8.0 | 199 (186–223) | 128 | 20 / 20 |
| izgled journal_gold (120) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_sunset (150) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled meadow_lavender (180) | 0.6 | 15 (13–16) | 11 | 20 / 20 |
| izgled pip_sky (200) | 0.8 | 20 (19–21) | 15 | 20 / 20 |
| izgled pip_blossom (250) | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| sve besplatne nadogradnje max | 8.0 | 199 (186–223) | 128 | 20 / 20 |
| svi izgledi za coine | 0.8 | 20 (20–21) | 15 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 37 · coin: dnevni poklon 59 · coin: prodaja cvijeća 3118 · coin: run 5372 · sjeme ★1 1199 · sjeme ★2 705 · sjeme ★3 320 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 80 · ★3 cvijet: u nadogradnje 96

#### skilled · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.2 | 30 (26–34) | 21 | 20 / 20 |
| country_bloom level 5 pređen | 0.2 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom level 10 pređen | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| country_bloom level 15 pređen | 0.8 | 20 (20–21) | 15 | 20 / 20 |
| country_bloom level 20 pređen | 1.1 | 28 (28–29) | 20 | 20 / 20 |
| country_bloom Endless otključan | 0.0 | 1 (1–1) | 1 | 20 / 20 |
| country_bloom prva nadogradnja | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| country_bloom nadogradnje max | 1.4 | 36 (29–42) | 25 | 20 / 20 |
| frost_orchard otključan | 2.8 | 70 (63–85) | 44 | 20 / 20 |
| frost_orchard level 5 pređen | 3.0 | 76 (69–91) | 49 | 20 / 20 |
| frost_orchard level 10 pređen | 3.3 | 83 (76–98) | 54 | 20 / 20 |
| frost_orchard level 15 pređen | 3.6 | 90 (84–105) | 59 | 20 / 20 |
| frost_orchard level 20 pređen | 3.9 | 98 (92–113) | 64 | 20 / 20 |
| frost_orchard Endless otključan | 2.8 | 71 (64–86) | 45 | 20 / 20 |
| frost_orchard prva nadogradnja | 3.0 | 75 (69–91) | 48 | 20 / 20 |
| frost_orchard nadogradnje max | 3.9 | 98 (89–111) | 63 | 20 / 20 |
| lantern_meadow otključan | 4.8 | 119 (103–134) | 74 | 20 / 20 |
| lantern_meadow level 5 pređen | 5.0 | 125 (109–141) | 79 | 20 / 20 |
| lantern_meadow level 10 pređen | 5.3 | 132 (116–148) | 84 | 20 / 20 |
| lantern_meadow level 15 pređen | 5.6 | 140 (123–156) | 89 | 20 / 20 |
| lantern_meadow level 20 pređen | 5.9 | 147 (132–163) | 95 | 20 / 20 |
| lantern_meadow Endless otključan | 4.8 | 120 (104–136) | 75 | 20 / 20 |
| lantern_meadow prva nadogradnja | 5.0 | 125 (108–141) | 79 | 20 / 20 |
| lantern_meadow nadogradnje max | 5.9 | 147 (130–162) | 94 | 20 / 20 |
| amber_canopy otključan | 6.7 | 167 (155–178) | 104 | 20 / 20 |
| amber_canopy level 5 pređen | 6.9 | 173 (161–184) | 109 | 20 / 20 |
| amber_canopy level 10 pređen | 7.2 | 180 (169–191) | 114 | 20 / 20 |
| amber_canopy level 15 pređen | 7.5 | 187 (176–198) | 119 | 20 / 20 |
| amber_canopy level 20 pređen | 7.8 | 194 (184–206) | 124 | 20 / 20 |
| amber_canopy Endless otključan | 6.7 | 168 (156–179) | 105 | 20 / 20 |
| amber_canopy prva nadogradnja | 6.9 | 173 (161–184) | 109 | 20 / 20 |
| amber_canopy nadogradnje max | 7.8 | 195 (179–206) | 124 | 20 / 20 |
| izgled journal_gold (120) | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| izgled meadow_sunset (150) | 0.3 | 6 (6–6) | 5 | 20 / 20 |
| izgled meadow_lavender (180) | 0.5 | 12 (10–12) | 9 | 20 / 20 |
| izgled pip_sky (200) | 0.5 | 13 (13–14) | 10 | 20 / 20 |
| izgled pip_blossom (250) | 0.5 | 13 (13–15) | 10 | 20 / 20 |
| sve besplatne nadogradnje max | 7.8 | 195 (179–206) | 124 | 20 / 20 |
| svi izgledi za coine | 0.5 | 13 (13–15) | 10 | 20 / 20 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 37 · coin: dnevni poklon 58 · coin: prodaja cvijeća 3028 · coin: run 5129 · sjeme ★1 1129 · sjeme ★2 697 · sjeme ★3 324 · trošak: izgledi 900 · trošak: nadogradnje 1560 · trošak: sezone 1500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 81 · ★3 cvijet: u nadogradnje 96

### Cijene u igri (iz podataka)

- Sezone: frost_orchard 500 C + 20 ★3, lantern_meadow 500 C + 20 ★3, amber_canopy 500 C + 20 ★3
- Nadogradnja po nivou (svaka od 3 staze, po sezoni): 10 C + 2 ★3 → 20 C + 2 ★3 → 40 C + 2 ★3 → 60 C + 2 ★3
- Izgledi za coine: journal_gold 120, meadow_sunset 150, meadow_lavender 180, pip_sky 200, pip_blossom 250
- Magnet radijus po nivou: 40, 88, 136, 184, 232
- Level Path nagrade: 5: 2 ★3 + 200 C, 10: 4 ★3 + 400 C, 15: 6 ★3 + 600 C, 20: 10 ★3 + 1000 C
- Dnevni poklon: 8 C + 3 sjemena

## Povezano

- [[balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]] · [[ekonomija-brojevi|ekonomija-brojevi]] · [[_index|02-design]]
