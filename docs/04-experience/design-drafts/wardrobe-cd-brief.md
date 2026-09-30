---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ui, home, kozmetika, shop, claude-design, mockup]
povezano:
  - home-v3-cd-brief
  - home-field-v2-cd-brief
  - shop-cd-brief
  - merge-arena-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: ormar (Wardrobe) — ikona na polju sezone dolje desno iznad Endlessa otvara sheet s kupljenom kozmetikom (Pip skin, tint livade, okvir albuma); izbor se primijeni na cijelu igru pri izlasku; tab i podaci moraju primiti nove slotove i stavke bez novog dizajna."
---

# Ormar (Wardrobe) — Claude Design brief

> **Status 2026-09-30: brief spreman, čeka CD.** Prompt je u §11. Paket se vraća kao `design_handoff_wardrobe/` (zip).

**Ormar** je mjesto gdje igrač bira kozmetiku koju je kupio u Shopu. Otvara se s polja sezone na Homeu, preko ekrana, i ono što igrač izabere nosi se kroz cijelu igru.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§10 | Šta mora, šta smije, šta se isporučuje |
| **Ti** | **§11** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §4, §5, §6 | Današnje vrijednosti, šema podataka i gdje se kozmetika primjenjuje u kodu |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto

Kozmetika se danas kupuje i oblači samo u Shopu, a vidi se na malo mjesta: Pip skin samo u runu, tint livade samo na pozadini runa, okvir samo u Journalu. Igrač nema mjesto gdje vidi šta posjeduje i gdje to mijenja bez odlaska u prodavnicu.

Ormar to rješava na polju sezone, gdje igrač već stoji s Pipom prije runa. I mora biti napravljen za budućnost: **dolazi još kozmetike** (novi skinovi, novi slotovi), a ekran i podaci moraju to primiti bez novog dizajna.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Kupovina | ostaje u **Shopu** (coini, 2 tapa, „Now / With it" pregled). Ormar ne prodaje. |
| Kozmetika | samo izgled — nikad loot, magnet ni snaga (**Pillar 2**, nepregovarljivo). Nijedan tekst ne smije sugerisati prednost. |
| Cijene i katalog | ne mijenjaju se (§4.2). |
| Polje sezone | livada je cijela stranica 1080 × 1633. Gift + korpa gore lijevo, nadogradnje gore desno, donji red Seasons 236 · Play 432 · Endless 236. Ne pomjeraj ih. |
| Endless | vidi se tek kad je tutorial gotov. |
| Sheetovi na polju | korpa (visina 1326) i nadogradnje (922) već se otvaraju preko polja sa scrimom `rgba(26,22,30,.55)`. Ormar je treći sheet i pripada istoj porodici. |
| Swipe | vodoravni swipe po praznoj livadi lista hub. Otvoren sheet ga blokira. |
| Header / footer | chrome v2, 143 / 144, ne dirati. |
| Art Pipa | `game/assets/sprites/pip_idle.svg` ostaje osnova. Ne crtaj novog Pipa. |

## 3. Šta se traži

Tačke 1–6 su **obavezne**. Raspored ormara, oblik kartica i animacije su tvoja odluka. Jedan dizajn.

1. **Ikona ormara na polju sezone, dolje desno, iznad Endlessa.** Mora se na prvi pogled čitati kao „kozmetika / izgled", ne kao Shop ni postavke. Dodir ≥ 120 × 120 (pločice na polju su 180). Kad Endless nije vidljiv (tutorial), ikona ostaje na istom mjestu. Sukobi koje moraš riješiti su u §4.1.
2. **Tap otvara ormar preko ekrana** (sheet ili puni preklop — tvoja odluka, ali kao dio iste porodice kao korpa i nadogradnje). Unutra je kozmetika iz Shopa: Pip skinovi, tint livade, okvir albuma.
3. **Izbor je jedan tap.** U svakom slotu igrač nosi najviše jednu stavku. Svaki slot ima i **Default** (bez kozmetike) — danas se stavka ne može skinuti; to se mijenja.
4. **Pregled uživo u ormaru.** Dok bira, igrač vidi kako izgleda (Pip u skinu, livada u tintu, okvir albuma). Pregled se ne dešava na pravom polju dok je ormar otvoren.
5. **Primjena pri izlasku.** Kad igrač zatvori ormar (X, tap na scrim ili povlačenje dolje — tvoja odluka koja od toga), izbor se snima i **odmah vidi u cijeloj igri** (§6). Pokaži taj trenutak: igrač se vraća na polje i vidi da se nešto promijenilo (npr. Pip kratko reaguje u novom skinu). Nema dugmeta „Save" koje igrač može zaboraviti.
6. **Stavke koje igrač nema** — prikaži ih ili ne, tvoja odluka, ali: ormar ne prodaje, nema cijene kao poziva na kupovinu, i ako vodiš igrača u Shop, to je jedan jasan put (npr. „More in Shop"), ne na svakoj kartici. Prazno stanje (igrač nema ništa) mora izgledati dobro i reći gdje se kozmetika nabavlja.

## 4. Današnje stanje (mjere iz koda)

### 4.1 Polje sezone — gdje ikona ide

Stranica 1080 × 1633, od y = 143. Izvor: `game/scripts/visual/ui_home_field.gd`.

| Blok | Rect (x, y, w, h) |
|---|---|
| Gift | (24, 24, 180, 180) |
| Korpa | (24, 220, 180, 180) |
| Nadogradnje | (876, 24, 180, 180) |
| Donji red | (70, 1461, 940, 148) |
| Seasons | (70, 1477, 236, 124) |
| Play | (324, 1461, 432, 140) — centar x 540 |
| **Endless** | **(774, 1477, 236, 124)** |
| Zona u kojoj Pip stoji (`PIP_BASE_ZONE`) | (151, 1306, 778, 131), Pip 190 px, podrazumijevano dno (756, 1404) |
| Keepout donjeg reda | (54, 1445, 972, 188) |

**Sukobi koje moraš riješiti i napisati u § Odlučeno:**

- Ikona iznad Endlessa (x ~774–1010) upada u zonu u kojoj Pip stoji (ta zona ide do x 929, y 1306–1437). Pip i ikona se ne smiju preklapati. Smiješ suziti `PIP_BASE_ZONE` ili pomjeriti ikonu; nemoj pomjeriti donji red.
- Cvijeće na livadi ima 13 mjesta (`MEADOW_SPOTS`, % od poda stranice). Zadnji red stoji oko 26–30 % od poda (y ~1140–1210, veličina 136–168). Ikona ne smije pokriti cvijet. Novi keepout napiši kao `Rect2i` u exportu.

### 4.2 Kozmetika danas

Izvor: `game/scripts/monetization/cosmetic_catalog.gd`, `game/scripts/economy/cosmetics.gd`.

| ID | Naziv | Slot | Cijena | Šta radi danas |
|---|---|---|---|---|
| `pip_blossom` | Pip Blossom | `pip_skin` | 250 | roza paleta za Pipa — samo u runu |
| `pip_sky` | Pip Sky | `pip_skin` | 200 | plava paleta za Pipa — samo u runu |
| `meadow_sunset` | Sunset Meadow | `meadow_bg` | 150 | tint pozadine runa `× (1,08; 0,94; 0,86)` |
| `meadow_lavender` | Lavender Meadow | `meadow_bg` | 180 | tint pozadine runa `× (0,94; 0,92; 1,06)` |
| `journal_gold` | Golden Album | `journal_frame` | 120 | zlatni okvir Bloom Albuma |

Stanje igrača: `owned_cosmetics {id: true}`, `equipped_cosmetics {slot: id}`. Kupovina u Shopu odmah i oblači stavku. **Skidanja nema** (Default ne postoji).

**Problem koji treba riješiti dizajnom:** Pip skin danas u runu **zamijeni pravi SVG art Pipa proceduralnim crtežom** (`PipDraw` s paletom), pa Pip u skinu izgleda lošije od Pipa bez skina. Na Homeu, u Areni i u Kampu skin se uopšte ne vidi. Skin mora raditi **na pravom artu** (`pip_idle.svg`) — reci kako (§6).

## 5. Proširivost — MORA (ovo je najvažniji dio)

Očekuje se još kozmetike. Dodavanje nove stavke ili novog slota mora biti **zapis u podacima**, ne novi dizajn ni novi kod ekrana.

1. **Ekran se gradi iz podataka.** Slotovi (tabovi, sekcije — tvoja odluka) i kartice se generišu iz kataloga. Dizajniraj pravila, ne 5 fiksnih kartica:
   - kartica stavke je **jedna komponenta** za svaki slot (pregled + naziv + stanje: nošeno / posjeduje / nema);
   - mreža ima pravilo za **bilo koji broj stavki** (1, 5, 30) — koliko kolona, skrol, šta kad je slot prazan;
   - navigacija kroz slotove radi i za **3 i za 8 slotova** (npr. skrolajući tabovi) — pokaži oba;
   - svaki slot ima svoju **vrstu pregleda** (`preview`): Pip, livada, album… Novi slot bira jednu od postojećih vrsta ili donosi novu.
2. **Šema podataka.** Predloži JSON za katalog (npr. `game/data/cosmetics/cosmetics.json`) koji će zamijeniti `ITEMS` u `cosmetic_catalog.gd`. Najmanje:
   - `slots[]`: `id`, `title`, `icon`, `order`, `preview` (vrsta), `applies_to[]` (gdje se u igri vidi, §6), `allow_default`;
   - `items[]`: `id`, `slot`, `title`, `description`, `coin_cost`, `source` (`shop` danas; kasnije npr. `season`, `event`), `order`, `new_since` (za oznaku „new"), i **podatke za izgled** (paleta za Pip skin, množitelj za tint, stil okvira) — sve što igri treba da stavku nacrta.
   - Postojećih 5 stavki mora ući u šemu bez gubitka (isti `id`, isti `slot`, iste cijene) — save igrača ih već drži po `id`.
3. **Primjeri proširenja u Specs** (samo kao demonstracija pravila, ne kao nova ekonomija): pokaži ormar s **dodatnim slotom** (npr. `companion` — igra već ima drugog saputnika, Mochi, `game/scripts/visual/companion_config.gd`) i s **više stavki** u jednom slotu (npr. 12 Pip skinova). Te stavke ne ulaze u katalog.

## 6. Primjena u igri — MORA

„Primijeni u cijeloj igri" znači: svaka stavka se vidi **svuda gdje njen slot kaže** (`applies_to`), a ne samo u runu. Za svaki slot napiši u README tabelu **gdje se vidi** i **kako** (tokeni, ne slike ekrana):

| Slot | Danas | Traži se |
|---|---|---|
| `pip_skin` | samo run, i to kao proceduralni crtež umjesto SVG-a | **svaki Pip u igri**: polje sezone (`season_field_pip.gd`), kartica sezone na Homeu, Arena (`pip_placeholder_control.gd`), run (`pip_visual.gd`, `pip_draw.gd`), i gdje god se Pip još crta. Skin radi na pravom SVG artu. Predloži način: zamjena boja u SVG-u po mapi (npr. tijelo, uši, unutrašnjost ušiju, obrub → nove boje) ili zaseban mali SVG po skinu (≤ 10 KB). Isporuči izgled za `pip_blossom` i `pip_sky`. |
| `meadow_bg` | množitelj boje pozadine runa | run obavezno. Da li tint ide i na **polje sezone** i **livadu u Areni** — tvoja odluka, obrazloži. Ako ide: Arena livade su osam različitih mjesta po sezoni (Arena v2) i identitet sezone mora ostati čitljiv; sjemenka i dalje ima kontrast ≥ 3 : 1 (pravilo dvostrukog ruba to već garantuje — ne kvari ga). |
| `journal_frame` | zlatni okvir Albuma | Journal, kao danas. Pokaži u ormaru kako se to vidi. |

Primjena je **odmah pri izlasku iz ormara**: sve stranice huba i Pip na polju se osvježe bez restarta igre.

## 7. Paleta i tehnika

Postojeći tokeni: `game/scripts/visual/ui_home_field.gd`, `ui_shop.gd`, `ui_palette.gd`. Warm white `#FFF8F0`, ink `#2D3436`, peach `#FFB88C` (CTA / aktivno), coin gold `#FFD56B`, mint `#A8E6CF`. Nova boja samo kao svjetlija ili tamnija varijanta postojeće, označena u README.

Godot 4.7, OpenGL, slabiji Android. Artboard 1080 × 1920, sve u px te baze. Paneli = ravna boja, radius, rub, jedna tvrda sjena. **Bez blura, glowa i gradijenata.** Animacije su tweenovi (skala, pozicija, alpha, boja). Najviše jedan loop na ekranu. Tekst ≥ 34 px, dodir ≥ 120 px, kontrast teksta ≥ 4,5 : 1. Ikona ormara i ikone slotova kao SVG u stilu hub chrome ikona (`game/assets/ui/chrome/` — tab i chip ikone chrome v2).

Budžet: cijela igra je ~0,44 MB sadržaja. Nova ikona + ikone slotova + eventualni SVG skinovi: ukupno ≤ 100 KB.

## 8. Isporuka

### 8.1 Stanja

1. **Polje sezone** s ikonom ormara — sa Endlessom i bez njega (tutorial). Dvije livade za kontrast: Country Bloom `#E6F2DB` i Moonlit Warren `#B8BDFF`.
2. **Ormar otvoren**, slot Pip skin: Default nošen, `pip_blossom` posjeduje, `pip_sky` nema.
3. **Ormar**, slot tint livade, sa živim pregledom.
4. **Ormar**, slot okvir albuma.
5. **Prazno stanje** — igrač nema nijednu stavku.
6. **Proširenje** — 8 slotova i 12 stavki u jednom slotu (§5.3).
7. **Izlazak i primjena** — 2–3 kadra ili opis u Specs: zatvaranje, povratak na polje, Pip u novom skinu reaguje.
8. **Gdje se vidi** — Pip u `pip_blossom` na polju sezone, u Areni i u runu; tint na pozadini runa (i gdje još odlučiš).

### 8.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_wardrobe/
  README.md                 šta otvoriti · § Odlučeno (uklj. sukobi iz §4.1) ·
                            § Primjena (tabela slot → gdje se vidi → kako) ·
                            § Proširivost (kako se dodaje slot / stavka) ·
                            § Šta se briše · § Samoprovjera · § Ideje van zadatka
  design/
    FieldWithWardrobe.dc.html   polje sezone s ikonom; prop season, endless (bool)
    Wardrobe.dc.html            ormar; prop slot, owned[], equipped{}, extra (bool)
    Wardrobe Specs.dc.html      anatomija kartice, mreža za N stavki, tabovi za
                                N slotova, sva stanja iz §8.1, primjena
    support.js · icons/ (ikona ormara, ikone slotova, SVG skinova ako ih ima)
  godot/
    wardrobe_export.json    meta · tokens · layout · components · states ·
                            animations · strings_en · godot_map · decisions
    cosmetics.json          katalog po šemi iz §5.2 — postojećih 5 stavki
    ui_wardrobe.gd          konstante (mjere, boje, tajminzi), isti nazivi gdje
                            postoje u ui_home_field.gd / ui_shop.gd
    wardrobe_tree.txt       stablo čvorova + red prenosa
```

**Imena slojeva:** `FieldPage`, `WardrobeButton`, `WardrobeSheet`, `WardrobeScrim`, `SlotTabs`, `SlotTab`, `ItemGrid`, `ItemCard`, `ItemPreview`, `EquippedBadge`, `DefaultCard`, `PreviewStage`, `ShopLink`, `EmptyState`, `CloseButton`, `ApplyMoment`.

### 8.3 Samoprovjera (u README, svaka stavka da/ne, provjereno u browseru)

1. Ikona ormara se ne preklapa ni s Endlessom, ni s Pipom, ni s jednim cvijetom polja, sa i bez Endlessa.
2. Dodir ikone ≥ 120 × 120; sav tekst ≥ 34 px i kontrast ≥ 4,5 : 1.
3. Svaki slot ima Default i može se skinuti ono što se nosi.
4. Ormar ne prodaje: nigdje dugme za kupovinu ni cijena kao poziv; najviše jedan put u Shop.
5. Ekran se gradi iz `cosmetics.json` — stanje §8.1/6 (8 slotova, 12 stavki) je napravljeno samo izmjenom podataka, bez izmjene komponenti.
6. Postojećih 5 stavki je u šemi s istim `id`, `slot` i cijenom.
7. Pip skin je prikazan na pravom SVG artu Pipa, na polju, u Areni i u runu.
8. Primjena se vidi odmah pri izlasku, bez „Save" dugmeta.
9. Nigdje blur, glow ni gradijent; najviše jedan loop.

## 9. Ne tražimo

- Novu kozmetiku za prodaju, nove cijene ili novu valutu.
- Promjene Shopa (osim eventualnog jednog linka „More in Shop" iz ormara).
- Novog Pipa ili novi art cvijeća.
- Header, footer, Camp, Journal (osim kako izgleda okvir), Arena mehaniku, run mehaniku.
- Više varijanti — jedan dizajn.

## 10. Scope

Kupovina kozmetike za coine je na launch IN listi (M8, Shop). Ormar je **UX za postojeću kozmetiku**, bez nove ekonomije, i ne krši Pillar 2 (samo izgled). Proširivi katalog je priprema za post-launch sadržaj. Novi slotovi i stavke iz §5.3 su samo demonstracija i ne ulaze u igru.

## 11. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je NOVI EKRAN: Ormar (Wardrobe) — mjesto gdje igrač bira kozmetiku koju je
kupio u Shopu. Mehanika igre i ekonomija se ne mijenjaju.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/wardrobe-cd-brief.md
    -> §2 (fiksno), §3 (šta se traži), §4 (mjere i kozmetika danas),
       §5 (PROŠIRIVOST — najvažnije), §6 (primjena u igri), §7 (tehnika),
       §8 (stanja, paket, samoprovjera)
  game/scripts/visual/ui_home_field.gd            (polje sezone: mjere, keepouti)
  game/scripts/monetization/cosmetic_catalog.gd   (5 stavki, 3 slota)
  game/scripts/economy/cosmetics.gd               (owned / equipped)
  game/scripts/visual/ui_shop.gd                  (kako Shop prikazuje kozmetiku)
  game/assets/sprites/pip_idle.svg                (pravi art Pipa)
  design_handoff_home_v3/                         (tvoj Home, polje sezone)
  design_handoff_shop/                            (tvoj Shop)

ŠTA TRAŽIM:

1. IKONA ORMARA na polju sezone, dolje desno, IZNAD Endless dugmeta
   (Endless je 236 x 124 na 774,1477 u px stranice 1080 x 1633). Mora se
   čitati kao "kozmetika / izgled", ne Shop ni postavke. Dodir >= 120 x 120.
   Kad Endless nije vidljiv (tutorial), ikona ostaje na mjestu.
   Dva sukoba riješi i zapiši: Pip stoji u zoni (151,1306, 778 x 131) koja
   ide do x 929 — ikona i Pip se ne smiju preklapati; i ikona ne smije
   pokriti nijedno od 13 mjesta za cvijeće (MEADOW_SPOTS). Donji red se ne
   pomjera.

2. TAP OTVARA ORMAR preko ekrana — iz iste porodice kao postojeći sheetovi
   korpe (1326) i nadogradnji (922), scrim rgba(26,22,30,.55). Unutra je
   kozmetika iz Shopa: Pip skinovi, tint livade, okvir albuma.
   - Jedan tap = izbor. Najviše jedna stavka po slotu.
   - Svaki slot ima DEFAULT (bez kozmetike) — danas se ne može skinuti,
     to se mijenja.
   - Pregled uživo u ormaru (Pip u skinu, livada u tintu, okvir albuma).
   - Ormar NE PRODAJE: kupovina ostaje u Shopu. Najviše jedan jasan put u
     Shop (npr. "More in Shop"). Prazno stanje mora izgledati dobro.

3. PRIMJENA PRI IZLASKU. Kad igrač zatvori ormar, izbor se snima i odmah
   vidi u CIJELOJ igri, bez "Save" dugmeta. Pokaži trenutak povratka na
   polje (npr. Pip kratko reaguje u novom skinu).
   Danas Pip skin radi samo u runu i tada ZAMIJENI pravi SVG art
   proceduralnim crtežom, pa izgleda lošije. Skin mora raditi na PRAVOM
   artu (pip_idle.svg) svuda gdje je Pip: polje sezone, kartica sezone,
   Arena, run. Predloži kako (zamjena boja u SVG-u po mapi ili mali SVG po
   skinu <= 10 KB) i isporuči izgled za pip_blossom i pip_sky.
   Tint livade: run obavezno; polje sezone i Arena — tvoja odluka,
   obrazloži (Arena ima 8 livada po sezoni, identitet sezone mora ostati).
   Za svaki slot napravi tabelu: gdje se vidi i kako (tokeni).

4. PROŠIRIVOST — NAJVAŽNIJE. Dolazi još kozmetike. Nova stavka ili novi
   slot mora biti ZAPIS U PODACIMA, ne novi dizajn:
   - ekran se gradi iz kataloga: jedna ItemCard komponenta za sve slotove,
     mreža s pravilom za 1, 5 i 30 stavki, navigacija kroz slotove koja
     radi i za 3 i za 8 slotova;
   - svaki slot ima vrstu pregleda (preview) — novi slot bira postojeću;
   - predloži JSON šemu kataloga (cosmetics.json): slots[] (id, title,
     icon, order, preview, applies_to[], allow_default) i items[] (id,
     slot, title, description, coin_cost, source, order, new_since +
     podaci za izgled: paleta, množitelj tinta, stil okvira). Postojećih
     5 stavki ulazi s ISTIM id, slot i cijenom (save ih drži po id-u).
   - u Specs pokaži ormar s 8 slotova (npr. companion — igra ima Mochi)
     i 12 stavki u jednom slotu, NAPRAVLJEN SAMO IZMJENOM PODATAKA.
     Te demo stavke ne ulaze u katalog.

FIKSNO: Pillar 2 — kozmetika je samo izgled, nikad snaga; nijedan tekst ne
sugeriše prednost. Cijene i katalog se ne mijenjaju. Polje sezone (Gift,
korpa, nadogradnje, Seasons · Play · Endless), header/footer i art Pipa se
ne diraju. Swipe po livadi lista hub; otvoren ormar ga blokira.

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920, sve u
px te baze. Ravne boje, radius, rub, jedna tvrda sjena. BEZ blura, glowa i
gradijenata. Animacije su tweenovi. Najviše jedan loop. Tekst >= 34 px,
dodir >= 120 px, kontrast >= 4,5:1. Nove ikone + SVG skinovi ukupno
<= 100 KB.

ISPORUKA (§8): novi folder design_handoff_wardrobe/, CIJELI U ZIPU za
preuzimanje u chatu:
  design/FieldWithWardrobe.dc.html, Wardrobe.dc.html, Wardrobe Specs.dc.html
  (sva stanja iz §8.1), support.js, icons/
  godot/wardrobe_export.json, cosmetics.json, ui_wardrobe.gd,
  wardrobe_tree.txt
  README.md sa § Odlučeno, § Primjena, § Proširivost, § Šta se briše i
  § Samoprovjera (9 stavki iz §8.3, svaka da/ne, provjereno u browseru
  PRIJE nego pošalješ zip).

NE RADI: novu kozmetiku za prodaju, nove cijene, promjene Shopa, novog Pipa,
druge stranice huba, više varijanti. Jedan dizajn, tvoj izbor, neka bude
lijep.
```

## Povezano

- [[../../06-production/CHECKPOINT|CHECKPOINT]] — traka WARDROBE-01
- [[home-v3-cd-brief|Home v3]] — polje sezone na koje ide ikona
- [[shop-cd-brief|Shop]] — gdje se kozmetika kupuje
- [[merge-arena-cd-brief|Arena]] — livade po sezoni (tint, kontrast sjemenke)
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
