---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, camp, arena, upgrade, claude-design, mockup]
povezano:
  - camp-v2-cd-brief
  - camp-cd-brief
  - merge-arena-cd-brief
  - hub-chrome-v2-cd-brief
  - ekonomija-brojevi
  - _index
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: camp bez zelene pozadine i s oznakom mergeable sjemena, ulaz u arenu tek od 50 mergeable sjemenki, upgradei po sezoni (cvijet te sezone + coini) i jedan novi boost koji CD sam predloži."
---

# Camp, ulaz u arenu, upgradei po sezoni — Claude Design brief

> Camp je već dvaput dizajniran ([[camp-cd-brief|camp-cd-brief]], [[camp-v2-cd-brief|camp-v2-cd-brief]], paketi `design_handoff_camp/` i `design_handoff_camp_v2/`). Ovo je **treća runda**. Camp dobija novu pozadinu i oznaku mergeable sjemena. Uz to dolaze dva mala ekrana koja dijele ista pravila: **vrata arene** (ne polje arene) i **sheet nadogradnji na Homeu**. Sve što ovdje nije spomenuto ostaje kako je u camp v2.

**Camp** je ostava: sjemenke iz runova, ★3 cvijeće iz Arene, trade u coine, kartica sljedeće besplatne sezone. Merge je u Areni. Nadogradnje su na Homeu, na otvorenom polju.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§9) + camp v2 za ono što ostaje | Šta se mijenja, šta je fiksno, mjere i isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §3, §10 | Pravila i mapa „CD sloj → Godot". Treći boost se čita iz JSON-a **prije** bilo kakvog koda |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto treća runda

1. **Camp je i dalje zelen.** Stranica je `#2E4733`. Header i footer su dusk plum `#2A2233`. Zelena se ne slaže s ostatkom huba.
2. **Igrač ne vidi šta može u Arenu.** Tip s 4 ili više sjemenki je gorivo za merge. Tip s 1, 2 ili 3 nije. Na kartici to ne piše, a prodaja tog stoga tiho spušta zbroj.
3. **Arena se otvara čim postoji jedan stog od 4.** Treba prag: merge run uopšte ne krene ispod 50 mergeable sjemenki.
4. **Magnet i Loot Boost su jedni za cijelu igru** i plaćaju se bilo kojim ★3. Treba da svaka sezona krene ispočetka, i da se plaća cvijetom **te** sezone i coinima.
5. Treba **jedan novi boost**, istih pravila. CD ga smišlja i crta. Mehanika mora biti napisana tako da se pri raspakivanju vidi svako stanje, da u kodu ne ostane rupa.

## 2. Pravila koja ostaju FIKSNA

Brojevi ispod se ne diraju. Mijenja se samo ono što §3 izričito traži.

| Pravilo | Vrijednost |
|---|---|
| Trade tap | prodaje **1 komad** |
| Trade držanje | **10 komada / s** dok držiš; na rezervisanom ★3 držanje **stane** na granici, dalje samo tap |
| Cijena sjemenke | ★1 = 1 · ★2 = 2 · ★3 = 4 coina po komadu |
| Cijena cvijeta | ★1 = 5 · ★2 = 10 · ★3 = 20 coina po komadu |
| Rezervisano cvijeće | badge „Kept · N / M" + strip dok je odabrano. To je **druga** oznaka od mergeable sjemena |
| Otključavanje sezone | **500 coina + 20 ★3** prethodne sezone |
| Cap torbe | **40**. Višak koji ne stane i dalje nestaje. Ovaj brief to ne rješava |
| Magnet | 4 nivoa. Radijus `40 + 48 × nivo` (0 → 40 px, 4 → 232 px) |
| Loot Boost | 4 nivoa. ×1, ×1.25, ×1.5, ×1.75, ×2 |
| Košara | **+5 %** šanse da pickup bude sjeme, ne novčić. Tip sjemena ostaje ravnomjeran iz poola sezone. Košara **ne** pretvara svako sjeme u odabrani tip |
| Fail / revive | fail čuva ceil od 50 %. Revive jednom, ne dira to pravilo |
| Plaćene sezone | tema, ne snaga. Novi boost im ne diže magnet, loot ni spawn |

