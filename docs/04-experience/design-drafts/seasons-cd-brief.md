---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, art, sezone, cvijece, home, shop, camp, arena, run, prepreke, animacije, claude-design, mockup]
povezano:
  - seeds-flowers-cd-brief
  - home-v3-cd-brief
  - home-field-v2-cd-brief
  - shop-v2-cd-brief
  - camp-v2-cd-brief
  - camp-season-link-cd-brief
  - merge-arena-cd-brief
  - run-cd-brief
  - plant-frame-cd-brief
  - popups-cd-brief
  - art-direction
  - design-pillars
  - scope-i-granice
  - CHECKPOINT
ai_sažetak: "Višefazni brief za Claude Design: svaka od 8 sezona dobija jedan Season Kit (mjesto, paleta, motivi, ambijent) koji se reže na sve površine igre — Home kartica izbora, Home polje (chill zona s Pipom), Shop kartica, Camp link, Arena, Run s preprekama — plus svih 144 crteža cvijeća (48 tipova × T1/T2/T3). Faza 1 (Country Bloom + Moonlit Warren) je u igri; AKTUELNO je faza 2 = svih 6 preostalih sezona i 108 crteža odjednom, prompt u §12.0, lekcije iz faze 1 u §10.1–§10.2."
---

# Sezone — cijeli izgled (mjesto + cvijeće) — Claude Design brief

> **AKTUELNO (2026-10-05): faza 2 = SVIH 6 PREOSTALIH SEZONA odjednom** — Frost Orchard, Lantern Meadow, Amber Canopy, Coral Tide Garden, Starfall Glade, Ember Fen, sa svih **108 crteža cvijeća**, svim površinama, preprekama, ambijentom i animacijama. **Prompt je u §12.0.** Prije toga obavezno §10.1 (lekcije iz faze 1) i §10.2 (šta igra već zna crtati).
>
> **Status 2026-10-05: faza 1 (Country Bloom + Moonlit Warren) u igri** — [[seasons-izvjestaj]]. Poslije prenosa popravljeno: pozadina kartice izbora i Shop kartice izlazila je iz okvira (recept je išao preko recta), Merge Hint je ostajao na polju Arene, polje sezone se nije osvježavalo poslije spajanja u Areni, plijen iz runa nestajao je bez poruke kad je vreća puna. Ovaj brief, `seasons-ref/`, `seasons-faza1/`, izvještaj i paket faze 1 su sada na `master`.
>
> Status 2026-10-03: brief napisan za 4 CD faze. U fazi 1 CD nije vidio ovaj fajl na masteru i radio je po sažetku, a nacrtao je samo dvije sezone. Zato se faze 2 i 3 sada spajaju u jednu (§10).

> ⚠️ **Scope:** `scope-i-granice.md` vodi sezone (SEZ-01) kao **v1.1+**, ne kao M8 launch listu. Ovaj brief je dizajn, ne kod. Ugradnju u igru treba poredati poslije stavki koje blokiraju launch (D0-P / D0-M u `CHECKPOINT.md`), osim ako svjesno promijeniš plan.

