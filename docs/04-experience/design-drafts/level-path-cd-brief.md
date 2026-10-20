---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, home, leveli, progres, nagrade, sezone, pip, claude-design]
povezano:
  - home-v3-cd-brief
  - home-field-v2-cd-brief
  - seasons-cd-brief
  - popups-cd-brief
  - pip-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: novi ekran „Level Path" po sezoni — Play u polju sezone otvara skrolabilan krivudavi putić od 20 checkpointa, Pip stoji na trenutnom levelu, nagrade na 5/10/15/20 (★3 cvjetovi sezone + coini) se claimaju tapom i popupom; Play dugme ostaje isto i na istom mjestu; 8 sezonskih dizajna."
---

# Level Path po sezoni · Claude Design brief

> **Status 2026-10-20: paket stigao i u igri — vidi [[level-path-izvjestaj|level-path-izvjestaj]].** Ranije (2026-10-19): spremno za slanje. Slike: `level-path-ref/` (l00–l08). Prompt je u §9.
>
> **Prije slanja: commitaj i pushaj na `master`.** CD čita repo samo po tačnim putanjama s mastera.

Igra ima **levele** (Play) i **Endless**. Danas Play u polju sezone odmah pokreće run, a igrač nigdje ne vidi dokle je stigao. Treba novi ekran — **Level Path**:

- Play u polju sezone **ne pokreće run**, nego otvara Level Path te sezone.
- Level Path je krivudavi putić sa **20 checkpointa** (level 1 → 20), skroluje se **prema gore**.
- **Pip stoji na checkpointu trenutnog levela** (na levelu 1 → na prvom checkpointu).
- Na dnu ostaje **isto Play dugme, na istom mjestu** — tek ono pokreće run.
- Svaka sezona ima **svoj putić** (svoj dizajn) i **svoj napredak** — leveli se ne miješaju između sezona.
- Na checkpointima **5, 10, 15 i 20** su nagrade. Claimaju se **ovdje**, tapom na checkpoint, uz popup.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7 + slike u `level-path-ref/` | Šta je danas, šta mora, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §4, §5, §8 | Mjere iz koda, logika, prenos i FPS |

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stil | isti kao Home v3, polje sezone i Season Kit (`design_handoff_home_v3/`, `design_handoff_home_field_v2/`, `design_handoff_seasons/`, `design_handoff_popups/`): flat, pastel, tamni obrub (ink `#2D3436`), ravne boje, jedna tvrda sjena. **Bez blura, glowa, gradijenata i maski** |
| Engine | Godot 4.7, GL Compatibility, slabiji Android, 60 FPS. Artboard 1080 × 1920, sve u px te baze |
| Hub chrome | gornji bar (coini / sjemenke / cvijet / zupčanik, visina ~140) i donji tab bar (5 tabova, ~140) ostaju kakvi jesu i vidljivi su i na Level Pathu |
| Play dugme | **isto kao danas, ista pozicija:** 432 × 140, centar x 540, donji red polja (y ~1610–1750), boja breskve, ▶ + „Play" 900. Ne mijenja se ni izgled ni mjesto |
| Donji red danas | Seasons 236 × 124 lijevo · Play 432 × 140 · Endless 236 × 124 desno (ljubičasto) |
| Sezone | 8 livada: besplatne Country Bloom, Frost Orchard, Lantern Meadow, Amber Canopy; plaćene Moonlit Warren, Coral Tide, Starfall Glade, Ember Fen. Svijetle i tamne — putić i tekst moraju se čitati na svima |
| Pip | rig iz `design_handoff_pip/` (pogled `three_q` ili `front`), ~150–180 px visok |
| Nagrade (fiksni brojevi) | checkpoint 5: **2 ★3 cvijeta + 200 coina** · 10: **4 + 400** · 15: **6 + 600** · 20: **10 + 1000**. Cvijet = ★3 cvijet **te sezone** (isti kao na upgrade-ima i Camp kartici) |
| Pillar 2 | nagrade su besplatne, jednokratne, bez reklama i bez kupovine; nema „preskoči level" za novac |

