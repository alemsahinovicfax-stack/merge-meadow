---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, plan]
povezano:
  - plan-telefon-playtest-1112
  - telefon-playtest-1112b-izvjestaj
  - CHECKPOINT
ai_sažetak: "FIX-TEL-3 plan (2026-11-12): treći krug prijava s telefona (build 12) — Arena štekanje pri tapu na vreću, Home Level Path (swipe na susjedne stranice, gašenje pri odlasku), Journal ★T1 odmah iz runa, Muncher jači, pragovi sezona 30/35/40, nove cijene Boostova po levelu. Plan je unaprijed odobren; izvršava se po fazama A–F."
---

# FIX-TEL-3 — treći krug poslije playtesta na telefonu (build 12)

> Roditelj: [[06-production/_index|06-production]] · Prethodni krug: [[plan-telefon-playtest-1112|plan-telefon-playtest-1112]] · 2026-11-12
> **Status: URAĐENO** — AAB code 13. U toku rada nađen i peti uzrok u Areni: korpa se crtala u svakom frejmu dok se klati (katalog #74).
> Plan je odobren unaprijed („dajem ti sve dozvole za planove i izvršavanje unaprijed") — izvršava se odmah, faza po faza. Izvještaj: [[telefon-playtest-1112b-izvjestaj|telefon-playtest-1112b-izvjestaj]].

## Prijave i uzroci (nađeno u kodu i mjerenjem)

| # | Prijava | Uzrok | Faza |
|---|---------|-------|------|
| 1 | Arena: baš šteka kad se tapne vreća dok sjemenke lete | Mjereno (`arena_bag_tap_bench`, laptop): (a) svako sipanje zakaže save 0,5 s kasnije — usred leta — a save je 7 ms rada s diskom na glavnoj niti (5 operacija nad fajlovima); (b) svako sipanje dvaput iscrta cijelu korpu (+4,9 ms po crtanju); (c) 30 sjemenki = 90 čvorova napravljenih u jednom frejmu (6–9 ms); (d) prvi crtež svake vrste cvijeta čita teksturu nazad s grafičke kartice da nađe rub crteža | A |
| 2 | Home: s Level Patha se ne može swipeati na Camp / Journal | Put je namjerno u grupi koja blokira swipe huba (da vertikalni skrol radi) | B |
| 3 | Home: poslije odlaska na drugu stranicu Level Path treba biti ugašen (polje) | Stanje puta se pamti dok je Home učitan | B |
| 4 | Journal: prva sjemena nove sezone iz runa se ne upišu | Journal „viđeno" čita samo `discovered_blooms`, koji se puni tek u Areni; izuzetak je bio lanac Country Blooma | C |
| 5 | Muncher preslab | Zaleđen 2 s, brzina 85 px/s | D |
| 6 | Prag sjemenki za otključavanje sezona: 30, 35, 40, 50 | Sada 22, 26, 30 (tri kapije: Frost, Lantern, Amber) | E |
| 7 | Cijene Boostova po levelu | Sada ★3 cvijet sezone × 2, 2, 3, 3 + coini | E |

## Faze

### Faza A — Arena (glavni dio)
1. **Save van glavne niti:** odgođeni save (onaj 0,5 s poslije sipanja / mergea) složi tekst na glavnoj niti, a pisanje na disk ide u pozadinsku nit. Obični save (promjena scene, pauza, izlaz) ostaje odmah i čeka pozadinski da završi.
2. **Korpa se ne crta ponovo pri sipanju:** tijelo korpe se crta samo kad se promijeni vidljiva gomila ili vrste; broj je u svom sloju.
3. **Sjemenka = jedan čvor pri sipanju:** crtež sjemenke nastaje kad dođe njen red u letu (jedna na 0,04 s), prsten tek kad zatreba.
4. **Rub crteža cvijeta iz tabele:** tabela se generiše jednom (alat), igra više ne čita teksture s grafičke.
5. Vacuum / ostatak T2 ne snimaju odmah, nego odgođeno.
6. Mjerenje prije / poslije istim benchom + test.

### Faza B — Home
7. Level Path pušta horizontalni swipe hubu; vertikalni skrol puta ostaje (odluka po smjeru prvog pomaka).
8. Kad igrač ode s Homea na drugu stranicu, put se ugasi (bez animacije, kad stranica izađe iz vida) — povratak pokazuje polje. Povratak iz runa i dalje otvara put (tamo se nastavlja igrati).

### Faza C — Journal
9. Sjeme pokupljeno u runu odmah upisuje ★T1 (i oznaku NEW) za tu vrstu. T2 se upisuje kad se u Areni prvi put spoji T2, T3 kad se spoji T3. Stari saveovi: vrste s pokupljenim sjemenom dobiju T1 pri učitavanju.

### Faza D — Muncher
10. Zaleđenost 2 s → 1 s; brzina 85 → 110,5 px/s (+30 %). Tekstovi „2s" → „1s".

### Faza E — Ekonomija
11. **Pragovi sezona (Journey):** Frost Orchard 30, Lantern Meadow 35, Amber Canopy 40 ★3 cvjetova prethodne sezone. Četvrti broj (50) nema kapiju — Journey ima četiri sezone, dakle tri otključavanja. Themes ostaju samo coini.
12. **Boostovi (svaka stavka, svaka sezona):** level 1 = 5 × T3 prvog ljubičastog (★2) cvijeta sezone; level 2 = 10 × T3 drugog ljubičastog; level 3 = 2 × T3 zlatnog (★3); level 4 = 5 × T3 zlatnog. Coini uz cvijeće ostaju kao do sada (100 / 250 / 500 / 800).

### Faza F — Provjera
13. Novi / dopunjeni testovi, `smoke-all`, GUT, pa `release-check.ps1` (AAB code 13). Izvještaj.

## Povezano

- [[plan-telefon-playtest-1112|plan-telefon-playtest-1112]]
- [[CHECKPOINT|CHECKPOINT]]
