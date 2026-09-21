---
type: dizajn
status: draft
milestone: "—"
tags: [dizajn, ui, home, sezone, polje, claude-design, mockup]
povezano:
  - home-season-select-cd-brief
  - hub-header-footer-cd-brief
  - camp-cd-brief
  - merge-arena-cd-brief
  - seeds-flowers-cd-brief
  - spec-vertical-slice
  - design-pillars
  - art-direction
  - pristupacnost
ai_sažetak: "Home — polje sezone (SeasonField: livada s cvijećem, Pip, korpa, Magnet / Loot Boost, Play / Play Endless, nazad na sezone): pravila iz koda koja ostaju fiksna, današnji raspored i mjere, šta ne štima, sloboda za CD (jedan dizajn, bez varijanti), format paketa za direktan prenos u Godot, gotov prompt i mapa node-ova."
---

# Home — polje sezone — Claude Design brief i referenca

> **Status: priprema dizajna, kod se ne mijenja.** Brief pokriva samo **polje sezone** (SeasonField), tj. Home dok je polje otvoreno. Biranje sezone (kolona kartica, smjer 1a Season Trail) je redizajnirano i u igri od 2026-09-21 ([[home-season-select-cd-brief]]). Polje treba da mu se vizuelno pridruži.
>
> **Razlika od ranijih briefova:** CD ovdje dobija **slobodu da unaprijedi dizajn** i isporučuje **jedan dizajn**, bez smjerova i varijanti za biranje. Paket odmah dolazi u formatu za prenos u Godot (§7).

Polje sezone je „dom“ aktivne sezone. Igrač tu vidi livadu te sezone i Pipa. Tu i sprema run: bira sjeme za korpu, nadograđuje Magnet i Loot Boost i pokreće Play ili Play Endless.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl po putanji iz repoa (§1–§8) | pravila, mjere, problemi, sloboda, format isporuke |
| **Ti** | §9 | gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §3, §10 | tačne današnje vrijednosti i mapa „CD sloj → Godot node“ |

**Prije slanja CD-u:** CD čita repo s `master` grane, i to samo po tačnoj putanji. Novi Home (kolona kartica) i paket `design_handoff_home/` moraju biti **commitani i pushani**. Inače CD vidi stari Home s dvije trake.

---

## 1. Kontekst (za CD)

- **Merge Meadow** je casual F2P merge/runner hibrid za mobitel, **portrait**. Stil je flat 2D cartoon, pastelan, s mekim outlineom, bez pixel-arta i 3D-a ([[../art-direction|art-direction]]). Mood: *cozy meadow*.
- **8 sezona** (4 besplatne linearno, 4 premium). Svaka ima 6 sjemenki/cvjetova: 3 × ★1, 2 × ★2 i 1 × ★3. Detalji su u [[home-season-select-cd-brief]] §1–§2.
- Home je **3. i početna stranica** meta-huba (Shop · Journal · **Home** · Camp · Arena). Header (143 px) i footer (180 px) su zadati.
- Home ima dva režima:
  - **biranje sezone:** gotovo, ne dira se;
  - **polje sezone:** ovaj brief.
- **Pillar 2 — Fair F2P:** core je uvijek besplatan. U polju se ništa ne kupuje pravim novcem.
- **Pillar 3 — napredak se vidi i osjeća:** polje je dobro mjesto da igrač vidi šta je u sezoni postigao.

---

## 2. Kako polje radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled, raspored i prelaze**, ne ekonomiju. Izvor: `game/scripts/ui/season_field.gd`, `season_field_pip.gd`, `season_field_flower.gd`, `main_menu.gd` (field režim), `season_stage.gd` (`open_season_field` / `close_season_field`), `autoload/game_state.gd`.

### 2.1 Ulaz i izlaz

- **Ulaz:** na biranju sezone, tap na otvorenu karticu **aktivne** sezone ili na njeno dugme `Open meadow ↗`. Polje zato uvijek pripada **aktivnoj** sezoni.
- **Izlaz:**
  - dugme `Seasons` (danas vidljivo tek nakon tutoriala);
  - sistemsko Android „back“ / Esc.
  - Oba vraćaju na kolonu kartica.
- Header i footer ostaju vidljivi. Na polju se Daily gift i „N / 4 free seasons“ ne vide, jer pripadaju biranju sezone.
- **Hub swipe** (lijevo/desno mijenja tab) mora raditi i u polju. Danas samo dugmad i kartice blokiraju swipe, da se tap ne pretvori u swipe; livada ga propušta.
- Polje ostaje otvoreno kad igrač ode na drugi tab i vrati se. Zatvara se kad Camp šalje igrača na Home preko kartice sljedeće sezone.