Camp ne prodaje ništa za pravi novac. Nema novog IAP-a za nadogradnju, nema energy, nema pay-to-continue.

Tekst koji je camp v2 već izbacio **ostaje van**: „Next free season", „Details", podnaslov na Unlock, prečica Merge, podnaslovi tabova („Arena fuel", „reward"), „1 coin each", „hold 10 / s".

## 3. Šta se mijenja

### 3.1 Camp — pozadina

Zelena `#2E4733` ide van. Header (143 px) i footer (144 px) ostaju `#2A2233` i ne crtaju se iznova. Stranica između njih je **1080 × 1633**. CD bira pozadinu stranice koja sjedi uz tu traku i uz Shop (topli papir, ne nova zelena). Kartice, tabovi i Trade bar ostaju čitljivi na toj pozadini. Raspored camp v2 ostaje: kartica sezone gore, sekcija odmah ispod, fiksna visina, lista skrola, Trade na dnu.

### 3.2 Camp — mergeable sjeme

**Mergeable** = u torbi imaš **4 ili više** tog tipa. Cijeli taj stog ulazi u zbroj za Arenu. Tip s 1, 2 ili 3 **ne ulazi nimalo**, ni kao ostatak.

| Torba | Zbroj | Smije u Arenu |
|---|---|---|
| djetelina 13, tratinčica 3, tulipan 40 | 13 + 40 = **53** (tratinčica van) | da |
| jedan tip × 49 | **49** | ne |
| četiri tipa × 12 | **48** | ne |
| jedan tip × 50 | **50** | da |
| jedan tip × 4, ostalo po 1–3 | **4** | ne |

Obrazac je isti kao kod rezervisanog ★3, značenje nije:

- na kartici sjemena mala oznaka, samo kad je stog mergeable;
- dok je taj tip odabran, i dok traje prodaja, jedna kratka linija ispod Trade reda.

Oznaka **ne smije** izgledati kao katanac cvijeta. Cvijet se čuva za sezonu i držanje na njemu staje. Ovo sjeme **smije** da se proda: tap i dalje 1, držanje i dalje 10/s. Linija samo kaže da stog ulazi u onih 50. Kad prodaja spusti tip ispod 4, oznaka nestane i stog ispada iz zbroja. Tip ispod 4 nema oznaku i nema tu liniju.

### 3.3 Vrata arene — samo ulaz

Polje, muncher, sipanje, merge i izlaz iz runde **se ne crtaju**. Danas prvi tap na vreću, čim neki tip ima ≥ 4, otvori rundu. Novo pravilo: runda **ne postoji** dok zbroj iz §3.2 nije ≥ 50.

CD crta stanje **prije** rundu, na stranici Arene, između istog headera i footera:

- broj `N / 50` (samo mergeable zbroj);
- vreća i dalje pokazuje i sitne stogove, ali se vidi da oni ne ulaze u N;
- ispod 50 vreća ne otvara rundu;
- na 50 ista vreća smije da krene (jedan jasan signal, bez rečenice uputstva).

### 3.4 Nadogradnje — po sezoni, na Homeu

Sheet ostaje na otvorenom polju Homea. Ne crta se cijela livada. Na sheetu piše ime sezone čije je polje otvoreno. Ta sezona je i sezona runa.

Magnet i Loot Boost ostaju, isti efekti, 4 nivoa. **Nivo je po sezoni.** Nova sezona krene od 0. Povratak u staru vrati njene nivoe. Run čita nivoe aktivne sezone.

Plaćanje jednog nivoa, za sva tri boosta:

- **2 ★3 te sezone** (cvijet druge sezone ne važi);
- **coini** iz istog novčanika. Nacrt, označen kao nacrt: nivo 1 = 10, nivo 2 = 20, nivo 3 = 40, nivo 4 = 60. Jedan run daje oko 8 coina. Nivo ne smije koštati blizu 500 (to je cijena cijele sezone). Ako promijeniš krivulju, upiši brojeve i razlog u README § Odlučeno. Inače važi ovaj nacrt.

