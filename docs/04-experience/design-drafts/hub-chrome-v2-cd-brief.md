---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, hub, header, footer, ikone, valute, claude-design, mockup]
povezano:
  - hub-header-footer-cd-brief
  - camp-v2-cd-brief
  - shop-cd-brief
  - seeds-flowers-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Hub chrome pass 2 — brief za Claude Design: footer bez teksta i niži, nove intuitivne tab ikone, zajednička ne-zelena boja headera i footera, dijamant u headeru zamijenjen cvijetom, i potpuno nove ikone coina / sjemena / cvijeta koje se koriste kroz cijelu igru (run, Camp, Shop, Home)."
---

# Hub chrome pass 2 + ikone valuta — Claude Design brief

> **Status: implementirano 2026-09-25** — paket `design_handoff_hub_chrome_v2/` prenesen u igru; odstupanja su u [[#Implementacija (2026-09-25)|§ Implementacija]] na kraju.

> Chrome je već dizajniran 2026-09-11 ([[hub-header-footer-cd-brief|hub-header-footer-cd-brief]], paket `design_handoff_hub_chrome/`, smjer B). Ovo je **druga runda**: isti okvir, ista navigacija, ali tiši footer, druga boja i — glavni dio — **nove ikone valuta koje idu kroz cijelu igru**, ne samo u header.

**Chrome** = fiksni okvir huba: **header** (gornja traka s valutama i Settings dugmetom, 143 px) + **footer** (donja navigacija s 5 tabova, 180 px). Stranica je između njih: 1080 × 1597 px.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§9) + prvi brief za kontekst | Šta se mijenja, šta ostaje, mjere i isporuka |
| **Ti** | §10 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §5, §11 | Današnje vrijednosti i mapa „CD sloj → Godot node" |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji (ne može listati foldere, zato su sve putanje u promptu ispisane do kraja).

## 1. Zašto druga runda

Chrome radi, ali:

1. **Zelena je promašena.** Traka je `#1A241E`, tamnija varijanta hub pozadine. Na Camp (`#2E4733`) i Arena (`#293D2E`) stranicama chrome i stranica su ista boja u dvije nijanse — okvir se stapa umjesto da drži ekran.
2. **Footer je pretežak.** 180 px + safe area, s imenom ispod svake ikone. To je 11 % ekrana na nešto što se ne čita — igrač poslije prvog dana zna gdje je šta i gleda samo ikonu.
3. **Ikone tabova su samo siluete.** Jedna boja (`#2D3436`), bez karaktera i bez međusobne veze osim što su sve crne. Camp je trougao, Arena je oblik koji niko neće pogoditi.
4. **Ikone valuta su najslabija tačka.** `icon_coin.svg` je crni prsten s dvije rupe, `icon_seed.svg` crna kap s prorezom, dijamant crni romb. Novčić u igri **nije ta ikona** — run crta svoj zlatni krug proceduralno (`coin_visual.gd`, 96 px), pa ikona u headeru i novčić koji skupljaš u runu nisu ista stvar.
5. **Dijamant je mrtav.** Pada 1 na ~300 sjemenki u runu i **nema gdje da se potroši** (nema nijednog `spend` poziva u kodu). Zauzima trećinu headera. Cvijeće se, s druge strane, broji na dva mjesta u Campu a u headeru ga nema.

## 2. Šta ostaje FIKSNO

| Pravilo | Vrijednost |
|---|---|
| Stranice i redoslijed | `Shop · Journal · Home · Camp · Arena`, Home u sredini i default |
| Swipe | horizontalno, uvijek sjedne na punu stranicu (0,28 s), prag 18 % ili 320 px/s, gumeni otpor na krajevima |
| Nav lock | tokom Arena sesije swipe i tabovi ne rade, pilula objašnjava zašto |
| Header visina | **143 px** (+ safe area) — ne mijenja se |
| Chipovi nisu dugmad | valuta je informacija, ne prodajno mjesto (Pillar 2) |
| Bez „+" dugmadi, pulsiranja i SALE oznaka na valutama | Pillar 2, nepregovarljivo |
| Chrome je univerzalan | ista boja i izgled na svih 5 stranica, ne mijenja se po stranici |
| Brojevi | `UiChrome.format_count()` — separator do 6 cifara (`999,999`), kompakt od 7 (`1.2M`) |
| Badge | generički (tačka/broj) na tabu; danas spojen samo na Journal („nova otkrića") |
| Safe area | chrome se produžava u notch (gore 0–100 px) i gesture bar (dolje 0–60 px), bez tamne rupe |

## 3. Šta se mijenja (zahtjevi igrača)

Tačke 1–8 su **obavezne**. Kako će izgledati poslije — tvoja odluka.

### 3.1 Footer

1. **Izbaci tekst ispod ikona.** Footer je od sada samo ikone. Danas: ikona 52 px + razmak 10 + labela 40 px unutar tile-a 196 × 152.
2. **Nove ikone tabova, intuitivne.** Home = kućica, i tako redom za ostala četiri. Igrač koji je jednom prošao kroz igru mora pogoditi svaki tab bez labele. **Pazi:** Camp i Home su oba „dom" — moraju se razlikovati na 64 px. Camp je u stvari **ostava** (torba sjemenki i ★3 cvijeća), Home je **sezonska livada** s upgradeima i Play dugmetom; Arena je merge sto. Odluči šta najbolje razlikuje i napiši razlog u README.
3. **Ikone moraju biti jedna porodica.** Ista debljina poteza, isti nivo detalja, isto zaobljenje, isti tretman boje — pet ikona koje očito dolaze iz istog seta (i koje se slažu s tri ikone valuta iz §3.3).
4. **Footer je previsok — smanji ga.** Danas 180 px (3 px rub + sadržaj 177). Cilj: **132–150 px** ukupno. Dodirna zona taba ostaje ≥ 120 px visine (to je tvrdi minimum, `pristupacnost.md`).
5. **Visina koju footer oslobodi ide stranicama, ne karticama.** Stranica je danas 1080 × 1597 (od y = 143). Kad footer padne za Δ px, stranica postaje 1597 + Δ. **Mjere kartica, chipova i dugmadi se ne mijenjaju** — svaka stranica upija Δ na jednom mjestu. Napiši u README tačno gdje, po stranici (§5.3 ima spisak s konstantama).

### 3.2 Header

6. **Boja pozadine headera i footera — nova, zajednička, ne zelena.** Ista površina, isti rub, isti jezik za obje trake; mijenja se **ton, ne vrijednost** — chrome ostaje tamna traka, jer je to jedino što ga odvaja i od svijetlih (Journal `#FFF8F0`, Shop `#B8E0F5`, Home polje `#E6F2DB`) i od tamnih stranica (Camp `#2E4733`, Arena `#293D2E`, Home karusel `#243329`). Svijetli chrome je već probao i pao u prvoj rundi. Kandidati za smjer (biraj ili predloži svoje): topla tamna zemlja / drvo (`#2A211C`, `#33261E`) · duboka šljiva-sumrak (`#2A2233`) · neutralna tamna tinta (`#262A2C`). **Odluči jednu**, pokaži je iznad svih 5 stranica, i u README navedi **2 odbijena kandidata sa swatchevima** — boja je jedan token u kodu (`UiChrome.CHROME_DEEP`), zamjena poslije košta jednu liniju.
7. **Dijamant van, cvijeće unutra.** Treći chip u headeru više ne broji dijamante nego **cvijeće** (`get_garden_crystal_total()` — ista brojka koju Camp pokazuje u Flowers tabu). Dijamanti ostaju u runu (HUD brojač) dok ne dobiju svrhu; iz huba nestaju. Redoslijed chipova: `coin · seed · flower`.
8. **Header zadržava 143 px i lanac širina** (20 · 296 · 16 · 296 · 16 · 296 · 16 · 124 = 1080). Unutrašnjost chipa smiješ mijenjati (ikona 56, razmak 12, broj 48 danas) ako nove ikone traže drugačiji ritam.

### 3.3 Ikone coina, sjemena i cvijeta (glavni dio)

Ove tri ikone **nisu chrome — one su ikone cijele igre.** Isti fajl se koristi u headeru, u Campu, u Shopu, na Home karticama sezona i u runu (§5 je puna mapa s veličinama). Zato ih radimo jednom i kako treba.

**Coin** — danas crni prsten s dvije koncentrične rupe; nema tijelo, nema materijal, ne izgleda kao nešto što bi skupljao. U runu se novčić uopšte ne crta tom ikonom nego proceduralno: krug 96 px, `#FFD56B` tijelo, tamniji rub, unutrašnje lice `#FFE8B8`, sjaj `#FFF3D0`. **Nova ikona mora biti taj novčić** — jedan asset koji je i pickup u runu i ikona cijene u UI-u. Mora se čitati kao zlatan, materijalan, „uzmi me" objekt.

> **Zamka:** coin ikona danas stoji na **zlatnom chipu** `#FFD56B` u headeru i na **zlatnoj pilulici cijene** `#FFE8B8` u Campu. Zlatna ikona na zlatnoj podlozi nestaje. Riješi to (jak tamni rub na ikoni, drugi fill chipa, disk ispod ikone — tvoj izbor) i pokaži ikonu na svim podlogama iz §5.4.

**Seed** — univerzalna ikona za **Tier 1 sjeme**, ne za konkretnu vrstu. Njome se označava Seeds tab u Campu, brojač sjemenki u headeru i u run HUD-u. Mora se čitati kao sjeme/klica koja tek kreće (T1 je „tek niknulo", T2 je cvijet, T3 kristalni cvijet). Ne smije ličiti na cvijet.

**Flower** — univerzalna ikona za **cvijeće koje se broji** (★3 cvjetovi iz Arene). Ide u header (novi treći chip) i na Flowers tab u Campu. Danas tu stoji `icon_crystal.svg` — crna peterokutna gemma koja ne liči na cvijet. Mora biti očito cvijet, ali **generičan** — ne smije biti prepoznatljiv kao jedan konkretan sezonski cvijet (per-tip art je [[seeds-flowers-cd-brief|poseban zadatak]] i crta ga igra).

**Sve tri + pet tab ikona = jedan set.** Isti stilski jezik, ista debljina outlinea, isti nivo detalja. Set mora ostati čitljiv od **32 px** (najmanja upotreba: cijena u Campu) do **96–120 px** (pickup u runu).

### 3.4 Današnje mjere (za orijentaciju)

```
        ┌ safe area (notch 0–100) ─────────────────────────────────┐
  y=0   │ HEADER 143 = sadržaj 140 + rub 3 (warm white 55 %)       │
        │ 20 │chip 296×100│16│chip 296│16│chip 296│16│ Set 124×140 │
        │    │ 🪙56 ·12· 1,250 (48) │ 🌱 34 │ 💎 2 │   tile 100    │
        │ chip radius 20, rub 2 px ink@14 %, fill: coin #FFD56B /  │
        │ seed #A8E6CF / diamond #D4A5FF                           │
  y=143 ├──────────────────────────────────────────────────────────┤
        │                                                          │
        │            STRANICA  1080 × 1597                         │
        │            (jedini dio koji se swipea)                   │
        │                                                          │
  y=1740├──────────────────────────────────────────────────────────┤
        │ rub 3 px │ ▬▬▬ ActiveIndicator 196 × 8 na y=5 (prati prst)│
        │ ┌ slot 216 × 177 ──┐ × 5                                 │
        │ │ tile 196 × 152 na y=17, radius 20                      │
        │ │   ikona 52   ↕10   "Home" 40                           │  ← 1. tekst van
        │ │   aktivan = peach #FFB88C + tamna tinta                │
        │ │   neaktivan = providan + warm white @82 %              │
        │ └──────────────────┘   badge 44 (pink #FFCCD5) gore desno│
  y=1920└──────────────────────────────────────────────────────────┘  ← 4. 180 → 132–150
        NavLockPill 64 px viri 36 px iznad footera (gold rub #E8C44A)
```

## 4. MORA / SMIJE

### 4.1 MORA

- Sve iz §3 (tačke 1–8).
- **Sve iz §2 ostaje** — redoslijed stranica, swipe, nav lock, header 143, chipovi nisu dugmad.
- **Aktivan tab mora biti prepoznatljiv na više od jednog načina** i u grayscale-u. Bez labela ovo je sada jedini signal gdje si — ne smije biti samo boja.
- **Pet tab ikona mora biti međusobno razlučivo na 64 px**, posebno Camp vs Home.
- **Tri ikone valuta rade od 32 do 120 px** i na svim podlogama iz §5.4.
- **Coin ikona zamjenjuje i proceduralni novčić u runu** — jedan asset za pickup i za UI.
- **Badge i nav lock ostaju** i moraju stati u niži footer (danas badge 44 px na uglu tile-a, lock pilula 64 px viri iznad trake).
- Dodir ≥ 120 px, tekst ≥ 38 px, brojevi ≥ 44 px (`pristupacnost.md`). EN tekst.
- Chrome se produžava u safe area bez rupe.
- **Δ visine footera ide stranicama; mjere kartica se ne mijenjaju.**

### 4.2 SMIJEŠ (sloboda)

- Promijeniti visinu, oblik i raspored tile-a u footeru, poziciju i oblik indikatora, mjesto badgea.
- Promijeniti fill chipova u headeru (danas gold / mint / lavender) ako nove ikone traže drugu podlogu — ili ih potpuno izbaciti u korist ikone + broja na traci.
- Promijeniti unutrašnjost chipa (veličina ikone, razmak, veličina broja) dok je header 143 px i lanac širina isti.
- Dati ikonama boju umjesto jedne tinte. **Ako su ikone u boji, reci to jasno** — kod ih danas tinta iz `modulate`, što radi samo na jednobojnim ikonama, i svaka tab ikona danas ima dvije varijante (`tab_home.svg` tamna za peach tile, `tab_home_light.svg` svijetla za traku). Za svaku ikonu napiši: jednobojna (tintabilna) ili u boji (fiksna), i ako je u boji — radi li jedan fajl na obje podloge ili trebaju dvije varijante.
- Dodati blagu animaciju (pop broja kad se promijeni, bounce ikone aktivnog taba) — tween, 0,08–0,42 s.
- Predložiti drugi redoslijed chipova uz obrazloženje.

## 5. Gdje se ikone koriste (obavezno pročitati prije crtanja)

Ovo nije chrome-only zadatak. Ikone iz §3.3 se već danas učitavaju iz `game/assets/ui/chrome/` na 20+ mjesta.

### 5.1 Coin — `icon_coin.svg`

| Mjesto | Fajl | Veličina |
|---|---|---|
| Hub header, chip valute | `scripts/meta/meta_hub_controller.gd:98` | 56 |
| Run HUD, brojač coina | `scripts/run/run_controller.gd:129` | 48 |
| **Run, pickup koji skupljaš** | `scripts/run/coin_visual.gd` (danas proceduralno) | **96** |
| Camp, cijena na kartici predmeta | `scripts/camp/camp_stash_chip.gd:233` | 32 |
| Camp, novčić koji leti u header pri prodaji | `scripts/camp/camp_trade_bar.gd:50` | 44 |
| Camp, kartica sljedeće sezone | `scripts/camp/season_link_card.gd:34` | 48 |
| Home, zaključana kartica sezone (disk u sredini) | `scripts/ui/home_season_card.gd:378` | 84 disk |
| Home, red „Coins" na kartici sezone | `scripts/ui/home_season_card.gd:572` | 44 u disku 64 |
| Shop, cijena kozmetike | `scripts/ui/shop_cosmetic_card.gd:189` | 48 |
| Shop, sadržaj starter packa | `scripts/ui/shop_screen.gd:292` | 48 |

### 5.2 Seed — `icon_seed.svg` · Flower — novi `icon_flower.svg`

| Mjesto | Fajl | Veličina |
|---|---|---|
| Hub header, seed chip | `meta_hub_controller.gd:99` | 56 |
| **Hub header, flower chip (novo)** | `meta_hub_controller.gd:100` (danas dijamant) | 56 |
| Run HUD, brojač sjemenki | `run_controller.gd:130` | 48 |
| Camp, Seeds / Flowers tab | `scripts/camp/camp_stash_tab.gd:100` | 44 (u okviru 76) |
| Camp, prazno stanje oba taba | `scripts/camp/camp_controller.gd:281` | 56 (u okviru 120) |
| Camp, prazan slot u Trade baru | `scripts/camp/camp_stash_chip.gd:272` | — |
| Home, prazna korpa sjemenki | `scripts/ui/home_basket_visual.gd:25` (`icon_seed_light`) | ~44 % slota |
| Shop, Loot Burst booster fallback | `scripts/ui/shop_booster_row.gd:183` | 48 |

Flower danas nema svoju ikonu — sva ta mjesta koriste `assets/ui/arena/icon_crystal.svg`.

### 5.3 Gdje svaka stranica upija Δ (footer niži za Δ px)

| Stranica | Konstanta danas | Kako upija Δ |
|---|---|---|
| Camp | `ui_camp.gd` `PAGE_H 1597`, `SECTION_H 1253`, `SECTION_H_NO_SEASON 1549` | sekcija raste za Δ, kartica ostaje 489 × 176 |
| Shop | `ui_shop.gd` `PAGE_H 1597` | duži skrol prozor, kartice iste |
| Journal | `ui_journal.gd` `PAGE_H 1597` | duži skrol prozor, red ostaje 200 |
| Arena | `ui_arena.gd` (polje = 1597 − 44) | polje raste za Δ |
| Home — polje sezone | `ui_home_field.gd` `PAGE (1080, 1597)`, `PAGE_Y 143` | livada je flex blok, upija sama |
| **Home — biranje sezone** | `ui_stage.gd` `STAGE (1080, 1597)`, `CARD (24, 24, 1032, 1100)`, `DOCK (0, 1148, 1080, 222)`, `PLAY_ROW (24, 1394, 1032, 180)` | **apsolutni rasporedi — reci tačno gdje ide Δ** (kartica viša ili razmaci veći) |

### 5.4 Podloge na kojima ikone moraju raditi

Chrome traka (nova boja) · peach aktivni tile `#FFB88C` · zlatni chip `#FFD56B` · mint chip `#A8E6CF` · zlatna pilula cijene `#FFE8B8` · krem disk `#FFF8F0` · krem panel Campa `#FFF8F0` · tamna livada Camp `#2E4733` / Arena `#293D2E` / Home karusel `#243329` · nebo runa `#B8E0F5`.

## 6. Paleta i tokeni

Postoji u `game/scripts/visual/ui_palette.gd` i `ui_chrome.gd`. Koristi te vrijednosti; nove nijanse samo kao svjetliju/tamniju varijantu postojećih i jasno označene.

mint `#A8E6CF` · lavanda `#D4A5FF` · peach `#FFB88C` (rub `#E8A374`) · coin gold `#FFD56B` · UI gold `#E8C44A` · warm white `#FFF8F0` · soft sky `#B8E0F5` · pastel yellow `#FFEAA7` · pastel pink `#FFCCD5` · price bg `#FFE8B8` · UI tekst `#4A4A4A` · outline `#2D3436` · tamne livade `#1F2B24` / `#243329` / `#293D2E` / `#2E4733`.

Oblik: radius 20 (chip, tile, traka), rub 2 px ink @ 10–14 %, jedna meka sjena. Font: nema custom fonta, kod simulira težinu (`FontVariation.variation_embolden` 0,25 / 0,5); Nunito je uveden samo na Home biranju sezone.

## 7. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- Artboard **1080 × 1920**, sve mjere u px te baze — prenos je 1:1.
- Paneli = ravna boja (+ alpha), radius po uglu, rub po strani, **jedna** sjena. Bez backdrop blura, bez gradijenata na panelima, bez inner shadowa i blend modova.
- Animacije = tweenovi (scale, pozicija, alpha, boja).
- **Ikone: SVG, viewBox `0 0 128 128`.** Ravni fillovi; najviše jedan jednostavan linearni gradijent po ikoni. **Bez** filtera, blura, maski, `clipPath`, `<text>` elemenata i ugrađenih bitmapa — Godotov SVG rasterizer ih ne renderuje pouzdano. Svaka ikona je samostalan fajl bez vanjskih referenci.
- Ikona koju kod tinta mora biti **jednobojna** (`#2D3436`); ikona u boji se ne smije tintati.
- Safe area: notch gore 0–100 px, gesture bar dolje 0–60 px — pokaži izgled s njim i bez njega.

## 8. Isporuka

### 8.1 Šta mora biti nacrtano

1. **Chrome iznad svih 5 stranica** — Shop, Journal, Home (karusel, tamno), Home (otvoreno polje, svijetlo), Camp, Arena. Sadržaj stranica ne dizajniraj: puna pozadinska boja + par sivih placeholder blokova. Svaki s tačnim aktivnim tabom.
2. **Spec header** — anatomija s mjerama, tri chipa (coin, seed, flower), Settings, brojevi `1,250` i `999,999`.
3. **Spec footer** — tab neaktivan / aktivan / pritisnut / s badgeom / zaključan, indikator, nav lock pilula, i **vertikalni budžet nove visine** (šta je koliko visoko, koliko ostaje dodiru).
4. **List ikona** — svih 8 (coin, seed, flower + 5 tabova) u veličinama 32 / 44 / 56 / 96 px, na svim podlogama iz §5.4, u tamnoj i svijetloj varijanti gdje treba.
5. **Coin u kontekstu runa** — 96 px iznad neba `#B8E0F5`, pored sjemenke 120 px koju igra crta proceduralno, da se vidi da pripadaju istom svijetu.
6. **Safe area ekran** — notch +90 gore, gesture bar +50 dolje.
7. **Prije / poslije footera** — stara traka 180 s labelama i nova, jedna ispod druge, s Δ ispisanim.

### 8.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom. Ako zip ne može, zalijepi sadržaj JSON-a, `.gd`, README-a i svih SVG-ova u chat.

```
design_handoff_hub_chrome_v2/
  README.md                    šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica
                               svaka) · § Boja chromea (izabrana + 2 odbijena
                               kandidata sa swatchevima) · § Ikone (tabela: fajl,
                               jednobojna ili u boji, varijante, gdje se koristi)
                               · § Δ po stranici · § Šta se briše · § Ideje van zadatka
  design/
    HubChromeScreen.dc.html    prop `page` = shop | journal | home_carousel |
                               home_field | camp | arena
                               prop `state` = normal | locked | badge | safe_area
    Hub Chrome Specs.dc.html   anatomija headera i footera, sva stanja taba,
                               vertikalni budžet, tabela animacija, prije/poslije
    Icons.dc.html              svih 8 ikona × veličine × podloge
    support.js · icons/
  assets/
    icons/                     SVG fajlovi spremni za uvoz u igru:
                               icon_coin.svg · icon_seed.svg · icon_flower.svg
                               tab_shop.svg · tab_journal.svg · tab_home.svg
                               tab_camp.svg · tab_arena.svg
                               (+ *_light.svg varijante gdje su potrebne)
  godot/
    hub_chrome_v2_export.json  ekran kao podaci, ista šema kao
                               design_handoff_shop/godot/shop_export.json:
                               meta · tokens · layout · components · scenes ·
                               animations · strings_en · assets · godot_map ·
                               smoke_tests · decisions
    ui_chrome.gd               samo izmijenjene/nove konstante i StyleBoxFlat
                               fabrike, isti nazivi kao u postojećem ui_chrome.gd
    hub_tree.txt               node tree s veličinama
    README.md                  red prenosa u koracima + šta se briše
```

**Imena slojeva** (za mapiranje na Godot, §11): `Header`, `CoinChip`, `SeedChip`, `FlowerChip`, `SettingsButton`, `Footer`, `Tab_Shop`, `Tab_Journal`, `Tab_Home`, `Tab_Camp`, `Tab_Arena`, `TabIcon`, `TabBadge`, `ActiveIndicator`, `NavLockPill`.

## 9. Ne tražimo

- Sadržaj stranica, njihove naslove i kartice (Shop, Journal, Home, Camp, Arena su gotovi ekrani).
- Settings ekran (D0-P, poseban zadatak) — dugme ostaje, ponašanje je toast.
- Run HUD raspored i loot ekran — samo ikone koje run koristi.
- Art pojedinačnih vrsta sjemena i cvijeća (48 vrsta, [[seeds-flowers-cd-brief|poseban brief]]) — ovdje pravimo samo **generičku** T1 seed i generičku flower ikonu.
- Nove elemente u headeru (avatar, level, energija, „+" kupovina).
- Više varijanti za biranje — jedan dizajn. Jedini izuzetak: dva odbijena kandidata za boju chromea, kao swatch u README-u.

## 10. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim drugu rundu redizajna "chrome"-a mobilne igre: fiksni HEADER i FOOTER
meta-huba, plus KOMPLETAN REDIZAJN IKONA VALUTA koje se koriste kroz cijelu
igru.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Chrome si već radio (design_handoff_hub_chrome/, smjer B). Sada ga mijenjamo.

Tvoja referenca su dva fajla u repou (master), pročitaj oba po ovim tačnim
putanjama:
  docs/04-experience/design-drafts/hub-chrome-v2-cd-brief.md   (ovaj zadatak)
  docs/04-experience/design-drafts/hub-header-footer-cd-brief.md  (prva runda)
Ako se ovaj prompt i fajl razlikuju, važi fajl. §11 je za kasniji prenos i
možeš ga preskočiti.

Korisno za kontekst (isti svijet, drži se istog jezika):
  design_handoff_hub_chrome/HubScreen.dc.html     (chrome, prva runda)
  design_handoff_camp_v2/design/CampScreen.dc.html (najnoviji ekran)
  design_handoff_shop/design/ShopScreen.dc.html
  game/scripts/visual/ui_chrome.gd                 (tokeni chromea u igri)
  game/scripts/visual/ui_palette.gd                (paleta igre)
  game/scripts/run/coin_visual.gd                  (kako run danas crta novčić)

JEDAN DIZAJN: ne pravi smjerove ni varijante za biranje. Kad imaš dilemu,
odluči sam i napiši razlog u jednoj rečenici u README § Odlučeno. Ne čekaj
moju potvrdu. Jedini izuzetak su dva odbijena kandidata za boju chromea, kao
swatch u README-u.

ŠTA SE MORA PROMIJENITI (mjere i detalji u §3):

FOOTER
1. Izbaci tekst ispod ikona — footer je od sada samo ikone (danas ikona 52 +
   razmak 10 + labela 40 unutar tile-a 196 x 152).
2. Nove ikone tabova, intuitivne: Home = kućica i tako redom za ostala
   četiri. Igrač koji je jednom prošao kroz igru mora pogoditi tab bez
   labele. Camp i Home su oba "dom" — moraju se razlikovati na 64 px: Camp
   je ostava (torba sjemenki i cvijeća), Home je sezonska livada s
   upgradeima i Play dugmetom, Arena je merge sto.
3. Pet ikona mora biti jedna porodica — ista debljina poteza, isti nivo
   detalja, isti tretman boje — i mora se slagati s tri ikone valuta iz
   tačke 9.
4. Footer je previsok: danas 180 px. Cilj 132–150 px ukupno. Dodirna zona
   taba ostaje >= 120 px.
5. Visina koju footer oslobodi (Δ) ide stranicama, NE karticama. Stranica je
   danas 1080 x 1597 od y=143; postaje 1597 + Δ. Mjere kartica, chipova i
   dugmadi ostaju iste. U README napiši tačno gdje svaka stranica upija Δ —
   spisak stranica s konstantama je u §5.3 brifa. Home "biranje sezone" ima
   apsolutni raspored, za njega obavezno reci gdje ide Δ.

HEADER
6. Nova boja pozadine headera i footera, zajednička za obje trake — i NE
   zelena. Danas je #1A241E, pa se na Camp (#2E4733) i Arena (#293D2E)
   stranicama chrome stapa sa stranicom. Mijenja se ton, ne vrijednost:
   chrome ostaje tamna traka jer je to jedino što ga odvaja i od svijetlih
   (Journal #FFF8F0, Shop #B8E0F5, Home polje #E6F2DB) i od tamnih stranica.
   Svijetli chrome je već pao u prvoj rundi. Kandidati: topla tamna zemlja
   (#2A211C, #33261E), duboka šljiva (#2A2233), neutralna tinta (#262A2C) —
   ili tvoj prijedlog. Odluči jednu, pokaži je iznad svih 5 stranica, i u
   README stavi 2 odbijena kandidata sa swatchevima.
7. Treći chip više ne broji dijamante nego CVIJEĆE (ista brojka koju Camp
   pokazuje u Flowers tabu). Dijamanti ostaju samo u run HUD-u. Redoslijed:
   coin, seed, flower.
8. Header zadržava visinu 143 px i lanac širina
   (20 + 296 + 16 + 296 + 16 + 296 + 16 + 124 = 1080). Unutrašnjost chipa
   smiješ mijenjati (danas ikona 56, razmak 12, broj 48).

IKONE — GLAVNI DIO
9. Potpuno nove ikone za COIN, SEED i FLOWER. To nisu chrome ikone — isti
   fajl se koristi u headeru, u Campu, u Shopu, na Home karticama sezona i u
   runu. Puna mapa mjesta i veličina je u §5 brifa, pročitaj je prije crtanja.
   - COIN: danas crni prsten s dvije rupe — bezdušna silueta. U runu se
     novčić uopšte ne crta tom ikonom nego proceduralno (krug 96 px, tijelo
     #FFD56B, tamniji rub, lice #FFE8B8, sjaj #FFF3D0). Nova ikona MORA biti
     taj novčić: jedan asset koji je i pickup u runu i ikona cijene u UI-u.
     Mora izgledati zlatno, materijalno, "uzmi me".
     ZAMKA: coin ikona stoji na zlatnom chipu #FFD56B u headeru i na zlatnoj
     pilulici cijene #FFE8B8 u Campu — zlatno na zlatnom nestaje. Riješi to
     (jak tamni rub, drugi fill chipa, disk ispod ikone — tvoj izbor).
   - SEED: univerzalna ikona za Tier 1 sjeme, ne za konkretnu vrstu. Ide na
     Seeds tab u Campu, u header i u run HUD. Čita se kao sjeme/klica koja
     tek kreće. Ne smije ličiti na cvijet.
   - FLOWER: univerzalna ikona za cvijeće koje se broji (★3 cvjetovi iz
     Arene). Ide u header (novi treći chip) i na Flowers tab u Campu. Danas
     tu stoji crna peterokutna gemma koja ne liči na cvijet. Mora biti očito
     cvijet, ali generičan — ne smije biti prepoznatljiv kao jedan konkretan
     sezonski cvijet (per-tip art je poseban zadatak, crta ga igra).
   Sve tri + pet tab ikona = JEDAN SET, isti stilski jezik. Set mora ostati
   čitljiv od 32 px (cijena u Campu) do 96–120 px (pickup u runu), i na svim
   podlogama iz §5.4 brifa.

MORA OSTATI:
- Redoslijed stranica Shop · Journal · Home · Camp · Arena, Home u sredini;
  swipe ponašanje; nav lock tokom Arena sesije s pilulom koja objašnjava.
- Header 143 px. Chipovi nisu dugmad. Bez "+" dugmadi, pulsiranja i SALE
  oznaka na valutama — igra je striktno Fair F2P.
- Aktivan tab prepoznatljiv na više od jednog načina i u grayscale-u (bez
  labela je to sada jedini signal gdje si).
- Badge na tabu (danas 44 px, pink #FFCCD5, ugao tile-a) i nav lock pilula
  (64 px, viri iznad trake) moraju stati u niži footer.
- Chrome je univerzalan: ista boja i izgled iznad svih 5 stranica, produžava
  se u safe area (notch 0–100 gore, gesture bar 0–60 dolje) bez tamne rupe.
- Dodir >= 120 px, tekst >= 38 px, brojevi >= 44 px. EN tekst.
- Brojevi: separator do 6 cifara (999,999), kompakt od 7 (1.2M).

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920, sve u
px te baze (prenos 1:1). Paneli = ravna boja + alpha, radius, rub, JEDNA
sjena. Animacije = tween. Bez blura, gradijenata na panelima, inner shadowa i
blend modova.
IKONE: SVG, viewBox 0 0 128 128, ravni fillovi, najviše jedan jednostavan
linearni gradijent po ikoni. BEZ filtera, blura, maski, clipPath, <text>
elemenata i ugrađenih bitmapa — Godotov SVG rasterizer ih ne renderuje
pouzdano. Za SVAKU ikonu napiši je li jednobojna (kod je smije tintati) ili u
boji (fiksna), i treba li dvije varijante (danas svaka tab ikona ima tamnu za
peach tile i svijetlu za traku).

ISPORUKA (§8): sedam stavki iz §8.1 i paket TAČNO po strukturi iz §8.2 —
design_handoff_hub_chrome_v2/ s README.md, design/ (HubChromeScreen.dc.html,
Hub Chrome Specs.dc.html, Icons.dc.html, support.js, icons/), assets/icons/
sa SVIH 8 SVG fajlova spremnih za uvoz, i godot/ (hub_chrome_v2_export.json u
istoj šemi kao shop_export.json, ui_chrome.gd, hub_tree.txt, README.md).
Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: Header, CoinChip, SeedChip, FlowerChip, SettingsButton,
Footer, Tab_Shop, Tab_Journal, Tab_Home, Tab_Camp, Tab_Arena, TabIcon,
TabBadge, ActiveIndicator, NavLockPill.

NE RADI: sadržaj stranica i njihove kartice, Settings ekran, run HUD
raspored, loot ekran, art pojedinačnih vrsta sjemena i cvijeća (48 vrsta su
poseban brief — ovdje su samo generička seed i flower ikona), nove elemente u
headeru. Ideje van zadatka navedi odvojeno na kraju README-a.
```

## 11. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot čvor / fajl |
|---|---|
| boja i mjere chromea | `scripts/visual/ui_chrome.gd` — `CHROME_DEEP`, `chrome_style()`, `FOOTER_CONTENT_H`, `TAB_TILE_*`, `TAB_ICON_*`, `TAB_LABEL_FONT_SIZE` (briše se), `INDICATOR_*`, `BADGE_*`, `LOCK_*` |
| `Header`, chipovi | `scenes/meta/meta_hub.tscn` → `RootVBox/TopBar/Panel/HBox/*Chip` + `meta_hub_controller.gd` `_setup_chip()` / `refresh_top_bar()` |
| `FlowerChip` | isti čvor kao `DiamondChip` (preimenovati) + `refresh_top_bar()` → `GameState.get_garden_crystal_total()` umjesto `get_diamonds()` |
| `Footer`, visina | `RootVBox/PageIndicator.custom_minimum_size` (180) + `NavPanel/Content.custom_minimum_size` (177) |
| `Tab_*`, `TabIcon`, `TabBadge` | `scripts/ui/hub_tab.gd` — `_label` i `TAB_ICON_GAP` odlaze, `_layout()` i `setup()` se mijenjaju |
| `ActiveIndicator`, `NavLockPill` | `NavPanel/Content/ActiveIndicator` i `.../NavLockPill` + `meta_hub_controller.gd` |
| ikone | `game/assets/ui/chrome/*.svg` → `scripts/godot-import.ps1`, commitati `.import` (CLAUDE.md § Novi asset) |
| coin u runu | `scripts/run/coin_visual.gd` (proceduralni `_draw`) → `Sprite2D.texture` + `PickupAssets.run_scale()`; `UiRun.COIN_FILL/EDGE/INNER/GLINT` postaju nepotrebni |
| stari coin/seed PNG | `assets/pickups/coin.png`, `seed.png` + `PickupAssets.get_coin_texture()` / `get_seed_texture()` — fallback koji poslije nove ikone može otpasti |
| dijamant | `PickupAssets.get_diamond_texture()` i `icon_diamond.svg` ostaju za run HUD; iz huba odlaze |
| Δ visine stranice | `ui_camp.gd` (`PAGE_H`, `CONTENT_H`, `SECTION_H`, `SECTION_H_NO_SEASON`), `ui_shop.gd` `PAGE_H`, `ui_journal.gd` `PAGE_H`, `ui_stage.gd` `STAGE`/`CARD`/`DOCK`/`PLAY_ROW`, `ui_home_field.gd` `PAGE`, `ui_arena.gd`, `camp/arena_meadow_bg.gd` `REF_H`, `ui/home_stage_hint.gd` |
| smoke testovi koje Δ ruši | `hub_chrome_smoke`, `camp_layout_smoke`, `camp_section_fixed_smoke`, `arena_redesign_smoke`, `season_home_smoke`, `meta_hub_flow_smoke` |

**Gotovo kad:**

- [ ] Footer bez teksta, ≤ 150 px, dodir ≥ 120 px, aktivan tab jasan i u grayscale-u
- [ ] Nova boja chromea iznad svih 5 stranica (screenshot Camp i Journal — najgori slučajevi)
- [ ] Header 143 px, treći chip broji cvijeće
- [ ] Coin / seed / flower ikona ista u headeru, Campu, Shopu, na Home kartici i u runu
- [ ] Novčić u runu je ikona, ne proceduralni krug
- [ ] Δ raspoređen: nijedna kartica nije promijenila mjeru, nijedna stranica nema novu rupu
- [ ] Suite prolazi (posebno smokeovi iz tablice gore) + GUT

## Implementacija (2026-09-25)

Paket: `design_handoff_hub_chrome_v2/` (README § Odlučeno, 26 odluka). Preneseno 1:1 osim odstupanja niže.

| Fajl | Uloga |
|------|-------|
| `game/assets/ui/chrome/*.svg` | 13 novih ikona (+ `icon_flower.svg`); `icon_seed_light.svg` obrisan, ostale prepisane |
| `game/scripts/visual/ui_chrome.gd` | `CHROME_DEEP #2A2233`, `CHIP_WELL`, `NUMBER_INK`, `FOOTER_H 144` / `FOOTER_CONTENT_H 141` / `FOOTER_DELTA 36` / `PAGE_H 1633`, tab tile 184 × 108, ikona 64 / 72, indikator 72 × 8; `chip_style()` bez argumenta, `tab_ink()` / `TAB_ICON_GAP` / `TAB_LABEL_FONT_SIZE` obrisani |
| `game/scripts/ui/hub_tab.gd` | Bez labele: slot 216 × 141 je hit-zona, tile 184 × 108 na (16, 20), ikona u boji 72 kad je aktivan (podignuta 2 px) i krem linija 64 kad nije, ime u `tooltip_text` |
| `game/scenes/meta/meta_hub.tscn` + `meta_hub_controller.gd` | `DiamondChip → FlowerChip` (ikona `icon_flower`, broj = `get_garden_crystal_total()`), chip ikone 64 i razmak 10, footer 144 / 141, lock ikona 34 |
| `game/scripts/ui/ui_text_layout.gd` | `header_chip_count()` boji broj u `NUMBER_INK` (krem na tamnom wellu) |
| `game/scripts/run/coin_visual.gd` | Novčić u runu je `icon_coin.svg` na 96 px; `UiRun.COIN_INNER` / `COIN_GLINT` obrisani |
| `ui_camp.gd` · `ui_shop.gd` · `ui_journal.gd` · `ui_stage.gd` · `ui_home_field.gd` · `ui_arena.gd` · `arena_meadow_bg.gd` | Stranica 1597 → **1633**; Camp sekcija 1289 / 1585; Home kartica 1136, dock i Play red 36 px niže |
| `camp_scene.tscn` · `season_stage.tscn` | `StashSection` 1289; `CardClip` 1136; `SeasonBrowser` 36 px niže |
| `camp_controller.gd` · `camp_stash_chip.gd` · `camp_stash_tab.gd` · `home_basket_visual.gd` | `arena/icon_crystal` → `chrome/icon_flower`, `icon_seed_light` → `icon_seed` |
| `game/scripts/dev/hub_chrome_icons_smoke.gd` · `run_coin_texture_smoke.gd` | Nova dva smokea iz `godot/hub_chrome_v2_export.json` |

**Odstupanja od handoffa (svjesna):**

1. **Novčić u runu se crta ručno** (`draw_texture_rect`), ne preko `Sprite2D.texture` + `scale` kako paket kaže. Sprite2D svoju teksturu crta **prije** skriptinog `_draw()`, pa bi `_draw_shadow()` završio **preko** novčića. Ručno crtanje čuva redoslijed; `texture` ostaje `null`, kao kod sjemenke.
2. **`UiRun.COIN_FILL` i `COIN_EDGE` ostaju** — paket ih briše sva četiri, ali `run_token.gd` (tačka na tokenu) i `run_pickup_feed.gd` („+1" koji leti) i dalje ih koriste. Obrisani su samo `COIN_INNER` i `COIN_GLINT`.
3. **`assets/pickups/coin.png` i `seed.png` ostaju** — paket ih nudi za brisanje „nakon provjere". Oni su fallback u `PickupAssets` ako import ne prođe (`greske-katalog` #6); 32 KB je jeftinija zaštita nego nevidljiva ikona.
4. **`arena/icon_crystal.svg` ostaje u repou bez korisnika** — poslije zamjene cvijetom ništa ga ne zove. Fajl stoji jer je kandidat za Arena ★3 kristal (README § Ideje van zadatka).
5. **Dock na Home biranju sezone pomjeren u sceni**, ne kroz `UiStage.DOCK` — `SeasonBrowser` je apsolutno pozicioniran u `season_stage.tscn` (offset 1124 → 1160). Play red je u VBoxu i sam je pao 36 px, kako paket i predviđa.
6. **`_slot_label_h()` čita `UiStage.CARD.size.y`** umjesto hardkodirane 1100 — paket to mjesto ne spominje, a ostalo bi zastarjelo pri sljedećoj promjeni visine.
7. **`hub_chrome_icons_smoke` gleda samo chrome podstablo** — stranice huba nose Kenney ikone koje se legitimno tintaju, pa bi provjera „nijedna ikona nije RGB-tintana" na cijelom hubu lažno padala.

## Odluke

| Datum | Odluka |
|---|---|
| 2026-09-24 | Footer je **samo ikone** — imena tabova odlaze. Poništava odluku iz prve runde („imena svih 5 sekcija uvijek vidljiva"). Cijena: prvi dan je teži dok igrač ne poveže ikonu s ekranom; zato je zahtjev na ikonama („pogodivo bez labele") i na aktivnom stanju („jasno i u grayscale-u") pooštren. |
| 2026-09-24 | Treći chip headera broji **cvijeće**, ne dijamante. Dijamant nema potrošnju u igri i zauzimao je trećinu headera; ostaje vidljiv u run HUD-u. Ako dijamant kasnije dobije svrhu, vraća se — ili u header ili u Shop. |
| 2026-09-24 | Chrome ostaje **tamna traka**, mijenja se samo ton. Svijetli chrome je pao u prvoj rundi jer nestaje iznad Journala i Shopa. |
| 2026-09-24 | Coin / seed / flower su **ikone cijele igre**, ne chrome asseti — jedan fajl po valuti, od 32 px (cijena u Campu) do 96 px (pickup u runu). |

## Otvorena pitanja (nakon CD-a)

- [ ] Tačna boja chromea — CD bira jednu, README nosi 2 odbijena kandidata za jeftinu zamjenu
- [ ] Nova visina footera i Δ po stranici (posebno Home biranje sezone, apsolutni raspored)
- [ ] Jesu li nove ikone jednobojne (tintabilne) ili u boji, i treba li i dalje `_light` varijanta po tabu
- [ ] Ostaju li `assets/pickups/coin.png` i `seed.png` ili se brišu kad ikone preuzmu run
- [ ] Gdje dijamant dobija svoje mjesto kad dobije potrošnju

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — prva runda, današnje stanje i odluke
- [[camp-v2-cd-brief|camp-v2-cd-brief]] — isti format, zadnji uspješan CD → Godot prenos
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — art za 48 vrsta cvijeća (ovaj brief pravi samo generičku ikonu)
- [[../art-direction|art-direction]] — paleta, stil
- [[../pristupacnost|pristupačnost]] — dodir 44 pt ≈ 120 px, font minimumi
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci
