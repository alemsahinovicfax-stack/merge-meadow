---
type: dizajn
status: aktivan
milestone: M8
tags: [balans, ekonomija, simulacija, run, endless]
povezano:
  - balans-ciklus-1-izvjestaj
  - ekonomija-brojevi
ai_sažetak: "Izlaz economy_sim.gd poslije ciklusa 1b (2026-10-22): težina +5 levela, prepreke 3× svojim tokom, Endless 60 s ispred, ★3 ×1,25 — prolaz po levelu i profilu, put igrača kroz 4 sezone."
---

# Balans ciklus 1b — simulacija (sirovi izlaz)

> Objašnjenje i poređenje: [[balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]] § 6c. Pokrenuto: `economy_sim.gd -- --runs=400 --reps=10`. Model igrača je pretpostavka (kalibrisati iz telemetrije).

Pravila: Endless rampa po stepenicama, plijen u Endlessu ostaje cijeli, sjeme po rijetkosti. Model: casual skuplja 55 %, rizik 1.00 % po prepreci; average skuplja 70 %, rizik 0.50 % po prepreci; skilled skuplja 85 %, rizik 0.25 % po prepreci.

## A. Leveli 1–20 i Endless (sezona sa svih 6 tipova, bez nadogradnji)

### Profil: casual

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 93 | 15 | 4.9 | 20 | 3.6 | 14.8 | 4.8 | 8.9 | 1.07 | 1.4 |
| 2 | 64 | 86 | 16 | 5.6 | 19 | 3.4 | 14.4 | 5.1 | 10.7 | 1.17 | 1.6 |
| 3 | 66 | 84 | 17 | 5.6 | 23 | 4.9 | 14.9 | 4.9 | 12.4 | 1.20 | 1.6 |
| 4 | 70 | 81 | 19 | 6.1 | 22 | 4.8 | 15.0 | 5.0 | 14.2 | 1.24 | 1.7 |
| 5 | 72 | 77 | 19 | 6.2 | 20 | 4.9 | 14.4 | 4.9 | 16.2 | 1.29 | 1.8 |
| 6 | 76 | 70 | 19 | 6.7 | 22 | 6.0 | 13.8 | 5.0 | 18.5 | 1.43 | 2.0 |
| 7 | 78 | 65 | 20 | 6.6 | 22 | 5.8 | 13.4 | 4.7 | 21.0 | 1.53 | 2.2 |
| 8 | 82 | 61 | 21 | 7.4 | 22 | 5.8 | 13.4 | 5.1 | 23.8 | 1.64 | 2.3 |
| 9 | 86 | 50 | 22 | 7.7 | 24 | 4.8 | 12.8 | 4.8 | 26.7 | 2.00 | 2.8 |
| 10 | 88 | 48 | 23 | 8.2 | 24 | 6.5 | 12.6 | 4.9 | 30.0 | 2.08 | 3.0 |
| 11 | 92 | 32 | 24 | 9.0 | 25 | 7.5 | 11.5 | 4.8 | 34.0 | 3.17 | 4.2 |
| 12 | 94 | 27 | 23 | 9.1 | 26 | 6.4 | 10.9 | 4.7 | 37.5 | 3.77 | 4.7 |
| 13 | 98 | 19 | 25 | 9.1 | 27 | 7.1 | 10.5 | 4.5 | 40.9 | 5.41 | 6.5 |
| 14 | 102 | 12 | 26 | 10.5 | 25 | 8.1 | 9.5 | 4.6 | 46.1 | 8.33 | 9.5 |
| 15 | 104 | 7 | 27 | 11.4 | 25 | 7.4 | 8.7 | 4.4 | 50.7 | 14.29 | 15.5 |
| 16 | 108 | 4 | 27 | 10.2 | 26 | 9.4 | 8.2 | 4.3 | 56.0 | 25.00 | 26.4 |
| 17 | 110 | 2 | 30 | 11.4 | 25 | 9.1 | 8.2 | 4.2 | 60.2 | 50.00 | 45.7 |
| 18 | 114 | 1 | 30 | 11.0 | 26 | 9.4 | 7.7 | 4.1 | 65.7 | 133.33 | 119.3 |
| 19 | 116 | 1 | 27 | 10.7 | 29 | 9.4 | 7.5 | 4.1 | 71.8 | 133.33 | 112.3 |
| 20 | 120 | 1 | 28 | 7.5 | 28 | 6.8 | 7.5 | 4.2 | 78.3 | 200.00 | 160.5 |
| Endless | med 81 · p90 144 | — | 23 | 8.6 | 23 | 6.7 | 16.2 | 6.0 | 31.0 | — | — |

### Profil: average

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 94 | 19 | 6.5 | 21 | 3.6 | 19.1 | 6.4 | 8.9 | 1.07 | 1.4 |
| 2 | 64 | 92 | 20 | 7.2 | 21 | 4.6 | 18.7 | 6.6 | 10.6 | 1.09 | 1.5 |
| 3 | 66 | 91 | 21 | 7.5 | 20 | 4.4 | 18.7 | 6.7 | 12.3 | 1.10 | 1.5 |
| 4 | 70 | 91 | 23 | 7.9 | 21 | 4.3 | 19.3 | 6.6 | 14.2 | 1.10 | 1.6 |
| 5 | 72 | 86 | 23 | 8.1 | 22 | 4.9 | 18.5 | 6.5 | 16.4 | 1.17 | 1.7 |
| 6 | 76 | 86 | 24 | 8.5 | 22 | 4.3 | 18.3 | 6.6 | 18.5 | 1.16 | 1.8 |
| 7 | 78 | 79 | 25 | 9.0 | 23 | 4.7 | 18.0 | 6.7 | 21.1 | 1.27 | 1.9 |
| 8 | 82 | 79 | 27 | 9.7 | 22 | 5.3 | 18.5 | 6.8 | 23.8 | 1.26 | 2.0 |
| 9 | 86 | 71 | 28 | 10.0 | 23 | 6.5 | 17.9 | 6.6 | 26.6 | 1.40 | 2.2 |
| 10 | 88 | 66 | 29 | 10.2 | 23 | 6.6 | 17.4 | 6.5 | 30.3 | 1.52 | 2.4 |
| 11 | 92 | 56 | 31 | 11.1 | 24 | 6.1 | 17.4 | 6.5 | 34.2 | 1.77 | 2.7 |
| 12 | 94 | 50 | 31 | 11.2 | 24 | 6.3 | 16.5 | 6.4 | 37.6 | 2.01 | 3.0 |
| 13 | 98 | 46 | 31 | 11.4 | 26 | 6.9 | 15.6 | 6.1 | 41.5 | 2.17 | 3.3 |
| 14 | 102 | 35 | 33 | 13.1 | 25 | 7.3 | 14.8 | 6.3 | 46.7 | 2.88 | 4.2 |
| 15 | 104 | 30 | 33 | 13.2 | 27 | 8.1 | 14.4 | 6.2 | 51.4 | 3.36 | 4.7 |
| 16 | 108 | 25 | 35 | 13.6 | 26 | 7.7 | 13.7 | 6.0 | 57.1 | 4.00 | 5.6 |
| 17 | 110 | 20 | 37 | 13.7 | 27 | 8.3 | 13.3 | 5.9 | 62.2 | 4.94 | 6.6 |
| 18 | 114 | 9 | 38 | 15.1 | 26 | 8.6 | 11.6 | 5.5 | 68.3 | 11.43 | 13.5 |
| 19 | 116 | 8 | 34 | 15.5 | 26 | 8.7 | 10.9 | 5.4 | 74.3 | 12.12 | 14.6 |
| 20 | 120 | 3 | 37 | 14.4 | 26 | 9.0 | 10.4 | 5.1 | 80.9 | 30.77 | 32.1 |
| Endless | med 116 · p90 195 | — | 43 | 15.4 | 23 | 8.1 | 21.5 | 7.8 | 37.1 | — | — |