Dugme na kartici pokazuje cijenu (cvijet ×2 i coini). Stanja, bez podnaslova-eseja: može se platiti · fali cvijet · fali coin · fali oboje · max.

### 3.5 Treći boost — ti ga predlažeš, jedan

Jedan novi boost, pored Magneta i Loot Boosta. Ista šina:

- po sezoni, nivoi 0–4, ista cijena (2 ★3 te sezone + ista coin krivulja);
- **jedan** efekat i **jedna** formula;
- ne mijenja radijus magneta, množitelj loota, fail 50 %, revive, trajanje runa, plaćenu sezonu, ni cap 40;
- ne uvodi novu valutu.

U `godot/` JSON-u (`decisions` + poseban objekat boost-a) mora pisati, rečenicama, ne samo u slici:

- ime (EN, kratko) i šta igrač osjeti u runu;
- formula na nivou 0 i na nivou 4, s jednim brojčanim primjerom;
- šta se **ne** mijenja (lista iz odlomka iznad);
- šta dugme pokaže u svih pet stanja iz §3.4.

To se čita pri raspakivanju zipa, prije koda. Ako formula ima granu koja nije napisana, boost nije gotov.

### 3.6 Košara na Homeu — pravilo, ne novi ekran

Ne crtaj Home. Pravilo ide u JSON (`strings_en` + `decisions`), da ga kasniji prenos ne izmisli.

U picker košare ulazi samo sjeme **te sezone** koje je igrač **barem jednom skupio u lane runu**. Brojač već postoji i raste samo na pickup u runu (`record_seed_pickup_lifetime` u `game/scripts/run/run_controller.gd`). Starter pack, daily chest i trade **ne** otvaraju košaru. Sjeme koje nikad nije skupljeno **nema red** (nema katanca po tipu).

Bonus ostaje +5 % šanse da pickup bude sjeme. Tipovi u runu ostaju ravnomjerni.

Ako picker nema nijedan tip, jedna kratka EN linija. Predloži je. Bez objašnjenja mehanike.

## 4. MORA / SMIJE

### 4.1 MORA

- Sve iz §3.
- Pravila iz §2, uključujući tekst koji camp v2 već nije imao.
- Mergeable oznaka i katanac rezervisanog cvijeta razlikuju se na prvi pogled.
- Prodaja mergeable sjemena i dalje radi (1 / 10 po sekundi).
- Vrata arene: ispod 50 nema runde; N broji samo stogove ≥ 4, cijeli stog.
- Nadogradnje pokazuju sezonu, nivo 0 na novoj, sačuvan nivo na povratku.
- Treći boost ima napisanu formulu, primjer i pet stanja dugmeta.
- Košara: nikad skupljeno sjeme se ne nudi; +5 % ostaje +5 %.
- Sve interaktivno ≥ 120 px; tekst ≥ 34 px; EN tekst.
- Header 143 i footer 144 se ne mijenjaju. Stranica 1080 × 1633. Nema horizontalnog gesta na stranici (hub se lista prstom).

### 4.2 SMIJEŠ

- Izabrati tačnu boju pozadine Campa, dok nije zelena i dok sjedi uz `#2A2233`.
- Smisliti oblik mergeable oznake (ne katanac).
- Na vratima arene pokazati sitne stogove drugačije od mergeable, bez rečenice.
- Promijeniti coin krivulju uz napisan razlog. Cvijet ostaje 2 ★3 te sezone.
- Izabrati efekat trećeg boosta, unutar zabrana iz §3.5.
- Skratiti praznu liniju košare.

## 5. Tokeni i stil

Polazi od `design_handoff_camp_v2/` i `game/scripts/visual/ui_camp.gd`. Novo je samo pozadina i oznaka.

- danas stranica `#2E4733` — to ide van;
- chrome `#2A2233`, tinta `#2D3436`, papir `#FFF8F0`, coin `#FFD56B`, peach `#FFB88C`, mint `#A8E6CF`;
- rezervisani cvijet zadržava svoj badge i svoj strip;
- radijusi i jedna sjena kao u camp v2. Bez blura na tekstu.

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

