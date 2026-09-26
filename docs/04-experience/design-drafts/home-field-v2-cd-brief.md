---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, home, polje, sezona, claude-design, mockup]
povezano:
  - home-field-cd-brief
  - home-season-select-cd-brief
  - hub-chrome-v2-cd-brief
  - camp-v2-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Home polje sezone pass 2 — brief za Claude Design: livada preuzima cijelu stranicu i postaje pozadina, a chrome pluta preko nje: gore lijevo gift chest i korpa (zajednički dizajn), gore desno ulaz u magnet/loot nadogradnje, dolje tri manja dugmeta Seasons · Play · Endless."
---

# Home — polje sezone, pass 2 — Claude Design brief

> **Status: implementirano 2026-09-25** — paket `design_handoff_home_field_v2/` prenesen u igru; odstupanja su u [[#Implementacija (2026-09-25)|§ Implementacija]] na kraju.

> Polje je već dizajnirano 2026-09-22 ([[home-field-cd-brief|home-field-cd-brief]], paket `design_handoff_home_field/`). Ovo je **druga runda**: iste mehanike, isti sadržaj, ali obrnut odnos — livada prestaje biti prozor i postaje **stranica**, a sve kontrole plutaju preko nje.

**Polje sezone** je ekran na koji igrač uđe kad na Home stranici otvori sezonu: livada s izraslim cvijećem po kojoj šeta Pip, korpa u kojoj bira sjeme, dvije nadogradnje i dugme Play koje pokreće run.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§9) + prvi brief za kontekst | Šta se mijenja, šta ostaje fiksno, mjere i isporuka |
| **Ti** | §10 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §5, §11 | Današnje vrijednosti i mapa „CD sloj → Godot node" |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji (ne može listati foldere, zato su putanje u promptu ispisane do kraja).

## 1. Zašto druga runda

Ekran radi, ali je **naopako složen**. Stranica je 1080 × 1633 px, a livada — jedini dio zbog kojeg se na ovaj ekran ulazi — dobija **606 px, odnosno 37 %**. Ostalih 980 px (63 %) troše četiri naslagana bloka: red s „‹ Seasons" i imenom sezone (124), kartica korpe (180), dvije kartice nadogradnji (192 + 192) i red s Play dugmetom (180). Pip od 190 px hoda po traci visokoj nekoliko svojih visina, a cvijeće se gura u 13 mjesta koja su međusobno pretijesna.

Uz to: dugmad su prevelika. Play je 656 × 176, Endless 360 × 176, Seasons 300 × 124, a svaka kartica nadogradnje nosi dugme 300 × 154. Četiri velika dugmeta i dvije velike kartice za ekran čiji je posao da **pokažeš livadu i pritisneš Play**.

Gift chest je danas **sakriven** dok je polje otvoreno (`_refresh_chest_card()` ga gasi) — postoji samo na biranju sezone. Igrač koji uđe u polje ne vidi da ga poklon čeka.

## 2. Pravila koja ostaju FIKSNA (mehanika)

Brojevi se **ne diraju** — mijenja se samo kako izgledaju i gdje stoje.

| Pravilo | Vrijednost |
|---|---|
| Ulaz u polje | tap na aktivnu karticu sezone na Home biranju sezone; prelaz je **jedan rect tween** (kartica se razvuče u livadu, `bg_color` iz mood boje u ground) |
| Izlaz | dugme **Seasons** vraća na biranje sezone |
| Play | pokreće run u toj sezoni (60 s) |
| Endless | isti run bez finiša, fiksna težina; **vidljiv tek kad je tutorial gotov** |
| Korpa (loadout) | jedan slot; izabrano sjeme pada **+5 %** češće u runu (`LOADOUT_SPAWN_BONUS = 0.05`) |
| Korpa — zaključana | dok igrač ne spoji prvi cvijet („Merge your first flower in the Arena to unlock the basket.") |
| Izbor u korpi | samo tipovi **trenutne sezone**; nezaključani se mogu izabrati, zaključani se vide ali su neaktivni; postoji i „očisti izbor" |
| Magnet | 5 nivoa (0–4), radius 40 + 48 × nivo px |
| Loot Boost | 5 nivoa (0–4), množilac ×1.0 · ×1.25 · ×1.5 · ×1.75 · ×2.0 |
| Cijena nadogradnje | **2 × određeni ★1 cvijet** (ime se zna prije tapa); stanja `ready` · `blocked` („Need N") · `maxed` |
| Livada | **13 mjesta** s pragovima 1 / 5 / 10 izraslih cvjetova; prazno mjesto je mrlja zemlje, ne blijedi cvijet; čip „N / 13 grown" |
| Pip | 190 px, šeta / njuška / spava po prednjoj traci livade |
| Gift chest | dnevni poklon; roze tačka dok čeka; tap otvara reward prozor |
| Swipe | vodoravni swipe **po livadi** i dalje lista hub stranice; kontrole ga blokiraju |
| Boja livade | po sezoni, 8 vrijednosti (`#E6F2DB` … `#FFC79E`) |

Polje ne prodaje ništa za pravi novac i ne troši dijamante.

## 3. Šta se mijenja (zahtjevi igrača)

Tačke 1–6 su **obavezne**. Kako će izgledati poslije — tvoja odluka.

1. **Livada je stranica, ne prozor.** Uzima gotovo cijeli ekran i stoji ispod svega ostalog; Pip dobija prostor u kojem se stvarno šeta, a 13 mjesta prestaju biti nagurana. Tamna hub pozadina `#2E4733` na ovom ekranu praktično nestaje.
2. **Sve kontrole plutaju preko livade**, ne oduzimaju joj visinu.
3. **Dolje tri dugmeta, ovim redom: `Seasons` · `Play` · `Endless`.** Prave proporcije — Play je glavni, Seasons i Endless su sporedni, ali sva tri su **znatno manja nego danas** (Play 656 × 176, Endless 360 × 176, Seasons 300 × 124). Prije nego tutorial završi Endlessa nema — nacrtaj i taj red s dva dugmeta.
4. **Gore lijevo gift chest** — onaj s Home biranja sezone (danas 180 × 180, krem kartica, lavanda kutija, roze tačka kad čeka). U polju je danas sakriven; od sada se vidi.
5. **Ispod chesta korpa.** Chest i korpa stoje jedno ispod drugog i **moraju dijeliti dizajn** — isti oblik, ista veličina, isti jezik; dva mjesta u istoj koloni, ne dva različita widgeta. Tap na korpu otvara izbor sjemena: **tipovi trenutne sezone, jedan ispod drugog, svaki s portretom** (crtežom biljke). Izabrano sjeme daje **+5 % spawn rate** i to mora biti jasno.
6. **Gore desno ulaz u nadogradnje.** Osmisli način da se odatle otvori tab / panel s **Magnetom i Loot Boostom** — dvije kartice koje danas pojedu 400 px stranice. Ulaz mora nagovijestiti da unutra ima šta da se uradi (npr. kad je nadogradnja dostupna).

### 3.1 Današnji raspored (mjere za orijentaciju)

Stranica 1080 × 1633 od y = 143 (header 143, footer 144). Kolona 1032, padding 24 gore / 23 dolje, razmak između blokova 24.

```
┌ stranica 1080 × 1633 ───────────────────────────────────────┐
│ ┌ FieldTopRow 124 ────────────────────────────────────────┐ │
│ │ [‹ Seasons 300×124]  Frost Orchard 56 / tagline 38      │ │  ← 3. i 4.
│ └─────────────────────────────────────────────────────────┘ │
│ ┌ Livada (flex) 1032 × 606 ───────────── 37 % stranice ───┐ │
│ │ [N / 13 grown]                                          │ │  ← 1.
│ │   sky 0–56 %  ·  far 56–78 %  ·  near 78–100 %          │ │
│ │   13 mjesta (76–128 px)              Pip 190            │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌ BasketCard 1032 × 180 ──────────────────────────────────┐ │
│ │ [art 128] Meadow Clover ★☆☆ 52 / "Falls 5 % more…" 38   │ │  ← 5.
│ │                                        [Change 20 px r] │ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌ MagnetRow 1032 × 192 ───────────────────────────────────┐ │
│ │ Magnet 38 · Lv 1 / 4 · "Pull radius 88 → 136 px"        │ │  ← 6.
│ │ · "2 × Meadow Clover"                 [Upgrade 300×154] │ │
│ ├ LootBoostRow 1032 × 192 (isti raspored) ────────────────┤ │
│ └─────────────────────────────────────────────────────────┘ │
│ ┌ PlayRow 1032 × 180 ─────────────────────────────────────┐ │
│ │      [▶ Play 656×176]        [Endless 360×176]          │ │  ← 3.
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
   Gift chest 180 × 180 — u polju SAKRIVEN, vidi se samo na
   biranju sezone                                                ← 4.
```

Ostale današnje mjere: picker je bottom sheet 1080 × 1308, red pickera 148 px; dodir min. 120, tekst min. 38, broj min. 44.

## 4. MORA / SMIJE

### 4.1 MORA

- Sve iz §3 (tačke 1–6).
- **Sve iz §2 ostaje** — brojevi, nivoi, cijene, pragovi, +5 %, zaključana korpa, Endless tek poslije tutoriala.
- **Livada mora ostati čitljiva ispod chroma.** Odredi **keepout zone** za chest / korpu, ulaz u nadogradnje i donji red, pa reci koja od 13 mjesta i gdje Pip smiju stajati. Ako pomjeraš mjesta, daj novu tablicu procenata (danas `MEADOW_SPOTS`, 13 redova `[x %, y % od poda, veličina, indeks, prag]`).
- **Chest i korpa dijele dizajn** — isti oblik i mjera, razlikuju se sadržajem i stanjem.
- **Stanja korpe ostaju razlučiva**: zaključana · prazna (traži pažnju) · izabrano sjeme.
- **Stanja nadogradnje ostaju razlučiva**: dostupno · nema cvijeta (`Need N`) · maxirano; nivo 0–4 mora biti vidljiv.
- **Prelaz kartica → livada mora preživjeti.** Danas je to jedan rect tween na istom panelu (kartica 1032 × 1136 na Home biranju sezone → okvir livade). Ako livada postane cijela stranica, reci šta je nova meta tweena i kako chrome ulazi (danas fade sa stagger 0,06 s).
- **Swipe po livadi i dalje lista hub stranice**; kontrole ga blokiraju. Ništa što pluta ne smije pokriti toliko livade da swipe postane neizvodljiv.
- Dodir ≥ 120 px, tekst ≥ 38 px, brojevi ≥ 44 px. EN tekst.
- Stranica je **1080 × 1633 od y = 143** (hub chrome v2: header 143, footer 144).

### 4.2 SMIJEŠ (sloboda)

- Potpuno promijeniti oblik i mjesto svake kontrole — današnje kartice nisu šablon.
- Odlučiti gdje ide **ime sezone i tagline** (danas 56 / 38 px u gornjem redu) ili ih izbaciti ako ekran i bez njih govori u kojoj si sezoni — samo reci šta si odlučio i zašto.
- Predložiti da Seasons bude ikona umjesto riječi, ako red time dobije bolje proporcije.
- Odlučiti oblik ulaza u nadogradnje (dugme, jezičak, kartica koja se izvlači) i oblik samog panela (bottom sheet, popover, puna ploča).
- Promijeniti picker sjemena (danas bottom sheet 1308 px, redovi 148) dok ostaje lista s portretima, jedan tip ispod drugog.
- Izbaciti podnaslov s Endlessa („Hard · no finish line") ako mode ostane prepoznatljiv na drugi način.
- Promijeniti čip „N / 13 grown" ili ga pomjeriti.
- Dodati blage animacije (tween, 0,08–0,42 s).

## 5. Kontrast — najveći rizik ovog redizajna

Danas chrome stoji na **tamnoj** stranici `#2E4733`, pa su paneli krem na 13 % i sve radi. Kad livada postane pozadina, iste kontrole stoje na **svijetlim pastelnim** podlogama koje se mijenjaju po sezoni:

| Sezona | Pod livade | | Sezona | Pod livade |
|---|---|-|---|---|
| Country Bloom | `#E6F2DB` | | Moonlit Warren | `#B8BDFF` |
| Frost Orchard | `#D1E6FF` | | Coral Tide | `#FFE0D6` |
| Lantern Meadow | `#EBD6FF` | | Starfall Glade | `#DBCCFF` |
| Amber Canopy | `#FFEBC7` | | Ember Fen | `#FFC79E` |

Uz to livada ima **tri trake** — nebo (pod posvijetljen 30 %), daljina, prednji plan (pod potamnjen 7 %) — pa ista kontrola preko gornjeg i donjeg dijela ekrana stoji na dvije različite svjetline.

**Zahtjev:** jedno rješenje koje radi na svih 8 sezona i na sve tri trake, bez varijante po sezoni. Tekst i brojevi ≥ **4,5:1** prema svojoj neposrednoj podlozi; svaka kontrola ima rub ili sjenu koja je odvaja od livade. Pokaži najgori slučaj (`#FFEBC7` Amber i `#B8BDFF` Moonlit) u isporuci.

## 6. Paleta i tokeni

Postoji u `game/scripts/visual/ui_home_field.gd` i `ui_stage.gd` — koristi iste nazive, dodaj samo ono što je novo.

warm white `#FFF8F0` · active rim `#FFF6D6` · ink `#1A1A14` · outline `#2D3436` · coin gold `#FFD56B` (rub `#D6A82F`) · UI gold `#E8C44A` (rub `#BA9D3B`) · peach `#FFB88C` (rub `#E8A374`, Play) · lavanda `#D4A5FF` (rub `#AA84CC`, Endless) · mint `#A8E6CF` (rub `#7FC9AC`) · well `#22342A` (rub `#16211B`) · hub chrome v2 `#2A2233`.

Oblik: radius 20–32, rub 3–4 px, jedna meka sjena. Okvir cvijeta je zlatni ram + tamni well (korpa 128, picker 104). Font: default (kod simulira težinu), Nunito samo na Home biranju sezone.

## 7. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- Artboard **1080 × 1920**, stranica 1080 × 1633 od y = 143; sve mjere u px te baze — prenos 1:1.
- Paneli = ravna boja (+ alpha), radius, rub, **jedna** sjena. Bez blura, gradijenata na panelima, inner shadowa i blend modova.
- Animacije = tweenovi. **Najviše jedan loop na ekranu** — 29 pulsirajućih elemenata je na emulatoru palo na 10 fps (odluka iz prve runde).
- Cvijeće i Pipa crta igra (proceduralno + SVG) — ne treba novi art, samo mjere i mjesta.
- Livada ima `clip_contents`; sve što pluta je iznad nje, u istoj stranici.

## 8. Isporuka

### 8.1 Stanja koja moraju biti nacrtana

1. **Polje, sve otključano** — sjeme izabrano, chest čeka (roze tačka), nadogradnja dostupna, Endless vidljiv.
2. **Polje prije prvog mergea** — korpa zaključana + poruka „Merge your first flower in the Arena to unlock the basket.", **bez Endlessa** (red s dva dugmeta).
3. **Korpa prazna** — traži pažnju (jedan loop).
4. **Izbor sjemena otvoren** — tipovi trenutne sezone jedan ispod drugog s portretima, izabrani označen, zaključani vidljivi ali neaktivni, „očisti izbor".
5. **Nadogradnje otvorene** — Magnet i Loot Boost: dostupno, `Need N` i maxirano na istom ekranu; nivo 0–4.
6. **Livada prazna (0 / 13)** i **puna (13 / 13)** — dokaz da mjesta i keepout zone rade u oba slučaja.
7. **Dvije sezone za kontrast** — Amber Canopy `#FFEBC7` i Moonlit Warren `#B8BDFF`.
8. **Chest poslije preuzimanja** (bez tačke).

### 8.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_home_field_v2/
  README.md                   šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica
                              svaka) · § Keepout i mjesta (nova tablica 13 mjesta
                              ako ih mijenjaš) · § Šta se briše · § Ideje van zadatka
  design/
    FieldScreen.dc.html       cijeli ekran; prop `scene` bira stanje iz 8.1,
                              prop `season` bira boju livade
    Field Specs.dc.html       sva stanja na jednom kanvasu, anatomija chesta i
                              korpe, panel nadogradnji, donji red u obje varijante,
                              keepout zone preko livade, tabela animacija
    HubChromeScreen.dc.html   zadati header/footer v2 (kopija, ne mijenja se)
    support.js · icons/
  assets/                     samo novi fajlovi za export (ako ih bude)
  godot/
    home_field_v2_export.json ekran kao podaci, ista šema kao
                              design_handoff_hub_chrome_v2/godot/hub_chrome_v2_export.json:
                              meta · tokens · layout · components · scenes ·
                              animations · strings_en · assets · godot_map ·
                              smoke_tests · decisions
    ui_home_field.gd          samo izmijenjene/nove konstante i StyleBoxFlat
                              fabrike (isti nazivi kao u postojećem)
    field_tree.txt            node tree s veličinama
    README.md                 red prenosa u koracima + šta se briše
```

**Imena slojeva** (za mapiranje na Godot, §11): `FieldPage`, `Meadow`, `MeadowPip`, `GrownChip`, `SeasonLabel`, `GiftChest`, `BasketButton`, `BasketSheet`, `BasketRow`, `UpgradesButton`, `UpgradesSheet`, `MagnetCard`, `LootCard`, `BottomRow`, `SeasonsButton`, `PlayButton`, `EndlessButton`, `TutorialHint`.

## 9. Ne tražimo

- Home **biranje sezone** (kartica, dock, Play red) — to je gotov ekran, dira se samo ako prelaz u polje to traži.
- Hub header i footer — zadati su (chrome v2), samo kopija u mockupu.
- Ostale stranice huba (Shop, Journal, Camp, Arena), Run i loot ekran.
- Promjenu brojeva iz §2 (nivoi, cijene, +5 %, pragovi 1 / 5 / 10).
- Novi art cvijeća i Pipa — crta ih igra.
- Više varijanti za biranje — jedan dizajn.

## 10. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim drugu rundu redizajna jednog ekrana mobilne igre: HOME — POLJE SEZONE.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Polje si već radio; taj paket je u repou (design_handoff_home_field/). Sada ga
okrećemo naglavačke.

Tvoja referenca su dva fajla u repou (master), pročitaj oba po ovim tačnim
putanjama:
  docs/04-experience/design-drafts/home-field-v2-cd-brief.md   (ovaj zadatak)
  docs/04-experience/design-drafts/home-field-cd-brief.md      (prva runda)
Ako se ovaj prompt i fajl razlikuju, važi fajl. §11 je za kasniji prenos i
možeš ga preskočiti.

Ostali ekrani (isti svijet, drži se istog jezika):
  design_handoff_home_field/design/FieldScreen.dc.html   (polje, prva runda)
  design_handoff_home_v2/design/SeasonStage.dc.html      (Home biranje sezone)
  design_handoff_hub_chrome_v2/design/HubChromeScreen.dc.html  (header/footer, zadato)
  game/scripts/visual/ui_home_field.gd                   (tokeni polja u igri)
  game/scripts/visual/ui_stage.gd                        (tokeni biranja sezone)

TVOJ ZADATAK: livada mora postati ekran. Danas je stranica 1080 x 1633, a
livada — jedini razlog zbog kojeg se ovdje ulazi — dobija 606 px (37 %).
Ostalih 980 px troše četiri naslagana bloka: red "Seasons + ime sezone" (124),
kartica korpe (180), dvije kartice nadogradnji (192 + 192) i Play red (180).
Pip je 190 px i hoda po traci visokoj nekoliko svojih visina.

JEDAN DIZAJN: ne pravi smjerove ni varijante za biranje. Kad imaš dilemu,
odluči sam i napiši razlog u jednoj rečenici u README § Odlučeno. Ne čekaj
moju potvrdu.

ŠTA SE MORA PROMIJENITI (mjere u §3):
1. Livada je stranica, ne prozor — uzima gotovo cijeli ekran i stoji ispod
   svega. Pip dobija prostor u kojem se stvarno šeta, 13 mjesta prestaju biti
   nagurana.
2. Sve kontrole PLUTAJU preko livade, ne oduzimaju joj visinu.
3. Dolje tri dugmeta, ovim redom: Seasons, Play, Endless. Prave proporcije —
   Play je glavni, druga dva sporedna, ali sva tri ZNATNO manja nego danas
   (Play 656 x 176, Endless 360 x 176, Seasons 300 x 124 u zasebnom redu gore).
   Prije nego tutorial završi Endlessa nema — nacrtaj i red s dva dugmeta.
4. Gore lijevo gift chest — onaj s Home biranja sezone (180 x 180, krem
   kartica, lavanda kutija, roze tačka kad poklon čeka). U polju je danas
   sakriven; od sada se vidi.
5. Ispod chesta korpa. Chest i korpa stoje jedno ispod drugog i MORAJU
   dijeliti dizajn — isti oblik, ista mjera, isti jezik. Tap na korpu otvara
   izbor sjemena: tipovi TRENUTNE sezone, jedan ispod drugog, svaki s
   portretom (crtežom biljke). Izabrano sjeme daje +5 % spawn rate i to mora
   biti jasno.
6. Gore desno osmisli ulaz u nadogradnje — odatle se otvara tab/panel s
   Magnetom i Loot Boostom (dvije kartice koje danas pojedu 400 px). Ulaz
   mora nagovijestiti kad unutra ima šta da se uradi.

KONTRAST — najveći rizik:
Danas chrome stoji na tamnoj stranici #2E4733 i paneli su krem na 13 %. Kad
livada postane pozadina, iste kontrole stoje na SVIJETLIM pastelnim podlogama
koje se mijenjaju po sezoni: #E6F2DB, #D1E6FF, #EBD6FF, #FFEBC7, #B8BDFF,
#FFE0D6, #DBCCFF, #FFC79E. Livada uz to ima tri trake (nebo = pod +30 %
svjetline, daljina, prednji plan = pod −7 %), pa ista kontrola gore i dolje
stoji na dvije svjetline. Treba JEDNO rješenje za svih 8 sezona i sve tri
trake, bez varijante po sezoni. Tekst >= 4,5:1 prema svojoj podlozi, svaka
kontrola ima rub ili sjenu prema livadi. Pokaži najgori slučaj (#FFEBC7 i
#B8BDFF).

MORA OSTATI (brojevi se ne diraju):
- Korpa: jedan slot, +5 % spawn; zaključana dok igrač ne spoji prvi cvijet
  ("Merge your first flower in the Arena to unlock the basket."); bira se samo
  iz trenutne sezone; zaključani tipovi se vide ali su neaktivni; postoji
  "očisti izbor".
- Magnet: 5 nivoa (0–4), radius 40 + 48 x nivo px.
- Loot Boost: 5 nivoa (0–4), x1.0 / x1.25 / x1.5 / x1.75 / x2.0.
- Cijena nadogradnje: 2 x određeni ★1 cvijet (ime se zna prije tapa); stanja
  dostupno / "Need N" / maxirano.
- Livada: 13 mjesta s pragovima 1 / 5 / 10 izraslih cvjetova, prazno mjesto je
  mrlja zemlje (ne blijedi cvijet), čip "N / 13 grown", Pip 190 px.
- Endless: isti run bez finiša, fiksna težina, vidljiv tek poslije tutoriala.
- Gift chest: dnevni poklon, roze tačka dok čeka, tap otvara reward prozor.
- Vodoravni swipe PO LIVADI i dalje lista hub stranice; kontrole ga blokiraju.
- Prelaz kartica sezone -> livada je jedan rect tween na istom panelu; reci
  šta je nova meta tweena i kako chrome ulazi (danas fade, stagger 0,06 s).
- Dodir >= 120 px, tekst >= 38 px, brojevi >= 44 px. EN tekst.
- Stranica je 1080 x 1633 od y = 143 (hub chrome v2: header 143, footer 144).

KEEPOUT: odredi zone koje chrome pokriva i reci koja od 13 mjesta i gdje Pip
smiju stajati. Ako pomjeraš mjesta, daj novu tablicu (danas 13 redova
[x %, y % od poda livade, veličina px, indeks u rosteru, prag]).

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, sve u px te
baze (prenos 1:1). Paneli = ravna boja + alpha, radius, rub, JEDNA sjena.
Animacije = tween, najviše JEDAN loop na ekranu (29 pulsirajućih elemenata je
na emulatoru palo na 10 fps). Bez blura, gradijenata na panelima i 3D-a.
Cvijeće i Pipa crta igra — ne treba novi art.

ISPORUKA (§8): osam stanja iz §8.1 i paket TAČNO po strukturi iz §8.2 —
design_handoff_home_field_v2/ s README.md, design/ (FieldScreen.dc.html,
Field Specs.dc.html, HubChromeScreen.dc.html, support.js, icons/), assets/ i
godot/ (home_field_v2_export.json u istoj šemi kao hub_chrome_v2_export.json,
ui_home_field.gd, field_tree.txt, README.md). Na kraju mi daj ZIP ZA
PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: FieldPage, Meadow, MeadowPip, GrownChip, SeasonLabel,
GiftChest, BasketButton, BasketSheet, BasketRow, UpgradesButton,
UpgradesSheet, MagnetCard, LootCard, BottomRow, SeasonsButton, PlayButton,
EndlessButton, TutorialHint.

NE RADI: Home biranje sezone (gotov ekran), hub header/footer (zadati),
ostale stranice huba, Run i loot ekran, promjenu brojeva iz §2, novi art
cvijeća i Pipa. Ideje van zadatka navedi odvojeno na kraju README-a.
```

## 11. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot čvor / fajl |
|---|---|
| `FieldPage`, raspored | `game/scenes/main_menu.tscn` → `HomeColumn` (VBox, separation 24) + `main_menu.gd` `_apply_mode_layout()` / `sync_field_backdrop()`. Plutajući chrome znači da `HomeColumn` prestaje biti nosilac rasporeda u field modu — vjerovatno novi `FieldOverlay` sloj iznad `SeasonStage` |
| `Meadow`, `MeadowPip`, `GrownChip` | `scenes/ui/season_stage.tscn` → `%SeasonField` + `scripts/ui/season_field.gd`; mjesta u `UiHomeField.MEADOW_SPOTS`, `PIP_*` |
| `GiftChest` | `%DailyChestCard` (`scripts/ui/home_gift_card.gd`) — danas `visible = false` kad je polje otvoreno (`main_menu.gd` `_refresh_chest_card()`); sjedi u `HomeColumn/PlayRow`, dijeli ga biranje sezone. **Ne reparentati u runtime** (CAMP-04 zamka) — ili drugi čvor za polje, ili oba mjesta iz istog `PackedScene` |
| `BasketButton`, `BasketSheet` | `%BasketCard` + `%BasketVisual` + `%BasketButton`, picker `%BasketPickerOverlay` / `%PickerPanel` / `%PickerList` (`main_menu.gd` `_rebuild_picker_list()`, `HomeBasketPickerIcon`) |
| `UpgradesButton`, `UpgradesSheet`, `MagnetCard`, `LootCard` | `%FieldUpgradeStack` → `MagnetRow` / `LootBoostRow` + `main_menu.gd` `_refresh_field_upgrades()` / `_apply_upgrade_card()`; tekstovi u `UiHomeField.magnet_effect()` / `loot_effect()` / `cost_text()` / `upgrade_button_label()` |
| `BottomRow`, `SeasonsButton`, `PlayButton`, `EndlessButton` | `HomeColumn/PlayRow` (`%PlayButton`, `%EndlessPlayButton`) + `%SeasonsRowButton` iz `FieldTopRow`; Seasons treba preseliti u donji red, `FieldTopRow` vjerovatno otpada |
| `SeasonLabel` | `%SeasonNameChip` (`NameLabel` 56 / `Tagline` 38) — otpada ili seli |
| `TutorialHint` | `%TutorialHintPanel` / `%TutorialHint` |
| tokeni i stilovi | `scripts/visual/ui_home_field.gd` — `MEADOW`, `BASKET_H`, `UPGRADE_H`, `UPGRADE_BTN`, `PLAY_ROW_H`, `PLAY_W`, `ENDLESS_W`, `TOP_ROW_H`, `BACK_W`, `SHEET_H`, `PICKER_ROW_H` i fabrike `field_panel()`, `basket_card()`, `upgrade_card()`, `play_button()`, `endless_button()`, `picker_sheet()` |
| prelaz | `UiHomeField.tween_open_field()` / `tween_chrome_in()` / `tween_flowers_settle()`; `season_stage.gd` `open_season_field()` / `close_season_field()` |
| swipe | grupa `block_hub_swipe` — `main_menu.gd` `_sync_field_hub_swipe_chrome()`; livada je namjerno **ne** blokira |
| smoke testovi | `season_meadow_smoke`, `home_basket_picker_smoke`, `season_home_smoke` |

**Gotovo kad:**

- [ ] Livada zauzima gotovo cijelu stranicu; Pip i 13 mjesta imaju prostora
- [ ] Chest i korpa gore lijevo, jedan ispod drugog, istog dizajna
- [ ] Ulaz u nadogradnje gore desno; Magnet i Loot više ne troše 400 px stranice
- [ ] Donji red je `Seasons · Play · Endless`, znatno manji nego danas, i radi i bez Endlessa
- [ ] Sve kontrole čitljive na svih 8 boja livade (screenshot Amber i Moonlit)
- [ ] Swipe po livadi i dalje lista hub; kontrole ga blokiraju
- [ ] Prelaz s kartice sezone u polje i nazad bez skoka
- [ ] Suite prolazi (`season_meadow_smoke`, `home_basket_picker_smoke`, `season_home_smoke`) + GUT

## Implementacija (2026-09-25)

Paket: `design_handoff_home_field_v2/` (README § Odlučeno, 26 odluka). Preneseno 1:1 osim odstupanja niže.

| Fajl | Uloga |
|------|-------|
| `game/scripts/visual/ui_home_field.gd` | v2 tokeni: `MEADOW` = cijela stranica, `MEADOW_BANDS [0.32, 0.68]`, nova `MEADOW_SPOTS` (4 dubine), `PIP_BASE_ZONE`, `KEEPOUT`, `TILE 180`, rectovi Gifta / korpe / nadogradnji, donji red, oba sheeta; fabrike `sticker()` / `tile()` / `corner_dot()` / `attention_ring()` / `level_segment()` / `grown_chip()`; obrisani `meadow_frame()`, `field_panel()`, `back_button()`, `basket_card()`, `basket_button()`, `have_text()`, `PANEL_*`, `DISABLED_*`, `SUB_ON_DARK`, `TOP_ROW_H`, `BACK_W`, `BASKET_H`, `UPGRADE_H`, `PLAY_ROW_H`, `PLAY_W`, `ENDLESS_W`, `MEADOW_INNER` |
| `game/scripts/ui/season_field.gd` | Livada bez okvira; mjesta iz nove tablice, crtaju se nazad → naprijed; Pip u pojasu `PIP_BASE_ZONE`; broj izraslih ide overlayu signalom `grown_changed` |
| `game/scenes/main_menu.tscn` | Novi `FieldOverlay` (SeasonLabel, GrownChip, GiftChest, BasketButton, UpgradesButton, TutorialHint, BottomRow) i `UpgradesOverlay`; obrisani `FieldTopRow`, `HomeTopStack`/`BasketCard`, stalni `FieldUpgradeStack` |
| `game/scripts/ui/field_basket_button.gd` | **Novo** — plocica korpe 180 × 180 u tri stanja (lokot · sjeme + prsten paznje · portret + „+5 %"), shake kad je zaključana |
| `game/scripts/ui/field_upgrades_button.gd` | **Novo** — plocica nadogradnji: ︽ znak, dvije trake nivoa 4 × (28 × 14), zlatna tacka kad se moze kupiti |
| `game/scripts/ui/main_menu.gd` | Kolona u polju pokriva cijelu stranicu (`FIELD_COLUMN_OFFSETS` 0), overlay preuzima raspored; novi `_open_upgrades_sheet()` / `_close_upgrades_sheet()` / `_refresh_upgrades_button()` / `_refresh_grown_chip()` / `_style_field_bottom_row()`; Gift se vise ne gasi u polju |
| `game/scripts/ui/season_stage.gd` | Prelaz: kartica (radius 36, rub 8) → cijela stranica (radius 0, rub 0) |
| `game/scripts/ui/home_gift_card.gd` · `home_basket_visual.gd` | `drop` (tvrda sjena) za instancu u polju; omjeri portreta 60 / sjemena 56 u wellu 70 |
| `game/scripts/dev/home_field_overlay_smoke.gd` | **Novo** — livada 1080 × 1633, rectovi kontrola, block_hub_swipe, keepout za 13 mjesta i Pipa, oba sheeta, tacno jedan loop |

**Odstupanja od handoffa (svjesna):**

1. **`FieldOverlay` je dijete `MainMenu`-a, ne `SeasonStage`-a.** `SeasonStage` je instancirana scena, a `MainMenu` **jeste** stranica — koordinate iz paketa važe 1:1 i bez diranja instance.
2. **Nema zajedničkog `SheetLayer`-a.** `BasketPickerOverlay` već živi u korijenu `MainMenu`-a i radi; `UpgradesOverlay` je dodan pored njega po istom obrascu umjesto da se oba sele pod `SeasonStage`.
3. **Play u polju je zaseban čvor `FieldPlayButton`.** Paket kaže da `%PlayButton` seli u overlay, ali to je **isti čvor** koji nosi Play na biranju sezone (836 × 180 u `HomeColumn/PlayRow`) — selidba bi ostavila taj ekran bez Play dugmeta. Rješenje je isto ono koje je paket izabrao za Gift (odluka 6): druga instanca, jedan zajednički handler.
4. **`MeadowCount` čvor je obrisan iz livade.** Paket stavlja `GrownChip` u overlay ali ostavlja brojač u livadi; livada sada emituje `grown_changed`, a čip crta overlay.
5. **`home_basket_visual.gd` je zadržan** i koristi se unutar plocice (omjeri prilagodeni wellu 70) umjesto novog crtanja — tako T3 putanja koju smoke čuva ostaje ista.
6. **Endless nosi „∞ Endless" kao tekst**, ne crtani dvostruki prsten — znak postoji u Nunitu, a crtanje bi tražilo još jednu skriptu za dugme koje je inače obično.
7. **`icon_seed_light.svg` je već bio obrisan** u chrome v2 (paket ga navodi u § Šta se briše).
8. **`ui_attention.gd` je ostao bez korisnika** — jedini loop je sada `tween_attention()` unutar `FieldBasketButton`.

## Odluke

| Datum | Odluka |
|---|---|
| 2026-09-25 | Livada postaje **stranica**, chrome pluta preko nje. Poništava odluku iz prve runde („livada je prozor, ne pozadina") — razlog te odluke bio je da ekran ostane isti hub kao Camp i Arena, ali cijena je bila 37 % stranice za sadržaj zbog kojeg se ulazi. |
| 2026-09-25 | Gift chest se **vidi u polju** (danas je tamo sakriven), gore lijevo, iznad korpe i istog dizajna. |
| 2026-09-25 | Donji red je `Seasons · Play · Endless`; „‹ Seasons" napušta gornji red i `FieldTopRow` vjerovatno otpada. |
| 2026-09-25 | Magnet i Loot Boost sele iza **jednog ulaza gore desno** umjesto dvije stalne kartice. |

## Otvorena pitanja (nakon CD-a)

- [ ] Gdje završava ime sezone i tagline (ili otpadaju)
- [ ] Nova tablica 13 mjesta i keepout zone — mijenjaju li se procenti
- [ ] Oblik ulaza u nadogradnje i panela (sheet / popover / ploča)
- [ ] Ostaje li podnaslov na Endlessu
- [ ] Kako se chest dijeli između biranja sezone i polja bez runtime reparenta

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[home-field-cd-brief|home-field-cd-brief]] — prva runda, današnje stanje i odluke
- [[home-season-select-cd-brief|home-season-select-cd-brief]] — ekran iz kojeg se ulazi
- [[hub-chrome-v2-cd-brief|hub-chrome-v2-cd-brief]] — header/footer i visina stranice (1633)
- [[../art-direction|art-direction]] — paleta, stil
- [[../pristupacnost|pristupačnost]] — dodir 44 pt ≈ 120 px, font minimumi
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci
