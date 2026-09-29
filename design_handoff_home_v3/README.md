# Home v3 — handoff

Jedan dizajn Homea: biranje sezone (dva taba) i ulaz u polje te sezone. Hub header (143) i footer (144) su chrome v2, nedirnuti.

## Šta otvoriti
- `design/HomeScreen.dc.html` — biranje, interaktivno. Prop `scene` (free_active · free_open · free_locked · free_unlock · premium_buy · premium_owned · premium_soon), `tab` (free|premium), `openT` / `closeT` (0–1, zamrznut kadar prelaza), `pipWalked` (zatvaranje kad je Pip odšetao). Klik: strelice, tabovi, Play, kartica, Unlock, cijena; na polju Seasons vraća nazad.
- `design/FieldScreen.dc.html` — polje. Prop `season` (8 ključeva), `scene` (gift · basket_empty · first), `u` (0–1, napredak prelaza); u Homeu se montira kao `embedded` (bez svojih traka, imena, Pipa i Playa — to nosi Home).
- `design/Home Specs.dc.html` — runda 3: šest stanja kartice jedno pored drugog + anatomija zone cvijeća; zatim sva stanja §6.1, trake kadrova otvaranja / zatvaranja / zatvaranja s odšetanim Pipom (`design/frames/`, snimljeno iz HomeScreen), P9 predaja, tri koraka Playa, tajming.
- `godot/` — export JSON, konstante, stablo čvorova, red prenosa.