Prije faze 1 sezone su imale **samo boju**, a za Frost, Lantern, Amber, Coral, Starfall i Ember to važi i danas. Polje, Home kartica i Shop kartica crtaju iste tri ravne trake u 8 nijansi (`UiHomeField.MEADOW_GROUND`). Run je ista staza s tintom (`SeasonTheme` doslovno piše „Placeholder run tints"). Prepreke su isti kamen i panj u drugoj boji. Od 48 vrsta cvijeća samo 6 ima crtež, a ostalih 42 su isti krug u drugoj nijansi. Jedino **Arena v2** zna da je svaka sezona **drugo mjesto, ne druga boja** (8 recepata u `UiArenaV2.FIELDS`).

Ovaj brief širi to pravilo na cijelu igru. Svaka sezona dobija **jedan Season Kit** — mjesto, paletu, potpis-motive, ambijent i 18 crteža cvijeća — a svaka površina igre je **isti kit izrezan za svoj format**. Igrač treba prepoznati sezonu po jednom pogledu na bilo koju karticu, i ući u polje sezone kao u stvarno mjesto.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§11 + slike u `seasons-ref/` | Šta mora, šta smije, kako izgleda danas, šta se isporučuje |
| **Ti** | **§10** (faze) i **§12** (prompt) | Plan sesija i gotov prompt za copy-paste |
| **Agent (kasnije)** | §5, §6, §11, §13 | Tačne mjere, fajlovi i red prenosa u Godot |

**Prije slanja prompta: commitaj i pushaj na `master`.** CD čita fajlove i slike iz repoa samo po tačnoj putanji, i samo pushane. Njegov alat za listanje foldera **ne vidi** `.gd` i `.tscn` fajlove, zato su sve putanje u §12 navedene pune.

## 1. Zašto — šta je danas

Slike stanja **prije faze 1** su u `docs/04-experience/design-drafts/seasons-ref/` (snimljene iz igre 2026-10-03, 1080 × 1920, skripta `game/scripts/dev/seasons_capture.gd`). Najbolje se vidi na uporednim listovima `00a`–`00e`, gdje je svih 8 sezona jedna pored druge. Za Frost, Lantern, Amber, Coral, Starfall i Ember to je i danas tačno stanje.

Slike **poslije faze 1** (Country Bloom i Moonlit Warren kao mjesta) su u `docs/04-experience/design-drafts/seasons-faza1/`: `01_home_kartica_polje.jpg`, `02_prelaz_u050_u0999_u1.jpg`, `03_run_shop.jpg`, `04_arena_l0_l4.jpg`, `05_pip_njusi_spava.jpg`. Tabela ispod opisuje stanje prije faze 1; šta je od toga promijenjeno piše u [[seasons-izvjestaj]].

| Površina | Fajl | Danas | Slike |
|---|---|---|---|
| **Home kartica izbora** | `game/scripts/ui/home_v3_card.gd`, `home_v3_card_content.gd` | Ime, 6 portreta, stanje. Pozadina su 3 ravne trake iz `MEADOW_GROUND`. Svih 8 sezona je ista kompozicija u drugoj boji. | `00a`, `01`–`08` |
| **Home polje** (chill zona) | `game/scripts/ui/season_field.gd`, `season_field_flower.gd`, `season_field_pip.gd` | Iste 3 trake, 13 cvjetova u redovima, Pip šeta. Nema horizonta, motiva ni ambijenta. Kod 7 sezona cvijeće je isti krug u jednoj nijansi. | `00b`, `09`–`15` |
| **Shop kartica** | `game/scripts/ui/season_pack_card.gd`, `game/scripts/visual/ui_shop_v2.gd` | 3 trake iz `UiShopV2.season_bands(ground)` + 6 istih proceduralnih cvjetića + ime + cijena. Moonlit Warren izgleda kao Country Bloom u ljubičastoj. | `19`, `20` |
| **Camp link** | `game/scripts/camp/season_link_card.gd`, `game/scripts/visual/ui_camp.gd` | Ravna boja `UiCamp.season_tint`: Frost `#C5D5E8`, Lantern `#C9B8E0`, Amber `#E8C48A`. | `00e`, `16`–`18` |
| **Arena** | `game/scripts/camp/arena_meadow_bg.gd`, `game/scripts/visual/ui_arena_v2.gd` | ✅ **8 različitih mjesta** iz recepata, bujnost 0–4, ComboLight, talas. **Ovo je referenca** za cijeli brief. | `00d`, `21`–`28` |
| **Run** | `game/scripts/visual/lane_background.gd`, `game/scripts/run/obstacle_visual.gd`, `game/scripts/seasons/season_theme.gd` | Jedna tamna livada s košenim stazama, `modulate` po sezoni. Prepreke su kamen i panj s `obstacle_modulate` tintom. | `00c`, `29`–`36` |
| **Cvijeće** | `game/assets/sprites/flowers/*.svg`, `game/scripts/visual/flower_assets.gd`, `camp_plant_draw.gd`, `seed_visual_config.gd` | Samo **Country Bloom** ima 18 SVG crteža (2026-09-10). Ostalih **42** tipa crta kod: isti krug latica u nijansi sezone (`SeedVisualConfig.SEASON_HUE`). U runu je T1 tih 42 tipa **sitna tačka na stabljici**, gotovo nevidljiva. | `00b`, `00c`, `19` |

Usput: `game/data/seasons/seasons.json` već ima prazna polja `thumbnail_path`, `run_bg_path`, `obstacle_theme_id`, `animal_skin_id` i `clear_rabbit_id`, napravljena upravo za ovaj posao, ali ih ništa još ne koristi.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| **Rasporedi iz prethodnih CD paketa** | Ostaju: Home v3 (tabovi, kartica, strelice, tačke, Play, prelaz kartica → polje), polje v2 (pločice Gift / Basket / Upgrades / Looks i donji red Seasons · Play · Endless), Shop v2 kartica (mjere, red portreta, ime, jedno dugme), Camp v2 link (redovi, Unlock, progres), hub header i footer (chrome v2), HUD runa, popups sistem, plant_frame okviri. **CD mijenja šta je iza i šta je nacrtano, ne raspored.** Ako misliš da raspored mora da se pomjeri zbog mjesta, predloži i obrazloži u README, ali ne crtaj tako. |
| **Mehanika i iznosi** | Unlock 500 coina + 20 ★3 cvijeta prethodne sezone, IAP cijene iz storea, roster 6 po sezoni (3 × ★1, 2 × ★2, 1 × ★3), 13 mjesta na polju s pragovima 1 / 5 / 10 ★3, Ember Fen „Coming soon". **Ništa se ne mijenja.** |
| **Geometrija runa** | 3 staze: `TRACK` 170–910, širina 200, šavovi na x 405 i 675, igrač na y 82 % (150 px). Kolizija prepreke 64 × 64. Crtež prepreke: tijelo 176 × 150 + ovratnik izgažene trave 240 × 52. Pickupi: coin 96, sjeme 120, dijamant 88. HUD (tajmer, Pip chip, brojači, pauza) se ne dira. |
| **Kontrast naljepnica** | Pločice i kartice su „naljepnice" s neprozirnim fillom i rubom 3 px koji drži ≥ 6,14 : 1 na svim trakama svih 8 sezona (`UiHomeField.STICKER*`). Nova pozadina to ne smije pokvariti. |
| **Kontrast objekata igre** | Pravilo Arene v2 (README `design_handoff_arena_v2` §1–3): svaki objekat na polju ima taman vanjski rub i svijetlu traku odmah do njega, pa jedna od te dvije ivice ima ≥ 3 : 1 na bilo kojoj livadi. Važi i za novo cvijeće, prepreke i pickupe u runu. |
| **Pillar 2 (Fair F2P)** | Plaćena sezona = **tema, ne snaga**. Besplatne sezone moraju biti **jednako lijepe** kao plaćene: razlika je mjesto, ne kvalitet. Shop kartica ne smije imati lažnu hitnost (tajmere, „samo danas", treperenje cijene). |
| **Arena v2** | Recepti livada, bujnost, ComboLight, talas i perf rješenja (commiti `ae73c5e`, `c3ca337`) ostaju osnova. Arena se usklađuje s kitom, ne crta ispočetka (§5.5). |
| **Base rezolucija** | 1080 × 1920. Stranica huba je 1080 × 1633 između headera (143) i footera (144). Sve mjere su u px te baze i prenose se 1:1. |

## 3. Šta se traži

Tačke 1–6 su **obavezne**. Izgled, boje i animacije su tvoja odluka, u okviru §2, §7 i §8. Jedan dizajnerski jezik za svih 8 sezona. Neka bude lijepo — ovo je ono što igrač gleda najviše.

1. **Season Kit za svaku od 8 sezona** (format u §4): mjesto, paleta, 2–4 potpis-motiva, jedan ambijent sloj.
2. **Svih 144 crteža cvijeća** (§6): 48 tipova × T1 / T2 / T3. To uključuje **obnovu** 18 današnjih Country Bloom crteža, da sve sezone budu u istom jeziku.
3. **Svaka površina iz §5 za svaku sezonu, u svim stanjima**: Home kartica, Home polje, Shop kartica (plaćene sezone), Camp link (besplatne sezone 2–4), Arena (usklađivanje), Run (tlo, staze, daljina, ambijent i 2 prepreke po sezoni).
4. **Kartica i polje su isto mjesto.** Prelaz kartica → polje traje 560 ms (zatvaranje 440 ms) i kartica u njemu **postaje** livada (`season_stage.gd`: livada ne crta svoje trake dok je napredak < 1). Crtež kartice mora biti isti recept kao polje, izrezan i skaliran, da predaja nema šav.
5. **Animacije** po budžetu iz §7: ambijent, njihanje cvijeća, Pipova reakcija na cvijet, paralaksa u runu.
6. **Samoprovjera** iz §9, izmjerena u browseru, s rezultatima u README.

## 4. Season Kit — format i 8 sezona

### 4.1 Šta jedan kit sadrži

| Dio | Sadržaj |
|---|---|
| **Mjesto** | Jedna rečenica: šta se vidi, gdje je horizont, šta je u daljini, a šta u blizini. Polazi od mjesta iz Arene v2 (tabela 4.2) i razvija ga, ne mijenja ga. |
| **Paleta** | Nebo, daljina, blizina, tlo staze, akcent, ink za tekst na tom mjestu. Za noćne sezone i svijetla verzija za tamne dijelove. Svaka boja je hex. |
| **Potpis-motivi** | 2–4 elementa po kojima se sezona prepozna i na traci od 364 px (Shop) i na 318 px (Camp): npr. ograda, red stabala, girlanda fenjera, mjesec, obala, prsten jela, rogoz. |
| **Ambijent** | Jedan sloj kretanja: pahulje, krijesnice, lišće, žeravice, mjehurići… Broj, brzina i ponašanje po §7. |
| **Cvijeće** | 18 crteža po §6, koji pripadaju tom mjestu. |
| **Rez po površini** | Kako se kit reže za svaku površinu iz §5 (koji dio mjesta, koja visina horizonta, gdje su mirne zone za tekst i kontrole). |

### 4.2 Osam sezona

Tagline je iz `seasons.json`. Mjesto je iz README-a `design_handoff_arena_v2` (§ Livade, tačka 23). Ambijent je samo prijedlog, odluka je tvoja.

| id | Ime | Vrsta | Tagline | Mjesto (Arena v2) | Ambijent (prijedlog) |
|---|---|---|---|---|---|
| `country_bloom` | Country Bloom | besplatna, početna | Warm fields, soft petals, home pastures. | Valoviti brežuljci, ograda na grebenu, pokošena trava | Maslačkove pahuljice ili leptir |
| `frost_orchard` | Frost Orchard | besplatna, 500 + 20 ★3 | Crisp air, silver blossom. | Ravan horizont, dva reda stabala, nanosi | Pahulje |
| `lantern_meadow` | Lantern Meadow | besplatna, 500 + 20 ★3 | Dusk lights among tall grass. | Visoka trava sa strana, girlanda fenjera | Krijesnice |
| `amber_canopy` | Amber Canopy | besplatna, 500 + 20 ★3 | Warm late-season light through high leaves. | Krošnja odozgo, dva debla, snopovi svjetla | Lišće koje pada |
| `moonlit_warren` | Moonlit Warren | plaćena | Night blooms under a quiet moon. | Mjesec, humke, jazbine | Treperenje zvijezda, mjesečeva prašina |
| `coral_tide` | Coral Tide Garden | plaćena | Salt breeze and seashell petals. | Obala dijagonalno, voda gore, pijesak dolje | Pjena na rubu vode, mjehurići |
| `starfall_glade` | Starfall Glade | plaćena | Petals that catch the night sky. | Prsten jela oko čistine, zvijezde | Zvijezde padalice |
| `ember_fen` | Ember Fen | plaćena, **coming soon** | Low firelight over marsh blooms. | Lokve, rogoz, dva pojasa dima | Žeravice |

Današnje boje tla (`UiHomeField.MEADOW_GROUND`) su polazna tačka, ne obaveza: Country `#E6F2DB`, Frost `#D1E6FF`, Lantern `#EBD6FF`, Amber `#FFEBC7`, Moonlit `#B8BDFF`, Coral `#FFE0D6`, Starfall `#DBCCFF`, Ember `#FFC79E`. Primijeti da Arena već koristi **tamne** livade za noćne sezone (Lantern, Moonlit, Starfall, Ember), a Home ih danas crta svijetlo. Kit odlučuje jednom za sezonu, i sve površine prate tu odluku.

## 5. Površine — šta se crta za svaku sezonu

### 5.1 Home — kartica izbora sezone

| | |
|---|---|
| **Fajlovi** | `game/scripts/ui/season_stage.gd`, `home_v3_card.gd`, `home_v3_card_content.gd`, `game/scripts/visual/ui_home_v3.gd`, `game/scenes/ui/season_stage.tscn` |
| **Mjere** | Kartica `(24, 172, 1032, 1160)`, radius 48, rub 4, sjena 12. Trake danas na 32 % i 68 %. Ime sezone 80 px gore. Roster: 6 portreta u 2 reda (kolone x 276 / 516 / 756, red 1 na y 230, red 2 na y 560), disk 180, ★3 je veći (220), crtež popunjava 0,78 diska. Tabovi Free / Premium iznad kartice, strelice i tačke sa strane i ispod. |
| **Stanja** | `owned` (igraš je), `locked` (besplatna, fali coina ili ★3, s progresom), `buy` (plaćena, cijena), `soon` (Ember Fen: crteži 50 %, „Coming soon" s isprekidanim rubom). Vidi `home_v3_card_content.gd` (`ST_LOCKED`, `ST_BUY`, `ST_OWNED`, `ST_SOON`). |
| **Traži se** | Pozadina kartice = **minijatura polja te sezone** (isti recept, §3.4). Portreti, ime i dugme ostaju čitljivi na njoj (tekst ≥ 4,5 : 1, portreti imaju svoj krem disk). Zaključana i „soon" stanja moraju i dalje izgledati kao to mjesto, ne kao siva kutija. |

### 5.2 Home — polje sezone (chill zona) — **najviše uloženo**

Ovdje igrač provodi vrijeme bez cilja: Pip šeta, njuši cvijeće i spava. Ovo je mjesto gdje sezona mora izgledati kao **stvarno mjesto**.

| | |
|---|---|
| **Fajlovi** | `game/scripts/ui/season_field.gd`, `season_field_flower.gd`, `season_field_pip.gd`, `game/scripts/visual/ui_home_field.gd`, `game/scenes/main_menu.tscn` |
| **Mjere** | Livada je **cijela stranica** 1080 × 1633 (od y 143), bez okvira. Trake danas: nebo 0–32 %, daljina 32–68 %, prednja 68–100 % (`MEADOW_BANDS`). Kontrole plutaju preko livade kao naljepnice: Gift `(24, 24, 180, 180)`, Basket `(24, 220, 180, 180)`, Upgrades `(876, 24, 180, 180)`, Looks `(876, 1265, 180, 180)`, naslov sezone i čip „13 / 13 grown" gore u sredini, donji red Seasons · Play · Endless. |
| **Cvijeće** | 13 mjesta (`MEADOW_SPOTS`), u 4 dubine (88 / 116 / 136 / 168 px), crtaju se od nazad prema naprijed. Mjesto se puni kad igrač ima dovoljno ★3 tog tipa (pragovi 1 / 5 / 10). Prazno mjesto je pilula zemlje. Kad ništa nije izraslo, piše „Nothing has grown here yet. Bring seeds back from a run." |
| **Pip** | 190 px. FSM: hoda 70 px/s (2,2–5,5 s), njuši cvijet unutar 72 px, spava. Težine 50 / 25 / 25 %. Zona baze `(151, 1306, 614, 131)`, ne smije u zone kontrola. |
| **Stanja** | 0 izraslo · 6 izraslo · svih 13 izraslo. Pip hoda / njuši / spava. |
| **Traži se** | Stvarno mjesto sezone: horizont, daljina, motivi, blizina, ambijent. Gornja grupa kontrola stoji na mirnom dijelu (nebo ili ekvivalent), donji red na mirnoj prednjoj traci. Smiješ predložiti drugi raspored 13 mjesta **po sezoni** (npr. Coral: cvijeće na pijesku uz vodu), ali broj (13), dubine, pragovi i redoslijed crtanja ostaju, i nijedno mjesto ne ide pod kontrole. Reakcija na Pipa (§7.2) i ulaz cvijeta kad izraste. |

### 5.3 Shop — kartica sezone (samo plaćene)

| | |
|---|---|
| **Fajlovi** | `game/scripts/ui/season_pack_card.gd`, `game/scripts/visual/ui_shop_v2.gd`, `game/scenes/ui/shop_screen.tscn` |
| **Mjere** | Kartica 1032 × 364. Danas: nebo 0–115, daljina, blizina 242–364. Red od 6 portreta: 5 × 148 + ★3 172 px, crtež 0,78 diska. Ispod: ime 52 px (`#1A1A14`) i jedno dugme. |
| **Stanja** | Cijena / kupi, kupuje se (busy), na čekanju (pending), vraća kupovine (restoring), **kupljena → ▶ Play** (vodi na Home), **soon** (Ember Fen: crteži 50 %, isprekidan rub, bez cijene i dugmeta). |
| **Sezone** | Moonlit Warren, Coral Tide Garden, Starfall Glade, Ember Fen. |
| **Traži se** | Kartica je **panorama mjesta** te sezone u traci 1032 × 364. Moonlit Warren mora izgledati kao noć pod mjesecom s jazbinama, a ne kao ljubičasta traka. Ime i dugme moraju biti čitljivi na crtežu (mirna zona ili traka ispod). Bez lažne hitnosti (§2). |

### 5.4 Camp — link kartica sljedeće besplatne sezone

| | |
|---|---|
| **Fajlovi** | `game/scripts/camp/season_link_card.gd`, `game/scripts/visual/ui_camp.gd`, `game/scenes/camp/camp_scene.tscn` |
| **Mjere** | 1032 × 318, padding 22. Glava 120 px: ime 56 px lijevo, Unlock 300 × 120 desno. Progres 128 px: lijevo coin ikona 56 + „320 / 500" (48 px) + traka 18; razdjelnik 5 × 128; desno okvir cvijeta 128 (crtež 108) + ime cvijeta 42 px + „12 / 20" + traka. Tekst `#3D3D33` danas drži 7,3 : 1 na tintu. |
| **Važno** | Cvijet u okviru je **★3 cvijet prethodne sezone** (traži se 20 komada za unlock): Frost link pokazuje Harvest Pumpkin, Lantern pokazuje Crystal Peony, Amber pokazuje Midnight Lotus. Nije cvijet sezone koja se otključava. |
| **Sezone** | Frost Orchard, Lantern Meadow, Amber Canopy (Country Bloom je početna i nikad nije „sljedeća"). |
| **Stanja** | Fali (short) · spremno (ready) · otključavanje (burst, pa skok na Home). |
| **Traži se** | Pozadina je panorama mjesta sezone koja se otključava (ona je cilj). Redovi ostaju čitljivi (tekst ≥ 4,5 : 1). Igrač treba poželjeti da ode tamo. |
| **Recept (faza 2)** | Kit u fazi 1 nema Camp površinu. Dodaj `kits[id].camp` = `{w: 1032, h: 318, layers: [...]}` za Frost, Lantern i Amber, istim rječnikom kao `shop` (§10.2). Agent ga crta kroz isti `SeasonBackdrop` umjesto `UiCamp.season_tint`; uglovi kartice idu maskom kao u Shopu. |

### 5.5 Arena — usklađivanje i doterivanje

| | |
|---|---|
| **Fajlovi** | `game/scripts/camp/arena_meadow_bg.gd`, `game/scripts/visual/ui_arena_v2.gd`, `game/scripts/camp/merge_arena_controller.gd`, `game/scenes/camp/merge_arena.tscn`, paket `design_handoff_arena_v2/` |
| **Danas** | 8 recepata (`fields[]`: slojevi kao poligoni u %, rasuti elementi po R2 nizu, bez RNG-a), bujnost 0–4 (T3 u rundi, crossfade 0,6 s), ComboLight, talas. Čip sjemena 134 px, kutija biljke 80 / 88 (plant_frame). Stranica 1080 × 1633. |
| **Traži se** | (a) **Isto mjesto kao Home polje**: ista paleta i isti potpis-motivi, tako da igrač prepozna da je Arena „iza kuće" iste sezone. (b) Doteraj recepte gdje ih kit poboljšava (npr. ambijent sloj, jasniji motiv). (c) Provjeri **novo cvijeće** (T1 / T2 u čipu, T3 burst) na svih 8 livada, posebno na tamnim. Ne ruši perf: livada se računa jednom (`_build_cache`), po frejmu se samo skaliraju tačke i boje. |

### 5.6 Run — staza, daljina, ambijent i prepreke

| | |
|---|---|
| **Fajlovi** | `game/scripts/visual/lane_background.gd`, `game/scripts/visual/ui_run.gd`, `game/scripts/run/obstacle.gd`, `obstacle_visual.gd`, `seed_visual.gd`, `run_controller.gd`, `game/scripts/seasons/season_theme.gd`, `game/scenes/run/run_scene.tscn`, `obstacle.tscn`, paket `design_handoff_run/` |
| **Danas** | „Smjer A": tlo `#26382C`, košene staze `#3A5C41` s prugama (period 124, pruga 40) i šavovima, dalji sloj s paralaksom 0,35 (period 720), bliži sloj (period 480), busenje i latice. Sve preko `modulate` tinta sezone. Prepreke: kamen i panj, s tintom (sijeno postoji u `UiRun.obstacle_colors`, ali se ne spawna). |
| **Traži se po sezoni** | **Tlo** (trava, snijeg, trava u sumrak, lišće, mjesečina, pijesak, mahovina, treset). **Materijal staze**, npr. ugažen snijeg (Frost), mokri pijesak (Coral), daske preko močvare (Ember). **Daljina** (paralaksa 0,35) i **blizina** uz rub staze (1,0). **Ambijent** koji pada ili leti preko svega. **2 prepreke** koje zamjenjuju kamen i panj, istog otiska (§2). |
| **Čitljivost** | Na svakoj sezoni prepreka se razlikuje od pickupa **na prvi pogled i u grayscaleu** (oblik + taman rub). Coin, sjeme i dijamant drže ≥ 3 : 1 prema stazi. Staza mora biti jasno odvojena od tla (igrač mijenja staze swipeom). Run smije biti svijetao ili taman po sezoni; HUD su krem naljepnice i popupi imaju scrim, pa rade na oba. |
| **Hookovi** | Predloži vrijednosti za `run_bg_path` i `obstacle_theme_id` u `seasons.json` (npr. `obstacle_theme_id = "<season_id>"`), da agent zna gdje se kit veže. |

Prijedlozi prepreka (odluka je tvoja, važni su otisak i čitljivost):

| Sezona | Prepreka A | Prepreka B |
|---|---|---|
| Country Bloom | kamen (osvježen) | panj ili bala sijena |
| Frost Orchard | blok leda / zaleđen kamen | panj pod snijegom |
| Lantern Meadow | drveni stub s fenjerom | kamen s mahovinom |
| Amber Canopy | srušeno deblo | panj s gljivama |
| Moonlit Warren | humka jazbine | kamen sa srebrnim lišajem |
| Coral Tide Garden | stijena sa školjkama | koralj |
| Starfall Glade | meteorit (kamen s iskrom) | panj jele |
| Ember Fen | panj koji tinja | busen rogoza u blatu |

## 6. Cvijeće — 48 tipova × T1 / T2 / T3

### 6.1 Svi tipovi (iz `seasons.json`, 2026-10-03)

`type_id` je ime fajla (§6.4). ★ je rijetkost i određuje kompleksnost (§6.2).

| Sezona | ★1 | ★1 | ★1 | ★2 | ★2 | ★3 |
|---|---|---|---|---|---|---|
| **Country Bloom** | `clover` Meadow Clover | `daisy` Field Daisy | `buttercup` Buttercup Lane | `tulip` Barn Tulip | `sunflower` Sunfence | `pumpkin` Harvest Pumpkin |
| **Frost Orchard** | `frost_snowdrop` Frost Snowdrop | `ice_crocus` Ice Crocus | `silver_aconite` Silver Aconite | `winter_camellia` Winter Camellia | `hoarfrost_rose` Hoarfrost Rose | `crystal_peony` Crystal Peony |
| **Lantern Meadow** | `dusk_firefly_grass` Dusk Firefly Grass | `paper_lantern_bloom` Paper Lantern Bloom | `evening_primrose` Evening Primrose | `foxfire_lily` Foxfire Lily | `glow_wisteria` Glow Wisteria | `midnight_lotus` Midnight Lotus |
| **Amber Canopy** | `copper_leaf` Copper Leaf | `maple_aster` Maple Aster | `russet_mallow` Russet Mallow | `cider_dahlia` Cider Dahlia | `golden_oak_bloom` Golden Oak Bloom | `amber_magnolia` Amber Magnolia |
| **Moonlit Warren** | `moon_moss` Moon Moss | `nightshade_petal` Nightshade Petal | `silver_harebell` Silver Harebell | `lunar_orchid` Lunar Orchid | `star_jasmine` Star Jasmine | `umbral_lily` Umbral Lily |
| **Coral Tide Garden** | `sea_thrift` Sea Thrift | `salt_daisy` Salt Daisy | `tide_anemone` Tide Anemone | `coral_hibiscus` Coral Hibiscus | `pearl_waterlily` Pearl Waterlily | `reef_crown` Reef Crown |
| **Starfall Glade** | `comet_sprig` Comet Sprig | `nebula_clover` Nebula Clover | `meteor_daisy` Meteor Daisy | `aurora_tulip` Aurora Tulip | `galaxy_sunburst` Galaxy Sunburst | `nova_bloom` Nova Bloom |
| **Ember Fen** | `marsh_rush` Marsh Rush | `peat_violet` Peat Violet | `cinder_buttercup` Cinder Buttercup | `flame_iris` Flame Iris | `smoke_lotus` Smoke Lotus | `fenfire_crown` Fenfire Crown |

Ime cvijeta je opis: Pumpkin je bundeva, Copper Leaf je list, Firefly Grass je trava s krijesnicama, Moon Moss je mahovina. Crtaj ono što ime kaže, u jeziku cvijeća igre — ne mora svaki biti klasičan cvijet s laticama.

### 6.2 Pravila

| Pravilo | |
|---|---|
| **T1 — sadnica** | Tek niknulo: stabljika i pupoljak ili prvi listovi. Silueta već govori koji je tip. Mora se čitati i kao sjeme u runu (120 px, bez okvira, u pokretu), gdje je danas tačka od par piksela. |
| **T2 — cvijet** | Otvoren cvijet, glavni prepoznatljiv oblik, puna boja. |
| **T3 — kristal** | **Isti cvijet kao T2**, ista silueta, s brušenim „dragulj" tretmanom (fasete, svijetla i tamna polovina latice, iskrice). **Bez krugova i prstenova preko cvijeta** — to je odbijeno 2026-09-10. Današnji Country Bloom T3 (`game/assets/sprites/flowers/*_t3.svg`) je dobar primjer smjera. |
| **Rijetkost → kompleksnost** | Važi za **sva tri tiera** istog cvijeta. ★1: malo oblika, jedna glavna boja + akcent, čista silueta. ★2: više latica ili slojeva, dvije nijanse, jedan mali detalj. ★3: najbogatiji (slojevi, kombinacija 2–3 boje, ukras), prepoznatljiv kao „najbolji u sezoni" već kao T1. Tier i rijetkost se kombinuju: T1 ★3 je jednostavniji od T2 ★3, ali bogatiji od T1 ★1 iste sezone. Rijetkost se ne smije čitati samo bojom (daltonisti) — broj i složenost oblika nose razliku. |
| **Cvijet pripada mjestu** | Frost je srebrn i leden, Lantern svijetli iznutra, Amber je jesenji, Coral ima školjke i more, Starfall kosmičke iskre, Ember vatru i dim, Moonlit blijedi srebrno-plavi sjaj. Cvijet mora izgledati kao da raste baš na tom polju. |
| **Čitljivost** | Svaki crtež se čita na: svojoj livadi (svijetloj ili tamnoj), krem disku (Shop, Home kartica, Journal), tamnom tlu runa ako run ostane taman. Zato svaki crtež ima taman vanjski rub (pravilo §2). Noćni cvijet treba i vlastiti svijetli rub ili sjaj da se vidi na tamnoj livadi (napomena iz README-a `design_handoff_arena_v2`). |

### 6.3 Gdje se crtež prikazuje i na kojoj veličini

| Mjesto | Veličina (px) | Tier |
|---|---|---|
| Home polje | 88 / 116 / 136 / 168 | T3 |
| Home kartica (roster) | disk 180 (★3 220), crtež 0,78 | T3 |
| Shop kartica | disk 148 (★3 172), crtež 0,78 | T3 |
| Journal | 128 | T1 / T2 / T3 |
| Arena čip | čip 134, kutija biljke 80 / 88 | T1 / T2 (T3 u burstu) |
| Camp (stash, link, trade) | 108 u okviru 128 | T1 / T3 |
| Run (sjeme) | 120, bez okvira | T1 |
| Kraj runa (loot) | 204 | T1 |
| Minimum čitljivosti | **64** (minijatura) | svi |

### 6.4 Tehnika crteža

- **SVG**, `viewBox="0 0 256 256"`. **Baza stabljike je na (128, 244)** za sve crteže (`camp_plant_draw.gd`, `TEX_TOP`).
- **Igra svuda crta odrezan crtež** (od faze 1): vidljivi pikseli (alpha > 0) popune mjesto po dužoj strani — polje (dno uz dno), kartica, Shop, Journal, Camp, Arena, run, korpa, loot. Zato je silueta kompaktna: nijedan odvojen element (iskra, list, mrlja, tačka rose) ne stoji daleko od tijela cvijeta, jer bi povećao rez i smanjio cijeli cvijet. Jedan SVG po tipu i tieru za cijelu igru, bez varijanti po površini.
- Raster u igri je 256 px. Linije ≥ 2 px na platnu 256, inače nestaju na 64 px.
- Stil naljepnice, kao današnjih 18: debeo taman vanjski rub, tanke unutrašnje linije, ravne boje.
- **Bez** gradijenata, filtera, blura, maski, `<text>`, slika i rastera. Svaki fajl ≤ 12 KB.
- **Čist SVG**: bez `<metadata>`, C2PA „content credentials", base64, `data:` i komentara. U fazi 1 su fajlovi nosili ~8 KB C2PA metapodataka i imali 9–19,7 KB umjesto ≤ 12 KB. Ako ih tvoj alat dodaje sam, napiši to u README i izmjeri veličinu bez njih.
- Ime fajla **tačno** `<type_id>_t<tier>.svg` iz tabele 6.1 (npr. `umbral_lily_t3.svg`). Igra ih učitava sama: `FlowerAssets` traži `res://assets/sprites/flowers/<type_id>_t<tier>.svg`, a svih 13 mjesta u igri crta biljke kroz `CampPlantDraw.draw_plant`. Kad fajl postoji, zamjenjuje proceduralni crtež svuda odjednom.
- Polazna tačka: 18 današnjih SVG-ova u `game/assets/sprites/flowers/` i generator `scripts/art/flowers_gen.py`. Jezik smiješ zadržati ili podići, ali Country Bloom se obnavlja u istom paketu.

## 7. Animacije

### 7.1 Alati i budžet

- Samo tweenovi (pozicija, skala, rotacija, alpha, boja) i lagane čestice crtane kao jednostavni oblici. Bez shadera, `GPUParticles2D`, blura i glowa.
- Ambijent: **najviše 24 čestice** na ekranu, pozicije po determinističkom nizu (kao R2 u Areni, bez RNG-a), petlja bez šava.
- Najviše **2 stalne petlje** po ekranu (npr. ambijent + njihanje). Sve ostalo su događaji.
- Svako trajanje i easing u `seasons_export.json` → `animations`.

### 7.2 Po površini

| Površina | Stalno | Događaji |
|---|---|---|
| **Home polje** | Ambijent sezone; blago njihanje cvijeća (±3°, 3–5 s, faza po mjestu) | Pip njuši cvijet → cvijet se nakloni (1 → 1,08 → 1, 0,3 s) i pusti 2–3 čestice sezone. Novi cvijet izraste (pop iz zemlje). Pip zaspi → ambijent se smiri. |
| **Home kartica** | Ništa ili jedan suptilan pokret (tvoja odluka) | Promjena sezone strelicom ili swipeom. Ambijent polja ulazi tek poslije prelaza (fade 0,3 s), da prelaz ostane bez šava. |
| **Shop kartica** | Ništa (lista u scrollu, perf) | Pritisak dugmeta. Kupljeno → kratki „unlock" trenutak u stilu sistema. |
| **Camp link** | Ništa | Postojeći burst pri otključavanju, u boji sezone. |
| **Arena** | Postojeće (bujnost, ComboLight, talas) | Ambijent sezone **samo ako** ne ruši perf (§8). |
| **Run** | Paralaksa daljine (0,35) i blizine (1,0) uz stazu; ambijent | Prepreka ulazi odozgo bez posebnog efekta (čitljivost prije svega). |

## 8. Tehnika i budžet

| | |
|---|---|
| **Engine** | Godot 4.7, renderer GL Compatibility (OpenGL 3.3). Cilj je slabiji Android; razvojni laptop ima AMD integrisanu grafiku. 60 fps u runu i Areni. |
| **Pozadine** | **Recepti** kao u Areni: slojevi kao poligoni u %, rasuti elementi po nizu, plus SVG motivi gdje oblik to traži. **0 PNG pozadina.** Pozadina se računa jednom po sezoni i veličini (keš), a po frejmu se mijenjaju samo pomak i alpha. |
| **Run** | Slojevi su vertikalno ponovljivi (period u px), kao danas (124 / 480 / 720). Crtanje ne smije rasti s brojem frejmova. |
| **Stil** | Ravne boje, radius, rub, jedna tvrda sjena. Bez blura, glowa i gradijenata; prijelaz neba radi se stepenastim trakama. |
| **Tekst** | Home ≥ 38 px (brojevi ≥ 44), ostalo ≥ 34, ime sezone ≥ 52 (na kartici 80). Font Nunito (`game/assets/fonts/nunito`). Kontrast teksta ≥ 4,5 : 1 na svom dijelu crteža. Dodir ≥ 120. |
| **Fajlovi** | Cvijet ≤ 12 KB (144 × 12 ≈ 1,7 MB najviše). Motivi ≤ 40 KB po sezoni. Recepti u JSON-u. |

## 9. Samoprovjera (mjeri u browseru, rezultat u README)

1. **Osam različitih mjesta** na svakoj površini: svih 8 jedno pored drugog — 8 različitih horizonata i struktura, ne ista slika u 8 boja.
2. **Kartica = polje:** zadnji kadar kartice i prvi kadar polja iste sezone poklapaju se bez šava.
3. **Kontrast:** tekst ≥ 4,5 : 1; rub naljepnica ≥ 6,14 : 1; cvijeće, sjemenke, pickupi i prepreke ≥ 3 : 1 na svih 8 mjesta.
4. **Run:** prepreka i pickup se razlikuju u grayscaleu na svih 8 sezona; staza je jasno odvojena od tla.
5. **Cvijeće:** list 6 × 3 po sezoni na 64, 128 i 192 px. ★1 < ★2 < ★3 po kompleksnosti u svakom tieru. T3 bez krugova i prstenova. T1 čitljiv na 64 px.
6. **Budžet:** veličine fajlova, broj čestica, broj stalnih petlji po ekranu.
7. **Imena:** svaki fajl cvijeta odgovara `type_id` iz §6.1, nijedan ne fali.

## 10. Faze — više CD sesija

Svaka faza isporučuje **cijeli** folder `design_handoff_seasons/` sa svim sezonama do tada (kumulativno). Poslije svake faze agent ugradi to u igru, napiše izvještaj (`seasons-izvjestaj.md`), ti odigraš, pa se sljedeći prompt prilagodi. Jedna faza smije trajati više CD chatova: na kraju svakog chata ide cijeli kumulativni ZIP s tabelom statusa u README, a sljedeći chat nastavlja od nje.

| Faza | Sezone | Šta | Status |
|---|---|---|---|
| **1** | **Country Bloom** (obnova) + **Moonlit Warren** | Sistem (format kita, tokeni, rez po površinama) + oba kita kompletno: 36 crteža, Home kartica, polje, Shop (Moonlit), Arena, Run s preprekama | ✅ u igri 2026-10-05 ([[seasons-izvjestaj]]) |
| **2** | **Svih 6 preostalih:** Frost Orchard, Lantern Meadow, Amber Canopy, Coral Tide Garden, Starfall Glade, Ember Fen | 6 kitova kompletno: **108 crteža**, Home kartica, polje, **Camp link** (Frost, Lantern, Amber), **Shop** (Coral, Starfall, Ember; Ember „soon"), Arena, Run s 2 prepreke po sezoni (12 SVG-ova), ambijent i animacije | ⏳ **aktuelno — prompt §12.0** |
| **3** | Svih 8 | Doterivanje: svih 8 jedno pored drugog, 144 crteža na jednom listu, animacije, perf mjerenja, ispravke iz playtesta i izvještaja faze 2 | čeka fazu 2 |

Prvobitni plan je imao 4 faze (besplatne i plaćene odvojeno). Spojene su jer je od početka traženo da **sve** sezone i **sve** cvijeće dobiju novi izgled, a faza 1 je pokrila samo dvije sezone.

### 10.1 Šta je naučeno iz faze 1 (obavezno za fazu 2)

| # | Lekcija iz faze 1 | Šta to znači za fazu 2 |
|---|---|---|
| 1 | Ovaj brief nije bio na `master` kad je CD radio fazu 1, pa je radio po sažetku iz poruke. | Sada jeste. Ovaj fajl, `seasons-ref/`, `seasons-faza1/`, `seasons-izvjestaj.md` i tvoj paket faze 1 (`design_handoff_seasons/`) su na `master`. Čitaj ih po tačnim putanjama iz §12.0. |
| 2 | Recept je izlazio iz svog recta: tlo do −2 / 102 / 101 %, rub grebena od −2 do 102 %. GL Compatibility na razvojnom laptopu ne reže crtanje (ni `clip_contents`), pa se na kartici izbora i u Shopu pozadina vidjela **izvan okvira kartice**, najviše u swipeu između kartica. | Igra sada sve reže na rect (slojevi u % na [0, 100] pri gradnji; oblik koji viri reže se trokut po trokut). Ti crtaj **unutar 0–100 %**. Ništa bitno (mjesec, motiv, ime) ne smije zavisiti od dijela izvan recta, a oblik prerezan ivicom kartice mora izgledati namjerno. |
| 3 | `pip_zone_feet` u exportu je bio širok 778, što pušta Pipa ispod pločice Looks. | Zona ostaje **`[151, 1306, 614, 131]`** za sve sezone. Ne mijenjaj je u kitu. |
| 4 | SVG-ovi su nosili C2PA metapodatke (~8 KB po fajlu) i imali 9–19,7 KB. | Čist SVG ≤ 12 KB, bez `<metadata>`, base64 i komentara (§6.4). |
| 5 | Cvijeće se u igri svuda crta **odrezano na vidljivi crtež** i popuni svoje mjesto (§6.4). | Kompaktna silueta, bez odvojenih elemenata daleko od cvijeta. Jedan crtež po tipu i tieru za cijelu igru. |
| 6 | Raster cvijeća je podignut na 256 px (polje do 168, disk 172 / 220, loot 204). | Linije ≥ 2 px na platnu 256. |
| 7 | Swipe između kartica traje 0,22 s s alphom 0,4 → 1, pa se slojevi dva kita kratko vide jedan kroz drugi. | Kit kartice neka podnese kratki crossfade. Ako misliš da kartice s kitom trebaju drugi prelaz (npr. klizanje bez alphe), predloži ga u README. |
| 8 | Prepreke kao SVG (tijelo 176 × 150, ovratnik u boji kita iz `run.collar`) rade dobro. | Isti format za svih 12 novih: `assets/seasons/<season_id>/obstacle_<ime>.svg`, ravna baza, taman rub, ista pravila čitljivosti. |
| 9 | Hookovi u `seasons.json` (`run_bg_path`, `obstacle_theme_id`) nisu potrebni: kit se veže po id-u sezone. | Ne popunjavaj ih. |
| 10 | Otvoreno pitanje faze 1: polje pokazuje T3 (kristal) na svih 13 mjesta. | Ostaje T3 dok korisnik ne odluči drugačije. |
| 11 | Tamne sezone: stranica izbora ostaje svijetla (`palette.page`), tekst direktno na livadi je `palette.ink_field`, a ispod kontrola su zabranjeni mid-tonovi (tvoje § Odlučeno 3 iz faze 1). | Isto za Lantern, Starfall i Ember ako budu tamne. Arena ih već crta tamno. |

### 10.2 Šta igra već zna crtati (nova sezona = novi red podataka)

Tvoj `design/seasons_kit.js` iz faze 1 je prenesen 1:1: `game/data/seasons/seasons_kit.json` (= tvoj `godot/seasons_export.json`), `game/scripts/visual/ui_seasons.gd`, `season_backdrop.gd` (polje, kartica, Shop), `season_ambient.gd` (ambijent polja), `lane_background.gd` (run), `obstacle_visual.gd` (prepreke), `ui_arena_v2.gd` (spajanje Arene). Sve iz tabele radi **bez novog koda**:

| Dio kita | Podržano danas |
|---|---|
| Slojevi polja, kartice i Shopa | `band` (traka neba), `ridge` (+ `rim`), `mow` (pruge između pomaknutih grebena), `fence` (stubovi po grebenu + letve), `shape` (motiv na tački), `scatter` (R2 niz, preskače keepout zone polja) |
| Oblici (`shapes`) | primitivi `c` krug, `e` elipsa, `p` poligon, `r` pravougaonik (zaobljen), `l` linija, `a` luk; boja je indeks u `pal` |
| 13 mjesta | `spots`: [x %, y % od dna, veličina, indeks u rosteru, prag] |
| Ambijent polja | `petals` (klizi po `drift`, rotira, alpha 0 → 0,9 → 0) i `stars_motes` (`twinkle` trepere, `motes` se dižu) |
| Arena | `base`, `layers`, `addLayers`, `scatter`, `addScatter`, `combo` preko `UiArenaV2.FIELDS[id]` |
| Run | `ground`, `lane`, `laneEdge`, `seam`; `material` = pruge (`stripe`, `period`, `on`) ili kamenčići (`pebble`, `period`); `far` (oblik na pozicijama, 0,35×); `near` (`posts`, `tufts`, `moss`, `flowers`, `glints`); `ambient` (latica ili tačka); `collar`; `obstacles` (2 SVG-a) |
| Shop | `shop` = `{w: 1032, h: 364, layers}`; crta se u 1024 × 356 unutar ruba 4 |

**Novo u fazi 2:**

- **Camp link:** recept `camp` = `{w: 1032, h: 318, layers}` za Frost, Lantern i Amber (§5.4).
- **Ambijenti** iz §4.2 (pahulje, krijesnice, lišće, mjehurići, zvijezde padalice, žeravice) uglavnom nisu ni `petals` ni `stars_motes`. Ne pravi šest posebnih kodova: dodaj **jedan generički** opis čestice, npr. `motion: drift | fall | rise | float | twinkle | streak` s poljima `n`, `shape`, `size`, `pal`, `zone`, `drift`, `sec`, `rot`, `alpha`, `pulse`, koji pokriva svih 8 sezona (i stare dvije), uz referentnu implementaciju u `seasons_kit.js`.
- **Materijal staze u runu:** ako trebaš nešto osim pruga i kamenčića (ugažen snijeg, mokri pijesak, daske preko močvare), dodaj ga isto **generički** (npr. `material.kind: stripe | pebble | plank | …` s parametrima).
- Svaki novi sloj, oblik ili ponašanje: tačni parametri u README § Novi primitivi, implementacija u `seasons_kit.js` i red u `godot/seasons_tree.txt`. Agent ih prenosi iz JS-a u GDScript, pa je bolje što manje novih vrsta.

## 11. Isporuka

Novi folder **`design_handoff_seasons/`**, cijeli u ZIP-u za preuzimanje u chatu, kumulativno po fazama:

- **`README.md`** (bosanski): ideja u par rečenica, šta otvoriti, **tabela statusa sezona × površina**, odluke, šta se briše, rezultati samoprovjere, otvorena pitanja.
- **`design/SeasonScreen.dc.html`** — artboard 1080 × 1920. Propovi:
  - `season` — 8 id-eva iz §4.2,
  - `surface` — `card · field · shop · camp · arena · run · flowers` (faza 1 je koristila kratka imena; `camp` je novo u fazi 2),
  - `state` — stanja površine iz §5,
  - `lush` — Arena 0–4,
  - `still` — bez animacija, za sličice.
- **`design/Season Specs.dc.html`**: kit po sezoni (paleta, motivi, ambijent), sve površine jedne sezone jedna pored druge, list cvijeća 6 × 3 na 64 / 128 / 192 px, tabela kontrasta, dugme za samoprovjeru (§9).
- **`assets/flowers/<type_id>_t<tier>.svg`** — 18 po sezoni, imena tačno iz §6.1 (poslije faze 2: svih 144).
- **`assets/seasons/<season_id>/`** — SVG motivi koji nisu recept (npr. prepreke, ograda, fenjer), ako ih ima.
- **`godot/seasons_export.json`** — `meta`, `tokens`, `kits` (paleta, motivi, ambijent po sezoni), `surfaces` (recept po površini i sezoni), `obstacles`, `animations`, `strings_en`, `godot_map`, `decisions`.
- **`godot/ui_seasons.gd`** — konstante i pristup receptima; imena kao u `UiHomeField` / `UiArenaV2` gdje postoje.
- **`godot/seasons_tree.txt`** — šta ide u koji fajl iz §5 i redoslijed prenosa.

U README napiši šta se **briše** kad kit stigne u igru (npr. `SeasonTheme.bg_modulate` i `obstacle_modulate`, `UiCamp.season_tint`, `UiShopV2.season_bands`, proceduralno cvijeće iz `SEASON_HUE` za tipove koji dobiju crtež).

## 12. Prompt za Claude Design

### 12.0 Faza 2 — svih 6 preostalih sezona (AKTUELNO)

> Prije slanja: sve je commitano i pushano na `master`. CD-u je dovoljan kratki prompt koji pokazuje na ovaj fajl i §12.0; blok ispod je pun zadatak.

```
Ovo je FAZA 2 REDIZAJNA SEZONA: SVIH 6 PREOSTALIH SEZONA ODJEDNOM.
Faza 1 (Country Bloom + Moonlit Warren) je gotova i u igri je. Ali od
početka je traženo da SVAKA sezona i SVO cvijeće dobiju novi izgled:
mjesto, pozadine, prepreke, ambijent, animacije. Sada radiš ostalih
šest: Frost Orchard, Lantern Meadow, Amber Canopy (besplatne) i Coral
Tide Garden, Starfall Glade, Ember Fen (plaćene; Ember je "Coming soon").

Prvo pročitaj (repo, grana master, tačne putanje):
  docs/04-experience/design-drafts/seasons-cd-brief.md
    -> CIJELI; obavezno §10.1 (lekcije iz faze 1) i §10.2 (šta igra
       već zna crtati), pa §2 (fiksno), §4.2 (8 sezona), §5 (površine:
       mjere, stanja, šta se crta), §6 (cvijeće), §7 (animacije), §8
       (tehnika), §9 (samoprovjera), §11 (isporuka)
  docs/04-experience/design-drafts/seasons-izvjestaj.md  (kako je faza 1
       ušla u igru: nalazi, mjerenja, popravke)
  docs/04-experience/design-drafts/seasons-faza1/01_home_kartica_polje.jpg
    ... 02_prelaz_u050_u0999_u1.jpg, 03_run_shop.jpg, 04_arena_l0_l4.jpg,
    05_pip_njusi_spava.jpg   (igra poslije faze 1)
  docs/04-experience/design-drafts/seasons-ref/  (stanje prije: listovi
       00a_sheet_home_card.jpg, 00b_sheet_home_field.jpg,
       00c_sheet_run.jpg, 00d_sheet_arena.jpg, 00e_sheet_camp_link.jpg;
       pojedinačno 02–04, 06–08 kartice; 10–12, 14, 15 polja; 16–18
       Camp link; 19–20 Shop; 22–24, 26–28 Arena; 30–32, 34–36 run)
  design_handoff_seasons/  = TVOJ PAKET FAZE 1, polazna tačka:
       README.md, design/seasons_kit.js, design/SeasonScreen.dc.html,
       design/Season Specs.dc.html, design/arena_v2_data.js,
       godot/seasons_export.json, godot/ui_seasons.gd,
       godot/seasons_tree.txt, tools/flowers_gen.js,
       assets/flowers/flowers_meta.json
  game/data/seasons/seasons_kit.json   (tvoj export kako je u igri)
  game/data/seasons/seasons.json       (roster, tagline, unlock)
  game/scripts/visual/ui_seasons.gd, season_backdrop.gd,
    season_ambient.gd, lane_background.gd, ui_arena_v2.gd,
    ui_home_field.gd, ui_camp.gd, ui_shop_v2.gd, camp_plant_draw.gd,
    flower_assets.gd
  game/scripts/ui/season_field.gd, season_field_flower.gd,
    season_field_pip.gd, home_v3_card.gd, home_v3_card_content.gd,
    season_pack_card.gd, season_stage.gd
  game/scripts/camp/season_link_card.gd, arena_meadow_bg.gd
  game/scripts/run/obstacle_visual.gd, seed_visual.gd
  design_handoff_arena_v2/README.md (§ Livade) i
    design_handoff_arena_v2/design/arena_v2_data.js  (mjesta svih 8)
  design_handoff_camp_season_link/README.md (+ design/, godot/)
  design_handoff_camp_v2/README.md
  design_handoff_shop_v2/design/Shop Specs.dc.html,
    design_handoff_shop_v2/godot/shop_v2_export.json
  design_handoff_run/design/RunScreen.dc.html
  game/assets/sprites/flowers/  (tvojih 36 crteža iz faze 1, isti jezik)
  game/assets/sprites/seasons/  (4 prepreke iz faze 1, isti format)

FAZA 2 = 6 KITOVA KOMPLETNO, ISTI SISTEM KAO FAZA 1 (nova sezona =
novi red u kits, renderer ostaje). Za SVAKU od 6 sezona:
  1. KIT: mjesto (razvij mjesto iz Arene v2, §4.2), paleta (hex),
     2–4 potpis-motiva, ambijent. Svaka sezona je DRUGO MJESTO, ne
     druga boja: 8 različitih horizonata i struktura jedno pored drugog.
  2. CVIJEĆE: 18 crteža (6 tipova × T1/T2/T3, imena iz §6.1), ukupno
     108 novih SVG-ova u jeziku tvojih 36 iz faze 1. T3 = isti T2
     crtež kao brušeni kristal, BEZ krugova, prstenova i iskrica.
     Rijetkost -> kompleksnost u sva 3 tiera. Cvijet pripada mjestu
     (Frost srebrn i leden, Lantern svijetli iznutra, Amber jesenji,
     Coral školjke i more, Starfall kosmičke iskre, Ember vatra i dim).
     T1 se čita kao sjeme u runu na 120 px i na 64 px.
  3. HOME KARTICA (§5.1), isti recept kao polje, sva stanja: Frost,
     Lantern, Amber owned + locked s progresom; Coral, Starfall buy +
     owned; Ember soon (crteži 50 %, "Coming soon" s isprekidanim rubom).
  4. HOME POLJE (§5.2), NAJVIŠE ULOŽENO: stvarno mjesto, 13 mjesta
     (smiješ ih rasporediti po mjestu; broj, dubine i pragovi ostaju),
     ambijent, mirne zone ispod kontrola, stanja 0 / 6 / 13 izraslo,
     Pip hoda / njuši / spava. Pip zona [151, 1306, 614, 131], ne
     mijenjaj je. Ember: kit potpun, iako je polje zaključano dok je "soon".
  5. SHOP KARTICA (§5.3) za Coral, Starfall, Ember: panorama mjesta
     1032 x 364 (crta se 1024 x 356 unutar ruba), sva stanja dugmeta;
     Ember soon: crteži 50 %, isprekidan rub, bez cijene i dugmeta.
  6. CAMP LINK (§5.4) za Frost, Lantern, Amber: NOVI recept "camp"
     1032 x 318, panorama mjesta koje se otključava; stanja short /
     ready / burst; cvijet u okviru je ★3 PRETHODNE sezone.
  7. ARENA (§5.5): uskladi svih 6 recepata s kitom (kits[id].arena
     preko UiArenaV2.FIELDS) i provjeri novo cvijeće na svih 6 livada.
  8. RUN (§5.6): tlo, materijal staze, daljina (0,35×), blizina (1,0×),
     ambijent, 2 prepreke po sezoni = 12 SVG-ova (tijelo 176 x 150 +
     ovratnik 240 x 52, ravna baza, taman rub; kolizija 64 x 64 ostaje).
     Prepreka se razlikuje od pickupa i u grayscaleu.
  9. ANIMACIJE (§7): ambijent <= 24 čestice, <= 2 stalne petlje po
     ekranu; Pip njuši -> cvijet se nakloni + čestice sezone; cvijet
     izraste. Ambijente (pahulje, krijesnice, lišće, mjehurići, zvijezde
     padalice, žeravice) opiši JEDNIM generičkim formatom čestica
     (§10.2), ne sa šest posebnih.

LEKCIJE IZ FAZE 1 (§10.1, obavezno):
  - Sve unutar recta 0–100 %. U fazi 1 je pozadina izlazila iz okvira
    kartice izbora i Shop kartice. Igra sada reže ono što viri, ali
    ništa bitno ne smije zavisiti od toga.
  - Čist SVG <= 12 KB, BEZ <metadata>, C2PA, base64 i komentara.
  - Cvijet se svuda crta odrezan na vidljivi crtež: kompaktna silueta,
    bez odvojenih elemenata daleko od cvijeta; baza stabljike (128, 244);
    linije >= 2 px na platnu 256.
  - Novi slojevi, oblici i ponašanja samo GENERIČKI, s tačnim
    parametrima u README § Novi primitivi i implementacijom u
    seasons_kit.js.
  - Country Bloom i Moonlit Warren ostaju kakvi jesu. Ako ih moraš
    uskladiti s ostalima, napiši šta i zašto u README.

FIKSNO: rasporedi iz prethodnih paketa (Home v3, polje v2, Shop v2,
Camp v2 + Camp link, chrome v2, HUD runa, popups, plant_frame) —
mijenjaš šta je iza i šta je nacrtano, ne raspored. Iznosi (unlock 500
+ 20 ★3, cijene iz storea, 13 mjesta, pragovi 1 / 5 / 10). Geometrija
runa. Kontrast: naljepnice >= 6,14:1 (dvostruki rub, bez mid-tonova
ispod kontrola), objekti >= 3:1, tekst >= 4,5:1. Pillar 2: plaćeno =
tema, ne snaga; besplatne sezone JEDNAKO lijepe kao plaćene; bez lažne
hitnosti u Shopu.

TEHNIČKI: Godot 4.7, OpenGL 3.3, slabiji Android, 60 fps. Artboard
1080 x 1920, stranica huba 1080 x 1633 (header 143, footer 144).
Recepti (poligoni u %, rasuti elementi po R2 nizu, bez RNG-a) + SVG
motivi; 0 PNG pozadina; računa se jednom, po frejmu samo pomak i alpha.
Ravne boje, bez blura, glowa i gradijenata (nebo stepenastim trakama).
Tekst >= 34 (Home >= 38, ime sezone >= 52), dodir >= 120, Nunito.

ISPORUKA (§11): CIJELI design_handoff_seasons/ (kumulativno: faza 1 +
faza 2, svih 8 sezona) u ZIPU za preuzimanje u chatu:
  README.md (bosanski: tabela statusa 8 sezona x 7 površina, kitovi,
    § Odlučeno, § Novi primitivi, § Šta se briše, samoprovjera,
    otvorena pitanja)
  design/SeasonScreen.dc.html (season = svih 8; surface = card, field,
    shop, camp, arena, run, flowers; state; lush; still; u; pip)
  design/Season Specs.dc.html (svih 8 jedno pored drugog po površini;
    list cvijeća 6 x 3 po sezoni na 64 / 128 / 192; kontrast;
    dugme za samoprovjeru)
  design/seasons_kit.js (svih 8 kitova)
  assets/flowers/<type_id>_t<tier>.svg (144: 36 iz faze 1 + 108 novih)
    + flowers_meta.json
  assets/seasons/<season_id>/obstacle_*.svg (16: 4 + 12 novih)
  godot/seasons_export.json, godot/ui_seasons.gd, godot/seasons_tree.txt

SAMOPROVJERA (§9) za svih 8 sezona prije predaje; rezultat u README.

AKO NE STIGNEŠ SVE U JEDNOM CHATU: radi sezonu po sezonu ovim redom —
Frost, Lantern, Amber, Coral, Starfall, Ember — i na kraju SVAKOG chata
isporuči cijeli kumulativni ZIP s tabelom statusa u README; sljedeći
chat nastavlja od nje. Ne štedi na kvaliteti da bi stigao brže: bolje
dvije sesije s potpunim kitovima nego jedna s polovičnim.
```

### 12.1 Faza 1 (urađeno 2026-10-05, zadržano kao zapis)

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je VIŠEFAZNI REDIZAJN SEZONA. Danas sezone imaju samo boju: polje,
Home kartica i Shop kartica su iste 3 trake u 8 nijansi, run je ista
staza s tintom, prepreke su isti kamen i panj, a 42 od 48 vrsta cvijeća
su isti krug. Samo Arena v2 zna da je svaka sezona DRUGO MJESTO.
To pravilo širimo na cijelu igru: svaka sezona dobija jedan Season Kit
(mjesto, paleta, motivi, ambijent, 18 crteža cvijeća) koji se reže na
svaku površinu. Ovo je FAZA 1 od 4.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/seasons-cd-brief.md
    -> §2 (fiksno), §3 (šta se traži), §4 (format kita + 8 sezona),
       §5 (svaka površina: mjere, stanja, šta se crta), §6 (cvijeće:
       tabela, pravila, veličine, tehnika), §7 (animacije), §8
       (tehnika), §9 (samoprovjera), §11 (isporuka)
  docs/04-experience/design-drafts/seasons-ref/   (41 slika iz igre;
       uporedni listovi 00a–00e: svih 8 sezona jedna pored druge)
  docs/04-experience/art-direction.md
  game/data/seasons/seasons.json
  design_handoff_arena_v2/   (README § Livade, ArenaScreen.dc.html,
       ArenaField.dc.html, Arena Specs.dc.html, arena_v2_data.js,
       godot/arena_v2_export.json, godot/ui_arena_v2.gd) — REFERENCA
  design_handoff_home_v3/    (HomeScreen.dc.html, FieldScreen.dc.html,
       godot/home_v3_export.json) — kartica i prelaz kartica -> polje
  design_handoff_home_field_v2/ (FieldScreen.dc.html, Field Specs.dc.html,
       godot/home_field_v2_export.json) — polje, pločice, Pip
  design_handoff_shop_v2/    (FlowerPortrait.dc.html, Shop Specs.dc.html,
       godot/shop_v2_export.json) — Shop kartica sezone
  design_handoff_run/        (RunScreen.dc.html, Run Redesign.dc.html)
  design_handoff_plant_frame/ (PlantFrame.dc.html, README) — okviri
  design_handoff_popups/     (Popup Specs.dc.html) — tokeni sistema
  game/assets/sprites/flowers/   (18 današnjih Country Bloom SVG-ova)
  scripts/art/flowers_gen.py     (kako su nastali)
  game/scripts/visual/ui_arena_v2.gd, ui_home_field.gd, ui_home_v3.gd,
    ui_shop_v2.gd, ui_camp.gd, ui_run.gd, lane_background.gd,
    camp_plant_draw.gd, flower_assets.gd, seed_visual_config.gd
  game/scripts/seasons/season_theme.gd, season_def.gd, seed_catalog.gd
  game/scripts/ui/season_stage.gd, season_field.gd, season_field_flower.gd,
    season_field_pip.gd, home_v3_card.gd, home_v3_card_content.gd,
    season_pack_card.gd
  game/scripts/camp/season_link_card.gd, arena_meadow_bg.gd
  game/scripts/run/obstacle.gd, obstacle_visual.gd, seed_visual.gd
  game/scenes/ui/season_stage.tscn, game/scenes/main_menu.tscn,
    game/scenes/run/run_scene.tscn, game/scenes/run/obstacle.tscn

FAZA 1 = SISTEM + DVA KITA KOMPLETNO:

  COUNTRY BLOOM (besplatna, početna; mjesto: valoviti brežuljci, ograda
  na grebenu, pokošena trava) i MOONLIT WARREN (plaćena; mjesto: mjesec,
  humke, jazbine). Svjetla i tamna, besplatna i plaćena — dokaz da
  sistem radi na oba kraja.

  Za oba:
  1. KIT: mjesto, paleta (hex), 2–4 potpis-motiva, ambijent.
  2. CVIJEĆE, 36 crteža (§6): 6 tipova × T1/T2/T3 po sezoni. Country
     Bloom se OBNAVLJA u istom jeziku. T3 = isti cvijet + brušeni
     kristal, BEZ krugova/prstenova preko cvijeta. Rijetkost -> kompleksnost
     u sva 3 tiera. SVG viewBox 256, baza stabljike (128,244), taman
     vanjski rub, ime <type_id>_t<tier>.svg, <= 12 KB, bez gradijenata.
  3. HOME KARTICA (§5.1) u stanjima owned/locked/buy — pozadina je
     minijatura polja, ISTI recept (prelaz 560 ms bez šava).
  4. HOME POLJE (§5.2) — NAJVIŠE ULOŽENO: stvarno mjesto, 13 mjesta za
     cvijeće (smiješ ih rasporediti po mjestu, broj/dubine/pragovi
     ostaju), Pip hoda/njuši/spava, kontrole na mirnim zonama, stanja
     0 / 6 / 13 izraslo.
  5. SHOP KARTICA (§5.3) za Moonlit Warren: panorama noći pod mjesecom u
     1032 x 364, sva stanja dugmeta, ime i dugme čitljivi.
  6. ARENA (§5.5): uskladi oba recepta s kitom (isto mjesto kao polje),
     provjeri novo cvijeće na livadi.
  7. RUN (§5.6): tlo, materijal staze, daljina (0,35), blizina, ambijent,
     2 prepreke po sezoni (tijelo 176 x 150 + ovratnik 240 x 52,
     kolizija 64 x 64 ostaje). Prepreka != pickup u grayscaleu.
  8. ANIMACIJE (§7): ambijent <= 24 čestice, <= 2 stalne petlje po
     ekranu, Pip njuši -> cvijet se nakloni + čestice, cvijet izraste.

FIKSNO: rasporedi iz prethodnih paketa (Home v3, polje v2, Shop v2,
Camp v2, chrome v2, HUD runa, popups, plant_frame) — mijenjaš šta je
iza i šta je nacrtano, ne raspored. Iznosi i uslovi (unlock 500 + 20
★3, cijene iz storea, 13 mjesta, pragovi). Geometrija runa. Kontrast
naljepnica >= 6,14:1, objekti >= 3:1, tekst >= 4,5:1. Pillar 2:
plaćeno = tema, ne snaga; besplatne sezone jednako lijepe; bez lažne
hitnosti u Shopu.

TEHNIČKI (Godot 4.7, OpenGL 3.3, slabiji Android, 60 fps): artboard
1080 x 1920, stranica huba 1080 x 1633 (header 143, footer 144), sve
u px te baze. Pozadine su RECEPTI kao u Areni (poligoni u %, rasuti
elementi po nizu, bez RNG-a) + SVG motivi; 0 PNG pozadina; računa se
jednom, po frejmu samo pomak/alpha. Ravne boje, radius, rub, jedna
tvrda sjena; bez blura, glowa, gradijenata (nebo stepenastim trakama).
Tekst >= 34 (Home >= 38, ime sezone >= 52), dodir >= 120, Nunito.

ISPORUKA (§11): novi folder design_handoff_seasons/, CIJELI U ZIPU za
preuzimanje u chatu:
  README.md (bosanski: ideja, šta otvoriti, tabela statusa sezona x
    površina, odluke, šta se briše, samoprovjera, otvorena pitanja)
  design/SeasonScreen.dc.html (propovi season, surface, state, lush, still)
  design/Season Specs.dc.html (kit po sezoni, sve površine, list cvijeća
    6 x 3 na 64/128/192, kontrast, dugme za samoprovjeru)
  assets/flowers/<type_id>_t<tier>.svg (36 u fazi 1)
  assets/seasons/<season_id>/ (motivi i prepreke koji nisu recept)
  godot/seasons_export.json, godot/ui_seasons.gd, godot/seasons_tree.txt

SAMOPROVJERA (§9) prije predaje: dva različita mjesta na svakoj
površini; kartica = polje bez šava; kontrast; run grayscale; cvijeće na
64 px; budžet; imena fajlova. Napiši rezultat u README.

Nakon faze 1 slijede faze 2 (Frost, Lantern, Amber + Camp link) i 3
(Coral, Starfall, Ember) — drži sistem takvim da se kit doda kao novi
red podataka, bez novog koda.
```

### 12.2 Stari plan faza 2–4 (zamijenjen sa §12.0)

Zadržano kao zapis. Faze 2 i 3 su spojene u §12.0, a faza 4 je sada faza 3 (§10).

- **Faza 2:** „FAZA 2 = TRI BESPLATNA KITA: Frost Orchard, Lantern Meadow, Amber Canopy. Sistem iz faze 1 ostaje — dodaješ kit kao novi red podataka. Za sve tri: kit, 54 crteža, Home kartica (owned / locked s progresom), polje, Arena, Run s 2 prepreke, **Camp link** (§5.4: pozadina je mjesto koje se otključava; cvijet u okviru je ★3 prethodne sezone). Isporuči cijeli folder s fazom 1 unutra." Dodaj na listu za čitanje `design_handoff_camp_v2/` i `design_handoff_camp_season_link/` i fajl `docs/04-experience/design-drafts/seasons-izvjestaj.md` (izvještaj faze 1, ako postoji).
- **Faza 3:** „FAZA 3 = TRI PLAĆENA KITA: Coral Tide Garden, Starfall Glade, Ember Fen. Kit, 54 crteža, Home kartica (buy / owned, Ember i `soon`), polje (Ember nema polje dok je „soon", ali kit je potpun), Shop kartica (sva stanja; Ember `soon`: crteži 50 %, isprekidan rub, bez dugmeta), Arena, Run s 2 prepreke."
- **Faza 4:** „FAZA 4 = DOTERIVANJE CIJELOG SETA: svih 8 sezona jedna pored druge na svakoj površini, 144 crteža na jednom listu (ista težina linije, isti nivo detalja po rijetkosti), animacije po §7, perf napomene, i ispravke iz izvještaja faza 1–3 (`seasons-izvjestaj.md`)."

## 13. Prenos u Godot (za agenta — CD može preskočiti)

Redoslijed po fazi, svaki korak sa smoke testom i ref slikama iz `seasons_capture.gd` (prije → poslije):

1. **Cvijeće:** `assets/flowers/*.svg` → `game/assets/sprites/flowers/`, pa `scripts/godot-import.ps1` i commit `.import` fajlova. `FlowerAssets` ih nalazi sam. Provjeri import skalu (danas raster 128 px) prema najvećoj veličini iz §6.3 (204 px na loot ekranu).
2. **Kit podaci:** `ui_seasons.gd` i `seasons_export.json` → `game/scripts/visual/`. Popuni `run_bg_path` i `obstacle_theme_id` u `seasons.json`.
3. **Home polje i kartica:** `season_field.gd` crta recept umjesto 3 trake; `home_v3_card` koristi isti recept izrezan. Provjeri šav prelaza (`home_capture.gd` snima kadrove u 0 … 1).
4. **Shop i Camp:** `season_pack_card.gd` (umjesto `season_bands`), `season_link_card.gd` (umjesto `season_tint`).
5. **Arena:** spoji izmjene recepata u `UiArenaV2.FIELDS`, izmjeri perf (`arena_perf_bench.gd`).
6. **Run:** `lane_background.gd` crta recept sezone (keš po sezoni), `obstacle_visual.gd` bira prepreke po `obstacle_theme_id`; obriši tint iz `SeasonTheme`.
7. **Camp link (faza 2):** `season_link_card.gd` crta `kits[id].camp` kroz `SeasonBackdrop.draw` + maske uglova (kao `season_pack_card.gd`), umjesto `UiCamp.season_tint`.
8. **Novi primitivi (faza 2):** svaki iz README § Novi primitivi prenijeti iz `seasons_kit.js` u `ui_seasons.gd` / `season_backdrop.gd` / `season_ambient.gd` / `lane_background.gd`, generički (podaci, ne grananje po sezoni).
9. **Provjera reza:** `SeasonBackdrop` reže slojeve na [0, 100] % i oblike koji vire na rect; snimi kartice izbora i Shop u swipeu (ivice kartice, bez pozadine izvan okvira).
10. **Izvještaj** `docs/04-experience/design-drafts/seasons-izvjestaj.md` (bosanski, tabela po zadatku, odluke koje čekaju tebe).

## Povezano

- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — prvi brief za cvijeće (2026-09-10); pravila tiera i rijetkosti su prenesena u §6
- [[merge-arena-cd-brief|merge-arena-cd-brief]] — Arena, odakle dolazi pravilo „drugo mjesto, ne druga boja"
- [[home-v3-cd-brief|home-v3-cd-brief]] · [[home-field-v2-cd-brief|home-field-v2-cd-brief]] · [[shop-v2-cd-brief|shop-v2-cd-brief]] · [[camp-v2-cd-brief|camp-v2-cd-brief]] · [[run-cd-brief|run-cd-brief]] · [[plant-frame-cd-brief|plant-frame-cd-brief]] · [[popups-cd-brief|popups-cd-brief]]
- [[../art-direction|art-direction]] · [[../../01-vision/design-pillars|design-pillars]] · [[../../06-production/scope-i-granice|scope-i-granice]] · [[../../06-production/CHECKPOINT|CHECKPOINT]]