### Profil: skilled

| Level | Trajanje s | Prolaz % | Coina / prolaz | Sjemena / prolaz | ★2 % | ★3 % | Coina / min | Sjem. / min | Prepreka / min | Pokušaja | Min do prolaza |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 60 | 98 | 23 | 7.6 | 19 | 4.7 | 23.2 | 7.6 | 8.9 | 1.02 | 1.4 |
| 2 | 64 | 97 | 26 | 8.3 | 20 | 4.4 | 24.2 | 7.7 | 10.6 | 1.03 | 1.4 |
| 3 | 66 | 95 | 26 | 9.0 | 22 | 4.4 | 23.1 | 8.1 | 12.3 | 1.05 | 1.5 |
| 4 | 70 | 96 | 28 | 9.1 | 21 | 3.9 | 23.6 | 7.8 | 14.2 | 1.04 | 1.5 |
| 5 | 72 | 95 | 28 | 9.9 | 22 | 4.5 | 23.1 | 8.2 | 16.2 | 1.06 | 1.6 |
| 6 | 76 | 91 | 30 | 10.3 | 21 | 5.3 | 23.0 | 8.0 | 18.5 | 1.10 | 1.7 |
| 7 | 78 | 90 | 30 | 11.0 | 22 | 5.9 | 22.5 | 8.3 | 21.0 | 1.11 | 1.7 |
| 8 | 82 | 88 | 33 | 11.6 | 23 | 4.8 | 22.9 | 8.3 | 24.2 | 1.14 | 1.9 |
| 9 | 86 | 86 | 34 | 12.2 | 23 | 6.0 | 22.7 | 8.2 | 26.6 | 1.16 | 1.9 |
| 10 | 88 | 80 | 35 | 12.9 | 24 | 6.5 | 22.4 | 8.4 | 30.2 | 1.26 | 2.1 |
| 11 | 92 | 77 | 36 | 13.3 | 23 | 6.4 | 22.1 | 8.3 | 34.5 | 1.30 | 2.2 |
| 12 | 94 | 71 | 37 | 14.0 | 23 | 7.0 | 21.7 | 8.4 | 37.9 | 1.42 | 2.3 |
| 13 | 98 | 66 | 39 | 14.6 | 24 | 6.4 | 21.3 | 8.2 | 41.8 | 1.52 | 2.6 |
| 14 | 102 | 59 | 41 | 15.3 | 26 | 6.5 | 20.6 | 8.1 | 46.9 | 1.69 | 2.9 |
| 15 | 104 | 53 | 40 | 15.9 | 25 | 7.1 | 19.4 | 8.1 | 52.1 | 1.90 | 3.2 |
| 16 | 108 | 44 | 43 | 16.2 | 25 | 7.4 | 19.2 | 7.6 | 57.1 | 2.26 | 3.7 |
| 17 | 110 | 44 | 43 | 16.8 | 24 | 8.0 | 18.8 | 7.8 | 62.9 | 2.29 | 3.8 |
| 18 | 114 | 32 | 45 | 17.3 | 27 | 8.0 | 17.7 | 7.5 | 69.1 | 3.15 | 4.8 |
| 19 | 116 | 34 | 45 | 17.6 | 26 | 8.5 | 17.5 | 7.5 | 75.8 | 2.96 | 4.7 |
| 20 | 120 | 21 | 50 | 18.1 | 28 | 7.8 | 16.6 | 7.1 | 82.5 | 4.71 | 6.7 |
| Endless | med 152 · p90 256 | — | 68 | 25.5 | 25 | 8.1 | 25.6 | 9.6 | 43.6 | — | — |

## A2. Vrijednost nadogradnji (average, level 20 i Endless)

| Nadogradnje | L20 coina / min | L20 sjem. / min | Endless coina / min | Endless sjem. / min |
|---|---|---|---|---|
| bez nadogradnji | 11.0 | 5.4 | 21.2 | 7.8 |
| Magnet max | 14.6 | 7.4 | 27.7 | 11.0 |
| Twin Seeds max | 10.5 | 5.9 | 21.1 | 10.0 |
| Loot Boost max | 20.2 | 8.2 | 42.0 | 15.6 |
| sve tri max | 29.3 | 15.9 | 55.5 | 26.8 |

## B. Put igrača kroz 4 besplatne sezone (medijan · p10–p90, 10 putovanja)

Dan = 25 min igre. rush štedi za sljedeću sezonu; boost kupuje nadogradnje čim može; looks prvo kupuje izgled iz Shopa (pa sezonu, pa nadogradnje).

### casual · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.6 | 39 (32–49) | 30 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 8 (7–10) | 6 | 10 / 10 |
| country_bloom level 10 pređen | 0.9 | 22 (18–26) | 14 | 10 / 10 |
| country_bloom level 15 pređen | 2.6 | 64 (53–151) | 54 | 10 / 10 |
| country_bloom level 20 pređen | 80.6 | 2016 (168–2124) | 2207 | 3 / 10 |
| country_bloom Endless otključan | 2.6 | 64 (53–151) | 54 | 10 / 10 |
| country_bloom prva nadogradnja | 29.1 | 728 (401–976) | 712 | 10 / 10 |
| country_bloom nadogradnje max | 79.8 | 1995 (1698–2283) | 2154 | 9 / 10 |
| frost_orchard otključan | 8.0 | 200 (164–225) | 196 | 10 / 10 |
| frost_orchard level 5 pređen | 8.3 | 207 (172–234) | 203 | 10 / 10 |
| frost_orchard level 10 pređen | 8.8 | 221 (182–247) | 208 | 10 / 10 |
| frost_orchard level 15 pređen | 10.6 | 265 (237–295) | 247 | 10 / 10 |
| frost_orchard level 20 pređen | 64.7 | 1617 (358–2020) | 1734 | 6 / 10 |
| frost_orchard Endless otključan | 10.6 | 265 (237–295) | 247 | 10 / 10 |
| frost_orchard prva nadogradnja | 57.2 | 1430 (738–1574) | 1546 | 10 / 10 |
| frost_orchard nadogradnje max | 78.7 | 1968 (1718–2200) | 2123 | 7 / 10 |
| lantern_meadow otključan | 18.0 | 450 (362–516) | 450 | 10 / 10 |
| lantern_meadow level 5 pređen | 18.3 | 458 (371–525) | 456 | 10 / 10 |
| lantern_meadow level 10 pređen | 18.8 | 469 (380–538) | 463 | 10 / 10 |
| lantern_meadow level 15 pređen | 20.7 | 517 (408–603) | 502 | 10 / 10 |
| lantern_meadow level 20 pređen | 53.2 | 1329 (665–1837) | 1416 | 7 / 10 |
| lantern_meadow Endless otključan | 20.7 | 517 (408–603) | 502 | 10 / 10 |
| lantern_meadow prva nadogradnja | 35.5 | 887 (720–1494) | 905 | 10 / 10 |
| lantern_meadow nadogradnje max | 79.4 | 1986 (1725–2230) | 2158 | 7 / 10 |
| amber_canopy otključan | 33.9 | 848 (713–929) | 888 | 10 / 10 |
| amber_canopy level 5 pređen | 34.3 | 858 (720–938) | 894 | 10 / 10 |
| amber_canopy level 10 pređen | 34.8 | 869 (732–959) | 900 | 10 / 10 |
| amber_canopy level 15 pređen | 35.8 | 895 (774–993) | 929 | 10 / 10 |
| amber_canopy level 20 pređen | 57.5 | 1439 (1209–1635) | 1569 | 10 / 10 |
| amber_canopy Endless otključan | 35.8 | 895 (774–993) | 929 | 10 / 10 |
| amber_canopy prva nadogradnja | 34.3 | 858 (720–938) | 894 | 10 / 10 |
| amber_canopy nadogradnje max | 43.4 | 1084 (950–1198) | 1115 | 10 / 10 |
| izgled journal_gold (800) | 6.1 | 151 (150–687) | 144 | 10 / 10 |
| izgled meadow_sunset (1000) | 36.9 | 922 (483–1105) | 926 | 10 / 10 |
| izgled meadow_lavender (1200) | 45.0 | 1125 (995–1150) | 1151 | 10 / 10 |
| izgled pip_sky (2000) | 48.3 | 1207 (1096–1272) | 1258 | 10 / 10 |
| izgled pip_blossom (2500) | 52.5 | 1313 (1190–1340) | 1393 | 10 / 10 |
| sve besplatne nadogradnje max | 79.4 | 1986 (1725–2230) | 2158 | 7 / 10 |
| svi izgledi za coine | 52.5 | 1313 (1190–1340) | 1393 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 7400 · coin: arena combo 1518 · coin: dnevni poklon 7590 · coin: prodaja cvijeća 29800 · coin: run 33610 · sjeme ★1 11435 · sjeme ★2 4259 · sjeme ★3 1285 · trošak: izgledi 7500 · trošak: nadogradnje 19160 · trošak: sezone 13500 · ★3 cvijet: Level Path 74 · ★3 cvijet: merge 340 · ★3 cvijet: u nadogradnje 118

### casual · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.7 | 42 (31–52) | 31 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 8 (7–10) | 6 | 10 / 10 |
| country_bloom level 10 pređen | 0.8 | 21 (18–27) | 14 | 10 / 10 |
| country_bloom level 15 pređen | 2.3 | 58 (45–98) | 45 | 10 / 10 |
| country_bloom level 20 pređen | 14.3 | 356 (212–425) | 371 | 3 / 10 |
| country_bloom Endless otključan | 2.3 | 58 (45–98) | 45 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–10) | 6 | 10 / 10 |
| country_bloom nadogradnje max | 8.5 | 212 (201–301) | 213 | 10 / 10 |
| frost_orchard otključan | 14.1 | 353 (329–451) | 373 | 10 / 10 |
| frost_orchard level 5 pređen | 14.5 | 361 (338–458) | 379 | 10 / 10 |
| frost_orchard level 10 pređen | 15.0 | 374 (358–473) | 388 | 10 / 10 |
| frost_orchard level 15 pređen | 16.2 | 405 (391–546) | 416 | 10 / 10 |
| frost_orchard level 20 pređen | 28.9 | 722 (722–722) | 788 | 1 / 10 |
| frost_orchard Endless otključan | 16.2 | 405 (391–546) | 416 | 10 / 10 |
| frost_orchard prva nadogradnja | 14.5 | 361 (338–458) | 379 | 10 / 10 |
| frost_orchard nadogradnje max | 24.3 | 607 (545–694) | 648 | 10 / 10 |
| lantern_meadow otključan | 31.9 | 796 (723–911) | 858 | 10 / 10 |
| lantern_meadow level 5 pređen | 32.2 | 805 (730–919) | 864 | 10 / 10 |
| lantern_meadow level 10 pređen | 32.6 | 816 (742–934) | 871 | 10 / 10 |
| lantern_meadow level 15 pređen | 34.0 | 849 (789–967) | 899 | 10 / 10 |
| lantern_meadow level 20 pređen | 38.1 | 953 (953–953) | 1021 | 1 / 10 |
| lantern_meadow Endless otključan | 34.0 | 849 (789–967) | 899 | 10 / 10 |
| lantern_meadow prva nadogradnja | 32.2 | 805 (730–919) | 864 | 10 / 10 |
| lantern_meadow nadogradnje max | 40.2 | 1004 (906–1095) | 1021 | 10 / 10 |
| amber_canopy otključan | 48.8 | 1219 (1075–1299) | 1253 | 10 / 10 |
| amber_canopy level 5 pređen | 49.0 | 1226 (1083–1306) | 1258 | 10 / 10 |
| amber_canopy level 10 pređen | 49.7 | 1243 (1093–1319) | 1267 | 10 / 10 |
| amber_canopy level 15 pređen | 50.8 | 1270 (1130–1373) | 1319 | 10 / 10 |
| amber_canopy level 20 pređen | 71.1 | 1779 (1417–2181) | 1946 | 9 / 10 |
| amber_canopy Endless otključan | 50.8 | 1270 (1130–1373) | 1319 | 10 / 10 |
| amber_canopy prva nadogradnja | 49.0 | 1226 (1083–1306) | 1258 | 10 / 10 |
| amber_canopy nadogradnje max | 57.3 | 1434 (1318–1573) | 1550 | 10 / 10 |
| izgled journal_gold (800) | 13.1 | 328 (316–729) | 342 | 10 / 10 |
| izgled meadow_sunset (1000) | 28.7 | 718 (391–1027) | 741 | 10 / 10 |
| izgled meadow_lavender (1200) | 44.2 | 1104 (447–1237) | 1132 | 10 / 10 |
| izgled pip_sky (2000) | 58.0 | 1450 (1350–1535) | 1534 | 10 / 10 |
| izgled pip_blossom (2500) | 61.9 | 1548 (1470–1652) | 1665 | 10 / 10 |
| sve besplatne nadogradnje max | 57.3 | 1434 (1318–1573) | 1550 | 10 / 10 |
| svi izgledi za coine | 61.9 | 1548 (1470–1652) | 1665 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 6200 · coin: arena combo 1703 · coin: dnevni poklon 8513 · coin: prodaja cvijeća 49309 · coin: run 54078 · sjeme ★1 18715 · sjeme ★2 6879 · sjeme ★3 2078 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 62 · ★3 cvijet: merge 543 · ★3 cvijet: u nadogradnje 120

