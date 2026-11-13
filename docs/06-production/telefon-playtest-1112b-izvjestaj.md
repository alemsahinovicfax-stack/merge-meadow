---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, izvjestaj]
povezano:
  - plan-telefon-playtest-1112b
  - telefon-playtest-1112-izvjestaj
  - play-uploads
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "FIX-TEL-3 izvještaj (2026-11-12): treći krug prijava s telefona — Arena štekanje pri tapu na vreću (korpa se crtala u svakom frejmu, save na disk usred leta, 90 čvorova po sipanju), Level Path pušta swipe i gasi se pri odlasku s Homea, Journal ★T1 odmah iz runa, Muncher jači, pragovi sezona 30 / 35 / 40, Boostovi po levelu u T3 cvjetovima. Šta je mjereno na laptopu, šta nije potvrđeno na telefonu, lista za ručnu provjeru."
---

# FIX-TEL-3 — izvještaj trećeg kruga (build 13)

> Roditelj: [[06-production/_index|06-production]] · Plan: [[plan-telefon-playtest-1112b|plan-telefon-playtest-1112b]] · Prethodni krug: [[telefon-playtest-1112-izvjestaj|telefon-playtest-1112-izvjestaj]] · 2026-11-12

## 1. Ukratko

Svih 7 stavki je urađeno u kodu. Novi AAB je **version code 13** (verzija 1.0.1). **Ništa nije provjereno na pravom telefonu** — mjereno i testirano na laptopu. Tvoj korak je § 6.

Dvije stvari traže tvoju odluku, vidi § 5: četvrti broj praga sezona (50) nema gdje da stane, i coini uz nove cijene Boostova su ostali (potvrđeno 2026-11-13: coini ostaju).

## 2. Šta je urađeno

| # | Prijava | Šta je sada | Kako je provjereno |
|---|---------|-------------|--------------------|
| 1 | Arena baš šteka kad tapnem vreću dok sjemenke lete | Četiri uzroka uklonjena, vidi § 3 | Mjerenje `arena_bag_tap_bench`, testovi `arena_pour_light_smoke`, `save_async_smoke` |
| 2 | S Level Patha ne mogu swipeati na Camp / Journal | Vodoravan potez preko puta mijenja stranicu; uspravan i dalje skrola put | Test `level_path_swipe_smoke` (pravi dodir) |
| 3 | Poslije odlaska na drugu stranicu Level Path treba biti ugašen | Kad Home izađe iz vida, put se ugasi; povratak pokazuje polje. Povratak iz runa i dalje otvara put | Isti test |
| 4 | Journal se ne updejtuje kad u novoj sezoni pokupim prva sjemena | Sjeme pokupljeno u runu odmah upisuje tier 1 te vrste, s oznakom NEW. Tier 2 se upisuje prvim spajanjem u T2 u Areni, tier 3 prvim T3 | Test `journal_run_seed_smoke` |
| 5 | Muncher preslab | Zaleđen 1 s (bilo 2), brzina 110,5 px/s (bilo 85, +30 %). Tekstovi kažu „1s" | Test `muncher_rig_smoke` |
| 6 | Prag sjemenki za sezone 30, 35, 40, 50 | Frost Orchard 30, Lantern Meadow 35, Amber Canopy 40 (bilo 22, 26, 30). Themes i dalje samo coini | Test `boost_price_smoke` |
| 7 | Cijene Boostova | Level 1: 5 × T3 prvog ljubičastog cvijeta sezone. Level 2: 10 × T3 drugog ljubičastog. Level 3: 2 × T3 zlatnog. Level 4: 5 × T3 zlatnog. Dugme pokazuje cvijet koji taj level traži | Test `boost_price_smoke` (svih 8 sezona) |

Koji cvijet plaća koji level:

| Sezona | Level 1 (×5) | Level 2 (×10) | Level 3 (×2) i 4 (×5) |
|--------|--------------|---------------|------------------------|
| Country Bloom | Barn Tulip | Sunfence | Harvest Pumpkin |
| Frost Orchard | Winter Camellia | Hoarfrost Rose | Crystal Peony |
| Lantern Meadow | Foxfire Lily | Glow Wisteria | Midnight Lotus |
| Amber Canopy | Cider Dahlia | Golden Oak Bloom | Amber Magnolia |
| Moonlit Warren | Lunar Orchid | Star Jasmine | Umbral Lily |
| Coral Tide | Coral Hibiscus | Pearl Waterlily | Reef Crown |
| Starfall Glade | Aurora Tulip | Galaxy Sunburst | Nova Bloom |
| Ember Fen | Flame Iris | Smoke Lotus | Fenfire Crown |

## 3. Arena — šta je stvarno štekalo

Nije bio jedan uzrok nego četiri, i sva četiri padaju baš u vrijeme dok sjemenke lete.

| Uzrok | Koliko je koštalo (laptop) | Šta je sada |
|-------|----------------------------|-------------|
| **Korpa se crtala u svakom frejmu dok se klati** (pleter + 12 cvjetova). Klati se čim u vreći ima sjemena, dakle cijelu rundu | +1,4 ms po frejmu, stalno | 0 crtanja; korpa se okreće bez ponovnog crtanja |
| **Save na disk pola sekunde poslije svakog sipanja**, na glavnoj niti (5 operacija nad fajlovima). Let sjemenki traje do 1,6 s, pa save padne usred leta | 7 ms u jednom frejmu | Pisanje ide u pozadinsku nit; na glavnoj ostaje oko 0,4 ms |
| **Svako sipanje je dvaput iscrtalo cijelu korpu** (zbog promjene broja) | 2 × 4,9 ms | Mijenja se samo broj u svom sloju |
| **30 sjemenki = 90 čvorova u jednom frejmu** | 6–9 ms | 30 čvorova; crtež sjemenke nastaje kad dođe njen red u letu |
| Prvi crtež svake vrste cvijeta čita teksturu nazad s grafičke kartice | prvo sipanje 23 ms umjesto 7 | Rub crteža je u gotovoj tabeli |

Mjereno istim alatom prije i poslije (medijan, laptop, s crtanjem):

| | Prije | Poslije |
|---|-------|---------|
| Prvi frejm poslije sipanja 30 sjemenki | 9–14 ms | 5,5–6,1 ms |
| Najgori frejm tokom leta | oko 9,3 ms | oko 7,3 ms |
| Prvi frejm poslije dosipanja usred leta | oko 12,5 ms | oko 4,8 ms |
| Sam poziv tapa koji sipa 30 | 7–9 ms | 7–9,5 ms (nije se promijenio) |
| Tap dok je polje puno | 0,4 ms | 0,4 ms (nikad nije bio problem) |

Šta ovo znači i šta ne znači:

- Na laptopu se štekanje ni prije nije vidjelo; brojevi su mali. Telefon je obično 4–8 puta sporiji, pa su tamo ovi troškovi prelazili jedan frejm. To je procjena, ne mjerenje.
- **Sam tap koji sipa 30 sjemenki i dalje košta 7–9 ms na laptopu** (pravljenje 30 sjemenki, razmicanje, buđenje Munchera). To nisam uspio smanjiti bez diranja pravila runde. Na telefonu bi to mogao biti jedan kratak trzaj u trenutku tapa. Ako ga i dalje osjetiš, sljedeći korak je sipati sjemenke u grupama kroz nekoliko frejmova.
- Laptop je tokom mjerenja bio opterećen, pa pojedinačna mjerenja variraju; zato su u tabeli rasponi.

Usput: alat `redraw_audit` je prošao svih pet stranica huba i tražio isto (čvor koji se crta u svakom frejmu). Drugi takav skup slučaj nije našao.

## 4. Odluke koje sam donio umjesto tebe

| Odluka | Zašto | Kako se mijenja |
|--------|-------|-----------------|
| **Level Path se gasi 0,35 s poslije odlaska s Homea**, ne odmah | Da se ne ugasi pred očima dok stranica još klizi. Ako se u tih 0,35 s vratiš, put ostaje | `HOME_LEFT_DELAY_SEC` u `meta_hub_controller.gd` |
| **Povratak iz runa i dalje otvara put** | Tamo nastavljaš igrati sljedeći level; tražio si gašenje samo kad odeš na drugu stranicu | — |
| **Tier 2 u Journalu se upisuje prvim spajanjem u T2** | Rekao si da se tier 2 i 3 otključavaju spajanjem u Areni; do sada se T2 nije upisivao nigdje | — |
| **Stari save: vrsta čije si sjeme već pokupio dobija tier 1 pri učitavanju**, bez oznake NEW | Da ti Journal ne ostane prazan za ono što si već skupio | — |
| **Gomila u korpi se više ne smanjuje na tren dok cvjetovi izlijeću** | Taj detalj je tražio dva puna crtanja korpe po sipanju | — |
| **Napomena „Uses flowers saved for …" na Boostovima se javlja samo za level 3 i 4** | Samo oni troše zlatni cvijet koji čeka sljedeća sezona | — |

## 5. Šta trebam od tebe

| Pitanje | Šta sam uradio | Šta mijenja tvoj odgovor |
|---------|----------------|---------------------------|
| **Prag 50:** naveo si 30, 35, 40 i 50, a Journey ima četiri sezone, dakle tri otključavanja | Postavio 30 / 35 / 40. Broj 50 nije nigdje upisan | Ako 50 treba za nešto poslije Amber Canopyja (npr. prelaz na Themes), reci za šta |
| **Coini uz Boostove:** naveo si samo cvijeće | Ostavio coine kao do sada (100 / 250 / 500 / 800), uz novo cvijeće | **Odlučeno 2026-11-13:** coini ostaju uz cvijeće |
| **Ljubičasti cvjetovi se mogu prodati u Campu** bez upozorenja | Nisam dirao. Zlatni ima „Kept" zaštitu za sljedeću sezonu, ljubičasti nema | Ako hoćeš istu zaštitu za cvijeće koje traže Boostovi, to je nova stavka |

## 6. Šta ti radiš

1. Upload `game\export\android\merge_meadow.aab` (code 13) na internal test.
2. Prođi listu:
   - [ ] **Arena:** tapkaj vreću dok sjemenke lete, i odmah poslije — šteka li i dalje? Ako da, kada tačno: u trenutku tapa ili pola sekunde kasnije?
   - [ ] **Arena:** Muncher je brži; T3 ga zaledi 1 s. Je li sada pretežak?
   - [ ] **Home:** s otvorenog Level Patha potez lijevo i desno mijenja stranicu; gore-dolje i dalje skrola put
   - [ ] **Home:** otvori Level Path, idi na Camp, vrati se — vidi se polje
   - [ ] **Journal:** u sezoni u kojoj još nemaš ništa pokupi sjeme u runu — vrsta je u Journalu s NEW
   - [ ] **Journal:** prvo spajanje u T2 neke vrste otključa tier 2
   - [ ] **Camp:** kartica sljedeće sezone traži 30 / 35 / 40
   - [ ] **Boosts:** level 1 traži 5 prvog ljubičastog cvijeta, level 2 deset drugog, level 3 i 4 zlatni
   - [ ] Zatvori i otvori igru poslije runde u Areni — napredak je sačuvan (save sada piše u pozadini)
3. Dodaj red u [[play-uploads|play-uploads]] (i za code 11 i 12 ako su uploadani).
4. Javi šta ne prolazi.

## 7. Šta nije riješeno ili nije potvrđeno

| Stavka | Stanje |
|--------|--------|
| Sve iz § 2 na pravom telefonu | Nije provjereno — samo laptop |
| Arena: trzaj u trenutku tapa koji sipa 30 sjemenki | Poziv je i dalje 7–9 ms na laptopu; ostali uzroci su uklonjeni |
| Save u pozadinskoj niti na Androidu | Testiran na laptopu (`save_async_smoke`); na telefonu nije |
| Home polje: ambijent (čestice) se crta u svakom frejmu | Namjerno (animacija), nije dirano |
| Testovi zavise od savea | Otvoreno od prvog kruga: 6 Camp testova pada s kopijom tvog savea, a `arena_round_cap_smoke` i `arena_nav_lock_smoke` padaju na praznom saveu |
| Sve otvoreno iz [[telefon-playtest-1112-izvjestaj|drugog kruga]] § 6 | Bez promjene |

## 8. Rezultat kapije

`scripts/release-check.ps1`, 2026-11-13, 19,1 min → **RELEASE OK**

| Korak | Rezultat |
|-------|----------|
| SVG tekst | 168 / 168 u paketu |
| GUT | prolazi (broj testova nije ostao u ispisu koji sam sačuvao) |
| Smoke testovi | 87 / 93 s kopijom tvog savea; preostalih 6 (svi Camp, isti kao u prethodna dva kruga) prolaze na čistom saveu → nijedan ne pada u oba |
| Testovi iz exportovanog paketa | prolaze |
| Version code | 13 |
| AAB | `game\export\android\merge_meadow.aab`, 69,2 MB, data JSON 16 / 16, bez test fajlova |

Napomene:

- Kapija je trajala 19 min umjesto 13 jer je laptop bio opterećen; to nije greška.
- Kapija na početku briše stari `merge_meadow.aab`, pa AAB code 12 više nije u folderu.

## 9. Novi alati i testovi

- `scripts/dev/arena_bag_tap_bench.gd` — cijena tapa na vreću i frejmova poslije njega (prazno polje, puno polje, dosipanje usred leta)
- `scripts/dev/redraw_audit.gd` — koji se čvorovi crtaju u svakom frejmu, po stranicama huba
- `scripts/dev/flower_crop_gen.gd` — generiše tabelu rubova crteža cvjetova; **pokreni poslije svake izmjene SVG-ova cvjetova**
- Testovi: `arena_pour_light_smoke`, `save_async_smoke`, `level_path_swipe_smoke`, `journal_run_seed_smoke`, `boost_price_smoke`
- Katalog grešaka #71–#74

## Povezano

- [[plan-telefon-playtest-1112b|plan-telefon-playtest-1112b]]
- [[telefon-playtest-1112-izvjestaj|telefon-playtest-1112-izvjestaj]]
- [[play-uploads|play-uploads]]
- [[../05-technical/godot/greske-katalog|greske-katalog]]
- [[CHECKPOINT|CHECKPOINT]]
