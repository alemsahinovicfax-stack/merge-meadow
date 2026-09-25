---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, hub, header, footer, ikone, claude-design, izvjestaj]
povezano:
  - hub-chrome-v2-cd-brief
  - hub-header-footer-cd-brief
  - camp-v2-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu paketa design_handoff_hub_chrome_v2 u Godot 2026-09-25: dusk plum trake, footer bez teksta na 144 px, cvijeće umjesto dijamanta i nove ikone coina / sjemena / cvijeta kroz cijelu igru."
---

# Hub chrome pass 2 — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[hub-chrome-v2-cd-brief]] (§ Implementacija) · datum: 2026-09-25

## Ukratko

Okvir igre je prestao biti zelen i prestao je pisati. Sve što si tražio je unutra, plus tri stvari koje su same pale kad su ikone postale prave.

- **Boja je `#2A2233` — dusk plum.** Nasuprot zelenoj na krugu boja, pa trake sada **uokviruju** tamne livade umjesto da izgledaju kao njihova tamnija nijansa. Razlika prema Campu je ΔE 32 (bila 7–18), a peach, zlato i mint na ljubičastoj iskaču.
- **Footer je 144 px** (bio 180) i nosi samo ikone. Dodir je i dalje cijeli slot **216 × 141**, dakle iznad minimuma od 120.
- **Stranica je dobila 36 px** — 1597 → **1633**. Nijedna kartica nije promijenila mjeru.
- **Treći chip broji cvijeće**, ne dijamante.
- **Coin, sjeme i cvijet su nove ikone** i idu kroz cijelu igru — isti fajl u headeru, Campu, Shopu, na Home kartici sezone i kao pickup u runu.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Trake** | Dusk plum `#2A2233`, krem rub 3 px na 55 %, ljubičasta sjena. Header je i dalje 143 px, lanac širina isti. |
| **Chipovi** | Više nisu zlatni / mint / lavanda nego jedan **udubljen tamni well `#1F1926`**, a broj je krem 48. Boju valute sada nosi ikona, pa zlatno-na-zlatnom više ne može nastati. Jedino Settings izgleda kao dugme — izdignut je i svjetliji. |
| **Ikona u chipu** | 64 px (bila 56); broju ostaje istih 190 px, pa `999,999` i dalje staje. |
| **Footer** | Indikator 72 × 8 iznad ikone (bio 196 px), tile 184 × 108, badge viri 6 px desno od tile-a. |
| **Aktivan tab** | Četiri signala odjednom: peach ploča, ikona **u boji** (neaktivne su krem linija), 72 umjesto 64 px i indikator. U grayscale-u ploča drži L 0,57 prema traci 0,02. |
| **Nav lock** | Pilula „ROUND IN PROGRESS" sada na 38 px (bila 26 — ispod minimuma), ikona lokota 34. |
| **Coin** | Zlatni disk s vidljivom debljinom, udubljenim licem, reljefnim listom i sjajem — isti slojevi koje je run ranije crtao sam. Tamni obris drži ga vidljivim i na zlatnoj pilulici cijene. |
| **Seed** | Sjeme koje je upravo puklo i pustilo dva lista — „tek kreće", bez latica, pa se ne miješa s cvijetom. |
| **Flower** | Pet okruglih latica, žuto srce, dva lista — najgeneričniji cvijet, bez oblika koji pripada ijednoj sezoni. |
| **Tabovi** | Shop = tezga s tendom · Journal = zatvorena knjiga s trakom · Home = kuća sa zabatom · Camp = vezana vreća iz koje vire klica i cvijet · Arena = sto s dva kruga koji se dodiruju i iskrom. |

## Gdje je otišlo 36 px

Footer je oslobodio 36 px i svaka stranica ih je upila na jednom mjestu — **nijedna kartica, chip ni dugme nije promijenilo mjeru**.

| Stranica | Gdje |
|---|---|
| Camp | stash sekcija 1253 → **1289** (1549 → 1585 bez kartice sezone); kartica predmeta ostaje 489 × 176 |
| Shop · Journal | duži skrol prozor |
| Arena | polje 1553 → **1589**, u donju marginu (spawn grid ne dobija novi red) |
| Home — polje sezone | livada je flex blok, upila je sama |
| Home — biranje sezone | kartica 1100 → **1136**, sve u art zonu; dock i Play red iste mjere, 36 px niže |

## Šta testirati u igri

1. Prošvrljaj kroz svih 5 stranica — traka se vidi i iznad krem Journala i iznad tamnog Campa.
2. Pogledaj footer bez čitanja: pogodi Camp i Home na prvu. Ako se dvoumiš, to je znak za CD, ne bug.
3. Otvori Arenu i pusti sesiju — nav lock pilula sada ima čitljiv tekst.
4. Journal ima „novo" → badge stoji na uglu tile-a, 6 px izvan.
5. Uđi u run i skupi novčić: to je ista ikona koja stoji u headeru.
6. Camp → Flowers tab: ikona cvijeta je ista kao treći chip u headeru.
7. Prazna korpa na Home polju pokazuje sjeme u boji (bila krem silueta).

## Odstupanja od paketa (namjerna)

- **Novčić u runu se crta ručno** (`draw_texture_rect`), ne preko `Sprite2D.texture`. Sprite2D svoju teksturu crta prije skriptinog `_draw()`, pa bi sjena završila **preko** novčića.
- **`UiRun.COIN_FILL` i `COIN_EDGE` ostaju** — paket briše sva četiri, ali tačka na tokenu i „+1" koji leti i dalje ih koriste. Obrisani su samo `COIN_INNER` i `COIN_GLINT`.
- **`assets/pickups/coin.png` i `seed.png` ostaju** kao fallback ako import ne prođe (`greske-katalog` #6).
- **`arena/icon_crystal.svg` ostaje bez korisnika** — kandidat je za Arena ★3 kristal.
- **Dock na Home biranju sezone pomjeren u sceni** (`season_stage.tscn`), jer je apsolutno pozicioniran, a ne kroz `UiStage.DOCK`.

## Testovi

- Nova dva: **`hub_chrome_icons_smoke`** (svih 16 SVG-ova se učitava na 128 × 128, `icon_seed_light` je obrisan, nijedna ikona u chromeu nije RGB-tintana) i **`run_coin_texture_smoke`** (novčić crta `icon_coin.svg`, kolizija ostaje r 18).
- Ažurirani: `hub_chrome_smoke` (footer 144, tile 184 × 108, bez labele, tooltip, FlowerChip, veličine ikona po stanju), `camp_layout_smoke`, `camp_section_fixed_smoke`, `arena_redesign_smoke`, `season_home_smoke`, `meta_hub_flow_smoke`.

## Poznata ograničenja i sljedeći koraci

- Paket `design_handoff_hub_chrome_v2/` je u korijenu repoa, uz ostale CD pakete; `chrome_swatches.png` nosi izabranu i dvije odbijene boje.
- **Zamjena boje košta jednu liniju** — `UiChrome.CHROME_DEEP` (+ `CHIP_WELL` kao ista boja ~25 % tamnije). Odbijeni kandidati su tamna zemlja `#33261E` i neutralna tinta `#262A2C`.
- Dijamant je sada vidljiv samo u run HUD-u. Dok ne dobije potrošnju, to je i dalje mrtva valuta.
- Count-up animacija broja u chipu i dalje nije implementirana (stoji kao ideja još iz v1).