Artboard 1080 × 1920. Sve mjere u px te baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna sjena. Animacije su tweenovi (0,08–0,42 s). Bez blura, gradijenata na panelima, teških čestica, 3D-a i stalnog pulsiranja više elemenata odjednom. Art sjemenki i cvijeća crta igra. Ne treba novi art cvijeta, samo oznaka na kartici.

## 7. Isporuka

### 7.1 Stanja koja moraju biti nacrtana

Camp (`CampScreen.dc.html`, prop `scene`):

1. **Seeds, nekoliko mergeable i jedan stog ispod 4** — oznaka samo na mergeable; odabran mergeable tip, linija ispod Tradea.
2. **Isti ekran, prodaja u toku** — linija ostaje, fill na dugmetu.
3. **Seeds, odabran tip ispod 4** — nema oznake, nema te linije. Trade i dalje radi.
4. **Flowers, rezervisani ★3** — stari badge i stari strip, da se vidi razlika.
5. **Prazna torba.**

Vrata (`ArenaGate.dc.html`):

6. **42 / 50** — sitni stogovi vidljivi, runda se ne otvara.
7. **53 / 50** — može se krenuti. Bez polja, munchera i čipova.

Sheet (`UpgradesSheet.dc.html`), ista sezona na sva tri:

8. **Nova sezona, sve na 0**, može se platiti prvi nivo (ima 2 ★3 i dovoljno coina).
9. **Fali cvijet** na jednoj kartici, **fali coin** na drugoj.
10. **Povratak u staru sezonu** — Magnet već na 2, ostalo na 0. Ime sezone je drugačije nego u 8.
11. **Treći boost na max** (nivo 4), formula vidljiva na kartici kao kratak broj, ne kao pasus.

### 7.2 Paket

Zip za preuzimanje u chatu, cijeli folder.

```
design_handoff_camp_v3/
  README.md
  design/
    CampScreen.dc.html
    ArenaGate.dc.html
    UpgradesSheet.dc.html
    Camp Specs.dc.html       sva stanja iz 7.1 + spec oznake i trećeg boosta
    HubScreen.dc.html        kopija chromea, ne mijenja se
    support.js · icons/
  assets/
  godot/
    camp_v3_export.json      ista šema kao design_handoff_shop/godot/shop_export.json
                             plus objekat third_boost (formula, nivo 0, nivo 4,
                             primjer, pet stanja dugmeta, šta se ne dira)
    ui_camp.gd               samo nova pozadina i stil oznake
    camp_tree.txt
    README.md
```

U `decisions` obavezno: boja pozadine, oblik mergeable oznake, coin krivulja (nacrt ili tvoja, s razlogom), ime i formula trećeg boosta, EN linija prazne košare.

**Imena slojeva:** `CampPage`, `StashSection`, `CampChip`, `MergeableMark`, `MergeableWarning`, `ReservedBadge`, `ReservedWarning`, `TradeBar`, `ArenaGate`, `GateCount`, `UpgradesSheet`, `SeasonTitle`, `MagnetCard`, `LootCard`, `ThirdCard`, `UpgradeButton`.

## 8. Ne tražimo

- Redizajn polja arene, munchera, sipanja, mergea, Home livade, headera, footera, Shopa, Ormara, Pipa, runa.
- Novu valutu, energy, pay-to-continue, IAP za nadogradnju.
- Cap 40 i brisanje viška — ostaje za kasnije.
- Košaru koja daje 100 % jednog tipa.
- Više varijanti za biranje. Jedan dizajn. Dilemu odluči i upiši u README jednom rečenicom.

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim treću rundu Campa i dva mala ekrana uz njega, u mobilnoj igri
Merge Meadow. Portrait, flat pastel cartoon, cozy livada. Bez pixel-arta
i bez 3D.

Camp si već radio. Paketi su u repou:
  design_handoff_camp/
  design_handoff_camp_v2/
Ovo nije novi raspored Campa. Raspored v2 ostaje. Mijenja se pozadina,
dodaje se oznaka na sjemenu, i dolaze vrata Arene + sheet nadogradnji.

Pročitaj fajl (ako se prompt i fajl razlikuju, važi fajl; §10 preskoči):
  docs/04-experience/design-drafts/camp-v3-cd-brief.md

Kontekst, ne diraj ove ekrane osim što chrome kopiraš:
  design_handoff_camp_v2/design/CampScreen.dc.html
  design_handoff_hub_chrome_v2/design/HubChromeScreen.dc.html
  game/scripts/visual/ui_camp.gd
  game/scripts/visual/ui_chrome.gd

JEDAN DIZAJN. Bez smjerova i bez alternativa. Dilemu odluči sam i upiši
jednu rečenicu u README § Odlučeno.

ŠTA MORA:

1. Camp pozadina. Danas je stranica zelena #2E4733. Header i footer su
   dusk plum #2A2233 (143 px i 144 px) i NE mijenjaju se. Stranica između
   njih je 1080 x 1633. Izaberi pozadinu koja sjedi uz tu traku i uz
   ostatak huba. Nije zelena. Kartice moraju ostati čitljive.
   Tekst koji v2 već nema nemoj vratiti: "Next free season", "Details",
   podnaslov Unlock, Merge prečica, "Arena fuel" / "reward",
   "1 coin each", "hold 10 / s".

2. Mergeable sjeme. U zbroj za Arenu ulazi samo tip kojeg ima 4 ili više,
   i ulazi CIJELI stog. Tip s 1, 2 ili 3 ne ulazi nimalo.
   Primjeri: 13+3+40 = 53 (trojka van); 49 jednog tipa = ne može;
   četiri tipa po 12 = 48 = ne može; 50 jednog tipa = može.
   Na kartici mala oznaka samo kad je stog mergeable. Dok je odabran i
   dok se prodaje, jedna kratka linija ispod Trade reda.
   Oznaka NE smije ličiti na katanac rezervisanog cvijeta: cvijet se
   čuva, ovo sjeme se SMIJE prodati (tap = 1, držanje = 10/s).
   Tip ispod 4 nema ni oznaku ni liniju.

3. Vrata Arene, NE polje. Ne crtaj muncher, čipove, sipanje ni merge.
   Prije runde stoji N / 50. Ispod 50 vreća ne otvara rundu. Na 50 smije.
   Sitni stogovi se vide, ali se vidi i da ne ulaze u N. Bez rečenice
   uputstva.

4. Sheet nadogradnji na Homeu (ne crtaj livadu). Ime sezone na sheetu.
   Magnet i Loot Boost ostaju: 4 nivoa; radijus 40+48*nivo;
   loot x1, x1.25, x1.5, x1.75, x2.
   Nivo je PO SEZONI. Nova sezona krene od 0. Povratak vrati stare nivoe.
   Cijena nivoa: 2 cvijeta ★3 TE sezone (tuđi cvijet ne važi) + coini.
   Nacrt coina: 10 / 20 / 40 / 60. Run daje ~8 coina; nivo ne smije
   koštati blizu 500. Ako mijenjaš krivulju, upiši brojeve i razlog.
   Inače važi nacrt. Stanja dugmeta: može · fali cvijet · fali coin ·
   fali oboje · max.

5. TI predlažeš JEDAN treći boost, iste šine (po sezoni, 0–4, ista cijena).
   Jedan efekat, jedna formula. Ne dira magnet, loot množitelj, fail 50%,
   revive, trajanje runa, plaćene sezone, cap torbe 40, i ne uvodi valutu.
   U godot JSON-u (objekat third_boost) napiši: ime, šta igrač osjeti,
   formulu na 0 i na 4, jedan brojčani primjer, šta se ne mijenja, i svih
   pet stanja dugmeta. Ako grana nije napisana, boost nije gotov.

