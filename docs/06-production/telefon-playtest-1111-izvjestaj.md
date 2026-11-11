---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, izvjestaj]
povezano:
  - plan-telefon-playtest-1111
  - play-uploads
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "FIX-TEL izvještaj (2026-11-11): šta je popravljeno poslije prvog playtesta na telefonu (skinovi / Nibbs u buildu, svi omjeri ekrana, dodir, Continue, kraj merge runde, Camp, Journal), šta NIJE potvrđeno na pravom telefonu, kapija release-check.ps1 i lista za ručnu provjeru."
---

# FIX-TEL — izvještaj poslije prvog playtesta na telefonu

> Roditelj: [[06-production/_index|06-production]] · Plan: [[plan-telefon-playtest-1111|plan-telefon-playtest-1111]] · Uploadi: [[play-uploads|play-uploads]] · 2026-11-11

## 1. Ukratko

Većina bugova je imala **tri uzroka**, i sva tri su se mogla reprodukovati na kompjuteru tek kad je igra pokrenuta kao na telefonu (iz exportovanog paketa, u visokom prozoru, s dodirom):

1. **U buildu nije bilo SVG fajlova** iz kojih se crtaju novi Pip, skinovi i Nibbs → na telefonu ih nije bilo nigdje.
2. **Ekran telefona je viši** od onog za koji su stranice crtane → bijela traka, kontrole „na sredini", lista koja ne ide do dna.
3. **Dugmad i kartice su „jeli" dodir** → Shop nije skrolao; u Areni je dodir računat u pogrešnim koordinatama → sjeme je skakalo u ugao.

Novi AAB je **version code 11** (verzija 1.0.1). **Ništa od ovoga još nije provjereno na pravom telefonu** — to je tvoj korak (§ 5).

## 2. Šta je popravljeno

