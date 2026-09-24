---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, hub, header, footer, navigacija, claude-design, mockup]
povezano:
  - journal-cd-brief
  - art-direction
  - pristupacnost
  - spec-vertical-slice
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Hub header (coins·seeds·diamonds·settings) + footer (5 swipe tabova): trenutno stanje iz koda s tačnim mjerama, zahtjevi za univerzalan dizajn na svih 5 stranica, gotov prompt za Claude Design i mapa za prenos CD izlaza u meta_hub.tscn."
---

# Hub header + footer — Claude Design brief i referenca

> **Status: implementirano 2026-09-11** — smjer B (tamni livadski chrome) iz Claude Design handoffa (`design_handoff_hub_chrome/`) prenesen u `meta_hub.tscn`. §2 opisuje stanje **prije** prenosa i ostaje kao zapis; trenutno stanje i odstupanja od handoffa su u [[#Implementacija (2026-09-11)|§ Implementacija]] na kraju.

**"Chrome"** u ovom dokumentu = stalni UI okvir huba: **header** (gornja traka s valutama i Settings dugmetom) + **footer** (donja navigacija s 5 tabova). Oba su fiksna i ista na svih 5 stranica po kojima se swipea: **Shop · Journal · Home · Camp · Arena**.

## 0. Kako koristiti ovaj fajl

Fajl ima tri uloge:

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl kao prilog (§1–§7) | Referenca: trenutni izgled, zahtjevi, paleta, pozadine stranica, ograničenja Godota |
| **Ti** | §8 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §5, §9 | Tačne današnje vrijednosti i mapa "CD sloj → Godot node" za prenos |

Postupak: u CD priloži ovaj `.md` fajl, pa zalijepi prompt iz §8. Ako CD ne prima `.md` prilog, zalijepi cijeli fajl kao prvu poruku, a prompt kao drugu. Kad CD završi, izvezi `.dc.html` (kao kod Journala — vrijednosti su se tada čitale direktno iz izvora) i daj ga agentu.

---

## 1. Kontekst igre (za CD)

- **Merge Meadow** — casual F2P merge/runner hibrid za mobitel, **portrait**.
- Stil: **flat 2D cartoon, pastel, meki outline**, bez pixel-arta, bez 3D, bez retro efekata ([[../art-direction|art-direction]]).
- Meta-hub je **Clash Royale** tip: 5 stranica punog ekrana poredanih horizontalno, prelaz swipeom ili tapom na tab. **Home** je u sredini i default.
- Fair F2P je nepregovarljiv princip ([[../../01-vision/design-pillars|design-pillars]], Pillar 2): monetizacija samo na prirodnim pauzama. Chrome ne smije gurati kupovinu.

---

## 2. Trenutni raspored (uvod u dizajn)

Scena: `game/scenes/meta/meta_hub.tscn` · skripta: `game/scripts/meta/meta_hub_controller.gd` · swipe: `game/scripts/ui/swipe_pager.gd`

Ekran je vertikalni stack od tri reda. **Header i footer nisu preko stranice — stranica je između njih.** Swipe pomjera samo srednji dio; header i footer stoje.

```
 1080 px
┌──────────────────────────────────────────────┐ ← safe area (notch) + 8 px
│ ╭──────────────────────────────────────────╮ │
│ │ [●  1250] [♣   34 ] [◆   2  ] [ prazno  ]│ │ HEADER  ~84 px
│ ╰──────────────────────────────────────────╯ │ (TopBar)
├──────────────────────────────────────────────┤
│                                              │
│                                              │
│            STRANICA  (SwipePager)            │ ← jedini dio koji se swipea
│                                              │   svaka stranica ima svoju
│    Shop · Journal · [Home] · Camp · Arena    │   pozadinu (§4)
│                                              │
│                                              │
├──────────────────────────────────────────────┤
│ [ Shop ][Journal][▓HOME▓][ Camp ][ Arena ]   │ FOOTER  ~80 px
└──────────────────────────────────────────────┘ ← safe area (gesture bar) + 6 px
  ● coin  ♣ seed  ◆ diamond   ▓ = aktivan tab (peach)
```

Iza cijelog huba je tamna pozadina `#1F2B24` — vidi se kao tanka traka kroz margine oko headera i footera.

### 2.1 Header danas — `RootVBox/TopBar`

| Element | Vrijednost danas |
|---------|------------------|
| Vanjski razmak | L/R 8 px, gore 8 px (+ safe area), dolje 4 px |
| Panel | `#FFF8F0` @ 94 %, radius 16, border 2 px `#2D3436` @ 12 %, padding 12 horizontalno / 10 vertikalno |
| Raspored | red, razmak 8 px, **4 jednako široka slota** (~254 px): Coin · Seed · Diamond · **prazan Spacer** |
| Prazan slot | ostatak nakon što je Settings premješten na Home (Bug-022) — četvrtina headera je prazna |
| Coin chip | peach `#FFB88C` @ 85 % |
| Seed chip | mint `#A8E6CF` @ 85 % |
| Diamond chip | tirkizna `#8CE0EB` @ 85 % (nije u paleti) |
| Oblik chipa | radius 12, border 2 px `#2D3436` @ 10 %, padding lijevo 10 · gore 6 · desno 12 · dolje 6 |
| Ikona | 28×28 px — coin `assets/pickups/coin.png`, seed `assets/pickups/seed.png`, diamond = **proceduralni placeholder** (tirkizni romb 32×32 crtan u kodu) |
| Broj | 28 px, `#4A4A4A`, bez teksta ("bez riječi"), sirovi broj bez separatora (`12450`), nikad se ne reže |
| Interakcija | chipovi **nisu klikabilni** |
| Izvor podataka | coins = `wallet_coins`, seeds = `sum_seed_bag_only()` (ukupno sjemenki u vreći), diamonds = `get_diamonds()` (rijedak drop, ~1/300 seed pickupa); osvježava se na svaku promjenu stranice |

**Settings dugme danas nije u headeru.** Nalazi se samo na Home stranici, gore desno: 64×64 px, varijanta `subtle` (warm white), Kenney ikona `assets/ui/kenney/icon_settings.png` tintana u `#2D3436`, 24 px od ruba. Handler je placeholder (puni Settings ekran = D0-P). Camp ima svoje Settings dugme, ali je u hubu sakriveno.

### 2.2 Footer danas — `RootVBox/PageIndicator/NavPanel`

| Element | Vrijednost danas |
|---------|------------------|
| Vanjski razmak | L/R 8 px, dolje 6 px (+ safe area), min. visina 56 px |
| Panel | `#FFF8F0` @ 94 %, **samo gornji border** 2 px `#2D3436` @ 10 %, **bez zaobljenja** (header je zaobljen, footer nije), padding lijevo 12 · gore 10 · desno 12 · dolje 12 |
| Tabovi | 5 jednako širokih dugmadi (~200 px), razmak 6 px, **samo tekst, bez ikona** |
| Tekst taba | 19 px (17 + 2 px readability bump), `#4A4A4A` |
| Neaktivan tab | varijanta `subtle`: `#FFF8F0`, radius 12, border 2 px @ 14 %; hover `#FFFDF9`, pritisnut `#F5EDE0` |
| Aktivan tab | varijanta `primary`: peach `#FFB88C` (hover +7 % svjetlije, pritisnut −7 %) — **jedina razlika je boja ispune** |
| Zaključano | svi tabovi na 45 % opacity + swipe isključen — tokom aktivne Arena merge sesije i na Loot ekranu |
| Visina | ~80 px + safe area |

### 2.3 Ponašanje koje se čuva

- Redoslijed je fiksan: `0 Shop · 1 Journal · 2 Home · 3 Camp · 4 Arena` (`meta_hub_pages.gd`). Home je centar i default.
- Swipe: horizontalno, uvijek "sjedne" na punu stranicu (0.28 s, cubic ease-out). Prag: 18 % širine ili 320 px/s. Na krajevima (Shop, Arena) gumeni otpor (35 %).
- Swipe radi samo u zoni stranice. Header i footer se ne pomjeraju.
- Tap na tab → animirani prelaz na tu stranicu.
- Aktivni tab se mijenja tek kad stranica sjedne (nakon puštanja prsta). Tokom povlačenja ništa ne prati prst.
- Stranice imaju vlastite stare trake (Back, ResourceBar, Settings) koje se u hubu sakrivaju. Novi dizajn ih ne treba uzimati u obzir.

### 2.4 Šta danas ne štima (zapažanja iz koda, nisu odluke)

1. **Kontrast prema stranicama.** Chrome je warm white — skoro ista boja kao Journal (`#FFF8F0`, 1.0:1), Shop (`#B8E0F5`, ~1.3:1) i otvoreno Home polje (`#E6F2DB`, ~1.1:1). Od njih ga odvaja samo 8 px tamne hub trake. Na Camp/Arena (tamne) kontrast je ~10:1. Isti chrome izgleda potpuno drugačije od stranice do stranice.
2. **Prazna četvrtina headera** (Spacer koji je ostao od Settingsa).
3. **Header i footer ne dijele isti oblik:** header je zaobljena "pilula", footer ravna traka bez zaobljenja.
4. **Aktivan tab se razlikuje samo bojom** — nema oblika, veličine, ikone ni indikatora. Slabo za colorblind i za "na prvi pogled".
5. **Premalo za prst i oko.** Baza je 1080 px širine, pa je na test uređaju (Pixel 4, gustina 2.75) 1 dp ≈ 2.75 px. Tab je visok ~47 px (≈ 17 dp), tekst taba 19 px (≈ 7 sp), Settings 64 px (≈ 23 dp). Minimum iz [[../pristupacnost|pristupačnosti]] je 44 pt ≈ **120 px** za dodir i 14 pt ≈ **38 px** za tekst.
6. **Boje chipova nisu vezane za valutu:** coin chip je peach umjesto coin gold `#FFD56B`, diamond chip `#8CE0EB` nije u paleti, a diamond ikona je placeholder.
7. **Brojevi bez formatiranja** — `124500` bez separatora, nema plana za 6+ cifara.
8. **Journal "novo" signal je nevidljiv.** `GameState.count_collection_journal_news()` postoji, ali ga nijedan tab ne prikazuje (jedini badge je na Camp stranici i u hubu je sakriven).
9. **Zaključano stanje** (Arena sesija) = sve prigušeno na 45 %. Igrač ne vidi zašto navigacija ne radi.

---

## 3. Zahtjevi za novi dizajn

Trenutni izgled je **polazna tačka, ne šablon** — CD ima slobodu u obliku, rasporedu, detaljima i animacijama, dok god poštuje ovo:

### 3.1 Header

- **Sadržaj, ni više ni manje:** 3 chipa valuta (Coins, Seeds, Diamonds — svaki ikona + broj) + **Settings** dugme (samo ikona).
- **Settings ide u header.** Ovo je nova odluka vlasnika projekta (2026-09-10). U kodu je Settings još uvijek na Home stranici; u header prelazi tek pri prenosu ovog dizajna u igru, a tada se Settings dugme s Home stranice uklanja. Poništava Bug-022 tačku 3 ("Settings: makni iz hub TopBar → Home"). **Za CD: dizajniraj header sa Settings dugmetom kao da je već tamo.**
- Settings na **desnom rubu**. Valute redom coin → seed → diamond (CD smije predložiti drugi redoslijed uz obrazloženje).
- Broj do **6 cifara** se nikad ne reže. CD predlaže jedan default format: separator (`12,450`) ili kompakt od 5+ cifara (`12.4K`).
- Chipovi i dalje **nisu dugmad** po defaultu. Opcija za razmatranje (ne default): tap na coin/diamond chip → skok na Shop tab.
- **Bez** "+" dugmadi, pulsiranja, "SALE" oznaka i sličnog na valutama — Pillar 2.
- Opcionalno: kratka animacija kad se broj promijeni (pop / count-up) — izvodljivo tweenom.

### 3.2 Footer

- **5 tabova, fiksni redoslijed**, Home u sredini.
- **Imena svih 5 sekcija uvijek vidljiva** — ne samo aktivna.
- Aktivna sekcija naglašena na **više od jednog načina** (npr. boja + oblik/veličina/podignutost/indikator) — mora biti jasna i u grayscale-u.
- Opcionalno **ikona iznad imena** — CD dizajnira 5 jednostavnih ikona (Shop, Journal, Home, Camp, Arena). Danas postoje samo Kenney ikone `home`, `settings`, `wallet`, `retry`, `revive`, `double`.
- **Badge slot** na tabu (tačka ili mali broj), generički. U mockupu ga pokaži samo na Journalu ("nova otkrića"); kasnije može služiti i drugim tabovima.
- **Zaključano stanje** — jasno da je navigacija privremeno zaključana (npr. mala ikona katanca ili traka), ne samo prigušeno.
- Opcionalno: **indikator koji prati prst** tokom swipea. Izvodljivo — pager zna pomak u realnom vremenu.

### 3.3 Univerzalnost i kontrast

- **Isti header i footer na svih 5 stranica** — chrome ne mijenja boju po stranici.
- Mora se jasno odvojiti i od **svijetlih** (Journal, Shop, Home polje) i od **tamnih** (Camp, Arena, Home karusel) pozadina: rub prema stranici ≥ 3:1 **ili** jasna sjena/outline.
- Tekst i brojevi ≥ **4.5:1** prema svojoj neposrednoj podlozi (chip, tab).
- Header i footer govore **istim vizuelnim jezikom** (isti radius, border, sjena, površina).

---

## 4. Stranice ispod chroma — pozadine i kontrast

| Stranica | Pozadina | Hex | Kontrast prema današnjem chromu `#FFF8F0` |
|----------|----------|-----|-------------------------------------------|
| Hub (iza svega, vidi se kroz margine) | tamna livada | `#1F2B24` | ~14:1 |
| **Shop** | soft sky | `#B8E0F5` | **~1.3:1** |
| **Journal** | warm white | `#FFF8F0` | **1.0:1** |
| **Home** — sezonski karusel | tamna livada | `#243329` | ~12.6:1 |
| **Home** — otvoreno sezonsko polje | tint po sezoni (tabela ispod) | `#E6F2DB` … | **~1.1–1.7:1** |
| **Camp** | tamna livada | `#2E4733` | ~9.7:1 |
| **Arena** | tamna livada | `#293D2E` | ~11:1 |

**Home polje po sezoni** (`SeasonTheme.home_field_tint`, vrijednosti >1 u kodu se na prikazu klampaju — hex je približan):

| Sezona | Hex | | Sezona | Hex |
|--------|-----|-|--------|-----|
| Country Bloom | `#E6F2DB` | | Moonlit Warren | `#B8BDFF` |
| Frost Orchard | `#D1E6FF` | | Coral Tide | `#FFE0D6` |
| Lantern Meadow | `#EBD6FF` | | Starfall Glade | `#DBCCFF` |
| Amber Canopy | `#FFEBC7` | | Ember Fen | `#FFC79E` |

**Šta je odmah ispod headera** (da se chrome ne sudari s tim):

| Stranica | Prvi element ispod headera |
|----------|----------------------------|
| Shop | naslov "Shop", 34 px, `#4A4A4A` |
| Journal | "Bloom Album" wordmark (PNG, ~100 px visok) |
| Home | Settings dugme gore desno (seli se u header) + sezonski sadržaj |
| Camp | odmah kartice sadržaja, bez naslova |
| Arena | naslov "Merge Arena", 28 px |

---

## 5. Paleta i UI tokeni

**Paleta** — [[../art-direction|art-direction]] + `game/scripts/visual/ui_palette.gd`. CD koristi ove vrijednosti. Nove nijanse samo kao svjetlija/tamnija varijanta postojećih, i jasno označene.

| Uloga | Hex | Napomena |
|-------|-----|----------|
| Primary — mint | `#A8E6CF` | seed chip danas |
| Secondary — lavanda | `#D4A5FF` | |
| Accent / CTA — peach | `#FFB88C` | aktivan tab + coin chip danas |
| Coin gold | `#FFD56B` | boja novčića (art direction) |
| UI gold | `#E8C44A` | "gold" dugmad, s tamnim tekstom `#1A1A14` |
| Warm white | `#FFF8F0` | chrome danas, Journal pozadina |
| Soft sky | `#B8E0F5` | Shop pozadina, nebo u runu |
| Pastel yellow | `#FFEAA7` | |
| Pastel pink | `#FFCCD5` | |
| Price bg | `#FFE8B8` | |
| UI tekst — soft charcoal | `#4A4A4A` | 8.4:1 na warm white, 5.3:1 na peach, 6.3:1 na mint |
| Outline — deep charcoal | `#2D3436` | border (10–14 % opacity), tint ikona |
| Tamne livadske (de-facto pozadine) | `#1F2B24` `#243329` `#293D2E` `#2E4733` | nisu u zvaničnoj paleti, ali su pozadina Camp/Arena/Home/huba |

**Tokeni** (vrijednosti u px baze 1080×1920):

| Token | Vrijednost |
|-------|------------|
| Radius | 12 (dugme/chip) · 16 (header panel) · 20 (veliki panel) · 26 (Journal kartica) |
| Border | 2 px, `#2D3436` @ 10–14 % |
| Sjena | jedna drop sjena, offset (0, 4), veličina 4, `#2D3436` @ 10 % |
| Tipografija (`ui_typography.gd`, u kodu +2 px) | naslov ekrana 42 · sekcija 28 · kartica 24 · body 22 · caption 18 · broj 32 · dugme 22 |
| Font | nema custom fonta (Godot default sans). Otvoreno pitanje u art-direction: "rounded sans". CD **smije** predložiti jedan besplatni OFL font (npr. Nunito, Fredoka, Baloo 2) s dobro čitljivim ciframa — opcija, ne obaveza |

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL / gl_compatibility)

**Jeftino za prenijeti 1:1:**

- Panel = ravna boja (+ alpha), svaki ugao zaobljen zasebno, border zasebno po strani, **jedna** drop sjena (boja / veličina / offset), padding — sve je Godot `StyleBoxFlat`.
- Ikone kao **SVG ili PNG** (SVG se importa direktno). Jednobojne ikone se mogu tintati iz koda.
- Tekst s outlineom ili sjenom (Godot Label podržava oboje).
- Tween animacije: scale, pozicija, opacity, boja — npr. indikator koji klizi ispod taba, pop broja.
- 9-slice PNG za posebne oblike panela — moguće, ali skuplje. Samo ako se isplati.

**Izbjegavati:**

- Backdrop blur / frosted glass (nema jeftino u OpenGL modu).
- Gradijente na panelima (u Godotu traže teksturu). Ako CD baš želi gradijent, neka ponudi i ravnu varijantu.
- Više slojeva sjene, inner shadow, blend modove.
- Izreze i maske u obliku trake (npr. "notch" iza aktivnog taba) — mogući samo kao PNG.

**Layout:**

- Baza **1080×1920 px** portrait, stretch `canvas_items`. **Artboard 1080×1920, sve mjere u px te baze** — prenos 1:1. Ako CD ipak radi u manjem okviru (npr. 360×640), neka to jasno napiše (sve ×3).
- Konverzija za mobitel: 1 dp ≈ 2.75 px → dodir 44 pt ≈ **120 px**, tekst 14 pt ≈ **38 px**, ključne brojke 18 pt ≈ **50 px**.
- **Safe area:** kod dodaje razmak iznad headera (notch/status bar, 0–~100 px) i ispod footera (gesture bar, 0–~60 px). Površina chroma treba da se produži u taj razmak, bez "rupe" tamne hub pozadine.
- **Ciljna visina** (bez safe area): header ~120–150 px, footer ~150–190 px. Stranice su scroll-first pa podnose manje prostora nego danas (~164 px chroma ukupno), ali ne mnogo više od ovoga.
- **Preporuka: odvojene trake** (kao danas — stranica između headera i footera). Plutajući chrome *preko* stranice je dozvoljena alternativa samo ako je znatno bolji, jer traži prepravku svih 5 stranica (gornji/donji padding).

---

## 7. Šta tražimo od CD (isporuka)

1. **Spec sheet — HEADER:** anatomija s mjerama, hex bojama, radiusima, borderom, sjenom, fontom.
2. **Spec sheet — FOOTER:** tab neaktivan / aktivan / pritisnut / s badgeom / zaključan.
3. **Šest ekrana 1080×1920** — header + footer iznad: Shop, Journal, Home (karusel, tamno), Home (otvoreno polje, svijetlo), Camp, Arena. Svaki s odgovarajućim aktivnim tabom. **Sadržaj stranica se ne dizajnira** — puna pozadinska boja iz §4 + par sivih zaobljenih placeholder blokova.
4. **Edge case ekran:** brojevi `999,999` i `12.4K`, notch safe area (+90 px gore, +50 px dolje), zaključana navigacija.
5. **Ikone kao SVG:** 5 tab ikona + diamond ikona (+ settings, ako se mijenja stil). Flat, max 2 boje + outline.
6. *(opciono)* **Swipe u toku** — indikator na pola puta između Home i Camp.

**Max 2 smjera**, jedan pored drugog, jasno labelirana (npr. **A:** svijetli chrome s jakim outlineom/sjenom · **B:** tamni livadski chrome sa svijetlim chipovima), uz preporuku CD-a koji je bolji i zašto.

**Imena slojeva** (za mapiranje na Godot node-ove, §9): `Header`, `CoinChip`, `SeedChip`, `DiamondChip`, `SettingsButton`, `Footer`, `Tab_Shop`, `Tab_Journal`, `Tab_Home`, `Tab_Camp`, `Tab_Arena`, `TabBadge`, `ActiveIndicator`.

**Ne tražimo:** sadržaj stranica, naslove stranica, Settings ekran (D0-P, poseban zadatak), run HUD, Loot ekran, nove elemente u headeru (avatar, level, energija, "+" kupovina).

---

## 8. Prompt za Claude Design

> Priloži ovaj fajl u CD, pa kopiraj sve iz bloka ispod.

```
Radim redizajn "chrome"-a mobilne igre: fiksni HEADER (gornja traka) i FOOTER
(donja navigacija) koji su isti na svih 5 swipe stranica meta-huba.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon stil (bez pixel-arta, bez 3D, bez retro efekata).

Uz ovu poruku prilažem fajl "hub-header-footer-cd-brief.md". To je tvoja
referenca: trenutni izgled s tačnim mjerama (§2), zahtjevi (§3), pozadine
svih stranica s kontrastom (§4), paleta i tokeni (§5), tehnička ograničenja
(§6) i isporuka (§7). Pročitaj ga cijelog prije rada — §9 je za kasniji
prenos u Godot i možeš ga preskočiti. Ovaj prompt je sažetak; ako se nešto
razlikuje, važi fajl.

CILJ: jedan univerzalan, dosljedan dizajn headera i footera koji je čitljiv
iznad SVIH 5 stranica — i svijetlih i tamnih — i koji mogu 1:1 prenijeti u
Godot 4. Imaš slobodu u obliku, rasporedu, detaljima i animacijama; trenutni
izgled je polazna tačka, ne šablon.

HEADER — sadržaj (ni više ni manje):
- 3 chipa valuta, svaki ikona + broj: Coins, Seeds, Diamonds
- Settings dugme (samo ikona zupčanika), na desnom rubu
- Brojevi do 6 cifara se nikad ne režu; predloži jedan default format
  (12,450 ili 12.4K)
- Chipovi nisu dugmad. Bez "+" dugmadi, pulsiranja i bilo čega što gura
  kupovinu — igra je striktno Fair F2P.

FOOTER — swipe navigacija:
- 5 tabova, fiksni redoslijed: Shop · Journal · Home · Camp · Arena
  (Home je u sredini i default)
- Imena SVIH 5 sekcija uvijek vidljiva
- Aktivna sekcija naglašena na više od jednog načina (ne samo bojom — npr.
  oblik, veličina, podignutost, indikator), jasna i u grayscale-u
- Smiješ dodati jednostavnu ikonu iznad svakog imena (dizajniraj ih: flat,
  max 2 boje + outline, izvozivo kao SVG)
- Mali badge (tačka ili broj) na tabu — pokaži ga na Journalu ("nova otkrića")
- Stanje "navigacija zaključana" (tokom Arena merge sesije swipe i tabovi
  ne rade) — igrač treba da razumije da je privremeno

KONTRAST — glavni izazov:
Chrome stoji iznad stranica vrlo različitih pozadina:
- svijetle: Journal #FFF8F0, Shop #B8E0F5, Home otvoreno polje #E6F2DB
  (nijansa se mijenja po sezoni, npr. #B8BDFF, #FFC79E)
- tamne: Camp #2E4733, Arena #293D2E, Home karusel #243329,
  hub pozadina #1F2B24
Današnji chrome je warm white #FFF8F0 i skoro nestaje na svijetlim
stranicama. Novi chrome ne mijenja boju po stranici, a mora se jasno
odvojiti od obje grupe (rub prema stranici >= 3:1 ili jasna sjena/outline).
Tekst i brojevi >= 4.5:1 prema svojoj podlozi. Header i footer dijele isti
vizuelni jezik.

PALETA (koristi ove hex vrijednosti; nove nijanse samo kao svjetliju/tamniju
varijantu postojećih i jasno ih označi):
mint #A8E6CF · lavanda #D4A5FF · peach #FFB88C · coin gold #FFD56B ·
UI gold #E8C44A · warm white #FFF8F0 · soft sky #B8E0F5 · pastel yellow
#FFEAA7 · pastel pink #FFCCD5 · UI tekst #4A4A4A · outline #2D3436 ·
tamne livadske #1F2B24 / #243329 / #293D2E / #2E4733
Stil: zaobljeni uglovi (12–20 px), border 2 px u outline boji na 10–14 %
opacity, jedna blaga drop sjena (offset 0,4, niska opacity).

TEHNIČKA OGRANIČENJA (Godot 4, OpenGL):
- Artboard 1080×1920 px; sve mjere u px te baze (prenos 1:1)
- Dodir: tabovi i Settings hit-zona min 120 px (= 44 pt na telefonu)
- Tekst: labele tabova min ~38 px, brojevi u headeru min ~44 px (idealno 50)
- Paneli = ravna boja (+alpha), zaobljeni uglovi, border, JEDNA sjena.
  Bez backdrop blura/frosted glassa, bez gradijenata na panelima, bez
  višeslojnih ili inner sjena, bez blend modova
- Chrome se produžava u safe area (notch gore 0–100 px, gesture bar dolje
  0–60 px) — pokaži izgled s i bez njega
- Ciljna visina bez safe area: header ~120–150 px, footer ~150–190 px
- Header i footer su odvojene trake, stranica je između njih (ne overlay)

ISPORUKA (statični artboardi, jasno labelirani):
1. Spec sheet HEADER — anatomija s mjerama, hex bojama, radiusima, fontom
2. Spec sheet FOOTER — tab neaktivan / aktivan / pritisnut / s badgeom /
   zaključan
3. Šest ekrana 1080×1920: header + footer iznad Shop, Journal, Home
   (karusel, tamno), Home (otvoreno polje, svijetlo), Camp, Arena — svaki
   s odgovarajućim aktivnim tabom. Sadržaj stranica NE dizajniraj: puna
   pozadinska boja + par sivih zaobljenih placeholder blokova.
4. Edge case ekran: brojevi 999,999 i 12.4K; notch safe area; zaključana
   navigacija
5. Ikone kao SVG: 5 tab ikona + diamond ikona (+ settings ako mijenjaš stil)
6. (opciono) swipe u toku — indikator na pola puta između Home i Camp
Pokaži max 2 smjera jedan pored drugog (npr. A: svijetli chrome s jakim
outlineom/sjenom, B: tamni livadski chrome sa svijetlim chipovima) i reci
koji preporučuješ i zašto.

IMENA SLOJEVA (da ih mogu mapirati na Godot node-ove): Header, CoinChip,
SeedChip, DiamondChip, SettingsButton, Footer, Tab_Shop, Tab_Journal,
Tab_Home, Tab_Camp, Tab_Arena, TabBadge, ActiveIndicator.

NE RADI: sadržaj stranica, naslove stranica, Settings ekran, run HUD, nove
elemente u headeru (avatar, level, energija, "+" kupovina). Ideje van
zadatka navedi odvojeno na kraju, ne u glavnom mockupu.
```

---

## 9. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `Header` | `meta_hub.tscn` → `RootVBox/TopBar` + `Panel` (`StyleBoxFlat_chrome`) | Ako chrome ide u safe area: pozadina iza `TopBar` MarginContainera (ili `TopBar` → PanelContainer), da nema tamne trake iznad |
| `CoinChip` / `SeedChip` / `DiamondChip` | `TopBar/Panel/HBox/*Chip` (`StyleBoxFlat_coin/seed/diamond`) | Format broja u `meta_hub_controller.gd` `refresh_top_bar()`; font u `ui_text_layout.gd` `header_chip_count()` |
| Ikone valuta | `pickup_assets.gd` (`get_coin_texture` / `get_seed_texture` / `get_diamond_texture`) | Diamond: zamijeniti proceduralni placeholder SVG-om. Novi asset → `scripts/godot-import.ps1` + commit `.import` (CLAUDE.md § Novi asset) |
| `SettingsButton` | novi `UiClickButton` na mjestu `Spacer` u `TopBar/Panel/HBox` | Ukloniti `SettingsButton` iz `main_menu.tscn`. Usput ažurirati: `main_menu.gd` (`FieldUpgradeStack` se ravna ispod Settingsa, ~l. 325–332), `season_field.gd` (~l. 171, meadow safe rect), `meta_hub_flow_smoke.gd` (l. 195–200 danas provjerava **obrnuto**), `season_meadow_smoke.gd` |
| `Footer` | `RootVBox/PageIndicator/NavPanel` (`StyleBoxFlat_nav`) | Visina: `PageIndicator.custom_minimum_size` |
| `Tab_*` | `meta_hub_controller.gd` `_build_tabs()` + `_update_tab_highlight()` | Danas generički `UiClickButton` (font 17, `subtle`/`primary`). Za ikonu + badge + lock vjerovatno poseban `hub_tab.gd` |
| `ActiveIndicator` (klizni) | `swipe_pager.gd` — `_pages_host.position.x` je live pomak | Treba novi signal, npr. `scroll_progress(f: float)` |
| `TabBadge` (Journal) | `GameState.count_collection_journal_news()` | Refresh u `_on_page_changed` / `refresh_top_bar()`. Stari Camp `collection_badge` (u hubu sakriven) postaje suvišan |
| Zaključano stanje | `set_nav_locked()` → `set_tabs_enabled()` | Danas samo `disabled` (45 % opacity) |
| Labele | `meta_hub_pages.gd` `PAGE_LABELS` | Redoslijed se ne mijenja |
| Boje / tokeni | `ui_palette.gd` | Nove chrome konstante dodati ovdje, ne hardkodirati samo u `.tscn` |

**Gotovo kad (implementacija):**

- [ ] Isti header i footer na svih 5 stranica, čitljiv na svijetlim i tamnim pozadinama (screenshot: svih 5 + Home polje u Country Bloom i Moonlit Warren)
- [ ] Settings samo u headeru; Home bez duplog Settingsa; FieldUpgradeStack i meadow dekor se ne sudaraju s headerom
- [ ] Brojevi do 6 cifara bez rezanja, u dogovorenom formatu
- [ ] Aktivan tab prepoznatljiv i na grayscale screenshotu
- [ ] Hit-zona tabova i Settingsa ≥ 120 px visine
- [ ] Swipe / tap / nav lock ponašanje nepromijenjeno — headless smoke: `swipe_snap_smoke`, `meta_hub_smoke`, `meta_hub_flow_smoke`, `arena_nav_lock_smoke`

---

## Implementacija (2026-09-11)

| Fajl | Uloga |
|------|-------|
| `game/scripts/visual/ui_chrome.gd` | Boje, mjere, stilovi (traka, chip, tab, badge, lock pill, toast), `format_count()` — iz CD `ui_chrome.gd`, dopunjen |
| `game/scripts/ui/hub_pressable.gd` | Zajednička klik-zona (input obrazac kao `UiClickButton`) |
| `game/scripts/ui/hub_tab.gd` | Tab: slot 216×177 hit-zona, tile 196×152, ikona + labela, badge |
| `game/scripts/ui/hub_icon_button.gd` | Settings tile 100×100 u hit-zoni 124×140 |
| `game/scenes/meta/meta_hub.tscn` + `meta_hub_controller.gd` | Header/footer struktura, safe area, nav lock vizual, indikator, Settings toast |
| `game/assets/ui/chrome/*.svg` | 16 ikona iz CD-a (+ `.import`) |
| `game/scripts/dev/hub_chrome_smoke.gd` | Geometrija iz handoffa, ikone, badge, lock, toast |

**Odstupanja od handoff README-a (svjesna):**

1. **Chip ikone bez `modulate = OUTLINE`** — SVG-ovi su već `#2D3436`; `modulate` množi boje pa bi ih zacrnio.
2. **`icon_diamond.svg` samo u headeru** — tamna je silueta; diamond pickup u runu zadržava tirkizni proceduralni dijamant (`pickup_assets.gd` nedirnut).
3. **Settings hit-zona 124 × 140**, ne 140 × 140 — uz chipove od 296 px i razmak 16 px više ne stane; i dalje iznad minimuma od 120 px.
4. **Indikator prati prst bez novog signala** — kontroler svaki frame čita `SwipePager.get_scroll_page()` (novi getter od 3 linije), pa prati i povlačenje i snap tween; snap logika pagera (Bug-027) nije dirana.
5. **Težina fonta 700/800** simulirana `FontVariation.variation_embolden` — default font ima jednu težinu; Nunito nije uveden.
6. **Settings tap** = toast "Settings coming soon." ispod headera (isti placeholder kao ranije na Home) dok ne stigne D0-P Settings ekran.
7. **Aktivan tab se mijenja kad stranica sjedne** (kao prije); tokom swipea klizi samo indikator — prelivanje peach boje između tile-ova iz `HubScreen.dc.html` nije preneseno.

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-11 | Odabran **smjer B** (tamni livadski chrome `#1A241E`) i prenesen u igru. Tap na chip valute → Shop: **ne** (chip je informacija, Pillar 2). |
| 2026-09-10 | Header = Coins · Seeds · Diamonds · **Settings**. Odluka nastala uz ovaj brief; kod se ne dira sad — Settings prelazi s Home stranice u hub header **pri prenosu CD dizajna u igru** (§9). Poništava Bug-022 t. 3. |
| 2026-09-10 | Chrome je **univerzalan** — isti izgled i boja na svih 5 stranica, ne mijenja se po stranici. |

## Otvorena pitanja (nakon CD-a)

- [x] Varijanta A ili B (ili miks)? → **B**, tamni livadski chrome
- [x] Tap na chip valute → Shop? → **ne** (preporuka CD-a, Pillar 2)
- [ ] Custom rounded font — CD predlaže **Nunito** (OFL, 700/800/900) za cijelu igru; Nunito je uveden za Home biranje sezone (HOME-20, `UiStage.font()`), ostatak igre i hub chrome još default font + embolden
- [ ] Badge i za druge tabove (npr. Camp kad je daily spreman)? — `HubTab.set_badge_count()` je generički, spojen je samo Journal
- [x] Ikone tabova: finalne iz CD-a ili placeholder? → finalne SVG iz CD-a
- [ ] Count-up animacija broja u headeru (CD prijedlog: 0,25 s + pop ikone) — nije implementirano

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[journal-cd-brief|journal-cd-brief]] — isti format, prvi uspješan CD → Godot prenos
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — art brief za cvijeće (ikone u chromeu ih ne diraju)
- [[../art-direction|art-direction]] — paleta, stil
- [[../pristupacnost|pristupačnost]] — touch 44 pt, font minimumi
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]] — § 0 Meta Hub
- [[../../06-production/d0-functional-audit|d0-functional-audit]] — Bug-014 (brojevi u headeru), Bug-019 (caption uklonjen), Bug-022 (Settings na Home), Bug-027 (snap)
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci (ovaj dokument ih ne mijenja)