## 2. Danas (slike `l00`–`l08`)

- `l00_card_country_bloom` — Home, kartica sezone (Play → otvara polje).
- `l01`–`l08` — **polje** svake od 8 sezona (stanje u kojem Play danas odmah pokreće run):
  - gore: Gift, Choose (vreća), ime sezone, Upgrades;
  - sredina: polje s cvijećem i Pipom koji šeta;
  - desno dolje: Looks;
  - donji red: **Seasons · Play · Endless**.
- Kod:
  - `game/scripts/ui/main_menu.gd` — `_start_run()` (Play u polju → run), `_on_endless_play_pressed()`, `_style_field_bottom_row()`;
  - `game/scripts/ui/season_stage.gd`, `season_field.gd` — kartica ↔ polje, `play_action()`;
  - `game/scripts/visual/ui_home_field.gd` — mjere donjeg reda (`SEASONS_BTN`, `ENDLESS_BTN`).
- Leveli danas: **jedan globalni** `run_level` (1–100) u `game_state.gd`, raste za 1 poslije uspješnog runa (ne u Endlessu, ne kad Pip udari prepreku). Level 1–10 iz `game/data/run_levels/levels_1_10.json`, ostalo krivulja (`run_level_library.gd`). U runu ga pokazuje LevelChip „Level N".

**Šta fali:** igrač ne vidi napredak; nema cilja ni nagrade na putu; sve sezone dijele jedan broj levela.

## 3. Šta se traži

### 3.1 Tok

