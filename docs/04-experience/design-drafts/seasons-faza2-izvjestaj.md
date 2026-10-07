---
type: iskustvo
status: aktivan
milestone: "—"
tags: [dizajn, sezone, cvijece, home, shop, camp, arena, run, claude-design, izvjestaj]
povezano:
  - seasons-izvjestaj
  - seasons-cd-brief
  - changelog
  - CHECKPOINT
ai_sažetak: "Izvještaj o prenosu CD paketa design_handoff_seasons faza 2 (svih 8 sezona) u Godot 2026-10-06: šta je u igri po površini, 12 koraka PREPORUKA s presudom, provjere (kontrast isti kao CD, JS = Godot), šta je obrisano i šta je namjerno ostalo, i odluke koje su na tebi objašnjene korak po korak."
---

# Sezone, faza 2: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · faza 1: [[seasons-izvjestaj]] · brief: [[seasons-cd-brief]] · paket: `design_handoff_seasons/` (faza 2, PREPORUKE_ZA_CLAUDE_CODE.md) · datum: 2026-10-06 · slike: `design-drafts/seasons-faza2/` (01–08)

## Ukratko

**Svih 8 sezona je sada mjesto, ne boja, na svakoj površini.** Frost Orchard, Lantern Meadow, Amber Canopy, Coral Tide Garden, Starfall Glade i Ember Fen su dobili isto što su CB i MW dobili u fazi 1. To vrijedi za Home karticu i polje, Shop karticu (plaćene sezone), Camp karticu (Frost, Lantern i Amber), Arenu i run.

- **Isti renderer, novi oblici.** `SeasonBackdrop` sada razumije i slojeve faze 2: red motiva duž grebena ili girlande, poligone sa zaglađivanjem, elipse, linije, krošnju odozgo i nagnutu obalu. Nijedna sezona nema svoj kod, svaka je samo red podataka u `seasons_kit.json`.
- **Godot crta isto što i CD.** Kontrast izmjeren iz geometrije u igri daje **iste brojeve kao CD-ova samoprovjera**: naljepnice Amber 6,42 · Frost 7,35 · CB 7,41, tekst Frost 5,54 · MW 6,87, coin / staza Frost 3,26 · Coral 4,02. Slike 02–04 pokazuju CD-ov crtež i crtež iz igre jedan pored drugog, za svih 8 polja i 7 Shop i Camp kartica.
- **108 novih crteža cvijeća i 12 novih prepreka.** Kodom crtani krug više se ne vidi ni za jedan od 48 tipova.
- **Ambijent je generički.** Pahulje, svici, lišće s prašinom, mjehurići s odsjajima, zvijezde s meteorima i žeravica s dimom rade kroz isti kod na polju i u runu. Najviše ima 22 čestice (Starfall), a budžet je 24.
- **Polje je življe.** Cvijeće se njiše ±3°, a kad Pip spava, ambijent se smiri na 35 %. Kad Pip njuši, cvijet se nakloni i iz njega se podignu tri čestice oblika ambijenta sezone (pahulje na Frostu, svici na Lanternu).
- **Obrisano je ono što više nema smisla.** Tint sezone u runu (`SeasonTheme`) je nestao, kao i stare tri trake na Home kartici, polju i Shop kartici. Nestale su i sezonske nijanse proceduralnog cvijeća (`SEASON_HUE`).

## Šta je na tebi: odluke i poslovi, objašnjeno

CD je napisao „ostaju cijene i dvije odluke". Evo šta to znači u praksi, plus nekoliko stvari koje sam našao usput. Kod za sve ovo je spreman. Odluka se svodi na jednu konstantu ili na posao van koda.

### Odlučeno 2026-10-06 (po preporuci)

- [x] **Polje ostaje T3** (2). Bez izmjene koda.
- [x] **Reduce motion gasi i ambijent** (3): `UiSeasons.REDUCE_MOTION_STOPS_AMBIENT = true`. `season_meadow_smoke` sada provjerava da Reduce motion zaustavi njihanje i ambijent i da se oboje vrati kad se ugasi.
- [x] **Raster 256 ostaje** (5). Mjerenje memorije na slabijem Androidu ide u playtest.
- [x] **C2PA metapodaci ostaju** (5).
- [ ] **Cijene** (1): kod je spreman, ali tri stvari su i dalje tvoje. (a) Iznosi: nisam ih preporučio, rezervne cijene su ostale. (b) Proizvodi u Play Consoleu (tvoj nalog). (c) „Da" za skidanje Billing plugina. Nalaz za (c): plugin 3.x pravi `BillingClient` kao GDScript klasu (`BillingClient.new()`), a `iap_manager.gd` ga traži preko `ClassDB`, koji vidi samo klase iz engine-a. Uz plugin zato ide i izmjena `_try_init_billing()`. Vidi [[../../05-technical/godot/iap-billing-setup|iap-billing-setup]].
- [ ] **Bez preporuke, ostaje tebi:** tempo njihanja (4, provjera na telefonu), swipe između kartica i vreća 100 / 40 (5), mjesta van paketa (6) i puštanje Embera (7).

