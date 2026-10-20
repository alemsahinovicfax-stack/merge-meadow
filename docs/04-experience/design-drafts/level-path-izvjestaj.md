---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, home, level-path, sezone, nagrade, pip, performanse, izvjestaj, claude-design]
povezano:
  - level-path-cd-brief
  - performanse
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "Prenos paketa design_handoff_level_path: Play u polju otvara put sezone (20 kamenova, Pip na trenutnom levelu, skok poslije pređenog levela), isto Play pokreće run, ‹ Field nazad; napredak i nagrade 5/10/15/20 po sezoni (popup + let u bar); badge na Play i kartici. Stari run_level prelazi na aktivnu sezonu; težina levela N ista u svim sezonama. FPS: put = polje ili brži, popup ~+1 ms dok traje."
---

# Level Path po sezoni · izvještaj prenosa

> Paket: `design_handoff_level_path/` (zip `Merge Meadow level path.zip`, 2026-10-20) · brief [[level-path-cd-brief|level-path-cd-brief]].

## Sažetak

| Dio | Stanje | Kako je provjereno |
|---|---|---|
| Play u polju → put; Play na putu → run; ‹ Field nazad | ✅ | `level_path_smoke` (prelaz, labela, chrome polja), snimke |
| 20 kamenova, krivudava ruta, skrol prema gore, Pip na svom kamenu | ✅ | smoke: Pip u kadru na otvaranju za levele 1…21 |
| Stanja done / current / locked + sanduci locked / ready / claimed + complete | ✅ | smoke + snimke svih sezona |
| Nagrade 5 / 10 / 15 / 20 (2 / 4 / 6 / 10 ★3 sezone + 200 / 400 / 600 / 1000) | ✅ | smoke: stash, Album, coini; drugi Claim ništa |
| Popup nagrade, let 3 + 4 (nagrada 20: 5 + 5, konfete), brojač raste po dolasku | ✅ | smoke: broj letača, kraj za ≤ 1 s |
| Zaključana nagrada → toast „Finish level N to claim" + tresenje | ✅ | smoke |
| Skok Pipa poslije pređenog levela; complete (zastavica, binky, traka) | ✅ | smoke: 7 → 8 i 20 → complete |
| Badge (roza tačka) na Play u polju i na kartici sezone | ✅ | smoke + snimke |
| „Pip" lokator kad je Pip van kadra | ✅ | smoke |
| 8 sezona = 8 putića iz `kits[id].path` | ✅ (7 vidljivo) | Ember Fen je još test-zaključan („Coming soon"), pa njegov put nije snimljen u igri |
| Napredak po sezoni (save) + stari save | ✅ | smoke: roundtrip, migracija, loše vrijednosti |
| FPS | ✅ | A/B prema polju (osnovica), § Performanse |

## Šta je u igri

### Ekran puta (`scripts/ui/level_path_view.gd`, `LevelPathView`)

- Cijela stranica 1080 × 1633, između headera i tab bara. Sadržaj je visok **4900 px** (3 stranice).
- **Pozadina** se crta jednom iz recepta `kits[id].path` (novo u `data/seasons/seasons_kit.json`, 8 sezona). Crta je isti `SeasonBackdrop` kao polje i kartica. Skrol samo pomjera sadržaj.
- `LevelPathKit` (`scripts/visual/level_path_kit.gd`) jednom prevede 4 nove vrste sloja iz paketa u obične slojeve Season Kita:
  - `route` → linija duž rute;
  - `route_marks` → oblik na svakih N px (kamenčići, lišće, zvjezdana prašina, daske);
  - `spurs` → krak do sanduka;
  - `stripes` → pokošene pruge.
- **Pređeni put:** 2–3 `Line2D` poteza s okruglim krajevima. Mijenja se samo kad se promijeni level.
- **Kamenje:** 20 crteža (sprite sezone po stanju + broj). `current` je breskvast i 1,22× veći.
- **Sanduci:** 4 komada. Ispod zaključanog stoji krem pilula s nagradom (★3 crtež + N, coin + N), a ispod spremnog breskvasta pilula „Claim". Tap radi na sanduk i na njegov kamen.
- **Pip:** rig iz Pip paketa (box 210, stopala 44 px iznad lica kamena), sa skinom iz Ormara. Idle se vrti.
- **Gore:** fiksna pločica „Ime sezone · 7 / 20", odnosno mint „✓ 20 / 20".
- **Lokator** „Pip ▲/▼" (176 × 96, iznad Endlessa) pojavi se kad Pip izađe iz kadra. Tap vrati skrol (0,36 s).
- **Skrol:** prst (s inercijom) i točkić miša. Blokira swipe huba.

![[level-path-izvjestaj-ref/p03_path_country_bloom.jpg]]
![[level-path-izvjestaj-ref/p04_path_moonlit_warren.jpg]]
![[level-path-izvjestaj-ref/p05_path_starfall_glade.jpg]]
![[level-path-izvjestaj-ref/p12_path_frost_orchard.jpg]]
![[level-path-izvjestaj-ref/p13_path_lantern_meadow.jpg]]
![[level-path-izvjestaj-ref/p14_path_coral_tide.jpg]]

### Polje ↔ put (`season_stage.gd`, `main_menu.gd`)

- **Play u polju** otvara put (0,56 s): put se digne odozdo, chrome polja ode (alpha + 16 px), a Pip skoči `card_jump` lukom s polja na svoj kamen.
  - Gift, Choose, Upgrades, Looks i ime sezone nestanu.
  - Play se ne pomjera.
  - Lijevo dugme se pretopi iz „Seasons" u „Field".
- **Play na putu** pokreće run (isto dugme, isti `play_run_requested`). Endless je nepromijenjen.
- **‹ Field** i Android back zatvaraju put (0,44 s), a Pip skoči nazad na polje.
- Dok je put otvoren, polje se ne crta (nema ni duplog troška).
- **Povratak iz runa:** put je i dalje otvoren. Ako je level pređen, Pip skoči na sljedeći kamen (≤ 1,0 s): čekanje 0,12 s, pa luk od 74 px, pop kamena, prsten i prašina. Ako je pređeni level nagradni, sanduk se istakne.
- **Neuspjeh** ne pomjera Pipa.
- **Tutorijal:** dok tutorijal nije završen, Play u polju i dalje pokreće run direktno, kao prije (put se pojavi poslije tutorijala).

![[level-path-izvjestaj-ref/p02_field_badge.jpg]]
![[level-path-izvjestaj-ref/p15_hop_mid.jpg]]

### Nagrade (`level_path_reward_popup.gd`)

- Tap na **spreman** sanduk otvara GiftModal sistema popupa. U njemu su:
  - zlatna pločica „Level N reward!";
  - otvoren sanduk na ravnim zrakama (rotacija 14°/s) i ★3 cvijet koji lebdi iznad;
  - ime cvijeta + ★3, 2 RewardChipa i Claim.
- **Claim** odmah upiše nagradu (stash + Album + coini, save). Modal nestane, a 3 cvijeta i 4 coina lete Bézier krivom do FlowerChipa i CoinChipa u headeru. Svaki dolazak doda svoj dio iznosa i trzne chip.
- **Nagrada 20:** veći sanduk, 6 konfeta, 5 + 5 letača.
- Tap na **zaključan** sanduk: sanduk se strese i pojavi se toast „Finish level N to claim". Popup se ne otvara.
- **Badge** (roza tačka 48) stoji na Play u polju i na uglu kartice sezone dok postoji neuzeta nagrada.

![[level-path-izvjestaj-ref/p07_locked_toast.jpg]]
![[level-path-izvjestaj-ref/p08_reward_popup.jpg]]
![[level-path-izvjestaj-ref/p09_reward_fly.jpg]]
![[level-path-izvjestaj-ref/p01_card_badge.jpg]]

### Završen put

- Kad se pređe 20: zastavica se digne (0,4 s), Pip izvede binky i pojavi se traka „Meadow complete!" s napomenom „▶ Play repeats Level 20".
- Play tada ponovo igra level 20 (coini i sjeme). Nagrade se ne daju ponovo.

![[level-path-izvjestaj-ref/p10_complete_coral_tide.jpg]]
![[level-path-izvjestaj-ref/p11_reward20_popup.jpg]]
![[level-path-izvjestaj-ref/p06_complete_amber_canopy.jpg]]

### Podaci i save (`scripts/economy/level_path.gd`, `LevelPathDomain`)

- U save idu `season_levels` {sezona: 1…21} i `season_level_rewards` {sezona: [5, 10, …]}.
- `GameState.run_level` je sada svojstvo: level puta **aktivne** sezone (complete → 20). Zato run, HUD (LevelChip) i težina rade kao prije.
- `finish_run`: uspješan kampanjski run pomjera level aktivne sezone i ostavlja „skok" za put. Neuspjeh i Endless ne pomjeraju ništa.
- `claim_level_reward(sezona, N)`: ★3 te sezone ide u stash i Album (kao Loot Burst), coini u novčanik, pa save.

## Odluke koje sam donio umjesto tebe (lako se mijenjaju)

CD je ova dva pitanja ostavio otvorenim. Izabrao sam:

1. **Stari `run_level` → aktivna sezona.**
   - Ako je stari level 12, a igrao si u Amber Canopy, Amber kreće od 12, a ostale sezone od 1.
   - Iznad 20 = put završen. Pređeni nagradni leveli tada čekaju Claim (zaradio si ih).
   - Ako hoćeš da sve kreće od 1, to je jedna linija u `LevelPathDomain.apply_from_save`.
2. **Težina: level N je jednako težak u svakoj sezoni** (`RunLevelLibrary.get_level(N)`).
   - Biblioteka i dalje ima 100 levela, a put koristi 1–20.
   - Ako hoćeš da kasnije sezone budu teže (npr. pomak po redu sezone), to se radi u `GameState.get_active_run_level_config`.

## Šta nije kao u mocku

- **Pip** nosi skin iz Ormara (u mocku je classic).
- **Ember Fen** je još test-zaključan (`TEST_LOCK_PAID_ID`), pa se njegov put u igri ne vidi. Recept i sprite-ovi postoje; smoke ih provjerava.
- **Prelaz kartica ↔ polje** je postojeći prelaz igre. Paket ga je u mocku samo pretapao.

## SVG-ovi

- Iz paketa su prenesena **41 SVG-a** (kamenje 3 × 8, sanduci 8, zastavica 2, efekti 7).
- C2PA zapis porijekla je skinut, pa je ukupno **39 KB**.
- `road.svg` (samo uzorak za poređenje) i kopije cvijeća i ikona nisu preneseni.
- Uvoz: `current` kamenje je rasterizovano na 1,25×, a veliki i otvoreni sanduk na 1,5×, da ne budu mutni kad se povećaju.

## Performanse

Mjereno s `level_path_bench.gd` u pravom hubu (1080 × 1920, vsync isključen, HP laptop, AMD iGPU, GL Compatibility). Osnovica je **polje sezone**, tj. ekran koji je Play do sada otvarao. Rađena su 2 prolaza, drugi naizmjenično (Country Bloom ↔ Lantern Meadow ×2).

| Scenarij | Country Bloom (avg ms / draw) | Lantern Meadow | Moonlit / Starfall (1. prolaz) |
|---|---|---|---|
| `lp_field` — polje (osnovica) | 7,01–7,04 / 111–115 | 7,43–7,45 / 114 | 9,53 / 9,35 |
| `lp_path` — put, 1 ready sanduk | 5,98–7,53 / 109–111 | **6,79–6,87** / 108 | **8,95 / 8,59** |
| `lp_ready4` — 4 ready (poskok + 12 iskri) | 6,20–7,49 / 105–107 | 6,79–6,91 / 104 | 8,95 / 8,64 |
| `lp_scroll` — skrol cijelog puta | 6,32 / 105 | — | 8,77 / 8,42 |
| `lp_hop` — skok svakih 1,2 s | 6,21 / 103 | — | 9,12 / 8,56 |
| `lp_popup` — popup + let 3 + 4 | 7,66–8,64 / 119–123 | 7,93–8,00 / 120 | 9,24 / 8,63 |
| `lp_popup20` — 5 + 5 + konfete | 7,86–8,45 / 123 | 7,74–7,79 / 120 | 9,16 / 8,74 |
| `lp_trans` — polje ↔ put u krug | 9,26 / 128 | — | 9,25 / 8,58 |

- **Put je jednak polju ili brži**, s ~6 draw poziva manje. Pozadina je 302–1017 poligona, crta se jednom i ne ažurira se po frejmu. Moonlit / Starfall prolaz je bio na zagrijanom laptopu, pa su tu sporiji i polje i put.
- **4 ready sanduka koštaju ~0:** samo transform (poskok + iskre). Draw pozivi čak padnu, jer sanduk bez pilule s nagradom crta manje.
- **Skok:** Pip + 2 + 2 prašine + prsten = 6 sprite-ova (budžet 6), iz bazena.
- **Popup** je jedini skuplji trenutak: ~+1 ms prosjek i +10–14 draw poziva (modal, chipovi, crteži cvijeća), a traje ~1 s. Udari > 16 ms u bench petlji dolaze od pravljenja modala i snimanja savea na svaki Claim. U igri se to desi jednom po nagradi.
- **Prelaz** crta polje i put zajedno 0,56 s (128 draw poziva), kao i postojeći prelaz kartica ↔ polje.
- Telefon nije mjeren.

## Testovi

Headless, 2026-10-20:

- **Smoke 76 / 76** poslije ažuriranja:
  - novi `level_path_smoke`: domena, save i migracija, `finish_run`, raspored i recepti 8 sezona, kontrast brojeva, cijeli tok na Homeu, polje zatvoreno izvana, povratak iz runa sa skokom;
  - `season_home_smoke` i `season_meadow_smoke` su očekivali da Play u polju odmah pokrene run — sad očekuju put (namjerna promjena iz briefa).
- **GUT 70 / 70.**
- **Izvoz:** `data/level_path/*.json` dodan u `include_filter` (Android); SVG-ovi idu kao uvezeni resursi.

## Šta ti treba provjeriti (playtest)

- [ ] Play u polju → put → Play → run → povratak: Pip skače na sljedeći kamen.
- [ ] Claim nagrade 5: let u bar i brojači (coini + cvijeće).
- [ ] Osjećaj skrola prstom na telefonu (inercija, swipe huba ne smije krenuti).
- [ ] Odluke gore (stari level → aktivna sezona; ista težina u svim sezonama) — ostaju ili mijenjamo?
- [ ] Ember Fen kad ga otključaš.

## Povezano

- [[level-path-cd-brief|level-path-cd-brief]] · [[../../05-technical/performanse|performanse]] · [[../../06-production/CHECKPOINT|CHECKPOINT]]
