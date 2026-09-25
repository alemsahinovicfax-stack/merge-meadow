---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, camp, claude-design, mockup, cleanup]
povezano:
  - camp-cd-brief
  - hub-header-footer-cd-brief
  - merge-arena-cd-brief
  - shop-cd-brief
  - ekonomija-brojevi
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Camp pass 2 — brief za Claude Design: izbaci suvišan tekst (Next free season, Details, podnaslovi tabova, Merge prečica, 1 coin each, hold 10/s), smanji Unlock i Trade dugme, prikuj sekciju uz karticu sezone (bez rupe u sredini) i povećaj art sjemena/cvijeta unutar istih kartica."
---

# Camp pass 2 — Claude Design brief (čišćenje i raspored)

> Camp je već redizajniran 2026-09-16 ([[camp-cd-brief|camp-cd-brief]], paket `design_handoff_camp/`). Ovo je **druga runda**: isti ekran, ista pravila, manje teksta i čvršći raspored. Sve što ovdje nije spomenuto ostaje kako je u prvom paketu.

**Camp** je igračeva ostava: vidi šta je skupio (sjemenke iz runova, ★3 cvijeće iz Arene), pretvara višak u coine i prati koliko mu fali do sljedeće besplatne sezone. Merge je u Areni, upgradei su na Home.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§7) + prvi brief za kontekst | Šta se mijenja, šta ostaje fiksno, mjere i isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §4, §10 | Današnje vrijednosti i mapa "CD sloj → Godot node" |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto druga runda

Ekran radi, ali priča previše. Skoro svaki element ima naslov, podnaslov i objašnjenje, pa igrač čita umjesto da gleda. Uz to raspored "pluta": sekcija sa sjemenkama je prikovana za dno stranice, a između nje i kartice sezone ostaje rupa koja mijenja veličinu (375 px kad je torba prazna, 215 px kad je puna). Igrač treba da prati intuiciju, ne uputstvo.

## 2. Pravila koja ostaju FIKSNA (ekonomija i tok)

Brojevi se **ne diraju** — mijenja se samo kako izgledaju.

| Pravilo | Vrijednost |
|---|---|
| Trade tap | prodaje **1 komad** |
| Trade držanje | **10 komada / s** dok držiš |
| Cijena sjemenke | ★1 = 1 · ★2 = 2 · ★3 = 4 coina po komadu |
| Cijena cvijeta (★3 iz Arene) | ★1 = 5 · ★2 = 10 · ★3 = 20 coina po komadu |
| Rezervisano cvijeće | cvijet koji traži sljedeća besplatna sezona nosi badge „Kept · N / M"; držanje **stane** na granici, dalje ide samo tap po tap uz upozorenje |
| Otključavanje sezone | **500 coina + 20 ★3 cvjetova** prethodne sezone, troši se odmah |
| Poslije otključavanja | skok na Home s fokusom na tu sezonu |
| Tap na karticu sezone | vodi na Home (ništa ne troši) |
| Sadržaj | do 8 tipova sjemenki i do 6 tipova cvijeća; katalog raste (7 sezona × 6 cvjetova) — lista mora moći skrolati |

Camp ne prodaje ništa za pravi novac i ne troši dijamante.

## 3. Šta se mijenja (zahtjevi igrača)

Tačke 1–10 su **obavezne**. Kako će izgledati poslije — tvoja odluka.

### 3.1 Kartica sljedeće sezone (gore)

1. **Izbaci „Next free season"** (mali tekst iznad imena). Ime sezone i dvije trake napretka dovoljno govore.
2. **Izbaci pločicu „Details ↗"**. Tap bilo gdje na kartici i dalje vodi na Home — to je već tako i mora ostati; samo se ne najavljuje tekstom.
3. **Unlock dugme: ostaje samo riječ „Unlock"**, bez podnaslova u sva tri stanja:
   - nedostaje: `Unlock` + „needs 240 more coins and 20 more flowers" — to već piše u trakama iznad,
   - spremno: `Unlock Lantern Meadow` + „spends 500 coins and 20 flowers",
   - trenutak otključavanja: `Lantern Meadow unlocked` + „spent 500 coins and 20 flowers" — ovdje smiješ ostaviti **jednu riječ** potvrde.