### 1. Prave cijene iz Play Storea (posao van koda)

**Šta je problem.** Shop pokazuje cijenu na dugmetu sezone. Igra pita Google Play za cijenu u valuti igrača (`formatted_price`, npr. „4,99 KM" ili „€2,99") i nju prikaže. To je već napisano u `iap_manager.gd`. Dok Play ne odgovori, igra pokazuje rezervne cijene iz `monetization_config.gd`: MW €2,99 · Coral €3,49 · Starfall €2,99 · Ember €3,49 (Ember se ne vidi dok je „uskoro"). CD je u maketi koristio iste brojeve kao primjer. To nisu tvoje cijene, nego mjesto za njih.

**Zašto Play sada ne odgovara.** U projektu nije instaliran Google Play Billing plugin za Godot, a Android export nema uključen Gradle build. Igra zato radi u „stub" modu.

**Šta trebaš uraditi ti:**
1. **Odluči cijene** po paketu sezone (poslovna odluka). Pillar 2 ostaje: plaćena sezona je tema, ne snaga, i nema tajmera, popusta ni „limited".
2. U **Google Play Consoleu** napravi in-app proizvode s tačno ovim ID-evima: `season_pack_moonlit_warren`, `season_pack_coral_tide`, `season_pack_starfall_glade` (Ember kasnije: `season_pack_ember_fen`). Unesi cijenu u EUR, a Play je sam preračuna u druge valute.
3. Kad mi kažeš, ja ubacim **Billing plugin** i uključim Gradle build u exportu. To je posao u kodu i konfiguraciji, ali plugin se skida s interneta, pa mi za to treba tvoje „da".
4. Postavi build na **internal testing** u Play Consoleu. Tek tada vidiš prave cijene na telefonu.
5. U `monetization_config.gd` stavi svoje EUR cijene u `price_label` kao rezervu. To mogu i ja kad mi javiš brojeve.

### 2. Polje: T3 ili T2 cvijeće (odluka, jedna konstanta)

**Šta je pitanje.** Na polju izraste do 13 cvjetova. Svaki tip cvijeta ima tri crteža: T1 je pupoljak, T2 je cvijet u punom cvatu, a T3 je isti cvijet s kristalom, najrjeđi oblik (★3). Sada je **svih 13 mjesta T3**, kao u fazi 1.

- **T3 (sada):** polje izgleda kao nagrada, a veza „spojiš ★3 u Areni → izraste na polju" je očigledna. Minus: 13 kristala odjednom može djelovati prenatrpano, a kristal je na polju manje poseban.
- **T2:** polje je mirnije i prirodnije, a kristal ostaje znak ★3 u Albumu, Campu i Areni. Pravilo rasta se ne mijenja: mjesto i dalje raste od ★3 cvjetova.

**Moja preporuka:** ostavi T3, jer drži vezu Arena → polje čitljivom. Pogledaj sliku 01 i odluči na oko. Promjena je jedan broj (`plant_tier = 3` u `setup_spot` u `season_field_flower.gd`).

### 3. Reduce motion: gasi li i ambijent? (odluka, jedna konstanta)

**Šta je pitanje.** „Reduce motion" je opcija za igrače kojima kretanje na ekranu smeta (vrtoglavica, fokus). Njihanje cvijeća sigurno gasi. Pitanje je da li gasi i ambijent, tj. pahulje, svice i lišće koje lebdi.

- **Bilo:** gasi samo njihanje (kako stoji u koraku 4 paketa). **Odlučeno 2026-10-06:** gasi i ambijent (`UiSeasons.REDUCE_MOTION_STOPS_AMBIENT = true`).
- **Moja preporuka:** `true`. Ambijent je čisti ukras, a uobičajeno pravilo pristupačnosti je da se ukrasno kretanje zaustavi. Čestice tada stoje mirno na srednjoj providnosti i ne nestaju.
- **Važno:** ekran Settings još ne postoji (D0-P). Prekidač je spreman (`GameState.reduce_motion`), ali igrač ga još nema gdje uključiti. Kad se pravi Settings, treba ga povezati i snimiti u save.

### 4. Tempo njihanja (provjeri na oko)

PREPORUKE kažu da je jedan puni zamah 3–5 s, i tako sam napravio. CD-ova HTML maketa njiše otprilike duplo sporije (6–10 s po zamahu), zbog toga kako CSS animacija ide naprijed-nazad. Ako ti se na telefonu čini prebrzo, to su dvije konstante (`UiSeasons.SWAY_SEC` / `SWAY_STEP`).

### 5. Otvoreno još iz faze 1

- [x] **Raster cvijeća 256 px** (odlučeno: ostaje). Sada je to 144 crteža. Ako bi se svi učitali odjednom (npr. Album sa svim sezonama), to je do oko 37 MB teksture, i ostaju u kešu. Preporuka: ostavi 256 i izmjeri na slabijem Androidu. Ako zatreba, 192 px je jedna izmjena importa.
- [x] **C2PA metapodaci u SVG-ovima** (odlučeno: ostaju) („content credentials", oznaka porijekla crteža). Ispravka faze 1: oni **ne ulaze u APK**, jer se cvijeće pakuje kao gotova tekstura, a SVG izvor ide u APK samo za Pipa. Zauzimaju oko 1,1 MB u repou. Preporuka: ostavi ih.
- [ ] **Swipe između kartica** (Nalaz 7 faze 1). Dok kartica blijedi, slojevi livade se kratko vide jedan kroz drugi, i to sada na svih 8 sezona. Prihvati ili traži popravku (CanvasGroup ili zamjena bez providnosti).
- [ ] **Vreća 100 / 40 u tvom saveu** (od dev skripte). I dalje važi ako je nisi potrošio.

### 6. Van paketa sezona, samo da znaš

Ova tri mjesta crtaju sezonu po starom, a CD ih nije obuhvatio. Ostavio sam ih namjerno. Ako želiš, mogu ući u sljedeći brief:
- **Camp, badge „Kept · N / M"** na rezervisanom cvijeću koristi stari tint sezone (`UiCamp.season_tint`). Boje recepta Campa su preblijede za badge na krem pločici, pa to traži odluku dizajna.
- **Shop, vinjeta Loot Bursta** crta tri trake sljedeće besplatne sezone ispod tamnog teksta (`UiShopV2.season_bands`). Recept bi na tamnoj sezoni (Lantern) ugasio tekst.
- **Ormar, pregled Pipa** (companion) crta male tri trake livade aktivne sezone.

Pregled tinta livade u Ormaru i Shopu sada uzima tlo i stazu runa iz kita (kao pravi run), umjesto starog tinta sezone.

### 7. Ember Fen „uskoro"

O tome da li je Ember „uskoro" odlučuje kod igre (`Seasons.TEST_LOCK_PAID_ID = "ember_fen"`), a kit samo ponavlja isto (`soon: true`). Kad budeš puštao Ember, promijeni oboje. Ja to mogu uraditi u jednom koraku.

## Status: sezona × površina

| Sezona | Kartica | Polje | Shop | Camp kartica | Arena | Run + 2 prepreke | Ambijent (polje / run) |
|---|---|---|---|---|---|---|---|
| Country Bloom | ✅ | ✅ | — | — | ✅ | ✅ pruge | latice 14 / 12 |
| Frost Orchard | ✅ | ✅ | — | ✅ (Pumpkin) | ✅ | ✅ trag sanki | pahulje 18 / 14 |
| Lantern Meadow | ✅ | ✅ | — | ✅ (Crystal Peony) | ✅ | ✅ kamenčići | svici 16 / 12 |
| Amber Canopy | ✅ | ✅ | — | ✅ (Midnight Lotus) | ✅ | ✅ lišće | lišće + prašina 20 / 12 |
| Moonlit Warren | ✅ | ✅ | ✅ | — | ✅ | ✅ kamenčići | zvijezde + mrvice 18 / 14 |
| Coral Tide Garden | ✅ | ✅ | ✅ | — | ✅ | ✅ daske | odsjaji + mjehurići 16 / 10 |
| Starfall Glade | ✅ | ✅ | ✅ | — | ✅ | ✅ zvjezdana prašina | zvijezde + meteori + latice 22 / 12 |
| Ember Fen | ✅ uskoro (isprekidan rub) | ✅ (otvara se kad Ember izađe) | ✅ uskoro | — | ✅ | ✅ daske | žeravica + dim 18 / 14 |

## PREPORUKE po koracima

| # | Korak | Presuda | Napomena |
|---|---|---|---|
| 0 | Priprema (JSON, ui_seasons, asseti) | ✅ | `seasons_kit.json` = CD-ov export. **`ui_seasons.gd` nije prepisan, nego spojen:** CD-ova kopija čita `r2` koji je u novom JSON-u premješten u `tokens`, i nema popravku kontrasta iz faze 1 (sRGB → linearno). 108 cvjetova i 12 prepreka su novi. 36 starih crteža i Pipove poze su isti crteži (razlikuju se samo C2PA metapodaci), pa nisu prepisani. Novi cvjetovi imaju raster 256 kao faza 1. |
| 1 | SeasonBackdrop, svi slojevi | ✅ | row, poly (Catmull-Rom), ellipse, line, `ridge.up` / `tilt`, shape s listom tačaka, `scatter.noAvoid`. Greben se uzorkuje 0–100. Mreža se gradi jednom po sezoni (3–16 ms na laptopu), po frejmu nema računanja. Poređenje s CD-ovim `buildScene` je na slikama 02–04. |
| 2 | Home kartica i polje | ✅ | Svih 8 crta recept, jer je kartica = polje već iz faze 1. Novo je isprekidan rub kartice „uskoro" (Ember). Imena cvijeća u boji kita, stranica u boji kita, ★3 prethodne sezone na zaključanoj i swipe od 0,22 s već su postojali. |
| 3 | Ambijent | ✅ | Jedan generički `SeasonAmbient` za svih 8 i za run (isti kod). Stare grane `petals` / `stars_motes` su obrisane. |
| 4 | Animacije polja | ✅ | Njihanje (jedna petlja za svih 13 cvjetova, samo na otvorenom polju), Pip spava → ambijent 0,35, njuškanje s česticama oblika ambijenta, naklon 1 → 1,08 → 1. Na polju su najviše 2 petlje. Pip zona je ista. |
| 5 | Looks pločica | ✅ | Već postoji (Ormar). Novi keepout iz JSON-a je uključen. |
| 6 | Shop | ✅ kod · ⏳ cijene | Coral, Starfall i Ember crtaju panoramu, Ember bez cijene i dugmeta. Cijene: vidi „Šta je na tebi" 1. |
| 7 | Camp kartica | ✅ | Recept „camp" unutar ruba 3 `#2D3436`, tekst `#3D3D33`, jedna tvrda sjena 0 8 0, uglovi maskirani bojom stranice Campa. Cvijet i prsten burst su bili po specifikaciji. |
| 8 | Arena | ✅ | Svih 8 se spaja s kitom. Test provjerava da svaki ključ kita pogodi sloj. Popravljeno: kad kit da paletu, stare varijante se brišu (kao u JS-u), inače bi pobijedile. |
| 9 | Run | ✅ | Materijal staze iz kita (pruge, kamenčići, daske, trag sanki) stoji između rubova staze (unutrašnjost 192 px), daljina i blizina iz kita, 16 prepreka, kolizija 64 × 64. |
| 10 | Brisanje | ✅ uz izuzetke | Obrisani su `SeasonTheme`, mrtva `UiShop.preview_lane_colors`, trake na Home kartici, polju i Shop kartici, i `SEASON_HUE`. Namjerno ostaje ono iz „Šta je na tebi" 6, plus proceduralni crtež cvijeta kao rezerva ako SVG fali. |
| 11 | Testovi | ✅ | Vidi Testovi. Performanse na slabijem Androidu traže uređaj (playtest). |
| 12 | Odluke | ⏳ | Vidi „Šta je na tebi". |

## Nalazi

1. **CD-ov `ui_seasons.gd` ne bi radio s njegovim novim JSON-om.** Čita `data()["r2"]`, a export faze 2 je premjestio R2 niz u `tokens.r2`. Tu je i stari kontrast bez sRGB → linearno (u fazi 1 smo ga ispravili da daje iste brojeve kao JS). Spojio sam CD-ove nove funkcije s postojećim fajlom.
2. **Staza runa je 200 px, a pločica materijala 192.** To je unutrašnjost između rubova od 4 px (`surfaces.run.lane_inner`), pa pločica ide od x = 4 i ne rasteže se.
3. **Dva stara testa su provjeravala staro ponašanje.** `season_home_smoke` je mjerio tri trake na Lantern kartici, a `season_run_smoke` je tražio drugačiji tint runa za Frost. Sada provjeravaju isti recept na kartici i polju, odnosno run kita (tlo i trag sanki), a tint ostaje samo kozmetika.
4. **Nekoliko stvari koje je CD stavio za brisanje imaju i druge korisnike** (Ormar, badge u Campu, vinjeta Loot Bursta). Vidi „Šta je na tebi" 6.

## Poslije playtesta (2026-10-06)

- **Čestice su se kretale previše jednako.** Po CD-ovom kitu sve čestice jednog sloja imaju istu brzinu, put, njihanje i rotaciju, pa crtaju istu putanju pomjerenu u vremenu. Svaka čestica sada ima svoju varijantu (`SeasonAmbient.vary_layer`: brzina, jačina i bočni smjer puta, njihanje, okretanje i faza), a latice na vjetru blago lepršaju. Ovo je **namjerno odstupanje od paketa** po tvom playtestu. CD-ova formula `ambient_at` je ista.
- **Crystal Peony iz Shopa nije bio u Journalu.** Loot Burst je dodavao ★3 samo u stash, a ne u Album. Popravljeno, a stari saveovi se popravljaju pri učitavanju.
- **Journal** je brži i puni se po tri sezone (aktivna sezona je prva). Vidi changelog 2026-10-06.

## Testovi

- **Novi `season_kit_all_smoke`:** za svih 8 sezona gradi recept polja, Shopa i Campa i provjerava da sve stoji unutar recta. Učitava 18 crteža i 2 prepreke po sezoni, provjerava budžet ambijenta na polju i u runu, i run (materijal, daljina, blizina). Provjerava i Arena spajanje (svaki ključ pogađa sloj) i Camp cvijet = ★3 prethodne sezone. Kontrast mjeri iz geometrije recepta, s istim kontrolama, ispunama i pravougaonicima kao CD-ova samoprovjera, i brojevi su isti.
- **Novi GUT `test_season_kit_parity`:** `ridge_y`, `scatter_at`, čestice ambijenta i `ambient_at` (svih 6 vrsta kretanja) daju iste brojeve kao CD-ov `seasons_kit.js` za 8 sezona. Referenca je izračunata iz JS-a (`scripts/art/gen_season_kit_parity.mjs`). Cijeli GUT: 44 / 44, 874 provjere.
- **Svi smoke testovi (60 pokretanja):** svi prolaze osim tri koja su padala i prije ovoga. `home_field_overlay` i `wardrobe` ovise o tvom trenutnom saveu, a za njih je otvoren poseban zadatak. `menu_play` traži dugme kojeg više nema. Tvoj save je poslije svakog testa bajt-identičan.
- **Slike iz igre:** `seasons_capture.gd` za svih 8 sezona (91 kadar), plus CD-ov `buildScene` kao SVG pored Godot crteža.

## Mjerenja

| Šta | Vrijednost |
|---|---|
| Gradnja mreže polja (jednom po sezoni) | 2,9–7,3 ms; CB 15,6 ms (prvo čitanje JSON-a i oblika) |
| Mreža polja (verteksi) | CB 3 623 · Frost 3 672 · Lantern 2 950 · Coral 2 203 · MW 1 713 · Amber 1 602 · Ember 1 419 · Starfall 1 083 |
| Ambijent | ≤ 22 čestice, jedna mreža i jedan draw poziv po frejmu |
| Petlje na polju | najviše 2 (ambijent + njihanje) |
| Novi asseti | 108 cvjetova (2 MB SVG u repou, od toga 1,1 MB C2PA), 12 prepreka |

## Slike (`design-drafts/seasons-faza2/`)

01 polje 7 sezona · 02–03 CD (lijevo) i igra (desno), 8 polja · 04 CD i igra, Shop i Camp recepti · 05 Home kartice svih 8 (Ember uskoro) · 06 Camp kartica Frost / Lantern / Amber · 07 run svih 8 s preprekama · 08 Pip njuši (pahulje na Frostu, svici na Lanternu)

## Povezano

- [[seasons-izvjestaj]]: faza 1 · [[seasons-cd-brief]]: brief · [[../../07-meta/changelog|changelog]] · [[../../06-production/CHECKPOINT|CHECKPOINT]]