### 2.2 Play i Play Endless

- `Play` pokreće **kampanjski run** u aktivnoj sezoni, isto kao Play na biranju sezone.
- `Play Endless` pokreće **Endless run** u toj sezoni. Težina je uvijek `Hard`: enum ima i `Easy` / `Normal`, ali ih UI danas ne nudi. Vidljiv je tek nakon tutoriala.
- Ovo je **jedino mjesto u igri** odakle se pokreće Endless.

### 2.3 Korpa (Basket / loadout)

- Jedan slot: igrač bira **jednu vrstu sjemena iz ove sezone**. U runu ta vrsta dobija **+5 % šanse** za pojavu (`LOADOUT_SPAWN_BONUS`).
- Mogu se birati samo **otključane** vrste. Zaključane se vide sive i ne reaguju.
- Stanja kartice:
  - `Tap to choose`: prazna, pulsira (`UiAttention`);
  - odabrana: ime + ★ + `(+5% spawn)`;
  - `Clear basket`: vraća u prazno.
- **Prije kraja tutoriala** korpa je zaključana (`Unlock after first merge`, siva). Tap pokaže hint `Merge your first flower to unlock the basket.`
- Picker je danas overlay: zatamnjenje, panel 560 px, naslov `Choose basket seed`, 6 redova (ikona + ime + ★), `Clear basket` i `Close`.
- Ako se aktivna sezona promijeni, a odabrano sjeme nije iz nje, korpa se sama isprazni.

### 2.4 Magnet i Loot Boost (nadogradnje)

| | Magnet | Loot Boost |
|---|---|---|
| Šta radi u runu | radijus skupljanja: `40 + 48 × nivo` px | množi loot runa: ×1.0 · ×1.25 · ×1.5 · ×1.75 · ×2.0 |
| Nivoi | 0 → 4 | 0 → 4 |
| Cijena po nivou | **2 cvijeta iste vrste** | **2 cvijeta iste vrste** |

- Nadogradnje su **globalne**: važe u svim sezonama, a kupuju se samo ovdje.
- **Koji cvijet se troši, bira igra sama:** najniži rarity, pa vrsta koje ima najviše (`pick_upgrade_flower_type`). Igrač to danas ne vidi.
- Dugme je `Upgrade`. Kad nema dovoljno cvijeća, onemogućeno je. Na max nivou piše `Maxed`.
- Cvijeće se dobija merge-om u Areni (`garden_crystal_stash`).

### 2.5 Livada

- Pozadina je ravna boja po sezoni (tabela ispod). Pokriva cijelu stranicu od headera do footera.
- Na livadi je **13 ukrasnih cvjetova** (76 px): ★3 crteži sjemenki te sezone, redom, na fiksnim slotovima. Raspored izbjegava dugmad i kartice (`meadow_safe_rect`). Cvjetovi **ne zavise od onoga što igrač ima** i ne reaguju na tap.
- **Pip** (maskota, 72 px) sam šeta: hoda 50 %, njuši cvijet 25 % i spava 25 % vremena. Ne reaguje na tap.

| Sezona | Livada danas | Mood (kartica) |
|--------|--------------|----------------|
| Country Bloom | `#E6F2DB` | `#A8E6CF` |
| Frost Orchard | `#D1E6FF` | `#C5D5E8` |
| Lantern Meadow | `#EBD6FF` | `#C9B8E0` |
| Amber Canopy | `#FFEBC7` | `#E8C48A` |
| Moonlit Warren | `#B8BDFF` | `#3D3A6B` |
| Coral Tide Garden | `#FFE0D6` | `#E8A090` |
| Starfall Glade | `#DBCCFF` | `#6B5B95` |
| Ember Fen | `#FFC79E` | `#C45C26` |

### 2.6 Tekstovi danas (EN)

`Seasons` · `Play` · `Play Endless` · `Basket` · `Tap to choose` · `Unlock after first merge` · `(+5% spawn)` · `Choose basket seed` · `Clear basket` · `Close` · `Magnet` · `Loot Boost` · `Upgrade` · `Maxed` · hint: `Merge your first flower to unlock the basket.`

Imena sezona i sjemenki su u `game/data/seasons/seasons.json`. Primjer Frost Orcharda: Frost Snowdrop ★ · Ice Crocus ★ · Silver Aconite ★ · Winter Camellia ★★ · Hoarfrost Rose ★★ · Crystal Peony ★★★. Najduže ime: `Dusk Firefly Grass` (18 znakova).

