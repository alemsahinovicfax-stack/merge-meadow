---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, monetizacija, coini, shop, home, camp, wardrobe, claude-design]
povezano:
  - ads-only-cd-izvjestaj
  - ads-only-coini-izvjestaj
  - shop-v2-cd-brief
  - home-v3-cd-brief
  - camp-season-link-cd-brief
  - muncher-premium-pip-cd-brief
  - popups-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: v1 izlazi bez kupovina pravim novcem, pa se teme (10000 C), Sir Pip, Merge Hint i Loot Burst kupuju coinima u dva tapa. Traži se dizajn ekrana koje je to poremetilo: Shop tenda za 3 taba (i 4 kad se IAP vrati), Home tabovi „Free / Premium" koji više ne znače ništa, jedan sistem coin cijene (obično / fali / potvrda / kupljeno, „Need N more coins", 5 cifara), oznaka i boja „Premium" bez pravog novca, Camp kartica teme. Logiku i cijene je agent već ugradio."
---

# v1 bez kupovina — Shop, Home i Camp za coine · Claude Design brief

> **Status 2026-10-27: spremno za slanje.** Slike: `ads-only-ref/` (a00–a15). Izvještaj sesije: [[ads-only-cd-izvjestaj|ads-only-cd-izvjestaj]]. Prompt je u §9.
>
> **Prije slanja: commitaj i pushaj na `master`.** CD čita repo samo po tačnim putanjama s mastera.

Agent je već uradio **logiku i cijene** ([[../../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]]):

- Prva verzija izlazi **bez kupovina pravim novcem** (BiH nije Google Play merchant zemlja). Zarada je samo od reklama.
- Teme (Moonlit Warren, Coral Tide Garden, Starfall Glade; Ember Fen kad izađe) koštaju **10000 coina**, Sir Pip **3000**, Merge Hint **1500**, Loot Burst **1000**. Kupuju se na istim mjestima kao ranije za €: Shop, Home (tab Premium), Camp (kartica sljedeće sezone), a Sir Pip i preko Ormara.
- **Dva tapa svuda:** prvi tap → tamno „✓ cijena" 3 s, drugi tap kupuje. Bez dovoljno coina: dugme drhti, coin čip u headeru pulsira i piše **„Need N more coins"**.
- Remove Ads, Starter Pack i Restore purchases ne postoje u v1. Shop ima **3 taba** (Seasons · Looks · Boosters), Support tab nestaje.
- ★3 sjeme pada dvostruko češće (ne traži dizajn — samo da znaš zašto ima više zlatnih cvjetova).

**Sve to radi, ali izgled je poremećen:** tenda u Shopu je napravljena za 4 taba (agent je samo centrirao 3), Home tabovi „Free / Premium" opisuju razliku koja više ne postoji (sve se kupuje coinima), cijene od 5 cifara ne staju lijepo u pilule, kvačica u Campu se crta kao „√", a ljubičasta „Premium" boja i dalje znači „pravi novac". **Traži se plan kako ovo izgleda** — jedan dosljedan sistem kupovine za coine na sva tri ekrana.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7 + slike u `ads-only-ref/` + [[ads-only-cd-izvjestaj|ads-only-cd-izvjestaj]] | Šta je danas, šta mora, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §4, §5, §8 | Kod, brojevi, prenos, FPS |

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stil | isti kao Shop v2, Home v3, Camp v3 / season link, hub chrome v2, popupi, Ormar (`design_handoff_shop_v2/`, `design_handoff_home_v3/`, `design_handoff_camp_v3/`, `design_handoff_camp_season_link/`, `design_handoff_hub_chrome_v2/`, `design_handoff_popups/`, `design_handoff_wardrobe/`, `design_handoff_muncher_premium_pip/`): flat, pastel, tamni obrub (ink `#2D3436`), ravne boje, jedna tvrda sjena. **Bez blura, glowa, gradijenata i maski** |
| Engine | Godot 4.7, GL Compatibility, slabiji Android, 60 FPS. Artboard 1080 × 1920, sve u px te baze |
| Cijene | **fiksne** (§4) — dizajn ih prikazuje, ne mijenja |
| Dva tapa | prvi tap = potvrda 3 s (`T_CONFIRM_TIMEOUT`), drugi tap kupuje; isto u Shopu, na Homeu i u Campu. Potvrda se poništi kad igrač lista karticu, promijeni tab ili ode s ekrana |
| Pillar 2 (Fair F2P) | **nema** paketa coina, popusta, tajmera, „limited", „best value", odbrojavanja ni „kupi coine" dugmeta. Coini se samo zarađuju. Plaćene stvari su izgled ili mala pomoć, nikad snaga |
| Bez pravog novca u v1 | nigdje „€", „$", „Restore purchases", „Purchase cancelled", „billing", „in-app purchase" (provjerava `iap_off_smoke`) |
| Povratak IAP-a | kad se merchant riješi, isti ekrani moraju raditi s **€ cijenama i 4 taba** (danas `a15`). Dizajn mora imati i tu varijantu — ili biti takav da radi u oba režima |
| Hub chrome | header (coin · sjeme · cvijeće čipovi, zupčanik) i footer se ne mijenjaju; coin čip pulsira kad fali coina (postoji) |
| Season Kit | 8 livada (4 besplatne, 4 teme), svijetle i tamne — sve na karticama tema se mora čitati na svim (tekst ≥ 4,5 : 1) |
| Besplatni put | Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy, redom, svaka košta coine **i** ★3 cvjetove prethodne (§4). Ovo je glavni put i mora ostati glavni na Homeu |

## 2. Danas (slike `a00`–`a15`)

**Shop (`ads-only-ref/`):**
- `a15_shop_seasons_iap_on_4_tabs` — Shop **s kupovinama** (poređenje): tenda s 4 taba, teme s € cijenom. Dizajn iz `design_handoff_shop_v2/`.
- `a00_shop_header_broken_before_fix` — v1 prije agentove zakrpe: bijele pozadine 4 taba ispod 3 pomjerena (pokvareno).
- `a01_shop_seasons_coins_short` — v1 sada: 3 taba centrirana na tendi, ~150 px prazno lijevo i desno; teme „10000" blijede (wallet 4200).
- `a02_shop_seasons_need_more_coins` — tap na blijedu pilulu: drhtaj + pilula „Need 5800 more coins".
- `a03_shop_seasons_coins_buy` — dovoljno coina: zlatne pilule.
- `a04_shop_seasons_confirm` — potvrda „✓ 🪙 10000": šira, raste ulijevo preko mjeseca na kartici.
- `a05_shop_boosters_coins` — Merge Hint 1500, Loot Burst 1000.
- `a06_shop_looks_sir_pip_coins` — Sir Pip 3000; ljubičasta oznaka „Premium" (`MONEY #D4A5FF` = boja pravog novca u Shop v2).

**Home (`ads-only-ref/`):**
- `a07_home_free_tab` — tab Free (krem, sjemenka), Country Bloom.
- `a08_home_free_tab_locked_next` — Free · Frost Orchard zaključan: pilule „2500 / 2500" (coini) i „★3 4 / 22".
- `a09_home_premium_coin_buy` — tab Premium (zlatni), Moonlit Warren, zlatna pilula „🪙 10000".
- `a10_home_premium_confirm` — potvrda „✓ 🪙 10000".
- `a11_home_premium_short_toast` — fali coina: blijeda pilula + toast „Need 5800 more coins".

**Camp (`ads-only-ref/`):**
- `a12_camp_theme_price` — kartica sljedeće sezone kad su besplatne gotove: tema, žuta oznaka „PREMIUM", „6 new flowers", dugme „🪙 10000".
- `a13_camp_theme_confirm` — potvrda: „√ 10000" (font nema „✓").
- `a14_camp_theme_short_toast` — fali coina: blijedo dugme + toast.

**Kod:**
- `game/scripts/monetization/monetization_config.gd` — `IAP_ENABLED`, `IAP_PRODUCTS` (`coin_price`), `PREMIUM_SEASON_COINS`, `shows_paid_offer`.
- `game/scripts/monetization/iap_manager.gd` — `buy_with_coins`, `is_coin_offer`, `get_coin_price`.
- `game/scripts/visual/ui_shop_v2.gd` — `TABS`, `TAB_LABELS`, `visible_tabs()`, mjere tende i tabova (`TABBAR_H`, `AWNING_*`, `TAB_X0`, `TAB_Y`, `TAB_W`, `TAB_H`, `TAB_STEP`), `coin_state`, `need_coins_text`, `S_NEED_COINS`, boje `MONEY`, `MONEY_SOFT`, `STATUS_PENDING_BG`, `T_CONFIRM_TIMEOUT`.
- `game/scripts/ui/shop_tab_bar.gd` — tenda i tabovi (`_draw`, `_x_for`, klizač).
- `game/scripts/ui/shop_screen.gd`, `game/scripts/ui/shop_card.gd`, `game/scripts/ui/season_pack_card.gd`, `game/scripts/ui/shop_booster_card.gd`, `game/scripts/ui/shop_premium_look_card.gd`, `game/scripts/ui/shop_buy_button.gd` — kartice i coin dugme (stanja `coins.buy`, `coins.confirm`, `coins.short`).
- `game/scripts/ui/home_v3_tabs.gd` — SeasonTabs (Free / Premium, 1032 × 124, tab 508 × 108).
- `game/scripts/ui/season_stage.gd` — `tab_ids`, `_buy_with_coins`, `_confirm_buy_id`, toast.
- `game/scripts/ui/home_v3_card_content.gd` — `_draw_coin_buy`, `_coin_buy_w` (coin pilula na kartici teme), pilule napretka besplatne sezone.
- `game/scripts/visual/ui_home_v3.gd` — mjere i boje Homea (`TABS_RECT`, `TAB_SIZE`, `GOLD`, `CREAM`).
- `game/scripts/camp/season_link_card.gd` — `_show_paid_coins`, `_buy_paid_coins`, `get_paid_button_state`, toast.
- `game/scripts/visual/ui_camp.gd` — `paid_confirm_style`, `premium_tag_style`, `S_PREMIUM_TAG`, `unlock_button_style`.
- `game/scripts/ui/wardrobe_sheet.gd`, `game/scripts/visual/ui_wardrobe.gd`, `game/scripts/ui/item_card.gd` — Sir Pip u Ormaru (veo, „Premium").
- `game/scripts/dev/ads_only_capture.gd` — snimač slika iz ovog briefa.

**Šta fali:** tenda za 3 taba (i varijanta za 4), smislena podjela sezona na Homeu kad sve košta coine, jedan sistem coin cijene na sva tri ekrana (5 cifara, potvrda bez „√", „Need N more coins" kao dio dizajna, ne pozajmljen status), i oznaka / boja za „posebnu stvar za coine" koja ne obećava pravi novac.

## 3. Šta se traži

### A. Shop — tenda s tabovima

**A1. Tenda za 3 taba (v1).** Seasons · Looks · Boosters na tendi 1080 × 172 (pruge, zaobljeno dno, tvrda sjena — iz Shop v2). Danas 3 taba 249 × 120 stoje centrirano s praznim krajevima. Predloži raspored: širi tabovi (npr. 3 × ~336), drugačiji razmak, ili tenda koja „zna" koliko tabova ima. Peach klizač aktivnog taba (0,2 s cubic-out) ostaje.

**A2. Varijanta za 4 taba (kad se IAP vrati).** Isti sistem s Support tabom (danas `a15`). Prebacivanje je jedan prekidač u kodu — oba rasporeda iz istih pravila (npr. širina taba = f(broj tabova)).

### B. Home — sezone kad sve košta coine

**B1. Šta umjesto „Free / Premium".** SeasonTabs (1032 × 124, dva taba 508 × 108) dijeli besplatni put od tema. „Free" više nije tačno (Frost košta 2500 C + ★3), „Premium" sugeriše pravi novac. Predloži:
- **imena i ikone** dva taba (npr. „Journey · Themes", „Path · Extras", „Seasons · Themes" — tvoj izbor; kratko, engleski, ≤ 10 znakova da stane na 46 px);
- ili **drugačiju strukturu** (npr. jedan red kartica s razdjelnikom „Themes" poslije Amber Canopyja) — ako je bolja, objasni zašto. Glavni besplatni put mora ostati prvi i najvidljiviji;
- boje tabova (danas krem i zlatni).

**B2. Kartica teme na Homeu — kupovina.** Danas zlatna pilula „🪙 10000" ispod cvjetova (`a09`). Dizajniraj sva stanja (§3 C): može se kupiti · fali coina · potvrda · kupljeno („Yours" → ▶ Play kao danas) · aktivna tema.

**B3. (opcionalno) Koliko fali.** Besplatna sezona pokazuje napredak („2500 / 2500", „★3 4 / 22", `a08`). Za temu predloži da li i kako pokazati „4,200 / 10,000" — kao cilj štednje, **bez** pritiska (nema tajmera, odbrojavanja ni „samo još…"). Ako misliš da ne treba, napiši zašto u § Odlučeno.

**B4. Varijanta s IAP-om.** Kad se kupovine vrate, teme će imati € cijenu (postojeći dizajn iz `design_handoff_home_v3/`). Pokaži kako tvoj B1 izgleda u tom režimu (može biti isti, samo druga cijena).

### C. Jedan sistem coin cijene (Shop, Home, Camp)

Danas tri ekrana imaju tri različite coin pilule / dugmeta. Treba **jedan sistem** s istim stanjima, prilagođen veličini mjesta:

| Stanje | Danas | Traži se |
|---|---|---|
| Može se kupiti | zlatno, 🪙 + broj | isto, ali broj s razmakom hiljada kao header („10,000") — tvoja odluka: zarez, uski razmak, ili bez |
| Fali coina | blijedo (bež), tap → drhtaj + puls čipa | jasno „još ne", ali i dalje se čita cijena; ne smije ličiti na onemogućeno zauvijek |
| „Need N more coins" | Shop: pilula statusa `#FFE8B8`; Home / Camp: toast | **dizajniran element**: gdje stoji na kartici (Shop), kako izgleda toast (Home / Camp, stil `design_handoff_popups/`), koliko traje |
| Potvrda (prvi tap, 3 s) | tamno „✓ 🪙 10000"; u Shopu raste ulijevo preko dekoracije, u Campu „√" | ista širina kao obično stanje (ili najviše +X px, napiši), **kvačica kao SVG asset**, ne slovo fonta; vidljiv znak da se čeka drugi tap (npr. tanka traka 3 s) |
| Kupuje se | Shop: drhtaj → ✓; Home / Camp: burst | kratak trenutak (≤ 0,6 s), ponovo iskoristi postojeći burst / ✓ |
| Kupljeno | Shop: ▶ Play / „Yours" / Wearing; Home: „Yours"; Camp: skok na Home | isto, samo uskladi izgled |

Mjere: 5 cifara (10000) mora stati u **najmanju** varijantu (Camp dugme na kartici sezone i Shop pilula na kartici teme) bez smanjivanja fonta ispod 44 px. Cijene od 4 cifre (1000–3000) moraju izgledati jednako dobro.

### D. „Premium" bez pravog novca

Riječ i boja „Premium" danas stoje na: Home tabu (zlatni), Camp oznaci „PREMIUM" (žuta pločica), Shop Looks Sir Pip (ljubičasta `MONEY #D4A5FF`), Ormaru (ljubičasta). Ljubičasta je u Shop v2 značila „ovo se plaća pravim novcem".

- **D1.** Predloži **jednu** oznaku za „posebna stvar za coine" (tema, Sir Pip) — riječ (npr. „Special", „Theme", „Rare", ili ostaje „Premium") i **jednu** boju — na sva četiri mjesta.
- **D2.** Šta s ljubičastom `MONEY` u v1: ostaje samo za IAP varijantu (A2 / B4) ili se mijenja. Napiši u § Odlučeno.

### E. Camp — kartica sljedeće teme

Kartica iz `design_handoff_camp_season_link/` (`a12`): kad su sve besplatne sezone otvorene, nudi sljedeću temu. Dugme cijene po sistemu iz C (sva stanja, bez „√"), oznaka iz D. Ostatak kartice (ime, „6 new flowers", 6 cvjetova) ostaje.

### F. (opcionalno) Boosters i Looks

Merge Hint, Loot Burst (`a05`) i Sir Pip (`a06`) već koriste Shop coin dugme. Samo provjeri da sistem iz C i oznaka iz D na njima izgledaju dobro; bez novog rasporeda kartica.

## 4. Podaci (fiksno — već u igri)

**Cijene (coini):**

| Stvar | Coini | Napomena |
|---|---|---|
| Moonlit Warren · Coral Tide Garden · Starfall Glade | 10000 svaka | bez ★3 uslova; Ember Fen ista cijena, ne nudi se dok sezona nije u igri |
| Sir Pip · Meadow Knight | 3000 | Shop · Looks; Ormar vodi u Shop |
| Merge Hint | 1500 | trajno |
| Loot Burst | 1000 | više puta; kartica se ne pokazuje kad su sve besplatne sezone otvorene |
| Frost Orchard (besplatni put) | 2500 + 22 ★3 Harvest Pumpkin | linearno |
| Lantern Meadow | 4500 + 26 ★3 Crystal Peony | |
| Amber Canopy | 6500 + 30 ★3 Midnight Lotus | |
| Najskuplji obični izgled (Looks) | 2500 | za poređenje |

**Mjere danas:**

| Element | Mjera |
|---|---|
| Shop tenda | 1080 × 172 (`TABBAR_H`), pruge 18 × 60, visina 160 (`AWNING_H`) |
| Shop tab | 249 × 120, korak 261, x0 24, y 10 (4 taba); v1 3 taba centrirana (x0 ≈ 154) |
| Home SeasonTabs | 1032 × 124 (radius 62), tab 508 × 108, labela 46 px |
| Shop coin dugme | ikona 60, padding 30 / 40, razmak 14, kvačica 30 (`shop_buy_button.gd`) |
| Potvrda | 3 s (`T_CONFIRM_TIMEOUT`) |
| Tekst kad fali | „Need %d more coins" (`S_NEED_COINS`) |

**Za mock:** wallet **4,200** (dosta za Sir Pipa i boostere, ne za temu → „Need 5800 more coins") i **12,000** (dosta za jednu temu). Besplatna sezona Frost Orchard zaključana s „2500 / 2500" i „★3 4 / 22". Sve tri teme ne-kupljene, pa jedna kupljena („Yours" / ▶ Play).

**Kad igrač kupuje (simulacija, medijan):** Sir Pip average 36. dan · prva tema average 41., skilled 32., casual 88. dan; ako štedi samo za temu: average 9 dana. Teme su dugoročni cilj.

## 5. Performanse (MORA, u README)

| | Budžet |
|---|---|
| Tenda s tabovima (A) | crta se jednom (pruge + pozadine tabova), klizač je jedan StyleBox koji se pomjera; **bez** novih čvorova po tapu |
| Coin dugme / pilula (C) | stanja su promjena StyleBoxa / teksta / ikone — ništa po frejmu; potvrda 3 s: najviše jedna traka ili tačkica koja se animira transformom |
| Drhtaj, puls čipa, „Need N" (C) | ≤ 0,5 s, samo transformi i alfa, ≤ 4 sprite-a istovremeno |
| Trenutak kupovine (C) | ≤ 0,6 s, ≤ 12 sprite-ova (postojeći burst se smije ponovo koristiti) |
| Toast (Home / Camp) | u budžetu toasta iz `design_handoff_popups/` |
| SVG | ukupno ≤ 60 KB za sve nove assete (kvačica, eventualna oznaka, ikone tabova) |
| Shop skrol | Seasons s 3 teme i Looks s 10+ kartica i dalje 60 FPS na slabom Androidu — oznake i dugmad ne smiju dodati `_draw` po frejmu |

U README napiši stvarne brojeve.

## 6. Isporuka

### 6.1 Stanja (sve živo u pregledaču)

- Shop: tenda s 3 taba (svaki aktivan) i s 4 taba (IAP varijanta); Seasons s 3 teme u stanjima: fali coina, „Need N more coins", može se kupiti, potvrda, kupljeno (▶ Play); Boosters (Merge Hint, Loot Burst); Looks · Sir Pip s oznakom iz D.
- Home: novi B1 (oba taba / struktura) na svijetloj i tamnoj sezoni; kartica teme u svim stanjima (B2), opcionalno B3; zaključana besplatna sezona (napredak coina i ★3); IAP varijanta (B4).
- Camp: kartica teme (dovoljno / fali + toast / potvrda / kupovina → skok na Home).
- Ormar: Sir Pip pod velom s oznakom iz D.
- Prekidači: wallet (4,200 / 12,000), režim (v1 coini / IAP €), sezona (svijetla / tamna), „usporeno ×4".

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_ads_only/
  README.md                 šta otvoriti · § Odlučeno · § Performanse · § Samoprovjera
  design/
    ShopTabs.dc.html        tenda s 3 i 4 taba, klizač, aktivni tab
    CoinPrice.dc.html       sistem coin cijene: sva stanja × Shop / Home / Camp veličina
    ShopCoins.dc.html       Seasons / Boosters / Looks s novim sistemom i oznakom
    HomeSeasons.dc.html     B1 (tabovi ili struktura), kartica teme u svim stanjima, B3, B4
    CampTheme.dc.html       Camp kartica sljedeće teme, sva stanja + toast
    PremiumTag.dc.html      oznaka i boja „posebno za coine" na 4 mjesta (D)
    Specs.dc.html           mjere, boje, vremena, budžeti
  assets/
    icons/*.svg             kvačica potvrde, ikone Home tabova, oznaka (ako je asset)
  godot/
    shop_tabs.json          mjere tende i tabova za 3 i 4 taba (širina, razmak, x0, radius)
    coin_price.json         stanja coin cijene: boje, rub, sjena, mjere po veličini, format broja, vremena
    home_season_tabs.json   imena, ikone, boje i mjere B1 (+ IAP varijanta)
    premium_tag.json        tekst, boje, mjere oznake (D) po mjestu
```

### 6.3 Samoprovjera (u README, svaka stavka da / ne, provjereno u pregledaču)

1. Tenda izgleda namjerno s 3 taba i s 4 taba (isti sistem); klizač radi u oba.
2. Home ne koristi riječ „Free" za sezone koje koštaju coine; besplatni put je i dalje prvi i najvidljiviji.
3. Coin cijena ima ista stanja na Shopu, Homeu i Campu (može / fali / „Need N more coins" / potvrda / kupljeno).
4. „10000" (i „10,000" ako tako odlučiš) staje u najmanju varijantu bez fonta ispod 44 px; potvrda nije šira od običnog stanja više od broja napisanog u Specs.
5. Kvačica potvrde je SVG asset (nigdje „√").
6. Nigdje „€", „$", „Restore purchases", „Purchase cancelled", „billing", popust, tajmer, „limited", „best value" ni paket coina u v1 varijanti.
7. Jedna oznaka i jedna boja za „posebno za coine" na sva 4 mjesta; odluka o ljubičastoj `MONEY` napisana u § Odlučeno.
8. IAP varijanta (4 taba, € na temama) postoji i ne lomi raspored.
9. Svi brojevi u mocku su iz §4 (ništa izmišljeno).
10. Budžeti iz §5 ispunjeni i napisani.
11. Nigdje blur, glow, gradijent ni maska; kartice tema čitljive na svih 8 sezona.

## 7. Ne tražimo

- Promjenu cijena, pravila dva tapa, besplatnog puta (2500 / 4500 / 6500 + ★3) ni balansa (to je agent + simulacija).
- Pakete coina, popuste, tajmere, ponude, „kupi coine", reklamu za coine (Pillar 2).
- Nove ekrane ili nove tabove u Shopu (Support se vraća tek s IAP-om).
- Redizajn header / footer chromea, Season Kita, kartica kozmetike u Looks (osim oznake i dugmeta), Ormara (osim oznake), Settingsa.
- Zvuk (agent ga veže: `coins_spend`, `ui_denied`, `ui_tab`).

## 8. Napomena za agenta (prenos)

- **Tenda:** `shop_tabs.json` → `UiShopV2` (`TAB_W`, `TAB_STEP`, `TAB_X0` kao funkcija `visible_tabs().size()`), `shop_tab_bar.gd` `_draw` / `_x_for`. Provjera: `shop_open_smoke`, `shop_nav_smoke`, `iap_off_smoke` (3 taba), sa `iap_override = 1` 4 taba.
- **Coin cijena:** `coin_price.json` → `ShopBuyButton` (Shop), `home_v3_card_content._draw_coin_buy` / `_coin_buy_w` (Home), `season_link_card._show_paid_coins` + `UiCamp.paid_confirm_style` (Camp). Kvačica kao tekstura umjesto „✓" glifa. Format broja na jednom mjestu: header već koristi `UiChrome.format_count` (`game/scripts/visual/ui_chrome.gd`, „12,000") — cijene kroz isti helper ako CD odluči za separator.
- **„Need N more coins":** `UiShopV2.need_coins_text` ostaje izvor teksta; Shop pilula (`shop_screen.gd`), toast na Homeu (`season_stage.gd`) i u Campu (`season_link_card.gd`).
- **Home B1:** `home_v3_tabs.gd` (imena, ikone, boje), `season_stage.gd` (`TAB_FREE` / `TAB_PREMIUM` ostaju interni ID-evi; mijenja se samo prikaz). Ako CD predloži jednu listu umjesto tabova — prvo plan s korisnikom, to je veća izmjena (`season_stage.gd` tab logika, `season_home_smoke`, `season_sync_smoke`).
- **Oznaka D:** `UiCamp.S_PREMIUM_TAG` / `premium_tag_style`, `UiShopV2.S_PREMIUM` / `PREMIUM_TAG_*`, `UiWardrobe.PREMIUM_TEXT` / `premium_tag`, `item_card.gd`.
- **Testovi:** `coin_offers_smoke`, `iap_off_smoke` (skener teksta), `season_home_smoke`, `season_sync_smoke`, `camp_paid_card_smoke`, `camp_season_link_smoke`, `wardrobe_smoke`, `shop_open_smoke`, GUT `test_coin_offers`. Nove snimke: `scripts/dev/ads_only_capture.gd` (iste a01–a15 poslije prenosa, za poređenje). FPS: Shop skrol prije / poslije (pravilo CD paketa).

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Nastavak za mobilnu igru Merge Meadow (portrait, flat pastel cartoon, zeko
Pip, 8 sezona-livada): v1 BEZ KUPOVINA PRAVIM NOVCEM — SHOP, HOME I CAMP
ZA COINE.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/ads-only-cd-brief.md
    -> §1 (fiksno), §2 (danas), §3 (šta se traži), §4 (brojevi),
       §5 (performanse), §6 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/ads-only-cd-izvjestaj.md
    (šta se promijenilo u sesiji i zašto)
  docs/04-experience/design-drafts/ads-only-ref/:
    a00_shop_header_broken_before_fix.jpg  tenda prije zakrpe (pokvareno)
    a01_shop_seasons_coins_short.jpg       3 taba (zakrpa), teme 10000, fali
    a02_shop_seasons_need_more_coins.jpg   „Need 5800 more coins"
    a03_shop_seasons_coins_buy.jpg         dovoljno coina
    a04_shop_seasons_confirm.jpg           potvrda „✓ 10000" (preširoka)
    a05_shop_boosters_coins.jpg            Merge Hint 1500, Loot Burst 1000
    a06_shop_looks_sir_pip_coins.jpg       Sir Pip 3000, ljubičasta „Premium"
    a07_home_free_tab.jpg                  Home · Free
    a08_home_free_tab_locked_next.jpg      Free · Frost zaključan (2500 + ★3)
    a09_home_premium_coin_buy.jpg          Home · Premium, 10000
    a10_home_premium_confirm.jpg           potvrda
    a11_home_premium_short_toast.jpg       fali coina + toast
    a12_camp_theme_price.jpg               Camp kartica teme, „PREMIUM"
    a13_camp_theme_confirm.jpg             potvrda „√ 10000" (pogrešan glif)
    a14_camp_theme_short_toast.jpg         fali coina + toast
    a15_shop_seasons_iap_on_4_tabs.jpg     Shop S kupovinama (4 taba, €)
  game/scripts/monetization/monetization_config.gd, iap_manager.gd
  game/scripts/visual/ui_shop_v2.gd     (TABS, visible_tabs, TAB_*, AWNING_*,
    coin_state, need_coins_text, MONEY, T_CONFIRM_TIMEOUT)
  game/scripts/ui/shop_tab_bar.gd, shop_screen.gd, shop_card.gd,
    season_pack_card.gd, shop_booster_card.gd, shop_premium_look_card.gd,
    shop_buy_button.gd
  game/scripts/ui/home_v3_tabs.gd, season_stage.gd, home_v3_card_content.gd
  game/scripts/visual/ui_home_v3.gd
  game/scripts/visual/ui_chrome.gd      (format_count — „12,000" u headeru)
  game/scripts/camp/season_link_card.gd, game/scripts/visual/ui_camp.gd
  game/scripts/ui/wardrobe_sheet.gd, game/scripts/visual/ui_wardrobe.gd,
    game/scripts/ui/item_card.gd
  design_handoff_shop_v2/, design_handoff_home_v3/, design_handoff_camp_v3/,
    design_handoff_camp_season_link/, design_handoff_hub_chrome_v2/,
    design_handoff_popups/, design_handoff_wardrobe/,
    design_handoff_muncher_premium_pip/, design_handoff_seasons/
    (tvoji paketi)

DANAS (već u igri, cijene FIKSNE): nema kupovina pravim novcem (BiH nije
Google Play merchant zemlja). Teme 10000 coina, Sir Pip 3000, Merge Hint
1500, Loot Burst 1000. Dva tapa svuda (prvi = „✓ cijena" 3 s, drugi kupuje),
bez dovoljno coina drhtaj + puls coin čipa + „Need N more coins". Remove
Ads / Starter Pack / Restore ne postoje -> Shop ima 3 taba. Ali izgled je
poremećen: tenda je za 4 taba, Home „Free / Premium" više ne znači ništa
(i besplatne sezone koštaju coine), 5 cifara ne staje lijepo, Camp kvačica
je „√", ljubičasta „Premium" i dalje znači pravi novac.

TRAŽI SE (plan kako izgleda):
A1. Shop tenda za 3 taba (Seasons · Looks · Boosters) — namjerno, ne
    centrirano s rupama. A2. Ista tenda za 4 taba (kad se IAP vrati).
B1. Home: umjesto „Free / Premium" — imena + ikone tabova (ili bolja
    struktura); besplatni put ostaje prvi i glavni.
B2. Kartica teme na Homeu u svim stanjima kupovine.
B3. (opcionalno) koliko fali do teme, bez pritiska.
B4. Home u IAP režimu (€ na temama).
C.  JEDAN sistem coin cijene za Shop, Home i Camp: može / fali / „Need N
    more coins" / potvrda (kvačica kao SVG, ne šira od običnog) / kupuje se
    / kupljeno; 5 cifara u najmanjoj varijanti, font >= 44 px; format broja
    kao header („10,000" — tvoja odluka).
D.  Jedna oznaka + jedna boja za „posebno za coine" (Home tab, Camp,
    Shop Sir Pip, Ormar); odluka o ljubičastoj MONEY.
E.  Camp kartica sljedeće teme po sistemu C i D.
F.  (opcionalno) provjera Boosters / Looks sa C i D.

PILLAR 2 (MORA): bez paketa coina, popusta, tajmera, „limited", „best
value", „kupi coine". U v1 nigdje „€", „$", „Restore purchases",
„Purchase cancelled", „billing".

PERFORMANSE (MORA, §5): ništa po frejmu; tenda se crta jednom; stanja
dugmeta = promjena stila / teksta; efekti <= 0,6 s; SVG <= 60 KB. Brojeve
napiši u README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android, 60 FPS): artboard
1080 x 1920. Stil kao Shop v2, Home v3, Camp, popupi: ravne boje, obrub,
jedna tvrda sjena. BEZ blura, glowa, gradijenata i maski.

ISPORUKA (§6): novi folder design_handoff_ads_only/, CIJELI U ZIPU za
preuzimanje u chatu (design/ShopTabs, CoinPrice, ShopCoins, HomeSeasons,
CampTheme, PremiumTag, Specs .dc.html; assets/icons; godot/shop_tabs.json,
coin_price.json, home_season_tabs.json, premium_tag.json; README sa
§ Odlučeno, § Performanse i § Samoprovjera — 11 stavki iz §6.3, svaka
da/ne, provjereno u pregledaču PRIJE nego pošalješ zip).

NE RADI: cijene, pravila kupovine, besplatni put, balans, nove ekrane ili
tabove, header / footer, Season Kit, Settings, zvuk. Jedan dizajn, tvoj
izbor, neka bude sočno i prelijepo.
```

## Povezano

- [[../_index|04-experience]]
- [[ads-only-cd-izvjestaj|ads-only-cd-izvjestaj]] — izvještaj sesije za CD
- [[../../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · [[../../06-production/CHECKPOINT|CHECKPOINT]] · [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]]
- [[shop-v2-cd-brief|Shop v2]] · [[home-v3-cd-brief|Home v3]] · [[camp-season-link-cd-brief|Camp season link]] · [[muncher-premium-pip-cd-brief|Sir Pip]] · [[popups-cd-brief|Popupi]]
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
