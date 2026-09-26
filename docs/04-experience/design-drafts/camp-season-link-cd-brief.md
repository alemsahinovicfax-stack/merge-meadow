---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, camp, sezona, claude-design, mockup]
povezano:
  - camp-v2-cd-brief
  - camp-cd-brief
  - hub-header-footer-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Mali redizajn samo kartice sljedeće zaključane sezone u Campu: igrač mora vidjeti ikonu i puno ime ★3 cvijeta koje skuplja da je otključa."
---

# Camp — kartica sljedeće sezone — Claude Design brief

> Camp je već u igri ([[camp-v2-cd-brief|pass 2]], paket `design_handoff_camp_v2/`). Ovo **nije** nova runda cijelog ekrana. Mijenja se **samo kartica** koja vodi na sljedeću zaključanu besplatnu sezonu. Sve ispod nje (tabovi, kartice sjemena i cvijeća, Trade, prazno stanje) ostaje kako jeste.

Igrač na toj kartici vidi ime sezone, koliko mu coina fali i `0 / 20`. Ne vidi **koje** cvijeće treba skupiti. Danas tamo stoji ikona od 56 px bez imena.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§8) | Šta se mijenja, šta ostaje fiksno, mjere i isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §4, §10 | Današnje vrijednosti i mapa „CD sloj → Godot" |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji (ne može listati foldere, zato su putanje u promptu ispisane do kraja).

## 1. Zašto

Kartica je portal do sljedeće besplatne sezone. Da je otključa, igrač troši **500 coina i 20 komada jednog ★3 cvijeta** — i to cvijeta **prethodne** sezone, ne cvijeta one koju otključava.

Primjer: kartica kaže **Frost Orchard**, a cvijet koji treba je **Harvest Pumpkin** (★3 iz Country Bloom). Za **Lantern Meadow** treba **Crystal Peony**. Igrač to danas ne može pročitati. Traka piše samo `0 / 20`, a crtež je 46 px u okviru od 56 px, bez imena.

## 2. Pravila koja ostaju FIKSNA

Brojevi se **ne diraju**. Mijenja se samo kako se na kartici vidi koji cvijet fali.

| Pravilo | Vrijednost |
|---|---|
| Šta kartica otvara | sljedeća **zaključana besplatna** sezona. Kad su sve otključane, kartice nema. |
| Cijena | **500 coina + 20** komada jednog ★3 cvijeta |
| Koji cvijet | ★3 **prethodne** besplatne sezone. Frost Orchard → Harvest Pumpkin. Lantern Meadow → Crystal Peony. Amber Canopy → Midnight Lotus. |
| Brojač | `imam / 20`, skraćeno na 20. Isti broj kao danas (`0 / 20`, `12 / 20`, `20 / 20`). |
| Coini | `imam / 500` i traka, kao danas. |
| Unlock | ostaje **jedna riječ** „Unlock". Lokot dok fali. Troši odmah tek kad je spremno, pa kratki burst, pa Home. |
| Tap na karticu (van Unlocka) | vodi na Home, **ništa ne troši**. Bez natpisa „Details" i bez „Next free season". |
| Ime cvijeta | puni `display_name` iz kataloga. Najduže današnje ★3 ime je **Harvest Pumpkin**. Mora stati cijelo. |
| Art cvijeta | postojeći crtež igre. **Nema novog cvijeta.** |

## 3. Šta danas stoji na kartici

Stranica huba između headera (143) i footera (144) je **1080 × 1633**. Padding 24. Kartica je **1032 × 276**, odmah ispod paddinga. Ispod nje, razmak **20 px**, pa sekcija Seeds/Flowers visine **1289**. Zbir: 276 + 20 + 1289 = 1585 (sadržaj). Ako kartica naraste, tih 20 px ostaje, a sekcija se skrati za istu razliku. Stranica se ne preliva.