### casual · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.5 | 38 (33–58) | 28 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 8 (7–10) | 6 | 10 / 10 |
| country_bloom level 10 pređen | 0.9 | 23 (19–30) | 17 | 10 / 10 |
| country_bloom level 15 pređen | 2.2 | 55 (48–71) | 41 | 10 / 10 |
| country_bloom level 20 pređen | 16.7 | 417 (207–539) | 453 | 6 / 10 |
| country_bloom Endless otključan | 2.2 | 55 (48–71) | 41 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–10) | 6 | 10 / 10 |
| country_bloom nadogradnje max | 12.0 | 300 (250–308) | 314 | 10 / 10 |
| frost_orchard otključan | 22.4 | 561 (399–642) | 627 | 10 / 10 |
| frost_orchard level 5 pređen | 22.8 | 570 (406–653) | 634 | 10 / 10 |
| frost_orchard level 10 pređen | 23.3 | 581 (428–667) | 642 | 10 / 10 |
| frost_orchard level 15 pređen | 24.3 | 607 (470–716) | 662 | 10 / 10 |
| frost_orchard level 20 pređen | 32.5 | 813 (655–888) | 832 | 3 / 10 |
| frost_orchard Endless otključan | 24.3 | 607 (470–716) | 662 | 10 / 10 |
| frost_orchard prva nadogradnja | 22.8 | 571 (407–653) | 634 | 10 / 10 |
| frost_orchard nadogradnje max | 32.2 | 804 (603–871) | 864 | 10 / 10 |
| lantern_meadow otključan | 36.9 | 923 (746–1117) | 974 | 10 / 10 |
| lantern_meadow level 5 pređen | 37.2 | 930 (755–1126) | 979 | 10 / 10 |
| lantern_meadow level 10 pređen | 37.7 | 944 (767–1139) | 988 | 10 / 10 |
| lantern_meadow level 15 pređen | 39.6 | 989 (811–1176) | 1023 | 10 / 10 |
| lantern_meadow level 20 pređen | 54.8 | 1370 (1127–1381) | 1483 | 3 / 10 |
| lantern_meadow Endless otključan | 39.6 | 989 (811–1176) | 1023 | 10 / 10 |
| lantern_meadow prva nadogradnja | 37.2 | 930 (755–1126) | 979 | 10 / 10 |
| lantern_meadow nadogradnje max | 45.5 | 1137 (930–1387) | 1187 | 10 / 10 |
| amber_canopy otključan | 54.1 | 1352 (1148–1648) | 1433 | 10 / 10 |
| amber_canopy level 5 pređen | 54.4 | 1360 (1156–1656) | 1439 | 10 / 10 |
| amber_canopy level 10 pređen | 55.0 | 1374 (1167–1673) | 1450 | 10 / 10 |
| amber_canopy level 15 pređen | 57.2 | 1429 (1190–1687) | 1501 | 10 / 10 |
| amber_canopy level 20 pređen | 74.5 | 1863 (1597–2085) | 2003 | 7 / 10 |
| amber_canopy Endless otključan | 57.2 | 1429 (1190–1687) | 1501 | 10 / 10 |
| amber_canopy prva nadogradnja | 54.4 | 1360 (1156–1656) | 1439 | 10 / 10 |
| amber_canopy nadogradnje max | 62.9 | 1571 (1340–1804) | 1650 | 10 / 10 |
| izgled journal_gold (800) | 1.0 | 24 (19–30) | 17 | 10 / 10 |
| izgled meadow_sunset (1000) | 2.8 | 69 (53–273) | 54 | 10 / 10 |
| izgled meadow_lavender (1200) | 13.8 | 345 (284–357) | 372 | 10 / 10 |
| izgled pip_sky (2000) | 16.8 | 419 (317–439) | 456 | 10 / 10 |
| izgled pip_blossom (2500) | 20.0 | 500 (357–540) | 529 | 10 / 10 |
| sve besplatne nadogradnje max | 62.9 | 1571 (1340–1804) | 1650 | 10 / 10 |
| svi izgledi za coine | 20.0 | 500 (357–540) | 529 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 6700 · coin: arena combo 1632 · coin: dnevni poklon 8160 · coin: prodaja cvijeća 43948 · coin: run 48342 · sjeme ★1 16781 · sjeme ★2 6174 · sjeme ★3 1845 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 67 · ★3 cvijet: merge 480 · ★3 cvijet: u nadogradnje 120

