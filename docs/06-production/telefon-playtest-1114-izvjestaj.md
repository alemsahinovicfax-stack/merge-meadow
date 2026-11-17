---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, balans, izvjestaj]
povezano:
  - plan-telefon-playtest-1114
  - telefon-playtest-1112b-izvjestaj
  - CHECKPOINT
  - play-uploads
ai_sažetak: "FIX-TEL-4 izvještaj (2026-11-14): 25 levela po sezoni (peti pojas Blitz, put viši 1030 px), level najviše 2 min, pragovi Journey sezona 40 / 45 / 50, sanduci Level Patha po novom redu cvijeća (+2000 coina na 25), Endless Pace korak × 1,1 i spawn × 1,2, Boost dugme u boji tiera s portretom 96 px. AAB code 14. Ništa nije provjereno na telefonu; simulacija ekonomije nije ponovo puštena."
---

# FIX-TEL-4 — izvještaj (balans i 25 levela)

> Roditelj: [[06-production/_index|06-production]] · Plan: [[plan-telefon-playtest-1114|plan-telefon-playtest-1114]] · 2026-11-14

## 1. Ukratko

Svih šest zahtjeva je urađeno. Claude Design nije trebao: put je produžen istim kamenjem, sanducima i pozadinom, a peti pojas („Blitz", 21–25) je crtež po uzoru na postojeća četiri.

Na telefonu ništa nije provjereno. Simulacija ekonomije (`economy_sim.gd`) nije ponovo puštena, pa koliko dana sada traje put do svake sezone nije izmjereno.

## 2. Šta je urađeno

| # | Zahtjev | Šta je sada |
|---|---------|-------------|
| 1 | Pragovi Journey sezona +10 | Frost Orchard 40, Lantern Meadow 45, Amber Canopy 50 zlatnih cvjetova prethodne sezone (bilo 30 / 35 / 40). Themes i dalje samo coini |
| 2 | Level najviše 2 minute | Leveli 1–19 kao prije (1:00–1:56), leveli 20–25 traju 2:00. Kod reže sve preko 120 s, ma šta pisalo u tabeli |
| 3 | 25 levela po sezoni | Jedna tabela važi za sve sezone (Journey i Themes). Leveli 21–25 nastavljaju isti korak kojim rastu 16–20 |
| 4 | Sanduci | 5: 10 × prvi ljubičasti · 10: 15 × drugi ljubičasti · 15: 20 × drugi ljubičasti · 20: 5 × zlatni · 25: 10 × zlatni + 2000 coina. Coini na 5–20 ostaju 200 / 400 / 600 / 1000 |
| 5 | Endless | Svaki prebačaj Pacea diže težinu 10 % više nego do sada; prepreke i pickupi dolaze 20 % češće |
| 6 | Boost dugme | Ljubičasto kad se plaća ljubičastim cvijetom, zlatno kad se plaća zlatnim; portret cvijeta 96 px u krem disku (bio 64 px) |

## 3. Detalji

### Leveli 21–25

| Level | Brzina | Rampa / 15 s | Razmak spawna | Prepreke | Parovi |
|-------|--------|--------------|---------------|----------|--------|
| 20 | × 1,375 | 3,88 % | 0,85 s | 37,4 % | 40 % |
| 21 | × 1,39 | 3,95 % | 0,83 s | 38,9 % | 42 % |
| 22 | × 1,405 | 4,03 % | 0,80 s | 40,4 % | 44 % |
| 23 | × 1,42 | 4,10 % | 0,78 s | 41,8 % | 46 % |
| 24 | × 1,435 | 4,18 % | 0,76 s | 43,3 % | 48 % |
| 25 | × 1,45 | 4,25 % | 0,73 s | 44,8 % | 50 % |

Na levelu 25 svaka druga prepreka zatvara dvije staze. Ako to na telefonu bude previše, parove treba spustiti prije brzine.

### Level Path

- Sadržaj je viši za 1030 px (5930 umjesto 4900). Kamenje 1–19 i ruta do kamena 19 su netaknuti; kamenje 21–25, ruta od 19 nagore i sanduk na 20 su izračunati istim postupkom kao original (provjera: moj proračun stare rute se s originalom slaže do 1 px).
- Veliki sanduk i zastavica cilja su sada na 25. Sanduk na 20 je običan.
- Pločica na vrhu piše „N / 25", traka na kraju „Play repeats Level 25".
- Pozadina sezone je razvučena s putem; broj rasutog dekora (trava, cvjetići) je povećan da gustina ostane ista.
- **Stari save:** ko je završio put (20 / 20), sada stoji na levelu 21 i nastavlja. Uzeti sanduci ostaju uzeti; neuzeti sanduk daje novu nagradu.
- Popup nagrade pokazuje pravi cvijet i pravu oznaku (★2 za ljubičasti, ★3 za zlatni).

### Endless

- Korak težine po Paceu je × 1,1: na početku svaki Pace dodaje 0,073 brzine umjesto 0,067; poslije zadnjeg ključa tabele 0,044 umjesto 0,04. Start je isti kao prije (× 1,15).
- Razmak spawna je podijeljen s 1,2 (na startu 0,92 s umjesto 1,10 s). Pošto prepreke i pickupi dijele isti takt, oboje dolaze 20 % češće.
- Zbog jačeg koraka Endless ranije stiže do gornjih granica (45 % prepreka, 45 % parova): oko Pacea 19 umjesto 21.

### Boost dugme

- „× N" je u gornjem redu, coini ispod; portret je lijevo.
- Kad se ne može kupiti, dugme je blijeda nijansa iste boje, a ono što fali (cvijeće ili coini) je na ružičastoj podlozi kao i prije.

## 4. Odluke koje sam donio

| Odluka | Zašto | Ako nije to |
|--------|-------|-------------|
| „Skoči za po 10" = svaki prag +10 (40 / 45 / 50) | Prošli put si naveo niz koji završava na 50 | Ako si mislio 30 / 40 / 50, to su tri broja u `seasons.json` |
| „10 % jači Pace" = korak svakog prebačaja × 1,1 | Potvrdio si u toku rada | — |
| Peti pojas se zove „Blitz", lavanda | Trebao je peti naziv poslije Stroll / Jog / Dash / Sprint | Ime i boja su jedan red u `ui_levels.gd` |
| Endless se i dalje otključava na levelu 15 | Nisi tražio promjenu | — |
| Coini na sanducima 5–20 nisu dirani | „Neka se samo mijenja cvijeće" | — |

## 5. Šta ovo radi ekonomiji (nije izmjereno)

- Sanduci jedne sezone daju 10 prvog i 35 drugog ljubičastog cvijeta. Boostovi te sezone (sva tri, level 1 i 2) traže 15 prvog i 30 drugog. Dakle sanduci pokrivaju skoro sve ljubičasto za Boostove.
- Zlatnih iz sanduka je 15 (bilo 22), a Boostovi level 3 i 4 traže 21, sljedeća sezona 40–50. Zlatni cvijet je sada osjetno skuplji put.
- Coina iz sanduka je 4200 po sezoni (bilo 2200).

## 6. Šta provjeriti na telefonu

1. Home → Level Path: 25 kamenova, pojas „Blitz 21–25", veliki sanduk i zastavica na vrhu kod 25, put ide do dna ekrana.
2. Stari napredak: ako si imao završen put, sada si na levelu 21 i Play igra level 21.
3. Sanduci: pločica ispod sanduka pokazuje pravi cvijet; Claim daje taj cvijet i coine.
4. Run: level 20 i više traje 2:00.
5. Endless: gušće nego prije, Pace jače steže.
6. Boosts: ljubičasto / zlatno dugme, veliki portret; kupovina radi kao prije.
7. Otključavanje sezone: Frost Orchard traži 40.

## 7. Šta nije potvrđeno

- Ništa od ovoga nije gledano na telefonu.
- Simulacija ekonomije nije ponovo puštena.
- Level Path plaćenih sezona (Themes) nisam mogao slikati jer su u igri „Coming soon"; dijele isti raspored i isti kod kao Journey, čije sam puteve pregledao.
- Puno zlatno Boost dugme (kad se može kupiti) nisam uhvatio na slici; vidio sam puno ljubičasto i blijedo zlatno. Boja dolazi iz iste tabele.
- Testovi `arena_pour_light`, `arena_round_cap`, `arena_nav_lock`, `fixes_1016`, `levels_endless` i `season_home` padaju na praznom saveu, a prolaze s kopijom tvog savea. Prva tri su tako padala i u prošlom krugu; za ostala tri nemam raniji zapis na praznom saveu.

## 8. Kapija

`release-check.ps1` → **RELEASE OK**, verzija 1.0.1, code 14, 12,8 min. GUT 149 / 149; smoke 88 / 94 s kopijom savea, preostalih 6 (Camp) prolazi na čistom saveu, kao u prethodnim krugovima. AAB: `game/export/android/merge_meadow.aab`, 69,2 MB.

**Rupa u kapiji, zatvorena:** prvi prolaz kapije je javio RELEASE OK iako je jedan GUT test pao (`test_levels_endless` je još očekivao četiri pojasa). GUT vraća izlazni kod 0 i kad test padne. `scripts/gut-run.ps1` sada čita ishod i iz ispisa; provjereno namjerno pokvarenim testom (izlaz 1) i ispravnim (izlaz 0). AAB code 14 je napravljen drugim prolazom, poslije ispravke testa. Katalog #75.

## Povezano

- [[plan-telefon-playtest-1114|plan-telefon-playtest-1114]]
- [[play-uploads|play-uploads]]
- [[CHECKPOINT|CHECKPOINT]]