1. Home → kartica sezone → **Play** → polje sezone (kao danas).
2. Polje → **Play** → otvara se **Level Path te sezone** (prelaz — tvoj prijedlog: putić se podigne / polje se zamagli… ali bez blura; npr. klizanje odozdo ili „zoom" na stazu).
3. Level Path → **Play** (isto dugme, isto mjesto) → run trenutnog levela.
4. Poslije runa → Loot ekran → nazad na Home. Igrač se vraća na **Level Path** te sezone i vidi da je Pip pomaknut (ako je level pređen).
5. Izlaz s Level Patha → nazad na polje (lijevo dugme donjeg reda, vidi §3.4).

### 3.2 Putić i checkpointi

- **20 checkpointa**, level 1 dolje → level 20 gore. Putić **krivuda** (lijevo-desno), ne ravna linija.
- Ne staje sve na ekran → **skrol vertikalno, prema gore**. Na otvaranju se ekran sam postavi tako da je **Pipov checkpoint vidljiv** (npr. u donjoj trećini, iznad Play dugmeta).
- Kroz skrol se vidi i dekor sezone sa strane puta (motivi iz Season Kita — drveće, lampioni, školjke, zvijezde…).
- **Stanja checkpointa:**
  - `done` — pređen (npr. zastavica / kvačica / obojen kamen);
  - `current` — trenutni level, Pip stoji na njemu, broj levela jasno vidljiv;
  - `locked` — još nije dostignut (prigušen, broj i dalje čitljiv);
  - `reward_locked` — 5 / 10 / 15 / 20 prije nego što je level pređen: vidi se nagrada (sanduk / poklon + mali prikaz „2 ★3 · 200"), ali zaključana;
  - `reward_ready` — level pređen, nagrada nije uzeta: **jasno klikabilno** (poskakuje, iskrice, oznaka „Claim" — ravni oblici, bez glowa);
  - `reward_claimed` — uzeta (otvoren sanduk / kvačica).
- **Putić između checkpointa:** dio puta koji je pređen razlikuje se od dijela koji nije (npr. obojen vs. isprekidan).
- Broj levela na svakom checkpointu (1…20) — mora se čitati na svih 8 sezona.

### 3.3 Pip i napredak

- Pip stoji na `current` checkpointu (idle animacija iz riga, može lagano disati / mahati).
- **Animacija napretka:** kad se igrač vrati poslije pređenog levela, Pip **skakuće s prethodnog na novi checkpoint** po putiću (≤ 1,2 s), pa stari checkpoint pređe u `done`. Ako je novi checkpoint nagradni pa sad postaje `reward_ready` — kratko ga istakni.
- Neuspješan run (prepreka) → Pip ostaje gdje je, bez animacije.
- **Poslije levela 20:** putić je „završen" (stanje `complete` — npr. Pip na vrhu sa zastavicom / krunom, natpis „Meadow complete!"). Play tada igra **level 20 ponovo** (za coine i sjemenke); nagrade se ne daju ponovo. Endless ostaje za beskonačno igranje.

### 3.4 Donji red na Level Pathu

- **Play** — isto dugme, isto mjesto (§1). Ne mijenja se.
- **Lijevo** (gdje je danas Seasons): dugme **nazad na polje** (npr. „‹ Field" ili ikonica polja) — isti oblik i veličina kao Seasons 236 × 124.
- **Desno**: **Endless** ostaje (isti kao danas) — Endless ne prati putić.
- Iznad Play dugmeta (ili na samom checkpointu) može stajati mala oznaka „Level 7" — tvoj prijedlog, ali Play ostaje „▶ Play".

### 3.5 Claim nagrade

- Nagrada se **ne daje automatski** poslije runa. Igrač mora doći na Level Path i tapnuti `reward_ready` checkpoint.
- Tap → **popup nagrade** u stilu `design_handoff_popups/` (kao „Gift claimed"):
  - naslov npr. „Level 5 reward!";
  - prikaz: N × ★3 cvijet te sezone (crtež cvijeta iz Season Kita) + coini;
  - dugme „Claim" → cvjetovi i coini **odlete u gornji bar** (coin chip / cvijet chip), brojač se trzne;
  - checkpoint prelazi u `reward_claimed`.
- Tap na `reward_locked` → kratka poruka „Finish level 5 to claim" (toast / oblačić), bez popupa.
- **Podsjetnik:** dok postoji neuzeta nagrada, mala tačka (badge) na Play dugmetu u polju te sezone i na kartici sezone na Homeu — tvoj prijedlog oblika; dugme Play se pri tome ne mijenja.
- Nagrada 20 (10 cvjetova + 1000) zaslužuje **veći trenutak** od 5 / 10 / 15 (npr. veći sanduk, više konfeta — u budžetu §5).

### 3.6 Po sezoni (8 dizajna)

- Svaka sezona ima svoj putić: podloga, materijal staze (zemljana staza, led, kamenčići s lampionima, lišće, mjesečeve ploče, pijesak i školjke, zvjezdani kamenovi, žar i trska…), oblik checkpointa i dekor sa strane.
- Bazu uzmi iz Season Kita (`game/data/seasons/seasons_kit.json` — paleta, `shapes`, motivi). Ako je moguće, **jedan recept po sezoni** u istom duhu (`kits[id].path`), da se putić crta iz podataka kao `camp` i `field`.
- Tamne sezone (Moonlit, Starfall, Ember): broj levela i oznake ≥ 4,5:1 kontrast.
- **Napredak je odvojen po sezoni:** Country Bloom može biti na levelu 12, Starfall na levelu 3. Isti ekran, drugi podaci.

## 4. Podaci (za tvoj prikaz i za agenta)

| | Vrijednost |
|---|---|
| Checkpointa po sezoni | 20 |
| Nagradni | 5, 10, 15, 20 |
| Nagrada | 5: 2 ★3 + 200 · 10: 4 ★3 + 400 · 15: 6 ★3 + 600 · 20: 10 ★3 + 1000 |
| Napredak | po sezoni: trenutni level (1–20, ili `complete`), set uzetih nagrada |
| Pređen level | samo uspješan run u kampanji (ne Endless, ne neuspjeh) |
| Za prikaz mocka | primjeri: Country Bloom level 7 (5 `reward_ready`), Lantern level 11 (5 uzeto, 10 `reward_ready`), Starfall level 1, Amber `complete` (sve uzeto) |

## 5. Performanse (MORA, u README)

| | Budžet |
|---|---|
| Putić | crta se **jednom** (statično) — skrol samo pomjera gotov sadržaj; ništa se ne crta po frejmu |
| Visina sadržaja | ≤ 3 ekrana (≤ ~5200 px) za svih 20 checkpointa |
| Slojevi / recept | ≤ 40 oblika po sezoni za cijeli putić + dekor (ili ≤ 3 teksture ≤ 1024 × 2048 po sezoni ako ide kao slika) |
| Animirano istovremeno | Pip idle + do 4 `reward_ready` efekta; samo transformi (pozicija, rotacija, skala, frejm) |
| Skok Pipa | ≤ 1,2 s, ≤ 6 sprite-ova |
| Popup + let nagrade | ≤ 16 sprite-ova, ≤ 1,0 s (nagrada 20 ≤ 24 sprite-a, ≤ 1,4 s) |
| SVG | ukupno ≤ 120 KB za svih 8 sezona |

U README napiši stvarne brojeve.

## 6. Isporuka

### 6.1 Stanja (sve živo u pregledaču)

- Level Path za **svih 8 sezona**, skrolabilan, s pravim hub chromeom (gornji bar + tab bar) i donjim redom (nazad · Play · Endless).
- Prekidač sezone i prekidač levela (1…20 + `complete`) — vidi se gdje je Pip i koja su stanja checkpointa.
- Sva stanja checkpointa: `done`, `current`, `locked`, `reward_locked`, `reward_ready`, `reward_claimed`.
- Prelaz polje → Level Path i nazad.
- Animacija napretka (Pip skače na sljedeći checkpoint), dugme „pređi level" u mocku.
- Popup nagrade 5 / 10 / 15 / 20 i let cvjetova + coina u gornji bar; toast za `reward_locked`.
- Badge „neuzeta nagrada" na Play dugmetu u polju i na kartici sezone.
- Prekidač „usporeno ×4".

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_level_path/
  README.md                 šta otvoriti · § Odlučeno · § Performanse · § Samoprovjera
  design/
    LevelPath.dc.html       8 sezona, skrol, stanja, Pip, prelaz, prop season / level
    RewardPopup.dc.html     popup 5 / 10 / 15 / 20, let u bar, toast
    Specs.dc.html           mjere, pozicije checkpointa, vremena, krive, budžeti
    support.js · pip_*.js · seasons_kit.js (ako koristiš runtime iz svojih paketa)
  assets/
    path/*.svg              checkpointi po stanju, nagradni sanduk (zaključan / spreman / uzet), staza
    fx/*.svg                skok, iskrice reward_ready, konfeti
  godot/
    level_path_layout.json  pozicije 20 checkpointa (x, y u px sadržaja), visina sadržaja,
                            početni skrol, mjere donjeg reda
    seasons_kit_path.json   kits[id].path za svih 8 sezona (format kao camp / field u
                            game/data/seasons/seasons_kit.json, + ink)
    level_path_states.json  izgled po stanju checkpointa, animacije (skok, reward_ready)
    reward_popup.json       popup, tekstovi, let, stanja
```

### 6.3 Samoprovjera (u README, svaka stavka da / ne, provjereno u pregledaču)

1. Play u polju otvara Level Path; Play na Level Pathu je **isto dugme na istom mjestu** kao danas.
2. 20 checkpointa na krivudavom putiću, level 1 dolje → 20 gore; skrol prema gore; Pipov checkpoint je vidljiv na otvaranju.
3. Pip stoji na trenutnom levelu; skače na sljedeći poslije pređenog levela (≤ 1,2 s).
4. Svih 6 stanja checkpointa + `complete` se razlikuju na prvi pogled.
5. Nagrade 5 / 10 / 15 / 20 pokazuju tačne brojeve (2/4/6/10 ★3 cvjetova sezone + 200/400/600/1000 coina) i claimaju se tapom kroz popup.
6. 8 sezona ima 8 različitih putića u stilu Season Kita; brojevi čitljivi (≥ 4,5:1) i na tamnim.
7. Napredak je po sezoni (mock pokazuje različite levele u različitim sezonama).
8. Hub chrome i donji red (nazad · Play · Endless) ostaju; ništa ne pokriva Play.
9. Budžeti iz §5 su ispunjeni i napisani.
10. Nigdje blur, glow, gradijent ni maska; putić se ne crta po frejmu.

## 7. Ne tražimo

- Promjenu runa, težine levela, LevelChipa ni Endlessa (Endless dugme ostaje kakvo jeste).
- Promjenu kartice sezone, polja, Gift / Choose / Upgrades / Looks.
- Nove valute ili nagrade osim zadanih (★3 cvjetovi sezone + coini).
- Kupovinu, reklame ili „preskoči level".
- Zvuk (agent ga veže: `gift`, `coin`, `discover`…).

## 8. Napomena za agenta (prenos)

- **Stanje (`game_state.gd`):**
  - globalni `run_level` → `season_levels: Dictionary` (`season_id → int 1…21`, 21 = `complete`) + `season_level_rewards_claimed: Dictionary` (`season_id → [5, 10, …]`); save / load / migracija (stari `run_level` → aktivna sezona, ili sve od 1 — odlučiti s korisnikom; ostale sezone od 1).
  - `finish_run`: uspješan kampanjski run povećava level **aktivne sezone** (do 21); `complete` igra level 20 ponovo.
  - `claim_level_reward(season_id, n)`: provjera da je level n pređen i da nije uzeto; daje ★3 cvijet sezone (`star3_type_id_for_season` → `garden_crystal_stash`) i coine; save.
  - Težina: level N sezone → `RunLevelLibrary.get_level(...)` — mapiranje (npr. isti 1–20 za sve, ili pomak po rednom broju sezone) odlučiti s korisnikom.
- **UI:**
  - nova scena `LevelPath` u Home stranici (`main_menu.gd` / `season_stage.gd`): Play u polju → `open_level_path(id)`, Play na pathu → `_start_run()`.
  - `ScrollContainer` (vertikalni, sadržaj crtan jednom), `BLOCK_HUB_SWIPE_GROUP` da swipe huba ne krade skrol.
  - recept `kits[id].path` u `seasons_kit.json`; `ink` po sezoni.
  - popup preko postojećeg `reward_tray.gd` / `ui_popups.gd`; let u gornji bar kao Gift.
  - badge na Play / kartici sezone kad postoji `reward_ready`.
- **Testovi:** novi `level_path_smoke` (napredak po sezoni, claim jednom, `complete`, migracija save-a), GUT za `claim_level_reward`; postojeći `home_field_overlay_smoke`, `season_sync_smoke`, `run_smoke`.
- **Provjera:** `perf_suite_bench.gd` prije / poslije (skrol pathe), pravilo CD paketa iz `performanse.md` (FPS po animaciji), veličina pck.
- Reference: `game/scripts/dev/level_path_capture.gd` (snima polje svih 8 sezona).

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Novi ekran za mobilnu igru Merge Meadow (portrait, flat pastel cartoon,
zeko Pip trči kroz levele u 8 sezona-livada): LEVEL PATH po sezoni.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/level-path-cd-brief.md
    -> §1 (fiksno), §2 (danas), §3 (šta se traži), §4 (podaci),
       §5 (performanse), §6 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/level-path-ref/:
    level-path-ref/l00_card_country_bloom.jpg    Home, kartica sezone
    level-path-ref/l01_field_country_bloom.jpg   polje — Play danas = run
    level-path-ref/l02_field_frost_orchard.jpg
    level-path-ref/l03_field_lantern_meadow.jpg
    level-path-ref/l04_field_amber_canopy.jpg
    level-path-ref/l05_field_moonlit_warren.jpg
    level-path-ref/l06_field_coral_tide.jpg
    level-path-ref/l07_field_starfall_glade.jpg
    level-path-ref/l08_field_ember_fen.jpg
  game/scripts/ui/main_menu.gd  (_start_run, _style_field_bottom_row)
  game/scripts/ui/season_stage.gd, game/scripts/ui/season_field.gd
  game/scripts/visual/ui_home_field.gd  (mjere donjeg reda)
  game/scripts/autoload/game_state.gd  (run_level, finish_run)
  game/data/seasons/seasons_kit.json  (kits[id], shapes, camp / field recepti)
  game/scripts/ui/popup/reward_tray.gd, game/scripts/visual/ui_popups.gd
  design_handoff_home_v3/, design_handoff_home_field_v2/,
    design_handoff_seasons/, design_handoff_popups/, design_handoff_pip/
    (tvoji paketi)

DANAS: u polju sezone Play odmah pokreće run; igrač ne vidi dokle je
stigao; sve sezone dijele jedan broj levela.

TRAŽI SE:
1. Play u polju sezone otvara LEVEL PATH te sezone. Na dnu ostaje ISTO
   Play dugme na ISTOM mjestu (432 x 140, centar x 540) — tek ono pokreće
   run. Lijevo: nazad na polje (umjesto Seasons), desno: Endless ostaje.
2. Krivudavi putić sa 20 checkpointa, level 1 dolje -> 20 gore, skrol
   PREMA GORE. Pip stoji na checkpointu trenutnog levela (level 1 = prvi
   checkpoint); na otvaranju se vidi njegov checkpoint. Poslije pređenog
   levela Pip skoči na sljedeći (<= 1,2 s). Poslije 20: stanje „complete".
3. Stanja checkpointa: done, current, locked, reward_locked, reward_ready,
   reward_claimed (+ complete za cijeli put).
4. Nagrade na 5 / 10 / 15 / 20: 2 / 4 / 6 / 10 ★3 cvjetova TE sezone +
   200 / 400 / 600 / 1000 coina. Ne daju se automatski: kad je level
   pređen, checkpoint je klikabilan (reward_ready), tap -> popup u stilu
   design_handoff_popups -> Claim -> let u gornji bar. Nagrada 20 je veći
   trenutak. Tap na zaključanu -> kratka poruka. Badge na Play / kartici
   sezone dok postoji neuzeta nagrada.
5. 8 SEZONA = 8 različitih putića (staza, checkpointi, dekor iz Season
   Kita; ako može, recept kits[id].path kao camp / field). Napredak je
   odvojen po sezoni. Brojevi čitljivi i na tamnim sezonama (>= 4,5:1).

PERFORMANSE (MORA, §5): putić se crta jednom (statično, skrol samo
pomjera), <= 3 ekrana visine, <= 40 oblika po sezoni, animacije samo
transformima, skok <= 6 sprite-ova, popup + let <= 16 (nagrada 20 <= 24),
SVG <= 120 KB ukupno. Brojeve napiši u README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android, 60 FPS): artboard
1080 x 1920, gornji bar i tab bar huba ostaju vidljivi. Stil kao Home v3
i Season Kit: ravne boje, obrub, jedna tvrda sjena. BEZ blura, glowa,
gradijenata i maski.

ISPORUKA (§6): novi folder design_handoff_level_path/, CIJELI U ZIPU za
preuzimanje u chatu (design/LevelPath.dc.html, RewardPopup.dc.html,
Specs.dc.html, assets/path, assets/fx, godot/level_path_layout.json,
seasons_kit_path.json, level_path_states.json, reward_popup.json, README
sa § Odlučeno, § Performanse i § Samoprovjera — 10 stavki iz §6.3, svaka
da/ne, provjereno u pregledaču PRIJE nego pošalješ zip).

NE RADI: run, težinu levela, LevelChip, Endless, karticu sezone, polje,
Gift / Choose / Upgrades / Looks, nove valute, kupovinu, reklame, zvuk.
Jedan dizajn, tvoj izbor, neka bude sočno i prelijepo.
```

## Povezano

- [[../_index|04-experience]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
- [[home-v3-cd-brief|Home v3]] · [[home-field-v2-cd-brief|polje sezone v2]] · [[seasons-cd-brief|Season Kit]]
- [[popups-cd-brief|Popupi]] · [[pip-cd-brief|Pip]]
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
