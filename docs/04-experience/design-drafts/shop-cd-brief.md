---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, shop, monetizacija, claude-design, mockup]
povezano:
  - hub-header-footer-cd-brief
  - home-season-select-cd-brief
  - home-field-cd-brief
  - journal-cd-brief
  - camp-cd-brief
  - spec-vertical-slice
  - design-pillars
  - art-direction
  - pristupacnost
ai_sažetak: "Shop (1. stranica huba: kozmetika za coine, boosteri, season packovi, Remove Ads / Starter Pack / Restore): pravila iz koda koja ostaju fiksna, današnji raspored i mjere, šta ne štima, sloboda za CD (jedan dizajn, bez varijanti), format zip paketa za direktan prenos u Godot, gotov prompt i mapa node-ova."
---

# Shop — Claude Design brief i referenca

> **Status: implementirano 2026-09-24** — CD paket `design_handoff_shop/`; vidi [§ Implementacija](#implementacija-2026-09-24) i [[shop-izvjestaj|izvještaj]].
>
> Brief pokriva **Shop stranicu huba** (`shop_screen.tscn`). Header i footer (2026-09-11), Merge Arena (09-12), Camp (09-16), Home biranje sezone (09-21), polje sezone (09-22), Run (09-22) i Journal (09-23) su već redizajnirani i u igri — Shop je **posljednja stranica huba koja još izgleda po starom**.
>
> **Format:** CD dobija **slobodu da unaprijedi dizajn** i isporučuje **jedan dizajn**, bez smjerova i varijanti za biranje, kao **zip paket spreman za prenos u Godot** (§7).

Shop je jedino mjesto gdje igrač troši **coine** na kozmetiku i gdje stoje sve kupovine pravim novcem. Ekonomija i cijene se ne mijenjaju — mijenja se kako Shop izgleda i koliko je pošten i razumljiv.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl po putanji iz repoa (§1–§8) | pravila, mjere, problemi, sloboda, format isporuke |
| **Ti** | §9 | gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §3, §10 | tačne današnje vrijednosti i mapa „CD sloj → Godot node“ |

**Prije slanja CD-u:** CD čita repo s `master` grane i samo po tačnoj putanji. Sve što prompt navodi (ovaj fajl i raniji CD paketi) mora biti **commitano i pushano**, inače CD vidi staro stanje.

---

## 1. Kontekst (za CD)

- **Merge Meadow** je casual F2P merge/runner hibrid za mobitel, **portrait**. Stil je flat 2D cartoon, pastelan, meki outline, bez pixel-arta i 3D-a ([[../art-direction|art-direction]]). Mood: *cozy meadow*.
- Hub ima 5 stranica: **Shop** · Journal · Home · Camp · Arena. Shop je **prva slijeva**; do njega se dolazi swipeom ili tapom na tab.
- Header (143 px) i footer (180 px) su zadati i ne mijenjaju se. Stranica ima **1080 × 1597 px** između njih.
- **Valute:** coini (runovi + trgovina sjemenjem u Campu), sjemenke (loot runa), dijamanti (rijedak pickup u runu), cvijeće (merge u Areni, troši se na Magnet / Loot Boost u polju sezone).
- **Pillar 2 — Fair F2P:** core je uvijek besplatan, ništa se ne može kupiti što bi presudno mijenjalo napredak. Kozmetika je čisto vizuelna; sezone su teme; boosteri su sitna pomoć.
- **Pillar 3 — napredak se vidi i osjeća.**

---

## 2. Kako Shop radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled, raspored i prelaze**, ne ekonomiju. Izvor: `game/scripts/ui/shop_screen.gd`, `shop_cosmetic_row.gd`, `shop_booster_row.gd`, `season_pack_card.gd`, `scripts/monetization/monetization_config.gd`, `cosmetic_catalog.gd`, `iap_manager.gd`, `ad_manager.gd`, `scripts/economy/cosmetics.gd`, `boosters.gd`.

### 2.1 Četiri sekcije

| Sekcija | Šta je | Plaća se |
|---|---|---|
| **Cosmetics (coins)** | 5 predmeta | coini iz igre |
| **Boosters (consumables)** | 2 potrošna predmeta | pravi novac |
| **Season packs** | 4 premium sezone | pravi novac |
| **Real-money** | Remove Ads, Starter Pack, Restore | pravi novac |

### 2.2 Kozmetika za coine (`cosmetic_catalog.gd`)

| Predmet | Slot | Cijena | Šta mijenja |
|---|---|---|---|
| Pip Blossom | `pip_skin` | 250 | roze paleta Pipa u runu |
| Pip Sky | `pip_skin` | 200 | plava paleta Pipa |
| Sunset Meadow | `meadow_bg` | 150 | topli tint livade u runu |
| Lavender Meadow | `meadow_bg` | 180 | ljubičasti tint livade |
| Golden Album | `journal_frame` | 120 | zlatni okvir i plaketa u Journalu |

- **Jedan predmet po slotu** može biti opremljen. Kupovina **odmah oprema** predmet.
- Kupljeno ostaje zauvijek; nema prodaje ni povrata. Bez dovoljno coina dugme je neaktivno, poruka je `Need 250 coins.`
- Stanja dugmeta: `250 coins` (kupi) → `Equip` (imaš, nije opremljeno) → `Equipped` (neaktivno).
- **Kozmetika je čisto vizuelna** — nikad ne daje prednost (Pillar 2).

### 2.3 Boosteri (potrošni, pravi novac)

| Booster | Cijena | Šta radi |
|---|---|---|
| **Merge Hint** | €0.99 | označi sljedeći par za merge u Areni (jednokratno) |
| **Loot Burst** | €0.99 | odmah dodaje 5 sjemenki u torbu |

- Kupovina povećava zalihu (`×N`), `Use` troši jedan komad. `Use` je neaktivan kad je zaliha 0.
- Poruke: `Merge Hint ready — open Merge arena.` · `Loot Burst: +5 seeds to bag!` · `No boosters left.`

### 2.4 Season packovi

- 4 premium sezone: Moonlit Warren €2.99 · Coral Tide Garden €3.49 · Starfall Glade €2.99 · Ember Fen €3.49.
- Opis svake: *„Unlock the … theme. Cosmetic only — no extra loot or magnet power.“*
- Kupljena: kartica piše `Owned` i tap ne radi ništa.
- **Ember Fen je `test-locked`:** prikazuje se s cijenom, ali kupovina je onemogućena u kodu (na Home se zato vodi kao **Coming soon**).
- **Iste sezone se kupuju i na Home stranici** (premium kartice s rosterom cvijeća). Shop i Home moraju pričati istu priču.

### 2.5 Kupovine pravim novcem i Restore

| Proizvod | Cijena | Opis u kodu |
|---|---|---|
| **Remove Ads** | €3.99 | gasi interstitial reklamu (danas: samo prije ponovnog pokretanja runa s loot ekrana). **Rewarded videe ne gasi** — one ostaju dobrovoljne (Pillar 2). |
| **Starter Pack** | €1.99 | jednokratno: +15 coina, +8 sjemenki djeteline, +1 Merge Hint |

- Kupljeno: dugme piše `… — Owned` i neaktivno je.
- Tok kupovine: tap → `Processing purchase…` → sistemski IAP dijalog → uspjeh ili `Purchase failed — <razlog>`.
- **Restore purchases** se vidi samo na pravom storeu (na desktopu je stub, pa je dugme skriveno). `Reset (dev)` se vidi samo u editoru.
- **Cijena je string iz storea** — može biti `€3.49`, `$2.99` ili `3,49 KM`.
- Reklame se **ne gledaju u Shopu**: rewarded video (dupli loot, revive) živi na loot ekranu poslije runa.

### 2.6 Valute i gdje se troše

| Valuta | Odakle | Gdje se troši |
|---|---|---|
| Coini | runovi, trgovina sjemenjem u Campu | **samo kozmetika u Shopu** i otključavanje sezona (500 po sezoni, na Home) |
| Sjemenke | loot runa | merge u Areni, Basket |
| Cvijeće | merge u Areni | Magnet / Loot Boost u polju sezone, otključavanje sezona |
| **Dijamanti** | rijedak pickup u runu | **nigdje** — vide se u headeru i runu, ali nemaju potrošnju |

### 2.7 Tekstovi danas (EN)

`Shop` · `Back` · `Cosmetics (coins)` · `Cosmetic-only — no gameplay advantage.` · `Boosters (consumables)` · `Buy with real money — use from inventory.` · `Season packs` · `Cosmetic themes. No extra power.` · `In-app purchases` · `Optional real-money purchases — Fair F2P.` · `Remove Ads — €3.99` · `Starter Pack — €1.99` · `Restore purchases` · `Equip` · `Equipped` · `250 coins` · `Use` · `Buy €0.99` · `Owned` · `Processing purchase…` · `Purchases restored.` · `Purchase failed — <razlog>`

**CD smije predložiti nove kratke tekstove** (tabela *novo / gdje*).

---

## 3. Trenutni raspored

Scena: `game/scenes/ui/shop_screen.tscn` → `scripts/ui/shop_screen.gd`. U hubu su `TopBar` i `ResourceBar` skriveni (valute su u headeru), pa stranica počinje odmah listom.

```
 1080 px
┌──────────────────────────────────────────────┐
│ [● 12,450] [♣ 340] [◆ 12]              [⚙]  │ HEADER 143 — zadato
╞══════════════════════════════════════════════╡ ─┐ y 0 (stranica)
│ ┌──────────────────────────────────────────┐ │  │ panel lavanda 92 %
│ │ Cosmetics (coins)                  32 px │ │  │
│ │ Cosmetic-only — no gameplay…       20 px │ │  │
│ │ Pip Blossom            28      [250 coins]│ │  │ red 100 px, dugme 168×60
│ │ Soft pink accents…     24                │ │  │ (Godot default tema)
│ │ … još 4 reda …                           │ │  │
│ └──────────────────────────────────────────┘ │  │
│ ┌──────────────────────────────────────────┐ │  │ SVE U JEDNOM SKROLU
│ │ Boosters (consumables)                   │ │  │ pozadina #B8E0F5
│ │ Merge Hint  ×0                           │ │  │
│ │ [   Use   ] [ Buy €0.99 ]           56 px│ │  │
│ └──────────────────────────────────────────┘ │  │
│ ┌──────────────────────────────────────────┐ │  │
│ │ Season packs                             │ │  │ 2 kolone × 120 px
│ │ [Moonlit    ] [Coral Tide  ]             │ │  │ font 20, „ime\ncijena“
│ │ [Starfall   ] [Ember Fen   ]             │ │  │
│ └──────────────────────────────────────────┘ │  │
│ ┌──────────────────────────────────────────┐ │  │
│ │ In-app purchases                         │ │  │
│ │ Optional real-money purchases — Fair F2P.│ │  │ status linija
│ │ [ Remove Ads — €3.99 ]                   │ │  │
│ │ Turn off interstitial ads…               │ │  │
│ │ [ Starter Pack — €1.99 ]                 │ │  │
│ │ [ Restore purchases ]  (samo na storeu)  │ │  │
│ └──────────────────────────────────────────┘ │  │
╞══════════════════════════════════════════════╡ ─┘
│ [Shop]  Journal   Home   Camp   Arena        │ FOOTER 180 — zadato
└──────────────────────────────────────────────┘
```

| Element | Danas |
|---------|-------|
| Pozadina | svijetloplava `#B8E0F5` |
| Panel sekcije | lavanda `#D4C4FA` @ 92 % (kozmetika) / krem `#FFF8F0` @ 95 % (ostalo), rub ink 10–12 %, razmak 16 |
| Naslov sekcije / hint | 32 px / 20 px |
| Red kozmetike | 100 px: ime 28 px, opis 24 px, dugme 168 × 60 (**Godot default tema**, ne `UiClickButton`) |
| Red boostera | 108 px: ime 28 + `×N`, opis, pa `Use` i `Buy` (svaki 56 px visine) |
| Season pack kartica | grid 2 × 2, min 120 px, font 20, tekst u dva reda `ime` + `cijena` / `Owned` |
| IAP sekcija | status linija 24 px, dugmad s cijenom u labeli, opisi 24 px |
| Feedback | **jedna status linija** u IAP sekciji — i za kupovinu kozmetike, i za greške, i za equip |

### 3.1 Šta danas ne štima (analiza iz koda, nisu odluke)

1. **Shop je jedina stranica huba koja nije redizajnirana** — svijetloplava pozadina, lavanda paneli i Godot default dugmad ne idu uz tamnu livadu ostalih ekrana.
2. **Kozmetika se kupuje naslijepo:** nigdje se ne vidi kako Pip Blossom ili Sunset Meadow izgledaju. Igrač plaća 250 coina za opis u jednoj rečenici.
3. **Tekst i dodir su premali:** 16–28 px tekst, dugmad 56–60 px. Minimum je 38 px teksta i 120 px dodira.
4. **Feedback je jedna linija teksta** na dnu ekrana, često van vidokruga kad kupuješ kozmetiku na vrhu. Nema potvrde na samom redu, nema animacije.
5. **Nema hijerarhije:** četiri panela u istom ritmu, a ono što igrač najčešće radi (potroši coine) nije istaknuto.
6. **Dijamanti se skupljaju, a nemaju gdje da se potroše** — u Shopu ih nema. Igrač vidi brojku u headeru koja ništa ne znači.
7. **Boosteri se mogu kupiti samo pravim novcem** i stoje odmah do `Use` dugmeta, pa se lako promaši. Nema objašnjenja koliko dugo Merge Hint traje.
8. **Season pack kartica ne pokazuje šta dobiješ** (ime + cijena u fontu 20), dok Home za iste sezone ima pun pregled sa 6 cvjetova i opisom.
9. **Ember Fen je ćorsokak:** prikazan s cijenom, a tap ne radi ništa (test-locked). Na Home je to jasno označeno kao „Coming soon“.
10. **Remove Ads ne objašnjava šta kupuješ** — „interstitial“ je žargon, a igra danas ima samo jednu takvu reklamu (prije ponovnog runa).
11. **Restore se ponaša različito** po platformi (skriveno na desktopu, vidljivo na storeu), a dizajn to nigdje ne predviđa.
12. **Kupljeno stanje je mrtvo:** `Owned` i `Equipped` su siva onemogućena dugmad; nema osjećaja da si nešto dobio ni mjesta gdje vidiš svoju kolekciju.

---

## 4. Zahtjevi

**Unaprijedi dizajn.** Trenutni izgled je samo polazna tačka. Ti si dizajner: odluči kako Shop treba izgledati da bude jasan, pošten i da se u njemu lijepo troše zarađeni coini. Radi **jedan dizajn**, bez smjerova i varijanti za biranje. Kad imaš dilemu, odluči i napiši razlog u jednoj rečenici (README § Odlučeno).

### 4.1 MORA

- **Pravila i brojevi iz §2 ostaju:** cijene, cijena u coinima, slotovi kozmetike, šta koji proizvod radi, kupovina odmah oprema, Ember Fen se ne može kupiti.
- **Shop mora izgledati kao ista igra** kao redizajnirani hub, Camp, Home i Journal.
- **Kozmetika se mora vidjeti prije kupovine** — pregled koji ne traži novi art (Pipa i livadu crta igra, Journal okvir je zlatni ram).
- **Vidljiv feedback na samom predmetu** kad se kupi, oprema ili ne uspije, ne samo linija na dnu.
- **Stanja:** može kupiti · nema dovoljno coina · kupljeno · opremljeno · kupovina u toku · kupovina neuspjela · restore (i kad ga nema) · booster zaliha 0 i > 0 · season pack nekupljen / kupljen / coming soon.
- **Dodir i tekst:** sve interaktivno ≥ **120 px**; tekst ≥ **38 px**, brojevi i cijene ≥ **44 px**.
- **Header i footer su zadati**, stranica je **1080 × 1597**; hub swipe lijevo/desno mora raditi, pa u Shopu nema horizontalnih gesti (lista se kreće gore-dolje).
- **Broj predmeta nije zakucan:** katalog može dobiti nove kozmetike, boostere i sezone — raspored ne smije pretpostaviti 5 + 2 + 4.
- **Cijena je proizvoljan string** iz storea (`€3.49`, `3,49 KM`).
- **Pillar 2 — pošten dućan:** bez lažne hitnosti, odbrojavanja, popusta, „samo danas“, loot boxeva i gacha mehanike. Jasno mora pisati da su kozmetika i sezone samo izgled, a boosteri sitna pomoć. Besplatan put ostaje vidljiv.

### 4.2 SMIJE (sloboda)

- **Cijeli raspored:** sekcije, tabovi, kartice, grid, bottom sheet za detalje predmeta — sve je otvoreno.
- **Pregled kozmetike:** veliki prikaz Pipa u odabranoj paleti, livada u tintu, Journal s okvirom.
- **Season pack kartica** smije preuzeti izgled Home premium kartice, da Shop i Home budu isti jezik.
- **Mjesto za „moje stvari“** (kupljeno i opremljeno) umjesto sivih dugmadi.
- **Novi kratki tekstovi** (EN), uključujući objašnjenje Remove Ads bez žargona.
- **Prijedlog šta raditi s dijamantima** — samo kao prijedlog na kraju README-a, ne u glavnom dizajnu (to je ekonomija).

Ideje koje traže novu mehaniku ili promjenu ekonomije (npr. coin packovi, dnevna ponuda, pretplata) navedi **odvojeno na kraju README-a** i ne crtaj ih u glavnom dizajnu.

---

## 5. Paleta i tokeni

**Koristi tokene iz ranijih paketa** — Shop ne uvodi novu paletu:

- `design_handoff_hub_chrome/HubScreen.dc.html` — header i footer (chrome `#1A241E`);
- `design_handoff_home_v2/` + `game/scripts/visual/ui_stage.gd` — Home stranica (`#243329`, Nunito, kartice i tokeni);
- `design_handoff_camp/CampScreen.dc.html` — Camp (`#2E4733`, zlatni okvir, tamni well);
- `design_handoff_journal/godot/ui_journal.gd` — Journal (krem stranica `#FFF8F0`, rarity boje, NEW pilula).

Ključne boje: peach `#FFB88C` (glavna akcija) · mint `#A8E6CF` · lavanda `#D4A5FF` · coin gold `#FFD56B` · UI gold `#E8C44A` · cijena `#FFE8B8` · krem `#FFF8F0` · rub aktivnog `#FFF6D6` · ink `#2D3436` · well `#22342A` · roze „novo“ `#FFCCD5`.

Mood boje sezona (za pack kartice): Moonlit Warren `#3D3A6B` · Coral Tide `#E8A090` · Starfall Glade `#6B5B95` · Ember Fen `#C45C26`.

**Komponente koje već postoje** (koristi ih gdje pašu, prenos je onda brz): `CampButton` (dugme s naslovom i podnaslovom), `CampArtFrame` (zlatni okvir + tamni well), `HomeSeasonCard` (premium kartica sezone), `HomeBar` / barovi napretka, čip ★☆☆, `UiJournal` red s tri slota.

**Font:** Nunito (igra ga ima od Home v2).

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- **Lako:** `StyleBoxFlat` (ravna boja + alpha, radius, border, jedna sjena) · `VBox` / `HBox` / `GridContainer` / `ScrollContainer` · tween (pozicija, skala, alpha, boja, visina) · ravni oblici (`draw_*`) · postojeći SVG/PNG.
- **Izbjegavati:** blur i glow shadere, gradijente na panelima, teške čestice, maske i izreze (osim kao PNG), 3D, stalno pulsiranje mnogo elemenata (na emulatoru je 29 pulsirajućih elemenata palo na 10 fps).
- **Sistemski IAP dijalog** crta store, ne mi — dizajniraj samo stanje prije, „u toku“ i poslije.
- **Layout:** artboard **1080 × 1920**, sve mjere u px te baze (prenos 1:1). Shop je **1080 × 1597** između headera (143) i footera (180). 1 dp ≈ 2,75 px → dodir 44 pt ≈ **120 px**, tekst 14 pt ≈ **38 px**.

---

## 7. Isporuka — jedan dizajn, zip spreman za Godot

**Jedan dizajn.** Bez smjerova, alternativa i prikaza za poređenje. Onoliko artboarda koliko treba da se vide stanja, ne više.

### 7.1 Stanja (P1, obavezno)

1. **Glavni ekran** 1080 × 1920 s headerom i footerom, sredina igre: 12 450 coina, kozmetika dijelom kupljena (Golden Album opremljen, Pip Sky u vlasništvu), boosteri `×0` i `×2`, nijedna premium sezona kupljena.
2. **Pregled kozmetike** prije kupovine (Pip skin i tint livade) i **trenutak kupovine** (2 kadra: kupljeno → opremljeno).
3. **Nema dovoljno coina** — kako izgleda predmet i šta piše.
4. **Boosteri:** zaliha 0, zaliha > 0, kupovina u toku.
5. **Season packovi:** nekupljen, kupljen (`Owned`), **Coming soon** (Ember Fen).
6. **Real-money sekcija:** Remove Ads i Starter Pack — dostupno i kupljeno; **Restore** vidljiv (store) i skriven (desktop).
7. **Greška kupovine** (`Purchase failed`).
8. **Prelaz** na stranicu (swipe s Journala) i skrol dugačke liste.
9. **Tabela animacija** (šta, trajanje, easing) i **lista asseta**.

### 7.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom. Ako zip ne može, zalijepi u chat sadržaj JSON-a, `.gd` i oba README-a.

```
design_handoff_shop/
  README.md                 šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica svaka)
                            · § Šta se briše · § Ideje van zadatka
  design/
    ShopScreen.dc.html      cijeli ekran; prop `scene` bira stanje iz 7.1
    Shop Specs.dc.html      sva stanja na jednom kanvasu + spec komponenti
                            + tabela animacija + asset lista
    HubScreen.dc.html       zadati header/footer (kopija, ne mijenja se)
    support.js · icons/
  assets/                   samo novi fajlovi koje treba exportati (SVG/PNG)
  godot/
    shop_export.json        ekran kao podaci, ista šema kao
                            design_handoff_home/godot/home_export.json (v1 paket):
                            meta · tokens (samo novi/promijenjeni) · layout (rect svakog
                            bloka) · components (child mjere + stanja) · scenes (stanja
                            s tačnim brojevima) · animations · strings_en · assets ·
                            godot_map (sloj → node iz §10) · smoke_tests · decisions
    ui_shop.gd              StyleBoxFlat fabrike i konstante; koristi postojeće
                            UiStage / UiCamp / UiJournal nazive, dodaje samo nove
    shop_tree.txt           node tree s veličinama (kao design_handoff_journal)
    README.md               red prenosa u koracima + šta se briše
```

**Imena slojeva** (za mapiranje na Godot, §10):

- **stranica:** `ShopPage`, `ShopHeaderRow`, `SectionTitle`;
- **kozmetika:** `CosmeticCard`, `CosmeticPreview`, `PriceTag`, `OwnedBadge`, `EquipButton`;
- **boosteri:** `BoosterCard`, `BoosterCount`, `UseButton`, `BuyButton`;
- **sezone:** `SeasonPackCard`, `ComingSoonTag`;
- **novac:** `IapCard`, `RestoreButton`, `PurchaseStatus`, `PurchaseToast`.

## 8. Ne tražimo

- Promjenu cijena, ekonomije i sadržaja kataloga; nove proizvode; coin packove.
- Sistemski IAP dijalog, ekrane storea, reklamni SDK.
- Ostale stranice (Home, Camp, Arena, Journal), Run i loot ekran.
- Crtanje lika Pipa, cvijeća i sezonskih ilustracija — koristi postojeće.

---

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim redizajn jednog ekrana mobilne igre: SHOP.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Tvoja referenca je fajl u repou (master):
  docs/04-experience/design-drafts/shop-cd-brief.md
Pročitaj ga cijelog: pravila i cijene (§2), današnji raspored (§3), šta ne
štima (§3.1), šta mora a šta smiješ (§4), tokeni (§5), tehnika (§6) i
isporuka (§7). §10 je za kasniji prenos i možeš ga preskočiti. Ako se ovaj
prompt i fajl razlikuju, važi fajl.

Shop je posljednja stranica huba koja nije redizajnirana. Mora izgledati kao
ista igra kao ekrani koje si već radio:
  design_handoff_hub_chrome/HubScreen.dc.html   (header + footer, zadato)
  design_handoff_home_v2/design/SeasonStage.dc.html (Home, kartice sezona)
  design_handoff_camp/CampScreen.dc.html        (Camp, zlatni okvir + well)
  design_handoff_journal/design/JournalScreen.dc.html (Journal, krem stranica)
  game/scripts/visual/ui_stage.gd               (tokeni i Nunito u igri)
  game/scripts/visual/ui_journal.gd             (tokeni Journala)

TVOJ ZADATAK: unaprijedi dizajn Shopa. Ti si dizajner — imaš punu slobodu u
rasporedu, kartici predmeta, pregledu kozmetike i načinu na koji se potvrđuje
kupovina. Cijene, katalog i pravila su fiksni.

JEDAN DIZAJN: ne pravi smjerove, varijante ni alternative za biranje. Kad
imaš dilemu, odluči sam i napiši razlog u jednoj rečenici u README
§ Odlučeno. Ne čekaj moju potvrdu.

ŠTA SHOP IMA (detalji i cijene u §2):
- KOZMETIKA ZA COINE (5 predmeta, 120–250 coina): 2 Pip skina, 2 tinta
  livade, zlatni okvir Journala. Jedan po slotu; kupovina odmah oprema.
  Čisto vizuelno, bez prednosti u igri.
- BOOSTERI (pravi novac, €0.99): Merge Hint (označi sljedeći par u Areni) i
  Loot Burst (+5 sjemenki). Kupovina puni zalihu, "Use" troši jedan.
- SEASON PACKOVI (€2.99–€3.49): 4 premium sezone, samo tema. Ember Fen se
  još ne može kupiti (coming soon). Iste sezone se kupuju i na Home.
- PRAVI NOVAC: Remove Ads €3.99 (gasi jednu interstitial reklamu; rewarded
  videi ostaju dobrovoljni) i Starter Pack €1.99 (+15 coina, +8 sjemenki,
  +1 booster). Restore purchases postoji samo na pravom storeu.

GLAVNI PROBLEMI DANAS (§3.1):
1. Shop je jedini ekran koji nije redizajniran: svijetloplava pozadina,
   lavanda paneli, Godot default dugmad.
2. Kozmetika se kupuje naslijepo — nema pregleda kako izgleda.
3. Tekst 16–28 px, dugmad 56–60 px.
4. Feedback je jedna linija teksta na dnu ekrana.
5. Dijamanti se skupljaju u runu, a nemaju gdje da se potroše.
6. Season kartica ne pokazuje šta dobiješ, a Ember Fen izgleda kupljivo pa
   tap ne radi ništa. "Owned" i "Equipped" su mrtva siva dugmad.

MORA:
- Cijene, katalog i pravila iz §2 ostaju.
- Kozmetika se vidi prije kupovine (bez novog arta — Pipa i livadu crta
  igra, Journal okvir je zlatni ram).
- Potvrda kupovine na samom predmetu, ne samo linija na dnu.
- Sva stanja: može kupiti / nema coina / kupljeno / opremljeno / kupovina u
  toku / neuspjela / restore (i kad ga nema) / booster 0 i >0 / sezona
  nekupljena, kupljena, coming soon.
- Sve interaktivno ≥ 120 px; tekst ≥ 38 px, cijene ≥ 44 px; EN tekst.
- Header (143) i footer (180) zadati; stranica 1080 × 1597 između njih.
  Bez horizontalnih gesti (hub se lista lijevo/desno).
- Broj predmeta nije zakucan (katalog može rasti).
- Cijena je string iz storea ("3,49 KM").
- Fair F2P: bez lažne hitnosti, odbrojavanja, popusta, loot boxeva i gacha;
  jasno da su kozmetika i sezone samo izgled.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 × 1920, sve u px
te baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna
sjena. Animacije = tween. Bez blura, gradijenata na panelima, teških
čestica, 3D-a i stalnog pulsiranja mnogo elemenata. Sistemski IAP dijalog
crta store — crtaš samo prije / u toku / poslije.

ISPORUKA (§7): stanja iz §7.1 i paket TAČNO po strukturi iz §7.2 —
design_handoff_shop/ s README.md, design/ (ShopScreen.dc.html, Shop
Specs.dc.html, HubScreen.dc.html, support.js, icons/), assets/ i godot/
(shop_export.json u istoj šemi kao home_export.json, ui_shop.gd,
shop_tree.txt, README.md). Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s
cijelim folderom.

IMENA SLOJEVA: ShopPage, ShopHeaderRow, SectionTitle, CosmeticCard,
CosmeticPreview, PriceTag, OwnedBadge, EquipButton, BoosterCard,
BoosterCount, UseButton, BuyButton, SeasonPackCard, ComingSoonTag, IapCard,
RestoreButton, PurchaseStatus, PurchaseToast.

NE RADI: promjenu cijena i ekonomije, nove proizvode, coin packove,
sistemski IAP dijalog, ostale stranice huba, Run i loot ekran, crtanje Pipa
i cvijeća. Ideje van zadatka (npr. šta s dijamantima) navedi odvojeno na
kraju README-a.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `ShopPage` | `scenes/ui/shop_screen.tscn` (`Dim`, `RootVBox`, `MainScroll/MainContent`) + `scripts/ui/shop_screen.gd` | u hubu su `TopBar` i `ResourceBar` skriveni (`set_meta_hub_mode`); `refresh_for_meta_hub()` osvježava |
| `CosmeticCard` / `PriceTag` / `EquipButton` | `shop_cosmetic_row.gd` (`ShopCosmeticRow`), gradi se u `_ensure_shop_lists_built()` | podaci: `GameState.get_cosmetic_shop_entries()`, `CosmeticCatalog.get_title/description/coin_cost/slot`, `owns_cosmetic`, `is_cosmetic_equipped`, `buy_cosmetic_with_coins`, `equip_cosmetic` |
| `CosmeticPreview` | novo | Pip crta `PipDraw` + `CosmeticCatalog.get_pip_palette()`; tint livade `get_meadow_modulate()`; Journal okvir `UiJournal.golden_frame_style()` |
| `BoosterCard` / `BoosterCount` / `UseButton` / `BuyButton` | `shop_booster_row.gd` (`ShopBoosterRow`) | `MonetizationConfig.all_booster_ids/booster_sku`, `GameState.get_booster_count`, `use_booster`, `IAPManager.purchase` |
| `SeasonPackCard` / `ComingSoonTag` | `season_pack_card.gd` (`SeasonPackCard`) u `%SeasonPacksGrid` | `SeasonCatalog.paid_defs()`, `IAPManager.owns_product`, `get_price_label`, `is_busy`, `GameState.is_test_locked_season` |
| `IapCard` / `RestoreButton` / `PurchaseStatus` | `IapPanel` u sceni + `_refresh_iap_section()` | `MonetizationConfig.SKU_REMOVE_ADS` / `SKU_STARTER_PACK`, `IAPManager.is_stub_mode`, `restore_purchases`, `reset_purchases_for_dev` (samo editor) |
| `PurchaseToast` | novo (danas samo `StatusLabel`) | signali `IAPManager.purchase_completed` / `purchase_failed` / `restore_completed` / `catalog_updated` |
| valute u headeru | `meta_hub_controller._refresh_top_bar()` | Shop javlja promjenu preko `call_group("meta_hub", "refresh_top_bar")` |

**Smoke testovi koje prenos mora proći ili svjesno ažurirati:** `shop_open_smoke` (2-kolonski grid, 4 packa), `shop_cosmetic_buy_smoke`, `shop_smoke`, `meta_hub_flow_smoke`, `swipe_snap_smoke`, `diamond_wallet_smoke`.

**Poznati problemi nađeni pri pisanju briefa:**

1. **`shop_nav_smoke` visi** (Godot proces ne izađe) — stari kvar, treba ga popraviti ili zamijeniti pri prenosu.
2. **Redovi Shopa koriste Godot `Button`**, ne `UiClickButton` / `CampButton` — jedino mjesto u igri s default temom.
3. **Dijamanti nemaju potrošnju** (`wallet_diamonds` se samo puni u runu).
4. **Ember Fen** se u Shopu prikazuje kao obična nekupljena sezona s cijenom, a kupovina je blokirana (`TEST_LOCK_PAID_ID`).
5. **`CosmeticCatalog.get_journal_title_color()`** je ostatak starog Journala (naslov je sada Label u inku) — može se ukloniti.
6. **Starter Pack daje 15 coina**, a najjeftinija kozmetika košta 120 — vrijedi provjeriti poruku „+15 coins“ u dizajnu da ne zvuči kao mnogo.

**Gotovo kad (implementacija):**

- [ ] Shop stane u 1080 × 1597; sve interaktivno ≥ 120 px, tekst ≥ 38 px
- [ ] Kozmetika ima pregled i jasno stanje kupljeno / opremljeno
- [ ] Kupovina, greška i restore imaju vidljiv feedback na mjestu radnje
- [ ] Boosteri pokazuju zalihu i šta rade
- [ ] Season packovi izgledaju kao na Home; Ember Fen je Coming soon
- [ ] Restore se pojavljuje samo van stub moda
- [ ] Hub swipe radi; lista se kreće samo vertikalno
- [ ] Smoke: sve iz liste gore (+ popravljen ili zamijenjen `shop_nav_smoke`)

---

## Implementacija (2026-09-24)

Izvor: `design_handoff_shop/` (README s 22 odluke, `godot/ui_shop.gd`, `godot/shop_export.json`, `godot/shop_tree.txt`, `design/*.dc.html`). Jedan dizajn, bez varijanti.

| Fajl | Šta |
|------|-----|
| `scripts/visual/ui_shop.gd` (`UiShop`) | paste-ready iz paketa, nepromijenjen: boje, mjere, stanja (`cosmetic_mode`, `buy_mode`, `season_mode`, `use_mode`, `fail_text`, `price_font_px`) i StyleBoxFlat fabrike |
| `scripts/visual/ui_shop_buttons.gd` (novo) | dugmad za pravi novac: idle / „Waiting for store…“ s pulsom / zatamnjeno „one purchase at a time“ |
| `scripts/ui/shop_cosmetic_preview.gd` (novo) | pregled „Now / With it“ — staza i Pip iz `UiRun` × meadow modulate × sezona, ili stranica Albuma sa zlatnim ramom |
| `scripts/ui/shop_cosmetic_card.gd` (novo, zamjenjuje `shop_cosmetic_row.gd`) | kartica kozmetike: pregled, ime, opis, red akcije i pet stanja (buy · short · confirm · owned · equipped) |
| `scripts/ui/shop_purchase_status.gd` (novo) | poruka na kartici: ok (2,4 s), fail (do sljedećeg tapa), pending |
| `scripts/ui/shop_price_tag.gd` (novo) | cjenovnik za store string; preko 7 znakova font pada na 44 px, tag raste |
| `scripts/ui/shop_jump_chip.gd` (novo) | chip u sticky redu (`HubPressable`), scroll-spy |
| `scripts/ui/shop_booster_row.gd` | booster kartica: disk s ikonom, zaliha, Use / Go to Arena ↗ / Bag is full, cijena i Buy |
| `scripts/ui/season_pack_card.gd` | premium sezona: mood boja, roster 3 × 2, tagline, „Get …“ / „Play it on Home ↗“ / Coming soon (više nije `UiClickButton`) |
| `scenes/ui/shop_screen.tscn` + `scripts/ui/shop_screen.gd` | pozadina `#2E4733`, jedan skrol sa 4 sekcije, sticky red chipova, toast; obrisani TopBar, ResourceBar, lavanda paneli i `StatusLabel` |
| `scripts/visual/pip_draw.gd` | `draw_pip(..., palette_override := {})` — jedini API dodatak iz paketa |
| `scripts/meta/meta_hub_controller.gd` | `show_coin_spend_pop(n)` (−N ispod coin chipa) i Shop više ne skriva nepostojeći TopBar |
| smoke | novi `shop_booster_guard_smoke`; prepisani `shop_open_smoke`, `shop_cosmetic_buy_smoke`; `meta_hub_flow_smoke` prati nove kartice; `shop_nav_smoke` popravljen (statička `GameState` referenca ga je vješala) |

**Odstupanja od paketa:**

1. `CoinSpendPop` crta hub (`show_coin_spend_pop`), jer je Shop stranica klipovana i ne može crtati preko headera; polazi ispod coin chipa umjesto s fiksnih (150, 132).
2. Kartica kozmetike naraste na ~290 px umjesto 284 kad se opis prelomi u dva reda — naš font je širi od Nunita (isto rješenje kao u Journalu).
3. Roster sezone su i dalje tačke u wellu (paket to i predviđa dok nema arta za 42 tipa).
4. Zlatni ram u pregledu Albuma je pravougaoni okvir od 10 px, usklađen s bojom iz Journala (`#E8C44A`); Journal svoj ram crta preko cijele stranice.
5. Reklamna poruka i `ResetDevButton` ostaju kako su bili; `Reset (dev)` se i dalje vidi samo u editoru uz stub IAP.

**Otvorena pitanja iz paketa:** brief je sada na `master`; tokeni §5 i lista stanja §7.1 su provjereni pri prenosu. Pip skin u runu ostaje `PipDraw` placeholder.


## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-24 | CD isporuka prenesena: jedan dizajn, 22 odluke iz paketa (dvotapna kupovina za coine, pregled kozmetike, sticky chipovi, poruke na kartici, „Play it on Home ↗“ za kupljenu sezonu, Ember Fen bez cijene). |
| 2026-09-23 | Brief za Shop napisan po formatu Home polja i Journala: CD dobija slobodu, isporučuje **jedan dizajn** bez varijanti i **zip paket** (`design_handoff_shop/` s `design/`, `assets/`, `godot/`). Ekonomija i katalog su fiksni; dizajn mora uvesti pregled kozmetike i vidljiv feedback kupovine. |

## Otvorena pitanja (nakon CD-a)

- [ ] Šta s dijamantima (prijedlog CD-a, van glavnog dizajna)?
- [ ] Ostaje li `SeasonPackCard` dijeljena sa Shopom ili Shop preuzima izgled Home kartice?
- [ ] Da li Shop dobija „moje stvari“ sekciju (kupljeno i opremljeno)?

## Povezano

- [[../_index|Iskustvo]]: roditeljski hub
- [[hub-header-footer-cd-brief]]: okvir u koji Shop ulazi
- [[home-season-select-cd-brief]]: premium sezone i njihove kartice
- [[home-field-cd-brief]]: isti format briefa (jedan dizajn + zip)
- [[journal-cd-brief]]: Golden Album kozmetika; format paketa
- [[camp-cd-brief]]: `CampButton`, `CampArtFrame`, vizuelni jezik
- [[shop-izvjestaj|shop-izvjestaj]]: izvještaj o prenosu (2026-09-24)
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]]: § Shop
- [[../../01-vision/design-pillars|design-pillars]]: Pillar 2 (Fair F2P)
- [[../art-direction|art-direction]] · [[../pristupacnost|pristupačnost]]
