---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, run, pickup, animacije, pip, camp, sezone, performanse, izvjestaj, claude-design]
povezano:
  - run-pickups-cd-brief
  - performanse
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "Prenos paketa design_handoff_run_pickups: (A) pickupi u runu — idle iz atlasa, let magnetom, dodir sa Pipom, niz coina, twin, 4 Pip reakcije, pilula „+1" do čipa, tačkasti magnet; (B) Camp kartice 4 plaćene sezone (recept, ink, PREMIUM + 6 cvjetova, stanja). FPS: prva verzija 3,3 ms CPU najgore → 0,35 ms poslije optimizacije; GPU A/B jednako ili brže, draw pozivi 72 → 45."
---

# Pickupi u runu + plaćene Camp kartice · izvještaj prenosa

> Paket: `design_handoff_run_pickups/` (zip `DIZZZAAAAJN.zip`, 2026-10-19) · brief [[run-pickups-cd-brief|run-pickups-cd-brief]].
> **Napomena:** taj zip je paket za pickupe (CD-RUN-PICK), ne Level Path — Level Path brief i dalje čeka slanje.

## Sažetak

| Dio | Stanje | Kako je provjereno |
|---|---|---|
| A · idle pickupa na stazi | ✅ | `run_pickups_smoke` (broj sprite-ova po rijetkosti, okret novčića, njihanje), snimke 8 livada (2 ovdje) |
| A · let magnetom do Pipa | ✅ | smoke: događaj počinje tek poslije leta (0,12–0,2 s); trzaj kruga |
| A · dodir coin / sjeme ★1–★3 / twin / niz coina | ✅ | smoke: `coin_n1…n5`, reset niza poslije 0,6 s, `seed_r3_twin`, `seed_r2` |
| A · Pip reakcije (4) + prioritet | ✅ | smoke: coin ne prekida `pickup_seed_rare` |
| A · pilula „+1 / +2" do čipa, broj raste po dolasku | ✅ | smoke: čip se ne mijenja prije dolaska; poruka s imenom na dolasku |
| A · magnet: tačkice, 18°/s, trzaj 4 % | ✅ | smoke + snimke |
| B · recept „camp" za 4 plaćene sezone + ink | ✅ | `camp_paid_card_smoke`, `season_kit_all_smoke`, snimke |
| B · raspored PREMIUM + 6 cvjetova, stanja price / buying / failed / burst | ✅ | `camp_paid_card_smoke`, `camp_season_link_smoke` (kupovina kroz stub) |
| FPS | ✅ uz napomenu | CPU i GPU A/B ispod; telefon nije mjeren |

Testovi: vidi § Testovi na dnu.

## A · Pickupi u runu

### Šta je u igri

- **Idle** (`coin_visual.gd`, `seed_visual.gd`): sve su Sprite2D iz jednog atlasa `assets/run/pickup_fx_atlas.png` (512 × 512) + region teksture cvijeta za sadnicu. Nema `_draw`.
  - Novčić: sjena, novčić koji se okrene (frejm `coin_edge`), blijesak iskrice.
  - Sjeme: sjena, zemljica, sadnica (njiše se), kapljica; ★2 lavanda zvijezda + 2 iskrice, ★3 zlatni oreol od latica + 3 iskrice. Iskrice vrti jedan čvor-orbita (elipsa 0,8).
- **Dodir** (`pickup_fx.gd`, novo): pickup se broji odmah kao prije, nestane sa staze, a `PickupFx` preuzima izgled:
  1. let do tačke C (nos / šape) po luku, skala → 0,85;
  2. događaj iz `data/run/pickup_fx.json` (11 događaja iz paketa), sidra C / B prate Pipa, dio ispod, dio iznad Pipa;
  3. krem pilula „+1" / „+2" (`pickup_pill.gd`) leti do CoinChipa / SeedChipa; tek tada broj raste, čip i broj se trznu, a za sjeme iskoči poruka „+1 Ime" (kao prije).
- **Zvuk** `coin` / `run_seed` sada ide u trenutku dodira (poslije leta), ne u trenutku hvatanja.
- **Pip:** `pickup_coin` i `pickup_seed` zamijenjeni, dodani `pickup_seed_rare` i `pickup_twin` (`data/pip/animations.json`). Niža reakcija ne prekida višu dok traje.
- **Magnet krug:** krem tačkice s ink rubom (L0 12 … L4 49), alfa 0,6, jedna mreža = 1 draw poziv; vrti se 18°/s i trzne 4 % kad uhvati pickup. Prozirna ispuna kruga je izbačena (nema je u paketu).
- **Ostalo:** `run_pickup_feed.gd` sada samo poruke s imenom; stari bijeli prsten (`run_ring_fx.gd`) ostaje samo za burst na cilju.

![[run-pickups-izvjestaj-ref/i01_idle_country_bloom.jpg]]
![[run-pickups-izvjestaj-ref/i02_idle_starfall_glade.jpg]]

Kadrovi dodira (redovi: coin, sjeme ★1, ★3, ★2 twin; kolone ~80 / 200 / 280 / 380 / 480 ms poslije hvatanja — snimano u stvarnom vremenu, pa kadrovi kasne):

![[run-pickups-izvjestaj-ref/i03_touch_sheet_country_bloom.jpg]]
![[run-pickups-izvjestaj-ref/i04_touch_sheet_starfall_glade.jpg]]

### FPS i animacije (pravilo za svaki CD paket)

**Prva verzija je bila preskupa.** Ključevi iz JSON-a su se čitali kroz Dictionary za svaki sprite svaki frejm → **~3,3 ms CPU** u najgorem slučaju i ~0,45 ms za idle 10 pickupa. Popravke:

1. događaji se jednom prevedu u tipizirane klase, staze se ispeku u `PackedFloat32Array` (120 uzoraka / s);
2. jedan upis `transform` umjesto pozicije, skale i rotacije; alfa samo kad se mijenja;
3. idle parametri u varijablama iz `_ready`; iskrice kroz jedan rotirajući čvor;
4. bazen sprite-ova i pilula zagrijan na startu runa — dodir ne pravi čvorove.

CPU skripti (headless, minimum od 5 naizmjeničnih prolaza):

| | Prije | Poslije |
|---|---|---|
| idle, 10 pickupa | ~450 µs | **~66 µs** |
| dodir, tipično (1 / 0,5 s) | — | **~45 µs** |
| dodir, najgore (15 / s, ~10 istovremeno, 34 sprite-a) | ~3 310 µs | **~345 µs** |

GPU A/B (stari kod iz odvojene kopije ↔ novi, 2 kruga naizmjenično, avg ms / draw pozivi):

| Scenarij | Stari | Novi |
|---|---|---|
| 10 pickupa stoji | 4,35–5,14 / 72 | 4,20–5,12 / **45** |
| 15 coina / s | 4,36–6,27 / 55 | 4,88–6,20 / 54 |
| sjeme ★1–★3 svakih 0,15 s | 5,77–6,44 / 61 | 5,26–6,50 / 62 |
| pravi run, magnet L4 | 5,72–6,26 / ~70 | **4,84–5,35** / ~48 |

Zaključak: novi pickupi nisu skuplji od starih, a pravi run s magnetom je čak malo brži (manje draw poziva — sjena i rijetkost više nisu posebni AA oblici). Budžeti paketa su ispunjeni: ≤ 8 sprite-ova po dodiru (s pilulom), 6 dodira odjednom = najviše 40 živih sprite-ova. Detalji: [[../../05-technical/performanse|performanse]] § Pickupi u runu, katalog grešaka #44.

**Šta nije mjereno:** pravi telefon. Laptop (AMD iGPU) nije mjerodavan za GPU telefona.

## B · Camp kartica plaćene sezone

- `seasons_kit.json`: `kits[id].camp` za Moonlit Warren, Coral Tide, Starfall Glade i Ember Fen (9–10 slojeva, samo postojeći oblici), `surfaces.camp.seasons` ih uključuje. Ostatak kita nije diran (provjereno poređenjem JSON-a).
- **Ink po sezoni:** Moonlit / Starfall / Ember krem `#FFF8F0`, Coral `#3D3D33` — naslov, broj cvjetova.
- **Raspored:** ime + zlatno dugme s cijenom (bez lokota); ispod oznaka **PREMIUM**, „6 new flowers" i red od 6 cvjetova sezone (★1 × 3 krem, ★2 × 2 mint, ★3 zlatni okvir, tamno udubljenje, t3 cvijet 84 px).
- **Stanja:** price → buying (svjetlije zlato bez sjene, tri tačke) → burst (isti prsten kao besplatna, „Unlocked", Home) ili failed (pilula „Purchase cancelled" 1,6 s iznad reda cvjetova, pa price).
- Ember Fen je i dalje test-zaključan (SOON), pa ga kartica ne nudi — recept je spreman za kad se otključa.

