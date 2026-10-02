---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ui, popup, modal, sheet, toast, run, arena, home, claude-design, mockup]
povezano:
  - shop-v2-cd-brief
  - wardrobe-cd-brief
  - home-field-v2-cd-brief
  - run-cd-brief
  - merge-arena-cd-brief
  - hub-chrome-v2-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: redizajn SVIH pop-upova u igri kao jednog sistema (modal, sheet, oblačić, toast, leteća poruka) — 21 pop-up u Home, hubu, Shopu, Campu, Areni i runu (pauza, kraj runa / loot, poklon, nadogradnje, izbor sjemena za korpu, „You need more seeds!" s ostatkom u korpi, tutorial oblačići, toastovi); mehanika i iznosi ostaju."
---

# Pop-upovi — cijela igra — Claude Design brief

> **Status 2026-10-02: prenesen u igru.** Paket `design_handoff_popups/` je u repou (22 ID-a — H1–H8, X1–X3, S1, C1, A1–A4, R1–R5; brief je brojao 21). Čeka playtest. Prompt je u §12.

> Pop-upovi su nastajali jedan po jedan, uz svaki ekran posebno, pa danas igra ima **pet različitih izgleda** za istu stvar: tamni stari loot ekran sa zelenim/crvenim tekstom, bijeli panel pauze, sitni poklon od 400 × 320, sheet korpe s tekstom od 22 px, tri vrste toasta. Ovo je **jedan dizajn za sve**: sistem od pet vrsta pop-upa, pa svaki pop-up iz §4 nacrtan u tom sistemu. **Nijedan ne smije ostati u starom izgledu.**

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§11 + slike u `popups-ref/` | Šta mora, šta smije, kako izgleda danas, šta se isporučuje |
| **Ti** | **§12** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §4, §6, §7 | Popis svih pop-upova s tačnim fajlom, tekstom i ponašanjem koje se ne mijenja |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove i slike iz repoa po tačnoj putanji.

## 1. Zašto

Agent je prošao kroz cijeli kod (`game/scripts/`, `game/scenes/`) i našao **21 pop-up** u šest zona (§4). Svaki je pravljen za svoj ekran i nijedan ne dijeli izgled s drugim:

- **Kraj runa** (`loot_screen`) je ostatak prototipa: tamna pozadina, naslov crven/zelen, plijen žutim tekstom na kremu, četiri dugmeta od 72 px (ispod minimuma dodira 120), status u sitnom redu.
- **Poklon** je panel 400 × 320 s naslovom i rečenicom „Daily chest: +8 coins and +3 Buttercup Lane seeds!" — nagrada se čita, ne vidi.
- **Izbor sjemena za korpu** (Basket seed) ima redove s imenom od **22 px** i malim crtežom; zaključani su samo posivljeni.
- **„You need more seeds!"** u Areni pokazuje **samo jedan red** iako u korpi ima pet tipova (bug mjerenja liste, `15_arena_need_more_seeds.jpg`) — igrač ne vidi šta mu je ostalo u korpi.
- **Toastovi**: tamna pilula `#2D3436` (Home, Ormar), bijeli toast (Settings), Shop toast, pa „+N" pilule u Campu i headeru — svaki drugih mjera.
- **Oblačići**: bijeli s repom u Areni, providna traka u runu, kremasti s prstenom na Homeu.

Cilj: igrač u bilo kom dijelu igre prepozna pop-up po obliku, zna kako se zatvara, a nagradu **vidi** (coin, cvijet, sjeme kao crtež), ne čita.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stranica huba | 1080 × 1633 između hub headera (143) i footera (144). **Hub header i footer (chrome v2) se ne diraju** — osim pilule „Round in progress" (§4, X3) koja dobija stil sistema, a ostaje na istom mjestu. |
| Run | 1080 × 1920 preko trake runa; HUD runa (tajmer, Pip chip, brojači, pauza) se ne dira. |
| Mehanika i iznosi | Poklon 8 coina + 3 sjemenke, nadogradnja košta 2 cvijeta, nivoi 0–4, „Quit" čuva pola, revive 1 po runu, ×2 loot preko reklame — **ništa se ne mijenja**, CD crta samo kako se vidi. |
| Kako se zatvara | Sheetovi (korpa, nadogradnje, Ormar): tap na scrim, Close, povlačenje dolje, Android back. Modali koji traže odluku (pauza, kraj runa, „You need more seeds!") **ne** zatvaraju se tapom van — samo dugmetom. Poklon: dugme ili tap van. Toast i leteće poruke nisu dodirljive. |
| Reklame (Pillar 2) | Double Loot i Revive su **opcionalni** rewarded video; dugme jasno kaže da je reklama, nikad nije primarno veće od „Retry"/„To Camp", a bez reklame igrač ništa ne gubi. Revive najviše 1 po runu i samo kad je run pao. |
| Jedan pop-up u isto vrijeme | Novi modal/sheet zatvara prethodni. Toastovi idu u red (najviše 2 vidljiva). |
| Već dizajnirano | Ormar (`design_handoff_wardrobe/`) i Shop v2 (`design_handoff_shop_v2/`) su najnoviji dizajn — njihov raspored ostaje, ali sheet Ormara, ApplyToast i Shop toast **ulaze u sistem** (scrim, ručka, Close, toast tokeni). Combo „×N" i MergeHintMark u Areni nisu pop-upovi i ne diraju se. |
| Pillar 2 | Nijedan pop-up ne smije pritiskati na kupovinu (nema ponude Shopa u pop-upu kraja runa, nema „kupi" u „You need more seeds!"). |

## 3. Šta se traži

Tačke 1–5 su **obavezne**. Izgled, animacije i boje su tvoja odluka. Jedan dizajn. Neka bude lijep.

1. **Sistem od pet vrsta pop-upa** — svaki pop-up iz §4 pripada tačno jednoj:
   - **Modal** — centriran panel + scrim, traži odluku (pauza, kraj runa, poklon, „You need more seeds!").
   - **Sheet** — izlazi odozdo + scrim, lista izbora (korpa, nadogradnje, Ormar).
   - **Oblačić (Coach)** — pokazuje na nešto, bez scrima, tutorial ili kratka poruka (Home hint, Arena oblačić, run tutorial).
   - **Toast** — kratka potvrda, sam nestaje, nije dodirljiv („Unlocked", „Yours", „Runs use Sunset Meadow", „Settings coming soon.").
   - **Leteća poruka (Pop)** — „+N" uz coin/sjeme koja odleti do brojača (Camp trade, coin pop u headeru, +1 u runu, ime sjemena u runu).
2. **Svaki pop-up iz §4 nacrtan u sistemu** — ništa ne ostaje u starom izgledu. Za svaki: sva stanja iz §4 i §9.1.
3. **Manje teksta, nagrada se vidi.** Gdje danas piše rečenica s brojevima („Daily chest: +8 coins and +3 Buttercup Lane seeds!", „+9 Coins / +3 Meadow Clover / +2 Field Daisy"), nagrada je **crtež + broj** (coin ikona, crtež sjemena/cvijeta iz igre). Izbaci sve označeno „izbaciti" u §4; ako misliš da još nešto treba van, izbaci i napiši u § Šta se briše.
4. **Jedna porodica dugmadi** za sve pop-upove: primarno, sekundarno, reklama (ikona video), onemogućeno, čeka (učitava reklamu). Dodir ≥ 120 (danas loot 72!).
5. **Dva konteksta**: pop-up preko huba (svijetle livade, pergament Shopa) i preko runa (tamna traka). Isti sistem, mora biti čitljiv na oba (scrim i panel riješe kontrast, ne druga paleta).
6. Ulaz/izlaz za svaku vrstu (tween: skala, pozicija, alpha). Nagrada u poklonu i na kraju runa smije imati mali „reveal" (chipovi iskoče jedan za drugim) — najviše jedan loop na ekranu.

## 4. Popis — svaki pop-up u igri

Slike današnjeg stanja: `docs/04-experience/design-drafts/popups-ref/` (1080 × 1920 iz igre, §7.2). Kolona „Vrsta" je prijedlog — ako misliš da pop-up pripada drugoj vrsti, promijeni i obrazloži.

### 4.1 Home (polje sezone i kartica)

| ID | Pop-up | Danas | Traži se |
|---|---|---|---|
| **H1** | **Hint prvog starta** · Coach | `home_stage_hint.gd`: kremasti oblačić „Tap Play to start your first run / The card opens your meadow." na y 836 + pulsirajući prsten oko Play. Slika `01`. | Oblačić sistema koji pokazuje na Play. Tekst — jedna kratka linija ili ništa uz prsten (tvoja odluka). |
| **H2** | **Korpa zaključana** · Coach | `main_menu.gd → TutorialHintPanel`: traka „Merge your first flower in the Arena to unlock the basket." dolje lijevo, **pokriva Pipa** (slika `02`); tap na zaključanu korpu = drhtaj korpe + ista traka. | Oblačić koji pokazuje na korpu, ne pokriva Pipa ni Play. Kraći tekst. |
| **H3** | **Poklon (Gift)** · Modal | `main_menu.gd → RewardOverlay`: panel 400 × 320, „Daily gift!" + „Daily chest: +8 coins and +3 Buttercup Lane seeds!" (ili „…(bag almost full!)"), dugme OK. Već otvoren danas: „Come back tomorrow / Daily chest already opened today." Slike `03`, `04`. | Modal nagrade: **coin + crtež sjemena s brojem** umjesto rečenice, jedan „reveal". Stanje „sutra opet" — kratko; da li prikazati vrijeme do sljedećeg poklona (npr. „in 7h") — tvoja odluka (agent zna izračunati). Stanje „korpa skoro puna" (dobio manje sjemenki) — vidljivo bez dugačke rečenice. **Izbaciti:** „Daily chest:", „Daily chest already opened today.", OK kao jedino što ima boju. |
| **H4** | **Izbor sjemena za korpu** (Choose / Basket seed) · Sheet 1326 | `main_menu.gd → BasketPickerOverlay`: naslov „Basket seed", 6 redova (sve sjemenke sezone: crtež + ime **22 px** + zvjezdice), zaključane posivljene, izabrana „primary", dugmad „Clear basket" i „Close". Slika `05`. | Sheet sistema (ista porodica kao Ormar). Sjemenke kao **veće kartice/pločice** s pravim crtežom (`HomeBasketPickerIcon`), ime ≥ 34, rijetkost zvjezdicama; zaključana = katanac (ne samo siva); izabrana = jasno označena. „Clear basket" — sekundarno ili ikona. Tap na sjemenku = izbor i zatvaranje (kao danas). |
| **H5** | **Nadogradnje (Boost / Upgrades)** · Sheet 922 | `main_menu.gd → UpgradesOverlay`: „Upgrades" + „Levels stay for every run. Paid in flowers.", dvije kartice **Magnet** i **Loot Boost**: „Lv 0 / 4", 4 segmenta, efekat („Pull radius 40 px → 88 px", „Run loot ×1.0 → ×1.25"), cijena „2 × Meadow Clover", dugme Upgrade / „Need N" / „Maxed"; poslije kupovine 0,4 s „Spent 2 × …"; „Nothing left to buy" na maksimumu; Close. Slika `06`. | Sheet sistema. Cijena kao **crtež cvijeta × 2**, ne tekst; nivo segmentima (broj „Lv" — tvoja odluka); efekat jedna linija. Stanja dugmeta: može / fali N / max. Trenutak kupovine (bljesak 0,4 s) u stilu sistema. **Izbaciti:** podnaslov „Levels stay for every run. Paid in flowers." (ili jedna kratka linija). |
| **H6** | **Ormar (Wardrobe)** · Sheet 1326 | `wardrobe_sheet.gd` — CD dizajn od 2026-10-01 (slika `07`). | **Raspored ostaje.** Uskladi samo sa sistemom: scrim, ručka, naslov, Close, ulaz/izlaz. Ako sistem traži promjenu tokena, primijeni je i ovdje i napiši u README. |
| **H7** | **ApplyToast** (Ormar) · Toast | Tamna pilula `#2D3436`, 44/900 krem, x 540, y 1110, h 100, 2,6 s: „Runs use Sunset Meadow", „New looks are on". Slika `08`. | Toast sistema, ista pozicija. |
| **H8** | **Unlocked / Yours** · Toast | `season_stage.gd → StageToast`: tamna pilula 600 × 100 na y 1250, 1,4 s, kad se otključa besplatna sezona („Unlocked") ili kupi premium („Yours"). Slika `09`. | Toast sistema. Smije nositi mali katanac koji se otvara / zvjezdicu (tvoja odluka). |

### 4.2 Hub (header) i Shop

| ID | Pop-up | Danas | Traži se |
|---|---|---|---|
| **X1** | **Settings** · Toast | `meta_hub_controller.gd → SettingsToast`: bijeli toast 36 px „Settings coming soon." 24 px ispod headera, 1,6 s. Slika `10`. | Toast sistema (isti kao H7/H8). |
| **X2** | **Coin pop** · Pop | `CoinSpendPop` ispod coin chipa (150, 132): „−150" pri kupovini u Shopu, „+2" iz combo nagrade u Areni (slike `11`, `16` gore lijevo). | Leteća poruka sistema: potrošnja i zarada se razlikuju (boja/znak), uz coin ikonu. |
| **X3** | **Round in progress** · statusna pilula | `NavLockPill` iznad footera dok traje Arena sesija: „🔒 ROUND IN PROGRESS" (slika `14` dolje). | Stil sistema, **isto mjesto i mjere** (dio chrome v2). |
| **S1** | **Shop toast** · Toast | `shop_screen.gd → _Toast` (Shop v2): „Moonlit Warren is yours" itd. Slika `11`. | Toast sistema; tekstovi ostaju. |

### 4.3 Camp

| ID | Pop-up | Danas | Traži se |
|---|---|---|---|
| **C1** | **Trade „+N"** · Pop | `camp_trade_bar.gd`: pilula „+12 ◎" iznad dugmeta Trade (raste dok držiš), na kraju odleti do coin chipa (`TradeFeedbackFly`). Slika `12`. | Leteća poruka sistema (ista kao X2 „+"). |

Journal i ostatak Campa — **pregledano, nema pop-upova** (prazna stanja i opisi u redovima nisu pop-up).

### 4.4 Arena

| ID | Pop-up | Danas | Traži se |
|---|---|---|---|
| **A1** | **Tutorial oblačić** · Coach | `arena_cue.gd`: bijeli oblačić s repom iznad korpe (max 760, dno 330 od dna polja, 40 px): „Tap the bag to pour seeds. Drag matching seeds together." Stoji dok se ne prospe sjeme. Slika `13`. | Oblačić sistema s repom na korpu. Kraći tekst (npr. dva koraka s ikonama — tvoja odluka). |
| **A2** | **Muncher se probudio** · Coach | Isti oblačić bez repa, 3,5 s, jednom: „Muncher's awake — a T3 freezes it 2s." Slika `14`. | Oblačić sistema; smije pokazivati na munchera umjesto na korpu. |
| **A3** | **„You need more seeds!" — ostatak u korpi** · Modal | `merge_arena_controller.gd → NeedMoreSeedsOverlay`: tap na korpu kad nijedan tip nema 4 sjemenke. Naslov 58, „Every type needs 4 seeds to reach T3. Run again to collect more.", lista `ArenaNeedRow` (T1 cvijet 72, ime 40, „1/4" 44, red 108 u boji rijetkosti), „Back to Camp". Zatvara se **samo** dugmetom. **Bug:** lista se mjeri na jedan red (108 px) pa se vidi samo prvi tip — slika `15` (u korpi je 5 tipova). | Modal sistema. **Svi tipovi iz korpe vidljivi** (mreža pločica umjesto liste — tvoja odluka), svaki s crtežom i napretkom do 4 (npr. 4 tačke/segmenta umjesto „1/4"). Kratko „treba ti još" + jedno dugme. Pillar 2: nikakva ponuda kupovine. **Izbaciti:** rečenicu „Every type needs 4 seeds to reach T3. Run again to collect more." (ili jedna kratka linija). |
| **A4** | Combo „+2" | Leti iz polja do coin chipa (Arena v2) pa X2 pop. | Samo X2 (ostatak je Arena v2 i ne dira se). |

### 4.5 Run

| ID | Pop-up | Danas | Traži se |
|---|---|---|---|
| **R1** | **Tutorial u runu** · Coach | `run_controller.gd → TutorialCue`: providna traka 760 × 110 na y 1218, 38 px: „Coins for the shop!" (prvi run, 20. s, 3 s). U sceni je i „Swipe left / right to change lanes" (trenutno se ne prikazuje). Slika `17`. | Oblačić sistema za tamnu traku runa; ne pokriva Pipa ni prepreke ispred njega. |
| **R2** | **Ime sjemena + „+1"** · Pop | `run_pickup_feed.gd`: „+1" leti do brojača, toast s imenom sjemena (npr. „Daisy") ispod brojača, 1,4 s, najviše 2. Slika `17`. | Leteća poruka sistema za run. |
| **R3** | **Pauza** · Modal | `run_scene.tscn → PauseOverlay`: panel 900 × 680 na 18 % visine: „Paused", „Quitting keeps half of what you carry. No revive is used.", „Keep running" (peach), „Quit to Camp". Slika `18`. | Modal sistema na tamnoj traci. Upozorenje „quit = pola" kratko (npr. ikona + „½") — mora ostati jasno da odlazak gubi pola. **Izbaciti:** „No revive is used." |
| **R4** | **Kraj vremena** · banner | `FinishBanner` 760 × 220 na 36 %: „Time!" + „Full basket — nothing lost", ~1 s, pa loot ekran. Slika `19`. **Pad (smrt)** nema pop-up: Pip se zaljulja, žetoni se rasprše, crveni bljesak, pa loot ekran. | Banner u stilu sistema (Toast ili Modal bez dugmeta — tvoja odluka). Da li pad dobija kratak banner (npr. „Ouch!") — tvoja odluka, bez dugmeta i ≤ 1 s. |
| **R5** | **Kraj runa (Loot)** — „kad umrem" i „kad završim" · Modal | `loot_screen.gd` / `.tscn` — zasebna scena, panel 680 × 720 na tamnom. **Pao:** „Run Failed" (crveno), plijen „+9 Coins / +3 Meadow Clover / +2 Field Daisy", red „Obstacle hit — kept 50%: 18 → 9 coins, 9 → 4 seeds." (tutorial: „Hit an obstacle? …"), dugmad **Double Loot** (reklama), **Revive — continue run** (reklama, samo ako nije iskorišten i loot nije duplan), **Retry**, **To Camp**. **Završio:** „Run Complete!" (zeleno), „Full rewards — Pip reached the finish!", Double Loot, Retry, To Camp. Statusi: „Loading rewarded ad…", „Loot doubled!", „Could not double loot.", „Revive not available.", „Ad not available — try again later.", „Loading…" (interstitial prije Retry). Slike `20`, `21`. | Modal sistema (ili cijeli ekran — tvoja odluka), isti za pad i kraj, razlika naslovom/bojom. **Plijen kao chipovi** (coin + crtež svakog sjemena + broj), kod pada vidljivo „pola" (precrtano 18 → 9 ili ½ — tvoja odluka). Revive i Double Loot = dugmad reklame (ikona video), stanja: dostupno / učitava / gotovo („×2" na chipovima) / nedostupno. Retry i To Camp jasni. Statusi reklame se vide na dugmetu, ne u redu teksta. **Izbaciti:** „Obstacle hit — kept 50%: …" kao rečenica, „Full rewards — Pip reached the finish!", „Run complete. Head to camp or try again!", „(test stub ~1s)". |

### 4.6 Sažetak po vrsti

| Vrsta | Pop-upovi |
|---|---|
| Modal | H3 Poklon · A3 You need more seeds · R3 Pauza · R5 Kraj runa (+ R4 banner) |
| Sheet | H4 Korpa · H5 Nadogradnje · H6 Ormar |
| Oblačić | H1 · H2 · A1 · A2 · R1 |
| Toast | H7 · H8 · X1 · S1 (+ X3 pilula) |
| Leteća poruka | X2 · C1 · R2 (+ A4) |

## 5. Sistem — šta se isporučuje za svaku vrstu

| Komponenta | Šta crtaš |
|---|---|
| `PopupScrim` | boja i alpha (danas `#1A161E` 55 %), isti za hub i run; ulaz/izlaz |
| `PopupModal` | panel (širina, radius, rub, tvrda sjena), zona naslova, zona sadržaja (nagrada / lista), zona dugmadi; varijanta „nagrada" (poklon, kraj runa) i „odluka" (pauza, need more) |
| `PopupSheet` | visina 922 i 1326 (danas), ručka, naslov, Close, skrol sadržaja; povlačenje dolje > 160 px zatvara (kao Ormar) |
| `CoachBubble` | oblačić s repom u 4 smjera i bez repa, max širina, za svijetlu livadu i tamnu traku |
| `Toast` | pilula, jedna linija, opciona ikona, mjesto (Home y 1110 / 1250, ispod headera), red kad ih je više |
| `FloatPop` | „+N" / „−N" s ikonom, let do brojača |
| `PopupButton` | primary · secondary · ad (video ikona) · disabled · loading · done |
| `RewardChip` | coin / sjeme / cvijet (crtež iz igre) + broj; varijanta „pola" i „×2" |

Crteži sjemena i cvijeća dolaze iz igre (`ArenaChipDraw.draw_flower`, `HomeBasketPickerIcon`, `CampPlantDraw`) — CD ne crta novi art, samo okvir/pločicu.

## 6. Ponašanje koje agent zadržava (CD ne mijenja)

- Svi uslovi kad se pop-up pojavi (tabela §4) i šta dugmad rade.
- Poklon: 8 coina + 3 sjemenke nasumičnog otključanog tipa, jednom dnevno, samo poslije tutorijala.
- Korpa: zaključana do prvog merge-a u Areni; jedan izabran tip; „Clear" briše izbor.
- Nadogradnje: 2 cvijeta ★1 po nivou, max 4, cvijet bira igra.
- „You need more seeds!": samo kad nijedan tip nema 4; jedini izlaz je dugme (vodi u Camp).
- Pauza: „Quit" = run pada, čuva se pola (isti tok kao pad).
- Kraj runa: Revive najviše jednom po runu, samo kod pada i prije Double Loot; Double Loot jednom; Retry može pokazati interstitial.
- **Bug A3** (lista na jedan red) agent popravlja pri prenosu.
- Ako CD predloži novu informaciju (npr. vrijeme do sljedećeg poklona), agent je dodaje samo ako je to čisti prikaz postojećih podataka; svaka promjena pravila ide prvo korisniku.

## 7. Danas u igri (orijentacija, ne obaveza)

### 7.1 Mjere i tokeni

| Šta | Vrijednost | Izvor |
|---|---|---|
| Scrim (Home, Ormar) | `#1A161E` 55 % | `ui_home_field.gd SCRIM`, `ui_wardrobe.gd` |
| Sheet | 1080 široko, 1326 (korpa, Ormar) / 922 (nadogradnje), Close 132 visok | `UiHomeField.SHEET_*` |
| Poklon | panel 400 × 320 centriran | `main_menu.tscn RewardPanel` |
| Need more | panel centriran, naslov 58, tijelo 38, red 108 (cvijet 72, ime 40, broj 44) | `merge_arena_controller.gd`, `arena_need_row.gd` |
| Arena oblačić | 40 px, max 760, dno 330 od dna polja, krem `#FFF8F0` | `arena_cue.gd`, `UiArena.cue_style()` |
| Pauza | 900 × 680 na 18 %, dugmad 140 | `run_controller.gd _layout_pause_panel` |
| Finish banner | 760 × 220 na 36 % | `_layout_finish_banner` |
| Loot | panel 680 × 720, dugmad 72 (!) | `loot_screen.tscn` |
| Toast Home | tamna `#2D3436`, 600 × 100 na y 1250 (sezona) / y 1110 (Ormar), 44/900 krem | `UiHomeV3.TOAST_*`, `UiWardrobe.TOAST_*` |
| Settings toast | 36 px, 24 ispod headera, 1,6 s | `UiChrome.toast_style()` |
| Font | Nunito (`UiStage.font(weight, size)`) | `ui_stage.gd` |
| Boje | krem `#FFF8F0`, ink `#2D3436`, peach `#FFB88C`, mint `#A8E6CF`, lavanda `#D4A5FF`, coin `#E8C44A`, roze `#FFCCD5`, hub plum `#2A2233`, pergament Shopa `#FBEDD7` | `ui_palette.gd`, `ui_shop_v2.gd`, `ui_chrome.gd` |

### 7.2 Slike iz igre (`docs/04-experience/design-drafts/popups-ref/`)

Snimljene skriptom `game/scripts/dev/popups_capture.gd` (ista skripta snima i poslije prenosa — poređenje).

| Fajl | ID | Šta je |
|---|---|---|
| `01_home_first_run_hint.jpg` | H1 | hint oko Play na prvom startu |
| `02_field_basket_locked_hint.jpg` | H2 | korpa zaključana — traka preko Pipa |
| `03_gift_claimed.jpg`, `04_gift_come_back.jpg` | H3 | poklon dobijen / sutra opet |
| `05_basket_picker.jpg` | H4 | izbor sjemena za korpu (22 px) |
| `06_upgrades_sheet.jpg` | H5 | nadogradnje Magnet / Loot Boost |
| `07_wardrobe_sheet_reference.jpg` | H6 | Ormar (raspored ostaje) |
| `08_wardrobe_apply_toast.jpg` | H7 | toast poslije Ormara |
| `09_home_unlocked_toast.jpg` | H8 | „Unlocked" |
| `10_settings_toast.jpg` | X1 | „Settings coming soon." |
| `11_shop_coin_pop_and_toast.jpg` | X2, S1 | „−150" ispod coin chipa + Shop toast |
| `12_camp_trade_gain.jpg` | C1 | „+12" na Trade |
| `13_arena_tutorial_cue.jpg` | A1 | tutorial oblačić iznad korpe |
| `14_arena_muncher_cue_and_nav_lock.jpg` | A2, X3 | muncher poruka + „Round in progress" |
| `15_arena_need_more_seeds.jpg` | A3 | „You need more seeds!" — vidi se 1 od 5 tipova (bug) |
| `16_arena_coin_earn_pop.jpg` | X2 | „+2" ispod coin chipa |
| `17_run_tutorial_cue_and_pickup.jpg` | R1, R2 | „Coins for the shop!" + „Daisy" |
| `18_run_pause.jpg` | R3 | pauza |
| `19_run_finish_banner.jpg` | R4 | „Time!" |
| `20_loot_run_failed.jpg` | R5 | kraj runa — pao (Double Loot, Revive, Retry, To Camp) |
| `21_loot_run_complete.jpg` | R5 | kraj runa — završio |

## 8. Paleta i tehnika

Postojeći tokeni: `ui_palette.gd`, `ui_home_field.gd`, `ui_home_v3.gd`, `ui_wardrobe.gd`, `ui_shop_v2.gd`, `ui_run.gd`, `ui_arena_v2.gd`, `ui_chrome.gd`. Nova boja samo kao svjetlija ili tamnija varijanta postojeće, označena u README.

Godot 4.7, OpenGL, slabiji Android. Artboard 1080 × 1920, sve u px te baze. Paneli = ravna boja, radius, rub, jedna tvrda sjena. **Bez blura, glowa i gradijenata** (scrim je ravna boja s alfom). Animacije su tweenovi (skala, pozicija, alpha, boja). Najviše jedan loop na ekranu. Tekst ≥ 34 px (naslov pop-upa ≥ 52, dugme ≥ 44), dodir ≥ 120 px, kontrast teksta ≥ 4,5 : 1 i na livadi i na tamnoj traci runa. Nove ikone kao SVG u stilu chrome v2 (`game/assets/ui/chrome/`): npr. video (reklama), katanac, ½. Novi asseti ukupno ≤ 120 KB, bez PNG pozadina.

## 9. Isporuka

### 9.1 Stanja

1. **Sistem**: scrim, modal (nagrada + odluka), sheet (922 + 1326), oblačić (4 smjera + bez repa, svijetlo + tamno), toast, leteća poruka (+ i −), sva dugmad i `RewardChip`.
2. **H1, H2** na Homeu (prvi start, korpa zaključana).
3. **H3 Poklon**: dobijen (8 coina + 3 sjemenke), dobijen kad je korpa skoro puna (manje sjemenki), već otvoren danas.
4. **H4 Korpa**: ništa izabrano, jedno izabrano, dio zaključan; sezona sa 6 tipova.
5. **H5 Nadogradnje**: obje mogu, jedna fali N, jedna na max, trenutak kupovine.
6. **H6 Ormar** u sistemu (samo zaglavlje/scrim/Close) i **H7, H8, X1, S1** toastovi.
7. **X2, C1, R2** leteće poruke; **X3** pilula.
8. **A1, A2** oblačići na Country Bloom (svijetla) i Moonlit Warren (tamna).
9. **A3** s 5 tipova u korpi (svi vidljivi) i s 1 tipom.
10. **R1** oblačić u runu, **R3** pauza, **R4** kraj vremena (+ pad ako ga predložiš).
11. **R5** kraj runa: pao (sva 4 dugmeta), pao bez reklama (tutorial / reklama nedostupna), završio, učitava reklamu, loot duplan (×2 na chipovima), mnogo tipova sjemena (6+ chipova).

### 9.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_popups/
  README.md                 šta otvoriti · § Odlučeno (vrsta svakog pop-upa, scrim, kontekst run)
                            · § Šta se briše (svaki tekst koji ide van) · § Sistem
                            · § Popis (svih 21 ID iz §4 → komponenta + stanja) · § Samoprovjera
                            · § Ideje van zadatka
  design/
    PopupsScreen.dc.html    prop zone (home|hub|shop|camp|arena|run), popup (ID iz §4),
                            state (stanja §9.1), season (za livadu)
    Popup Specs.dc.html     anatomija svake vrste, dugmad, RewardChip, animacije, prije → poslije
                            za svaki ID
    support.js · icons/
  godot/
    popups_export.json      meta · tokens · components · popups (po ID) · states · animations ·
                            strings_en · godot_map · decisions
    ui_popups.gd            konstante; isti nazivi gdje postoje u ui_home_field.gd / ui_wardrobe.gd
    popups_tree.txt         stablo čvorova po komponenti + red prenosa
```

**Imena slojeva:** `PopupScrim`, `PopupModal`, `PopupSheet`, `SheetHandle`, `CoachBubble`, `CoachTail`, `Toast`, `FloatPop`, `PopupButton`, `RewardChip`, `GiftModal`, `BasketSheet`, `SeedTile`, `UpgradesSheet`, `UpgradeCard`, `NeedSeedsModal`, `NeedSeedTile`, `PauseModal`, `FinishBanner`, `RunEndModal`, `AdButton`.

### 9.3 Samoprovjera (u README, svaka stavka da/ne, provjereno u browseru)

1. Svih 21 pop-upa iz §4 (H1–H8, X1–X3, S1, C1, A1–A4, R1–R5) je nacrtano u novom sistemu; nijedan nije ostao u starom izgledu.
2. Svaki pop-up pripada tačno jednoj od pet vrsta, i vrste se razlikuju oblikom.
3. Poklon i kraj runa pokazuju nagradu crtežom + brojem, ne rečenicom.
4. „You need more seeds!" pokazuje sve tipove iz korpe (test s 5 tipova).
5. Double Loot i Revive su jasno reklame (ikona), nisu veći od Retry / To Camp; bez reklame ekran i dalje ima smisla.
6. Pauza jasno kaže da izlazak čuva pola.
7. Nijedan tekst iz §4 označen „izbaciti" se ne pojavljuje.
8. Tekst ≥ 34 (naslov ≥ 52, dugme ≥ 44), dodir ≥ 120, kontrast ≥ 4,5 : 1 na livadi i na tamnoj traci runa.
9. Nigdje blur, glow ni gradijent; najviše jedan loop; hub header/footer i HUD runa nepromijenjeni.

## 10. Ne tražimo

- Hub header i footer (chrome v2) osim stila pilule X3, HUD runa, Shop kartice, Arena v2 efekte (combo, MergeHintMark), raspored Ormara.
- Nove mehanike, iznose, nagrade, nove pop-upove koji danas ne postoje (osim opcionalnog banera pada, R4).
- Ekran postavki (Settings) — ostaje toast „coming soon".
- Novi art cvijeća, sjemena ili Pipa.
- Više varijanti — jedan dizajn.

## 11. Pillar 2 i scope

- M8 launch: redizajn postojećeg UI-ja, bez nove funkcije — u scopeu (`scope-i-granice.md`, M8 → Launch IN lista; UX/flow: loot ekran ×2 rewarded, revive max 1/run, kamp, shop).
- **Reklame** ostaju opcionalne i nikad primarne; revive 1/run; nema interstitiala osim postojećeg opcionalnog prije Retry.
- Nijedan pop-up ne prodaje i ne vodi u Shop. „You need more seeds!" vodi samo u Camp.

## 12. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je REDIZAJN SVIH POP-UPOVA u igri kao JEDNOG SISTEMA. Mehanika, iznosi
i uslovi ostaju — mijenja se izgled, količina teksta i kako se nagrada vidi.
Nijedan pop-up ne smije ostati u starom izgledu.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/popups-cd-brief.md
    -> §2 (fiksno), §3 (šta se traži), §4 (POPIS svih 21 pop-upa:
       danas -> traži se), §5 (komponente sistema), §6 (ponašanje koje
       ostaje), §7 (mjere + slike), §8 (tehnika), §9 (isporuka)
  docs/04-experience/design-drafts/popups-ref/          (21 slika iz igre)
  design_handoff_wardrobe/                               (sheet, toast — najnoviji)
  design_handoff_shop_v2/                                (dugme, toast, tokeni)
  design_handoff_home_v3/, design_handoff_home_field_v2/ (Home, korpa, nadogradnje)
  design_handoff_arena_v2/                               (Arena, korpa, livade)
  design_handoff_run/                                    (run HUD, tamna traka)
  design_handoff_hub_chrome_v2/                          (header/footer — NE diraj)
  game/scripts/ui/main_menu.gd, loot_screen.gd, home_stage_hint.gd,
    wardrobe_sheet.gd, season_stage.gd                   (Home pop-upovi)
  game/scenes/main_menu.tscn, game/scenes/ui/loot_screen.tscn,
    game/scenes/run/run_scene.tscn, game/scenes/camp/merge_arena.tscn
  game/scripts/camp/arena_cue.gd, arena_need_row.gd, merge_arena_controller.gd
  game/scripts/run/run_controller.gd, game/scripts/ui/run_pickup_feed.gd
  game/scripts/visual/ui_home_field.gd, ui_wardrobe.gd, ui_shop_v2.gd, ui_run.gd

ŠTA TRAŽIM:

1. SISTEM OD PET VRSTA: Modal (centriran, scrim, odluka ili nagrada),
   Sheet (odozdo, scrim, lista), Oblačić (pokazuje na nešto, bez scrima),
   Toast (kratka potvrda, sam nestaje), Leteća poruka (+N / -N do
   brojača). Plus jedna porodica dugmadi (primary, secondary, reklama s
   video ikonom, disabled, loading) i RewardChip (coin / sjeme / cvijet +
   broj). Mora raditi i na svijetlim livadama huba i na tamnoj traci runa.

2. SVAKI POP-UP IZ §4 NACRTAN U SISTEMU — svih 21:
   HOME: hint prvog starta (Play), korpa zaključana, POKLON (Gift: dobijen
   / korpa skoro puna / sutra opet), IZBOR SJEMENA ZA KORPU (Choose basket
   seed — danas tekst 22 px!), NADOGRADNJE (Boost: Magnet, Loot Boost),
   Ormar (raspored ostaje, samo sistem), toastovi "Runs use ...",
   "Unlocked", "Yours".
   HUB / SHOP / CAMP: "Settings coming soon.", coin pop -150 / +2, pilula
   "Round in progress" (isto mjesto), Shop toast, Camp "+12" na Trade.
   ARENA: tutorial oblačić iznad korpe, "Muncher's awake ...",
   "YOU NEED MORE SEEDS!" — ostatak u korpi: svi tipovi moraju biti
   vidljivi (danas se zbog buga vidi samo prvi), svaki s crtežom i
   napretkom do 4, jedno dugme, nikakva ponuda kupovine.
   RUN: tutorial "Coins for the shop!", ime sjemena +1, PAUZA ("quit"
   čuva pola — mora ostati jasno), kraj vremena "Time!", KRAJ RUNA kad
   padnem i kad završim (Run Failed / Run Complete, Double Loot i Revive
   kao reklame, Retry, To Camp, sva stanja reklame na dugmetu).

3. NAGRADA SE VIDI, NE ČITA. Poklon i kraj runa: chipovi (coin + crtež
   sjemena + broj) umjesto "Daily chest: +8 coins and +3 Buttercup Lane
   seeds!" i "+9 Coins / +3 Meadow Clover". Kod pada vidljivo "pola".
   Izbaci sav tekst iz §4 označen "izbaciti".

4. ZATVARANJE (fiksno): sheetovi — scrim, Close, povlačenje dolje,
   Android back. Pauza, kraj runa i "You need more seeds!" — samo
   dugmetom. Toast i leteće poruke nisu dodirljive. Jedan pop-up u isto
   vrijeme, toastovi u red (max 2).

FIKSNO: hub header/footer (chrome v2) i HUD runa se ne diraju; iznosi i
uslovi iz §6; reklame opcionalne i nikad veće od Retry/To Camp, revive
max 1/run; Arena v2 efekti i Shop kartice se ne diraju; Pillar 2 — nijedan
pop-up ne prodaje.

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920,
stranica huba 1080 x 1633 između headera 143 i footera 144, sve u px te
baze. Ravne boje, radius, rub, jedna tvrda sjena. BEZ blura, glowa i
gradijenata. Animacije su tweenovi. Najviše jedan loop. Tekst >= 34 px
(naslov >= 52, dugme >= 44), dodir >= 120, kontrast >= 4,5:1 na livadi i
na tamnoj traci. Novi asseti <= 120 KB, bez PNG pozadina. Crteži sjemena
i cvijeća dolaze iz igre — ne crtaj novi art.

ISPORUKA (§9): novi folder design_handoff_popups/, CIJELI U ZIPU za
preuzimanje u chatu:
  design/PopupsScreen.dc.html (prop zone, popup = ID iz §4, state, season),
  Popup Specs.dc.html (sistem + prije -> poslije za svaki ID),
  support.js, icons/
  godot/popups_export.json, ui_popups.gd, popups_tree.txt
  README.md sa § Odlučeno, § Šta se briše, § Sistem, § Popis (svih 21 ID
  -> komponenta + stanja) i § Samoprovjera (9 stavki iz §9.3, svaka da/ne,
  provjereno u browseru PRIJE nego pošalješ zip).

NE RADI: hub header/footer, HUD runa, Shop kartice, raspored Ormara, nove
mehanike ili nagrade, ekran postavki, novi art, više varijanti. Jedan
dizajn, tvoj izbor, neka bude lijep.
```

## Povezano

- [[../../06-production/CHECKPOINT|CHECKPOINT]] — traka POPUP-01
- [[shop-v2-cd-brief|Shop v2]] — šablon ovog briefa, dugme i toast
- [[wardrobe-cd-brief|Ormar]] — sheet i ApplyToast
- [[home-field-v2-cd-brief|Home polje v2]] — korpa i nadogradnje
- [[run-cd-brief|Run]] — HUD i tamna traka
- [[merge-arena-cd-brief|Arena]] — oblačić, korpa, livade
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