```
┌ SeasonLinkCard 1032 × 276  (tint sezone, rub 3 px) ─────────┐
│ SeasonHead 120                                               │
│ Frost Orchard          56          ┌ Unlock 300 × 120 ┐      │
│                                    └ lokot 40, 1 riječ┘      │
│ SeasonProgress 86                                            │
│ 🪙 48   260 / 500  48          │  [cvijet 56]  0 / 20  48    │
│ ▬▬▬ traka 18                   │  ▬▬▬ traka 18               │
│                                ↑                             │
│                    ime cvijeta NE POSTOJI                   │
└──────────────────────────────────────────────────────────────┘
        ↕ 20 px (fiksno)
┌ StashSection 1289 — NE DIRAJ ────────────────────────────────┐
```

Tint kartice prati sezonu koju otključava: Frost `#C5D5E8`, Lantern `#C9B8E0`, Amber `#E8C48A` (rub ~20 % tamniji). Tekst na tintu je `#1A1A14`.

Okvir cvijeta danas: **56 × 56**, crtež **46 px**, zlatni zaobljeni kvadrat (`#FFD56B`, rub `#D6A82F`) — isti jezik kao cvijet u karticama ispod, samo premali da se prepozna, i bez imena.

## 4. Šta se mijenja

Obavezno je ovo. Raspored unutar kartice je tvoja odluka.

1. **Ime cvijeta mora biti na kartici**, cijelo, uz brojač `N / 20`. Igrač čita „Harvest Pumpkin", ne „neko cvijeće".
2. **Ikona tog istog cvijeta mora biti dovoljno velika da se prepozna.** Danas 46 px u okviru 56 nije. Povećaj je. I dalje je zlatni zaobljeni kvadrat (cvijet, ne sjeme). Ne mora do ruba okvira; mora se vidjeti koji je cvijet.
3. **Ime i ikona su isti cvijet** — onaj čiji je brojač `N / 20`. Ne cvijet sezone koja se otključava i ne mješavina više vrsta.
4. **Coini, traka coina, traka cvijeća, ime sezone i Unlock ostaju.** Igrač i dalje vidi oba uvjeta.

Kartica smije biti viša od 276 ako ime i veća ikona ne staju. Napiši novu visinu. Razmak do sekcije ostaje 20 px, a sekcija se skrati. Ne diraj tabove, grid, Trade ni prazno stanje.

## 5. MORA / SMIJE

### 5.1 MORA