| # | Prijava | Stanje | Kako je provjereno |
|---|---------|--------|--------------------|
| 1 | Stare slike Pipa, novih nema | Popravljeno | Test iz exportovanog paketa: atlas svakog skina ima slike |
| 2 | Skinova nema (Shop, inventar, run) | Popravljeno | Isto; svaki skin iz kataloga daje teksturu |
| 3 | Nibbs se ne vidi u Areni | Popravljeno | Isto; atlas Nibbsa ima slike |
| 4 | Level Path: 20 % ekrana bijelo | Popravljeno | Slika na 1080 × 2400 prije / poslije |
| 5 | Home: inventar gore prema sredini | Popravljeno („Looks" je dolje desno) | Slika na 1080 × 2400 |
| 6 | Camp: polje za trejd staje na pola | Popravljeno (do dna) | Slika na 1080 × 2400 |
| 7 | Shop: skrol ne radi preko kartica i dugmadi | Popravljeno | Test s pravim dodirom: povlačenje s dugmeta i s kartice skrola, tap i dalje kupuje |
| 8 | Obrub oko coina u headeru neprecizan | Popravljeno | Uzrok nađen u kodu (kontejner je pomjerao prsten); **nije slikano** |
| 9 | Arena: sjeme skoči gore lijevo | Popravljeno | Test s pravim dodirom: sjeme prati prst |
| 10 | Merge runda nema oznaku kraja | Dodano: „Round over" + ishod („3 blooms made" / „Nibbs ate the rest") | Postojeći testovi Arene prolaze; **izgled nije slikan** |
| 11 | „Retry" poslije pređenog levela | Sada „Continue" (pad i Endless ostaju „Retry") | Testovi loot ekrana prolaze |
| 12 | Camp: animacija coina šteka | Djelimično: novčići se više ne prave i brišu po trejdu | **Nije mjereno na telefonu** — vidi § 4 |
| 13 | Camp: zastarjela ikona u „Open meadow" | Popravljeno (SVG strelica umjesto znaka „↗") | Testovi Campa prolaze |
| 14 | Journal šteka pri svakom ulasku | Popravljeno u kodu: gradi se u pozadini, ne ruši se | Mjerenje na laptopu: ulazak 7–20 ms → ~4 ms; **telefon nije mjeren** |
| 15 | Home šteka pri ulasku | **Nije dirano** — izmjereno 4–9 ms na laptopu | Vidi § 4 |

## 3. Prilagodljivost ekranu (telefoni i tableti)

- **Visoki telefoni (19,5:9, 20:9, 21:9):** stranica raste u visinu; Level Path, Home polje, Camp, Shop, Journal i Arena su slikani na 1080 × 2400 i izgledaju ispravno.
- **Tableti (16:10, 4:3):** igra je portrait stupac u sredini, **sa strane su trake** (boja pozadine sistema). Sve radi i ništa nije odsječeno, ali strane nisu ukrašene. Ranije sam najavio pozadinu sezone sa strane — to **nije urađeno**: tražilo bi da svaka scena zna za širi ekran, što je prevelik zahvat pred closed test. Ostaje kao otvorena stavka.
- **Home kartica sezone** na visokom telefonu ima prazan prostor između kartice i tačkica — radi, ali nije najljepše. Otvorena stavka.
- Alat: `scripts/screen-matrix.ps1` slika sve stranice na 6 omjera u `%TEMP%\\mm_matrix`.

## 4. Šta nije riješeno ili nije potvrđeno

| Stavka | Zašto | Šta dalje |
|--------|-------|-----------|
| Štekanje na pravom telefonu (Journal, Home, Camp trejd) | Mjereno samo na laptopu, bez crtanja | Probaj build 11; ako Journal i dalje šteka → CD redizajn (harmonika po sezonama), prompt je u planu § 5 |
| Home ulazak (4–9 ms na laptopu) | Nije dirano; najveći dio je osvježavanje pozornice sezone (~2,2 ms) | Sljedeća meta ako se osjeti na telefonu |
| Camp i Shop ulazak (5–8 ms na laptopu) | Otkriveno mjerenjem, nije u prijavi | Isto |
| Camp trejd: kartica sezone se osvježava pri svakom trejdu | Postojeći test traži da se mijenja usred držanja, pa nije usporeno | Ako šteka na telefonu: pojeftiniti samo osvježavanje brojeva |
| Tableti: ukrasne strane | Vidi § 3 | Poseban zadatak |
| Harmonika sezona u Journalu | Nije rađena — prvo vidjeti da li gradnja u pozadini rješava štekanje | Odluka poslije builda 11 |
| 6 Camp testova pada s kopijom tvog savea | Padali su i prije današnjih izmjena (samostalna Camp scena se s tvojim saveom preusmjeri u hub); na čistom saveu prolaze | Kapija zato vrti testove na čistom saveu (`-CleanSave`) |

## 5. Šta ti radiš

1. Upload `game\\export\\android\\merge_meadow.aab` (code 11) na internal test.
2. Prođi listu (5 min):
   - [ ] Home: Pip je novi, „Looks" dolje desno, Level Path do dna ekrana
   - [ ] Shop → Looks: skinovi se vide; skrol prstom preko kartica i dugmadi; tap kupuje ili javlja „Need N more coins"
   - [ ] Shop bez coina: prsten tačno oko coin čipa u headeru
   - [ ] Ormar: obuci skin → isti skin na Homeu i u runu
   - [ ] Run: pređi level → „Continue"; padni → „Retry"
   - [ ] Arena: Nibbs se vidi; sjeme prati prst i spaja se; na kraju runde „Round over"
   - [ ] Camp: lista i Trade bar do dna; drži Trade — šteka li?; prazna vreća → ikona strelice
   - [ ] Journal: ulazak bez zastoja, i poslije novog cvijeta
   - [ ] Okreni kroz svih 5 tabova 3 puta — šteka li?
   - [ ] Zatvori i otvori igru — napredak je tu
3. Dodaj red u [[play-uploads|play-uploads]].
4. Javi šta od liste ne prolazi (i model telefona, zbog omjera ekrana).

## 6. Kako se ovo više ne ponavlja

- **`scripts/release-check.ps1`** — jedna skripta prije svakog uploada. Pada na prvoj grešci; upload samo kad piše `RELEASE OK`. Koraci: SVG tekst → GUT + svi smoke testovi na čistom saveu → **isti testovi pokrenuti iz exportovanog paketa** → version code veći od zadnjeg uploadanog → AAB + provjera sadržaja → lista za ručnu provjeru.
- **`scripts/phone-like-run.ps1`** — igra iz paketa u prozoru omjera telefona. Bug s telefona se prvo reprodukuje ovdje.
- **`scripts/screen-matrix.ps1`** — slike na 6 omjera.
- Novi testovi: `svg_source_smoke`, `touch_scroll_smoke` (pravi dodir), `hub_switch_bench` (mjerenje ulaska na stranice).
- Pravila su upisana u `CLAUDE.md` (§ Build za Play) i `greske-katalog` #63–#66.

## 7. Rezultat kapije

`scripts/release-check.ps1`, 2026-11-11, 18,9 min → **RELEASE OK**

| Korak | Rezultat |
|-------|----------|
| SVG tekst | 168 kopija, `svg_source_smoke` prolazi |
| GUT | 149 / 149 |
| Smoke testovi | 80 / 86 s kopijom tvog savea; preostalih 6 (svi Camp) prolaze na čistom saveu → nijedan ne pada u oba |
| Testovi iz exportovanog paketa | `svg_source_smoke`, `touch_scroll_smoke`, `shop_open_smoke` prolaze |
| Version code | 11 (zadnji uploadan 10) |
| AAB | `game\export\android\merge_meadow.aab`, 69,1 MB, SVG tekst 168 / 168, data JSON 16 / 16, bez test fajlova |

Napomene:

- **Testovi zavise od savea.** 6 Camp testova pada s kopijom tvog trenutnog savea, a 3 druga (`arena_nav_lock_smoke`, `fixes_1016_smoke`, `levels_endless_smoke`) padaju na potpuno čistom saveu — oboje je tako bilo i prije današnjih izmjena. Kapija zato obara build samo za test koji padne u oba okruženja. Otvoren zadatak: svaki test sa svojim saveom.
- **GUT je do sada pisao u tvoj pravi save folder** (test atomarnog savea). Save je provjeren i ispravan (2740 coina, 54 polja); kapija od sada pokreće GUT na kopiji. `scripts/gut-run.ps1` pokrenut ručno i dalje koristi pravi folder.
- Slike na tabletima i izgled „Round over" pilule nisu pregledani okom — samo testovima.

## Povezano

- [[plan-telefon-playtest-1111|plan-telefon-playtest-1111]]
- [[play-uploads|play-uploads]]
- [[../05-technical/godot/greske-katalog|greske-katalog]]
- [[CHECKPOINT|CHECKPOINT]]