**CD smije predložiti nove kratke tekstove** (tabela *novo / gdje*).

---

## 3. Trenutni raspored

Scene: `game/scenes/main_menu.tscn` (field chrome) → `HomeColumn/SeasonStage/SeasonField` (`game/scenes/ui/season_stage.tscn`)

```
 1080 px
┌──────────────────────────────────────────────┐
│ [● 12,450] [♣ 340] [◆ 12]              [⚙]  │ HEADER 143 — zadato
╞══════════════════════════════════════════════╡ ─┐ y 0 (stranica)
│[🧺 Basket     ]  [ Frost Orchard ]   Magnet  │  │ korpa 336×104 @ (24,24)
│[  Tap to choose]    280×48, 22px   [Upgrade] │  │ čip imena (ne reaguje)
│                                   Loot Boost │  │ nadogradnje 196 px, 16 px
│                                    [Upgrade] │  │ dugmad 44 px, 18 px
│                                              │  │ ≈ 200 px prazno
│  ✿        ✿        ✿        ✿                │  │ y 380 — livada 984 × ≈1085
│       ✿        ✿        ✿                    │  │ 13 cvjetova × 76 px
│  ✿        ✿    🐾     ✿        ✿             │  │ Pip 72 px šeta
│       ✿                 ✿                    │  │ boja = ista kao pozadina
│                                              │  │
│ [ Seasons ]   [ ▶ Play ]   [ Play Endless ]  │  │ 3 × 320×96, razmak 12
╞══════════════════════════════════════════════╡ ─┘
│ Shop   Journal   [Home]   Camp   Arena       │ FOOTER 180 — zadato
└──────────────────────────────────────────────┘
```

| Element | Danas |
|---------|-------|
| Pozadina | cijela stranica 1080 × 1597 u boji livade (§2.5); livada nema ivicu |
| Korpa | 336 × 104 @ (24, 24), naslov 26 px, caption 18 px, ikona 72 px; zaključana = 78 % sivo |
| Čip imena sezone | 280 × 48, centriran, y 28, 22 px, `subtle` — izgleda kao dugme, a nije |
| Magnet / Loot Boost | desno gore, 196 px široko; naslov 16 px, dugme 44 px s fontom 18 px, `subtle` |
| Livada | 984 × ≈ 1085 (bočno 48, od y 380 do reda dugmadi) |
| Cvijet / Pip | 76 px / 72 px, ukrasni |
| Red dugmadi | `Seasons` (subtle, 28 px) · `Play` (peach, 40 px + ikona) · `Play Endless` (lavanda, 28 px + ikona): sva tri 320 × 96 |
| Picker korpe | zatamnjenje; panel 560 × do 720, naslov 28 px; redovi 128 px, font 22 px; `Clear basket` / `Close` 56 px |

### 3.1 Šta danas ne štima (analiza iz koda, nisu odluke)

1. **Polje izgleda kao druga igra.** Svijetla pastelna pozadina preko cijelog ekrana odudara od tamne zelene `#2E4733` na kojoj su biranje sezone, Camp i Arena. Prelaz s kartice u polje je skok boje, bez veze s karticom.
2. **Livada ne govori ništa.** 13 istih ukrasnih ★3 cvjetova se ne mijenja s napretkom, pa novi igrač i igrač sa svim cvijećem vide isto polje (Pillar 3).
3. **Nadogradnje su nejasne.** Piše samo `Upgrade`, bez nivoa, efekta i cijene. Igra sama bira koji cvijet troši, a igrač to ne vidi prije tapa. Kad je dugme sivo, ne piše zašto.
4. **Tekst i dodir su premali:** 16 px naslovi, dugmad od 44 px s fontom 18, caption korpe 18 px, čip 22 px. Minimum je 38 px za tekst i 120 px za dodir.
5. **Korpa se ne razumije.** Da `+5% spawn` znači „ovo sjeme češće pada u runu“ nigdje ne piše. Picker izgleda kao debug meni.
6. **Hijerarhija dugmadi:** `Seasons` (nazad), `Play` i `Play Endless` su iste veličine. Nazad izgleda kao glavna akcija, a Endless ne objašnjava šta je.
7. **Prije tutoriala nema vidljivog puta nazad:** `Seasons` je skriven, pa izlaz postoji samo preko sistemskog „back“.
8. **Čip s imenom sezone** izgleda kao dugme, a ne reaguje.
9. **Mrtav prostor:** ≈ 200 px između gornjih kartica i livade. Livada nema ivicu, pa se ne zna gdje počinje.
10. **Pip je sitan** (72 px na 1080 px širine) i ne reaguje. Maskota je u polju samo dekor.
11. **Stil ne prati novi Home:** kartice, dugmad (`UiClickButton` varijante) i fontovi su iz starog UI-a, a ne iz Home/Camp tokena (`CampButton`, `UiHome`).

---

## 4. Zahtjevi

**Unaprijedi dizajn.** Trenutni izgled je samo polazna tačka. Ti si dizajner: odluči sam kako polje treba izgledati da bude lijepo, jasno i da igrač voli ući u njega. Radi **jedan dizajn**, bez smjerova i varijanti za biranje. Kad imaš dilemu, odluči i napiši razlog u jednoj rečenici (README § Odlučeno).

### 4.1 MORA

- **Pravila iz §2 ostaju:**
  - korpa: 1 slot, samo otključana sjemena ove sezone, +5 %;
  - Magnet i Loot Boost: 4 nivoa, 2 cvijeta po nivou, globalni;
  - `Play` pokreće run, `Play Endless` pokreće Endless u aktivnoj sezoni;
  - ulaz u polje s kartice aktivne sezone.
- **Uvijek vidljiv put nazad** na kolonu sezona, i prije tutoriala.
- **Nadogradnja pokazuje:** nivo (npr. `Lv 1 / 4`), šta radi sad i na sljedećem nivou, cijenu (`2 ×` i **koji cvijet** će se potrošiti), zašto je nedostupna i max stanje.
- **Korpa objašnjava svoj efekat** jednim kratkim tekstom.
- **Stanja** (§7 P1): poslije tutoriala / prije tutoriala, korpa prazna / odabrana / picker, nadogradnje dostupne / nema cvijeća / max, svijetla i tamna sezona.
- **Rarity čitljiv i bez boje** (zvjezdice, oblik), kao u Campu, Journalu i Areni.
- **Dodir i tekst:** sve interaktivno ≥ **120 px**; tekst ≥ **38 px**, brojevi ≥ **44 px**.
- **Header i footer su zadati.** Polje živi u **1080 × 1597 px** između njih.
- **Hub swipe radi:** bez horizontalnih gesti u polju.
- **Radi za svih 8 sezona**, uključujući tamne mood boje (Moonlit Warren, Starfall Glade, Ember Fen) i duga imena (`Coral Tide Garden`, `Dusk Firefly Grass`).
- **Cvijeće i Pipa CD ne crta:**
  - cvijeće: placeholderi `design_handoff_home/flowers/ph_*.svg`;
  - Pip: `game/assets/sprites/pip_idle.svg`.
  - Veličinu i mjesto smiješ mijenjati.
- **Pillar 2:** u polju nema kupovine pravim novcem ni reklama, a nadogradnje su samo za cvijeće iz igre.

### 4.2 SMIJE (sloboda)

- **Sve u rasporedu:** gdje su korpa, nadogradnje, dugmad i ime sezone; da li je livada puni ekran, „prozor“ s ivicom ili scena koja izraste iz kartice; kako izgleda prelaz iz kolone u polje i nazad.
- **Livada kao napredak:** npr. na livadi raste ono što je igrač skupio u toj sezoni, a prazna mjesta čekaju. Podaci postoje: broj cvjetova po vrsti (`garden_crystal_stash`) i otkriveni cvjetovi (Journal). U README-u to označi kao **prijedlog za prikaz**, ne kao novu mehaniku.
- **Pip:** veći, na istaknutom mjestu, s malom reakcijom na tap (animacija ili oblačić s porukom). Novu reakciju označi kao prijedlog.
- **Picker korpe:** overlay, sheet odozdo ili red direktno u polju.
- **Nova boja livade** po sezoni, izvedena iz mood boje (daj formulu, kao `derived_fills` u Home paketu).
- **Novi kratki tekstovi** (EN).

Ideje koje traže novu mehaniku (npr. izbor težine za Endless, nove nadogradnje) navedi **odvojeno na kraju README-a** i ne crtaj ih u glavnom dizajnu.

---

## 5. Paleta i tokeni

**Koristi tokene iz Home paketa:** `design_handoff_home/godot/home_export.json` (`tokens`, `season_colors`, `derived_fills`) i `game/scripts/visual/ui_home.gd`. Nove boje dodaj samo kao svjetliju ili tamniju varijantu postojećih i jasno ih označi.

Ključne vrijednosti:

- stranica `#2E4733` · rub aktivnog `#FFF6D6` · ink `#1A1A14`;
- peach `#FFB88C` (Play) · lavanda `#D4A5FF` · mint `#A8E6CF`;
- coin gold `#FFD56B` · UI gold `#E8C44A`;
- rarity ★1 `#B8D4F0` / ★2 `#E0C4FF` / ★3 `#FFE8B8`;
- well `#22342A` · chrome `#1A241E`.

Mood boje sezona i današnje boje livade su u §2.5.

**Komponente koje već postoje u igri** (koristi ih gdje pašu, da prenos bude brz):

- `CampButton`: dugme s naslovom i podnaslovom;
- `CampArtFrame`: zlatni okvir + tamni well za cvijet;
- Home kartica sezone (`HomeSeasonCard`);
- traka napretka (`HomeBar`);
- čip ★☆☆.

Vidi `design_handoff_home/SeasonCard.dc.html` i `design_handoff_camp/CampChip.dc.html`.

**Font:** igra koristi default sans sa simuliranim težinama. Mockup smije koristiti Nunito, ali računaj da je naš font nešto širi, pa ostavi mjesta za duži tekst.

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- **Lako:** `StyleBoxFlat` (ravna boja + alpha, radius, border, jedna sjena) · `VBox`/`HBox`/`ScrollContainer` · tween (pozicija, skala, alpha, boja, visina) · ravni oblici (`draw_*`) · postojeći SVG/PNG.
- **Izbjegavati:** blur i glow shadere, gradijente na panelima, teške čestice, maske i izreze (osim kao PNG), 3D, animaciju koja svaki frame crta cijelu livadu.
  - Pip i do ~14 cvjetova smiju se pomjerati tweenom.
  - Stalno pulsiranje mnogo elemenata je skupo: na emulatoru je 29 pulsirajućih chipova palo na 10 fps.
- **Layout:** artboard **1080 × 1920**, sve mjere u px te baze (prenos 1:1). Polje je **1080 × 1597** između headera (143) i footera (180). 1 dp ≈ 2,75 px, pa je dodir 44 pt ≈ **120 px**, a tekst 14 pt ≈ **38 px**.

---

## 7. Isporuka — jedan dizajn, paket spreman za Godot

**Jedan dizajn.** Bez smjerova, alternativa i prikaza za poređenje. Pravi samo onoliko artboarda koliko treba da se vide stanja.

### 7.1 Stanja (P1, obavezno)

1. **Glavni ekran** 1080 × 1920 s headerom i footerom, sredina igre:
   - polje **Frost Orcharda** (aktivna), poslije tutoriala;
   - korpa prazna;
   - Magnet `Lv 1 / 4`, Loot Boost `Lv 0 / 4`;
   - dovoljno cvijeća za nadogradnju (npr. 5 × Meadow Clover, 2 × Barn Tulip).
2. **Korpa odabrana** (Winter Camellia ★★) + **picker** otvoren: 6 vrsta, od toga 2 zaključane.
3. **Nadogradnje:**
   - dostupna;
   - nema cvijeća (i zašto);
   - max (`Lv 4 / 4`);
   - trenutak nadogradnje (2 kadra).
4. **Novi igrač, prije tutoriala:** Country Bloom, korpa zaključana, bez Endlessa, put nazad vidljiv.
5. **Tamna sezona:** Moonlit Warren (premium, kupljena i aktivna), kao provjera kontrasta.
6. **Sheet livade za svih 8 sezona** (mali prikaz, boje i čitljivost).
7. **Prelaz** kolona sezona → polje → nazad (2–3 kadra).
8. **Tabela animacija** (šta, trajanje, easing) i **lista asseta**.

### 7.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom, kao za Camp. Ako zip ne može, zalijepi u chat sadržaj JSON-a, `.gd` i oba README-a.

```
design_handoff_home_field/
  README.md                 šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica svaka)
                            · § Šta se briše · § Ideje van zadatka
  HomeField.dc.html         cijeli ekran; prop `scene` bira stanje iz 7.1
  HomeField Specs.dc.html   sva stanja na jednom kanvasu + spec komponenti
                            + tabela animacija + asset lista
  HubScreen.dc.html         zadati header/footer (kopija, ne mijenja se)
  support.js
  icons/ · flowers/         samo fajlovi koje dizajn stvarno učitava
  godot/
    field_export.json       ista šema kao design_handoff_home/godot/home_export.json:
                            meta · tokens (samo novi/promijenjeni) · derived_fills ·
                            layout (rect svakog bloka) · components (child mjere + stanja) ·
                            scenes (stanja s tačnim brojevima) · animations · strings_en ·
                            assets · godot_map (sloj → node iz §10) · smoke_tests ·
                            decisions (umjesto open_decisions)
    ui_home_field.gd        StyleBoxFlat fabrike i konstante; koristi postojeće
                            UiHome / UiCamp nazive, dodaje samo nove
    README.md               red prenosa u koracima + šta se briše
```