6. Košara se NE crta (nema Home ekrana). U JSON upiši pravilo i jednu
   kratku EN liniju za prazan picker: u košaru ulazi samo sjeme te sezone
   koje je igrač barem jednom skupio u lane runu. Nikad skupljeno se ne
   lista. Nema reda s katancem po tipu. Bonus ostaje +5% šanse da pickup
   bude sjeme, ne 100% tog tipa. Starter pack, daily i trade ne otvaraju
   košaru.

MORA OSTATI: trade 1 / 10 po sekundi, cijene, rezervisano cvijeće
(Kept N/M + strip, držanje staje na granici), sezona 500+20, cap 40
(višak i dalje nestaje — ne rješavaj to), header i footer.

TEHNIČKI: artboard 1080 x 1920, px 1:1. Paneli = ravna boja, radius,
border, jedna sjena. Tween 0.08–0.42 s. Bez blura, gradijenata na
panelima, teških čestica i 3D. Art cvijeta crta igra.

ISPORUKA (§7): stanja iz §7.1 i paket TAČNO
design_handoff_camp_v3/ s README.md, design/ (CampScreen.dc.html,
ArenaGate.dc.html, UpgradesSheet.dc.html, Camp Specs.dc.html,
HubScreen.dc.html, support.js, icons/), assets/ i godot/
(camp_v3_export.json, ui_camp.gd, camp_tree.txt, README.md).
Na kraju ZIP ZA PREUZIMANJE u chatu, cijeli folder.

IMENA SLOJEVA: CampPage, StashSection, CampChip, MergeableMark,
MergeableWarning, ReservedBadge, ReservedWarning, TradeBar, ArenaGate,
GateCount, UpgradesSheet, SeasonTitle, MagnetCard, LootCard, ThirdCard,
UpgradeButton.

NE RADI: polje Arene, Home livadu, Shop, Ormar, Pip, run, novu valutu,
energy, pay-to-continue, IAP za upgrade, košaru na 100% jednog tipa.
Jedan dizajn. Ideje van zadatka na kraj README-a.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

Ne raditi u ovoj rundi. Treći boost se prvo čita iz `third_boost` u JSON-u. Ako formula, nivo 0, nivo 4 ili stanje dugmeta fali, prenos staje na tom boostu.

| CD sloj | Godot, danas |
|---|---|
| pozadina Campa | `game/scripts/visual/ui_camp.gd` → `MEADOW_BG` `#2E4733` |
| `CampChip`, `MergeableMark` | `game/scripts/camp/camp_stash_chip.gd` (danas rezervacija, ne mergeable) |
| `MergeableWarning`, `TradeBar` | `game/scripts/camp/camp_trade_bar.gd` |
| `ReservedBadge` / `ReservedWarning` | isti chip i trade bar — ostaju za ★3 sezone |
| `ArenaGate` | `game/scripts/camp/merge_arena_controller.gd` — prvi pour danas otvara `_session_open` čim neki tip ima ≥ 4. Prag 50 ide prije toga |
| zbroj od 50 | novi pomoćnik nad `seed_bag`: zbroj `count` gdje je `count >= 4` |
| `UpgradesSheet` | `game/scenes` Home → `%UpgradesOverlay`, `game/scripts/ui/main_menu.gd` |
| nivoi | `game/scripts/autoload/game_state.gd` `magnet_level` / `multiplier_level` su globalni. Prenos ih dijeli po `active_season_id` |
| cvijet nadogradnje | `spend_flowers_for_upgrade` danas uzme bilo koji ★3. Prenos uzima samo ★3 te sezone. Coin krivulja je nova |
| košara | `get_unlocked_loadout_types_for_season` + `get_lifetime_seeds_collected >= 1`. Lifetime raste samo u `run_controller.gd` (`record_seed_pickup_lifetime`) |
| +5 % | `LOADOUT_SPAWN_BONUS` i `pick_random_run_seed_type` — tip ostaje ravnomjeran |

## Povezano

- [[_index|_index]]
- [[camp-v2-cd-brief|camp-v2-cd-brief]]
- [[merge-arena-cd-brief|merge-arena-cd-brief]]
- [[../02-design/ekonomija-brojevi|ekonomija-brojevi]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