## Stanja (§6.1)
1. Free, sezona u kojoj se igra — Pip na kartici, Play = ▶ Play → polje.
1b. Free, otključana ali se ne igra (`free_open`) — peach kapija, bez Pipa; Play = Back.
2. Free, zaključana — Play postaje „Back" + disk sezone u kojoj se igra; vraća karticu, ne pali run.
3. Sljedeća sezona — još fali: dva chipa (coin 320 / 500, ★3 14 / 20); može: jedno zlatno „Unlock · 500".
4. Premium — cijena ($4.99, zlatno), kupljena („Yours", mint), Ember „Coming soon" bez cijene.
5. Prelaz — kartica se otvara u svoju livadu, Seasons ga pušta unazad.
6. Polje — Amber #FFEBC7 i Moonlit #B8BDFF, Gift s roze tačkom, korpa +5 %, Play pali run.

## § Odlučeno
- **Jedna kartica + strelice, ne traka:** jedna velika livada po ekranu nosi mood bez ijedne rečenice, a strelice (120) su jasniji dodir od swipea koji mora ostati za hub.
- **Kartica je minijatura livade (tri trake iste svjetline):** tako prelaz nije efekt nego istina — kartica se samo raširi i već jeste polje te sezone.
- **Play je 520 × 180 pill u sredini, ne preko cijele širine:** centriran i odvojen od kartice čita se kao jedini glavni potez, a rupa lijevo/desno ostaje prazna zona za hub swipe.
- **Korak 1 mijenja natpis u „Back" + disk aktivne sezone:** igrač vidi kuda ga dugme vodi prije nego tapne; „Play" koji ne pokreće igru bi lagao.
- **Isto dugme putuje u donji red polja:** Play s biranja postaje FieldPlayButton, pa je treći korak (run) fizički isti prst na istom dugmetu.
- **Premium = zlatni tab + zlatni unutrašnji rub + zlatna cijena s draguljem:** zlato je jedini signal „kupuje se", bez objašnjenja.
- **Ember Fen: isprekidani chip „Coming soon", cvijeće na 50 %:** pokazuje da postoji, ali bez ikakvog dugmeta da nije kupovina.
- **Uslovi otključavanja kao dva chipa s brojem, mint kad je ispunjen:** ikone (coin, cvijet prethodne sezone + ★3) zamjenjuju rečenicu „Needs 500 coins + 20 flowers".
- **Cvijet koji fali = silueta u isprekidanom disku + ime:** jedini tekst na kartici osim imena sezone, kako brief dozvoljava.
- **Sezona u kojoj se igra = Pip na kartici + peach tačka u nizu:** Pip već znači „ti" na polju, pa ne treba natpis.
- **Tab se otvara na sezoni u kojoj se igra ako je u njemu, inače na prvoj:** nijedan tap na tab ne mijenja aktivnu sezonu.
- **Pozadina stranice = najsvjetlija nijansa mood boje:** sezona oboji cijeli ekran jednom ravnom bojom, bez gradijenta.
- **Swipe po kartici lista sezone, hub swipe živi na praznom pojasu y 1392–1633 lijevo/desno od Playa:** kontrole blokiraju hub swipe kako traži §2.
- **Tačke ispod kartice su samo indikator (nisu dugmad):** listanje je strelicama i swipeom; peach tačka = sezona u kojoj se igra.
- **Runda 2 — Play zadržava svoje mjere na biranju i tokom prelaza ih interpolira do FieldPlayButton-a:** biranje ostaje nepromijenjeno, a polje ostaje kao u igri (rub 3, tekst 64).
- **Runda 2 — trajanja 560 / 440 / 220 ms ostaju:** sve se sada kreće zajedno, pa nema razloga za duži prelaz.
- **Runda 2 — chrome stagger ukinut, flower stagger 24 → 12 ms:** stari stagger bi trajao ≈ 820 ms, duže od prelaza; ovako sve sjedne do u .92.
- **Runda 2 — otključana sezona u kojoj se ne igra (open) = peach „kapija" 150 px, bez teksta i bez Pipa:** tap na nju ili na karticu otvara njeno polje i ona postaje sezona u kojoj se igra.
- **Jedini loop je ripple na praznoj korpi (polje):** biranje nema loop, pa limit od jednog ostaje.

## § Prelaz (runda 2)
Jedan tween, napredak **u** 0 → 1. Geometrija koristi **e = ease in-out cubic(u)** — kartica, ime, Pip i Play na ISTOM e (P10). Blijeđenja koriste sirovi u.
- **Otvaranje** (Play na sezoni u kojoj se igra, tap na otključanu karticu ili gate): **560 ms**.
- **Zatvaranje** (SeasonsButton): isti tween unazad, **440 ms**; tab i kartica se prije starta postave na sezonu u kojoj se igra.
- **Promjena kartice** (strelice, swipe ≥ 60 px, Back, tab): 220 ms, x ±90 → 0, alpha .4 → 1. Snap nazad poslije kratkog drag-a 180 ms.

| Objekat | Svojstva | Kada |
|---|---|---|
| SeasonCard (trake = livada) | rect (24,172,1032,1160) → (0,0,1080,1633); radius 48 → 0; rub 4 → 0 (CardEdge); sjena 12 → 0; trake round(h·0.32) / round(h·0.68) | e 0 → 1 |
| SeasonName → SeasonLabel | top 244 → 36; size 80 → 56; letter-spacing −.015em → −.01em; centar x 540 | e |
| MeadowPip (s kartice) | (425,1027) 230 → (stopala − (95,190)) 190; sjena 45/8/140/30 → 35/6/120/26 | e |
| PlayButton = FieldPlayButton | (280,1413,520,180) → (324,1461,432,140); rub 4 → 3; sjena 10 α.30 → 8 α.28; tekst 76 → 64; trokut 30/48 → 26/42; gap 24 → 22; margin 8 → 6 | e |
| SeasonTabs, CardNav (strelice, tačke) | alpha 1 → 0, y 0 → −24 | u .02 – .30 |
| CardContent (roster, status, lokot, premium rub) | alpha 1 → 0 | u .02 – .40 |
| MeadowFlower i (13) | alpha 0 → 1 (100 ms), scale .9 → 1 (200 ms, ease out) | start u .20 + i·12 ms (zadnji završi u .814) |
| MeadowNote (prazna livada) | alpha 0 → 1 | u .30 – .60 |
| GiftChest, BasketButton, UpgradesButton, GrownChip | alpha 0 → 1, y −16 → 0 | u .60 – .92 |
| SeasonsButton / EndlessButton | alpha 0 → 1, x +254 / −254 → 0 (izlaze iza Playa) | u .60 – .92 |
| FieldClip | clip polja = rect + radius kartice, pa ništa ne izlazi van kartice | e |
| Meadow (trake polja) | ne crta se dok u < 1; na u = 1 preuzima iste piksele od kartice | u = 1 |

Pip: stopala na otvaranju = kuća (756,1404). Hodanje (walk 70 px/s, 2,2–5,5 s, pauza 0,7–2,5 s, zona stopala PIP_BASE_ZONE) počinje tek kad je u = 1. Na zatvaranju Pip kreće sa **trenutnih** stopala.

## § Šta se briše
- Stari 836 × 180 Play s diskom i podnaslovom → novi PlayButton 520 × 180.
- Chest slot desno od Playa (rupa) — nema ga.
- Natpisi „FREE · 1 OF 4", „6 flowers · 3 shown", tagline, „Open meadow" + „field · upgrades", „PREVIEW · PREMIUM", „Get … Garden", „no price yet · preview the flowers", „Needs 500 coins + 20 flowers".
- Jedna zajednička traka svih 8 sezona → dva taba.
- Dock tokena (1080 × 222 na y 1327) nije na biranju — **potvrditi** da tokeni žive na polju/runu; ako moraju ostati na Homeu, mjesto je pojas iznad tačaka (kartica se skrati na 1000).

## Otvoreno
- Cijena $4.99 je placeholder; Coral Tide je u mocku „kupljen" samo radi stanja 4b.
- ★3 chip koristi crtež srednjeg cvijeta prethodne sezone kao ikonu — zamijeniti ako postoji ★3 ikona.

## § Runda 2
| ID | Šta je promijenjeno |
|---|---|
| I1 | PrevSeason / NextSeason imaju `pointer-events:auto` i `stopPropagation`; CardNav je sestra kartice, klik nikad ne padne na nju. Provjereno: ‹ › na aktivnoj i zaključanoj mijenja sezonu, polje se ne otvara. |
| I2 | Swipe po kartici: pointer down/move/up, tap slop 12, prag **60 px**, kartica prati prst, na krajevima rubber 40 px (0,35 × dx), pa 220 ms swap ili 180 ms snap. Klik poslije drag-a se guta. |
| I3 | Jedan `busy()` guard (prelaz u toku, swap < 1, drag, zamrznut kadar) za tabove, strelice, karticu, kapiju, Unlock, cijenu, Play i Seasons. Tabovi su i `pointer-events:none` dok u > 0. |
| I4 | Pip samo na statusu `active`. Novi status `open` = peach kapija bez teksta; tap → polje te sezone, ona postaje aktivna. |
| I5 | Tačke su indikator, `pointer-events:none`, bez handlera (§ Odlučeno). |
| T1 | Ime i Pip više nemaju fade: jedan SeasonName i jedan MeadowPip putuju od kartice do polja. Roster blijedi 2–40 %, cvijeće dolazi od 20 % — preklopljeno. Nijedan kadar bez imena, Pipa i Playa (sve alfa 1). |
| T2 | Postoji samo PlayButton; na polju on JESTE FieldPlayButton (FieldScreen u `embedded` modu ne crta svoj). Rub, sjena, tekst, trokut, gap i margin se interpoliraju; na u = 1 = FieldPlayButton. |
| T3 | Trake kartice = `MEADOW_BANDS` 0.32 / 0.68, u px round(h·0.32) / round(h·0.68) → na 1633: 523 / 1110, isto kao Meadow. |
| T4 | FieldPage ne blijedi kao cjelina i nema traka dok u < 1 (`noBands`); sadržaj polja je u FieldClip-u = rect + radius kartice, pa nema duhova ivica. |
| T5 | SeasonLabel polja se ne crta u Homeu; ime nosi putujući SeasonName (P2). |
| T6 | `home_v3_export.json → animations.open / close` nabraja svaki objekat; `godot_map.anim_changes` = UiHomeField.ANIM staro → novo; iste vrijednosti u HTML-u (`T`, `W`) i `ui_home_v3.gd`. |

**Dopuna 2026-09-29** (nalaz iz prenosa u igru, § Implementacija briefa): `OpenTransition` je pokrivao cijelu stranicu bez `pointer-events:none`, pa tap na Free / Premium nije stizao do taba. Sada grupa ne prima dodir (Godot `MOUSE_FILTER_IGNORE` = `OPEN_TRANSITION_MOUSE_FILTER`); dodir primaju SeasonCard, PlayButton i FieldClip (samo na u = 1). FieldClip ostaje montiran i skriven na u = 0, pa je polje učitano već u prvom kadru otvaranja. Izgled i tajming se ne mijenjaju.

## § Samoprovjera
Provjereno 2026-09-29 u `HomeScreen.dc.html` (Chromium), poslije dopune gore. Svaki tap ide na `document.elementFromPoint` na koordinati dugmeta, pa pogađa ono što bi pogodio prst; swipe je niz pointer eventova. Vrijeme je virtualni sat (`performance.now` + `setTimeout`) koji se pomjera kadar po kadar, pa je svaki kadar tačan. Mjereno iz DOM-a, na živom toku (ne na zamrznutom `openT`).

> Ispravka: zip od 28. 9. je ovdje napisao „da" i za tab, ali tab je bio pokriven `OpenTransition`-om i tap nije stizao — ta provjera nije gađala pravu tačku. Sada gađa.

1. **da** — › na aktivnoj (Lantern → Amber), ‹ na zaključanoj (Amber → Lantern) i ‹ na aktivnoj (Lantern → Frost): sezona se promijeni, polje se ne otvori. Tabovi: Premium → Moonlit, Free → Lantern.
2. **da** — swipe 120 px ulijevo = sljedeća, 150 px udesno = prethodna; 150 px na kraju reda = rubber i nazad; 30 px = snap nazad, polje se ne otvori.
3. **da** — 90 ms u otvaranje: tab, ›, kartica, Play i ‹ ne rade ništa (otvori se Lantern, bez „Run starts"). 90 ms u zatvaranje: Seasons, Play, tab, ›, kartica ne rade ništa. 60 ms u promjenu kartice: druga strelica i tab ne rade ništa.
4. **da** — otvaranje i zatvaranje s Pipom koji je 4,5 s hodao, u = 0 … 1 po 0,05 + 0,99 (44 kadra): ime, Pip i Play alfa 1 u svakom; nikad dva Playa, dva imena ni dva Pipa. Roster i cvijeće zajedno na u .25–.35, nikad oboje prazno. Kartica, ime, Pip i Play na istom e (razlika ≤ 0,002).
5. **da** — 0,99 vs 1: lista svega što se crta (rect, boja, rub, sjena, slika, tekst; 0,5 px) je ista — otvaranje 124 stavke, zatvaranje 76, 0 razlika. Trake kartice = round(h·0,32 / 0,68) u svakom kadru; Meadow se ne crta dok je u < 1.
6. **da** — Pip samo na Lantern Meadow (aktivna): Country i Frost nose kapiju, Amber i sve četiri premium bez Pipa. Kapija na Frostu otvori Frost; poslije Seasons Pip je na Frostu, a Lantern dobije kapiju.
7. **da** — svih 118 brojeva iz `animations` postoji u HTML-u (`T` / `W` / keyframes) i u `ui_home_v3.gd` (dodani `NAME_*.cx`, `SWAP_ALPHA_FROM`, `ATTENTION_RING`).

## § Runda 3
| ID | Šta je promijenjeno |
|---|---|
| R1 | Kartica nosi svih šest cvjetova u svakom stanju: dva reda po tri. Red 1 = trojka iz runde 2 (oko 220 u sredini, strane 180 spuštene 26), red 2 = ostala tri (180, vrh 552). Zona 230–830, red 2 x 198–834, pa ništa ne ulazi u strelice ni u status red. |
| R2 | Zaključana besplatna sezona (locked i unlock): na svakom disku ravni sivi veo `#E3D9CC`, crtež se ne crta, pa se nijedan cvijet ne prepoznaje. Jedan katanac: RosterLock 120 na sredini bloka (locked); u unlock stanju katanac nosi dugme Unlock. Tap na Unlock diže veo disk po disk (300 ms, +40 ms po disku) — to je jedini trenutak kad se cvijeće sezone prvi put vidi. |

**Odlučeno (runda 3):**
- **Dva reda po tri, oko ostaje:** 600 px visine nosi dva reda s imenima; srednji disk u gornjem redu (220) je potpisni cvijet sezone — isti crtež je na disku dugmeta Back, pa oko povezuje karticu i Play.
- **Diskovi 220 / 180:** najveće što stane da red 2 ostane između strelica, a ime ispod reda 2 (i u dva reda) završi prije 830.
- **Jedan katanac na bloku, ne na svakom cvijetu:** sezona se otključava jednom; šest katanaca bi izgledalo kao šest odvojenih kupovina.
- **LockBadge gore desno otpada:** nigdje dva katanca. U unlock stanju katanac je samo na dugmetu Unlock.
- **Zaključano potpuno zamjenjuje „missing":** na zaključanoj kartici nema isprekidanih diskova ni imena; „missing" se crta samo na sezoni koja se može igrati.
- **Premium je drugačiji — bez vela i katanca:** premium se kupuje, pa kartica pokazuje šta se kupuje (šest cvjetova u boji); zlatni rub + cijena kažu „nije tvoje". Katanac znači „otključava se igrom", zlato „kupuje se". Ember (coming soon) ostaje na 50 %.
- **Ime cvijeta koji fali ostaje** ispod njegovog diska (38, gap 18).

## § Samoprovjera runde 3
Provjereno 2026-09-29 na svim instancama kartice u `Home Specs.dc.html` (13 kartica, svih 7 stanja), mjereno iz DOM-a.
1. **da** — šest `RosterFlower` vidljivo na svakoj kartici (aktivna, otključana, zaključana, unlock, premium na prodaju, kupljena, coming soon).
2. **da** — nijedan disk, crtež ni ime ne siječe PrevSeason / NextSeason; najniža tačka cvijeća je y 904 na stranici, status red počinje na 1002 (kartica 830).
3. **da** — locked: veo alfa 1 na svih šest, 0 crteža, jedan katanac.
4. **da** — otključana (Frost, Lantern, kupljena Coral): 0 vela, 0 katanaca, šest crteža. Tap na Unlock: poslije reveala 0 vela, šest crteža, kapija.
5. **da** — katanaca po kartici: locked 1 (blok), unlock 1 (dugme), sve ostalo 0.
6. **da** — kartica 1032 × 1160 na (24, 172) u svim stanjima; tabovi, Play, tačke, status red i prelaz nisu dirani.
7. **da** — novi tokeni (`ROSTER_*`, `ROSTER6`, `LOCK_VEIL`, `ROSTER_LOCK`, `REVEAL_*`) isti u `ui_home_v3.gd`, `home_v3_export.json` (`layout.SeasonRoster`, `LockVeil`, `RosterLock`) i HTML-u (`ROSTER6`, `VEIL`, `REVEAL`).

## § Ideje van zadatka
- Kratki „bloom" (scale 1 → 1.06 → 1, 300 ms) na disku cvijeta kad se na polju prvi put ubere taj cvijet — veza polje ↔ kartica.
- Kad se sljedeća sezona može otključati, peach tačka na njenoj tački u nizu — da igrač zna bez listanja.