**Imena slojeva** (za mapiranje na Godot, §10):

- **stranica i livada:** `FieldPage`, `FieldBackdrop`, `Meadow`, `MeadowFlower`, `MeadowPip`;
- **gornji dio:** `FieldTitle`, `BackButton`;
- **korpa:** `BasketCard`, `BasketPicker`, `PickerRow`;
- **nadogradnje:** `UpgradeCard` (Magnet / LootBoost), `UpgradeCost`, `UpgradeLevel`;
- **dugmad i ostalo:** `PlayButton`, `EndlessButton`, `TutorialHint`, `FieldTransition`.

## 8. Ne tražimo

- **Biranje sezone** (kolona kartica): gotovo, ne mijenja se. Crta se samo prelaz u polje i nazad.
- Promjenu brojeva: +5 %, 4 nivoa, 2 cvijeta, radijus i množioci. Ni novu mehaniku, osim kao odvojenu ideju.
- Header, footer, run ekran i Arenu.
- Crtanje cvijeća i lika Pipa: koriste se postojeći asseti ili placeholderi.

---

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** novi Home (vidi §0).

```
Radim redizajn jednog ekrana mobilne igre: HOME — POLJE SEZONE.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Tvoja referenca je fajl u repou (master):
  docs/04-experience/design-drafts/home-field-cd-brief.md
Pročitaj ga cijelog: pravila (§2), današnji raspored (§3), šta ne štima
(§3.1), šta mora a šta smiješ (§4), tokeni (§5), tehnika (§6) i isporuka
(§7). §10 je za kasniji prenos i možeš ga preskočiti. Ako se ovaj prompt
i fajl razlikuju, važi fajl.

Polje mora izgledati kao ista igra kao ekrani koje si već radio:
  design_handoff_home/HomeScreen.dc.html        (biranje sezone — odavde se ulazi)
  design_handoff_home/SeasonCard.dc.html        (kartica sezone)
  design_handoff_home/godot/home_export.json    (tokeni — koristi njih)
  design_handoff_camp/CampScreen.dc.html        (Camp, isti vizuelni jezik)
  design_handoff_hub_chrome/HubScreen.dc.html   (header + footer, zadato)
Cvijeće: design_handoff_home/flowers/ph_*.svg · Pip: game/assets/sprites/pip_idle.svg

TVOJ ZADATAK: unaprijedi dizajn polja. Ti si dizajner — imaš punu slobodu
u rasporedu, kompoziciji livade, mjestu Pipa, prelazu iz kartice u polje i
izgledu korpe i nadogradnji. Pravila i brojevi su fiksni.

JEDAN DIZAJN: ne pravi smjerove, varijante ni alternative za biranje.
Kad imaš dilemu, odluči sam i napiši razlog u jednoj rečenici u README
§ Odlučeno. Ne čekaj moju potvrdu.

ŠTA JE POLJE (detalji u §2):
- "Dom" aktivne sezone: livada u boji sezone, 13 ukrasnih cvjetova, Pip šeta.
- Ulaz: tap na karticu aktivne sezone na biranju. Izlaz: dugme nazad na
  sezone (+ sistemski back).
- Korpa: 1 vrsta sjemena ove sezone → +5 % šanse da pada u runu. Samo
  otključane; prije tutoriala zaključana.
- Magnet (radijus skupljanja) i Loot Boost (×1.0 → ×2.0): po 4 nivoa,
  svaki nivo košta 2 cvijeta iste vrste (igra sama bira koji — pokaži
  igraču koji). Globalni, kupuju se samo ovdje.
- Play = run u aktivnoj sezoni. Play Endless = Endless (Hard), poslije
  tutoriala.

GLAVNI PROBLEMI DANAS (§3.1):
1. Svijetla pastelna pozadina preko cijelog ekrana — izgleda kao druga igra
   u odnosu na tamni #2E4733 Home/Camp.
2. Livada je ista za novog i starog igrača — ne pokazuje napredak.
3. Nadogradnje pišu samo "Upgrade": bez nivoa, efekta, cijene i razloga
   zašto su sive.
4. Tekst 16–22 px, dugmad 44 px.
5. Seasons / Play / Play Endless iste veličine; prije tutoriala nema
   vidljivog puta nazad.

MORA:
- Pravila i brojevi iz §2 ostaju.
- Uvijek vidljiv put nazad (i prije tutoriala).
- Nadogradnja: nivo, šta radi sad → sljedeće, cijena i koji cvijet, zašto
  nedostupna, max.
- Rarity čitljiv i bez boje. Sve interaktivno ≥ 120 px; tekst ≥ 38 px,
  brojevi ≥ 44 px; EN tekst.
- Header (143) i footer (180) zadati; polje 1080 × 1597 između njih.
  Bez horizontalnih gesti (hub se lista swipeom lijevo/desno).
- Radi za svih 8 sezona, i tamne (Moonlit Warren #3D3A6B).
- Cvijeće i Pipa ne crtaš — koristiš postojeće.
- Fair F2P: bez kupovine pravim novcem i reklama u polju.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 × 1920, sve u px
te baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna
sjena. Animacije = tween. Bez blura, gradijenata na panelima, teških čestica,
3D-a i stalnog pulsiranja mnogo elemenata.

ISPORUKA (§7): stanja iz §7.1 i paket TAČNO po strukturi iz §7.2 —
design_handoff_home_field/ s README.md, HomeField.dc.html,
HomeField Specs.dc.html, HubScreen.dc.html, support.js, icons/, flowers/ i
godot/ (field_export.json u istoj šemi kao home_export.json, ui_home_field.gd,
README.md). Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: FieldPage, FieldBackdrop, Meadow, MeadowFlower, MeadowPip,
FieldTitle, BackButton, BasketCard, BasketPicker, PickerRow, UpgradeCard,
UpgradeCost, UpgradeLevel, PlayButton, EndlessButton, TutorialHint,
FieldTransition.

NE RADI: biranje sezone (samo prelaz), promjenu brojeva i novu mehaniku,
header/footer, run, crtanje cvijeća i Pipa. Ideje van zadatka navedi
odvojeno na kraju README-a.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `FieldPage` / `FieldBackdrop` | `main_menu.tscn` `FieldBackdrop` + `main_menu.gd` `sync_field_backdrop()`, `_apply_mode_layout(true)` | `FIELD_COLUMN_OFFSETS` (48, 380, −48, −24), `FIELD_COLUMN_SEPARATION` 12; `TopRow` skriven u polju |
| `Meadow` / `MeadowFlower` / `MeadowPip` | `season_stage.tscn` → `%SeasonField` (`season_field.gd`): `MeadowGround`, cvjetovi `season_field_flower.gd` (76 px, `CampPlantDraw`), `MeadowPip` (`season_field_pip.gd`, `PipDraw`) | `meadow_safe_rect()` izbjegava chrome iz `_chrome_controls()` (Daily, korpa, čip, PlayRow, nadogradnje); boja `SeasonTheme.home_field_tint()`; Pip FSM Walk/Sniff/Sleep |
| `FieldTitle` | `%SeasonNameChip` (`UiClickButton`, `MOUSE_FILTER_IGNORE`) | `_refresh_season_name_chip()` |
| `BackButton` | `%SeasonsRowButton` → `_on_seasons_row_pressed()` → `season_stage.close_season_field()` | vidljiv samo `tutorial_complete`; `SeasonField/SeasonsButton` je mrtav (uvijek skriven); back/Esc: `season_stage._try_close_field_on_back()` |
| `BasketCard` | `HomeTopStack/BasketCard` (+ `home_basket_visual.gd`) | `_refresh_basket_card()`, `_basket_attention` (`UiAttention.Kind.BASKET`), `_sync_loadout_to_open_season()` |
| `BasketPicker` / `PickerRow` | `BasketPickerOverlay` → `PickerPanel` / `PickerList` / `PickerClearButton` / `PickerCloseButton` | redovi se grade u `_rebuild_picker_list()` (`home_basket_picker_icon.gd`, `PICKER_ROW_MIN_HEIGHT` 128); `GameState.set_loadout` / `clear_loadout` / `is_seed_type_unlocked`; `SeedCatalog.types_for_season` |
| `UpgradeCard` / `UpgradeCost` / `UpgradeLevel` | `%FieldUpgradeStack` → `MagnetRow` / `LootBoostRow` (`MagnetTitle`, `MagnetButton`, …) | `_refresh_field_upgrades()`; `GameState.magnet_level` / `multiplier_level`, `MAGNET_MAX_LEVEL`, `MULTIPLIER_MAX_LEVEL`, `UPGRADE_FLOWER_COST`, `try_upgrade_magnet` / `try_upgrade_multiplier`, `can_spend_flowers_for_upgrade`, `pick_upgrade_flower_type` (koji cvijet), `get_magnet_radius_for_level`, `get_loot_multiplier_for_level` |
| `PlayButton` | `%PlayButton` (`CampButton`) u field layoutu: `_apply_play_layout(true)`, `FIELD_PLAY_SIZE` 320 × 96 | `_on_play_pressed()` — isti tok kao na biranju |
| `EndlessButton` | `%EndlessPlayButton` → `_on_endless_play_pressed()` (`EndlessDifficulty.HARD`) | vidljiv samo `tutorial_complete` |
| `TutorialHint` | `TutorialHintPanel` / `%TutorialHint` | tekst za zaključanu korpu u `_on_basket_pressed()` |
| hub swipe | `_sync_field_hub_swipe_chrome()` → grupa `block_hub_swipe` | u polju grupa drži chrome; livada propušta swipe |
| `FieldTransition` | `season_stage.open_season_field()` / `close_season_field()` → `_sync_season_field()` + `sync_field_backdrop()` | danas bez animacije (odmah) |

**Smoke testovi koje prenos mora proći ili svjesno ažurirati:**

- `season_meadow_smoke`: glavni za polje. Pokriva cvijeće 12–14 u sigurnoj zoni, Pipa, chrome, Play i Endless, hub swipe i Daily koji je skriven u polju.
- `season_home_smoke`: otvaranje i zatvaranje polja s kartice.
- `home_basket_picker_smoke`.
- `camp_season_link_smoke`: Camp zatvara polje kad šalje na Home.

Svi čuvaju pravi save (`CampSmokeUtil.backup_save` / `restore_save`) ili ga moraju dobiti.

**Poznati problemi nađeni pri pisanju briefa:**

1. **`SeasonField/SeasonsButton` je mrtav:** uvijek skriven, a `_is_shell_child` ga i dalje štiti. Kandidat za brisanje pri prenosu.
2. **Prije tutoriala nema dugmeta nazad** (§3.1 t. 7). U igri je izlaz samo preko sistemskog „back“.
3. **Koji cvijet nadogradnja troši, igrač ne vidi** (`pick_upgrade_flower_type`). Za prikaz cijene treba javni poziv koji vraća tip prije potrošnje; funkcija već postoji i samo je treba koristiti u UI-u.
4. **Endless težina:** enum ima `Easy` / `Normal` / `Hard`, save pamti `endless_difficulty`, a UI uvijek šalje `Hard`.

**Gotovo kad (implementacija):**

- [ ] Polje stane između headera i footera; sve interaktivno ≥ 120 px, tekst ≥ 38 px
- [ ] Put nazad je vidljiv i prije tutoriala
- [ ] Nadogradnje pokazuju nivo, efekat, cijenu i koji cvijet se troši
- [ ] Korpa: prazna, odabrana, picker i zaključana stanja rade
- [ ] Svih 8 sezona čitljivo (i tamne)
- [ ] Hub swipe radi u polju
- [ ] Rarity prepoznatljiv na grayscale screenshotu
- [ ] Smoke: sve iz liste gore (ažurirano gdje se tok svjesno mijenja)

---

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-22 | Brief za polje sezone napisan. Novi format: CD dobija slobodu da unaprijedi dizajn i isporučuje **jedan dizajn** (bez smjerova i varijanti), a svoje dileme odlučuje sam u README § Odlučeno. Paket odmah dolazi kao zip u Godot formatu (`godot/field_export.json` u šemi Home paketa). Pravila i brojevi iz §2 su fiksni. |

## Otvorena pitanja (nakon CD-a)

- [ ] Da li livada pokazuje igračev napredak u sezoni (prijedlog CD-a, §4.2)?
- [ ] Pip reakcija na tap (prijedlog CD-a)?
- [ ] Endless težina: ostaje fiksni `Hard` ili izbor (ideja van zadatka)?

## Povezano

- [[../_index|Iskustvo]]: roditeljski hub
- [[home-season-select-cd-brief]]: biranje sezone (ulaz u polje), isti format
- [[home-season-select-izvjestaj]]: šta je preneseno na biranju sezone
- [[hub-header-footer-cd-brief]]: okvir u koji polje ulazi
- [[camp-cd-brief]]: vizuelni jezik, `CampButton` i `CampArtFrame`
- [[seeds-flowers-cd-brief]]: cvijeće (posebna ilustracija)
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]]: § 1 Main Menu
- [[../../01-vision/design-pillars|design-pillars]]: Pillar 2 (Fair F2P), Pillar 3
- [[../art-direction|art-direction]] · [[../pristupacnost|pristupačnost]]