- Ikona **i** puno ime cvijeta, na istoj kartici, u sva tri stanja (fali / spremno / trenutak otključavanja).
- Brojač `N / 20` i coini `N / 500` ostaju čitljivi. 20 i 500 se ne mijenjaju.
- Unlock ostaje jedna riječ, 300 × 120, lokot dok fali, zlatno dugme kad je spremno.
- Tap na karticu i dalje samo vodi na Home. Bez „Details", bez „Next free season", bez rečenice uputstva („collect 20 of these" i slično).
- Tekst ≥ 34 px. Ime cvijeta ≥ 34 px i **ne smije** u ellipsis za „Harvest Pumpkin".
- EN tekst. Postojeća imena, ne nova.
- Header (143) i footer (144) se ne mijenjaju. Ostatak Campa se ne crta iznova.
- Radi i za drugo ime (Crystal Peony, Midnight Lotus) — ime je podatak, ne natpis urezan u Frost.

### 5.2 SMIJEŠ

- Preraspodijeliti donji dio kartice (ikona, ime, brojač, traka) da ime stane.
- Podići visinu kartice koliko treba, uz pravilo iz §3 (sekcija se skrati, razmak 20 ostaje).
- Staviti ime ispod ili pored ikone. Brojač smije stajati uz ime.
- Malo povećati i coin ikonu ako time red postane mirniji. Broj coina ostaje.
- Zadržati današnji raspored glave (ime sezone lijevo, Unlock desno) ako radi.

## 6. Tokeni

Isto što Camp već koristi (`game/scripts/visual/ui_camp.gd` i `design_handoff_camp_v2/`):

- tinta kartice: Frost `#C5D5E8`, Lantern `#C9B8E0`, Amber `#E8C48A`;
- tekst na tintu `#1A1A14`, traka prazna bijela @ ~35 %, traka coina `#FFD56B`, traka cvijeta `#7DCEA0`;
- Unlock spreman: zlato `UiPalette.GOLD`, rub `#BA9D3B`; dok fali: prigušeno, s lokotom;
- okvir cvijeta: `#FFD56B`, rub `#D6A82F`;
- jedna meka sjena, bez blura na tekstu.

Crtež cvijeta u mockupu uzmi iz postojećeg SVG-a (npr. `game/assets/sprites/flowers/` ili `design_handoff_plant_frame/`). U igri se slika mijenja po sezoni — ti zadaješ **kutiju**, ne novi crtež.

## 7. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

Artboard 1080 × 1920, sve mjere u px te baze (prenos je 1:1). Paneli = ravna boja + alpha, radius, border, jedna sjena. Bez blura, gradijenata na panelima, teških čestica i 3D-a. Burst pri otključavanju ostaje jedan tween (danas 0,42 s), ne novi efekat.

## 8. Isporuka

### 8.1 Stanja

1. **Fali** — Frost Orchard, 260 / 500 coina, Harvest Pumpkin **0 / 20**, Unlock s lokotom.
2. **Spremno** — isti cvijet **20 / 20** i 500 / 500, Unlock aktivan.
3. **Drugi cvijet** — Lantern Meadow, Crystal Peony (npr. 4 / 20), da se vidi da ime i ikona nisu uvijek bundeva.
4. **Trenutak otključavanja** — burst, Unlock neaktivan, ime cvijeta i dalje tu.

Kartica neka bude nacrtana **u Camp stranici** (header, kartica, vrh sekcije ispod), da se vidi razmak od 20 px. Sekciju ispod ne precrtavaj — dovoljan je postojeći vrh (tabovi Seeds | Flowers).

### 8.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_camp_season_link/
  README.md
        šta otvoriti · § Odlučeno (1 rečenica po odluci, uključujući novu visinu kartice)
        · § Šta se ne dira · § Ideje van zadatka
  design/
    SeasonLink.dc.html       kartica u Camp stranici; prop `scene` bira stanje iz 8.1
    SeasonLink Specs.dc.html sva 4 stanja + mjere djece
    support.js
  godot/
    season_link_export.json  meta · tokens (samo novo/promijenjeno) · layout
                             (rect kartice i djece) · components · scenes
                             · strings_en · godot_map · decisions
    season_link_tree.txt     node tree s veličinama
    README.md                red prenosa + nova visina SEASON_H ako se mijenja
```

**Imena slojeva:** `SeasonLinkCard`, `SeasonTitle`, `UnlockButton`, `CoinProgress`, `FlowerProgress`, `FlowerArt`, `FlowerName`, `FlowerCount`, `FlowerBar`.

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim mali redizajn JEDNE kartice u mobilnoj igri Merge Meadow (casual F2P,
portrait, flat pastel, cozy livada). Ne diraj ostatak ekrana.

Kartica je u Campu, na vrhu. Vodi na sljedeću zaključanu besplatnu sezonu.
Igrač na njoj vidi ime sezone, coine i "0 / 20", ali NE vidi koje cvijeće
treba skupiti. To je cijeli zadatak: na karticu dodaj ikonu I puno ime tog
cvijeta.

Tvoja referenca je jedan fajl u repou (master). Pročitaj ga po ovoj tačnoj
putanji:
  docs/04-experience/design-drafts/camp-season-link-cd-brief.md
Ako se ovaj prompt i fajl razlikuju, važi fajl. §10 je za kasniji prenos i
možeš ga preskočiti.

Kontekst (isti svijet, ne precrtavaj ove ekrane):
  design_handoff_camp_v2/design/CampScreen.dc.html
  design_handoff_hub_chrome/HubScreen.dc.html
  game/scripts/visual/ui_camp.gd
  game/scripts/camp/season_link_card.gd

TVOJ ZADATAK: igrač mora na kartici pročitati ime cvijeta i prepoznati ga
na ikoni. Primjer: kartica "Frost Orchard" traži 20 komada "Harvest Pumpkin"
(★3 prethodne sezone, ne cvijet Frost-a). Za "Lantern Meadow" to je
"Crystal Peony". Danas je ikona 56 px (crtež 46) i nema imena — zato niko
ne zna šta skuplja.

JEDAN DIZAJN: ne pravi smjerove, varijante ni alternative. Kad imaš dilemu,
odluči sam i napiši razlog u jednoj rečenici u README § Odlučeno. Ne čekaj
moju potvrdu.

MORA:
- Puno ime cvijeta (npr. Harvest Pumpkin) i ikona TOG ISTOG cvijeta, uz
  brojač N / 20. Ime cijelo, bez ellipsisa, tekst >= 34 px.
- Coini N / 500, obje trake, ime sezone i dugme Unlock ostaju.
- Unlock je i dalje samo riječ "Unlock", 300 x 120, lokot dok fali.
- Tap na karticu i dalje samo vodi na Home. Ne vraćaj tekst "Details" ni
  "Next free season". Ne dodaji rečenicu uputstva.
- Cvijet je ★3 prethodne sezone. 20 i 500 se ne mijenjaju. Nema novog arta
  cvijeta — ti zadaješ kutiju, igra crta postojeći SVG.
- Ako kartica mora biti viša od današnjih 276 px, napiši novu visinu.
  Razmak do sekcije ispod ostaje 20 px, sekcija se skrati za istu razliku.
  Stranica se ne preliva. Tabove, grid, Trade i prazno stanje ne diraj.

MORA OSTATI VIDLJIVO U ČETIRI STANJA:
1. Fali — Frost Orchard, 260/500, Harvest Pumpkin 0/20, Unlock s lokotom.
2. Spremno — 20/20 i 500/500, Unlock aktivan.
3. Drugi cvijet — Lantern Meadow, Crystal Peony (npr. 4/20).
4. Trenutak otključavanja — burst, ime i ikona i dalje tu.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, sve u px
baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna sjena.
Bez blura, gradijenata na panelima i 3D-a.

ISPORUKA (§8): četiri stanja i paket TAČNO po strukturi iz §8.2 —
design_handoff_camp_season_link/ s README.md, design/ (SeasonLink.dc.html,
SeasonLink Specs.dc.html, support.js) i godot/ (season_link_export.json,
season_link_tree.txt, README.md). Na kraju mi daj ZIP ZA PREUZIMANJE u
chatu s cijelim folderom.

IMENA SLOJEVA: SeasonLinkCard, SeasonTitle, UnlockButton, CoinProgress,
FlowerProgress, FlowerArt, FlowerName, FlowerCount, FlowerBar.

NE RADI: ostatak Campa, Trade, tabove, prazno stanje, Home, Run, Arenu,
Shop, Journal, novi art cvijeta, promjenu cijene 500 + 20. Ideje van
zadatka navedi odvojeno na kraju README-a.
```

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot |
|---|---|
| `SeasonLinkCard` | `scenes/camp/camp_scene.tscn` → `SeasonLinkCard` + `scripts/camp/season_link_card.gd` |
| Visina | `UiCamp.SEASON_H` (danas 276). Ako naraste, `SECTION_H` = 1585 − nova visina − 20. `SECTION_GAP` ostaje 20. |
| `SeasonTitle`, `UnlockButton` | `%SeasonLinkTitle`, `%SeasonLinkUnlock` |
| `CoinProgress` | `CoinProgress` / `%SeasonLinkCoinIcon`, `%SeasonLinkCoins`, `%SeasonLinkCoinsBar` |
| `FlowerArt` | `%SeasonLinkFlower` (`CampArtFrame`). Danas `SEASON_ART_FRAME` 56, `SEASON_ART` 46. Cvijet je `GameState.star3_type_id_for_season(previous_free)`. |
| `FlowerName` | **novi label** — danas ne postoji (`SeasonLinkFlowerName` je obrisan u pass 2). Tekst: `GameState.get_seed_display_name(flower_type)`. |
| `FlowerCount`, `FlowerBar` | `%SeasonLinkT3`, `%SeasonLinkT3Bar` |
| Tap / Unlock | `navigate_to_lock()` → Home bez trošenja; Unlock i dalje `unlock_free` + burst |

Smoke koji prenos mora zadržati zelenim: `camp_season_link_smoke`, `camp_layout_smoke`, `camp_section_fixed_smoke`.

## Povezano

- [[camp-v2-cd-brief|camp-v2-cd-brief]] — kartica kakva je danas (276 px, bez imena cvijeta)
- [[camp-cd-brief|camp-cd-brief]] — prva runda, pravilo 500 + 20
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
