---
type: dizajn
status: aktivan
milestone: M8
tags: [simulacija, retencija, sadrzaj, ekonomija, balans]
povezano:
  - balans-ciklus-1b-simulacija
  - procjena-igraca
ai_sažetak: "Izlaz economy_sim.gd dijela C (2026-10-26, RET-01): kalendarski dani do kraja besplatnog sadržaja (4 sezone) pri 10 / 15 / 25 / 40 min igre dnevno — average ~64 / 47 / 27 / 18 d, skilled ~48 / 34 / 21 / 13 d, casual zapne na zidu L15–20."
---

# Trajanje sadržaja — simulacija (sirovi izlaz)

> Tumačenje i strategija: [[06-production/procjena-igraca|procjena-igraca]] (RET-01). Isti model kao [[02-design/balans-ciklus-1b-simulacija|balans-ciklus-1b-simulacija]]. Pokrenuto: `economy_sim.gd -- --runs=400 --reps=10` (seed 7, default `--day-mins=10,15,25,40`, sva četiri dijela, ~9 min) na kodu `9c6f92b`. Model igrača je pretpostavka (kalibrisati iz telemetrije). Balans se ovdje ne mijenja — zid rješava BAL-01.
>
> Samo `--parts=c` daje malo drugačije brojke (drugi tok slučajnih brojeva; zid se tada mjeri posebnim prolazom).

## Sažetak

Average igrač (skuplja 70 %, rizik 0,5 % po prepreci) pređe L20 u sve 4 besplatne sezone za oko 600 minuta igre: to je ~59 dana pri 10 min dnevno, ~43 pri 15, ~24 pri 25 i ~16 pri 40, a sav besplatni sadržaj (i sve nadogradnje i svi izgledi za coine) je gotov za ~64 / 47 / 27 / 18 dana. Skilled igraču treba oko 30 % manje vremena: sve sezone za ~41 / 28 / 18 / 11 dana, kraj sadržaja za ~48 / 34 / 21 / 13 dana (10 / 15 / 25 / 40 min). Ukupne minute igre skoro ne zavise od minuta dnevno (average 590–650 min do svih sezona, skilled 410–440), pa su dani ≈ minute ÷ minute dnevno; dnevni poklon samo malo ubrzava one koji igraju kraće. Casual igrač otključa sve 4 sezone za ~1200 min (~123 / 78 / 48 / 29 dana) i max-a sve nadogradnje za ~1450 min (~145 / 93 / 58 / 36 dana), ali do granice simulacije (2500 runova ≈ 2240 min ≈ 224 / 149 / 89 / 56 dana) samo 1–3 od 10 putovanja pređu L20 u sve 4 sezone. Zid za casual je L15–20: prolaz pada sa 7 % (L15) na 2 % (L17) i 0,5–0,8 % (L18–20), što je ~556 pokušaja i ~480 min samo za te levele po sezoni (~48 / 32 / 19 / 12 dana po sezoni pri 10 / 15 / 25 / 40 min). Nadogradnje u modelu ne smanjuju rizik prepreka, pa casual ne može „kupiti" prolaz — putovanja stanu na L19–20 nižih sezona. Profili su pretpostavka, ne telemetrija: brojke kalibrisati čim stignu podaci testera.

Pravila: Endless rampa po stepenicama, plijen u Endlessu ostaje cijeli, sjeme po rijetkosti. Model: casual skuplja 55 %, rizik 1.00 % po prepreci; average skuplja 70 %, rizik 0.50 % po prepreci; skilled skuplja 85 %, rizik 0.25 % po prepreci.

## C. Koliko kalendarskih dana traje besplatni sadržaj (boost, medijan, 10 putovanja)

Put kao u B (politika boost) za svaku vrijednost minuta igre dnevno; svaka ima svoja putovanja jer dnevni poklon i arena combo idu po danu. Razlika od B: kad su sve nadogradnje max, igrač se vraća na nepređene levele nižih sezona (u B igra Endless najviše sezone). Granica: 2500 runova po putovanju; medijan je preko svih putovanja (nedostignuto = beskonačno), „— (x / 10)" = medijan nije dostignut, x putovanja je stiglo.