### average · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.2 | 30 (25–38) | 20 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 7 (7–11) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.8 | 19 (17–23) | 13 | 10 / 10 |
| country_bloom level 15 pređen | 1.5 | 37 (32–51) | 24 | 10 / 10 |
| country_bloom level 20 pređen | 4.0 | 99 (62–541) | 78 | 10 / 10 |
| country_bloom Endless otključan | 1.5 | 37 (32–51) | 24 | 10 / 10 |
| country_bloom prva nadogradnja | 14.3 | 358 (313–480) | 258 | 10 / 10 |
| country_bloom nadogradnje max | 30.2 | 756 (716–833) | 457 | 10 / 10 |
| frost_orchard otključan | 4.0 | 99 (62–149) | 78 | 10 / 10 |
| frost_orchard level 5 pređen | 4.3 | 107 (69–157) | 84 | 10 / 10 |
| frost_orchard level 10 pređen | 4.7 | 117 (81–169) | 90 | 10 / 10 |
| frost_orchard level 15 pređen | 5.5 | 137 (100–184) | 102 | 10 / 10 |
| frost_orchard level 20 pređen | 7.5 | 189 (153–284) | 141 | 10 / 10 |
| frost_orchard Endless otključan | 5.5 | 137 (100–184) | 102 | 10 / 10 |
| frost_orchard prva nadogradnja | 16.1 | 404 (329–512) | 296 | 10 / 10 |
| frost_orchard nadogradnje max | 30.8 | 771 (729–843) | 463 | 10 / 10 |
| lantern_meadow otključan | 7.5 | 189 (153–284) | 141 | 10 / 10 |
| lantern_meadow level 5 pređen | 7.9 | 199 (160–291) | 149 | 10 / 10 |
| lantern_meadow level 10 pređen | 8.4 | 209 (172–305) | 155 | 10 / 10 |
| lantern_meadow level 15 pređen | 9.1 | 229 (187–322) | 169 | 10 / 10 |
| lantern_meadow level 20 pređen | 13.2 | 330 (249–414) | 255 | 10 / 10 |
| lantern_meadow Endless otključan | 9.1 | 229 (187–322) | 169 | 10 / 10 |
| lantern_meadow prva nadogradnja | 14.3 | 356 (324–460) | 267 | 10 / 10 |
| lantern_meadow nadogradnje max | 30.3 | 757 (741–830) | 453 | 10 / 10 |
| amber_canopy otključan | 14.1 | 353 (318–454) | 264 | 10 / 10 |
| amber_canopy level 5 pređen | 14.4 | 361 (326–462) | 270 | 10 / 10 |
| amber_canopy level 10 pređen | 14.8 | 371 (336–472) | 276 | 10 / 10 |
| amber_canopy level 15 pređen | 15.6 | 391 (351–488) | 288 | 10 / 10 |
| amber_canopy level 20 pređen | 19.0 | 475 (398–524) | 364 | 10 / 10 |
| amber_canopy Endless otključan | 15.6 | 391 (351–488) | 288 | 10 / 10 |
| amber_canopy prva nadogradnja | 14.4 | 361 (326–462) | 270 | 10 / 10 |
| amber_canopy nadogradnje max | 20.3 | 506 (443–810) | 377 | 10 / 10 |
| izgled journal_gold (800) | 20.3 | 507 (117–752) | 316 | 10 / 10 |
| izgled meadow_sunset (1000) | 25.7 | 643 (541–821) | 427 | 10 / 10 |
| izgled meadow_lavender (1200) | 30.5 | 762 (610–836) | 452 | 10 / 10 |
| izgled pip_sky (2000) | 32.6 | 816 (782–872) | 483 | 10 / 10 |
| izgled pip_blossom (2500) | 33.8 | 846 (815–901) | 496 | 10 / 10 |
| sve besplatne nadogradnje max | 31.2 | 779 (744–843) | 463 | 10 / 10 |
| svi izgledi za coine | 33.8 | 846 (815–901) | 496 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 503 · coin: dnevni poklon 2513 · coin: prodaja cvijeća 11922 · coin: run 17220 · sjeme ★1 5092 · sjeme ★2 1915 · sjeme ★3 573 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 149 · ★3 cvijet: u nadogradnje 120

### average · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.2 | 29 (26–34) | 19 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 7 (7–11) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.8 | 19 (17–23) | 12 | 10 / 10 |
| country_bloom level 15 pređen | 1.4 | 36 (29–43) | 22 | 10 / 10 |
| country_bloom level 20 pređen | 3.6 | 89 (74–141) | 61 | 10 / 10 |
| country_bloom Endless otključan | 1.4 | 36 (29–43) | 22 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–11) | 5 | 10 / 10 |
| country_bloom nadogradnje max | 3.8 | 95 (87–141) | 63 | 10 / 10 |
| frost_orchard otključan | 6.2 | 154 (126–189) | 83 | 10 / 10 |
| frost_orchard level 5 pređen | 6.5 | 163 (134–197) | 89 | 10 / 10 |
| frost_orchard level 10 pređen | 6.9 | 172 (144–206) | 95 | 10 / 10 |
| frost_orchard level 15 pređen | 7.4 | 185 (163–221) | 103 | 10 / 10 |
| frost_orchard level 20 pređen | 10.4 | 259 (202–332) | 164 | 10 / 10 |
| frost_orchard Endless otključan | 7.4 | 185 (163–221) | 103 | 10 / 10 |
| frost_orchard prva nadogradnja | 6.5 | 163 (134–197) | 89 | 10 / 10 |
| frost_orchard nadogradnje max | 10.4 | 259 (215–311) | 165 | 10 / 10 |
| lantern_meadow otključan | 12.6 | 315 (284–367) | 192 | 10 / 10 |
| lantern_meadow level 5 pređen | 13.0 | 325 (291–375) | 199 | 10 / 10 |
| lantern_meadow level 10 pređen | 13.4 | 334 (300–386) | 204 | 10 / 10 |
| lantern_meadow level 15 pređen | 14.2 | 354 (315–404) | 216 | 10 / 10 |
| lantern_meadow level 20 pređen | 16.9 | 424 (364–480) | 266 | 10 / 10 |
| lantern_meadow Endless otključan | 14.2 | 354 (315–404) | 216 | 10 / 10 |
| lantern_meadow prva nadogradnja | 13.0 | 325 (291–375) | 199 | 10 / 10 |
| lantern_meadow nadogradnje max | 17.0 | 424 (371–480) | 266 | 10 / 10 |
| amber_canopy otključan | 20.1 | 503 (454–558) | 292 | 10 / 10 |
| amber_canopy level 5 pređen | 20.5 | 511 (462–565) | 297 | 10 / 10 |
| amber_canopy level 10 pređen | 20.9 | 522 (471–577) | 305 | 10 / 10 |
| amber_canopy level 15 pređen | 21.6 | 539 (489–598) | 315 | 10 / 10 |
| amber_canopy level 20 pređen | 23.2 | 581 (545–668) | 335 | 10 / 10 |
| amber_canopy Endless otključan | 21.6 | 539 (489–598) | 315 | 10 / 10 |
| amber_canopy prva nadogradnja | 20.5 | 511 (462–566) | 297 | 10 / 10 |
| amber_canopy nadogradnje max | 24.3 | 607 (561–671) | 349 | 10 / 10 |
| izgled journal_gold (800) | 6.3 | 157 (135–499) | 110 | 10 / 10 |
| izgled meadow_sunset (1000) | 21.0 | 526 (363–590) | 302 | 10 / 10 |
| izgled meadow_lavender (1200) | 23.8 | 594 (556–684) | 342 | 10 / 10 |
| izgled pip_sky (2000) | 25.3 | 632 (603–710) | 361 | 10 / 10 |
| izgled pip_blossom (2500) | 26.5 | 662 (629–742) | 369 | 10 / 10 |
| sve besplatne nadogradnje max | 24.3 | 607 (561–671) | 349 | 10 / 10 |
| svi izgledi za coine | 26.5 | 662 (629–742) | 369 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 395 · coin: dnevni poklon 1973 · coin: prodaja cvijeća 12823 · coin: run 17034 · sjeme ★1 5503 · sjeme ★2 2025 · sjeme ★3 612 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 158 · ★3 cvijet: u nadogradnje 120