4. **Unlock dugme je bespotrebno ogromno** (danas 988 × 132 px, puna širina kartice). Smanji ga — ne mora nositi cijelu širinu.

### 3.2 Sekcija Seeds / Flowers (dolje)

5. **Sekcija mora uvijek stajati prikovana uz karticu sezone**, odmah ispod nje, i **ne smije mijenjati visinu** po broju elemenata. Danas je prikovana za dno stranice pa rupa u sredini raste i pada (375 px prazna torba → 215 px šest tipova). Prijedlog koji rješava problem: sekcija ima fiksnu visinu = sve što ostane ispod kartice (≈ 1107 px uz razmak 20 px), tabovi su na vrhu, Trade bar na dnu sekcije, a lista u sredini skrola kad ima više redova. Ako imaš bolje rješenje, uzmi ga — samo ne smije ostati prazan prostor u sredini stranice.
6. **Izbaci „Merge" prečicu** iz reda s tabovima (danas 190 px desno). Taj red je samo za biranje **Seeds | Flowers**. Arena je ionako tab u footeru.
7. **Izbaci podnaslove tabova:** „Arena fuel" ispod „Seeds" i „reward" ispod „Flowers". Ostaju ime + broj tipova.
8. **Povećaj crtež sjemenke/cvijeta u karticama, ali ne povećavaj kartice.** Danas: kartica 489 × 176, okvir arta 104 px, sam crtež 66 px (sjeme) / 70 px (cvijet) — premalo za toliku karticu. Prostor se oslobađa jer tekst ide van (tačke 9–10).
9. **Trade bar:** izbaci `★☆☆ · 1 coin each` (cijena po komadu već stoji na svakoj kartici kao „🪙 1 each") i podnaslov `hold 10 / s` s dugmeta. **Smanji dugme** (danas 430 × 120).
10. **Isto važi za prazno stanje** u oba taba (`Your bag is empty` / `No flowers yet`): isto skraćivanje i manje dugme („Play a run ↗" je danas 110 px visok, a ispod njega stoji onemogućen Trade bar s „Nothing selected / pick a type to trade" + „Trade / nothing to trade").

### 3.3 Današnji raspored (mjere za orijentaciju)

Stranica huba: 1080 × 1597 između headera (143) i footera (180). Padding stranice 24 → sadržaj 1032 × 1549.

```
┌ SeasonLinkCard 1032 × 422 ─────────────────────────────┐
│ "Next free season"  38                  ┌ Details ↗ ┐  │  ← 1. i 2. van
│ Lantern Meadow      56                  └ 72 px ────┘  │
│ 🪙 260 / 500   │  🌸 0 / 20      ← vrijednosti 48       │
│ Coins 38       │  Crystal Peony ★★★ 38                  │
│ ▬▬▬▬ traka 18  │  ▬▬▬▬ traka 18                         │
│ ┌ Unlock 988 × 132 ─────────────────────────────────┐  │  ← 3. i 4.
│ │ "Unlock" 50 / "needs 240 more coins…" 38          │  │
└─┴───────────────────────────────────────────────────┴──┘
        ↕ rupa 215–375 px (raste kad ima manje sadržaja)     ← 5.
┌ StashSection 1032 × (752–908) ─────────────────────────┐
│ ┌ Seeds 46 [2] ──┐ ┌ Flowers [0] ┐ ┌ Merge 190 ┐      │  ← 6. i 7.
│ │ "Arena fuel" 38│ │ "reward"    │ └───────────┘      │
│ ├────────────────┴─┴─────────────┴───────────────┐    │
│ │ chip 489 × 176: okvir arta 104 (crtež 66)      │    │  ← 8.
│ │ ime 40 · ★★☆ 32 · [🌱 7] 48 · [🪙 1 each] 46    │    │
│ ├────────────────────────────────────────────────┤    │
│ │ TradeBar 152: art 88 · ime 40                  │    │  ← 9.
│ │ "★☆☆ · 1 coin each" 38 · [Trade 430 × 120]     │    │
└─┴────────────────────────────────────────────────┴────┘
```

Ostale današnje mjere: red tabova 132 px (ikona 84, brojač 88 × 60), razmak u gridu 14, rezervisana kartica 244 px (ima badge red), Trade bar s upozorenjem 224 px, prazno stanje 400 px (ikona 110, CTA 110).

## 4. MORA / SMIJE

### 4.1 MORA

- Sve iz §3 (tačke 1–10).
- **Pravila iz §2 ostaju** — tap = 1, držanje = 10/s, cijene, rezervisano cvijeće, 500 + 20.
- **Držanje mora ostati otkrivljivo bez rečenice.** Danas to piše na dugmetu („hold 10 / s"). Kad tekst ode, mora se vidjeti iz ponašanja: dugme se već puni dok držiš, a „+N" pilula leti prema coin chipu u headeru. Pojačaj taj signal ako treba.
- **Stanja Trade dugmeta moraju ostati razlučiva bez podnaslova** (danas ih nosi podnaslov): mirno · drži se (prodaje 10/s) · držanje stalo na rezervisanom cvijetu (dalje samo tap) · prodaja bi dirala rezervisano (upozorenje) · nema šta prodati.
- **Upozorenje za rezervisano cvijeće ostaje** (strip iznad reda + badge „Kept · N / M" na kartici). To je zaštita igrača, ne ukras.
- **Cijena po komadu ostaje na kartici** predmeta (ide samo iz Trade bara).
- Sve interaktivno ≥ 120 px u dodiru; tekst ≥ 34 px; EN tekst.
- Header (143) i footer (180) su zadati i ne mijenjaju se; stranica je 1080 × 1597 između njih, bez horizontalnih gesti (hub se lista lijevo/desno prstom).
- Lista skrola vertikalno unutar sekcije (drag scroll već postoji) i radi za 1 do 8+ tipova.
- Radi i kad kartice sezone **nema** (sve besplatne sezone otključane) — tada sekcija uzima cijelu stranicu.

### 4.2 SMIJEŠ (sloboda)

- Preraspodijeliti sadržaj kartice sezone (glava, trake, dugme) i smanjiti joj visinu ako dobiješ bolji ritam — sekcija onda dobija tu visinu.
- Promijeniti oblik i mjesto Unlock dugmeta (npr. uz traku coina ili kao pilula u glavi kartice).
- Redizajnirati karticu predmeta iznutra (odnos art / ime / broj / cijena) dok je vanjska mjera 489 × 176 ista.
- Promijeniti izgled tabova (visina reda, brojač, aktivno stanje).
- Skratiti ili izbaciti „each" uz cijenu na kartici — broj mora ostati.
- Promijeniti prazno stanje (ikona, jedna rečenica, dugme) — samo kraće i manje nego danas.
- Predložiti bolji raspored Trade bara (art, ime, dugme) dok ostaje na dnu sekcije.

## 5. Tokeni i stil

Sve već postoji u paketu `design_handoff_camp/` i u `game/scripts/visual/ui_camp.gd` — koristi iste boje i nazive, dodaj samo ono što je novo:

- pozadina stranice `#2E4733`, sekcija `WARM_WHITE #FFF8F0` s rubom `INK @ 16 %`, tinta `INK #2D3436`;
- kartica sezone u tinti sezone: Frost `#C5D5E8`, Lantern `#C9B8E0`, Amber `#E8C48A` (rub 20 % tamniji);
- akcenti: PEACH (Trade), MINT (prečice), coin gold `#FFD56B`, Unlock gold `UiPalette.GOLD` s rubom `#BA9D3B`;
- rarity podloge kartica: `RARITY_BG_1/2/3` iz `ui_palette.gd`;
- radijusi i sjene kao u prvom paketu (jedna meka sjena, bez blura na tekstu).

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

Artboard 1080 × 1920, sve mjere u px te baze (prenos je 1:1). Paneli = ravna boja + alpha, radius, border, jedna sjena. Animacije su tweenovi (0,08–0,42 s). Bez blura, gradijenata na panelima, teških čestica, 3D-a i stalnog pulsiranja više elemenata odjednom. Art sjemenki i cvijeća crta igra (SVG + proceduralni fallback) — ne treba novi art, samo veće mjere okvira i crteža.

## 7. Isporuka

### 7.1 Stanja koja moraju biti nacrtana

1. **Seeds, puna torba** (6–8 tipova, skrol) — odabran jedan tip, Trade spreman.
2. **Seeds, malo sadržaja** (1–2 tipa) — dokaz da nema rupe u sredini.
3. **Seeds, prazna torba** — prazno stanje + onemogućen Trade.
4. **Flowers s rezervisanim cvijetom** — badge „Kept · 12 / 20" i strip upozorenja iznad Trade reda.
5. **Flowers, držanje stalo na granici** — dalje samo tap.
6. **Trade u toku** (držanje) — fill i „+N" pilula.
7. **Kartica sezone: nedostaje** (Unlock neaktivan) i **spremno** (Unlock aktivan).
8. **Trenutak otključavanja** (burst na kartici).
9. **Bez kartice sezone** — sve besplatne otključane, sekcija uzima cijelu stranicu.

### 7.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom. Ako zip ne može, zalijepi u chat sadržaj JSON-a, `.gd` i README-a.

```
design_handoff_camp_v2/
  README.md                 šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica svaka)
                            · § Šta se briše · § Ideje van zadatka
  design/
    CampScreen.dc.html      cijeli ekran; prop `scene` bira stanje iz 7.1
    Camp Specs.dc.html      sva stanja na jednom kanvasu + spec komponenti
                            + tabela animacija
    HubScreen.dc.html       zadati header/footer (kopija, ne mijenja se)
    support.js · icons/
  assets/                   samo novi fajlovi za export (ako ih uopšte bude)
  godot/
    camp_v2_export.json     ekran kao podaci, ista šema kao
                            design_handoff_shop/godot/shop_export.json:
                            meta · tokens (samo novi/promijenjeni) · layout (rect
                            svakog bloka) · components (child mjere + stanja) ·
                            scenes (stanja s tačnim brojevima) · animations ·
                            strings_en · assets · godot_map (sloj → node iz §10) ·
                            smoke_tests · decisions
    ui_camp.gd              samo izmijenjene/nove konstante i StyleBoxFlat fabrike
                            (isti nazivi kao u postojećem ui_camp.gd)
    camp_tree.txt           node tree s veličinama
    README.md               red prenosa u koracima + šta se briše
```

**Imena slojeva** (za mapiranje na Godot, §10): `SeasonLinkCard`, `SeasonProgress`, `UnlockButton`, `StashSection`, `StashTabs`, `SeedsTab`, `FlowersTab`, `StashGrid`, `CampChip`, `ChipArt`, `ReservedBadge`, `TradeBar`, `TradeArt`, `TradeButton`, `ReservedWarning`, `TradeFeedback`, `EmptyState`, `EmptyCta`.

## 8. Ne tražimo

- Promjenu cijena, brojeva i pravila iz §2.
- Merge u Campu, kupovinu upgradea, potrošnju dijamanata.
- Ostale stranice huba (Home, Shop, Journal, Arena), Run i loot ekran.
- Novi art sjemenki i cvijeća (to je [[seeds-flowers-cd-brief|poseban zadatak]]).
- Više varijanti za biranje — jedan dizajn.

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim drugu rundu redizajna jednog ekrana mobilne igre: CAMP.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Camp si već radio; taj paket je u repou (design_handoff_camp/). Sada ga
čistimo.

Tvoja referenca su dva fajla u repou (master), pročitaj oba po ovim tačnim
putanjama:
  docs/04-experience/design-drafts/camp-v2-cd-brief.md   (ovaj zadatak)
  docs/04-experience/design-drafts/camp-cd-brief.md      (prva runda, kontekst)
Ako se ovaj prompt i fajl razlikuju, važi fajl. §10 je za kasniji prenos i
možeš ga preskočiti.

Ostali ekrani (isti svijet, drži se istog jezika):
  design_handoff_hub_chrome/HubScreen.dc.html        (header + footer, zadato)
  design_handoff_camp/CampScreen.dc.html             (Camp, prva runda)
  design_handoff_shop/design/ShopScreen.dc.html      (najnoviji ekran)
  game/scripts/visual/ui_camp.gd                     (tokeni u igri)

TVOJ ZADATAK: očisti Camp. Previše je teksta i raspored pluta — igrač treba
da prati intuiciju, ne uputstvo. Ekonomija i pravila su fiksni.

JEDAN DIZAJN: ne pravi smjerove, varijante ni alternative za biranje. Kad
imaš dilemu, odluči sam i napiši razlog u jednoj rečenici u README
§ Odlučeno. Ne čekaj moju potvrdu.

ŠTA SE MORA PROMIJENITI (detalji i mjere u §3):
1. Kartica sezone gore: izbaci tekst "Next free season" i pločicu
   "Details ↗". Tap bilo gdje na kartici i dalje vodi na Home — to ostaje,
   samo se ne najavljuje tekstom.
2. Unlock dugme: ostaje samo riječ "Unlock", bez podnaslova ("needs 240 more
   coins and 20 more flowers" već piše u trakama napretka iznad). Dugme je
   danas 988 x 132 px - bespotrebno ogromno, smanji ga.
3. Sekcija sa sjemenkama/cvijećem mora uvijek stajati odmah ispod kartice
   sezone i imati istu visinu bez obzira na broj elemenata. Danas je
   prikovana za dno stranice pa u sredini ostaje rupa koja mijenja veličinu
   (375 px prazna torba, 215 px puna) - ružno.
4. Red s tabovima: izbaci "Merge" prečicu, taj red je samo za biranje
   Seeds | Flowers (Arena je tab u footeru).
5. Tabovi: izbaci podnaslove "Arena fuel" (Seeds) i "reward" (Flowers).
   Ostaju ime + broj tipova.
6. Kartice predmeta: povećaj crtež sjemenke/cvijeta, ali NE povećavaj
   karticu (ostaje 489 x 176; danas je okvir arta 104, crtež 66/70 px).
7. Trade bar: izbaci "★☆☆ · 1 coin each" (cijena već stoji na kartici) i
   podnaslov "hold 10 / s" s dugmeta; smanji dugme (danas 430 x 120).
8. Isto skraćivanje i manje dugme u praznom stanju, u oba taba.

MORA OSTATI:
- Pravila: tap prodaje 1, držanje prodaje 10/s, cijene po rijetkosti,
  rezervisano cvijeće za sljedeću sezonu, otključavanje 500 coina + 20 ★3.
- Držanje mora ostati otkrivljivo BEZ rečenice - dugme se puni dok držiš i
  "+N" leti prema coin chipu u headeru; pojačaj taj signal ako treba.
- Stanja Trade dugmeta razlučiva bez podnaslova: mirno · drži se · držanje
  stalo na rezervisanom · prodaja bi dirala rezervisano · nema šta prodati.
- Upozorenje za rezervisano cvijeće (strip + badge "Kept · N / M").
- Cijena po komadu ostaje na kartici predmeta.
- Sve interaktivno >= 120 px, tekst >= 34 px, EN tekst.
- Header (143) i footer (180) zadati; stranica 1080 x 1597 između njih, bez
  horizontalnih gesti. Lista skrola vertikalno, radi za 1 do 8+ tipova.
- Radi i kad kartice sezone nema (sve besplatne otključane).

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, sve u px
te baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna
sjena. Animacije = tween. Bez blura, gradijenata na panelima, teških
čestica i 3D-a. Art sjemenki i cvijeća crta igra - ne treba novi art, samo
veće mjere okvira i crteža.

ISPORUKA (§7): devet stanja iz §7.1 i paket TAČNO po strukturi iz §7.2 -
design_handoff_camp_v2/ s README.md, design/ (CampScreen.dc.html, Camp
Specs.dc.html, HubScreen.dc.html, support.js, icons/), assets/ i godot/
(camp_v2_export.json u istoj šemi kao shop_export.json, ui_camp.gd,
camp_tree.txt, README.md). Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s
cijelim folderom.

IMENA SLOJEVA: SeasonLinkCard, SeasonProgress, UnlockButton, StashSection,
StashTabs, SeedsTab, FlowersTab, StashGrid, CampChip, ChipArt,
ReservedBadge, TradeBar, TradeArt, TradeButton, ReservedWarning,
TradeFeedback, EmptyState, EmptyCta.

NE RADI: promjenu cijena i ekonomije, merge u Campu, potrošnju dijamanata,
ostale stranice huba, Run i loot ekran, novi art cvijeća. Ideje van zadatka
navedi odvojeno na kraju README-a.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot čvor / fajl |
|---|---|
| `SeasonLinkCard`, `SeasonProgress`, `UnlockButton` | `scenes/camp/camp_scene.tscn` → `RootVBox/CampPage/ContentStack/SeasonLinkCard` + `scripts/camp/season_link_card.gd` |
| razmak i visina sekcije | `ContentStack/StackGap` (danas `size_flags_vertical = 3` — to je uzrok rupe) + `UiCamp.SEASON_H` / `SECTION_GAP_MIN` / `section_height()` / `grid_budget()` |
| `StashSection`, `StashTabs` | `ContentStack/StashSection/SectionVBox` + `scripts/camp/camp_controller.gd` |
| `SeedsTab`, `FlowersTab` | `scripts/camp/camp_stash_tab.gd` (podnaslov `_sub` se briše) |
| Merge prečica | `%MergeShortcut` + `UiCamp.shortcut_style()` / `SHORTCUT_W` — briše se (prazno stanje zadržava CTA „Merge in Arena ↗") |
| `CampChip`, `ChipArt`, `ReservedBadge` | `scripts/camp/camp_stash_chip.gd` + `UiCamp.CHIP_*` (art: `CHIP_ART_FRAME`, `CHIP_ART_SEED`, `CHIP_ART_FLOWER`) |
| `TradeBar`, `TradeButton`, `ReservedWarning`, `TradeFeedback` | `scripts/camp/camp_trade_bar.gd` + `UiCamp.TRADE_*`, `trade_button_text()`, `trade_info_text()` |
| `EmptyState`, `EmptyCta` | `camp_controller._apply_empty_state()` + `UiCamp.EMPTY_*` |
| tekst Unlock dugmeta | `UiCamp.unlock_button_text()` + `UNLOCK_BTN_H` |

Smoke testovi koje prenos mora zadržati zelenima: `camp_layout_smoke`, `camp_season_link_smoke`, `camp_trade_select_smoke`, `camp_trade_hold_smoke`, `camp_hold_floor_smoke`, `camp_crystal_select_smoke`, `camp_donate_smoke`, `meta_hub_flow_smoke`.

## Implementacija (2026-09-24)

> Status: **preneseno u igru** iz `design_handoff_camp_v2/`. §3 opisuje stanje **prije** prenosa i ostaje kao zapis.

| Fajl | Šta je urađeno |
|------|----------------|
| `game/scripts/visual/ui_camp.gd` | v2 mjere: `SEASON_H` 276, `SECTION_GAP` 20, `SECTION_H` 1253 / `SECTION_H_NO_SEASON` 1549, tabovi 120, chip art 128 (96 / 100), pilule 52, Trade 300 × 120, prazno stanje 120/100. Nove fabrike `coin_bump_style()`, `trade_art_empty_style()`, `hold_fill_ratio()`, `trade_button_icon()`; `unlock_button_text()` i `trade_button_text()` vraćaju jednu riječ. Obrisano: `SECTION_GAP_MIN`, `SECTION_H_DEFAULT`, `GRID_MAX_ROWS`, `home_hint_style()`, `trade_info_text()`, `switch_plate_style()`, `FONT_EACH`, `FONT_BADGE_FLOOR`, `FONT_TAB_SUB`, `SHORTCUT_*`, `HOME_HINT_H`, `UNLOCK_BTN_H`, `EMPTY_BLOCK_H`. |
| `game/scenes/camp/camp_scene.tscn` | `StackGap` obrisan (`ContentStack.separation = 20`); kartica sezone 276 px s `SeasonHead` = ime + Unlock 300 × 120; obrisani `SeasonEyebrow`, `HomeHint`, `SeasonCoinCap`, `SeasonLinkFlowerName`, `MergeShortcut`, `EmptyBody`, `SelectedValue`; `StashSection` fiksne visine, `StashScroll` i `EmptyState` uzimaju ostatak. |
| `season_link_card.gd` | Bez natpisa i pločice; Unlock u glavi kartice, jedna riječ + lokot 40 px u „short" stanju. |
| `camp_stash_tab.gd` | Bez podnaslova; ime lijevo, brojač uz desni rub; red 120 px, ikona 76 / 44. |
| `camp_stash_chip.gd` | Art 128 px (crtež 96 / 100), tijelo 315 px, pilule 52 px bez „each", `ReservedBadge` u redu pipsa (chip ostaje 176 px i kad je rezervisan). |
| `camp_trade_bar.gd` | Bez `SelectedValue`; dugme 300 × 120 s jednom riječju i ikonom (lokot / hold-stop); fill = prodani dio gomile; na svaki tik novčić 44 px leti do coin chipa (max 3) i chip dobije prsten; prazan izbor = obris bez crteža. |
| `camp_controller.gd` | Sekcija uvijek `UiCamp.section_height(hero)`; nema rezanja redova po `grid_budget()`; prazno stanje bez rečenice; `_hold_sold` / `_sellable_left()` hrane fill. |
| `camp_art_frame.gd` | Prazan okvir (bez tipa i ikone) crta `trade_art_empty_style()` umjesto tamnog wella. |
| Testovi | Novi `camp_section_fixed_smoke` (sekcija ista za 0 / 1 / 8 / 14 tipova, sa stripom i bez kartice sezone); ažurirani `camp_layout_smoke`, `camp_season_link_smoke`, `camp_trade_select_smoke`, `camp_hold_floor_smoke`, `camp_trade_hold_smoke`, `camp_crystal_select_smoke`, `camp_smoke_util`. Suite 52/52, GUT 33/33. |

**Odstupanja od paketa (svjesna):**

1. **`FONT_BTN_SUB` je ostao** u `UiCamp` — Camp ga više ne koristi, ali `CampButton` dijeli Shop (`ui_shop_buttons.gd`) i tamo podnaslov postoji.
2. **Duga imena se i dalje skraćuju na kartici** („Harvest Pumpk…" u Seeds tabu) — paket računa s Nunitom, a naš default font je širi na 38 px. U Flowers tabu, gdje su pilule uže, ime staje cijelo.
3. **`CoinChipBump` prati pravi rect coin chipa** (+6 px) umjesto fiksnog `(12, 15, 312, 116)` — safe-area pomjera header, pa je vezivanje za čvor sigurnije.
4. **`TradeFeedback` je ostao na staroj kotvi** `(−16, −20)`; paket traži `(−16, −42)`. Pilula i bez toga stoji iznad bara.
5. **Auto prelaz na sljedeći tip** javlja se pojavom novog imena u baru (fade 0,2 s) umjesto mint pločice — tekst „empty — switched here" je obrisan.

## Povezano

- [[camp-cd-brief|camp-cd-brief]] — prva runda (pravila, mjere, § Implementacija)
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — header/footer u koji Camp ulazi
- [[shop-cd-brief|shop-cd-brief]] — isti format brifa i paketa
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci
