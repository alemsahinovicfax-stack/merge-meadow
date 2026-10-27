---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, monetizacija, coini, shop, home, camp, claude-design, izvjestaj]
povezano:
  - ads-only-cd-brief
  - ads-only-coini-izvjestaj
  - coin-ponude-simulacija
  - ekonomija-brojevi
  - shop-v2-cd-brief
  - home-v3-cd-brief
  - camp-season-link-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Izvještaj sesije 2026-10-26/27 za Claude Design: v1 izlazi bez kupovina pravim novcem, pa se teme (10000 C), Sir Pip (3000), Merge Hint (1500) i Loot Burst (1000) kupuju coinima u dva tapa; Remove Ads / Starter Pack / Restore nestali; ★3 sjeme ×2. Šta je to direktno i indirektno promijenilo na Shopu (3 taba umjesto 4), Homeu (Free / Premium više ne znači ništa), Campu i Ormaru, šta je agent privremeno popravio i šta je pokvareno — sa 16 snimaka."
---

# v1 bez kupovina — izvještaj sesije za Claude Design

> Roditelj: [[../_index|04-experience]] · Brief za izradu: [[ads-only-cd-brief|ads-only-cd-brief]] · Tehnički izvještaj: [[../../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · Cijene: [[../../02-design/ekonomija-brojevi#Coin cijene bez kupovina (v1, 2026-10-26)|ekonomija-brojevi]] · Simulacija: [[../../02-design/coin-ponude-simulacija|coin-ponude-simulacija]]
>
> Slike: `docs/04-experience/design-drafts/ads-only-ref/` (a00–a15, 1080 × 1920). Snimač: `game/scripts/dev/ads_only_capture.gd`.

## Ukratko

Bosna i Hercegovina nije Google Play merchant zemlja, pa prva verzija igre izlazi **bez kupovina pravim novcem** — zarađuje samo od reklama. Sve što se ranije prodavalo za € sada se kupuje **coinima zarađenim u igri**, osim Remove Ads i Starter Packa, koji su sakriveni. Kupovina coinima ide kroz isti kod kao Play kupovina, pa igra reaguje isto: tema se otključa, Sir Pip se obuče, booster stigne.

Ova promjena je **direktno** promijenila tri ekrana (Shop, Home, Camp) i Ormar. **Indirektno** je obezvrijedila nekoliko dizajnerskih odluka koje su pretpostavljale pravi novac: podjelu Home sezona na „Free / Premium", ljubičastu „money" boju, oznaku „PREMIUM" i Shop tendu napravljenu za 4 taba. Uz to su u drugom krugu (na zahtjev) sve teme poskupile na **10000 C**, a ★3 sjeme pada **dvostruko češće**.

Agent je sve to ugradio da **radi**. Izgled je na nekim mjestima privremen ili pokvaren, a jedan bug (Shop header) je privremeno zakrpljen. Kako to treba da izgleda, opisuje brief [[ads-only-cd-brief|ads-only-cd-brief]].

## 1. Pravila koja su se promijenila

| Šta | Prije (s IAP-om) | Sada (v1) |
|-----|------------------|-----------|
| Kupovine pravim novcem | Play Billing, € cijene | **nema**. `MonetizationConfig.IAP_ENABLED = false`; Billing plugin je isključen, pa APK / AAB nema ni dozvolu za kupovine |
| Teme (Moonlit Warren, Coral Tide Garden, Starfall Glade; Ember Fen kad izađe) | €2.99 / €3.49 | **10000 coina** svaka (u prvom krugu 3000 / 3500, pa na zahtjev 10000) |
| Sir Pip · Meadow Knight (premium Pip skin) | €3.99 | **3000 coina** |
| Merge Hint (trajni booster) | €0.99 | **1500 coina** |
| Loot Burst (+5 ★3 cvijeta sezone koja otvara sljedeću besplatnu; više puta) | €0.99 | **1000 coina**; kad nema cilja (sve besplatne sezone otvorene), kartica se ne pokazuje |
| Remove Ads, Starter Pack, Restore purchases | tab Support u Shopu, sekcija Purchases u Settingsu | **ne postoje** u v1 (reklame su jedina zarada; Starter Pack ima tajmer i daje coine — Pillar 2) |
| Potvrda kupovine | Shop: coin kozmetika dva tapa; € kupovina otvara Play dijalog | **dva tapa svuda**: prvi tap → tamno „✓ cijena" 3 s, drugi tap kupuje. Isto u Shopu, na Homeu i u Campu |
| Nema dovoljno coina | kozmetika: dugme drhti, coin čip pulsira | isto **+ tekst „Need N more coins"** (N = koliko fali): pilula na Shop kartici (sad i u Looks), toast na Homeu i u Campu |
| Zvuk | € kupovina `purchase_ok` | coin kupovina `coins_spend` (kao Looks), fali coina `ui_denied` |
| ★3 sjeme | 7–15 % rjeđe | **×2**, ali svaki ★3 tip i dalje rjeđi od ★2 tipa: 7,3 % sjemena na levelu 1 → 12,3 % na levelu 20; Endless 8,8 → 13,6 % |
| Kad se merchant riješi | — | prekidač nazad na `true` + plugin → **sve izgleda kao prije** (4 taba, €). Ono što je igrač kupio coinima ostaje njegovo |

**Pillar 2 (Fair F2P) ostaje netaknut:** nema paketa coina, popusta, tajmera ni „limited" ponuda. Coini se samo zarađuju igranjem; plaćene stvari su i dalje samo izgled (tema, skin) ili mala pomoć (booster).

## 2. Ekran po ekran — direktni uticaj

### 2.1 Shop

| Slika | Šta se vidi |
|-------|-------------|
| `a15_shop_seasons_iap_on_4_tabs` | **Za poređenje — Shop s kupovinama (kakav je bio i bit će kad se IAP vrati):** tenda s 4 taba Seasons · Looks · Boosters · Support, teme s € cijenom. Ovo je dizajn iz `design_handoff_shop_v2/` |
| `a00_shop_header_broken_before_fix` | **Pokvareno (prije agentove zakrpe):** bez kupovina Support tab nestaje, 3 taba su se pomjerila na sredinu, ali je tenda i dalje crtala bijele pozadine na sve 4 stare pozicije → pilule su virile ispod i između tabova |
| `a01_shop_seasons_coins_short` | **Sada (zakrpa):** 3 taba centrirana, s praznim prostorom lijevo i desno na tendi. Radi, ali tenda je dizajnirana za 4. Teme s coin pilulom **„10000"**: wallet 4200 je premalo, pa su pilule blijede (bež) |
| `a02_shop_seasons_need_more_coins` | Tap na blijedu pilulu: dugme drhti, coin čip pulsira i pojavi se pilula **„Need 5800 more coins"** |
| `a03_shop_seasons_coins_buy` | Wallet 12000: pilule zlatne (može se kupiti) |
| `a04_shop_seasons_confirm` | Prvi tap: tamna pilula **„✓ 🪙 10000"**. Šira je od obične i raste ulijevo, preko mjeseca na kartici Moonlit Warrena. Drugi tap u 3 s kupuje → kartica pokaže ▶ Play |
| `a05_shop_boosters_coins` | Boosters: Merge Hint **1500**, Loot Burst **1000** s coin pilulom (ranije €0.99) |
| `a06_shop_looks_sir_pip_coins` | Looks · Sir Pip: ljubičasta oznaka **„Premium"** gore lijevo (ljubičasta `#D4A5FF` = boja „pravog novca" u Shop v2), cijena **3000** coina istim dugmetom kao ostala kozmetika |

### 2.2 Home (polje sezone, SeasonTabs)

| Slika | Šta se vidi |
|-------|-------------|
| `a07_home_free_tab` | Tab **Free** (krem, ikona sjemenke) — Country Bloom otvoren |
| `a08_home_free_tab_locked_next` | Free · Frost Orchard zaključan: pilule **„2500 / 2500"** (coini, zelena kad ih ima) i **„★3 4 / 22"** (Harvest Pumpkin iz prethodne sezone). Dakle i „besplatna" sezona košta coine |
| `a09_home_premium_coin_buy` | Tab **Premium** (zlatni): Moonlit Warren s velikom zlatnom pilulom **„🪙 10000"** (ranije € cijena) |
| `a10_home_premium_confirm` | Prvi tap: tamno **„✓ 🪙 10000"**, drugi kupuje → „Yours" |
| `a11_home_premium_short_toast` | Wallet 4200: blijeda pilula, tap → toast **„Need 5800 more coins"** + puls coin čipa |

**Glavni problem Homea:** tabovi „Free" i „Premium" su opisivali razliku *besplatno naspram pravog novca*. Sada se **sve kupuje coinima**: besplatne sezone 2500 / 4500 / 6500 C + ★3 cvijeće redom (linearni put), teme 10000 C bez ★3 uslova. „Free" više nije tačno (Frost košta 2500), a „Premium" sugeriše pravi novac kojeg nema.

### 2.3 Camp (kartica sljedeće sezone)

| Slika | Šta se vidi |
|-------|-------------|
| `a12_camp_theme_price` | Kad su sve besplatne sezone otvorene, kartica nudi sljedeću temu: Moonlit Warren, žuta oznaka **„PREMIUM"**, „6 new flowers", dugme **„🪙 10000"** (zlatno). Ranije € cijena |
| `a13_camp_theme_confirm` | Prvi tap: tamno dugme **„√ 10000"** — kvačica se crta fontom koji nema „✓", pa izgleda kao korijen „√". Drugi tap kupuje → burst i skok na Home |
| `a14_camp_theme_short_toast` | Wallet 4200: blijedo dugme, tap → toast „Need 5800 more coins"; „Purchase cancelled" se u v1 nikad ne pojavi |

### 2.4 Ormar i Settings (bez slika)

- **Ormar:** Sir Pip se vratio među skinove (pod velom, ljubičasta oznaka „Premium"). Tap vodi u Shop · Looks na njegovu karticu; Ormar po dizajnu nikad ne pokazuje cijenu.
- **Settings:** sekcija Purchases (Restore purchases, Remove Ads status) se ne gradi. Ostatak ekrana je isti (`design_handoff_settings_fixes/`).

## 3. Indirektni uticaj na dizajn

1. **Semantika boja.** Shop v2 je uveo ljubičastu `MONEY #D4A5FF` / `MONEY_SOFT #EAD2FF` kao znak „ovo je pravi novac" (Sir Pip „Premium" oznaka, Ormar „Premium", € dugmad). U v1 tog novca nema, a ljubičasta i dalje stoji na Sir Pipu. Home Premium tab je zlatni, a Camp „PREMIUM" oznaka žuta. Za istu ideju („posebna stvar za coine") postoje tri boje.
2. **Riječ „Premium".** Pojavljuje se na Home tabu, Camp oznaci, Shop Looks i u Ormaru. Bez pravog novca znači samo „skuplje / posebno". Ne vara igrača, ali više ne opisuje razliku.
3. **Velike cijene.** Pet cifara („10000") prvi put stoje na pilulama napravljenim za „€2.99". Wallet u headeru piše „12,000" (sa zarezom), a pilule „10000" bez njega. Potvrda „✓ 🪙 10000" je šira od obične pilule.
4. **Shop tenda za 3 taba.** 3 taba širine 249 na tendi od 1080 ostavljaju po ~150 px praznog lijevo i desno. Tabovi bi mogli biti širi (npr. ~336) ili tenda drugačije raspoređena — ali kad se IAP vrati, opet trebaju 4.
5. **Ritam napretka.** Teme su sada dugoročni cilj: u normalnoj igri (prvo sve besplatne sezone) prosječan igrač kupi prvu temu oko **41. dana**, vješt oko 32., casual oko 88. Ako igrač štedi samo za temu: 9 dana (average). Dizajn može pokazati koliko je igrač blizu (npr. „4,200 / 10,000" kao kod besplatnih sezona) — to je ideja, ne pravilo.
6. **Više ★3 cvijeća.** Sa duplim ★3 sjemenom igrač češće vidi zlatno sjeme u runu i ★3 cvjetove u Campu. Casual igrač do Frost Orcharda stiže za 5,9 dana umjesto 8,3. Ništa od pickup / seed dizajna se ne mijenja, samo frekvencija.
7. **Loot Burst** ostaje u Boostersima, ali se kupuje coinima. Kad igrač otvori sve besplatne sezone, kartica nestaje (nema cilja).

## 4. Šta je agent privremeno uradio, a šta je pokvareno

| Stavka | Stanje | Gdje |
|--------|--------|------|
| Shop tenda — bijele pilule ispod 3 pomjerena taba | **Zakrpljeno**: crta se pozadina samo za tabove koji se vide (3, centrirani). Funkcionalno OK, vizuelno privremeno | `game/scripts/ui/shop_tab_bar.gd` `_draw` |
| Home „Free / Premium" | **Nije mijenjano** — imena i boje kao u Home v3. Logično zastarjelo | `game/scripts/ui/home_v3_tabs.gd`, `game/scripts/ui/season_stage.gd` |
| Coin pilula na Homeu (zlatna / blijeda / tamna potvrda) | Privremeno: metrika pozajmljena od coin dijela dugmeta „Unlock" | `game/scripts/ui/home_v3_card_content.gd` `_draw_coin_buy`, `_coin_buy_w` |
| Camp dugme teme (zlatno / blijedo / tamno „✓") | Privremeno: tamni stil `UiCamp.paid_confirm_style()`; **„✓" se crta kao „√"** (fallback font) | `game/scripts/camp/season_link_card.gd`, `game/scripts/visual/ui_camp.gd` |
| Shop potvrda | Iz Shop v2 (kozmetika); sa 5 cifara pilula raste ulijevo preko dekoracije kartice | `game/scripts/ui/shop_buy_button.gd` |
| „Need N more coins" | Pilula na Shop kartici (`STATUS_PENDING_BG #FFE8B8`), toast na Homeu i u Campu — postojeći stilovi, bez posebnog dizajna | `game/scripts/visual/ui_shop_v2.gd` `S_NEED_COINS`, `need_coins_text` |
| Format broja | Header „12,000", pilule „10000" — nedosljedno | `ui_shop_v2.gd`, `home_v3_card_content.gd`, `season_link_card.gd` |
| Ljubičasta „Premium" na Sir Pipu | Nije mijenjano | `game/scripts/ui/shop_premium_look_card.gd`, `game/scripts/visual/ui_wardrobe.gd` |

## 5. Brojevi (za mock — iz igre, ne izmišljati)

| | Vrijednost |
|---|---|
| Teme (Moonlit, Coral, Starfall; Ember skriven dok nije u igri) | 10000 C svaka, bez ★3 uslova |
| Sir Pip | 3000 C |
| Merge Hint · Loot Burst | 1500 C · 1000 C |
| Besplatne sezone (linearno) | Country Bloom (start) → Frost Orchard 2500 C + 22 ★3 Harvest Pumpkin → Lantern Meadow 4500 C + 26 ★3 Crystal Peony → Amber Canopy 6500 C + 30 ★3 Midnight Lotus |
| Potvrda | 3 s (`UiShopV2.T_CONFIRM_TIMEOUT`), drugi tap kupuje |
| Tekst kad fali | „Need %d more coins" (npr. wallet 4200, tema 10000 → „Need 5800 more coins") |
| Primjeri walleta na slikama | 4200 (premalo za temu, dosta za Sir Pipa i boostere) · 12000 (dosta za jednu temu) |
| Kad se kupuje u normalnoj igri (simulacija, medijan) | Sir Pip: average 36. dan · prva tema: average 41., skilled 32., casual 88. |

## 6. Kod — gdje šta živi

| Područje | Fajlovi |
|----------|---------|
| Prekidač i cijene | `game/scripts/monetization/monetization_config.gd` (`IAP_ENABLED`, `coin_price`, `PREMIUM_SEASON_COINS`), `game/scripts/monetization/iap_manager.gd` (`buy_with_coins`) |
| Shop | `game/scripts/ui/shop_tab_bar.gd`, `game/scripts/visual/ui_shop_v2.gd` (`visible_tabs`, `coin_state`, boje, mjere taba), `game/scripts/ui/shop_screen.gd`, `game/scripts/ui/shop_card.gd`, `game/scripts/ui/season_pack_card.gd`, `game/scripts/ui/shop_booster_card.gd`, `game/scripts/ui/shop_premium_look_card.gd`, `game/scripts/ui/shop_buy_button.gd` |
| Home | `game/scripts/ui/home_v3_tabs.gd` (Free / Premium), `game/scripts/ui/season_stage.gd` (`tab_ids`, `_buy_with_coins`, potvrda), `game/scripts/ui/home_v3_card_content.gd` (coin pilula), `game/scripts/visual/ui_home_v3.gd` (mjere, boje) |
| Camp | `game/scripts/camp/season_link_card.gd` (`_show_paid_coins`, `_buy_paid_coins`), `game/scripts/visual/ui_camp.gd` (`paid_confirm_style`, `premium_tag_style`, `S_PREMIUM_TAG`) |
| Ormar | `game/scripts/ui/wardrobe_sheet.gd`, `game/scripts/visual/ui_wardrobe.gd`, `game/scripts/ui/item_card.gd` |
| Rijetkost sjemena | `game/data/run_levels/levels.json` (`rare3_mult`), `game/scripts/run/run_balance.gd` (`BASE_RARE3`) |
| Snimke | `game/scripts/dev/ads_only_capture.gd` |
| Testovi koji čuvaju ponašanje | `game/scripts/dev/coin_offers_smoke.gd`, `game/scripts/dev/iap_off_smoke.gd` (skener teksta: nigdje „€", „$", „Restore purchases", „Purchase cancelled", „billing"), `game/test/unit/test_coin_offers.gd` |

## 7. Šta se NIJE mijenjalo

- Hub header (coin / sjeme / cvijeće čipovi, zupčanik) i footer — `design_handoff_hub_chrome_v2/`.
- Season Kit (livade, cvjetovi, boje sezona) — `design_handoff_seasons/`.
- Run, pickupi, Level Path, popupi, Settings ostatak.
- Reklame (Revive, Double), AdMob, balans runa osim ★3 sjemena.
- Ostale coin cijene (nadogradnje, izgledi, besplatne sezone).

## 8. Slike (`ads-only-ref/`)

| Fajl | Ekran · stanje |
|------|----------------|
| `a00_shop_header_broken_before_fix.jpg` | Shop · Seasons, tenda prije zakrpe (pokvareno) |
| `a01_shop_seasons_coins_short.jpg` | Shop · Seasons, 3 taba (zakrpa), teme 10000, fali coina |
| `a02_shop_seasons_need_more_coins.jpg` | isto + pilula „Need 5800 more coins" |
| `a03_shop_seasons_coins_buy.jpg` | Shop · Seasons, dovoljno coina (zlatne pilule) |
| `a04_shop_seasons_confirm.jpg` | Shop · Seasons, potvrda „✓ 🪙 10000" |
| `a05_shop_boosters_coins.jpg` | Shop · Boosters, Merge Hint 1500 / Loot Burst 1000 |
| `a06_shop_looks_sir_pip_coins.jpg` | Shop · Looks, Sir Pip 3000, ljubičasta „Premium" |
| `a07_home_free_tab.jpg` | Home · Free, Country Bloom |
| `a08_home_free_tab_locked_next.jpg` | Home · Free, Frost Orchard zaključan (2500 + ★3 22) |
| `a09_home_premium_coin_buy.jpg` | Home · Premium, Moonlit 10000 (zlatno) |
| `a10_home_premium_confirm.jpg` | Home · Premium, potvrda |
| `a11_home_premium_short_toast.jpg` | Home · Premium, fali coina + toast |
| `a12_camp_theme_price.jpg` | Camp · kartica teme, 10000 |
| `a13_camp_theme_confirm.jpg` | Camp · potvrda („√" umjesto „✓") |
| `a14_camp_theme_short_toast.jpg` | Camp · fali coina + toast |
| `a15_shop_seasons_iap_on_4_tabs.jpg` | Shop s kupovinama (poređenje): 4 taba, € |

## Povezano

- [[ads-only-cd-brief|ads-only-cd-brief]] — šta CD treba da napravi
- [[../../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · [[../../06-production/CHECKPOINT|CHECKPOINT]] · [[../../06-production/scope-i-granice|scope-i-granice]]
- [[shop-v2-cd-brief|Shop v2]] · [[home-v3-cd-brief|Home v3]] · [[camp-season-link-cd-brief|Camp season link]] · [[muncher-premium-pip-cd-brief|Sir Pip]]
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