### average · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.4 | 35 (27–40) | 24 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 7 (7–11) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.7 | 18 (17–22) | 12 | 10 / 10 |
| country_bloom level 15 pređen | 1.5 | 36 (33–46) | 23 | 10 / 10 |
| country_bloom level 20 pređen | 4.4 | 109 (88–145) | 82 | 10 / 10 |
| country_bloom Endless otključan | 1.5 | 36 (33–46) | 23 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–11) | 5 | 10 / 10 |
| country_bloom nadogradnje max | 6.0 | 150 (126–184) | 95 | 10 / 10 |
| frost_orchard otključan | 10.1 | 253 (241–281) | 128 | 10 / 10 |
| frost_orchard level 5 pređen | 10.4 | 261 (249–289) | 133 | 10 / 10 |
| frost_orchard level 10 pređen | 10.8 | 270 (259–304) | 138 | 10 / 10 |
| frost_orchard level 15 pređen | 11.6 | 290 (277–316) | 152 | 10 / 10 |
| frost_orchard level 20 pređen | 14.2 | 355 (328–389) | 222 | 10 / 10 |
| frost_orchard Endless otključan | 11.6 | 290 (277–316) | 152 | 10 / 10 |
| frost_orchard prva nadogradnja | 10.4 | 261 (249–289) | 133 | 10 / 10 |
| frost_orchard nadogradnje max | 14.2 | 355 (328–389) | 222 | 10 / 10 |
| lantern_meadow otključan | 17.3 | 432 (386–448) | 244 | 10 / 10 |
| lantern_meadow level 5 pređen | 17.6 | 439 (395–455) | 250 | 10 / 10 |
| lantern_meadow level 10 pređen | 17.9 | 448 (404–465) | 256 | 10 / 10 |
| lantern_meadow level 15 pređen | 18.5 | 464 (424–483) | 266 | 10 / 10 |
| lantern_meadow level 20 pređen | 21.8 | 546 (511–612) | 334 | 10 / 10 |
| lantern_meadow Endless otključan | 18.5 | 464 (424–483) | 266 | 10 / 10 |
| lantern_meadow prva nadogradnja | 17.6 | 439 (395–456) | 250 | 10 / 10 |
| lantern_meadow nadogradnje max | 21.6 | 539 (511–567) | 325 | 10 / 10 |
| amber_canopy otključan | 24.7 | 617 (584–650) | 353 | 10 / 10 |
| amber_canopy level 5 pređen | 25.0 | 624 (592–660) | 359 | 10 / 10 |
| amber_canopy level 10 pređen | 25.5 | 637 (602–672) | 365 | 10 / 10 |
| amber_canopy level 15 pređen | 26.2 | 654 (613–702) | 384 | 10 / 10 |
| amber_canopy level 20 pređen | 27.8 | 695 (688–772) | 432 | 10 / 10 |
| amber_canopy Endless otključan | 26.2 | 654 (613–702) | 384 | 10 / 10 |
| amber_canopy prva nadogradnja | 25.0 | 624 (592–660) | 359 | 10 / 10 |
| amber_canopy nadogradnje max | 28.1 | 702 (690–772) | 435 | 10 / 10 |
| izgled journal_gold (800) | 0.7 | 18 (17–22) | 12 | 10 / 10 |
| izgled meadow_sunset (1000) | 3.0 | 75 (36–111) | 51 | 10 / 10 |
| izgled meadow_lavender (1200) | 5.8 | 145 (89–167) | 98 | 10 / 10 |
| izgled pip_sky (2000) | 7.3 | 183 (174–212) | 108 | 10 / 10 |
| izgled pip_blossom (2500) | 8.7 | 218 (205–245) | 117 | 10 / 10 |
| sve besplatne nadogradnje max | 28.1 | 702 (690–772) | 435 | 10 / 10 |
| svi izgledi za coine | 8.7 | 218 (205–245) | 117 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 419 · coin: dnevni poklon 2093 · coin: prodaja cvijeća 12792 · coin: run 17244 · sjeme ★1 5504 · sjeme ★2 2003 · sjeme ★3 629 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 161 · ★3 cvijet: u nadogradnje 120