### Sažetak (dani)

| Profil | Mjera | 10 min/dan | 15 min/dan | 25 min/dan | 40 min/dan |
|---|---|---|---|---|---|
| casual | sve besplatne sezone pređene | — (3 / 10) | — (2 / 10) | — (1 / 10) | — (1 / 10) |
| casual | kraj besplatnog sadržaja | — (3 / 10) | — (2 / 10) | — (1 / 10) | — (1 / 10) |
| average | sve besplatne sezone pređene | 59.2 | 43.3 | 24.4 | 15.6 |
| average | kraj besplatnog sadržaja | 63.8 | 46.6 | 27.0 | 17.6 |
| skilled | sve besplatne sezone pređene | 40.8 | 27.9 | 17.6 | 10.9 |
| skilled | kraj besplatnog sadržaja | 47.8 | 33.5 | 20.6 | 13.0 |

### casual · boost (dan · min igre)

| Milestone | 10 min/dan | 15 min/dan | 25 min/dan | 40 min/dan |
|---|---|---|---|---|
| country_bloom level 20 pređen | 205.3 · 2053 (6 / 10) | 146.2 · 2194 (7 / 10) | 78.4 · 1960 (7 / 10) | 56.3 · 2252 (6 / 10) |
| frost_orchard otključan | 37.9 · 379 | 25.0 · 375 | 15.2 · 380 | 9.6 · 385 |
| frost_orchard level 20 pređen | — (3 / 10) | — (3 / 10) | — (4 / 10) | — (4 / 10) |
| lantern_meadow otključan | 75.4 · 754 | 50.9 · 764 | 30.6 · 765 | 19.3 · 772 |
| lantern_meadow level 20 pređen | — (4 / 10) | — (4 / 10) | — (1 / 10) | — (4 / 10) |
| amber_canopy otključan | 122.7 · 1227 | 77.5 · 1163 | 48.2 · 1206 | 29.1 · 1164 |
| amber_canopy level 20 pređen | 189.5 · 1895 (8 / 10) | 114.2 · 1713 (9 / 10) | 74.9 · 1873 (8 / 10) | 48.7 · 1950 (8 / 10) |
| sve besplatne sezone pređene | — (3 / 10) | — (2 / 10) | — (1 / 10) | — (1 / 10) |
| sve besplatne nadogradnje max | 144.9 · 1449 | 92.9 · 1393 | 58.0 · 1451 | 36.1 · 1444 |
| svi izgledi za coine | 110.9 · 1109 | 87.5 · 1313 | 63.9 · 1596 | 40.7 · 1628 |
| kraj besplatnog sadržaja | — (3 / 10) | — (2 / 10) | — (1 / 10) | — (1 / 10) |
| u granici (2500 runova) | 7 / 10 · 2235 min ≈ 224 d | 8 / 10 · 2238 min ≈ 149 d | 9 / 10 · 2235 min ≈ 89 d | 9 / 10 · 2236 min ≈ 56 d |

### average · boost (dan · min igre)

| Milestone | 10 min/dan | 15 min/dan | 25 min/dan | 40 min/dan |
|---|---|---|---|---|
| country_bloom level 20 pređen | 9.3 · 93 | 7.3 · 110 | 4.0 · 100 | 2.8 · 112 |
| frost_orchard otključan | 15.5 · 155 | 11.2 · 169 | 6.3 · 156 | 4.6 · 182 |
| frost_orchard level 20 pređen | 25.8 · 258 | 18.3 · 274 | 10.0 · 251 | 7.0 · 280 |
| lantern_meadow otključan | 31.8 · 318 | 22.1 · 331 | 13.1 · 328 | 8.6 · 342 |
| lantern_meadow level 20 pređen | 43.5 · 435 | 30.1 · 452 | 16.6 · 414 | 11.0 · 439 |
| amber_canopy otključan | 50.0 · 500 | 34.7 · 521 | 19.8 · 496 | 13.3 · 531 |
| amber_canopy level 20 pređen | 59.2 · 592 | 43.3 · 649 | 24.4 · 610 | 15.6 · 622 |
| sve besplatne sezone pređene | 59.2 · 592 | 43.3 · 649 | 24.4 · 610 | 15.6 · 622 |
| sve besplatne nadogradnje max | 61.1 · 611 | 42.7 · 641 | 24.8 · 620 | 16.0 · 639 |
| svi izgledi za coine | 63.3 · 633 | 46.6 · 698 | 27.0 · 676 | 17.6 · 705 |
| kraj besplatnog sadržaja | 63.8 · 638 | 46.6 · 698 | 27.0 · 676 | 17.6 · 705 |
| u granici (2500 runova) | 0 / 10 | 0 / 10 | 0 / 10 | 0 / 10 |

### skilled · boost (dan · min igre)

| Milestone | 10 min/dan | 15 min/dan | 25 min/dan | 40 min/dan |
|---|---|---|---|---|
| country_bloom level 20 pređen | 5.5 · 55 | 3.8 · 57 | 2.5 · 63 | 1.5 · 60 |
| frost_orchard otključan | 11.1 · 111 | 7.2 · 109 | 4.8 · 120 | 3.0 · 122 |
| frost_orchard level 20 pređen | 16.6 · 166 | 11.4 · 170 | 7.3 · 182 | 4.3 · 171 |
| lantern_meadow otključan | 22.1 · 221 | 15.0 · 225 | 9.8 · 244 | 5.8 · 234 |
| lantern_meadow level 20 pređen | 28.1 · 281 | 19.1 · 287 | 12.1 · 301 | 7.5 · 299 |
| amber_canopy otključan | 35.9 · 359 | 24.2 · 363 | 15.3 · 382 | 9.6 · 383 |
| amber_canopy level 20 pređen | 40.8 · 408 | 27.9 · 418 | 17.6 · 439 | 10.9 · 437 |
| sve besplatne sezone pređene | 40.8 · 408 | 27.9 · 418 | 17.6 · 439 | 10.9 · 437 |
| sve besplatne nadogradnje max | 42.5 · 425 | 29.3 · 440 | 18.4 · 459 | 11.4 · 455 |
| svi izgledi za coine | 47.8 · 478 | 33.5 · 502 | 20.6 · 516 | 13.0 · 519 |
| kraj besplatnog sadržaja | 47.8 · 478 | 33.5 · 502 | 20.6 · 516 | 13.0 · 519 |
| u granici (2500 runova) | 0 / 10 | 0 / 10 | 0 / 10 | 0 / 10 |

## C2. Zid za casual igrača

Leveli gdje casual prolazi < 10 % (dio A: sezona sa svih 6 tipova, bez nadogradnji; nadogradnje u modelu ne smanjuju rizik prepreka, pa ovo važi za svaku sezonu).

| Level | casual prolaz % | casual pokušaja | casual min do prolaza | average prolaz % | skilled prolaz % |
|---|---|---|---|---|---|
| 15 | 7.0 | 14 | 16 | 30 | 53 |
| 16 | 4.0 | 25 | 26 | 25 | 44 |
| 17 | 2.0 | 50 | 46 | 20 | 44 |
| 18 | 0.8 | 133 | 119 | 9 | 32 |
| 19 | 0.8 | 133 | 112 | 8 | 34 |
| 20 | 0.5 | 200 | 160 | 3 | 21 |
| ukupno | — | 556 | 480 | — | — |

Samo zid (očekivane minute pokušaja, bez ostatka puta): 10 min/dan → 48 d po sezoni, 192 d za 4 sezone; 15 min/dan → 32 d po sezoni, 128 d za 4 sezone; 25 min/dan → 19 d po sezoni, 77 d za 4 sezone; 40 min/dan → 12 d po sezoni, 48 d za 4 sezone.

