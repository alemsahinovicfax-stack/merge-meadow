---
type: dizajn
status: draft
milestone: "—"
tags: [dizajn, ui, home, sezone, claude-design, mockup]
povezano:
  - hub-header-footer-cd-brief
  - merge-arena-cd-brief
  - camp-cd-brief
  - journal-cd-brief
  - seeds-flowers-cd-brief
  - spec-vertical-slice
  - ekonomija-brojevi
  - design-pillars
  - art-direction
  - pristupacnost
ai_sažetak: "Home (3. stranica huba) — SAMO scena biranja sezone (SeasonStage: free/premium trake, roster, unlock poster, Browser, Play, Daily gift): pravila iz koda koja ostaju fiksna, raspored i mjere, šta ne štima, šta CD mora a šta smije, gotov prompt i mapa za prenos u Godot. Polje sezone (SeasonField) je van ovog briefa."
---

# Home — biranje sezone — Claude Design brief i referenca

> **Status: priprema dizajna — ne mijenja kod.** Obuhvata **samo scenu biranja sezone** (Home dok polje nije otvoreno). **Polje sezone** (SeasonField — livada s cvijećem, Pip, korpa, Magnet / Loot Boost, Play Endless, dugme `Seasons` nazad) dobija **poseban brief kasnije**; ovdje se crta samo *ulaz* u polje. Header/footer (2026-09-11), Merge Arena (2026-09-12) i Camp (2026-09-16) su već redizajnirani i u igri — Home treba da im se vizuelno pridruži. *Ažurirano 2026-09-18: usklađeno s Camp redizajnom (tok Camp → Home, `UnlockProgress` više nije dijeljen).*

**Home** je prva stranica koju igrač vidi: ovdje bira **u kojoj sezoni igra**, vidi koliko mu fali do sljedeće besplatne sezone i otključava je, pregleda premium sezone, i odavde kreće u igru. Home ima dva režima:

| Režim | Šta je | Ovaj brief |
|-------|---------|------------|
| **Biranje sezone** (SeasonStage) | Trake sa karticama sezona, roster cvijeća, unlock poster, Browser, Play, Daily gift | ✅ dizajnira se |
| **Polje sezone** (SeasonField) | Otvara se tapom na otključanu sezonu: livada, Pip, cvijeće, korpa, upgradei, Play / Play Endless / Seasons | ❌ kasnije, poseban brief |

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl iz repoa po putanji, ili kao prilog (§1–§8) | Pravila koja važe, mjere, trenutno stanje, sloboda i ograničenja |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §5, §10 | Tačne današnje vrijednosti, poznati problemi, mapa "CD sloj → Godot node" |

Postupak: zalijepi prompt iz §9 u CD. CD čita repo direktno, ali samo **po putanji** (ne može pretraživati foldere), pa su sve putanje navedene u promptu: ovaj fajl, `design_handoff_hub_chrome/HubScreen.dc.html` (okvir), `design_handoff_merge_arena/SeedChip.dc.html` i `design_handoff_camp/CampScreen.dc.html` (vizuelni jezik) — Home treba da izgleda kao ista igra. Ako CD ipak ne može pročitati fajl, priloži ga ručno. Kad CD završi, izvezi `.dc.html` + asset fajlove i daj ih agentu.

---

## 1. Kontekst (za CD)

- **Merge Meadow** — casual F2P merge/runner hibrid za mobitel, **portrait**. Flat 2D cartoon, pastel, meki outline, bez pixel-arta, bez 3D ([[../art-direction|art-direction]]). Mood: *cozy meadow*.
- **Sezona** = tema igre: određuje koje sjemenke padaju u runu, ton pozadine runa i polje na Home. Svaka sezona ima **6 cvjetova** (3 × ★1, 2 × ★2, 1 × ★3).
- **8 sezona:**
  - **4 besplatne, linearno:** Country Bloom (otključana od starta) → Frost Orchard → Lantern Meadow → Amber Canopy. Svaka sljedeća traži **500 coina + 20 ★3 cvjetova prethodne sezone** (Frost traži Harvest Pumpkin iz Country Blooma itd.). Cvijeće se dobija merge-om u Areni.
  - **4 premium (IAP):** Moonlit Warren, Coral Tide Garden, Starfall Glade, Ember Fen — kupuju se pravim novcem (danas placeholder cijene €2.99 / €3.49).
- Home je **3. stranica** swipe meta-huba (Shop · Journal · **Home** · Camp · Arena) i **početna** stranica.
- Camp vodi ovamo. Na vrhu Campa je kartica **sljedeće besplatne sezone** (coini + ★3 cvijet s trakama, dugme Unlock):
  - **tap na karticu** („Details ↗") → Home, traka besplatnih sezona, **fokus na tu sezonu** (ako je polje sezone bilo otvoreno, zatvara se);
  - **Unlock u Campu** troši 500 coina + 20 ★3 **odmah, u Campu** (kratak burst na kartici, ~0,9 s), pa prebacuje na Home s fokusom na **upravo otključanu** sezonu. Home tada **ne** ponavlja trenutak otključavanja — dočeka sezonu koja je već otključana.
  - Trenutak otključavanja na Home se vidi samo kad igrač otključa **na Home**.
- **Pillar 2** ([[../../01-vision/design-pillars|design-pillars]]): *Fair F2P — core je uvijek besplatan.* Premium sezone su opcionalni sadržaj; besplatni put mora uvijek biti vidljiv i dostižan igrom. **Pillar 3:** napredak (koliko sezona imaš, koliko fali do sljedeće) treba da se *vidi i osjeća*.

---

## 2. Kako biranje sezone radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled, raspored i geste**, ne ekonomiju. Izvor: `season_stage.gd`, `season_browser.gd`, `season_unlock_gate.gd`, `season_roster_panel.gd`, `season_pack_card.gd`, `main_menu.gd`, `economy/seasons.gd`, `seasons.json`.

### 2.1 Pojmovi

| Pojam | Značenje |
|-------|----------|
| **Aktivna** sezona | U njoj se igra (run, polje). Uvijek otključana/kupljena. Tačno jedna. |
| **Fokus** | Sezona koja je trenutno u centru pregleda. Ne mora biti aktivna. |
| **Otključana** (free) / **kupljena** (premium) | Može se igrati. |
| **Sljedeća zaključana** (next lock) | Prva neotključana besplatna — jedina zaključana free sezona koja se smije fokusirati i otključati. |
| **Dalje zaključane** (free) | Iza next locka — ne mogu se ni fokusirati ni otključati (linearni put). |
| **Coming soon** | Ember Fen je danas zaključan i za kupovinu (`test-locked`). |

### 2.2 Besplatne sezone

- Redoslijed je fiksan 1 → 4. Fokus ide samo preko otključanih + **next locka**; pokušaj dalje = odbijanje (bounce).
- Fokus na otključanu sezonu je automatski i **odabir** (postaje aktivna); fokus na next lock **ne** mijenja aktivnu.
- **Next lock u centru → unlock poster:** coini `320 / 500` + bar, ★3 cvijet prethodne sezone (slika, ★★★, ime, `12 / 20` + bar), dugme **Unlock** — zlatno i aktivno samo kad su **oba** uslova ispunjena, inače sivo i ne reaguje.
- **Unlock na licu mjesta:** troši 500 coina + 20 ★3 cvjetova, sezona postaje aktivna, pokaže se njen roster, sljedeća postaje next lock. Header se odmah osvježi.
- Kad su sve 4 otključane, next lock ne postoji (poster nestaje).

### 2.3 Premium sezone

- Sve 4 se mogu fokusirati i pregledati **i prije kupovine** (roster od 6 cvjetova se prikazuje).
- Nekupljena: 🔒 + ime + **cijena** (string iz store-a — može biti `€3.49`, `$2.99`, `3,49 KM`…). Kupovina ide sistemskim IAP dijalogom; dok traje, dugme je zauzeto (`busy`).
- Kupljena: ponaša se kao otključana free — bira se i igra. Kupovina odmah postavlja tu sezonu kao aktivnu.
- Ember Fen: danas se ne može kupiti (**coming soon**).

### 2.4 Dvije trake (današnje rješenje — nije obavezno)

- Gore **Premium** traka, dolje **Free** traka. Jedna je "hero" (velika, 4 dijela visine), druga "preview" (1 dio). Tap na preview traku ih zamijeni (tween 0,25 s). Home pamti koja je hero.
- Svaka traka pokazuje 3 kartice: lijeva · **centar** (fokus) · desna.

### 2.5 Geste i tapovi (danas)

| Radnja | Rezultat |
|--------|----------|
| Horizontalni swipe na hero traci | Sljedeća / prethodna sezona (fade 0,25 s, ne klizanje) |
| Tap na bočnu karticu | Pomak ka njoj |
| Tap na centar — otključana | **Otvara polje sezone** (SeasonField) |
| Tap na centar — zaključana (next lock ili premium) | Otvara **Browser** |
| Tap na preview traku | Zamjena traka |
| Swipe dolje | Odaberi fokusiranu (ako je otključana) ili zadnju otključanu kao aktivnu |
| Swipe gore | Bounce (ništa) |

- **Konflikt s hubom:** cijela površina scene danas **blokira hub swipe** (swipe mijenja sezonu, ne tab). Hub se na Home lista samo izvan nje: gornjih ≈ 380 px stranice, Play red i bočne margine od 48 px.

### 2.6 Play (ispod scene)

- Na sceni biranja **Play ne pokreće run**: ako je centar otključan → otvara polje (tek tamo Play pokreće run); ako nije → vraća traku na aktivnu sezonu. Do runa su danas **3 koraka** (Home → polje → Play).
- U polju: `Play` → run, `Play Endless`, `Seasons` → nazad na biranje (polje — kasniji brief).

### 2.7 Browser (overlay "Seasons")

- Pregled svih sezona: red **Free** (4) i red **Premium** (4).
- Free: otključana → odaberi i zatvori; next lock → fokusiraj i zatvori; dalje zaključane → trepne (ništa).
- Premium: kupljena → odaberi i zatvori; nekupljena → IAP kupovina (po uspjehu se zatvara).
- Zatvara se `Close` ili tapom na zatamnjenje.

### 2.8 Daily gift (gornji lijevi ugao)

- Vidljiv tek nakon tutoriala. Spremno: `Daily gift` / `Tap to open` (pulsira) → tap → nagrada (**+8 coina + 3 sjemenke**, `OK`). Preuzeto: `Daily gift` / `Back tomorrow` (sivo).
- Funkcija ostaje; CD smije premjestiti i redizajnirati karticu.

### 2.9 Tekstovi danas (EN)

`Play` · `Seasons` · `Close` · `Free` · `Premium` · `Unlock` · `Owned` · `Daily gift` · `Tap to open` · `Back tomorrow` · `OK` · 🔒 · brojevi `320 / 500`, `12 / 20` · cijene `€2.99` / `€3.49` · tutorial: `First run: swipe left/right to change lanes.`

**Imena sezona** (najduže `Coral Tide Garden`, 17 znakova) i **imena cvjetova** (najduže `Dusk Firefly Grass`, 18 znakova) — puni roster u `game/data/seasons/seasons.json`.

**Taglines postoje u podacima, ali se nigdje ne prikazuju** — CD ih smije koristiti:

| Sezona | Tagline |
|--------|---------|
| Country Bloom | Warm fields, soft petals, home pastures. |
| Frost Orchard | Crisp air, silver blossom. |
| Lantern Meadow | Dusk lights among tall grass. |
| Amber Canopy | Warm late-season light through high leaves. |
| Moonlit Warren | Night blooms under a quiet moon. |
| Coral Tide Garden | Salt breeze and seashell petals. |
| Starfall Glade | Petals that catch the night sky. |
| Ember Fen | Low firelight over marsh blooms. |

**CD smije predložiti nove kratke tekstove** (tabela *novo / gdje*), npr. `Playing now`, `Coming soon`, `Need 180 more coins`.

---

## 3. Trenutni raspored (uvod u dizajn)

Scene: `game/scenes/main_menu.tscn` (Home stranica) → `HomeColumn/SeasonStage` (`game/scenes/ui/season_stage.tscn`) · Browser: `game/scenes/ui/season_browser.tscn`

```
 1080 px
┌──────────────────────────────────────────────┐
│ [● 12,450] [♣ 340] [◆ 12]              [⚙]  │ HEADER 143 px — zadato
╞══════════════════════════════════════════════╡ ─┐ y 0 (stranica)
│ [🎁 Daily gift ]                             │  │ 336 × 104 @ (24, 24)
│ [   Tap to open]                             │  │
│                                              │  │ ≈ 250 px prazno
│   ┌────────┐ ┌──────────┐ ┌────────┐         │  │ y 380 — PREMIUM (preview ≈ 216)
│   │🔒 Moon │ │🔒 Coral  │ │🔒 Star │  14–16px │  │
│   └────────┘ └──────────┘ └────────┘         │  │
│   ─────────────── separator 6 ─────────────  │  │
│   ┌────────┐ ┌──────────┐ ┌────────┐         │  │ FREE (hero ≈ 863)
│   │Country │ │  Frost   │ │🔒      │         │  │ HOME STRANICA 1080 × 1597
│   │ Bloom  │ │ Orchard  │ │Lantern │  20 px  │  │
│   │        │ │  28 px   │ │Meadow  │         │  │ scena 984 × ≈1085
│   │        │ │┌────────┐│ │        │         │  │ blokira hub swipe
│   │        │ ││★ ico … ││ │        │         │  │ roster 6 × 56 px
│   │        │ ││★ ico … ││ │        │         │  │ (ili unlock poster
│   │        │ ││★★★ …   ││ │        │         │  │  za next lock)
│   └────────┘ └──────────┘ └────────┘         │  │
│              [ ▶  Play ]                      │  │ 320 × 96
╞══════════════════════════════════════════════╡ ─┘
│ Shop   Journal   [Home]   Camp   Arena       │ FOOTER 180 px — zadato
└──────────────────────────────────────────────┘
```

### 3.1 Elementi danas

| Element | Danas |
|---------|-------|
| Stranica | 1080 × 1597; tamna livada `#243329`; dva tamnozelena "brežuljka" u donjim uglovima (50–55 % alpha) |
| Daily gift | 336 × 104 @ (24, 24); `#FFC77A` @ 95 %, border 3 px amber, radius 16; škrinja 72 px; naslov + caption; preuzeto = sivo-zeleno |
| Scena (SeasonStage) | 984 × ≈ 1085 px (bočne margine 48, od y = 380 do Play reda); cijela površina hvata geste |
| Trake | hero : preview = 4 : 1 (≈ 863 / ≈ 216 px; min 300 / 110); separator 6 px, tamni @ 35 % |
| Kartice u traci | 3 po traci, širine 1 : 1.35 : 1 (≈ 289 / 390 / 289 px), razmak 8; ravna **mood boja** sezone, radius 16, padding 12; ime centrirano |
| Font imena | hero: centar 28, strane 20 · preview: centar 16, strane 14 px |
| Zaključana kartica | mood 25 % tamnija, 72 % alpha; `🔒` + ime (premium: + cijena) |
| Aktivna sezona | border 5 px cream `#FFF6D6` + tanka ink sjena `#1A1A14` |
| Roster (u hero centru) | panel ≈ 85 % širine kartice, donjih ≈ 356 px; 6 redova × 56 px: T3 ikona 52, ★ 18 px, ime 22 px; okvir = mood tint @ 28 %, radius 12, border 1 px |
| Unlock poster (next lock) | bez okvira, donjih 40 % kartice: coin 40 px, `0 / 500` 18 px, bar 10 px, linija, ★3 cvijet 92 px, ★★★ 16 px, ime 16 px, `0 / 20` 18 px, bar 10 px; Unlock 48 px, font 26, `gold` / `subtle` |
| Play | 320 × 96, `primary` (peach), 40 px + play ikona; razmak 12 iznad |
| Browser | zatamnjenje 58 %; panel 840 × 720, warm white, radius 20; `Seasons` 28 px; `Close` 120 × 48; `Free` / `Premium` 20 px; kartice 168 × 120, font 20 (otključana peach, zaključana warm white, premium kupljena peach, nekupljena lavanda + cijena); redovi scrollaju vodoravno |

Varijante dugmadi (`UiClickButton`): `primary` peach `#FFB88C` · `accent` lavanda `#D4A5FF` · `subtle` warm white `#FFF8F0` · `gold` `#E8C44A` · `secondary` mint `#A8E6CF`.

### 3.2 Šta danas ne štima (zapažanja iz koda, nisu odluke)

1. **Sezona nema identitet** — kartica je obojeni pravougaonik s imenom. Nema ilustracije (`thumbnail_path` je prazan za svih 8), tagline se ne koristi, roster je jedini sadržaj.
2. **Tekst premali:** imena 14–28 px (preview 14 px ≈ 5 sp), zvjezdice 16–18 px, brojevi na posteru 18 px.
3. **Skrivene geste:** swipe dolje = odaberi, tap na preview traku = zamjena, tap na centar = polje *ili* Browser — ništa od toga se ne vidi. Nema indikatora pozicije (npr. 2 / 4).
4. **Dvije trake su teške za čitanje:** preview traka od ≈ 216 px s fontom 14 px; nije jasno da je gore "Premium", a dolje "Free".
5. **`Play` ne pokreće igru** — na ovoj sceni otvara polje ili vraća traku; do runa su 3 koraka.
6. **Aktivna vs fokus:** razlika je samo cream rub; nigdje ne piše "u ovoj igraš".
7. **Unlock poster je sitan** (coin 40 px, brojevi 18 px, dugme 48 px) i ne kaže "fali ti još 180 coina i 8 bundeva".
8. **Browser izgleda kao debug meni** (840 × 720, kartice 168 × 120, font 20); zaključane free kartice samo trepnu, bez objašnjenja.
9. **Premium:** osim imena cvjetova ne vidi se šta dobiješ; cijena je dio 🔒 labele; Ember Fen izgleda kao ostale, a ne može se kupiti.
10. **Mrtav prostor:** ≈ 250 px između Daily gift kartice i scene, prazna desna strana vrha.
11. **Konflikt gesti:** 984 × 1085 px Home stranice ne propušta hub swipe — tab se na Home mijenja samo swipeom na vrhu, u Play redu ili u uskim bočnim marginama (48 px), ili tapom na footer.
12. **Stil ne prati novi chrome i Arenu** (tamna traka `#1A241E`, Arena livada koja raste, sjemenka = cream rim + tamni well).
13. **Dodir:** Unlock 48 px, Close 48 px, kartice u preview traci ≈ 216 px visine ali font 14 — sve ispod minimuma.

---

## 4. Zahtjevi za redizajn

Trenutni izgled je **polazna tačka, ne šablon.** CD ima slobodu u rasporedu, gestama i vizuelnoj metafori — dok god poštuje ovo:

### 4.1 MORA

- **Pravila iz §2 ostaju:** redoslijed i uslovi besplatnih sezona (500 coina + 20 ★3 prethodne), linearnost (iza next locka se ne može), Unlock na licu mjesta, premium preko IAP-a, tap na otključanu sezonu vodi u **polje sezone**.
- **Stanja:**
  - novi igrač (samo Country Bloom; Frost next lock `0 / 500`, `0 / 20`; tutorial hint);
  - sredina igre (2 otključane, Lantern next lock `320 / 500`, `12 / 20`);
  - spremno za Unlock (zlatno) i trenutak otključavanja;
  - dolazak iz Campa nakon otključavanja tamo: nova sezona je već otključana i u fokusu (bez drugog trenutka otključavanja; smije kratak „new" akcent);
  - sve besplatne otključane (nema next locka);
  - premium: nekupljena / kupljena / aktivna / coming soon (Ember Fen) / kupovina u toku.
- **Jasno "u ovoj igraš"** (aktivna sezona) naspram "samo gledam" (fokus).
- **Rarity čitljiv i bez boje** (zvjezdice, oblik), isto kao u Journalu, Campu i Areni.
- **Dodir i tekst:** sve interaktivno ≥ **120 px**; tekst ≥ **38 px**, brojevi ≥ **44 px** — i u sekundarnim dijelovima (preview, Browser).
- **Header i footer su zadati**; Home živi u **1080 × 1597 px** između njih.
- **Hub swipe:** igrač mora moći preći na susjedni tab. Ako CD zadrži horizontalni karusel sezona, mora pokazati zonu u kojoj swipe mijenja tab — ili predložiti drugačiju gestu za sezone (vertikalna lista, strelice, tabovi).
- **Broj sezona nije zakucan** — raspored ne smije pretpostaviti tačno 4 + 4 (nova sezona = novi red u `seasons.json`).
- **Cijena je proizvoljan string** (valuta, dužina) — dizajn mora podnijeti `€3.49` i `3,49 KM`.
- **Cvijeće CD ne crta** — koristi postojeću ilustraciju. **Sezonska ilustracija ne postoji:** dizajn mora raditi bez nje (mood boja + cvijeće iz rostera + tagline); CD smije predvidjeti slot za buduću ilustraciju.
- **Pillar 2:** besplatni put je uvijek vidljiv i dostižan igrom; premium nikad ne zaklanja free sezone; bez agresivnog "Buy", lažne hitnosti, odbrojavanja ili popusta.
- **Polje sezone se ne dizajnira** — samo prelaz u njega (npr. kartica koja se "otvori").

### 4.2 SMIJE (sloboda)

- **Raspored:** npr. jedna velika kartica + mali pregled ostalih, vertikalna "mapa sezona" (put od Country Blooma do Amber Canopyja), tabovi Free | Premium, knjiga sezona… **Dvije trake nisu obavezne.**
- **Browser:** zadržati i redizajnirati (full-screen), ili spojiti sa scenom ako scena već pokazuje sve sezone — uz obrazloženje.
- **Identitet sezone:** mood boja, tagline, 2–3 cvijeta iz rostera kao kompozicija, mali pejzaž od ravnih oblika, zastavica ili znak.
- **Tok do igre:** npr. `Play` odmah pokreće run u aktivnoj sezoni, a polje se otvara tapom na karticu — ili obrnuto. Navedi kao **prijedlog** (mijenja današnji tok od 3 koraka).
- **Napredak:** "2 / 4 seasons", put s tačkama, "fali ti još…" poruka na posteru.
- **Trenutak otključavanja** (slavlje) i **premium pregled** (šta dobiješ: 6 cvjetova, ton, polje).
- **Daily gift:** premjestiti ili redizajnirati (funkcija ostaje).
- **Novi kratki tekstovi** (EN).

Ideje van ovoga (npr. sezonski eventi, pretplata, novi resursi) navedi **odvojeno na kraju**.

---

## 5. Paleta i tokeni

**Paleta** — [[../art-direction|art-direction]] + `ui_palette.gd` + hub chrome + Arena. Nove nijanse samo kao svjetlija/tamnija varijanta postojećih, jasno označene.

| Uloga | Hex |
|-------|-----|
| Mint · lavanda · peach (CTA / Play) | `#A8E6CF` · `#D4A5FF` · `#FFB88C` |
| Coin gold · UI gold (Unlock) | `#FFD56B` · `#E8C44A` |
| Warm white · price bg | `#FFF8F0` · `#FFE8B8` |
| Soft sky · pastel yellow · pastel pink | `#B8E0F5` · `#FFEAA7` · `#FFCCD5` |
| UI tekst · outline | `#4A4A4A` · `#2D3436` |
| Hub chrome · Arena well · Arena rim edge | `#1A241E` · `#22342A` · `#CBC2B6` |
| Home pozadina (danas) · Daily gift (danas) | `#243329` · `#FFC77A` |
| Aktivna sezona (rub) · ink | `#FFF6D6` · `#1A1A14` |
| Rarity pozadine | ★1 `#B8D4F0` · ★2 `#E0C4FF` · ★3 `#FFE8B8` · locked `#E4E4E0` |

**Mood boje sezona** (`season_card_contrast.gd` — boja kartice; naslov se bira po svjetlini):

| Sezona | Vrsta | Mood | Naslov na kartici |
|--------|-------|------|-------------------|
| Country Bloom | free 1 | `#A8E6CF` | tamni `#2E3833` |
| Frost Orchard | free 2 | `#C5D5E8` | tamni |
| Lantern Meadow | free 3 | `#C9B8E0` | tamni |
| Amber Canopy | free 4 | `#E8C48A` | tamni |
| Moonlit Warren | premium · €2.99 | `#3D3A6B` | cream `#FFF6D6` |
| Coral Tide Garden | premium · €3.49 | `#E8A090` | tamni |
| Starfall Glade | premium · €2.99 | `#6B5B95` | cream |
| Ember Fen | premium · €3.49 (coming soon) | `#C45C26` | cream |

**Tokeni:** radius 12 / 16 / 20 / 26 · border 2 px outline @ 10–14 % · jedna drop sjena · outline ~20 % tamniji od fill-a.

**Font:** igra koristi default sans (težine simulirane); mockup smije Nunito kao prethodni CD radovi.

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

**Lako za prenijeti:**

- Kartice, paneli, dugmad, barovi = Godot `StyleBoxFlat` (ravna boja + alpha, zaobljeno, border, jedna sjena).
- Karusel / lista = `HBox` / `VBox` / `ScrollContainer`; animacija = tween (pozicija, skala, prozirnost, boja, visina).
- Blokada hub swipea radi po **pravougaoniku** (node u grupi `block_hub_swipe`) — zone su lako izvodljive, ako su jasno nacrtane.
- Kompozicija sezone od ravnih oblika + postojeće ikone cvjetova (SVG/PNG).
- IAP dijalog je sistemski — CD crta samo stanje prije, "u toku" i poslije.

**Izbjegavati:** blur/glow shadere, gradijente na panelima, teške čestice, maske/izreze (osim kao PNG), 3D rotacije kartica.

**Layout:** artboard **1080 × 1920**, sve mjere u px te baze (prenos 1:1); Home = **1080 × 1597** između headera (143) i footera (180); 1 dp ≈ 2,75 px → dodir 44 pt ≈ **120 px**, tekst 14 pt ≈ **38 px**.

---

## 7. Šta tražimo od CD (isporuka)

**P1 — obavezno:**

1. **Glavni ekran 1080 × 1920** sa headerom/footerom — sredina igre: Country Bloom i Frost Orchard otključani (Frost aktivna), Lantern Meadow next lock `320 / 500` i `12 / 20`, premium 0 kupljenih.
2. **Novi igrač:** samo Country Bloom; Frost next lock `0 / 500`, `0 / 20`; tutorial hint.
3. **Unlock:** spremno (zlatno) + trenutak otključavanja (storyboard 2–3 kadra).
4. **Premium:** nekupljena (Coral Tide Garden, cijena), kupljena i aktivna (Moonlit Warren), coming soon (Ember Fen), kupovina u toku.
5. **Kraj besplatnog puta:** sve 4 free otključane (Amber aktivna).
6. **Spec sheet kartice sezone:** aktivna / otključana / next lock / dalje zaključana / premium nekupljena / kupljena / coming soon — za svih 8 mood boja.
7. **Pregled svih sezona** (Browser ili njegova zamjena) — ili obrazloženje zašto nestaje.
8. **Geste:** skica šta radi swipe / tap gdje, uključujući zonu za hub swipe.

**P2 — poželjno:**

9. **Tabela animacija** (šta, trajanje, easing).
10. **Lista asseta za export** (SVG/PNG).
11. **Alternativni raspored** za poređenje.

**Max 2 vizuelna smjera**, jedan pored drugog, uz preporuku CD-a koji je bolji i zašto.

**Imena slojeva** (za mapiranje na Godot, §10): `HomePage`, `SeasonStage`, `SeasonCard`, `ActiveBadge`, `SeasonRoster`, `UnlockPoster`, `CoinProgress`, `FlowerProgress`, `UnlockButton`, `PremiumCard`, `PriceTag`, `SeasonBrowser`, `ProgressIndicator`, `PlayButton`, `DailyGiftCard`, `HubSwipeZone`.

## 8. Ne tražimo

- **Polje sezone** (SeasonField: livada, Pip, cvijeće na polju, korpa, Magnet / Loot Boost, `Play Endless`, `Seasons` nazad) — poseban brief.
- Promjenu cijena, uslova otključavanja i broja sezona; novu mehaniku.
- Header/footer, Shop ekran (napomena: premium kartica je danas dijeljena sa Shopom — ako je CD redizajnira, Shop je naslijedi), IAP sistemski dijalog.
- Cvijeće (posebna ilustracija), lik Pipa, sezonsku key-art ilustraciju (samo slot).

---

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. Putanje su iz repoa (`master`); ako CD neki fajl ne može pročitati, priloži ga ručno.

```
Radim redizajn jednog ekrana mobilne igre: HOME — scena biranja sezone.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon stil (bez pixel-arta, bez 3D, bez retro efekata). Mood: cozy livada.

Tvoja referenca je fajl u repou (master):
  docs/04-experience/design-drafts/home-season-select-cd-brief.md
U njemu su pravila koja važe (§2), trenutni raspored s mjerama (§3), šta
danas ne štima (§3.2), šta mora a šta smiješ (§4), paleta i mood boje
sezona (§5), tehnička ograničenja (§6) i isporuka (§7). Pročitaj ga cijelog
prije rada — §10 je za kasniji prenos u Godot i možeš ga preskočiti. Ovaj
prompt je sažetak; ako se nešto razlikuje, važi fajl.

Header/footer huba, Merge Arena i Camp su već redizajnirani u ovom projektu
(tamna traka #1A241E; sjemenka = cream rim + tamni well). Home mora
izgledati kao ista igra — nastavi taj vizuelni jezik. Tvoji raniji radovi
su u repou:
  design_handoff_hub_chrome/HubScreen.dc.html   (okvir: header + footer)
  design_handoff_merge_arena/SeedChip.dc.html   (sjemenka, vizuelni jezik)
  design_handoff_camp/CampScreen.dc.html        (Camp, kartica sljedeće sezone)

VAŽNO: dizajniraš SAMO scenu biranja sezone. Polje sezone (livada s
cvijećem, Pip, korpa, upgradei, Play Endless) je poseban ekran i radi se
kasnije — ovdje nacrtaj samo ulaz u njega.

CILJ: igrač na prvi pogled vidi u kojoj sezoni igra, koje ima, koliko mu
fali do sljedeće besplatne i šta nudi premium — i lako kreće u igru. Svaka
sezona treba da ima svoj osjećaj. Mora se moći 1:1 prenijeti u Godot 4.
Imaš punu slobodu u rasporedu, gestama i vizuelnoj metafori. Pravila i
brojevi su fiksni.

KAKO RADI (detalji u §2):
- 8 sezona, svaka ima 6 cvjetova (3×★1, 2×★2, 1×★3).
- 4 BESPLATNE, linearno: Country Bloom (otključana od starta) → Frost
  Orchard → Lantern Meadow → Amber Canopy. Sljedeća traži 500 coina + 20 ★3
  cvjetova prethodne sezone. Samo prva zaključana ("next lock") se može
  pogledati i otključati; dalje ne. Unlock je na licu mjesta: zlatno dugme
  kad su oba uslova ispunjena, sivo kad nisu; troši oboje, sezona postaje
  aktivna.
- 4 PREMIUM (IAP): Moonlit Warren €2.99, Coral Tide Garden €3.49, Starfall
  Glade €2.99, Ember Fen (coming soon). Mogu se pregledati prije kupovine
  (6 cvjetova). Cijena je string iz store-a (npr. "3,49 KM").
- AKTIVNA sezona = u njoj se igra (tačno jedna). Tap na otključanu sezonu
  otvara njeno polje (poseban ekran).
- Camp (susjedni tab) ima karticu sljedeće besplatne sezone. Tap na nju
  dovodi igrača ovamo s fokusom na tu sezonu. Unlock u Campu troši odmah
  (burst u Campu), pa prebacuje ovamo: Home dočeka već otključanu sezonu u
  fokusu — bez drugog trenutka otključavanja (smije kratak "new" akcent).
- Daily gift kartica (Tap to open / Back tomorrow) je na ovoj sceni.

GDJE ŽIVI: 3. i početna stranica meta-huba (Shop · Journal · Home · Camp ·
Arena). Header (143 px) i footer (180 px) su zadati — prikaži ih, ne mijenjaj
ih. Home ima 1080 × 1597 px između njih. Hub se lista horizontalnim
swipeom — ako i sezone listaš horizontalno, pokaži gdje swipe mijenja tab.

GLAVNI PROBLEMI DANAS (§3.2):
1. Kartice sezona su obojeni pravougaonici s imenom — nema identiteta.
2. Tekst 14–28 px; poster za otključavanje sitan (brojevi 18 px).
3. Dvije trake (Premium gore, Free dolje) i skrivene geste (swipe dolje =
   odaberi, tap na malu traku = zamjena) — ništa se ne vidi.
4. "Play" na ovoj sceni ne pokreće igru nego otvara polje (3 koraka do runa).
5. Ne piše "u ovoj igraš"; Browser (pregled svih sezona) izgleda kao debug
   meni; ≈ 250 px praznog prostora na vrhu.

DIZAJNIRAJ (sloboda):
- Raspored: jedna velika kartica, vertikalna "mapa sezona", tabovi Free |
  Premium… — dvije trake nisu obavezne. Browser zadrži ili spoji sa scenom.
- Karticu sezone: identitet od mood boje, taglinea (§2.9) i cvijeća iz
  rostera; slot za buduću ilustraciju.
- Unlock poster s jasnim "fali ti još…", trenutak otključavanja.
- Premium pregled (šta dobiješ) bez pritiska na kupovinu.
- Tok do igre (npr. Play odmah pokreće run) — kao prijedlog.
- Indikator napretka (npr. 2 / 4), Daily gift, nove kratke tekstove (EN).

MORA:
- Pravila i brojevi iz §2 ostaju; linearni free put.
- Stanja: novi igrač, sredina igre, spremno za Unlock, sve free otključane,
  premium nekupljena / kupljena / aktivna / coming soon / kupovina u toku.
- Jasno "u ovoj igraš" vs "samo gledam".
- Rarity čitljiv i bez boje (zvjezdice/oblik).
- Sve interaktivno ≥ 120 px; tekst ≥ 38 px, brojevi ≥ 44 px (i u
  sekundarnim dijelovima); EN tekst.
- Raspored ne smije pretpostaviti tačno 4 + 4 sezone.
- Cvijeće NE crtaš — koristi postojeću ilustraciju. Sezonske ilustracije
  ne postoje — dizajn mora raditi bez njih.
- Fair F2P: besplatni put uvijek vidljiv i dostižan; bez agresivnog "Buy",
  lažne hitnosti, odbrojavanja, popusta.

PALETA (koristi ove hex vrijednosti; nove nijanse samo kao svjetlija/tamnija
varijanta postojećih i jasno ih označi):
mint #A8E6CF · lavanda #D4A5FF · peach #FFB88C (CTA/Play) · coin gold
#FFD56B · UI gold #E8C44A (Unlock) · warm white #FFF8F0 · price bg #FFE8B8
· soft sky #B8E0F5 · UI tekst #4A4A4A · outline #2D3436 · chrome #1A241E ·
Arena well #22342A · aktivna (rub) #FFF6D6 · rarity ★1 #B8D4F0 / ★2 #E0C4FF
/ ★3 #FFE8B8
Mood sezona: Country Bloom #A8E6CF · Frost Orchard #C5D5E8 · Lantern Meadow
#C9B8E0 · Amber Canopy #E8C48A · Moonlit Warren #3D3A6B · Coral Tide
#E8A090 · Starfall Glade #6B5B95 · Ember Fen #C45C26
Stil: zaobljeno, outline ~20 % tamniji od fill-a, jedna blaga sjena.

TEHNIČKI (Godot 4, OpenGL, slabiji Android):
- Artboard 1080 × 1920 px; sve mjere u px te baze (prenos 1:1).
- Paneli/kartice/barovi = ravna boja (+alpha), zaobljeno, border, jedna
  sjena. Bez blura, gradijenata na panelima, teških čestica, 3D rotacija.
- Animacije = tween (pozicija, skala, prozirnost, boja, visina).
- Zona za hub swipe = pravougaonik.

ISPORUKA (statični artboardi, jasno labelirani):
P1 — obavezno:
1. Glavni ekran 1080 × 1920 sa headerom/footerom: Country Bloom + Frost
   otključane (Frost aktivna), Lantern next lock 320/500 i 12/20, premium
   0 kupljenih.
2. Novi igrač (samo Country Bloom, Frost 0/500 i 0/20, tutorial hint).
3. Unlock: spremno (zlatno) + trenutak otključavanja (2–3 kadra).
4. Premium: nekupljena (Coral Tide), kupljena i aktivna (Moonlit),
   coming soon (Ember Fen), kupovina u toku.
5. Sve 4 free otključane (Amber aktivna).
6. Spec sheet kartice sezone (sva stanja, svih 8 mood boja).
7. Pregled svih sezona (Browser ili zamjena) ili zašto nestaje.
8. Skica gesti (swipe / tap) uključujući zonu za hub swipe.
P2 — poželjno:
9. Tabela animacija (šta, trajanje, easing).
10. Lista asseta za export (SVG/PNG).
11. Alternativni raspored za poređenje.
Pokaži max 2 vizuelna smjera jedan pored drugog i reci koji preporučuješ i
zašto.

IMENA SLOJEVA (da ih mogu mapirati na Godot node-ove): HomePage,
SeasonStage, SeasonCard, ActiveBadge, SeasonRoster, UnlockPoster,
CoinProgress, FlowerProgress, UnlockButton, PremiumCard, PriceTag,
SeasonBrowser, ProgressIndicator, PlayButton, DailyGiftCard, HubSwipeZone.

NE RADI: polje sezone, cijene/uslove/broj sezona, novu mehaniku,
header/footer, Shop, IAP dijalog, cvijeće, lik Pipa, sezonsku ilustraciju
(samo slot). Ideje van zadatka navedi odvojeno na kraju.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `HomePage` | `main_menu.tscn` (`Background`, `DecorMoundLeft/Right`, `HomeTopStack`, `HomeColumn`) + `main_menu.gd` | Field-režim node-ovi (`FieldBackdrop`, `BasketCard`, `FieldUpgradeStack`, `SeasonNameChip`, `SeasonsRowButton`, `EndlessPlayButton`) nisu dio ovog briefa; vidljivost preko `sync_field_backdrop()` |
| `SeasonStage` | `season_stage.tscn` / `season_stage.gd` (`BandColumn` → `PaidBand` / `BandSep` / `FreeBand`, `*Motion`, `Row` / `PaidRow`, `Left/Center/RightSlot`, `Paid*Slot`) | Geste: `_on_stage_gui_input`, `_update_press`, `_handle_tap`, `swap_home_band`, `cycle_free_strip` / `cycle_paid_strip`, `_play_inplace_morph`. Stil: `_apply_card_color`, `_slot_font` |
| `SeasonCard` / `ActiveBadge` | slotovi u `season_stage.gd` (`_fill_slot`, `_fill_paid_slot`) | Aktivna = `GameState.active_season_id`; fokus = `home_hero_center_id()` |
| `SeasonRoster` | `FreeRoster` / `PaidRoster` (`season_roster_panel.gd`) u `CenterFill` | Ikone: `collection_bloom_icon.gd`; podaci `SeasonDef.roster` |
| `UnlockPoster` / `CoinProgress` / `FlowerProgress` / `UnlockButton` | `UnlockGate` (`season_unlock_gate.gd`) + `UnlockProgress` (`season_unlock_progress.gd`) | Od Camp redizajna (2026-09-16) `season_unlock_progress.gd` koristi **samo Home** — Camp ima svoju karticu (`season_link_card.gd`, stilovi u `ui_camp.gd`), pa se `UnlockProgress` može mijenjati slobodno; njegov `split` režim je ostatak starog Campa. Uslovi: `can_unlock_free`, `unlock_free`, `star3_flower_count_for_unlock` |
| `ArrivalFromCamp` | `season_link_card.gd` (`_go_home`, `_finish_unlock`) | Camp postavlja `set_free_strip_focus(id)` + `set_home_band("free")`, zatvara polje i ide na `MAIN`; nakon Unlocka zove `refresh_for_meta_hub()` na Home. Sezona je tada već otključana |
| `PremiumCard` / `PriceTag` | `season_pack_card.gd` (`SeasonPackCard`) | **Dijeljen sa Shopom** (2-kolonski grid paketa) — redizajn mijenja i Shop. Podaci: `IAPManager.owns_product`, `get_price_label`, `purchase`, `is_busy` |
| `SeasonBrowser` | `season_browser.tscn` / `season_browser.gd` | Signal `season_selected` → `season_stage._on_browser_selected` |
| `PlayButton` | `HomeColumn/PlayRow/PlayButton` | Tok: `main_menu.home_play_action()` → `"run"` / `"open_field"` / `"snap"` |
| `DailyGiftCard` | `HomeTopStack/DailyChestCard` + `RewardOverlay` | `_refresh_chest_card`, `UiAttention` puls |
| `HubSwipeZone` | grupa `block_hub_swipe` → `swipe_pager.should_block_hub_swipe_at()` | Danas je u grupi cijeli `SeasonStage` |
| Boje | `season_card_contrast.gd` | `mood_color`, `title_color`, `text_color`, `make_frame` |
| Podaci | `GameState` / `economy/seasons.gd` | `strip_left/center/right_id`, `paid_left/center/right_id`, `home_band`, `is_season_playable`, `is_free_selectable`, `next_locked_free_id`, `set_active_season`, `is_test_locked_season`; `SeasonCatalog.free_defs_sorted()` / `paid_defs()`; `SeasonDef.display_name` / `tagline` / `roster` |

**Smoke testovi koje prenos mora proći ili svjesno ažurirati:** `season_home_smoke` (glavni — 3-slot trake, hit-through kartice, gate i roster u `CenterSlot`, zamjena traka, preview tap, kupovina ne krade centar, Frost → Lantern → Amber unlock tok, Browser se ne otvara na preview tap), `season_meadow_smoke` (Play u 3 koraka, ulaz u polje), `season_unlock_smoke`, `season_iap_smoke`, `shop_open_smoke` (`SeasonPackCard` 2-col, 4 paketa), `camp_season_link_smoke` (Camp → Home: fokus na sezonu, Unlock u Campu troši odmah pa Home), `meta_hub_flow_smoke`.

**Poznati problemi nađeni pri pisanju briefa:**

1. **`SeasonUnlockSheet` je mrtav u igri:** `season_browser.gd` deklariše `unlock_requested`, ali ga nikad ne emituje — sheet otvara samo `season_home_smoke` (P11). Tekst u sceni je placeholder (`Coins  0 / 80`, `Flowers  0 / 5`). Kandidat za brisanje pri prenosu (+ ažurirati smoke).
2. **Uvijek skriveni node-ovi:** `SeasonField/SeasonsButton`, `PlayThemeBadge`, `PipPortrait`, `Tagline` (Home) — mrtvi u sceni biranja.
3. **Ember Fen je test-locked** (`TEST_LOCK_LAST_SEASONS`, `TEST_LOCK_PAID_ID` u `economy/seasons.gd`) — UI ga prikazuje kao običnu nekupljenu premium sezonu s cijenom.
4. **[[../../02-design/spec-vertical-slice|spec-vertical-slice]] § 1 Main Menu je zastario** ("Play → Run") — ne opisuje SeasonStage ni polje; ažurirati pri prenosu.
5. **Uslovi sezona nisu u GDD-u:** 500 coina + 20 ★3 i IAP cijene žive samo u `game/data/seasons/seasons.json` i `monetization_config.gd` (+ CHECKPOINT / changelog); [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]] ih ne navodi.
6. **`season_unlock_progress.gd` ima mrtav `split` režim** (koristio ga je stari Camp SeasonLink do 2026-09-16) — ukloniti pri prenosu.

**Gotovo kad (implementacija):**

- [ ] Home stane između headera i footera; sve interaktivno ≥ 120 px, tekst ≥ 38 px
- [ ] Rade sva stanja iz §4.1 (novi igrač → sve free otključane; premium 4 stanja)
- [ ] Aktivna sezona jasno označena; tap na otključanu vodi u polje
- [ ] Unlock na licu mjesta troši 500 + 20 i pokazuje trenutak otključavanja
- [ ] Dolazak iz Campa: fokus na traženu sezonu; nakon Unlocka u Campu sezona je već otključana, bez drugog trenutka otključavanja
- [ ] Hub swipe radi u dogovorenoj zoni
- [ ] Rarity prepoznatljiv na grayscale screenshotu
- [ ] Smoke: sve iz liste gore (ažurirane gdje se tok svjesno mijenja)

---

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-14 | Brief napisan samo za scenu biranja sezone; polje sezone (SeasonField) dobija poseban brief kasnije. Ekonomija i pravila sezona (§2) su fiksni; CD dizajnira izgled, raspored i geste. Header/footer i Arena (smjer B) su zadati vizuelni jezik. |
| 2026-09-18 | Usklađeno s Camp redizajnom (2026-09-16): Unlock u Campu troši odmah i prebacuje na Home s već otključanom sezonom u fokusu (novo stanje „dolazak iz Campa" u §4.1); `UnlockProgress` više nije dijeljen s Campom; Camp je dio zadatog vizuelnog jezika. CD čita brief i ranije radove iz repoa po putanji (§0, §9). |

## Otvorena pitanja (nakon CD-a)

- [ ] Dvije trake ili jedan raspored (lista / mapa / tabovi)?
- [ ] Browser ostaje ili se spaja sa scenom?
- [ ] Šta `Play` radi na sceni biranja (direktno run ili polje)?
- [ ] Zona za hub swipe vs gesta za sezone?
- [ ] Sezonske ilustracije — ko ih crta i kada (danas `thumbnail_path` prazan)?
- [ ] Brisanje mrtvog `SeasonUnlockSheet` pri prenosu?
- [ ] Ember Fen: "Coming soon" oznaka ili sakriti do izlaska?

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — okvir u koji Home ulazi
- [[merge-arena-cd-brief|merge-arena-cd-brief]] — isti format; vizuelni jezik (smjer B)
- [[camp-cd-brief|camp-cd-brief]] — isti uslovi otključavanja; kartica sljedeće sezone u Campu vodi na Home (implementirano 2026-09-16)
- [[journal-cd-brief|journal-cd-brief]] — roster i rarity prikaz cvjetova
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — cvijeće i sjemenke (posebna ilustracija)
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]] — § 0 Meta Hub, § 1 Main Menu
- [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]] — coini i kamp (uslovi sezona tamo **nisu** — izvor je `seasons.json`, vidi §10)
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2 (Fair F2P)
- [[../art-direction|art-direction]] · [[../pristupacnost|pristupačnost]]