### skilled · rush

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.0 | 24 (20–27) | 15 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 8 (7–9) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.7 | 18 (16–20) | 11 | 10 / 10 |
| country_bloom level 15 pređen | 1.2 | 30 (28–33) | 17 | 10 / 10 |
| country_bloom level 20 pređen | 2.1 | 52 (47–72) | 31 | 10 / 10 |
| country_bloom Endless otključan | 1.2 | 30 (28–33) | 17 | 10 / 10 |
| country_bloom prva nadogradnja | 10.0 | 251 (240–264) | 129 | 10 / 10 |
| country_bloom nadogradnje max | 22.7 | 568 (540–594) | 240 | 10 / 10 |
| frost_orchard otključan | 2.1 | 52 (48–72) | 31 | 10 / 10 |
| frost_orchard level 5 pređen | 2.4 | 60 (55–80) | 36 | 10 / 10 |
| frost_orchard level 10 pređen | 2.8 | 70 (64–91) | 41 | 10 / 10 |
| frost_orchard level 15 pređen | 3.3 | 82 (79–110) | 49 | 10 / 10 |
| frost_orchard level 20 pređen | 4.5 | 113 (103–139) | 71 | 10 / 10 |
| frost_orchard Endless otključan | 3.3 | 82 (79–110) | 49 | 10 / 10 |
| frost_orchard prva nadogradnja | 10.0 | 251 (244–325) | 131 | 10 / 10 |
| frost_orchard nadogradnje max | 22.9 | 573 (520–599) | 239 | 10 / 10 |
| lantern_meadow otključan | 4.5 | 114 (103–140) | 71 | 10 / 10 |
| lantern_meadow level 5 pređen | 4.8 | 121 (110–147) | 76 | 10 / 10 |
| lantern_meadow level 10 pređen | 5.3 | 131 (122–157) | 82 | 10 / 10 |
| lantern_meadow level 15 pređen | 5.7 | 143 (135–173) | 87 | 10 / 10 |
| lantern_meadow level 20 pređen | 6.6 | 166 (160–192) | 98 | 10 / 10 |
| lantern_meadow Endless otključan | 5.7 | 143 (135–173) | 87 | 10 / 10 |
| lantern_meadow prva nadogradnja | 9.5 | 238 (231–252) | 122 | 10 / 10 |
| lantern_meadow nadogradnje max | 22.9 | 572 (553–607) | 243 | 10 / 10 |
| amber_canopy otključan | 9.5 | 238 (230–252) | 120 | 10 / 10 |
| amber_canopy level 5 pređen | 9.8 | 246 (238–260) | 126 | 10 / 10 |
| amber_canopy level 10 pređen | 10.2 | 255 (247–270) | 133 | 10 / 10 |
| amber_canopy level 15 pređen | 10.8 | 270 (262–286) | 139 | 10 / 10 |
| amber_canopy level 20 pređen | 11.8 | 294 (279–314) | 156 | 10 / 10 |
| amber_canopy Endless otključan | 10.8 | 270 (262–286) | 139 | 10 / 10 |
| amber_canopy prva nadogradnja | 9.8 | 246 (238–260) | 126 | 10 / 10 |
| amber_canopy nadogradnje max | 15.4 | 384 (341–586) | 201 | 10 / 10 |
| izgled journal_gold (800) | 15.2 | 380 (275–584) | 185 | 10 / 10 |
| izgled meadow_sunset (1000) | 17.2 | 430 (377–596) | 196 | 10 / 10 |
| izgled meadow_lavender (1200) | 23.6 | 590 (430–607) | 242 | 10 / 10 |
| izgled pip_sky (2000) | 25.1 | 627 (606–629) | 254 | 10 / 10 |
| izgled pip_blossom (2500) | 26.1 | 654 (632–657) | 262 | 10 / 10 |
| sve besplatne nadogradnje max | 23.4 | 586 (569–607) | 243 | 10 / 10 |
| svi izgledi za coine | 26.1 | 654 (632–657) | 262 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 383 · coin: dnevni poklon 1913 · coin: prodaja cvijeća 12194 · coin: run 17645 · sjeme ★1 5213 · sjeme ★2 1934 · sjeme ★3 612 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 156 · ★3 cvijet: u nadogradnje 120

### skilled · boost

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.1 | 28 (21–39) | 16 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 8 (7–8) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.7 | 17 (16–19) | 11 | 10 / 10 |
| country_bloom level 15 pređen | 1.3 | 33 (30–37) | 19 | 10 / 10 |
| country_bloom level 20 pređen | 2.7 | 68 (48–74) | 42 | 10 / 10 |
| country_bloom Endless otključan | 1.3 | 33 (30–37) | 19 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (8–8) | 5 | 10 / 10 |
| country_bloom nadogradnje max | 3.1 | 78 (64–84) | 45 | 10 / 10 |
| frost_orchard otključan | 4.6 | 116 (106–143) | 55 | 10 / 10 |
| frost_orchard level 5 pređen | 4.9 | 123 (114–150) | 60 | 10 / 10 |
| frost_orchard level 10 pređen | 5.4 | 134 (123–160) | 65 | 10 / 10 |
| frost_orchard level 15 pređen | 6.0 | 149 (138–173) | 74 | 10 / 10 |
| frost_orchard level 20 pređen | 7.0 | 175 (162–199) | 86 | 10 / 10 |
| frost_orchard Endless otključan | 6.0 | 149 (138–173) | 74 | 10 / 10 |
| frost_orchard prva nadogradnja | 4.9 | 123 (114–151) | 60 | 10 / 10 |
| frost_orchard nadogradnje max | 7.0 | 176 (165–203) | 86 | 10 / 10 |
| lantern_meadow otključan | 9.4 | 234 (219–289) | 101 | 10 / 10 |
| lantern_meadow level 5 pređen | 9.7 | 243 (228–296) | 107 | 10 / 10 |
| lantern_meadow level 10 pređen | 10.1 | 252 (239–307) | 112 | 10 / 10 |
| lantern_meadow level 15 pređen | 10.5 | 263 (252–319) | 120 | 10 / 10 |
| lantern_meadow level 20 pređen | 11.9 | 298 (266–350) | 137 | 10 / 10 |
| lantern_meadow Endless otključan | 10.5 | 263 (252–319) | 120 | 10 / 10 |
| lantern_meadow prva nadogradnja | 9.7 | 243 (228–296) | 107 | 10 / 10 |
| lantern_meadow nadogradnje max | 11.9 | 298 (279–350) | 141 | 10 / 10 |
| amber_canopy otključan | 15.1 | 378 (358–413) | 162 | 10 / 10 |
| amber_canopy level 5 pređen | 15.4 | 386 (366–421) | 167 | 10 / 10 |
| amber_canopy level 10 pređen | 15.9 | 396 (376–430) | 172 | 10 / 10 |
| amber_canopy level 15 pređen | 16.4 | 409 (391–442) | 178 | 10 / 10 |
| amber_canopy level 20 pređen | 17.4 | 436 (415–481) | 196 | 10 / 10 |
| amber_canopy Endless otključan | 16.4 | 409 (391–442) | 178 | 10 / 10 |
| amber_canopy prva nadogradnja | 15.4 | 386 (366–421) | 167 | 10 / 10 |
| amber_canopy nadogradnje max | 18.5 | 462 (434–509) | 200 | 10 / 10 |
| izgled journal_gold (800) | 9.2 | 230 (107–386) | 100 | 10 / 10 |
| izgled meadow_sunset (1000) | 15.7 | 393 (132–448) | 166 | 10 / 10 |
| izgled meadow_lavender (1200) | 18.4 | 459 (277–474) | 194 | 10 / 10 |
| izgled pip_sky (2000) | 19.7 | 492 (467–501) | 207 | 10 / 10 |
| izgled pip_blossom (2500) | 20.9 | 522 (506–530) | 217 | 10 / 10 |
| sve besplatne nadogradnje max | 18.5 | 462 (434–509) | 200 | 10 / 10 |
| svi izgledi za coine | 20.9 | 522 (506–530) | 217 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 303 · coin: dnevni poklon 1515 · coin: prodaja cvijeća 12810 · coin: run 17521 · sjeme ★1 5505 · sjeme ★2 2044 · sjeme ★3 616 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 157 · ★3 cvijet: u nadogradnje 120