![[run-pickups-izvjestaj-ref/i06_paid_moonlit_price.jpg]]
![[run-pickups-izvjestaj-ref/i07_paid_coral_price.jpg]]
![[run-pickups-izvjestaj-ref/i08_paid_starfall_buying.jpg]]
![[run-pickups-izvjestaj-ref/i10_paid_coral_failed.jpg]]

## Fajlovi

| Novo | Šta |
|---|---|
| `game/assets/run/pickup_fx_atlas.png` (+ `.import`) | atlas efekata iz paketa |
| `game/data/run/pickup_fx.json` | idle, događaji, magnet, HUD let, regije atlasa (iz `godot/*.json` paketa) |
| `game/scripts/run/pickup_art.gd` | učitavanje, atlas, odrezane sadnice, prevođenje i pečenje staza |
| `game/scripts/run/pickup_fx.gd` | let, dodir, pilula, bazen |
| `game/scripts/run/pickup_pill.gd` | pilula „+1" |
| `game/scripts/dev/run_pickups_smoke.gd`, `camp_paid_card_smoke.gd` | testovi |
| `game/scripts/dev/run_pickups_bench.gd`, `run_pickups_cpu_bench.gd`, `run_pickups_capture.gd` | mjerenje i snimke |

Izmijenjeno: `coin_visual.gd`, `seed_visual.gd`, `coin.tscn` / `seed_pickup.tscn` (vizual je Node2D), `run_controller.gd`, `run_pickup_feed.gd`, `pip_visual.gd`, `ui_run.gd`, `data/pip/animations.json`, `seasons_kit.json`, `season_link_card.gd`, `ui_camp.gd`, `export_presets.cfg` (`data/run/*.json` u izvozu), `run_coin_texture_smoke.gd`, `popups_capture.gd`.

## Odluke koje čekaju tebe

- [ ] **Playtest na telefonu:** osjećaj dodira i niza coina; da li je pilula „+1" previše (5 coina / s = 5 pilula).
- [ ] **Zvuk u trenutku dodira** kasni 0,12–0,2 s za hvatanjem (namjerno, uz vizual) — da li se to osjeti?
- [ ] **Magnet bez ispune:** krug je sad samo tačkice (kao u paketu); stari blagi krem krug je izbačen.
- [ ] **Ember Fen** ostaje SOON dok ga ne otključaš.
- [ ] **Reduce motion je uključen** u postavkama igre na ovom laptopu — ako nije namjerno, isključi ga u Settings (testovi više ne zavise od toga).

## Testovi

Svi headless smoke testovi (75) + GUT, 2026-10-20:

- **GUT:** 70 / 70.
- **Smoke (prvi prolaz):** 68 / 75 prolazi. Novi `run_pickups_smoke` i `camp_paid_card_smoke` prolaze; ažurirani `run_coin_texture_smoke` (novčić iz atlasa) i `pip_rig_smoke` (84 animacije).
- **7 starih padova popravljeno u istoj sesiji** (katalog grešaka #45) — padali su i na čistom HEAD-u jer su testovi zavisili od stanja na računaru: uključen Reduce motion u `settings.cfg` (Nibbs, ogrtač Sir Pipa) i pravi save (Frost nadogradnje na max, lifetime sjemena, uzgojeno ★3). `loot_logic_smoke` je prepravljen na novi tok Loot Bursta iz MEAD-4 (consume, pa nagrada), `merge_arena_smoke` sada ispisuje „OK".
- **Poslije popravke: smoke 75 / 75, GUT 70 / 70**; pravi save i `settings.cfg` isti prije i poslije punog prolaza (md5).

## Povezano

- [[run-pickups-cd-brief|run-pickups-cd-brief]] · [[../_index|04-experience]]
- [[../../05-technical/performanse|performanse]] · [[../../05-technical/godot/greske-katalog|greske-katalog]] #44
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