Casual putovanja koja pređu L20 (x / putovanja; „ostali" = raspon levela na kojem su ostala kad je putovanje stalo):

| Sezona | B rush · 25 min | B boost · 25 min | B looks · 25 min | C boost · 10 min | C boost · 15 min | C boost · 25 min | C boost · 40 min |
|---|---|---|---|---|---|---|---|
| country_bloom | 3 / 10 (ostali L19–20) | 3 / 10 (ostali L20) | 6 / 10 (ostali L20) | 6 / 10 (ostali L19–20) | 7 / 10 (ostali L19–20) | 7 / 10 (ostali L20) | 6 / 10 (ostali L20) |
| frost_orchard | 6 / 10 (ostali L19–20) | 1 / 10 (ostali L20) | 3 / 10 (ostali L19–20) | 3 / 10 (ostali L19–20) | 3 / 10 (ostali L19–20) | 4 / 10 (ostali L19–20) | 4 / 10 (ostali L20) |
| lantern_meadow | 7 / 10 (ostali L20) | 1 / 10 (ostali L19–20) | 3 / 10 (ostali L19–20) | 4 / 10 (ostali L20) | 4 / 10 (ostali L19–20) | 1 / 10 (ostali L19–20) | 4 / 10 (ostali L19–20) |
| amber_canopy | 10 / 10 | 9 / 10 (ostali L20) | 7 / 10 (ostali L20) | 8 / 10 (ostali L19–20) | 9 / 10 (ostali L20) | 8 / 10 (ostali L20) | 8 / 10 (ostali L20) |
| sve 4 sezone | 2 / 10 | 0 / 10 | 0 / 10 | 3 / 10 | 2 / 10 | 1 / 10 | 1 / 10 |

## A, A2 i B — isto kao 1b

Dijelovi A, A2 i B su red po red isti kao u [[02-design/balans-ciklus-1b-simulacija|balans-ciklus-1b-simulacija]] (provjereno diffom, isti seed, dan = 25 min). Jedino novo je red „sve besplatne sezone pređene" u svakoj tabeli dijela B (u B se igrač ne vraća na nepređene levele nižih sezona):

| Profil · politika | Dan | Min igre | Runova | Dostiglo |
|---|---|---|---|---|
| casual · rush | 84.9 | 2124 (2020–2124) | 2298 | 2 / 10 |
| casual · boost | — | — | — | 0 / 10 |
| casual · looks | — | — | — | 0 / 10 |
| average · rush | 19.0 | 475 (398–541) | 365 | 10 / 10 |
| average · boost | 23.2 | 581 (545–668) | 335 | 10 / 10 |
| average · looks | 27.8 | 695 (688–772) | 432 | 10 / 10 |
| skilled · rush | 11.8 | 294 (279–314) | 156 | 10 / 10 |
| skilled · boost | 17.4 | 436 (415–481) | 196 | 10 / 10 |
| skilled · looks | 20.8 | 519 (501–552) | 213 | 10 / 10 |

## Cijene u igri (iz podataka)

- Sezone: frost_orchard 2500 C + 22 ★3, lantern_meadow 4500 C + 26 ★3, amber_canopy 6500 C + 30 ★3
- Nadogradnja po nivou (svaka od 3 staze, po sezoni): 100 C + 2 ★3 → 250 C + 2 ★3 → 500 C + 3 ★3 → 800 C + 3 ★3
- Izgledi za coine: journal_gold 800, meadow_sunset 1000, meadow_lavender 1200, pip_sky 2000, pip_blossom 2500
- Magnet radijus po nivou: 40, 95, 150, 205, 260
- Level Path nagrade: 5: 2 ★3 + 200 C, 10: 4 ★3 + 400 C, 15: 6 ★3 + 600 C, 20: 10 ★3 + 1000 C
- Dnevni poklon: 75 C + 5 sjemena

## Povezano

- [[06-production/procjena-igraca|procjena-igraca]]
- [[02-design/balans-ciklus-1b-simulacija|balans-ciklus-1b-simulacija]]
- [[02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]]
- [[02-design/_index|02-design]]