### skilled · looks

| Milestone | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| country_bloom ★3 sjeme u igri | 1.1 | 28 (22–34) | 16 | 10 / 10 |
| country_bloom level 5 pređen | 0.3 | 7 (7–8) | 5 | 10 / 10 |
| country_bloom level 10 pređen | 0.7 | 17 (17–19) | 11 | 10 / 10 |
| country_bloom level 15 pređen | 1.2 | 31 (28–33) | 18 | 10 / 10 |
| country_bloom level 20 pređen | 2.1 | 52 (45–58) | 29 | 10 / 10 |
| country_bloom Endless otključan | 1.2 | 31 (28–33) | 18 | 10 / 10 |
| country_bloom prva nadogradnja | 0.3 | 8 (7–9) | 5 | 10 / 10 |
| country_bloom nadogradnje max | 4.6 | 114 (95–120) | 43 | 10 / 10 |
| frost_orchard otključan | 8.0 | 201 (196–210) | 68 | 10 / 10 |
| frost_orchard level 5 pređen | 8.4 | 210 (203–217) | 73 | 10 / 10 |
| frost_orchard level 10 pređen | 8.8 | 219 (214–228) | 80 | 10 / 10 |
| frost_orchard level 15 pređen | 9.4 | 234 (225–243) | 86 | 10 / 10 |
| frost_orchard level 20 pređen | 10.7 | 267 (249–276) | 107 | 10 / 10 |
| frost_orchard Endless otključan | 9.4 | 234 (225–243) | 86 | 10 / 10 |
| frost_orchard prva nadogradnja | 8.4 | 210 (203–217) | 73 | 10 / 10 |
| frost_orchard nadogradnje max | 10.7 | 268 (250–276) | 107 | 10 / 10 |
| lantern_meadow otključan | 13.0 | 324 (303–343) | 121 | 10 / 10 |
| lantern_meadow level 5 pređen | 13.3 | 332 (310–350) | 126 | 10 / 10 |
| lantern_meadow level 10 pređen | 13.7 | 341 (321–359) | 132 | 10 / 10 |
| lantern_meadow level 15 pređen | 14.2 | 354 (339–374) | 139 | 10 / 10 |
| lantern_meadow level 20 pređen | 15.1 | 377 (360–408) | 155 | 10 / 10 |
| lantern_meadow Endless otključan | 14.2 | 354 (339–374) | 139 | 10 / 10 |
| lantern_meadow prva nadogradnja | 13.3 | 332 (310–351) | 126 | 10 / 10 |
| lantern_meadow nadogradnje max | 15.4 | 384 (373–413) | 156 | 10 / 10 |
| amber_canopy otključan | 18.3 | 459 (444–481) | 178 | 10 / 10 |
| amber_canopy level 5 pređen | 18.7 | 467 (452–488) | 184 | 10 / 10 |
| amber_canopy level 10 pređen | 19.0 | 476 (462–503) | 190 | 10 / 10 |
| amber_canopy level 15 pređen | 19.5 | 489 (483–515) | 197 | 10 / 10 |
| amber_canopy level 20 pređen | 20.8 | 519 (501–552) | 213 | 10 / 10 |
| amber_canopy Endless otključan | 19.5 | 489 (483–515) | 197 | 10 / 10 |
| amber_canopy prva nadogradnja | 18.7 | 467 (452–488) | 184 | 10 / 10 |
| amber_canopy nadogradnje max | 20.9 | 521 (508–553) | 215 | 10 / 10 |
| izgled journal_gold (800) | 0.7 | 18 (17–20) | 11 | 10 / 10 |
| izgled meadow_sunset (1000) | 1.2 | 31 (28–33) | 18 | 10 / 10 |
| izgled meadow_lavender (1200) | 2.3 | 59 (51–114) | 35 | 10 / 10 |
| izgled pip_sky (2000) | 5.6 | 139 (132–146) | 53 | 10 / 10 |
| izgled pip_blossom (2500) | 6.8 | 170 (163–177) | 61 | 10 / 10 |
| sve besplatne nadogradnje max | 20.9 | 521 (508–553) | 215 | 10 / 10 |
| svi izgledi za coine | 6.8 | 170 (163–177) | 61 | 10 / 10 |

Tok (prosjek po putovanju, do kraja): coin: Level Path 8800 · coin: arena combo 306 · coin: dnevni poklon 1530 · coin: prodaja cvijeća 12934 · coin: run 17491 · sjeme ★1 5486 · sjeme ★2 2051 · sjeme ★3 651 · trošak: izgledi 7500 · trošak: nadogradnje 19800 · trošak: sezone 13500 · ★3 cvijet: Level Path 88 · ★3 cvijet: merge 165 · ★3 cvijet: u nadogradnje 120

## Cijene u igri (iz podataka)

- Sezone: frost_orchard 2500 C + 22 ★3, lantern_meadow 4500 C + 26 ★3, amber_canopy 6500 C + 30 ★3
- Nadogradnja po nivou (svaka od 3 staze, po sezoni): 100 C + 2 ★3 → 250 C + 2 ★3 → 500 C + 3 ★3 → 800 C + 3 ★3
- Izgledi za coine: journal_gold 800, meadow_sunset 1000, meadow_lavender 1200, pip_sky 2000, pip_blossom 2500
- Magnet radijus po nivou: 40, 95, 150, 205, 260
- Level Path nagrade: 5: 2 ★3 + 200 C, 10: 4 ★3 + 400 C, 15: 6 ★3 + 600 C, 20: 10 ★3 + 1000 C
- Dnevni poklon: 75 C + 5 sjemena

## Povezano

- [[balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]]
- [[_index|02-design]]
