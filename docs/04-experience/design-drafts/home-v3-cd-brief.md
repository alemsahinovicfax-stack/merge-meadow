---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, home, sezone, claude-design, mockup]
povezano:
  - home-season-select-cd-brief
  - home-field-v2-cd-brief
  - hub-chrome-v2-cd-brief
  - camp-v2-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Puni redizajn Homea (dva taba, novo Play, prelaz u polje). Runda 1 imala mrtve strelice i prelaz s rupom; runda 2 (§9–§12) ih je popravila i 2026-09-28 je prenesena u igru 1:1 (§ Implementacija, home-v3-izvjestaj)."
---

# Home — puni redizajn — Claude Design brief

> **Status 2026-09-28 (kasnije): runda 2 isporučena i implementirana u igri** — vidi [[#Implementacija (2026-09-28)|§ Implementacija]] i [[home-v3-izvjestaj|izvještaj]].
>
> ~~**Status 2026-09-28: runda 1 isporučena, treba runda 2 (korekcije).**~~ Paket `design_handoff_home_v3/` je u repou, raspakovan i cijeli (29 fajlova). Test u browseru je našao greške u interakciji i u prelazu biranje → polje, vidi [[#9. Runda 2 — nalazi testiranja (2026-09-28)|§9]]. **Za CD sada šalji prompt iz §12**, ne onaj iz §8.

> Biranje sezona je u igri od 2026-09-21 ([[home-season-select-cd-brief|Season Trail]]), polje sezone od 2026-09-25 ([[home-field-v2-cd-brief|pass 2]]). Ovo je **nova runda cijelog Homea**: biranje i ulaz u polje. Hub header i footer se ne diraju.

**Home** je stranica na kojoj igrač bira sezonu i odande ulazi u njenu livadu. Besplatne sezone se otključavaju igrom. Premium sezone se plaćaju.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7, pa **§9–§11** | Runda 1: šta mora, šta smije. Runda 2: šta je pokvareno i pravila prelaza |
| **Ti** | §12 (runda 2) | Gotov prompt za copy-paste u CD chat. §8 je prompt runde 1, već poslan. |
| **Agent (kasnije)** | §3, §4, §10 | Današnje vrijednosti i mapa u Godot |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto

Ekran radi, ali priča previše i Play na dnu ne izgleda kao glavni potez. Igrač treba da razumije besplatno i plaćeno bez uputstva, da prepozna cvijet, i da ulazak u livadu osjeti kao otvaranje, ne kao skok na drugi ekran.

Daily chest je **već skinut** s biranja sezona. Ostaje samo na polju, gore lijevo, kao Gift. Ne vraćaj ga na biranje.

## 2. Pravila koja ostaju FIKSNA

Brojevi i tok se **ne diraju**. Mijenja se kako izgledaju i kako se ulazi u polje.

| Pravilo | Vrijednost |
|---|---|
| Besplatne sezone | 4, redom: Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy. Sljedeća traži **500 coina + 20 ★3 cvjetova** prethodne. Daleka sezona se ne otvara dok prethodna nije otključana. |
| Premium sezone | 4, plaćaju se: Moonlit Warren, Coral Tide, Starfall Glade, Ember Fen (Ember je „coming soon“, bez cijene). Kupljena se odmah može igrati. |
| Sezona u kojoj se igra | jedna aktivna. Listanje kartica je ne mijenja. |
| Play, tri koraka | 1) kartica nije ta sezona → Play je **vrati** na nju. 2) na njoj, polje zatvoreno → Play **otvara polje**. 3) polje otvoreno → Play **pali run**. |
| Tap na otključanu karticu | i dalje smije otvoriti polje. |
| Polje | livada je cijela stranica. Pip, 13 mjesta, korpa (jedan slot, +5 % spawn, zaključana do prvog mergea), Magnet i Loot Boost (nivoi 0–4), Gift, donji red Seasons · Play · Endless. Endless tek kad je tutorial gotov. |
| Gift | samo na polju. Roze tačka dok dnevni poklon čeka. |
| Swipe | vodoravni swipe po praznom dijelu i dalje lista hub. Kontrole ga blokiraju. |
| Header / footer | chrome v2, 143 / 144, ne dirati. |

## 3. Šta se mijenja

Tačke 1–5 su **obavezne**. Sve ostalo na Homeu — raspored, oblik kartice, kako se sezona bira — tvoja je odluka. Jedan dizajn. Neka bude lijep.

1. **Dva taba: Free i Premium.** Besplatne i plaćene sezone više nisu jedna traka. Premium se vidi kao nešto što se kupuje, bez rečenice koja to objašnjava.
2. **Manje teksta.** Danas kartica nosi natpise tipa „FREE · 1 OF 4“, „6 flowers · 3 shown“, tagline, „Open meadow“ + „field · upgrades“, „PREVIEW · PREMIUM“, „Get … Garden“, „no price yet · preview the flowers“, „Needs 500 coins + 20 flowers“. Ostavi samo ono bez čega se igrač ne snađe. Ime sezone i ime cvijeta koji fali smiju ostati.
3. **Play na biranju.** Današnje dugme je 836 × 180, peach, na dnu, s diskom ▶ i podnaslovom. Igraču se ne sviđa. Napravi Play koji se osjeća kao glavni potez, a i dalje radi tri koraka iz §2. Ne širi ga preko cijele širine samo zato što chest više nije tu.
4. **Daily chest nije na biranju.** Na polju Gift ostaje (180 × 180, gore lijevo, ispod njega korpa istog okvira).
5. **Prelaz biranje → polje.** Danas se kartica (radius 36, rub 8) razvuče u cijelu livadu. Smiješ tu animaciju promijeniti. Mora se vidjeti da je livada **ta** sezona koja se otvara, i nazad (Seasons) da je povratak na biranje, ne drugi svijet. Polje samo: livada, Pip, cvijeće, Gift, korpa, nadogradnje, Seasons · Play · Endless — mehanika iz §2 ostaje; smiješ dotjerati kako prelaz izgleda.

Cvijet na kartici sezone već puni svoj krug odrezanim crtežom. Ne crtaj novi art cvijeta.

## 4. Današnji raspored (orijentacija, ne obaveza)

Stranica 1080 × 1633, od y = 143.

| Blok | Mjesto |
|---|---|
| Kartica sezone | 1032 × 1136 na (24, 167) |
| Dock tokena | 1080 × 222 na (0, 1327) |
| Play red | 1032 × 180 na (24, 1573). Play je 836 × 180. Chest je skriven, rupa desno ostaje dok je ti ne riješiš. |

Polje (kad je otvoreno) je cijela ta stranica. Chrome pluta: Gift + korpa gore lijevo (oba 180), nadogradnje gore desno, dolje Seasons 236 × 124 · Play 432 × 140 · Endless 236 × 124.

Boje livade po sezoni: `#E6F2DB` `#D1E6FF` `#EBD6FF` `#FFEBC7` `#B8BDFF` `#FFE0D6` `#DBCCFF` `#FFC79E`. Tri trake svjetline (nebo, daljina, prednji plan). Jedno rješenje za sve.

## 5. Paleta i tehnika

Postojeći tokeni: `game/scripts/visual/ui_stage.gd`, `ui_home_field.gd`. Warm white `#FFF8F0`, ink `#2D3436` / `#1A1A14`, peach `#FFB88C`, coin gold `#FFD56B`, mint `#A8E6CF`. Nova boja samo kao svjetlija ili tamnija varijanta, označena u README.

Artboard 1080 × 1920. Paneli = ravna boja, radius, rub, jedna sjena. Bez blura i 3D. Animacije = tween. **Najviše jedan loop** na ekranu. Tekst koji ostane ≥ 34 px. Dodir ≥ 120 px. Kontrast teksta ≥ 4,5:1.

## 6. Isporuka

### 6.1 Stanja

1. **Free, sezona u kojoj se igra** — Play vodi u polje.
2. **Free, listaš zaključanu** — vidi se da Play vraća na sezonu u kojoj se igra, ne da pali run.
3. **Free, sljedeća sezona se može otključati** i **još fali** (500 + 20).
4. **Premium tab** — kupovna sezona s cijenom, kupljena, i Ember „coming soon“ bez cijene.
5. **Prelaz** — biranje se otvara u polje, i Seasons vraća nazad. Dovoljna su 2–3 kadra ili opis trajanja u Specs.
6. **Polje** — Gift čeka (roze tačka), korpa, Play u donjem redu pali run. Dvije livade za kontrast: Amber `#FFEBC7` i Moonlit `#B8BDFF`.

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_home_v3/
  README.md                 šta otvoriti · § Odlučeno · § Prelaz (trajanje, šta se
                            animira) · § Šta se briše · § Ideje van zadatka
  design/
    HomeScreen.dc.html      biranje; prop scene i tab (free|premium)
    FieldScreen.dc.html     polje poslije prelaza; prop season
    Home Specs.dc.html      anatomija, tri koraka Playa, prelaz, oba taba
    support.js · icons/
  godot/
    home_v3_export.json     meta · tokens · layout · components · scenes ·
                            animations · strings_en · godot_map · decisions
    ui_home_v3.gd           nove/izmijenjene konstante, isti nazivi gdje postoje
                            (ui_stage.gd / ui_home_field.gd)
    home_tree.txt
    README.md               red prenosa
```

**Imena slojeva:** `SeasonSelect`, `FreeTab`, `PremiumTab`, `SeasonCard`, `SeasonRoster`, `PlayButton`, `FieldPage`, `Meadow`, `GiftChest`, `BasketButton`, `UpgradesButton`, `BottomRow`, `SeasonsButton`, `FieldPlayButton`, `EndlessButton`, `OpenTransition`.

## 7. Ne tražimo

- Hub header i footer.
- Camp, Journal, Shop, Arena, Run.
- Novi art cvijeta i Pipa.
- Daily chest na biranju.
- Vraćanje Playa na „odmah u run“ s kartice.
- Više varijanti za biranje — jedan dizajn.

## 8. Prompt za Claude Design — runda 1 (poslan 2026-09-28, ne slati ponovo)

> Ostaje kao zapis. Za rundu 2 koristi **§12**.

```
Radim PUNI redizajn HOME stranice mobilne igre. Home je mjesto gdje igrač
bira sezonu i ulazi u njenu livadu.

Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada. Neka dizajn zaista
očara — ovo je ekran koji igrač vidi prvi.

Tvoja referenca je jedan fajl u repou (master), pročitaj ga po ovoj tačnoj
putanji:
  docs/04-experience/design-drafts/home-v3-cd-brief.md
Ako se ovaj prompt i fajl razlikuju, važi fajl. §10 briefa (ako ga vidiš
kao prenos) možeš preskočiti — mapa za agenta je u §6 i na dnu fajla nije
obavezna za tebe.

Kontekst, ne precrtavaj hub chrome:
  design_handoff_home_v2/design/SeasonStage.dc.html
  design_handoff_home_field_v2/design/FieldScreen.dc.html
  design_handoff_hub_chrome_v2/design/HubChromeScreen.dc.html
  game/scripts/visual/ui_stage.gd
  game/scripts/visual/ui_home_field.gd

TVOJ ZADATAK: Home priča previše, a Play na dnu ne djeluje kao glavni potez.
Besplatne i plaćene sezone moraju biti dva taba. Daily chest NIJE na biranju
— već je skinut; ostaje samo Gift na polju sezone.

JEDAN DIZAJN. Ne pravi smjerove ni varijante. Kad imaš dilemu, odluči sam i
napiši razlog u jednoj rečenici u README § Odlučeno. Imaš slobodu rasporeda,
oblika kartice i animacije. Obavezne su samo ove tačke (detalji u fajlu):

1. Dva taba: Free i Premium. Premium se plaća. Ember Fen je "coming soon",
   bez cijene. Bez rečenice koja objašnjava razliku — neka se vidi.
2. Manje teksta. Ime sezone i, kad fali cvijet, ime tog cvijeta smiju ostati.
   Natpisi tipa "FREE · 1 OF 4", "6 flowers · 3 shown", "field · upgrades",
   "no price yet · preview the flowers" nisu svetinja.
3. Play na biranju iznova. Danas je 836 x 180, peach, na dnu, s diskom i
   podnaslovom. Igraču se to ne sviđa. Tri koraka MORAJU ostati:
   - lista zaključanu ili premium karticu → Play vrati na sezonu u kojoj se igra
   - na toj sezoni → Play otvori polje (livadu)
   - na polju → Play upali run
4. Prelaz biranje → polje. Danas se kartica razvuče u livadu. Smiješ animaciju
   promijeniti. Mora se osjetiti da se otvara BAŠ ta sezona, i da Seasons
   vraća nazad. Uzmi u obzir i polje: livada je cijela stranica, Gift i korpa
   gore lijevo, nadogradnje gore desno, dolje Seasons · Play · Endless.

MORA OSTATI:
- 4 besplatne sezone redom, otključavanje 500 coina + 20 ★3 prethodne.
- 4 premium sezone, pravi novac, Ember bez cijene.
- Gift samo na polju, roze tačka dok poklon čeka. Korpa zaključana do prvog
  mergea, +5 % spawn. Endless tek poslije tutoriala.
- Header 143 i footer 144 (chrome v2).
- Tekst koji ostane >= 34 px, dodir >= 120 px.
- Cvijet crta igra — ne treba novi art.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, stranica
između chromea je 1080 x 1633, sve u px te baze (prenos 1:1). Paneli = ravna
boja + alpha, radius, border, jedna sjena. Tween, najviše jedan loop.
Bez blura, gradijenata na panelima i 3D-a.

ISPORUKA (§6): stanja iz §6.1 i paket TAČNO po strukturi iz §6.2 —
design_handoff_home_v3/ s README.md, design/ (HomeScreen.dc.html,
FieldScreen.dc.html, Home Specs.dc.html, support.js) i godot/
(home_v3_export.json, ui_home_v3.gd, home_tree.txt, README.md).
Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: SeasonSelect, FreeTab, PremiumTab, SeasonCard, SeasonRoster,
PlayButton, FieldPage, Meadow, GiftChest, BasketButton, UpgradesButton,
BottomRow, SeasonsButton, FieldPlayButton, EndlessButton, OpenTransition.

NE RADI: hub header/footer, Camp, Journal, Shop, Arena, Run, novi art
cvijeta, daily chest na biranju, Play koji s kartice odmah pali run.
Ideje van zadatka navedi odvojeno na kraju README-a.
```

---

## 9. Runda 2 — nalazi testiranja (2026-09-28)

**Paket je cijeli.** Zip `design_handoff_home_v3/` ima 29 fajlova i raspakuje se bez greške. Sve putanje u HTML-u postoje. U repou je na istoj putanji. Greške su **u samom dizajnu**, ne u raspakivanju: CD je sažeo rad bez testiranja.

**Kako je testirano:** `HomeScreen.dc.html` je pokrenut u Chromiumu 1080 × 1920. Klikovi su pravi klikovi mišem na koordinate dugmadi. Za prelaz je sat stranice (`performance.now`) zaustavljen i pomjeran po 28 ms, uz snimak ekrana i neprozirnost svakog sloja u svakom koraku. Kadrovi su u `docs/04-experience/design-drafts/home-v3-test/open-frames.png` i `close-frames.png`.

### 9.1 Interakcija — zašto se sezone ne mogu birati

| # | Nalaz | Uzrok u kodu | Posljedica |
|---|---|---|---|
| **I1** | Strelice ‹ › ne rade. | `CardNav` ima `pointer-events:none`, a `PrevSeason` / `NextSeason` to nasljeđuju jer nemaju `pointer-events:auto`. Klik prolazi kroz strelicu na `SeasonCard` ispod. | Na aktivnoj sezoni **tap na strelicu otvara polje**. Na zaključanoj ne radi ništa. Unutar taba se ne može listati. **Ovo je glavni razlog zašto se sezone ne mogu birati.** |
| **I2** | Swipe po kartici ne lista. | README i § Odlučeno kažu „swipe po kartici lista sezone", ali u HTML-u nema nijednog pointer/drag handlera. | Osim strelica nema drugog načina da se lista. |
| **I3** | Tap na tab usred prelaza mijenja karticu. | Tabovi, strelice i kartica nemaju zaštitu dok `t` nije 0 (ima je samo `onPlay`). | Tap na Premium u 84. ms otvaranja pretvori karticu u Moonlit (plava) dok se otvara polje Lanterna (lila). Boja skoči usred animacije. |
| **I4** | Pip stoji na svakoj otključanoj free sezoni. | `stActive: status === 'active' \|\| status === 'open'`. | Frost Orchard (otključana, ne igra se) nosi Pipa, a Pip znači „ti si ovdje". Igrač ne vidi koju sezonu igra. Stanje `open` nema svoj izgled. |
| **I5** | Tačke ispod kartice nisu dugmad. | Nema handlera, 24 px. | Nije greška ako su samo indikator. Treba to napisati u README, inače će ih agent napraviti kao dugmad. |

### 9.2 Prelaz — zašto elementi nestanu pa se ponovo pojave

Izmjerena otvaranja (560 ms). Vremena su od tapa na Play:

| ms | Šta se vidi |
|---|---|
| 0–224 | Ime, cvijeće i Pip na kartici blijede (`CardContent` 0–40 %). Tabovi i strelice blijede. |
| **224–308** | **Kartica je prazan obojeni pravougaonik.** Nema imena, nema Pipa, nema cvijeća. |
| 308–476 | `FieldPage` se pojavljuje: trake livade, **ime ponovo** (sada 56 px, gore) i `FieldPlayButton`. |
| 420–560 | **Pip ponovo**, ali na drugom mjestu (x 540 → 756), i **cvijeće ponovo**, kao 13 drugih cvjetova. Gift, korpa i nadogradnje ulaze. |
| 560 | Putujući `PlayButton` postaje `visibility:hidden`, a vidi se `FieldPlayButton`. **Skok:** tekst 76 → 64, trokut 48 → 42, rub 4 → 3, sjena 10 → 8. |

Zatvaranje (440 ms) ima iste greške unazad. U 28. ms putujući Play iskoči preko `FieldPlayButton` (tekst 64 → 76). Od 196. do 280. ms kartica je opet prazna, a ime, cvijeće i Pip se vraćaju tek poslije.

| # | Nalaz | Uzrok | Popravak (§10) |
|---|---|---|---|
| **T1** | Ime, Pip i cvijeće nestanu pa se ponovo pojave (gore opisano). | Dvije kopije istog objekta (kartica i polje) imaju fade-out i fade-in koji se **ne preklapaju**. Između njih je rupa od 84 ms. | P1, P2, P3 |
| **T2** | Dva dugmeta Play u istom kadru i skok na kraju. | `PlayButton` putuje na mjesto `FieldPlayButton`, ali ne postaje isti. `FieldPlayButton` se paralelno pojavljuje ispod njega od 308. ms. | P4 |
| **T3** | Trake se ne poklapaju, iako README kaže da se poklapaju. | Kartica koristi `CARD_BANDS 0.327 / 0.363 / 0.31`, pa je na punoj visini nebo 534 i daljina do 1127. Livada u igri (`UiHomeField.MEADOW_BANDS 0.32 / 0.68`, isto i u `FieldScreen`) ima 523 i 1110. Pri predaji to je skok od **11 i 17 px**. | P5 |
| **T4** | Duhovi ivica u sredini prelaza. | `FieldPage` sa svojim trakama preko cijele stranice blijedi (308–476 ms) **preko kartice koja još nije puna** (radius, rub 4, uvučena). Dva seta ivica traka i obris kartice vide se kroz poluprozirno polje. `FieldScreen` ima prop `noBands`, ali ga `HomeScreen` ne koristi. | P5 |
| **T5** | Ime sezone na polju ne prati `reveal`. | `SeasonLabel` nije u `TopChrome`, pa ulazi s cijelom `FieldPage` (55–85 %), a ne s ostalim chromeom. | P2 |
| **T6** | Export i HTML ne opisuju isto. | `animations.open` nema tragove za ime, Pipa ni `SeasonLabel`. `godot_map` ne kaže koje konstante u `UiHomeField.ANIM` se mijenjaju. Igra danas ima `field_open 0.28`, chrome stagger `0.22 + 0.06·i`, cvijeće `0.9 → 1` sa stagger 24 ms, a zatvaranje je trenutno. | P8 |

## 10. Runda 2 — pravila prelaza (MORA)

Prelaz biranje ↔ polje je **najosjetljiviji dio Homea**. Igrač mora vidjeti **jednu stvar koja se otvara**, a ne dva ekrana koji se smjenjuju. Ova pravila nisu stil. Svako je odgovor na jedan nalaz iz §9.

**P1 — Nijedan kadar bez sadržaja.** U svakom kadru od 0 do 1, i unazad, vide se ime sezone, Pip i Play, svaki s alfom ≥ 0,6. Kartica nikad nije prazan pravougaonik.

**P2 — Ime sezone je jedan objekat.** `SeasonName` (80 px, centar x 540, vrh y 244 na stranici) se **pretvori** u `SeasonLabel` polja (56 px, vrh y 36): pomak plus skala 0,70, na istom eased `t` kao kartica. Nema fade-out pa fade-in. Na t = 1 piksel-identičan je `SeasonLabel`-u.

**P3 — Pip je jedan objekat.** Pip s kartice (230 px, gornji lijevi ugao (425, 1027)) putuje i smanjuje se u `MeadowPip` (190 px na (661, 1214), noge na `PIP_DEFAULT_BASE` (756, 1404)). U igri Pip na polju **hoda** (`season_field.gd`, walk / sniff / sleep). Zato:
- hodanje počinje tek kad je prelaz gotov;
- na zatvaranju Pip kreće **s mjesta gdje trenutno stoji**, ne s kućne pozicije.

Nacrtaj oba slučaja u Specs.

**P4 — Play je jedan objekat.** Putujući `PlayButton` uz rect interpolira i **rub, sjenu, veličinu teksta, trokut i razmak**. Na t = 1 piksel-identičan je `FieldPlayButton`-u (danas rub 3, sjena 0 8 0 α .28, tekst 64, trokut 26 / 42, gap 22). Tek tada se predaje. `FieldPlayButton` se ne vidi dok putujući Play postoji, i obrnuto. Isto vrijedi unazad. Ako ti je bolje da oba imaju iste mjere od starta (npr. i polje dobije 76 / rub 4), odluči i zapiši u § Odlučeno.

**P5 — Jedne trake.** Dok prelaz traje, **kartica jeste livada**, a `FieldPage` ne crta svoje trake (`noBands`). Trake kartice koriste **iste razlomke kao igra**: `0.32 / 0.68` visine (`UiHomeField.MEADOW_BANDS`), ne 0.327 / 0.363. Na t = 1 kartica i `Meadow` daju iste piksele, pa predaja nema šav. `FieldPage` ne blijedi preko kartice koja još nije puna.

**P6 — Samo-jednostrani objekti se preklapaju, ne smjenjuju.** Neki objekti postoje samo na jednoj strani:
- samo na kartici: roster diskovi, statusi, lokot, strelice, tabovi, tačke;
- samo na polju: 13 cvjetova, Gift, korpa, nadogradnje, čip izraslih, Seasons, Endless.

Ti smiju blijediti. Ali odlazak roster diskova i dolazak cvjetova livade se **preklapaju** (npr. roster 0–35 %, cvijeće 30–80 %), tako da livada nikad nije bez cvijeća i bez diskova u istom trenutku. Cvijeće koristi isti „settle" kao igra (`tween_flowers_settle`: scale 0,9 → 1, stagger 24 ms), ili napiši novu vrijednost i zašto.

**P7 — Unos je zaključan dok prelaz traje.** Od tapa do kraja (oba smjera) tabovi, strelice, kartica, Play i Seasons ne reaguju. Isto vrijedi za promjenu kartice (220 ms). U mocku: jedan `busy` guard za sve handlere.

**P8 — Jedan izvor istine.** `animations.open` i `animations.close` u `home_v3_export.json` nabrajaju **svaki** objekat koji se mijenja (uključujući ime, Pipa, cvijeće, `SeasonLabel`, `FieldPlayButton`) sa `from` / `to` i svojstvima. Vrijednosti su iste kao u HTML-u i u `ui_home_v3.gd`. Plus tabela „`UiHomeField.ANIM` staro → novo" za svaku konstantu koju prelaz mijenja: `field_open`, `chrome_delay`, `chrome_stagger`, `chrome_in`, `flower_settle`, `field_close`. Današnji stagger chromea traje do ≈ 820 ms, duže od tvojih 560. Odluči: skrati ga ili ukini.

**P9 — Test predaje.** Kadar na `openT = 0.99` i kadar na `openT = 1` razlikuju se samo u loopu (prsten korpe), ništa drugo. Isto za zatvaranje.

**P10 — Tempo.** Svi objekti iz P2–P5 koriste **isti eased `t`** (ease in-out cubic) kao kartica, da se kreću zajedno. Dužine 560 / 440 / 220 ms smiju ostati ili se promijeniti, uz rečenicu u § Odlučeno.

### 10.1 Interakcija (MORA)

- **I1:** strelice rade (`pointer-events:auto`) i klik ne prolazi na karticu (`stopPropagation`). Dodir 120.
- **I2:** swipe po kartici lista sezone unutar taba: prag ~60 px, iste 220 ms kao strelice. Hub swipe ostaje samo u `HubSwipeZone`.
- **I3:** vidi P7.
- **I4:** Pip samo na sezoni u kojoj se igra. Otključana sezona u kojoj se ne igra (`open`) dobija svoj izgled, bez teksta i bez Pipa. Na njoj Play je „Back" (korak 1), a tap na karticu otvara njeno polje i ona postaje aktivna (kao u igri, `open_season_field`). Odluči kako se to vidi.
- **I5:** tačke su samo indikator. Napiši to u README.

## 11. Runda 2 — isporuka

**Ne pravi novi dizajn.** Sve iz runde 1 što nije u §9 ostaje kako jeste: tabovi, kartica, Play, statusi, boje, § Odlučeno. Mijenjaš samo ono što traže §10 i §10.1.

Paket: isti `design_handoff_home_v3/`, iste putanje, **cijeli folder u zipu**.

| Fajl | Šta se mijenja |
|---|---|
| `design/HomeScreen.dc.html` | I1–I5, P1–P7, P10 |
| `design/FieldScreen.dc.html` | samo ako treba za P2–P5 (npr. `SeasonLabel` pod `reveal`, prop za Pip / Play predaju) |
| `design/Home Specs.dc.html` | **traka kadrova**: otvaranje na `openT` 0, .1, .2 … 1 i zatvaranje isto (11 + 11). Uz to Pip na zatvaranju kad je odšetao od kuće (P3). |
| `godot/home_v3_export.json` | P8: puni tragovi + tabela ANIM staro → novo; `CARD_BANDS` → 0.32 / 0.36 / 0.32 |
| `godot/ui_home_v3.gd` | iste vrijednosti kao JSON |
| `godot/README.md` | red prenosa dopuniti za P2–P4 (jedan objekat, predaja) |
| `README.md` | nova sekcija **§ Runda 2** sa po jednim redom za svaki ID (I1–I5, T1–T6): šta je promijenjeno. Uz to **§ Samoprovjera** (ispod). |

**§ Samoprovjera** (CD je popuni prije slanja zipa; svaka stavka da/ne):

1. Klik na ‹ i › mijenja sezonu i **ne** otvara polje, na aktivnoj i na zaključanoj kartici.
2. Swipe po kartici lista sezone.
3. Tap na tab, strelicu, karticu ili Play za vrijeme prelaza ne radi ništa.
4. `openT` od 0 do 1 u koracima 0,05: u svakom kadru se vide ime, Pip i Play (P1).
5. `openT` 0,99 i 1 izgledaju isto (P9). Isto za zatvaranje.
6. Pip je samo na sezoni u kojoj se igra.
7. Svaki broj u `animations` postoji isti u HTML-u i u `ui_home_v3.gd`.

## 12. Prompt za Claude Design — runda 2

> Kopiraj sve iz bloka ispod u CD, u **isti chat** gdje je rađena runda 1 ako još postoji (ima kontekst), inače u novi. **Prije toga commitaj i pushaj na `master`** — CD čita brief, paket i kadrove po putanji.

```
Ovo je RUNDA 2 za Home v3 — samo KOREKCIJE, ne novi dizajn.

Runda 1 (tvoj paket design_handoff_home_v3/) je testirana u browseru
pravim klikovima i kadar-po-kadar snimkom prelaza. Dizajn nam se sviđa i
ostaje. Pokvarene su interakcija i prelaz biranje -> polje. Sesija ti je
prošli put završila sažetkom bez provjere — ovaj put testiraj prije zipa.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/home-v3-cd-brief.md
    -> §9 (nalazi s uzrocima), §10 i §10.1 (pravila MORA), §11 (isporuka)
  docs/04-experience/design-drafts/home-v3-test/open-frames.png
  docs/04-experience/design-drafts/home-v3-test/close-frames.png
    -> izmjereni kadrovi tvog prelaza, vidi se rupa i skokovi
  design_handoff_home_v3/design/HomeScreen.dc.html   (tvoj, polazna tačka)
  design_handoff_home_v3/design/FieldScreen.dc.html  (tvoj)
  design_handoff_home_v3/godot/home_v3_export.json   (tvoj)
Polje sezone kakvo je danas U IGRI — prelaz mora sletjeti tačno u ovo:
  design_handoff_home_field_v2/design/FieldScreen.dc.html
  game/scripts/visual/ui_home_field.gd   (MEADOW_BANDS, PIP_*, ANIM,
                                          tween_chrome_in, tween_flowers_settle)
  game/scripts/ui/season_field.gd        (Pip hoda: walk/sniff/sleep)
  game/scripts/ui/season_stage.gd        (_play_field_open_motion)
Ako se prompt i brief razlikuju, važi brief.

INTERAKCIJA — zašto se sezone ne mogu birati:
I1 CardNav ima pointer-events:none, strelice to naslijede, klik padne na
   karticu -> na aktivnoj sezoni strelica OTVARA POLJE. Popravi: strelice
   primaju klik i ne propuštaju ga kartici.
I2 Swipe po kartici je u README-u, ali ne postoji. Napravi ga (~60 px).
I3 Tap na tab usred prelaza promijeni karticu u drugu sezonu. Zaključaj
   sav unos dok traje prelaz ili promjena kartice.
I4 Pip stoji na svakoj otključanoj free sezoni (status 'open'). Pip je
   samo na sezoni u kojoj se igra; 'open' dobija svoj izgled bez teksta.
I5 Tačke su indikator, ne dugmad — napiši to.

PRELAZ — elementi se pojave, nestanu, pa ponovo pojave:
- 224–308 ms kartica je prazna: ime, cvijeće i Pip su izblijedili, a
  polje još nije ušlo. Onda se ime i Pip vrate na DRUGOM mjestu.
- Play: tvoj putujući PlayButton i FieldPlayButton su dva dugmeta; na
  560 ms skok (tekst 76->64, rub 4->3, sjena 10->8). Na zatvaranju isto.
- Trake kartice 0.327/0.363 ne poklapaju livadu igre 0.32/0.68 (skok
  11 i 17 px), a FieldPage blijedi sa svojim trakama preko kartice koja
  još nije puna -> duhovi ivica. FieldScreen ima noBands — iskoristi ga.

PRAVILA (detalji u §10 briefa):
P1 Nijedan kadar bez imena, Pipa i Playa (alfa >= 0,6).
P2 Ime = JEDAN objekat: 80 px na kartici se pretvori u 56 px SeasonLabel.
P3 Pip = JEDAN objekat: 230 px s kartice putuje u MeadowPip 190 px
   (noge 756,1404). Hodanje tek poslije prelaza; nazad kreće s mjesta
   gdje trenutno stoji.
P4 Play = JEDAN objekat: na kraju piksel-identičan FieldPlayButton-u,
   pa predaja. Nikad dva Play dugmeta u kadru.
P5 Jedne trake: dok traje prelaz kartica JESTE livada (0.32 / 0.68),
   polje bez svojih traka; na t=1 isti pikseli.
P6 Roster diskovi odlaze, cvijeće livade dolazi — PREKLOPLJENO, ne
   jedno pa drugo. Settle kao u igri (0,9 -> 1, stagger 24 ms) ili
   napiši novu vrijednost.
P7 Unos zaključan tokom prelaza (oba smjera) i promjene kartice.
P8 export JSON nabraja SVAKI objekat koji se mijenja; iste vrijednosti
   u HTML-u i ui_home_v3.gd; tabela UiHomeField.ANIM staro -> novo.
P9 Kadar openT 0,99 = kadar openT 1 (osim loopa korpe). Isto nazad.
P10 Ime, Pip, Play i kartica na ISTOM eased t — kreću se zajedno.

NE MIJENJAJ: tabove, izgled kartice, Play, statuse, boje, § Odlučeno,
hub header/footer, polje (osim onoga što traže P2–P5). Jedno rješenje.

ISPORUKA (§11): isti folder design_handoff_home_v3/, iste putanje.
Home Specs dobija traku kadrova openT 0, .1 ... 1 za otvaranje i
zatvaranje, plus Pip koji se vraća s mjesta gdje je odšetao. README
dobija "§ Runda 2" (po red za I1–I5 i T1–T6) i "§ Samoprovjera" sa 7
stavki iz §11 briefa — svaku provjeri u svom prototipu i napiši da/ne.
Na kraju mi daj ZIP ZA PREUZIMANJE s cijelim folderom.
```

## Implementacija (2026-09-28)

Paket: `design_handoff_home_v3/` (runda 2). Prije prenosa testiran u browseru: strelice, swipe, zaključan unos, Pip samo na aktivnoj i prelaz bez rupe rade. Ostala je jedna greška mocka: `OpenTransition` bez `pointer-events:none` pokriva tabove. U igri je taj kontejner `MOUSE_FILTER_IGNORE`. Detalji, slike Godot ↔ dizajn i video su u [[home-v3-izvjestaj|izvještaju]] i u `home-v3-test/`.

| Fajl | Uloga |
|------|-------|
| `game/scripts/visual/ui_home_v3.gd` | **Novo** — tokeni i mjere iz paketa, `ease_t` / `win`, putujući objekti (`PLAY_CARD` → `PLAY_FIELD`, ime, Pip), crtanje (panel sa sjenkom 0 Y 0, isprekidani rub, chevron, kvačica, cvijet, Pip) |
| `game/scripts/ui/season_stage.gd` + `scenes/ui/season_stage.tscn` | **Prepisano** — tabovi, kartica, strelice, swipe, tačke, Play u tri koraka i prelaz (`_set_u`: kartica, rub, FieldClip, ime, Pip, Play, chrome polja) |
| `game/scripts/ui/home_v3_card.gd` · `home_v3_card_content.gd` | **Novo** — trake kartice (`round(h·.32/.68)`) i sadržaj (premium rub, lokot, tri diska, status po stanju) |
| `game/scripts/ui/home_v3_tabs.gd` · `home_v3_arrow.gd` · `home_v3_marks.gd` · `home_v3_play_button.gd` · `home_v3_glyph.gd` | **Novo** — tabovi, strelice, tačke / rub / ime / Pip / toast, Play (i „Back"), znakovi Seasons / Endless |
| `game/scripts/ui/season_field.gd` · `season_field_pip.gd` · `season_field_flower.gd` | `apply_reveal(u)`: trake samo na `u = 1`, prozori cvijeća i napomene; `hold_pip` / `release_pip` / `pip_feet`; boje iz `UiHomeField.meadow_ground`; Pip iz `pip_idle.svg` sa sjenkom; sjenka cvijeta kao pilula |
| `game/scenes/main_menu.tscn` · `scripts/ui/main_menu.gd` | Obrisani `HomeColumn`, `PlayRow`, stari `PlayButton`, `DailyChestCard`, `FieldBackdrop`, `SeasonLabel` i `FieldPlayButton`. Chrome polja ide u `FieldOverlay → FieldOverlayInner → TopChrome / BottomRow` (clip = rect kartice). Blokada dodira dok traje prelaz. Prsten korpe tek na `u = 1` |
| `game/scripts/visual/ui_home_field.gd` | `meadow_sky` / `meadow_near` zaokruženo na 8 bita (isti pikseli kao kartica) |
| obrisano | `home_season_card.gd`, `season_browser.gd`, `home_dock_token.gd`, `home_play_disc.gd`, `season_colors.gd`; v2 mjere i crteži iz `UiStage` (ostali su fontovi, box i oblici), stari tweenovi prelaza iz `UiHomeField` (`tween_open_field`, `tween_chrome_in`, `tween_flowers_settle`) |
| `game/scripts/dev/season_home_smoke.gd` | **Prepisano za v3** (vidi izvještaj § Testovi), plus `home_capture.gd` (sva stanja + kadrovi prelaza) i `home_movie.gd` (video toka) |

## Povezano

- [[home-v3-izvjestaj|home-v3-izvjestaj]] — prenos u igru, provjere, odstupanja
- [[home-season-select-cd-brief|home-season-select-cd-brief]] — biranje, Season Trail
- [[home-field-v2-cd-brief|home-field-v2-cd-brief]] — polje, livada kao stranica
- [[hub-chrome-v2-cd-brief|hub-chrome-v2-cd-brief]] — header i footer
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
