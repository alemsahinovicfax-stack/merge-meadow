---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ui, shop, monetizacija, arena, claude-design, mockup]
povezano:
  - shop-cd-brief
  - wardrobe-cd-brief
  - home-v3-cd-brief
  - merge-arena-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: Shop redizajn 2 — četiri taba kao četiri zasebna ekrana sa svojim skrolom (Seasons je prvi i podrazumijevani), manje teksta i jedno dugme s cijenom na svakoj kartici, veće kartice i pravi portreti cvijeća u sezonama, nova pozadina i tabovi; Looks iz istog kataloga kao Ormar; Merge Hint postaje trajna kupovina s novom oznakom u Areni, Loot Burst daje 5 ★3 cvjetova za otključavanje, Starter Pack traje 7 dana."
---

# Shop — redizajn 2 — Claude Design brief

> **Status 2026-10-01: brief spreman, čeka CD.** Prompt je u §12. Paket se vraća kao `design_handoff_shop_v2/` (zip).

> Prvi redizajn Shopa je u igri od 2026-09-24 ([[shop-cd-brief|brief]], paket `design_handoff_shop/`). Ovo je **runda 2**: isti sadržaj, ali Shop postaje četiri taba umjesto jedne duge stranice, s manje teksta i novim izgledom. Uz to se mijenjaju tri ponude (Merge Hint, Loot Burst, Starter Pack) — mehaniku radi agent, CD crta stanja.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§11 + slike u `shop-v2-ref/` | Šta mora, šta smije, kako izgleda danas, šta se isporučuje |
| **Ti** | **§12** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §5, §6, §7 | Nove mehanike, veza s Ormarom, današnje vrijednosti u kodu |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove i slike iz repoa po tačnoj putanji.

## 1. Zašto

