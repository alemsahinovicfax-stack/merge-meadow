---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, camp, ekonomija, claude-design, mockup]
povezano:
  - merge-arena-cd-brief
  - hub-header-footer-cd-brief
  - seeds-flowers-cd-brief
  - spec-vertical-slice
  - ekonomija-brojevi
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Camp (4. stranica huba) — brief za Claude Design i zapis prenosa (2026-09-16, smjer 1b: hero sezona + tabovi Seeds/Flowers + jedan Trade bar; držanje staje na granici ★3 cvijeća za sezonu). §2–§3 = stanje prije, § Implementacija = trenutno stanje i odstupanja."
---

# Camp — Claude Design brief i referenca

> **Status: implementirano 2026-09-16** — smjer 1b (tabovi + hero sezona) iz Claude Design handoffa (`design_handoff_camp/`). §2–§3 opisuju stanje **prije** prenosa i ostaju kao zapis; trenutno stanje, novo pravilo držanja i odstupanja su u [[#Implementacija (2026-09-16)|§ Implementacija]]. Prenos zamjenjuje CAMP-06 raspored — CAMP-06 u CHECKPOINT-u zatvoriti nakon playtesta.

> **Druga runda (2026-09-24):** [[camp-v2-cd-brief|camp-v2-cd-brief]] — čišćenje teksta i rasporeda (bez „Next free season" i „Details", manji Unlock, sekcija prikovana uz karticu, bez Merge prečice i podnaslova tabova, veći art u karticama, kraći Trade bar).

**Camp** je igračeva "ostava i radionica": ovdje vidi šta je skupio (sjemenke iz runova, T3 cvijeće iz Arene), pretvara višak u coine i prati koliko mu fali do sljedeće besplatne sezone. Merge se **ne** radi ovdje (to je Arena), a upgradei se **ne** kupuju ovdje (to je Home polje).

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl kao prilog (§1–§8) | Pravila koja važe, mjere, trenutno stanje, sloboda i ograničenja |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §5, §10 | Tačne današnje vrijednosti, poznati problemi, mapa "CD sloj → Godot node" |

Postupak: u CD priloži ovaj `.md` fajl, pa zalijepi prompt iz §9. Ako CD projekat nema prethodne radove, priloži i `design_handoff_hub_chrome/HubScreen.dc.html` (okvir) i `design_handoff_merge_arena/SeedChip.dc.html` (vizuelni jezik sjemenke) — Camp treba da izgleda kao ista igra. Kad CD završi, izvezi `.dc.html` + asset fajlove i daj ih agentu.

---

## 1. Kontekst (za CD)

- **Merge Meadow** — casual F2P merge/runner hibrid za mobitel, **portrait**. Flat 2D cartoon, pastel, meki outline, bez pixel-arta, bez 3D ([[../art-direction|art-direction]]). Mood: *cozy meadow*.
- **Petlja:** run → sjemenke u **vreću** (max 40) → **Arena** spaja T1 → T2 → T3 → T3 "**Flowers**" idu u garden stash → troše se na: (a) Magnet / Loot Boost upgrade na Home polju (2 cvijeta istog tipa po nivou), (b) otključavanje sljedeće besplatne sezone, (c) **Trade za coine u Campu**. I sjemenke se u Campu mogu prodati za coine.
- Camp je **4. stranica** swipe meta-huba (Shop · Journal · Home · **Camp** · Arena) — između Home i Arene.
- **8 sezona × 6 tipova** cvijeća, rarity ★1–★3. Besplatne sezone se otključavaju redom (Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy); 4 plaćene nisu dio Campa.
- **Pillar 3** ([[../../01-vision/design-pillars|design-pillars]]): "Kamp te zove natrag" — napredak treba da se *vidi i osjeća*. **Pillar 2** (Fair F2P): u Campu nema kupovine za pravi novac; Trade je razmjena, ne prodavnica.

---

## 2. Kako Camp radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled i osjećaj**, ne pravila. Izvor: `camp_controller.gd`, `seed_bag_chip.gd`, `crystal_stash_chip.gd`, `season_link_card.gd`, `season_unlock_progress.gd`, `economy/seasons.gd`, `GameState`.

### 2.1 Seeds (vreća sjemena, T1)

- Po jedan chip za svaki tip koji igrač ima (≥ 1), sortirano **rastuće po rarity** (★1 prvo), 2 kolone.
- **Tap na chip** = odabir tipa za prodaju (uvijek je tačno jedan odabran; default prvi).
- **Trade:** tap = proda **1** sjeme; **držanje = 10 / s**. Kad se odabrani tip isprazni, odabir **sam prelazi na sljedeći** tip i držanje nastavlja.
- **Cijena po sjemenu:** ★1 = **1**, ★2 = **2**, ★3 = **4** coina.
- Vreća ima soft cap **40**. Sjemenke su gorivo za Arenu (u hubu Camp nema Merge dugme — Arena je susjedni tab).

### 2.2 Flowers (garden stash, T3 kristali)

- Isti obrazac: chip po tipu (T3 ikona), sortirano rastuće, tap = odabir, Trade tap 1 / držanje 10 / s, auto prelaz.
- **Cijena po cvijetu:** ★1 = **5**, ★2 = **10**, ★3 = **20** coina.
- Cvijeće se troši i drugdje: **upgrade** na Home polju (2 cvijeta istog tipa po nivou, max 4 nivoa po upgradeu) i **otključavanje sezone** (§2.3).

### 2.3 Sljedeća sezona (SeasonLink)

- Prikazuje **sljedeću zaključanu besplatnu** sezonu (npr. Frost Orchard). Kad su sve besplatne otključane, sekcija **nestaje** — Camp tada ima samo Seeds i Flowers.
- **Uslovi** (primjer Frost Orchard): **500 coina** + **20 ★3 cvjetova prethodne besplatne sezone** (Harvest Pumpkin iz Country Blooma). Lantern Meadow i Amber Canopy: isto, 500 + 20.
- Dvije kolone: **coini** (ikona, `100 / 500`, bar) | **★3 cvijet** (slika, ★★★, ime, `3 / 20`, bar), vertikalna linija između.
- Pozadina kartice = **mood boja sezone** (tabela §5).
- **Tap bilo gdje na kartici** → skok na Home, fokus na tu sezonu (ništa se ne troši).
- **Unlock:** aktivno (zlatno) tek kad su **oba** uslova ispunjena; tap → Home, pa nakon 0,4 s otključa i **potroši 500 coina i 20 ★3 cvjetova**. Kad ne može: sivo i ne reaguje.

### 2.4 Hub integracija

- Header (valute + Settings) i footer (tabovi) su iznad i ispod; Camp ima **1080 × 1597 px**. Campov stari vlastiti header (Home, Journal, Settings, resursi) i footer (Merge / Play) su u hubu sakriveni — **ne dizajniraju se**.
- Svaki pojedinačni trade odmah osvježava header (coini) i SeasonLink (napredak).
- Nav nije zaključan u Campu (za razliku od Arene).

### 2.5 Tekstovi danas (EN)

`Seeds` · `Flowers` · `Trade` · `Unlock` · ime sezone (`Frost Orchard`) · `100 / 500` · `3 / 20` · imena cvjetova (`Meadow Clover`, `Harvest Pumpkin`… do ~20 znakova, npr. `Paper Lantern Bloom`). Drugih poruka danas nema (hintovi su uklonjeni u CAMP-01…03). **CD smije predložiti nove kratke tekstove** (tabela *novo / gdje*).

---

## 3. Trenutni raspored (uvod u dizajn)

Scena: `game/scenes/camp/camp_scene.tscn` · skripta: `game/scripts/camp/camp_controller.gd`

```
 1080 px
┌──────────────────────────────────────────────┐
│ [● 12,450] [♣ 340] [◆ 12]              [⚙]  │ HEADER 143 px — zadato
╞══════════════════════════════════════════════╡ ─┐
│ ┌──────────────── Seeds ─────────────────┐   │  │ trećina ≈ 520 px
│ │[★ ico Meadow Clover (12)(1●)][★ ico …] │   │  │ 2 kolone, scroll povlačenjem
│ │[★ ico Field Daisy   (4)(1●)] [★ ico …] │   │  │
│ │               [  Trade  ]              │   │  │ 460 × 64
│ └────────────────────────────────────────┘   │  │
│ ┌──────────────── Flowers ───────────────┐   │  │ trećina
│ │[★ ✦ Field Daisy  (3)(5●)]  [★ ✦ …]     │   │  │ CAMP STRANICA 1080 × 1597
│ │               [  Trade  ]              │   │  │
│ └────────────────────────────────────────┘   │  │
│ ┌──────────── Frost Orchard ─────────────┐   │  │ trećina, tint po sezoni
│ │     (coin)       ┃     ★★★ (pumpkin)   │   │  │
│ │                  ┃   Harvest Pumpkin   │   │  │
│ │    100 / 500     ┃       3 / 20        │   │  │
│ │   [====------]   ┃    [==--------]     │   │  │
│ │               [  Unlock  ]             │   │  │ 460 × 64
│ └────────────────────────────────────────┘   │  │
╞══════════════════════════════════════════════╡ ─┘
│ Shop   Journal   Home   [Camp]   Arena       │ FOOTER 180 px — zadato
└──────────────────────────────────────────────┘
```

### 3.1 Elementi danas

| Element | Danas |
|---------|-------|
| Stranica | 1080 × 1597; tamna livada `#2E4733`; margine 12 px lijevo/desno, 8 px gore/dole; razmak kartica 8 px; **nema vanjskog scrolla** |
| Kartice | tri **jednake trećine** (≈ 520 px); pozadina `#F5FAF2` @ 98 %, radius 16, border 2 px outline @ 14 %, padding 14 / 12 |
| Naslov kartice | `Seeds` / `Flowers`, 30 px, centriran |
| Grid | 2 kolone (chip ≈ 510 px širok), razmak 8 px; vertikalni scroll **povlačenjem**, bez trake; tap vs scroll prag 12 px; vidi se ≈ 3 reda (6 chipova) |
| Chip (Seeds = Flowers) | ≈ 510 × 119 px; pozadina = **rarity boja**; radius 12, border 2 px @ 16 %. Lijevo: ★ (22 px, samo popunjene) iznad ikone ~80 px (Seeds: T1 sadnica, Flowers: T3 kristal). Sredina: ime 30 px (prelama se). Desno: **count pill** (60 h, radius 8, rarity → warm white 55 %) broj 34 px + **price pill** (`#FFE8B8`, 60 h) cijena 36 px + coin ikona 36 |
| Chip odabran | border 4 px peach `#FFB88C`, pozadina rarity 12 % svjetlija |
| Trade | 460 × 64, `price` varijanta (`#FFE8B8`), 34 px; bez odabira — providna ispuna |
| SeasonLink | tint mood boje sezone (20 % svjetlije ili 18 % tamnije), radius 16; naslov 36 px; kolone: coin 88 px \| cvijet 88 px, ★ 28 px, ime 28 px, broj 32 px, bar 16 px; vertikalna linija 5 px |
| Unlock | 460 × 64; `gold` (`#E8C44A`) kad može, `subtle` (warm white, sivo) kad ne može |

### 3.2 Šta danas ne štima (zapažanja iz koda, nisu odluke)

1. **Zamka: prodaja cvijeća koje sezona traži.** Flowers Trade prodaje ★3 cvijeće (npr. Harvest Pumpkin, 20 coina komad) koje SeasonLink traži za otključavanje (20 komada) — bez ikakve oznake ili upozorenja. Igrač može "zaraditi" coine za sezonu prodajom upravo onoga što mu za nju treba. Slično za 2 cvijeta po upgradeu na Home.
2. **Seeds i Flowers izgledaju identično** — isti chip, isti Trade, razlikuje ih samo naslov i sitna ikona. Ne vidi se da su sjemenke *gorivo za Arenu*, a cvijeće *nagrada i valuta*.
3. **Dva broja jedan do drugog** (count pill i price pill) — nejasno šta je "imam" a šta "vrijedi"; da je cijena **po komadu** nigdje ne piše.
4. **Trade pravila su nevidljiva:** tap = 1, držanje = 10 / s, auto prelaz na sljedeći tip — ništa od toga se ne vidi; nema feedbacka koliko je coina upravo dobijeno (samo header se promijeni).
5. **Nema empty stanja** — prazna vreća ili prazan stash = naslov + sivo dugme.
6. **SeasonLink:** tap na cijelu karticu vodi na Home (skrivena radnja); nema jasnog "fali ti još 400 coina i 17 bundeva".
7. **Krute trećine:** s jednim tipom kartica je gotovo prazna, s 15+ tipova se scrolla u malom prozoru; bez sljedeće sezone ostaju 2 kartice.
8. **Stil ne prati novi chrome i Arenu** (tamna traka `#1A241E`, sjemenka = cream rim + tamni well) — Camp su svijetle ploče s pastelnim chipovima.
9. **Dodir i tekst:** Trade / Unlock 64 px (≈ 23 dp, ispod 120 px); zvjezdice 22 px (≈ 8 sp).
10. **Nema identiteta** — Camp je tri tabele; "pastelni kutak koji raste s tobom" (Pillar 3) se ne osjeća.

---

## 4. Zahtjevi za redizajn

Trenutni izgled je **polazna tačka, ne šablon.** CD ima slobodu u rasporedu, vizuelnoj metafori i feedbacku — dok god poštuje ovo:

### 4.1 MORA

- **Pravila iz §2 ostaju:** kursevi, tap = 1 / držanje = 10 / s, auto prelaz, uslovi otključavanja, tap na sezonu → Home, Unlock troši 500 + 20.
- **Tri funkcije:** Seeds (pregled + prodaja), Flowers (pregled + prodaja), Sljedeća sezona (napredak + Unlock). Bez nove mehanike (nema merge u Campu, nema kupovine za pravi novac, nema upgradea — oni su na Home).
- **Stanja:** Camp s 3 i s **2** sekcije (sve besplatne sezone otključane); prazna vreća; prazan stash; 1 tip; **20+ tipova** (dugačka lista).
- **★3 cvijeće koje sezona traži mora biti vidljivo označeno** prije prodaje (npr. "needed for Frost Orchard · 3/20"). CD predlaže kako (oznaka, drugačiji chip, potvrda pri prodaji…); samo pravilo prodaje se ne mijenja — ako predlog traži promjenu pravila (npr. blokada), navedi ga odvojeno.
- **Rarity čitljiv i bez boje** (zvjezdice, oblik), isto kao u Journalu i Areni.
- **Dodir i tekst:** Trade / Unlock hit-zona ≥ **120 px** visine; chip ≥ 120 px; labele ≥ **38 px**, brojevi ≥ **44 px**.
- **Header i footer su zadati**; Camp živi u **1080 × 1597 px** između njih.
- **Cvijeće i sjemenke CD ne crta** — koristi postojeću ilustraciju; okvir/ikona smije pratiti Arena SeedChip jezik (cream rim + tamni well).
- **Pillar 2:** bez "kupi coine" CTA-a u Campu; Trade je razmjena.

### 4.2 SMIJE (sloboda)

- **Raspored:** npr. tabovi Seeds | Flowers, jedna lista s filterom, sekcije različite visine, sticky Trade traka, "hero" sezona na vrhu… (fiksne trećine nisu obavezne).
- **Vizuelna metafora:** vrtna ostava, police, korpe, sanduci, stol s posudama… — cozy, flat, u paleti.
- **Identitet stranice** (naslov, mala ilustracija, Pip) — ako ne jede prostor listama.
- **Trade UX:** jasna vrijednost ("4 ● each"), "+4 ●" pop koji leti u header, vidljiv hold (napunjavanje), auto prelaz koji se vidi.
- **Sljedeća sezona:** veći prikaz, jasna lista šta fali, trenutak otključavanja (slavlje).
- **Prečica "Merge in Arena"** kod sjemenki (skok na Arena tab) — kao prijedlog.
- **Novi kratki tekstovi** (EN).

Ideje van ovoga (npr. "Sell all", sortiranje, nove mehanike) navedi **odvojeno na kraju**.

---

## 5. Paleta i tokeni

**Paleta** — [[../art-direction|art-direction]] + `ui_palette.gd` + hub chrome + Arena. Nove nijanse samo kao svjetlija/tamnija varijanta postojećih, jasno označene.

| Uloga | Hex |
|-------|-----|
| Mint · lavanda · peach (CTA / odabir) | `#A8E6CF` · `#D4A5FF` · `#FFB88C` |
| Coin gold · UI gold (Unlock) | `#FFD56B` · `#E8C44A` |
| Warm white · price bg | `#FFF8F0` · `#FFE8B8` |
| Soft sky · pastel yellow · pastel pink | `#B8E0F5` · `#FFEAA7` · `#FFCCD5` |
| UI tekst · outline | `#4A4A4A` · `#2D3436` |
| Hub chrome · Arena well · Arena rim edge | `#1A241E` · `#22342A` · `#CBC2B6` |
| Camp pozadina (danas) · kartica (danas) | `#2E4733` · `#F5FAF2` |
| Rarity pozadine | ★1 `#B8D4F0` · ★2 `#E0C4FF` · ★3 `#FFE8B8` · locked `#E4E4E0` |

**Mood boje besplatnih sezona** (`season_card_contrast.gd` — tint SeasonLinka):

| Sezona | Mood | Tekst na kartici |
|--------|------|------------------|
| Frost Orchard | `#C5D5E8` | tamni ink `#1A1A14` |
| Lantern Meadow | `#C9B8E0` | tamni ink |
| Amber Canopy | `#E8C48A` | tamni ink |

**Tokeni:** radius 12 / 16 / 20 / 26 · border 2 px outline @ 10–14 % · jedna drop sjena · outline ~20 % tamniji od fill-a.

**Font:** igra koristi default sans (težine simulirane); mockup smije Nunito kao prethodni CD radovi.

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

**Lako za prenijeti:**

- Kartice, chipovi, pillovi, dugmad = Godot `StyleBoxFlat` (ravna boja + alpha, zaobljeno, border, jedna sjena).
- Liste = `ScrollContainer` + grid/lista; scroll povlačenjem već postoji (bez trake).
- Držanje dugmeta (auto-repeat 10 / s) već postoji u `UiClickButton` — vizuelni prikaz napunjenosti je izvodljiv.
- Progress barovi = obojene trake (ravna boja, zaobljeno).
- Animacije = tween (skala, pozicija, prozirnost, boja), mali "pop" i let ikone do headera (kao T3 u Areni).
- Ikone kao SVG/PNG; ilustracija pozadine kao PNG.

**Izbjegavati:** blur/glow shadere, gradijente na panelima, teške čestice, maske/izreze (osim kao PNG).

**Layout:** artboard **1080 × 1920**, sve mjere u px te baze (prenos 1:1); Camp = **1080 × 1597** između headera (143) i footera (180); 1 dp ≈ 2,75 px → dodir 44 pt ≈ **120 px**, tekst 14 pt ≈ **38 px**.

---

## 7. Šta tražimo od CD (isporuka)

**P1 — obavezno:**

1. **Glavni ekran 1080 × 1920** sa headerom/footerom: tipično stanje — Seeds 6 tipova (jedan odabran), Flowers 4 tipa (uklj. Harvest Pumpkin označen kao potreban za sezonu), Frost Orchard `320 / 500` i `12 / 20`.
2. **Isti ekran bez sljedeće sezone** (sve besplatne otključane) — 2 sekcije.
3. **Rubna stanja:** prazna vreća; prazan stash; 20+ tipova u jednoj sekciji.
4. **Spec sheet chipa:** Seeds i Flowers (★1 / ★2 / ★3) — neodabran, odabran, pritisnut, "potreban za sezonu".
5. **Trade:** tap (1) i držanje (10 / s) — feedback vrijednosti, auto prelaz na sljedeći tip, disabled.
6. **Sljedeća sezona:** nedovoljno / spremno za Unlock / trenutak otključavanja (storyboard 2–3 kadra) + tint za Frost, Lantern i Amber.

**P2 — poželjno:**

7. **Tabela animacija** (šta, trajanje, easing).
8. **Lista asseta za export** (SVG/PNG).
9. **Alternativni raspored** (npr. tabovi umjesto sekcija) za poređenje.

**Max 2 vizuelna smjera**, jedan pored drugog, uz preporuku CD-a koji je bolji i zašto.

**Imena slojeva** (za mapiranje na Godot, §10): `CampPage`, `SeedsSection`, `FlowersSection`, `SeedChip`, `FlowerChip`, `ReservedBadge`, `TradeButton`, `TradeFeedback`, `SeasonLink`, `CoinProgress`, `FlowerProgress`, `UnlockButton`, `EmptyState`.

## 8. Ne tražimo

- Promjenu pravila i brojeva (§2), novu mehaniku, kupovinu za pravi novac.
- Magnet / Loot Boost upgrade (živi na Home polju), Arenu, header/footer, Shop, plaćene sezone.
- Cvijeće i sjemenke (posebna ilustracija) i lik Pipa (postoji).

---

## 9. Prompt za Claude Design

> Priloži ovaj fajl u CD, pa kopiraj sve iz bloka ispod.

```
Radim redizajn jednog ekrana mobilne igre: CAMP — igračeva ostava i
radionica. Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait,
flat pastel cartoon stil (bez pixel-arta, bez 3D, bez retro efekata).
Mood: cozy livada.

Uz ovu poruku prilažem fajl "camp-cd-brief.md". To je tvoja referenca:
pravila koja važe (§2), trenutni raspored s mjerama (§3), šta danas ne
štima (§3.2), šta mora a šta smiješ (§4), paleta (§5), tehnička ograničenja
(§6) i isporuka (§7). Pročitaj ga cijelog prije rada — §10 je za kasniji
prenos u Godot i možeš ga preskočiti. Ovaj prompt je sažetak; ako se nešto
razlikuje, važi fajl.

Header/footer huba i Merge Arena su već redizajnirani u ovom projektu (tamna
traka #1A241E; sjemenka = cream rim + tamni well). Camp mora izgledati kao
ista igra — nastavi taj vizuelni jezik.

CILJ: Camp treba da bude pregledan, "cozy kutak koji raste s tobom" i da
igraču jasno kaže šta ima, šta vrijedi i koliko mu fali do sljedeće sezone
— a da ga mogu 1:1 prenijeti u Godot 4. Imaš punu slobodu u rasporedu,
vizuelnoj metafori i feedbacku. Pravila i brojevi su fiksni.

KAKO CAMP RADI (detalji u §2):
- SEEDS: sjemenke iz runova (gorivo za Arenu). Chip po tipu, sortirano
  rastuće po rarity; tap = odabir tipa; TRADE prodaje 1 sjeme po tapu,
  držanje prodaje 10/s i samo prelazi na sljedeći tip kad se isprazni.
  Cijena po sjemenu: ★1 = 1, ★2 = 2, ★3 = 4 coina.
- FLOWERS: T3 cvijeće iz Arene. Isto: odabir + Trade (tap 1 / držanje
  10/s). Cijena: ★1 = 5, ★2 = 10, ★3 = 20 coina. Cvijeće se troši i na
  upgrade (Home) i na otključavanje sezone.
- SLJEDEĆA SEZONA: sljedeća zaključana besplatna sezona (npr. Frost
  Orchard): treba 500 coina + 20 ★3 cvjetova prethodne sezone (Harvest
  Pumpkin). Prikaz: coini "100 / 500" + bar | ★3 cvijet "3 / 20" + bar.
  Tap na karticu = skok na Home. UNLOCK je aktivan tek kad su oba uslova
  ispunjena i tada troši 500 coina + 20 cvjetova. Kad su sve besplatne
  sezone otključane, ova sekcija nestaje (Camp ima 2 sekcije).

GDJE ŽIVI: 4. stranica meta-huba. Header (143 px) i footer (180 px) su
zadati — prikaži ih, ne mijenjaj ih. Camp ima 1080 × 1597 px između njih.

GLAVNI PROBLEMI DANAS (§3.2):
1. Trade može prodati ★3 cvijeće koje je potrebno za sezonu — bez ikakve
   oznake. Mora biti jasno označeno prije prodaje.
2. Seeds i Flowers izgledaju identično; ne vidi se razlika "gorivo za
   Arenu" vs "nagrada/valuta".
3. Broj koji imam i cijena po komadu stoje jedan do drugog bez objašnjenja.
4. Trade pravila (tap/držanje/auto prelaz) i dobijeni coini se ne vide.
5. Nema empty stanja; krute trećine; dugmad premala (64 px).

DIZAJNIRAJ (sloboda):
- Raspored (npr. tabovi Seeds | Flowers, sekcije različite visine,
  sticky Trade traka, "hero" sezona) — trećine nisu obavezne.
- Vizuelnu metaforu (vrtna ostava, police, korpe…) i identitet stranice.
- Chip za sjemenku i za cvijet (★1/★2/★3; neodabran, odabran, pritisnut,
  "potreban za sezonu").
- Trade feedback: vrijednost po komadu, "+4 ●" pop koji leti u header,
  vidljivo držanje, vidljiv auto prelaz.
- Sljedeću sezonu: jasno šta fali, trenutak otključavanja.
- Po želji prečicu "Merge in Arena" kod sjemenki i kratke nove tekstove (EN).

MORA:
- Pravila i brojevi iz §2 ostaju.
- Stanja: 3 i 2 sekcije, prazna vreća, prazan stash, 1 tip, 20+ tipova.
- Rarity čitljiv i bez boje (zvjezdice/oblik).
- Trade/Unlock hit-zona ≥ 120 px; chip ≥ 120 px; tekst ≥ 38 px,
  brojevi ≥ 44 px; EN tekst.
- Cvijeće i sjemenke NE crtaš — koristi postojeću ilustraciju; okvir smije
  pratiti Arena sjemenku.
- Bez kupovine za pravi novac i "kupi coine" dugmadi (Fair F2P).

PALETA (koristi ove hex vrijednosti; nove nijanse samo kao svjetlija/tamnija
varijanta postojećih i jasno ih označi):
mint #A8E6CF · lavanda #D4A5FF · peach #FFB88C (CTA/odabir) · coin gold
#FFD56B · UI gold #E8C44A · warm white #FFF8F0 · price bg #FFE8B8 · soft
sky #B8E0F5 · pastel yellow #FFEAA7 · pastel pink #FFCCD5 · UI tekst
#4A4A4A · outline #2D3436 · chrome #1A241E · Arena well #22342A · rarity
★1 #B8D4F0 / ★2 #E0C4FF / ★3 #FFE8B8 · mood sezona Frost #C5D5E8 /
Lantern #C9B8E0 / Amber #E8C48A
Stil: zaobljeno, outline ~20 % tamniji od fill-a, jedna blaga sjena.

TEHNIČKI (Godot 4, OpenGL, slabiji Android):
- Artboard 1080 × 1920 px; sve mjere u px te baze (prenos 1:1).
- Paneli/chipovi/barovi = ravna boja (+alpha), zaobljeno, border, jedna
  sjena. Bez blura, gradijenata na panelima, teških čestica.
- Liste scrollaju povlačenjem; držanje dugmeta (10/s) već postoji.
- Animacije = tween (skala, pozicija, prozirnost, boja).

ISPORUKA (statični artboardi, jasno labelirani):
P1 — obavezno:
1. Glavni ekran 1080 × 1920 sa headerom/footerom: Seeds 6 tipova (jedan
   odabran), Flowers 4 tipa (Harvest Pumpkin označen kao potreban za
   sezonu), Frost Orchard 320/500 i 12/20.
2. Isti ekran bez sljedeće sezone (2 sekcije).
3. Rubna stanja: prazna vreća, prazan stash, 20+ tipova.
4. Spec sheet chipa (Seeds i Flowers, ★1/★2/★3, sva stanja).
5. Trade: tap i držanje, feedback vrijednosti, auto prelaz, disabled.
6. Sljedeća sezona: nedovoljno / spremno / trenutak otključavanja
   (2–3 kadra) + tint Frost / Lantern / Amber.
P2 — poželjno:
7. Tabela animacija (šta, trajanje, easing).
8. Lista asseta za export (SVG/PNG).
9. Alternativni raspored (npr. tabovi) za poređenje.
Pokaži max 2 vizuelna smjera jedan pored drugog i reci koji preporučuješ i
zašto.

IMENA SLOJEVA (da ih mogu mapirati na Godot node-ove): CampPage,
SeedsSection, FlowersSection, SeedChip, FlowerChip, ReservedBadge,
TradeButton, TradeFeedback, SeasonLink, CoinProgress, FlowerProgress,
UnlockButton, EmptyState.

NE RADI: pravila i brojeve, novu mehaniku, Magnet/Loot Boost upgrade (to je
Home), Arenu, header/footer, Shop, plaćene sezone, cvijeće, lik Pipa. Ideje
van zadatka (npr. "Sell all", sortiranje) navedi odvojeno na kraju.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `CampPage` | `camp_scene.tscn` → `RootVBox/MainScroll/ContentMargin/Content` (+ `MeadowBg`) | U hubu: `HeaderPanel` (Home/Journal/Settings/ResourceBar) i `FooterBar` (Merge/Play) sakriveni u `_apply_hub_chrome()`; `UpgradeCards` i `StatusToast` uvijek sakriveni — kandidati za čišćenje |
| `SeedsSection` / `FlowersSection` | `%GardenCard` / `%CrystalCard` (+ `%SeedBagScroll`/`%SeedBagGrid`, `%CrystalScroll`/`%CrystalGrid`) | Trećine = `size_flags_stretch_ratio` 1.0 (smoke to provjerava — novi raspored mijenja i test) |
| `SeedChip` / `FlowerChip` | `seed_bag_chip.gd` / `crystal_stash_chip.gd` (ikone: `seed_bag_icon.gd` / `crystal_stash_icon.gd` preko `CampPlantDraw`) | Dva gotovo identična fajla — prenos je prilika za zajedničku baznu klasu |
| `ReservedBadge` | novo | Podatak: `GameState.star3_type_id_for_season(GameState.previous_free_id_for(next_id))` + `GameState.star3_flower_count_for_unlock(next_id)` |
| `TradeButton` | `%ExchangeButton` / `%CrystalExchangeButton` (`UiClickButton` `price`, `auto_repeat` 10 / s, `ghost_when_disabled`) | Logika: `_trade_step()` / `_crystal_step()`, lagani refresh `_refresh_trade_light()` (hold ne rebuilda grid) |
| `TradeFeedback` | novo | Iznos: `GameState.seed_exchange_coins_per_seed(type)` / `crystal_exchange_coins_for_type(type)`; header: `_notify_hub_chrome()` |
| `SeasonLink` / `CoinProgress` / `FlowerProgress` / `UnlockButton` | `%SeasonLinkCard` (`season_link_card.gd`) + `SeasonUnlockProgress` (`season_unlock_progress.gd`) | `season_unlock_progress.gd` je **dijeljen s Home UnlockGate posterom** (Home stacked, Camp split) — izmjene diraju i Home. Tint: `season_card_contrast.gd` |
| `EmptyState` | novo | `GameState.get_seed_bag_entries()` / `get_garden_crystal_entries()` prazni |

**Smoke testovi koje prenos mora proći ili svjesno ažurirati:** `camp_layout_smoke` (trećine, sakriveni elementi, naslovi Seeds / Flowers), `camp_trade_select_smoke` (tap = 1, ASC sort, default odabir), `camp_trade_hold_smoke` (labela `Trade`, 10 / s, auto prelaz, save na otpuštanje), `camp_crystal_select_smoke`, `camp_season_link_smoke` (SplitRow, tap → Home, Unlock gold / subtle, troši 20 bundeva), `camp_donate_smoke` (UpgradeCards sakriveni).

**Poznati problemi nađeni pri pisanju briefa:**

1. **Trade prodaje ★3 cvijeće potrebno za sezonu** — UX (ovaj brief traži oznaku); ako se odluči i za zaštitu u pravilima (potvrda / blokada), to je promjena mehanike i ide u [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]].
2. **Mrtav kod u hubu:** Campov `HeaderPanel`, `FooterBar`, `UpgradeCards`, `StatusToast`, `GardenCliff`, `BagLabel`, `CrystalTotalLabel`, `CollectionBadge` — postoje samo za standalone Camp koji se u igri više ne otvara.
3. **CAMP-06 čeka playtest** — prenos CD dizajna ga zamjenjuje; zatvoriti CAMP-06 u CHECKPOINT-u tek kad se odluči.
4. **CHECKPOINT je zastario za hold:** red CAMP-06 kaže `hold=6/s`, a kod i smoke kažu **10 / s** (`TRADE_HOLD_RATE`, commit dbcfa12) — važi kod.

**Gotovo kad (implementacija):**

- [x] Camp stane između headera i footera; Trade / Unlock ≥ 120 px
- [x] Rade 3 i 2 sekcije, prazna stanja i 20+ tipova
- [x] ★3 cvijeće potrebno za sezonu označeno u Flowers
- [x] Trade feedback vidljiv za tap i držanje; auto prelaz vidljiv
- [ ] Rarity prepoznatljiv na grayscale screenshotu — provjeriti u playtestu
- [x] Smoke: svih 7 `camp_*_smoke` (ažurirani + novi `camp_hold_floor_smoke`) + `meta_hub_flow_smoke`

---

## Implementacija (2026-09-16)

Prenesen **smjer 1b — tabovi + hero sezona** iz `design_handoff_camp/`. §2–§3 opisuju stanje **prije** prenosa.

| Fajl | Uloga |
|------|-------|
| `game/scripts/visual/ui_camp.gd` | Boje, budžet 1597 px, mjere, stilovi, tekstovi stanja — iz CD `ui_camp.gd`, ispravljen prema `.dc.html` (vidi odstupanja 1–3) |
| `game/scenes/camp/camp_scene.tscn` + `camp_controller.gd` | Hero `SeasonLinkCard` gore (422), `StashSection` dolje: `StashTabs` (Seeds · Flowers · Merge), `StashScroll` s `SeedBagGrid` / `CrystalGrid`, `EmptyState`, `ExchangeBar`; grid se pakuje po stvarnim redovima i reže na ≤ 4 reda koji staju |
| `game/scripts/camp/camp_stash_chip.gd` | Jedan chip za sjeme i cvijet (zamjenjuje `seed_bag_chip` / `crystal_stash_chip` + ikone): okvir + well + art, ime, ★☆☆, CountPill, PricePill "each", `ReservedBadge`, `SelectMark`, lift −3 |
| `game/scripts/camp/camp_stash_tab.gd` | Tab s ikonom, brojem tipova i podnaslovom; naslov se smanjuje (≥ 34 px) kad je tab uzak |
| `game/scripts/camp/camp_trade_bar.gd` | Odabrani tip + cijena po komadu, strip za rezervisano, "+N" pop koji na otpuštanje leti do coin chipa u headeru, mint "empty — switched here" |
| `game/scripts/camp/camp_button.gd` | `UiClickButton` sa stilom iz `UiCamp`, naslov + podnaslov, ikona, hold fill |
| `game/scripts/camp/camp_art_frame.gd` | Okvir (cream krug / coin gold kvadrat) + well + cvijet (`ArenaChipDraw`) ili ikona |
| `game/scripts/camp/season_link_card.gd` | Hero kartica: "Next free season", Coins / ★3 cvijet s barovima, Unlock s tri stanja, burst |
| `game/scripts/ui/ui_click_button.gd` | `repeat_guard` + `repeat_blocked` + `last_click_was_repeat` — držanje staje, tap ostaje netaknut |
| `game/assets/ui/camp/*.svg` | `icon_merge_arrow`, `icon_reserved`, `icon_hold_stop` |
| `game/scripts/dev/camp_*_smoke.gd` + `camp_smoke_util.gd` | 6 ažuriranih + novi `camp_hold_floor_smoke`; backup/restore `player_save.json` |

**Pravilo (odluka 2026-09-15):** rezervisani tip = ★3 cvijet prethodne besplatne sezone, granica = `t3_flowers_required` sljedeće (Frost Orchard: 20 Harvest Pumpkin). Iznad granice držanje ide 10/s i staje kad bi sljedeći tik odveo tip ispod granice; na i ispod granice tap prodaje po 1, držanje ne ponavlja. Auto prelaz radi dalje; kad uđe u rezervisani tip, staje na njegovoj granici. Sjemenke i stanje bez sljedeće sezone nemaju granicu. Upisano u [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]].

**Riješeno iz §3.2 / §10:** oznaka `Kept · N / 20` prije prodaje (#1); Seeds i Flowers razlikuju okvir (cream krug / gold kvadrat) i podnaslov "Arena fuel" / "reward" (#2); cijena nosi "each" (#3); Trade pokazuje "hold 10 / s", "+N" i auto prelaz (#4); prazna stanja s CTA (#5); "Details ↗" na hero kartici (#6); nema krutih trećina (#7); Trade / Unlock 120 / 132 px, tekst ≥ 30 px (#9); mrtvi `UpgradeCards` / `StatusToast` / cliff labele uklonjeni.

**Odstupanja od handoffa (svjesna):**

1. **`ui_camp.gd` ↔ `.dc.html`** — gdje se razilaze, prenesen je crtež: tamni ink `#2D3436` (CD je `UiPalette.UI_TEXT` čitao kao `#2D3436`, a on je `#4A4A4A`), rubovi panela `OUTLINE` @ 16–18 % (ne puni), okvir cvijeta coin gold `#FFD56B` (ne UI gold), brojač taba 60 × 88 · r 14, rub spremnog Unlocka `#BA9D3B`, sjene s malim blurom (`shadow_size = 0` ne crta sjenu).
2. **Sekcija +4 px** — HTML je border-box, a README zbirovi ne broje rub od 2 px; u Godotu je content margin 18 + 2, pa tabovi (387) i chipovi (489) ostaju tačni, a sekcija je 908 / 1098 / 858 / 752 (README 904 / 1094 / 854 / 748).
3. **Okvir cvijeta na hero kartici 48 px** (mockup 52) — isti red kao ikona novčića, kartica ostaje 422.
4. **Unlock troši odmah** i pokaže burst na Campu (0,42 s + 0,45 s), pa Home s fokusom na otključanu sezonu — prije: Home, pa trošenje nakon 0,4 s. Uslovi i iznos isti.
5. **Ikone:** "Merge" = `icon_merge_arrow` + tekst; Kept badge / pink strip = `icon_reserved`, stop = `icon_hold_stop` (mockup je svuda imao `icon_lock`).
6. **Prazna vreća:** kraći tekst iz 1a varijante — 1b tekst u default fontu ide u 3 reda i ruši blok od 400 px. Okvir ikone je pun rub (mockup isprekidan).
7. **Sitni tekstovi:** `Kept · N / M` broji najviše M; Unlock podnaslov izostavlja ispunjen uslov ("needs 8 more flowers"); "1 coin each" / "5 coins each"; "Hold stopped · …" se vidi i kad je tip tačno na granici bez prethodnog držanja.
8. **Hold fill** napreduje 1/10 po auto-tiku i zatvara krug svake sekunde (README: "širina prati 10/s").
9. **Font:** default + embolden, line-height 1 preko `FontVariation` spacinga (`UiCamp.tight_font`) — bez toga chip od 176 px ne primi ime + ★ + pillove.
10. **Smokeovi:** `camp_season_unlock_smoke` iz README-a ne postoji → ažuriran `camp_season_link_smoke`; `camp_donate_smoke` sada provjerava samo GameState API (upgradei su na Home polju).
11. **Ostavljeno:** Camp split mod u `season_unlock_progress.gd` više se ne koristi (Home stacked da) — kandidat za čišćenje; standalone `HeaderPanel` / `FooterBar` ostaju.
12. **Van zadatka, nije urađeno:** Sell all, sortiranje, "keep N", long-press tooltip, animacija badgea kad se granica prebaci na sljedeći ★3 tip.

---

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-12 | Brief napisan. Pravila i brojevi Campa (§2) su fiksni; CD dizajnira izgled i osjećaj. Header/footer i Arena (smjer B) su zadati vizuelni jezik. |
| 2026-09-15 | Rezervisano ★3 cvijeće: oznaka + **držanje staje na granici, tap prodaje dalje** (bez potvrde i blokade). Prečica "Merge" da. Sell all / sortiranje / "keep N" ne sada. |
| 2026-09-16 | Odabran i prenesen **smjer 1b** (tabovi + hero sezona). |

## Otvorena pitanja (nakon CD-a)

- [x] ★3 cvijeće za sezonu → **držanje staje na granici, tap prodaje dalje** (pravilo, ne blokada)
- [x] Raspored → **tabovi** Seeds | Flowers, jedan Trade bar
- [x] Prečica "Merge in Arena" → **da**, na Seeds tabu
- [x] Identitet stranice → **hero kartica sljedeće sezone na vrhu** (bez naslova i Pipa)
- [x] Čišćenje mrtvog standalone koda → `UpgradeCards`, `StatusToast`, cliff labele uklonjeni; standalone header/footer ostaju
- [ ] Ime sezone i na chipu? (CD: treba drugi red 244 → 300 ili font 30)
- [ ] Animacija badgea kad se granica prebaci na sljedeći ★3 tip (nije nacrtano)
- [ ] Outline cvijeta (otvoreno iz Arena paketa) — ne blokira Camp

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[merge-arena-cd-brief|merge-arena-cd-brief]] — isti format; vizuelni jezik sjemenke (smjer B)
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — okvir u koji Camp ulazi
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — cvijeće i sjemenke (posebna ilustracija)
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]] — § 4 Camp
- [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]] — kursevi Trade (uslovi sezona tamo nisu — izvor je `seasons.json`)
- [[../art-direction|art-direction]] · [[../pristupacnost|pristupačnost]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — CAMP-06 (prenos ga zamjenjuje; zatvaranje nakon playtesta)