Shop danas radi, ali je jedna duga stranica (Looks → Seasons → Boosters → Support) sa 4 dugmeta koja samo skrolaju do sekcije. Kartice nose po tri-četiri reda pomoćnog teksta („6 flowers for your Album · same runs, same rewards", „Get Moonlit Warren / yours to keep", „Need 30 more / earn in runs", „You have 1", „+1 to your stock"…), a cijena i dugme za kupovinu su dva odvojena elementa. Portreti cvijeća na kartici sezone su mali (96 px) i **ne pokazuju cvijet** — samo obojenu tačku. Zelena pozadina `#2E4733` je ostatak Kampa i ne pripada Shopu.

Cilj: igrač otvori Shop, odmah vidi sezone (najveća ponuda), lako prelazi između četiri taba, i na svakoj kartici vidi **šta dobija i jedno dugme koje to kupuje**.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stranica | 1080 × 1633 između hub headera (143) i footera (144). **Hub header i footer (chrome v2) su zajednički svim stranicama i ne diraju se.** |
| Cijene | Kozmetika za coine: Pip Blossom 250, Pip Sky 200, Sunset Meadow 150, Lavender Meadow 180, Golden Album 120. Pravi novac (store string, primjer EUR): Moonlit Warren €2.99, Coral Tide €3.49, Starfall Glade €2.99, Ember Fen „coming soon" (bez cijene), Merge Hint €0.99, Loot Burst €0.99, Remove Ads €3.99, Starter Pack €1.99. CD ne mijenja iznose. |
| Cijena je store string | može biti dug („Rp 57.900", „1,99 KM"). > 7 znakova → 44 px, nikad manje; dugme raste, ne reže tekst. |
| Boja = valuta | coin kupovina i kupovina pravim novcem se vizuelno razlikuju (danas zlatno vs lavanda). Ostaje pravilo, boje su tvoja odluka. |
| Jedna IAP kupovina u isto vrijeme | aktivno dugme pokazuje čekanje na store, ostala su prigušena. Neuspjeh / otkazano / pending se vide na kartici dok igrač ne tapne ponovo. |
| Coin kupovina | ne smije se desiti slučajno: zaštita od jednog slučajnog tapa ostaje (danas 2 tapa). Kako — tvoja odluka (§4.2). |
| Kupljena kozmetika | odmah se i nosi (kao danas), a dalje se mijenja u Ormaru. |
| Kupljena sezona | igra se kao besplatna; s kartice vodi na Home s fokusom na tu sezonu. |
| Restore purchases | mora postojati (store zahtjev), u Support tabu. U stub modu (bez storea) se ne crta. |
| Pillar 2 | kozmetika i sezone su samo izgled. Nijedan tekst ne smije sugerisati jači loot, magnet ili brži run. |
| Swipe | vodoravni swipe po praznom dijelu stranice i dalje lista hub (Shop je prva stranica s lijeva). Tabovi se ne mijenjaju swipeom. |

## 3. Šta se traži — cijeli Shop

Tačke 1–6 su **obavezne**. Izgled kartica, pozadina, tabovi i animacije su tvoja odluka. Jedan dizajn. Neka bude lijep.

1. **Četiri taba = četiri zasebna ekrana.** Svaki tab je svoja scena sa svojim elementima i **svojim vertikalnim skrolom**. Nema više jedne stranice sa skokom na sekciju. Tab bar je uvijek vidljiv na vrhu stranice; igrač u bilo kom trenutku tapne drugi tab. Svaki tab pamti svoj skrol dok je igrač u Shopu.
2. **Seasons je prvi i podrazumijevani tab.** Kad igrač otvori Shop iz footera, uvijek se otvara Seasons. Redoslijed ostala tri taba **predloži ti** i obrazloži u § Odlučeno. Izuzetak: link „More in Shop" iz Ormara otvara Looks (§6).
3. **Pozadina.** Makni zelenu `#2E4733`. Predloži pozadinu koja ide uz igru (cozy, pastel, flat — vidi Home, Ormar i hub chrome v2 u referencama). Kartice moraju ostati čitljive na njoj (kontrast teksta ≥ 4,5 : 1).
4. **Tabovi i dno stranice.** Dizajniraj tab bar Shopa (danas 4 „jump chipa" 120 visoka, aktivni peach) i kako se svaki tab završava na dnu (danas Fair note i Restore). Ovo je „header i footer" Shopa — ne hub chrome iz §2.
5. **Manje teksta.** Na svakoj kartici ostaje samo ono bez čega igrač ne zna šta kupuje. Sve iz §4 označeno „izbaciti" ide van. Ako misliš da još nešto treba van, izbaci i napiši u § Šta se briše.
6. **Jedno dugme za kupovinu.** Na svakoj kartici je **jedno** dugme koje je i cijena i kupovina (nema odvojenog PriceTaga + dugmeta „Get … / Buy 1"). Stanja tog dugmeta (kupi, čeka store, kupljeno, nema dovoljno coina, nedostupno) moraju se razlikovati oblikom/bojom, ne rečenicom ispod.
7. **Kartice smiju biti veće** (danas 1032 široke, visine 284–400). Više mjesta za pregled i portrete, manje za tekst.

## 4. Tabovi — šta se mijenja

Slike današnjeg stanja: `docs/04-experience/design-drafts/shop-v2-ref/` (1080 × 1920 iz igre, §7.2).

### 4.1 Seasons (prvi, podrazumijevani)

Danas (`season_pack_card.gd`): kartica u mood boji sezone, eyebrow „PREMIUM SEASON", ime 60, tagline, roster 3 × 2 tačke od 96 px, red „6 flowers for your Album · same runs, same rewards", PriceTag „€2.99 / one-time" + lavanda dugme „Get Moonlit Warren / yours to keep". Kupljena: „Play it on Home ↗ / owned · plays like a free season". Ember: „Not for sale yet / no price until it's ready".

| Traži se | |
|---|---|
| **Veće kartice** | da se portreti fino vide. |
| **Veći portreti cvijeća** | svih 6 cvjetova sezone, **pravi crtež** (danas se vidi samo obojena tačka). Igra crta portret isto kao na Home kartici sezone: `UiHomeV3.draw_flower()` → `CampPlantDraw.draw_cropped_plant()` (odrezan SVG, a za premium cvijeće bez SVG-a proceduralni cvijet u boji sezone — vidi `08_home_card_premium_portraits.jpg`). Da li ispod stoje imena — tvoja odluka. |
| **Izbaciti** | „6 flowers for your Album · same runs, same rewards"; „Get <sezona> / yours to keep"; „one-time" ispod cijene. Eyebrow „PREMIUM SEASON" i tagline — tvoja odluka (tab se već zove Seasons). |
| **Dugme** | jedno, s cijenom. Kupljena sezona: jedno dugme koje vodi na Home (kratko, npr. „Play"). Ember: bez dugmeta i bez cijene, jasno „uskoro". |

### 4.2 Looks

Danas (`shop_cosmetic_card.gd`, `shop_cosmetic_preview.gd`): grupisano po slotu s naslovom i podnaslovom („Pip skin · everywhere · wear one", „Meadow tint · run background · wear one", „Album frame · Journal page"); kartica = pregled „Now | With it" 440 × 284 + ime + opis + coin PriceTag + dugme („Buy & wear" → „Buy for ◎ n", ili „Need 30 more / earn in runs" kad nema coina). Kupljena: tag „Wearing" + „Your runs use this tint."

| Traži se | |
|---|---|
| **Iz kataloga Ormara** | slotovi, njihovi nazivi, ikone, redoslijed i stavke dolaze iz `game/data/cosmetics/cosmetics.json` — **isti izvor kao Ormar**. Nova stavka ili slot u tom fajlu se pojavi i u Shopu bez novog dizajna. Pregled stavke koristi iste vrste pregleda kao Ormar (`companion`, `meadow`, `album`, `swatch` — `design_handoff_wardrobe/design/ItemPreview.dc.html`). |
| **Veće kartice**, ljepši pregled | slobodno. „Now / With it" smije ostati ili ga zamijeni nečim boljim. |
| **Izbaciti** | podnaslove slotova („everywhere · wear one", „run background · wear one", „Journal page"), podnaslov sekcije („for coins · looks only"), „Need N more / earn in runs", „Buy & wear". Opis stavke — skrati ili izbaci, tvoja odluka. |
| **Dugme** | jedno, s cijenom u coinima. Zaštita od slučajne kupovine ostaje (npr. prvi tap pretvori isto dugme u potvrdu, drugi kupuje). **Nema dovoljno coina:** isto dugme s cijenom, ali drugačije stanje (prigušeno / drugi oblik) i tap daje kratku reakciju bez rečenice (npr. drhtaj dugmeta + puls coin chipa). |
| **Kupljeno** | tag na kartici (kupljeno / nosiš). Gdje se nosi i skida je Ormar; da li Shop zadržava „Wear" na kartici ili vodi u Ormar — tvoja odluka, ali stanje u Shopu i Ormaru je uvijek isto (jedan izvor: `GameState`). |

### 4.3 Boosters

Danas (`shop_booster_row.gd`): disk s ikonom, ime, opis, okvir „You have N", PriceTag „€0.99 / each", dugme „Buy 1 / +1 to your stock", „Use one" kad imaš, „Bag is full / trade seeds in Camp first".

| Traži se | |
|---|---|
| **Izbaciti** | „You have N", „+1 to your stock", „each", „Use one", „Bag is full / trade seeds in Camp first", podnaslov sekcije („optional helpers · one use each"). Opis — najviše jedna kratka linija ili ništa. |
| **Merge Hint** | postaje **jednokratna kupovina** (kupi jednom, imaš zauvijek). Kartica: jedno dugme s cijenom → poslije kupovine stanje „kupljeno". **Nema dizajna za mehaniku u Shopu**, ali treba dizajn **oznake u Areni** (§5.1). |
| **Loot Burst** | kupuje se **više puta**. Svaka kupovina odmah daje **5 ★3 cvjetova** sezone koja otključava sljedeću besplatnu sezonu (§5.2). Kartica pokazuje **koji** cvijet dobijaš (portret ★3 cvijeta te sezone) — tvoja odluka da li i napredak „n / 20". Kad igrač otključa sve besplatne sezone, kartica **nestaje**. |
| **Prazan tab** | kad je Merge Hint kupljen, a sve sezone otključane, tab ima samo kupljeni Merge Hint. Neka i to izgleda dovršeno. |

### 4.4 Support

Danas: Remove Ads (opis od dva reda, „€3.99 / one-time", „Remove ads / for good, on this account"), Starter Pack („A one-time bundle to get going.", 3 chipa sadržaja, „€1.99 / one-time", „Get the pack / once per account"), Restore purchases, Fair note („Everything here is optional…").

| Traži se | |
|---|---|
| **Izbaciti** | „one-time", „for good, on this account", „once per account", „A one-time bundle to get going." i dugi opis Remove Ads (najviše jedna kratka linija šta dobijaš). Fair note — jedna kratka rečenica ili ništa, tvoja odluka (Pillar 2 se ne mora pisati da bi vrijedio). |
| **Remove Ads** | jedno dugme s cijenom; kupljeno → „ads are off" stanje. |
| **Starter Pack** | novi sadržaj i rok od 7 dana (§5.3). Jedno dugme s cijenom; sadržaj kao vizuelni chipovi (100 coina, Pip Blossom, sjemenke). **Istekao** (7 dana prošlo, nije kupljen): kartica pod sivim prozirnim velom s katancem, kao isteklo — nije dodirljiva. Kupljen: stanje „claimed". Da li prikazati preostalo vrijeme (npr. „6d left") — tvoja odluka. |
| **Restore purchases** | ostaje, diskretno (link ili sekundarno dugme na dnu taba). |

## 5. Nove mehanike (radi agent; CD crta samo ono što se vidi)

### 5.1 Merge Hint — trajno, oznaka u Areni (TREBA DIZAJN ZA ARENU)

- Kupuje se **jednom** (non-consumable IAP, isti SKU `booster_merge_hint`). Restore ga vraća.
- Kad je kupljen: dok igrač **drži sjemenku** u Areni, **najbliža ista sjemenka** (isti tip i isti tier, najmanja udaljenost centara) je **posebno označena**. Pomjeranjem prsta najbliža se može promijeniti — oznaka prelazi na novu (bez treperenja kad su dvije skoro jednako daleko; agent dodaje histerezu).
- Danas, dok igrač drži sjemenku, **sve** iste sjemenke dobiju zlatni puls (`PULSE_GOLD #F2D940`, prsten 12 px), a magnet partner dobije prsten `#FFD56B` 14 px — vidi `12_arena_hold_pulses.jpg`. Oznaka Merge Hinta mora se **odmah razlikovati od oba** (drugi oblik, ne samo druga boja), i mora važiti pravilo dvostrukog ruba iz Arene v2 (taman vanjski rub + svijetla traka, kontrast ≥ 3 : 1 na svih 8 livada). Bez glowa, bez blura.
- Ako na polju nema iste sjemenke — nema oznake. Ako igrač nije kupio Merge Hint — sve kao danas.
- Isporuči: komponentu `MergeHintMark` (izgled, mjere, animacija ulaska/prelaska/izlaska), kadrove na 2 livade (Country Bloom svijetla, Moonlit Warren tamna) i tokene u `ui_shop_v2.gd` ili zasebno u exportu.
- Stari tekst „Hint: merge two … seeds." u oblačiću se briše.

### 5.2 Loot Burst — 5 ★3 cvjetova za sljedeću sezonu

- Kupuje se **više puta** (consumable, isti SKU `booster_loot_burst`), **odmah se primijeni** — nema inventara ni „Use one".
- Daje **+5** u `garden_crystal_stash` ★3 tipa (rarity 3) sezone koja je uslov za sljedeću zaključanu besplatnu sezonu. Sljedeća besplatna sezona traži 500 coina + 20 ★3 cvjetova prethodne (`seasons.gd → can_unlock_free`). Primjer: dok je sljedeća Frost Orchard, Loot Burst daje 5 × Harvest Pumpkin (★3 Country Bloom).
- Kad su sve besplatne sezone otključane (`next_locked_free_id()` prazan), Loot Burst se ne prodaje (kartica se ne crta).
- Coini (500) se ne dobijaju — Loot Burst ne kupuje cijelo otključavanje.

### 5.3 Starter Pack — 7 dana, novi sadržaj

- Rok: **7 dana od prvog pokretanja igre** (novo polje u saveu; postojećim igračima rok počinje pri prvom pokretanju nove verzije).
- Sadržaj: **100 coina**, **Pip Blossom** skin, **10 sjemenki od svakog od prvih 5 tipova** (clover, daisy, buttercup, tulip, sunflower — redom iz Country Bloom). **Merge Hint više nije u paketu.**
- Ako igrač već posjeduje Pip Blossom, paket daje ostalo, a skin se u sadržaju prikazuje kao već tvoj (cijena ista).
- Stanja: dostupan · čeka store · kupljen („claimed") · **istekao** (siv prozirni veo + katanac, nije dodirljiv). Kupljen ostaje kupljen i poslije 7 dana.

## 6. Veza s Ormarom

- Ormar (`design_handoff_wardrobe/`, u igri od 2026-10-01) je na polju sezone (pločica „Looks", 876, 1265, 180). Ne prodaje; jedini put u Shop je „More in Shop".
- **„More in Shop" otvara Shop na tabu Looks**, na slotu iz kojeg je igrač došao. Ulaz u Shop iz footera uvijek otvara Seasons.
- Looks tab i Ormar dijele: katalog (`cosmetics.json`), nazive i ikone slotova (`game/assets/ui/wardrobe/slot_*.svg`), vrste pregleda i Pip skin na pravom SVG-u (`pip_idle.svg` + recolor iz kataloga). Igrač mora prepoznati da je to isti svijet: ista kartica stavke ili jasno srodna.
- Stanje „kupljeno / nosiš" je isto u Shopu i Ormaru.

## 7. Danas u igri (orijentacija, ne obaveza)

### 7.1 Mjere i tokeni

Izvor: `game/scripts/visual/ui_shop.gd` (`UiShop`).

| Šta | Vrijednost |
|---|---|
| Stranica | 1080 × 1633, padding x 24, kartice 1032 široke, radius kartice 26, dugme 20 |
| Tab red danas | visina 160 (jump chip 120, gap 14, font 42); sadržaj počinje na 184 |
| Pozadina | `#2E4733` (ide van) |
| Kartica kozmetike | 284 visoka; pregled 440 × 284 („Now | With it") |
| Kartica sezone | padding 24, roster 316 širok, 6 portreta po 96 px (prazni), ime 60 |
| Booster | disk 112, ikona 64, „You have" okvir 190 × 112 |
| Dugmad | coin akcija 120 visoka, novac 130; cijena min 190–280 |
| Tekst | ime 48, tijelo 38, naslov sekcije 56; minimum teksta 38, cijene 44, dodir ≥ 120 |
| Boje | krem `#FFF8F0`, ink `#2D3436`, sub ink `#555C5E`, coin `#E8C44A`/`#FFD56B`, pravi novac lavanda `#D4A5FF`, aktivno peach `#FFB88C`, mint `#A8E6CF`, fail roze `#FFCCD5` |

### 7.2 Slike iz igre (`docs/04-experience/design-drafts/shop-v2-ref/`)

| Fajl | Šta je |
|---|---|
| `01_shop_looks.jpg` … `04_shop_support.jpg` | današnji Shop, svaka sekcija od vrha |
| `05_…`, `06_…`, `07_…` | sredina skrola (Meadow tint, Seasons, Boosters + Support) |
| `08_home_card_premium_portraits.jpg` | Home kartica premium sezone — **ovako igra već crta portrete cvijeća** |
| `09_field_looks_tile.jpg` | polje sezone s pločicom Looks (Ormar) |
| `10_wardrobe_sheet.jpg`, `11_wardrobe_empty.jpg` | Ormar otvoren, prazno stanje s „More in Shop" |
| `12_arena_hold_pulses.jpg` | Arena dok igrač drži Field Daisy: sve iste sjemenke imaju zlatni puls — polazište za Merge Hint oznaku |

## 8. Paleta i tehnika

Postojeći tokeni: `ui_shop.gd`, `ui_palette.gd`, `ui_home_v3.gd`, `ui_wardrobe.gd`, `ui_arena_v2.gd`. Nova boja samo kao svjetlija ili tamnija varijanta postojeće, označena u README.

Godot 4.7, OpenGL, slabiji Android. Artboard 1080 × 1920, sve u px te baze. Paneli = ravna boja, radius, rub, jedna tvrda sjena. **Bez blura, glowa i gradijenata.** Animacije su tweenovi (skala, pozicija, alpha, boja). Najviše jedan loop na ekranu. Tekst ≥ 34 px (ime i cijena ≥ 44), dodir ≥ 120 px, kontrast teksta ≥ 4,5 : 1. Nove ikone kao SVG u stilu chrome v2 (`game/assets/ui/chrome/`). Novi asseti ukupno ≤ 150 KB, bez PNG pozadina.

## 9. Isporuka

### 9.1 Stanja

1. **Seasons tab** (podrazumijevani): Moonlit za kupiti, Coral kupljena, Starfall čeka store, Ember coming soon.
2. **Looks tab**: stavka za kupiti, potvrda (drugi tap), nema dovoljno coina (s reakcijom na tap), kupljena / nosiš; svi slotovi iz `cosmetics.json`.
3. **Boosters tab**: Merge Hint za kupiti i kupljen; Loot Burst sa ★3 cvijetom za Frost Orchard; tab kad je Loot Burst nestao.
4. **Support tab**: Remove Ads za kupiti i kupljen; Starter Pack dostupan, kupljen i **istekao**; Restore.
5. **Prelaz između tabova** i ulaz u Shop (iz footera → Seasons; iz Ormara → Looks na slotu).
6. **Neuspjeh / otkazano / pending** na jednoj kartici pravim novcem.
7. **Dugačka cijena** („Rp 57.900") na sezoni i boosteru.
8. **Arena — Merge Hint oznaka** na Country Bloom i Moonlit Warren: drži se sjemenka, najbliža ista označena, ostale iste sa današnjim pulsom; prelazak oznake na novu najbližu.

### 9.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_shop_v2/
  README.md                 šta otvoriti · § Odlučeno (uklj. redoslijed tabova i pozadinu)
                            · § Šta se briše (svaki tekst koji ide van) · § Stanja dugmeta
                            · § Merge Hint u Areni · § Samoprovjera · § Ideje van zadatka
  design/
    ShopScreen.dc.html      prop tab (seasons|looks|boosters|support), scene (stanja §9.1),
                            price (eur|km|long), coins, starter (available|bought|expired)
    ArenaMergeHint.dc.html  prop season, held, nearest
    Shop Specs.dc.html      anatomija svake kartice, stanja dugmeta, tabovi, prelaz,
                            Merge Hint oznaka, prije → poslije
    support.js · icons/
  godot/
    shop_v2_export.json     meta · tokens · layout · components · states · animations ·
                            strings_en · godot_map · decisions
    ui_shop_v2.gd           konstante; isti nazivi gdje postoje u ui_shop.gd
    shop_tree.txt           stablo čvorova + red prenosa
```

**Imena slojeva:** `ShopPage`, `ShopBg`, `ShopTabBar`, `ShopTab`, `TabPage_Seasons`, `TabPage_Looks`, `TabPage_Boosters`, `TabPage_Support`, `SeasonCard`, `SeasonPortraits`, `FlowerPortrait`, `CosmeticCard`, `CosmeticPreview`, `BoosterCard`, `SupportCard`, `StarterPackCard`, `StarterContent`, `ExpiredVeil`, `BuyButton`, `OwnedTag`, `PurchaseStatus`, `RestoreLink`, `MergeHintMark`.

### 9.3 Samoprovjera (u README, svaka stavka da/ne, provjereno u browseru)

1. Četiri taba, svaki svoj ekran sa svojim skrolom; ulaz iz footera otvara Seasons.
2. Na svakoj kartici koja nešto prodaje postoji tačno jedno dugme za kupovinu, i ono nosi cijenu.
3. Nijedan tekst iz §4 označen „izbaciti" se ne pojavljuje.
4. Portreti sezona su pravi crteži cvijeća, svih 6, veći od 96 px.
5. Looks tab je napravljen iz `cosmetics.json` (isti katalog kao Ormar).
6. Starter Pack ima stanje „istekao" (siv veo + katanac) i nije dodirljiv; sadržaj je 100 coina + Pip Blossom + 5 × 10 sjemenki, bez Merge Hinta.
7. Merge Hint oznaka se razlikuje od pulsa i od magnet prstena oblikom, ima taman rub i ≥ 3 : 1 na obje livade.
8. Dugačka cijena stane bez rezanja; tekst ≥ 34 (ime i cijena ≥ 44), dodir ≥ 120, kontrast ≥ 4,5 : 1.
9. Nigdje blur, glow ni gradijent; najviše jedan loop; nema zelene `#2E4733`.

## 10. Ne tražimo

- Hub header i footer (chrome v2), druge stranice huba, Ormar (osim veze iz §6).
- Nove cijene, nove proizvode, novu valutu.
- Novi art cvijeća ili Pipa (portreti i Pip se crtaju iz igre).
- Dizajn mehanike Loot Bursta i Starter Packa izvan Shop kartice.
- Više varijanti — jedan dizajn.

## 11. Pillar 2 i scope

- Shop je na launch IN listi (M8): remove ads, starter pack, boosteri, kozmetika, sezone.
- **Merge Hint trajno:** pomoć u prepoznavanju para, ne mijenja loot, merge ni ekonomiju i ne blokira ništa besplatnim igračima (pulsevi za sve iste sjemenke ostaju svima). U skladu s Pillar 2.
- **Loot Burst → ★3 cvjetovi:** ubrzava otključavanje besplatne sezone, a sezona je samo tema („same runs, same rewards"). Besplatno otključavanje igrom ostaje isto; coini se ne kupuju. Svjesna odluka 2026-10-01 — Pillar 2 primjer „❌ pay-to-win množitelji" se ne odnosi (nema snage ni množitelja).
- **Starter Pack 7 dana:** rok je za ponudu, ne za igru; ništa u igri ne nestaje kad istekne.
- Agent pri prenosu ažurira `scope-i-granice.md` i ekonomiju za tri promijenjene ponude.

## 12. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je DRUGA RUNDA REDIZAJNA Shopa. Sadržaj ostaje (sezone, kozmetika,
boosteri, support), cijene se ne mijenjaju — mijenja se raspored, količina
teksta i izgled. Uz to crtaš jednu oznaku u Areni (Merge Hint).

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/shop-v2-cd-brief.md
    -> §2 (fiksno), §3 (cijeli Shop), §4 (svaki tab: danas -> traži se),
       §5 (nove mehanike: Merge Hint, Loot Burst, Starter Pack),
       §6 (veza s Ormarom), §7 (mjere + slike), §8 (tehnika), §9 (isporuka)
  docs/04-experience/design-drafts/shop-v2-ref/          (12 slika iz igre)
  design_handoff_shop/                                   (tvoj prvi Shop)
  design_handoff_wardrobe/                               (tvoj Ormar — ItemCard,
                                                          ItemPreview, ikone slotova)
  design_handoff_home_v3/                                (Home, portreti cvijeća)
  design_handoff_arena_v2/                               (Arena: pravilo dvostrukog
                                                          ruba, livade, sjemenka)
  game/data/cosmetics/cosmetics.json                     (katalog kozmetike)
  game/scripts/visual/ui_shop.gd                         (tokeni Shopa danas)
  game/scripts/ui/season_pack_card.gd, shop_cosmetic_card.gd,
    shop_booster_row.gd, shop_screen.gd                  (kartice i tekstovi danas)
  game/scripts/monetization/monetization_config.gd       (proizvodi i cijene)
  game/scripts/visual/ui_home_v3.gd -> draw_flower()     (kako igra crta portret)

ŠTA TRAŽIM:

1. ČETIRI TABA = ČETIRI EKRANA. Svaki tab je svoja scena sa svojim
   elementima i SVOJIM vertikalnim skrolom (nema više jedne duge stranice
   sa skokom na sekciju). Tab bar uvijek vidljiv; svaki tab pamti skrol.
   SEASONS je prvi i podrazumijevani — Shop iz footera uvijek otvara
   Seasons. Redoslijed ostala tri taba predloži i obrazloži. "More in Shop"
   iz Ormara otvara Looks na slotu iz kojeg se došlo. Vodoravni swipe i
   dalje lista hub — tabovi se mijenjaju tapom.

2. NOVI IZGLED. Makni zelenu pozadinu #2E4733 i daj nešto što ide uz igru
   (cozy, pastel, flat — pogledaj Home, Ormar, hub chrome v2). Dizajniraj
   tab bar Shopa i kako se svaki tab završava na dnu. Hub header i footer
   (chrome v2) su zajednički svim stranicama — NE diraj ih.

3. MANJE TEKSTA, JEDNO DUGME. Na svakoj kartici koja prodaje je TAČNO
   JEDNO dugme koje nosi cijenu i kupuje (nema PriceTag + "Get ..."/"Buy 1").
   Stanja dugmeta (kupi, potvrdi, čeka store, kupljeno, nema coina,
   nedostupno) se razlikuju oblikom/bojom, ne rečenicom. Kartice smiju biti
   veće. Izbaci sav tekst iz §4 označen "izbaciti", npr.:
   - Seasons: "6 flowers for your Album · same runs, same rewards",
     "Get <sezona> / yours to keep", "one-time".
   - Looks: "everywhere · wear one", "run background · wear one",
     "Journal page", "for coins · looks only", "Need N more / earn in runs",
     "Buy & wear".
   - Boosters: "You have N", "+1 to your stock", "each", "Use one",
     "Bag is full / trade seeds in Camp first".
   - Support: "one-time", "for good, on this account", "once per account",
     dugi opis Remove Ads.

4. SEASONS TAB. Veće kartice i VEĆI PORTRETI svih 6 cvjetova — PRAVI
   crteži (danas se vidi samo obojena tačka od 96 px). Igra crta portret
   kao na Home kartici: UiHomeV3.draw_flower() (slika
   shop-v2-ref/08_home_card_premium_portraits.jpg). Kupljena sezona: jedno
   dugme koje vodi na Home. Ember Fen: uskoro, bez cijene i dugmeta.

5. LOOKS TAB. Slotovi, nazivi, ikone i stavke iz cosmetics.json — ISTI
   katalog kao Ormar; nova stavka u tom fajlu se pojavi i u Shopu bez novog
   dizajna. Pregled iz istih vrsta kao Ormar (ItemPreview). Coin kupovina se
   ne smije desiti slučajno (npr. prvi tap = potvrda na istom dugmetu).
   Nema dovoljno coina: isto dugme u drugom stanju + kratka reakcija na tap,
   bez rečenice. Stanje kupljeno/nosiš isto kao u Ormaru.

6. BOOSTERS TAB.
   - MERGE HINT postaje JEDNOKRATNA kupovina (imaš zauvijek). U Shopu samo
     kartica s dugmetom -> stanje kupljeno. TREBA DIZAJN ZA ARENU: dok
     igrač drži sjemenku, NAJBLIŽA ISTA sjemenka (isti tip i tier) je
     posebno označena; pomjeranjem oznaka prelazi na novu najbližu. Danas
     SVE iste sjemenke imaju zlatni puls (#F2D940, prsten 12 px) i magnet
     partner prsten #FFD56B 14 px (slika 12_arena_hold_pulses.jpg) —
     oznaka se mora razlikovati od oba OBLIKOM, imati taman vanjski rub +
     svijetlu traku (pravilo dvostrukog ruba Arene v2, >= 3:1 na svih 8
     livada), bez glowa. Komponenta MergeHintMark + ArenaMergeHint.dc.html
     na Country Bloom i Moonlit Warren.
   - LOOT BURST se kupuje VIŠE PUTA i odmah daje 5 ★3 cvjetova sezone koja
     otključava sljedeću besplatnu sezonu (npr. 5 × Harvest Pumpkin dok je
     sljedeća Frost Orchard). Pokaži koji cvijet dobijaš. Kad su sve
     besplatne sezone otključane, kartica NESTAJE.

7. SUPPORT TAB. Remove Ads i Starter Pack, svaki jedno dugme. Restore
   purchases ostaje, diskretno.
   STARTER PACK: traje 7 DANA od prvog pokretanja. Sadržaj: 100 coina,
   Pip Blossom skin, po 10 sjemenki prvih 5 tipova (clover, daisy,
   buttercup, tulip, sunflower) — BEZ Merge Hinta. Sadržaj kao vizuelni
   chipovi. Poslije 7 dana (nije kupljen): ISTEKAO — siv prozirni veo preko
   kartice + katanac, nije dodirljiv. Stanja: dostupan, čeka store,
   kupljen, istekao.

FIKSNO: cijene i proizvodi (§2); cijena je store string (dugačka ->
44 px, dugme raste); boja razlikuje coine od pravog novca; jedna IAP
kupovina u isto vrijeme; Pillar 2 — kozmetika i sezone su samo izgled,
nijedan tekst ne sugeriše snagu.

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920,
stranica 1080 x 1633 između headera 143 i footera 144, sve u px te baze.
Ravne boje, radius, rub, jedna tvrda sjena. BEZ blura, glowa i
gradijenata. Animacije su tweenovi. Najviše jedan loop. Tekst >= 34 px
(ime i cijena >= 44), dodir >= 120, kontrast >= 4,5:1. Novi asseti
<= 150 KB, bez PNG pozadina.

ISPORUKA (§9): novi folder design_handoff_shop_v2/, CIJELI U ZIPU za
preuzimanje u chatu:
  design/ShopScreen.dc.html (prop tab, scene, price, coins, starter),
  ArenaMergeHint.dc.html, Shop Specs.dc.html (sva stanja §9.1),
  support.js, icons/
  godot/shop_v2_export.json, ui_shop_v2.gd, shop_tree.txt
  README.md sa § Odlučeno, § Šta se briše, § Stanja dugmeta,
  § Merge Hint u Areni i § Samoprovjera (9 stavki iz §9.3, svaka da/ne,
  provjereno u browseru PRIJE nego pošalješ zip).

NE RADI: hub header/footer, druge stranice huba, nove cijene ili
proizvode, novi art cvijeća ili Pipa, više varijanti. Jedan dizajn, tvoj
izbor, neka bude lijep.
```

## Povezano

- [[../../06-production/CHECKPOINT|CHECKPOINT]] — traka SHOP-02
- [[shop-cd-brief|Shop runda 1]] — prvi redizajn (`design_handoff_shop/`)
- [[wardrobe-cd-brief|Ormar]] — isti katalog kozmetike
- [[home-v3-cd-brief|Home v3]] — portreti cvijeća na kartici sezone
- [[merge-arena-cd-brief|Arena]] — pravilo dvostrukog ruba, livade
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
