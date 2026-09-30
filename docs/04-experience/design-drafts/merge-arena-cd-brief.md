---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, arena, merge, claude-design, mockup, feel]
povezano:
  - hub-header-footer-cd-brief
  - seeds-flowers-cd-brief
  - merge-arena-v1.1
  - merge-arena-pest
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Merge Arena (5. stranica huba) — pravila iz koda koja ostaju fiksna, raspored i mjere, gotov prompt za Claude Design i mapa za prenos u Godot. Redizajn 1 (smjer B) je u igri od 2026-09-12; redizajn 2 (§11–§12, 2026-09-30) traži pravog neprijatelja umjesto munchera-smajlija, novu korpu iz koje viri sjeme, osam različitih livada — po jednu za svaku sezonu — i vidljiv combo koji mijenja polje."
---

# Merge Arena — Claude Design brief i referenca

> **Status 2026-09-30: redizajn 2 (muncher, korpa, livada po sezoni, combo) čeka CD** — šalji prompt iz [[#12. Prompt za Claude Design — redizajn 2|§12]]. Zadatak je u [[#11. Redizajn 2 (2026-09-30) — muncher, korpa, livada po sezoni, combo|§11]].

> **Status: implementirano 2026-09-12** — smjer B (sadnica: cream rim + tamni well) iz Claude Design handoffa (`design_handoff_merge_arena/`). §2–§3 opisuju stanje **prije** prenosa i ostaju kao zapis; trenutno stanje i odstupanja su u [[#Implementacija (2026-09-12)|§ Implementacija]] na kraju.

**Merge Arena** je mjesto gdje igrač spaja sjemenke iz runa u cvijeće: T1 + T1 → T2, T2 + T2 → T3 "kristal". To je najtaktilniji ekran u igri — "igračka" koju igrač dira prstom, pa je ovdje osjećaj (feel) jednako važan kao izgled.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl kao prilog (§1–§8) | Pravila koja važe, mjere, trenutno stanje, sloboda i ograničenja |
| **Ti** | §12 (redizajn 2) | Gotov prompt za copy-paste u CD chat |
| ~~Ti~~ | ~~§9~~ | ~~Prompt redizajna 1 — poslan 2026-09-12, ne slati ponovo~~ |
| **Agent (kasnije)** | §3, §5, §10 | Tačne današnje vrijednosti, poznati problemi, mapa "CD sloj → Godot node" |

Postupak: u CD priloži ovaj `.md` fajl, pa zalijepi prompt iz §9. Ako CD projekat nema header/footer iz prošlog zadatka, priloži i `design_handoff_hub_chrome/HubScreen.dc.html` (ili screenshot igre) da CD vidi okvir u koji Arena ulazi. Kad CD završi, izvezi `.dc.html` + asset fajlove i daj ih agentu.

---

## 1. Kontekst (za CD)

- **Merge Meadow** — casual F2P merge/runner hibrid za mobitel, **portrait**. Flat 2D cartoon, pastel, meki outline, bez pixel-arta, bez 3D ([[../art-direction|art-direction]]). Mood: *cozy meadow, vedro, satisfying*.
- **Petlja:** run (lane runner) → skupljaš sjemenke → **seed bag** (max 40) → **Arena**: spajaš T1→T2→T3 → T3 kristali idu u **garden stash** (troše se u Campu za upgrade/exchange) i otključavaju T3 u Journalu.
- Arena je **5. stranica** swipe meta-huba (Shop · Journal · Home · Camp · **Arena**). Nakon runa, ako igrač ima sjemenki, igra ga odvede pravo u Arenu — **najčešći prvi pogled je: polje prazno, vreća puna.**
- Sjemenke dolaze iz **svih sezona** (8 sezona × 6 tipova, ★1–★3) — na polju je mix boja i oblika.
- Fair F2P je nepregovarljiv ([[../../01-vision/design-pillars|design-pillars]], Pillar 2): u Areni nema reklama, kupovine, energije ni tajmera koji stvaraju paniku.

---

## 2. Kako Arena radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled i osjećaj**, ne pravila. Sve u ovom poglavlju važi i poslije redizajna. Izvor: `merge_arena_controller.gd`, `economy/arena.gd`, `arena_pest.gd`, `GameState.ARENA_*`.

### 2.1 Tok runde

1. **Tap na vreću** (dolje u sredini) → sjemenke "iskoče" na polje. Na polju je najviše **30** sjemenki (`ARENA_MAX_CHIPS`).
2. Iz vreće izlaze samo tipovi kojih ima **≥ 4** (4 × T1 → 2 × T2 → 1 × T3, pa svaki izbačeni tip može stići do T3). Izlaze cijele gomile, redom po katalogu, dok se polje ne napuni.
3. **Drag** sjemenke: sve iste (isti tip **i** isti tier) na polju **pulsiraju**; najbliža ista u krugu **182 px** (`ARENA_MAGNET_RADIUS`) se **magnetom** privlači prema prstu.
4. **Pusti** unutar **140 px** (`ARENA_SNAP_DISTANCE`) od iste → **merge**:
   - **T1 + T1 → T2** — ostaje na polju, na sredini između dvije.
   - **T2 + T2 → T3 "kristal"** — **odmah napušta polje** → garden stash (+ Journal T3). T3 nikad ne stoji na polju.
5. **Auto-dopuna:** kad na polju ostane **≤ 12** sjemenki, a u vreći ima što izbaciti, vreća sama izbaci novu turu.
6. **Ostaci ("vacuum"):** kad neki tip na polju više ne može do T3 (manje od 4 T1-ekvivalenta; T2 = 2), njegove sjemenke **same odlete nazad u vreću** i taj tip se ne izbacuje do kraja runde. T2 bez ikakve šanse za par → vraća se kao 2 × T1.
7. **Polje očišćeno:** kad na polju nema nijednog legalnog para → jednokratni "clear" efekt (bljesak + sjemenke poskoče).
8. **Nema šta izbaciti** (nijedan tip u vreći nema ≥ 4) → overlay **"You need more seeds!"** s listom tipova `n/4`.
9. **Done** → sve s polja nazad u vreću (T1 → T1, T2 → 2 × T1), Muncher u gnijezdo, navigacija se otključava, hub ide na Camp stranicu. **Done je jedini izlaz dok traje runda.**

### 2.2 Muncher (štetočina) — [[../../02-design/merge-arena-pest|merge-arena-pest]]

| Stanje | Ponašanje | Danas vizuelno |
|--------|-----------|----------------|
| Spava u gnijezdu | Na vrhu polja, u sredini, dok nema sjemenki | tamnija ljubičasta, zatvorene oči |
| Budi se | 0,3 s nakon izbacivanja | otvorene oči |
| Lovi | Ide ka najbližoj T1/T2 (malo preferira T2), **85 px/s**, cilj preračunava svakih 0,25 s | ljubičasti krug, bob |
| Jede | Kad je ≤ 36 px od sjemenke, jede je **0,5 s** → sjemenka nestaje | roze "usta" |
| Zamrznut | Svaki **T3 merge** ga zamrzne na **2 s** | svijetloplav |
| Spava na mjestu | Polje prazno → zaspi gdje je stao; budi se na sljedeće izbacivanje | zatvorene oči |

Ne jede T3 (nema ih na polju), ne jede iz vreće, ne dira Pipa.

### 2.3 Combo i dnevni zadatak

- **Combo:** svaki merge unutar **1,4 s** od prethodnog povećava brojač. Prikazuje se od **2** (`Combo N`). Na tačno **5** → **+2 coina**, jednom po nizu, najviše **10 coina dnevno**. Niz gasi isticanje vremena ili Done (jedenje ga ne gasi).
- **Dnevni Arena zadatak:** jedan po danu (bira se po datumu): `Merge T2 n/3` · `T3 n/1` · `Combo 5 n/1`. Arena samo **prikazuje napredak**; nagrada ("Arena streak N" badge) se preuzima na Home.

### 2.4 Postojeći "feel" elementi (koriste se kao polazna tačka)

| Element | Danas |
|---------|-------|
| **Pip** (maskota) | 72 × 72 px, gore lijevo na polju; poskoči na combo ≥ 2 i na T3 |
| Pozadina | ravna tamnozelena, sa svakim T3 u rundi postaje bujnija (0→4 T3), reset na Done |
| Pair pulse | zlatni prsten pulsira oko istih sjemenki dok vučeš |
| Clear efekt | topli bijeli bljesak @ 40 % + sve sjemenke 1,0 → 1,12 → 1,0 (0,4 s) |
| Vacuum | sjemenka se smanjuje (→ 0,2) i leti u usta vreće (0,38 s, cubic ease-in, 0,05 s razmak), vreća "punch" 1,14× |
| Vreća | otvorena i "klimava" (wiggle) kad ima ≥ 2 sjemena; iz nje vire 3 tipa koji će izaći |

### 2.5 Hub integracija

- Dok runda traje (sjemenke na polju **ili** Muncher budan), hub navigacija je **zaključana**: swipe i tabovi ne rade, footer dobije zlatni rub i pill **"ROUND IN PROGRESS"** koji izviruje **36 px** u dno Arena stranice (u sredini, ~420 px širok).
- Header (valute + Settings) je iznad Arene i osvježava se uživo (npr. +2 coina od comboa).

### 2.6 Svi tekstovi (EN, dinamični)

| Kad | Tekst |
|-----|-------|
| Prvi put (merge tutorijal) | `Tap bag to pour seeds. Drag matching seeds together.` |
| Prvi put (Muncher) | `Pour seeds — watch the muncher! Merge to T3 to freeze it.` |
| Polje prazno, vreća ≥ 2 | `Tap the bag below — seeds jump into the arena!` |
| Ima mjesta, vreća > 0 | `Tap bag again to pour more (up to 30 on field).` |
| Runda u toku | `Merge T1→T2→T3. T3 crystals go to garden stash.` |
| Nakon izbacivanja | `Poured 12 seeds — drag matching ones together!` |
| Prvo buđenje Munchera | `Muncher woke up — merge fast! T3 merge freezes it 2s.` |
| Merge u T2 | `Merged to T2 — keep merging!` |
| Merge u T3 | `Clover crystal → garden stash! Muncher frozen 2s.` |
| Tap na vreću, polje puno | `Arena full (30/30) — merge some seeds first!` |
| Tap na praznu vreću | `Bag is empty.` / `Nothing to pour.` |
| Nema sjemena, Muncher budan | `Out of seeds — tap Done or pour again when you have more.` |
| Nema sjemena, kraj | `No seeds left — tap Done to return to camp.` |
| Merge hint booster (Shop) | `Hint: merge two Clover seeds.` / `Hint: pour seeds and merge matching pairs.` |
| Overlay | `You need more seeds!` + lista tipova `3/4` |
| Combo | `Combo 2` … `Combo N` |
| Dnevni | `Merge T2 1/3` · `T3 0/1` · `Combo 5 0/1` |

Najduže poruke (~60 znakova, npr. `Paper Lantern Bloom crystal → garden stash! Muncher frozen 2s.`) moraju stati. **CD smije predložiti kraće tekstove** — dostavi tabelu *stari → novi*.

---

## 3. Trenutni raspored (uvod u dizajn)

Scena: `game/scenes/camp/merge_arena.tscn` · skripta: `game/scripts/camp/merge_arena_controller.gd`

```
 1080 px
┌──────────────────────────────────────────────┐
│ [● 12,450] [♣ 340] [◆ 12]              [⚙]  │ HEADER 143 px — zadato, ne mijenja se
╞══════════════════════════════════════════════╡ ─┐
│               Merge Arena        [Combo 3]   │  │ naslov 28 px (+ Combo kad je aktivan)
│   Poured 12 seeds — drag matching ones…      │  │ hint 18 px (mijenja se stalno)
│                Merge T2 1/3                  │  │ dnevni 16 px
│ (Pip)             (Muncher)                  │  │
│                                              │  │
│      ○    ○       ○        ○                 │  │ PLAYFIELD ≈ 1080 × 1425
│   ○       ○   ○       ○                      │  │ sjemenka Ø 134 px, max 30
│       ○       ○   ○       ○                  │  │ ARENA STRANICA 1080 × 1597
│                                              │  │
│                  ┌──────┐                    │  │
│                  │ VREĆA│ 160×130            │  │ 114 px iznad dna polja
│                  └──────┘                    │  │
│ ┌──────────────────────────────────────────┐ │  │
│ │                  Done                    │ │  │ Done 1056 × 56 (peach)
│ └──────────[ 🔒 ROUND IN PROGRESS ]────────┘ │  │ ← pill izviruje 36 px (samo tokom runde)
╞══════════════════════════════════════════════╡ ─┘
│ Shop   Journal   Home   Camp   [Arena]       │ FOOTER 180 px — zadato
└──────────────────────────────────────────────┘
```

Iza svega je tamna livadska pozadina. Header i footer su tamna traka `#1A241E` s 3 px svijetlim rubom.

### 3.1 Elementi danas

| Element | Danas |
|---------|-------|
| Arena stranica | **1080 × 1597 px** (1920 − header 143 − footer 180; bez safe area) |
| Naslov | `Merge Arena`, 28 px, default font, centriran |
| Combo | `Combo N`, 22 px, u redu naslova desno; kad se pojavi, red naraste na 52 px (layout "skoči") |
| Hint (`InfoLabel`) | 18 px, 1–2 reda, tekst iz §2.6 |
| Dnevni (`DailyLabel`) | 16 px, npr. `Merge T2 1/3` |
| Playfield | ≈ **1080 × 1425 px**; centri sjemenki drže 83 px od rubova; dno polja (268 px) rezervisano za vreću |
| Sjemenka | disk **Ø 134,4 px** (radius 67,2): cvijet crtan kodom ili SVG (Country Bloom), tanki tamni prsten @ 35 %; T2 ima natpis `T2` (22 px) ispod diska; min. razmak centara 142,8 px |
| Vreća | 160 × 130 px, dolje u sredini, 114 px iznad dna polja; proceduralna smeđa vreća + broj (22 px); oko nje zona u koju sjemenke ne ulaze (±75 px bočno, 159 px iznad) |
| Muncher | krug **Ø 56 px**, ljubičast, oči-tačke; gnijezdo gore u sredini (nema vizual) |
| Pip | 72 × 72 px, gore lijevo (12, 8) |
| Done | 1056 × 56 px, peach `#FFB88C`, labela 26 px, 8 px iznad dna stranice |
| Overlay | cijela stranica zatamnjena 72 %, panel 84 % × 68 %; naslov `You need more seeds!` (warm white, 28 px) + lista Camp chipova (ikona, ★, ime, `n/4`); **tap bilo gdje = Done → Camp** |

### 3.2 Boje koje Arena danas koristi

| Šta | Hex |
|-----|-----|
| Pozadina — početak runde | `#293D2E` |
| Pozadina — 4+ T3 u rundi | `#335C38` |
| Prsten sjemenke | `#334738` @ 35 % |
| Pair pulse | `#F2D940` (pulsira 45–80 %) |
| Natpis `T2` | `#406147` |
| Muncher budan / spava / zamrznut | `#8C61B8` / `#7A579E` / `#A6D1FA` |
| Vreća (tijelo / tamno / rub) | `#9E7A52` / `#735738` / `#B89466` |
| Broj na vreći | `#FFFAE6` |
| Clear bljesak | `#FFF5D1` @ 40 % |
| Overlay zatamnjenje | `#0F1412` @ 72 % |

### 3.3 Šta danas ne štima (zapažanja iz koda, nisu odluke)

1. **Done je nizak i sad je djelimično pokriven.** 56 px (≈ 20 dp) je ispod minimuma od 120 px, a novi footer pill "ROUND IN PROGRESS" izviruje 36 px baš preko donjeg dijela Done labele — tokom runde, kad je Done jedini izlaz.
2. **Polje se smanjilo.** Novi header/footer (2026-09-11) uzeli su ~160 px visine: polje je palo s ~1582 na ~1425 px, a limit od 30 sjemenki je mjeren na 1582 px. HUD iznad polja mora biti štedljiv.
3. **HUD su tri labave linije teksta** (naslov, hint, dnevni) u default fontu od 16–28 px (≈ 6–10 sp na telefonu) — nečitljivo; hint se stalno mijenja a Combo labela pomjera cijeli red.
4. **Naslov `Merge Arena` duplira** footer tab `Arena`.
5. **Sjemenke se slabo čitaju na tamnoj pozadini:** cvijet stoji na providnom disku s jedva vidljivim prstenom; T1 i T2 se razlikuju samo sitnim natpisom `T2`; T3 se nikad ne vidi na polju — "nagradni trenutak" je samo tekst + blaga promjena pozadine.
6. **Muncher je placeholder** (krug s tačkama, 56 px) — premalen i bez karaktera; gnijezdo nema vizual.
7. **Vreća je proceduralni poligon** s brojem u sitnom fontu.
8. **Pip je sitan u uglu** i jedva se primijeti.
9. **Pozadina je ravna boja**; art-direction dozvoljava flat ilustraciju livade.
10. **Kristal "nestane"** — igrač ne vidi gdje T3 ode ni koliko ih je skupio.
11. **Overlay izlazi na bilo koji tap** — iznenađujuće, nema jasnog dugmeta.
12. **Nema feedbacka za promašaj** (pustio si sjemenku pored pogrešne) osim teksta.

---

## 4. Zahtjevi za redizajn

Trenutni izgled je **polazna tačka, ne šablon.** CD ima slobodu u vizuelnom jeziku, rasporedu, animacijama i feedbacku — dok god poštuje ovo:

### 4.1 MORA

- **Pravila i brojevi iz §2 ostaju.** CD ne mijenja mehaniku, brojeve ni tok runde.
- **Sjemenka ~134 px u prečniku (± 10 %)** — veličina je vezana za snap (140), magnet (182) i limit od 30. Ako CD predloži drugu veličinu, mora to jasno napisati (traži novo balansiranje).
- **Cvijeće unutar sjemenke CD NE crta.** To je posebna ilustracija ([[seeds-flowers-cd-brief|seeds-flowers brief]]): flat pastel cvijeće ~70–80 px, sve boje i 8 sezonskih paleta, 3 tiera. CD dizajnira **kontejner** oko cvijeta (disk, jastučić, grumen zemlje, mahuna…) i on mora dati kontrast **svakoj** boji cvijeta.
- **T1 i T2 moraju se razlikovati i bez boje** (oblik okvira, oznaka, veličina…). ★3 (mythic, najrjeđe po sezoni) smije imati poseban tretman (npr. zlatni rub).
- **Polje mora primiti 30 sjemenki bez preklapanja** na ~1080 × 1425 px (ili više, ako novi HUD uzme manje).
- **Header i footer su zadati** — ne mijenjaju se. Arena živi u **1080 × 1597 px** između njih.
- **Zona pilla:** dno stranice u sredini, ~420 × 40 px — tu tokom runde stoji "ROUND IN PROGRESS" pill. Done i važan tekst ne smiju biti ispod nje (ili predloži gdje pill ide umjesto toga).
- **Done:** hit-zona **≥ 120 px visine**, uvijek dostupan tokom runde (jedini izlaz).
- **Vreća** ostaje u **donjoj trećini, u sredini** (zona palca), hit-zona ≥ 120 px; broj sjemenki u vreći vidljiv.
- **Muncher:** sladak i cozy, ne strašan. Stanja iz §2.2 moraju se razlikovati i bez boje (npr. zamrznut = kocka leda/inje, spava = zzz).
- **Tekst:** labele ≥ 38 px, brojevi ≥ 44 px (≈ 14 / 16 pt na telefonu); EN tekst; poruke iz §2.6 moraju stati.
- **Fair F2P:** bez tajmera, energije, reklama i kupovine u Areni. Combo prozor od 1,4 s je jedini "ritam" — ne pravi od njega odbrojavanje.

### 4.2 SMIJE (sloboda)

- **HUD:** novi raspored hinta, dnevnog zadatka i comboa (npr. kompaktna statusna traka, "pilule", plutajuća poruka) — bez skakanja layouta. Odluči treba li naslov.
- **Sjemenka:** vizuelna metafora, stanje dok se vuče (podizanje, sjena, veća), magnet (npr. "nit" između prsta i partnera), pair pulse stil, merge pop, T2 okvir.
- **T3 trenutak:** kristal bljesne i odleti (npr. do malog brojača stasha u HUD-u) — pokaži kao storyboard.
- **Vreća:** potpuno novi dizajn i animacija izbacivanja (sjemenke "iskaču").
- **Muncher + gnijezdo:** karakter, veličina (danas 56 px — smije veće, npr. 80–100 px), animacije stanja.
- **Pip:** položaj i reakcije (Pip art već postoji — ne redizajniraj lik, samo gdje stoji i kako reaguje).
- **Pozadina:** flat ilustracija livade (1–2 sloja), koja postaje bujnija sa svakim T3 u rundi (0 → 4).
- **Feedback:** "nema para" wobble, polje očišćeno, combo meter, +2 coina od comboa.
- **Overlay "You need more seeds!"** s jasnim dugmetom (npr. "Back to Camp") umjesto "tap bilo gdje".
- **Kraći tekstovi** (tabela stari → novi).

Ideje van ovoga (npr. "Sort by type" dugme, novi mehanizmi) navedi **odvojeno na kraju**, ne u glavnom mockupu.

---

## 5. Paleta i tokeni

**Paleta** — [[../art-direction|art-direction]] + `ui_palette.gd` + hub chrome. Nove nijanse samo kao svjetlija/tamnija varijanta postojećih, jasno označene.

| Uloga | Hex |
|-------|-----|
| Primary — mint | `#A8E6CF` |
| Secondary — lavanda | `#D4A5FF` |
| Accent / CTA — peach | `#FFB88C` |
| Coin gold | `#FFD56B` |
| UI gold | `#E8C44A` |
| Warm white | `#FFF8F0` |
| Soft sky | `#B8E0F5` |
| Pastel yellow | `#FFEAA7` |
| Pastel pink | `#FFCCD5` |
| UI tekst | `#4A4A4A` |
| Outline | `#2D3436` |
| Hub chrome (traka) | `#1A241E` |
| Livada (danas) | `#293D2E` → `#335C38` |
| Rarity pozadine (Journal/Camp) | ★1 `#B8D4F0` · ★2 `#E0C4FF` · ★3 `#FFE8B8` |

**Tokeni:** radius 12 / 20 / 26 · border 2 px outline @ 10–14 % · jedna drop sjena (offset 0,4; niska prozirnost) · outline ~20 % tamniji od fill-a (2–4 px).

**Font:** igra danas koristi default sans (težine 700/800 simulirane). Mockup smije koristiti Nunito kao u header/footer dizajnu — mjere ostaju iste.

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

**Lako za prenijeti:**

- Sjemenka, vreća i Muncher su Godot kontrole koje se crtaju kodom (`_draw`): krug, luk, poligon, linija, tekst i **tekstura** (SVG/PNG). Okvir sjemenke može biti SVG/PNG tekstura ispod cvijeta.
- Animacije = **tween**: skala, pozicija, rotacija, prozirnost, boja; lanci i paralelne animacije; easing (cubic, back, elastic).
- Mali "burst" efekti (nekoliko čestica) na merge / T3 — **ne** stalne čestice na svakoj sjemenci.
- Pozadina polja smije biti **PNG ilustracija** (~1080 × 1600) + promjena nijanse/crossfade za "bujnost".
- Paneli (HUD, Done, overlay) = ravna boja + alpha, zaobljeno, border, jedna sjena (Godot `StyleBoxFlat`).

**Izbjegavati:**

- Blur, glow i bloom shadere; backdrop blur; gradijente na panelima (samo kao PNG ako baš treba).
- Teške čestice — na polju je do **30 sjemenki + Muncher + VFX** odjednom, na slabijem telefonu.
- Efekte koji zavise od preciznog timinga frame-a (fizika je "lite": odbijanje sjemenki je jednostavno).

**Layout:**

- Artboard **1080 × 1920**, sve mjere u px te baze (prenos 1:1). Arena = **1080 × 1597** između headera (143) i footera (180).
- 1 dp ≈ 2,75 px → dodir 44 pt ≈ **120 px**, tekst 14 pt ≈ **38 px**.
- Safe area rješava chrome — Arena je uvijek između headera i footera.

**Referentne animacije danas** (za tabelu kretanja):

| Pokret | Trajanje |
|--------|----------|
| Snap hub stranice | 0,28 s, cubic ease-out |
| Clear efekt | 0,4 s |
| Vacuum let | 0,38 s, cubic ease-in, 0,05 s razmak |
| Vreća punch | 0,08 s gore + 0,12 s dolje |
| Pip reakcija | 0,28 s (1,0 → 1,18 → 1,0) |
| Merge pop (art-direction) | skala 1,0 → 1,3 → 1,0 + čestice u accent boji |

---

## 7. Šta tražimo od CD (isporuka)

**P1 — obavezno:**

1. **Glavni ekran 1080 × 1920** sa headerom/footerom: runda u toku — ~20 sjemenki (mix tipova i sezona, T1 i T2), Muncher lovi, `Combo 3`, dnevni `1/3`, footer zaključan (pill vidljiv).
2. **Prazna Arena** (vreća puna, Muncher spava u gnijezdu) — najčešći prvi pogled nakon runa — i ista scena u **tutorijal** varijanti (prvi put).
3. **Spec sheet sjemenke:** T1, T2, ★3 T1 + stanja: miruje, vuče se, magnet-partner, par pulsira, spajanje, pojeden, leti u vreću.
4. **Vreća:** prazna · 1 sjeme · otvorena (≥ 2, vire 3 tipa) · izbacivanje · punch (sjeme se vratilo).
5. **Muncher + gnijezdo:** svih 6 stanja iz §2.2.
6. **HUD komponente:** hint (kratka + najduža poruka), dnevni zadatak (u toku / završen), combo 2 i combo 5 (+2 coina), T3 poruka, `Arena full`.
7. **Done + zaključano stanje:** kako Done i "ROUND IN PROGRESS" pill stoje zajedno.
8. **Overlay "You need more seeds!"** s listom tipova `n/4` i jasnim izlazom.

**P2 — poželjno:**

9. **Puno polje** (30 sjemenki) — test gustine.
10. **Pozadina:** 0 T3 vs 4 T3 u rundi.
11. **T3 trenutak** kao storyboard (3–4 kadra) + **tabela animacija** (šta, trajanje, easing).
12. **Lista asseta za export** (SVG/PNG: okviri sjemenke, vreća po stanjima, Muncher po stanjima, gnijezdo, pozadina, ikone).

**Max 2 vizuelna smjera**, jedan pored drugog, jasno labelirana, uz preporuku CD-a koji je bolji i zašto.

**Imena slojeva** (za mapiranje na Godot, §10): `ArenaHud`, `HintLine`, `DailyTask`, `ComboMeter`, `Playfield`, `SeedChip_T1`, `SeedChip_T2`, `SeedBag`, `Muncher`, `MuncherNest`, `ArenaPip`, `DoneButton`, `NeedMoreSeedsOverlay`, `T3Burst` (+ `StashCounter` ako ga predložiš).

## 8. Ne tražimo

- Promjenu pravila i brojeva (§2), nove mehanike, monetizaciju.
- Cvijeće (posebna ilustracija) i lik Pipa (postoji).
- Header i footer, druge stranice (Shop, Journal, Home, Camp).
- **Donate / Keep / Basket / Bloom inbox u Areni** — namjerno uklonjeni (FLOW-A); T3 ide direktno u garden stash.

---

## 9. Prompt za Claude Design

> Priloži ovaj fajl u CD, pa kopiraj sve iz bloka ispod.

```
Radim redizajn jednog ekrana mobilne igre: MERGE ARENA — mjesto gdje igrač
spaja sjemenke u cvijeće. Igra: Merge Meadow — casual F2P merge/runner
hibrid, portrait, flat pastel cartoon stil (bez pixel-arta, bez 3D, bez
retro efekata). Mood: cozy livada, vedro, "satisfying".

Uz ovu poruku prilažem fajl "merge-arena-cd-brief.md". To je tvoja
referenca: pravila igre koja važe (§2), svi tekstovi (§2.6), trenutni
raspored s mjerama (§3), šta danas ne štima (§3.3), šta mora a šta smiješ
(§4), paleta (§5), tehnička ograničenja (§6) i isporuka (§7). Pročitaj ga
cijelog prije rada — §10 je za kasniji prenos u Godot i možeš ga preskočiti.
Ovaj prompt je sažetak; ako se nešto razlikuje, važi fajl.

CILJ: Arena treba da izgleda i "osjeća se" kao najzadovoljnija igračka u
igri — sočna, cozy, čitljiva na telefonu — a da je mogu 1:1 prenijeti u
Godot 4. Imaš punu slobodu u vizuelnom jeziku, rasporedu, animacijama i
feedbacku. Pravila i brojevi igre su fiksni: ti dizajniraš izgled i osjećaj,
ne pravila.

KAKO ARENA RADI (detalji u §2):
- Tap na vreću sjemena (dolje u sredini) → sjemenke iskoče na polje (max 30).
- Povučeš sjemenku; iste (isti tip + isti tier) pulsiraju, najbliža se
  magnetom privlači; pustiš blizu → spoje se.
- T1 + T1 → T2 (ostaje na polju). T2 + T2 → T3 "kristal": odmah napušta
  polje i ide u "garden stash" (troši se u Campu) + otključava T3 u Journalu.
- Muncher (mala štetočina) spava na vrhu polja, budi se kad izbaciš
  sjemenke i jede T1/T2; svaki T3 ga zamrzne na 2 s. Lagan pritisak, ne strah.
- Combo: spajanja u razmaku do 1,4 s; prikazuje se od 2, na 5 → +2 coina.
- Dnevni zadatak (jedan dnevno): "Merge T2 n/3", "T3 n/1" ili "Combo 5 n/1".
- Sjemenke koje više ne mogu do T3 same odlete nazad u vreću.
- Dok traje runda, navigacija huba je zaključana; jedini izlaz je DONE.

GDJE ŽIVI: 5. stranica meta-huba. Header (143 px) i footer (180 px) su već
dizajnirani (tamna traka #1A241E sa svijetlim rubom) — prikaži ih kao
zadate, ne mijenjaj ih. Arena ima 1080 × 1597 px između njih. Tokom runde
footer pokazuje pill "ROUND IN PROGRESS" koji izviruje 36 px u dno stranice
(sredina, ~420 px širok) — Done ni važan tekst ne smiju biti ispod njega.

DIZAJNIRAJ (sloboda):
- Raspored i HUD: poruka/hint, dnevni zadatak, combo — kompaktno i bez
  skakanja layouta. Odluči treba li naslov "Merge Arena" (footer već kaže
  "Arena").
- Sjemenku: kontejner oko cvijeta (disk, jastučić, grumen zemlje, mahuna…).
  Stanja: miruje, vuče se, magnet-partner, par pulsira, spajanje, T3
  trenutak, pojedena, leti nazad u vreću.
- Vreću sjemena: prazna, 1 sjeme, otvorena (vire 3 tipa), izbacivanje,
  "punch" kad se sjeme vrati; broj sjemenki vidljiv.
- Munchera + gnijezdo: slatko stvorenje; stanja spava, budi se, lovi, jede,
  zamrznut (ne samo bojom — led/inje), spava na mjestu.
- Pozadinu polja (smije biti flat ilustracija livade) koja postaje bujnija
  sa svakim T3 u rundi (0 → 4).
- Done dugme i overlay "You need more seeds!" (lista tipova n/4 + jasan izlaz).
- Feedback: merge pop, T3 slavlje (npr. kristal odleti do malog brojača),
  "nema para" wobble, polje očišćeno, combo, Pip (maskota, lik već postoji)
  koji reaguje.
- Smiješ predložiti kraće tekstove (EN) — tabela stari → novi.

MORA:
- Sjemenka ~134 px u prečniku (±10 %) — vezana je za mehaniku (snap 140 px,
  magnet 182 px, max 30 na polju). Ako predlažeš drugu veličinu, napiši.
- Cvijeće unutar sjemenke NE crtaš — to je posebna ilustracija (flat pastel
  cvijeće ~70–80 px, sve boje i 8 sezonskih paleta). Kontejner mora dati
  kontrast svakoj boji. T1 i T2 moraju se razlikovati i bez boje.
- Polje mora primiti 30 sjemenki bez preklapanja (~1080 × 1425 px danas) —
  HUD iznad polja neka bude štedljiv.
- Vreća u donjoj trećini, u sredini; hit-zona ≥ 120 px. Done hit-zona
  ≥ 120 px visine, uvijek dostupan tokom runde.
- Tekst ≥ 38 px, brojevi ≥ 44 px; EN tekst; najduže poruke (~60 znakova) staju.
- Bez tajmera, energije, reklama i kupovine u Areni (striktno Fair F2P).

PALETA (koristi ove hex vrijednosti; nove nijanse samo kao svjetlija/tamnija
varijanta postojećih i jasno ih označi):
mint #A8E6CF · lavanda #D4A5FF · peach #FFB88C (CTA) · coin gold #FFD56B ·
UI gold #E8C44A · warm white #FFF8F0 · soft sky #B8E0F5 · pastel yellow
#FFEAA7 · pastel pink #FFCCD5 · UI tekst #4A4A4A · outline #2D3436 ·
chrome #1A241E · livada danas #293D2E → #335C38 (sa T3)
Stil: zaobljeno, outline ~20 % tamniji od fill-a, jedna blaga sjena.

TEHNIČKI (Godot 4, OpenGL, slabiji Android):
- Artboard 1080 × 1920 px; sve mjere u px te baze (prenos 1:1).
- Sjemenka, vreća i Muncher se crtaju kodom ili iz SVG/PNG (krug, luk,
  poligon, tekstura). Animacije = tween (skala, pozicija, rotacija,
  prozirnost, boja) + par malih "burst" efekata.
- Bez blur/glow shadera, bez teških čestica — do 30 sjemenki + Muncher +
  VFX odjednom. Paneli = ravna boja, zaobljeno, border, jedna sjena (bez
  gradijenata na panelima). Pozadina polja smije biti PNG ilustracija.

ISPORUKA (statični artboardi, jasno labelirani):
P1 — obavezno:
1. Glavni ekran 1080 × 1920 sa headerom/footerom: runda u toku (~20
   sjemenki, mix tipova, T1 i T2, Muncher lovi, Combo 3, dnevni 1/3, pill).
2. Prazna Arena (vreća puna, Muncher spava) + ista u tutorijal varijanti.
3. Spec sheet sjemenke: T1, T2, ★3 T1 + sva stanja.
4. Vreća: sva stanja.
5. Muncher + gnijezdo: svih 6 stanja.
6. HUD komponente: hint (kratka + najduža), dnevni (u toku / završen),
   combo 2 i combo 5 (+2 coina), T3 poruka, "Arena full".
7. Done + zaključano stanje (pill).
8. Overlay "You need more seeds!".
P2 — poželjno:
9. Puno polje (30 sjemenki).
10. Pozadina 0 T3 vs 4 T3.
11. T3 trenutak kao storyboard (3–4 kadra) + tabela animacija (šta,
    trajanje, easing).
12. Lista asseta za export (SVG/PNG).
Pokaži max 2 vizuelna smjera jedan pored drugog i reci koji preporučuješ i
zašto.

IMENA SLOJEVA (da ih mogu mapirati na Godot node-ove): ArenaHud, HintLine,
DailyTask, ComboMeter, Playfield, SeedChip_T1, SeedChip_T2, SeedBag,
Muncher, MuncherNest, ArenaPip, DoneButton, NeedMoreSeedsOverlay, T3Burst
(+ StashCounter ako ga predložiš).

NE RADI: pravila i brojeve igre, cvijeće, lik Pipa, header/footer, druge
stranice, Donate/Keep/Basket u Areni (namjerno uklonjeno), reklame ni
kupovinu. Ideje van zadatka (npr. "Sort" dugme) navedi odvojeno na kraju.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `ArenaHud` / `HintLine` / `DailyTask` / `ComboMeter` | `merge_arena.tscn` → `RootVBox/TopBar` (`Title`, `ComboLabel`), `RootVBox/InfoLabel`, `RootVBox/DailyLabel` | Tekstovi: `_update_hint()` i direktni `info_label.text` u controlleru, `GameState.get_arena_daily_hud_text()`, `_refresh_combo_hud()`. Novi HUD fiksne visine (danas `ComboLabel` min 52 px pomjera red) |
| `Playfield` | `RootVBox/Playfield` (Control, EXPAND, min 400) | Granice: `_playfield_bounds()` (margina R + 16; dno `BAG_SIZE.y + 14 + 100 + 24`), spawn: `_pour_spawn_bounds()` |
| `SeedChip_T1/T2` | `arena_seed_chip.gd` `_draw()`; isti crtež u `arena_vacuum_fly.gd` | Cvijet: `CampPlantDraw.draw_plant` / `draw_fitted_plant` (SVG iz `FlowerAssets` za Country Bloom, proceduralno za ostale). CD okvir → tekstura ispod cvijeta. Veličina: `DISPLAY_SCALE` / `CHIP_RADIUS`; promjena → retune `GameState.ARENA_MAX_CHIPS / ARENA_SNAP_DISTANCE / ARENA_MAGNET_RADIUS` (bag keepout i `CHIP_MIN_DIST` su izvedeni iz `CHIP_RADIUS`) |
| `SeedBag` | `arena_seed_bag.gd` `_draw()` (`BAG_SIZE` 160 × 130, `DRAW_SCALE` 1.35) | `set_state(count, can_pour, preview_types)`; wiggle u `_process`; punch u controlleru (`_punch_seed_bag`) |
| `Muncher` / `MuncherNest` | `arena_pest.gd` `_draw()` (`PEST_RADIUS` 28) | `enum State` (6 stanja); gnijezdo = `set_nest_position()` (danas bez vizuala). Vizuelna veličina smije rasti — `ARENA_PEST_EAT_RADIUS` (36) je odvojen |
| `ArenaPip` | `RootVBox/Playfield/ArenaPip` (`pip_placeholder_control.gd`, 72 × 72, inset 12/8) | `_react_arena_pip()` |
| `T3Burst` / `StashCounter` | `_on_chip_released()` grana `new_tier >= MAX_MERGE_TIER` | Danas: `_remove_chip` + tekst + `_add_session_t3()` (tint + Pip) + `GameState.stash_garden_crystal()`; brojač: `GameState.get_garden_crystal_total()` |
| Clear / Vacuum / tint | `_play_clear_field_vfx()`, `_vacuum_fly_chip()`, `_apply_meadow_tint()` | Konstante na vrhu controllera (`CLEAR_*`, `VACUUM_*`, `ARENA_BG_*`) |
| Pozadina | `$Bg` (ColorRect) | Ilustracija → `TextureRect` + modulate/crossfade po `_session_t3_count` |
| `DoneButton` | `FooterBar/DoneButton` (`UiClickButton` primary, 56 px) | ≥ 120 px + razmak za `NavLockPill` (`UiChrome.LOCK_PILL_RISE` 36 px + visina 64) |
| `NeedMoreSeedsOverlay` | `$NeedMoreSeedsOverlay` (Dim, Panel, lista `SeedBagChip` iz Campa) | Danas tap bilo gdje = `_on_done_pressed()`; `SeedBagChip` je dijeljen s Campom — izmjene tamo diraju i Camp |
| Novi asseti | `game/assets/sprites/arena/` | `scripts/godot-import.ps1` + commit `.import` (CLAUDE.md § Novi asset); fallback na proceduralni crtež ako tekstura fali |

**Poznati problemi nađeni pri pisanju briefa (riješiti pri prenosu ili ranije):**

1. **NavLockPill preklapa Done** — regresija od hub chromea (2026-09-11): pill izviruje 36 px u stranicu preko donjeg dijela Done labele tokom runde.
2. **Polje ~1582 → ~1425 px** zbog većeg chromea — `ARENA_MAX_CHIPS` 30 je mjeren na 1582; provjeriti pun pour bez preklapanja.
3. **T3 poruka koristi `SEED_DISPLAY_NAMES.get(type_id, type_id)`** — za tipove van Country Bloom ispisuje sirovi id (`paper_lantern_bloom crystal → …`); treba `GameState.get_seed_display_name()`.
4. **Zastarjela dokumentacija:** [[../../02-design/merge-arena-v1.1|merge-arena-v1.1]] i [[../../02-design/spec-vertical-slice|spec-vertical-slice]] § 4b još opisuju Bloom inbox / Donate / Keep (uklonjeno u FLOW-A).

**Gotovo kad (implementacija):**

- [ ] Arena stane između headera i footera; Done ≥ 120 px i nije pod pillom
- [ ] Pun pour od 30 sjemenki bez preklapanja na stvarnoj visini polja
- [ ] T1 / T2 / ★3 prepoznatljivi na grayscale screenshotu
- [ ] Muncher stanja čitljiva; zamrznut se razlikuje i bez boje
- [ ] Svi tekstovi iz §2.6 staju (i najduži, s imenom sezonskog cvijeta)
- [ ] Nema pada FPS-a s 30 sjemenki + Muncher + VFX (emulator Pixel_4_API33)
- [ ] Smoke: svih 16 `arena_*_smoke` + `merge_arena_smoke` + `hub_chrome_smoke` + `meta_hub_flow_smoke`

---

## 11. Redizajn 2 (2026-09-30) — muncher, korpa, livada po sezoni, combo

Arena od 2026-09-24 nema HUD ni Done dugme — **cijela stranica je polje** ([[#Izmjena (2026-09-24) — arena je samo polje|§ Izmjena]]). Mehanika radi. Ono što ne valja je **kako izgleda**: muncher je ljubičasti smajli, vreća sjemena je smiješna, a livada je jedna ista tamnozelena površina bez obzira na to koju sezonu igrač igra.

Ovo je **druga runda redizajna** Arene. Sve iz §2 (pravila koja ostaju fiksna) i dalje vrijedi.

### 11.1 Šta se traži

| # | Zahtjev |
|---|---|
| **R1** | **Muncher — pravi neprijatelj.** Danas je ljubičasti krug s ušima, dva oka i ustima — smajli. Treba biti stvorenje koje **guta cvijeće**: prijeteće, ali i dalje u cozy cartoon jeziku igre, ne horor. |
| **R2** | **Korpa (vreća sjemena) — redizajn.** Danas izgleda smiješno. Uz to: **kad u njoj ima sjemena, sjeme mora viriti iz nje** — količina se vidi i bez brojača. |
| **R3** | **Livada po sezoni — osam različitih polja.** Pozadina Arene mijenja se prema sezoni koju igrač igra. **Ne isti šablon u drugim bojama** — svaka sezona nosi svoje elemente, svoj horizont, svoj ritam. |
| **R4** | **Combo — izgled i reakcija polja.** Danas se combo gotovo ne vidi. Treba mu čitljiv prikaz i **polje mora reagovati dok combo traje**. |

### 11.2 Mjere danas (iz koda, 2026-09-30)

> **Ispravka §6:** tamo piše „Arena = 1080 × 1597, footer 180". To je zastarjelo. Poslije hub chrome v2 stranica je **1080 × 1633** (header 143, footer 144), a polje uzima sve osim donjeg pojasa od 44 px za NavLockPill.

| Element | Mjera |
|---|---|
| **Playfield** | **1080 × 1589**, počinje na vrhu stranice |
| Sjemenka (chip) | radius **67,2** (48 × 1,4) → 134 px; T1 krug, T2 zaobljen kvadrat r 53; krem rub `#FFF8F0` + tamni well `#22342A`; cvijet 80 (T1) / 88 (T2) / 140 (T3) |
| Sjemenki na polju | do **30** odjednom (hex rešetka, korak 150 / 164) |
| **Muncher** | krug r **52** (104 px) + dvije uši r 15 na (±27, −51); oči, usta; ljubičasta `#8C61B8`, usnula `#7A579E`, zaleđena `#A6D1FA`; ledena heksagonalna ljuska r 70; „z z z" 32 px na (+44, −60) |
| Gnijezdo | elipsa **210 × 104**, centar na (sredina polja, **y 108**) |
| **Vreća** | dodir **280 × 250**; tijelo **214 × 178** puna, **214 × 126** prazna; vrat 118 × 34 (diže se 16); brojač krug r **42** dolje desno, tekst 44 |
| Sjeme koje viri | do **3** cvijeta 64 / 74 / 64, rotirani −16° / 0 / +16°, utonuli 26 px u tijelo — **samo kad ima ≥ 2 sjemena** |
| Vreća: pozicija | centrirana, **40 px** iznad dna polja; keepout `Rect2(-185, -349, 370, 520)` oko nje |
| Pip | 150 px, dolje lijevo, 30 od ruba i 26 od dna |
| **Livada** | ravna boja `#293D2E` → `#335C38`, dva brda, busenje, cvjetići; „bujnost" 0 → 4 po broju T3 u sesiji, crossfade 0,6 s |
| **Combo** | prozor **1,4 s**; od combo 2 Pip poskoči (1,0 → 1,18 → 1,0 za 0,28 s); na combo 5 sitno zlato + „+N" pop na hub traci. **Na polju nema nikakvog prikaza combo-a** — pilula je obrisana 2026-09-24 skupa s HUD-om |

**Brojevi koje mijenja igra, ne dizajn** (muncher): brzina **85 px/s**, jede sve unutar **36 px** od svog centra, jedenje traje **0,5 s**, T3 ga zaledi **2 s**, budi se **0,3 s** poslije sipanja, metu bira svakih **0,25 s**.

### 11.3 R1 — Muncher

**Šest stanja koja moraju ostati razlučiva, i bez boje** (pravilo iz §2):

| Stanje | Kada | Šta danas kaže |
|---|---|---|
| Spava u gnijezdu | polje prazno, on je gore na sredini | zatvorene oči, „z z z", gnijezdo pod njim |
| Spava gdje je stao | polje se ispraznilo dok je lovio | isto, bez gnijezda |
| Budi se | 0,3 s poslije sipanja | veće oči |
| Lovi | ide ka najbližoj sjemenki (T2 mu je draži) | nagib −6°, njiše se gore-dolje 5 px / 0,6 s |
| Jede | stigao je do sjemenke | usta se otvaraju i zatvaraju 2× u 0,5 s |
| Zaleđen | igrač je napravio T3 | ledena ljuska, 2 s |

**MORA**

- Sva **šest stanja razlučiva bez boje** (siluetom, oblikom, pozom) — igrač mora znati spava li, lovi li ili jede.
- **Ne smije se zamijeniti sa sjemenkom.** Sjemenka je krem krug s tamnim wellom, 134 px. Muncher mora biti drugačijeg reda i siluete.
- **Mora se vidjeti da guta cvijeće** — usta su glavni element, ne dekoracija. Jedenje je 0,5 s i mora izgledati kao zalogaj, ne kao treptaj.
- **Zaleđeno stanje mora biti očito i lijepo** — to je nagrada igraču za T3.
- Cozy cartoon, meki outline, bez horora, bez krvi, bez realističnih zuba. Igra je vedra ([[../art-direction|art-direction]]).
- Mora se čitati na **svih osam livada** iz R3, i na svijetlim i na tamnim.
- Gnijezdo je na **y 108**, odmah ispod headera — ništa iznad munchera ne smije biti odsječeno.

**SMIJEŠ** (odluči i obrazloži u § Odlučeno)

- **Veličina i silueta.** 104 px je današnji vizual; eat radius je 36 px od centra i ne mijenja se, pa usta treba da budu blizu centra.
- **Da li je i dalje ljubičast.** Ljubičasta je danas jedina „neprijateljska" boja u igri — ako je mijenjaš, reci šta signalizira opasnost umjesto nje.
- **Gnijezdo** — oblik, veličina, da li uopšte ostaje kao posebna stvar.
- **Uši, oči, rep, noge, sjena** — sve je tvoje.
- Kako izgleda ledena ljuska i „usnulo" stanje.

### 11.4 R2 — Korpa sjemena

Vreća drži do **40** sjemenki. Tap na nju sipa sjeme u polje. Kad ih je ≥ 2, vreća se klati i iz vrata vire tri cvijeta; kad je prazna, tijelo je niže (214 × 126).

**MORA**

- **Dodirna zona ostaje ≥ 280 × 250** i vreća ostaje **centrirana na dnu polja** — to je glavno dugme Arene.
- **Količina se vidi bez brojača**: koliko sjemena ima, toliko se i vidi da viri. Brojač ostaje kao tačan broj, ali ne smije biti jedini signal.
- **Tri jasna stanja**: prazna · ima sjemena · sipa (danas nagib −12°, 0,1 s tamo i 0,25 s nazad).
- Sjeme koje viri koristi **prave crteže cvijeća** iz igre (`FlowerAssets`), ne izmišljene oblike — to su tipovi koje igrač zaista ima.
- Mora se čitati na svih osam livada.

**SMIJEŠ**

- **Da li je to i dalje vreća.** Igrač je zove „korpa" — ako korpa, sanduk, saksija ili kolica bolje rade, uzmi to i reci zašto.
- Koliko sjemena viri i kako (3 kao danas, ili više, u slojevima, prelijevanje preko ruba).
- Gdje stoji brojač i kako izgleda.
- Da li se puna i skoro prazna vreća razlikuju i po obliku, ne samo po broju.

### 11.5 R3 — Osam livada, jedna po sezoni

Ovo je najveći dio zadatka.

Danas je Arena **jedna tamnozelena livada** za sve. Igrač koji igra Coral Tide i igrač koji igra Ember Fen spajaju sjeme na istoj površini. Polje treba da prati **sezonu koju igrač igra** (`active_season_id`) — istu onu čija se livada vidi na Home kartici.

**Osam sezona i njihov ton** (iz `game/data/seasons/seasons.json`; boja je mood boja sezone iz `UiHomeV3.SEASON_GROUND`):

| Sezona | Tagline | Mood boja | Cvijeće (★1 → ★3) |
|---|---|---|---|
| **Country Bloom** | Warm fields, soft petals, home pastures. | `#E6F2DB` | Meadow Clover · Field Daisy · Buttercup Lane · Barn Tulip · Sunfence · **Harvest Pumpkin** |
| **Frost Orchard** | Crisp air, silver blossom. | `#D1E6FF` | Frost Snowdrop · Ice Crocus · Silver Aconite · Winter Camellia · Hoarfrost Rose · **Crystal Peony** |
| **Lantern Meadow** | Dusk lights among tall grass. | `#EBD6FF` | Dusk Firefly Grass · Paper Lantern Bloom · Evening Primrose · Foxfire Lily · Glow Wisteria · **Midnight Lotus** |
| **Amber Canopy** | Warm late-season light through high leaves. | `#FFEBC7` | Copper Leaf · Maple Aster · Russet Mallow · Cider Dahlia · Golden Oak Bloom · **Amber Magnolia** |
| **Moonlit Warren** | Night blooms under a quiet moon. | `#B8BDFF` | Moon Moss · Nightshade Petal · Silver Harebell · Lunar Orchid · Star Jasmine · **Umbral Lily** |
| **Coral Tide Garden** | Salt breeze and seashell petals. | `#FFE0D6` | Sea Thrift · Salt Daisy · Tide Anemone · Coral Hibiscus · Pearl Waterlily · **Reef Crown** |
| **Starfall Glade** | Petals that catch the night sky. | `#DBCCFF` | Comet Sprig · Nebula Clover · Meteor Daisy · Aurora Tulip · Galaxy Sunburst · **Nova Bloom** |
| **Ember Fen** | Low firelight over marsh blooms. | `#FFC79E` | Marsh Rush · Peat Violet · Cinder Buttercup · Flame Iris · Smoke Lotus · **Fenfire Crown** |

**MORA**

- **Osam polja, osam različitih mjesta.** Ne jedan crtež u osam paleta. Mijenjaj horizont, broj slojeva, elemente, gustoću, pravac. Coral Tide treba da bude plitka voda i pijesak, Ember Fen močvara s dimom, Frost Orchard smrznuti voćnjak — ne isti brežuljci u drugoj boji.
- **Sjemenka mora ostati čitljiva na svih osam.** Sjemenka je krem rub + **tamni well** `#22342A`. Na tamnoj livadi to radi; na svijetloj (Country Bloom, Amber Canopy) krem rub se gubi. Reci kako to rješavaš — ili polje ostaje dovoljno tamno, ili sjemenka dobija nešto ispod sebe. **Kontrast sjemenke prema polju ≥ 3 : 1.**
- **Muncher, vreća i Pip moraju se čitati na svih osam.**
- **„Bujnost" ostaje.** Danas livada postaje bogatija sa svakim T3 u sesiji (nivo 0 → 4, crossfade 0,6 s). Svaka sezona mora imati svoj **prazan** i svoj **pun** izgled — reci šta konkretno raste u svakoj.
- **Polje je pozadina, ne takmac.** Igrač gleda 30 sjemenki; livada ne smije da se bori za pažnju. Nikakav pokret koji vuče oko dok igrač spaja.
- Bez blura, bez gradijenata, bez glowa (§6) — ravne boje, poligoni, lukovi, male teksture.

**MORA (tehnički budžet — ovo je važno)**

Cijeli sadržaj igre danas je **0,44 MB** od ~26 MB downloada. Osam pozadina od 1080 × 1589 kao pune PNG slike dodalo bi **višestruko više od cijele igre**.

Zato: svaka livada mora biti **recept, ne slika** — spisak ravnih oblika s brojevima koje igra sama crta (kao što `arena_meadow_bg.gd` danas crta brda, busenje i cvjetiće). Za svaku sezonu daj:

- boje traka / neba / tla (hex),
- 2–4 sloja siluete: svaki kao poligon s tačkama u % širine i visine,
- 3–6 vrsta „rasutih" elemenata (busen, kamen, školjka, pečurka, fenjer…): oblik, veličina, koliko ih je na nivou 0 i koliko na nivou 4, i gdje smiju biti,
- šta se mijenja između praznog i punog polja.

Ako neki motiv **mora** biti slika, neka bude jedan mali PNG po sezoni (≤ 256 × 256, koji se ponavlja ili rasipa), i reci zašto se ne da nacrtati.

**SMIJEŠ**

- Sve o izgledu svakog pojedinog polja — to je suština zadatka.
- Predložiti da neke sezone dijele strukturu ako to zaista ima smisla (npr. dvije noćne), ali onda **objasni** i pokaži da se ne doimaju isto.
- Predložiti da se polje mijenja i po dobu dana ili po napretku — ako ne košta ništa dodatno.

### 11.6 R4 — Combo

**Kako je danas.** Svaki merge unutar **1,4 s** od prethodnog diže combo. Od combo 2 Pip poskoči. Na combo 5 igrač dobije sitno zlato i „+N" iskoči na hub traci. Na samom polju **nema ničega** — combo pilula je obrisana 2026-09-24 kad je Arena ostala samo polje, i **ne vraća se**.

**MORA**

- **Combo se mora vidjeti na polju, bez povratka HUD-a.** Bez trake gore, bez pilule u uglu. Neka to bude nešto što živi u samom polju ili oko sjemenki.
- **Polje reaguje dok combo traje** — to je izričito traženo. Reci tačno šta se mijenja na kojem broju, i kako se vraća kad combo istekne.
- **Reakcija polja na combo ne smije se potući s „bujnošću" od T3.** To su dvije stvari na istoj površini: jedna je trajna (koliko si T3 napravio u sesiji), druga je trenutna (koliko brzo spajaš). Reci kako se slažu.
- **Ne smije ometati igru.** Igrač u combou gleda sjemenke i vuče prstom; ako mu polje počne treperiti, combo je kazna a ne nagrada.
- **Bez blura i glowa** i dalje vrijedi, i na vrhuncu combo-a.
- Prozor je **1,4 s** — sve što predložiš mora raditi na toj brzini, uključujući povratak u normalu.

**SMIJEŠ**

- Kako combo izgleda i na kojem broju eskalira.
- Predložiti drugi prozor (1,4 s) ili drugi prag za nagradu (danas 5), s obrazloženjem — **ali to je prijedlog, ne odluka**.
- Šta radi Pip (danas poskoči od combo 2).

**NE SMIJEŠ** — **iznos nagrade i dnevni limit su ekonomija, ne dizajn.** Danas: +2 coina na combo 5, najviše 10 coina dnevno. To čuva Pillar 2 (Fair F2P) i mijenja se samo dogovorom. Ne planiraj dizajn koji traži veću nagradu.

### 11.7 Isporuka

Novi paket: **`design_handoff_arena_v2/`**, ista struktura kao dosadašnji paketi.

| Fajl | Sadržaj |
|---|---|
| `design/ArenaScreen.dc.html` | Arena, interaktivno. Prop `season` (8 ključeva), `lush` (0–4), `combo` (0–8), `state` (prazno polje · puno polje · muncher lovi · muncher jede · muncher zaleđen · vreća prazna) |
| `design/Arena Specs.dc.html` | anatomija munchera (svih 6 stanja jedno pored drugog), anatomija korpe (3 stanja), **svih 8 livada jedna pored druge na nivou 0 i na nivou 4**, combo stepenice |
| `godot/arena_v2_export.json` | tokeni: muncher, korpa, combo + **`fields`: po jedna stavka za svaku sezonu s bojama, slojevima i rasutim elementima** |
| `godot/ui_arena_v2.gd` | iste vrijednosti kao JSON |
| `godot/arena_tree.txt` | stablo čvorova i red prenosa |
| `README.md` | § Odlučeno · § Šta se briše · § Runda 2 · § Samoprovjera · § Ideje van zadatka |

**§ Samoprovjera** (popuni prije zipa, svaka stavka da/ne, mjereno u browseru):

1. Svih šest stanja munchera razlučivo i u crno-bijelom.
2. Muncher se ne može zamijeniti sa sjemenkom ni na jednoj od 8 livada.
3. Korpa: količina sjemena se vidi bez brojača; tri stanja jasna; dodir ≥ 280 × 280.
4. Osam livada — stavi ih jednu pored druge i pogledaj: da li bi neko rekao da su to različita mjesta, ili ista slika u osam boja?
5. Sjemenka (krem rub + tamni well) ima kontrast ≥ 3 : 1 prema pozadini na **svakoj** od 8 livada, i na nivou 0 i na nivou 4.
6. Nijedna livada nije puna PNG slika; svaka je opisana brojevima u `fields`.
7. Combo se vidi na polju i **nigdje** nema trake ni pilule u uglu.
8. Combo reakcija i „bujnost" od T3 rade istovremeno bez sudara.
9. Nigdje blur, glow ni gradijent.

### 11.8 Scope

Osam zasebnih polja je **proširenje** obima. Trenutni milestone je M8 (launch IN lista), a sezone su na OUT listi *za launch*; per-sezonska tema je v1.1+ (`SEZ-01`, [[../../06-production/scope-i-granice|scope-i-granice]]).

Zato paket mora biti **primjenjiv sezonu po sezonu**: prvo Country Bloom (početna sezona), pa ostale. Muncher, korpa i combo ne zavise od toga i mogu ući odmah.

### 11.9 Odluke CD-a tokom izrade (2026-09-30, paket još nije isporučen)

CD je stao na pola paketa (istekao limit). Ove odluke postoje **samo u CD chatu**, pa su ovdje zapisane da se ne izgube ako ta sesija nestane. Nisu provjerene u igri — paket još nije stigao.

**Gotovo u `design_handoff_arena_v2/design/`:** `Arena Today.dc.html` (današnja Arena rekonstruisana iz koda, kao „prije" referenca), `arena_v2_data.js` (jedan izvor za muncher, korpu, combo i svih 8 livada kao recepte — bez ijednog PNG-a), `ArenaField.dc.html` (crta bilo koju sezonu na bilo kojem nivou bujnosti).

| Odluka | Sadržaj |
|---|---|
| **Čitljivost sjemenke** | Svaka sjemenka dobija **tamni prsten 4 px** ispod krem ruba. Na tamnoj livadi radi krem rub, na svijetloj tamni prsten — uvijek jedno od dvoje. Najniži izmjereni kontrast na 8 livada: **3,47 : 1** (traženo ≥ 3 : 1). |
| **Muncher** | Ljubičasta **gusjenica** sa žutim upozoravajućim tačkama. Svako stanje ima svoj oblik: sklupčana sa „zzz" (u gnijezdu i van njega), rep uvis i „!" pri buđenju, ispružena s ljutim obrvama u lovu, širom otvorena usta dok jede, u ledenom bloku sa ledenicama kad je zaleđena. |
| **Korpa** | Pletena **piknik korpa** s ručkom i peach krpom, dodir **300 × 280**. Do **12 cvjetova** se gomila u njoj (40 sjemenki = puna gomila), pa se količina vidi bez brojača. Brojač ostaje. |
| **Combo** | Na svaki combo merge iskoči „×N" na mjestu spajanja. Prsten se širi ispod sjemenki, a livada se **posvjetljava stepenasto (2 → 5)**; 5 je maksimum. Na 5 broj postaje zlatan i coin odleti na coin chip. Poslije 1,4 s bez merga sve se vrati. |
| **Combo vs bujnost** | Ne sudaraju se: **bujnost mijenja šta je na livadi** (više biljaka i detalja), **combo mijenja samo svjetlo**. |

**Provjereno uz kod:** prsten od 4 px je tačan — najmanji razmak centara sjemenki je `CHIP_MIN_DIST` 142,8 px, a sjemenka je 134,4 px široka, pa između rubova ostaje 8,4 px; pola je 4,2. Prstenovi se ne mogu preklopiti. Dodir korpe 300 × 280 je iznad traženih 280 × 250. Puna korpa od 40 sjemenki odgovara `GameState` limitu vreće.

**Ostalo CD-u:** popravka performansi (galerija od 16 livada se guši — spajanje oblika po boji), `SeedChip` / `Muncher` / `SeedBasket` komponente, `ArenaScreen.dc.html`, `Arena Specs.dc.html`, `godot/` (export JSON, `ui_arena_v2.gd`, `arena_tree.txt`), README sa § Odlučeno i § Samoprovjerom od 9 stavki, pa zip.

## 12. Prompt za Claude Design — redizajn 2

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je DRUGA RUNDA REDIZAJNA Merge Arene. Mehanika radi i ne mijenja se —
mijenja se kako Arena izgleda.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/merge-arena-cd-brief.md
    -> §2 (pravila koja ostaju fiksna), §5 (paleta), §6 (tehnika),
       §11 (OVAJ zadatak: mjere, MORA i SMIJEŠ, isporuka)
  game/scripts/camp/arena_pest.gd          (muncher danas)
  game/scripts/camp/arena_seed_bag.gd      (korpa danas)
  game/scripts/camp/arena_meadow_bg.gd     (livada danas)
  game/scripts/visual/ui_arena.gd          (tokeni u igri)
  game/data/seasons/seasons.json           (8 sezona, taglineovi, cvijeće)

Arena je cijela hub stranica: polje je 1080 x 1589 (stranica 1633 minus 44 px
donjeg pojasa). Nema HUD-a, nema Done dugmeta — obrisani su 2026-09-24 i ne
vraćaju se. Na polju je do 30 sjemenki (krug 134 px, krem rub + tamni well
#22342A), muncher, korpa dolje na sredini i Pip dolje lijevo.

ČETIRI STVARI:

R1 — MUNCHER, PRAVI NEPRIJATELJ.
Danas je ljubičasti krug r 52 s dvije uši, dva oka i ustima — izgleda kao
smajli. Treba stvorenje koje GUTA CVIJEĆE: prijeteće, ali u cozy cartoon
jeziku igre, bez horora. Šest stanja mora ostati razlučivo I BEZ BOJE: spava
u gnijezdu, spava gdje je stao, budi se, lovi, jede, zaleđen je (T3 ga zaledi
2 s — to je nagrada igraču i treba da izgleda tako). Ne smije se zamijeniti
sa sjemenkom. Brojevi igre koji se NE mijenjaju: brzina 85 px/s, jede sve u
36 px od svog centra, zalogaj traje 0,5 s, budi se 0,3 s poslije sipanja.
Gnijezdo je na y 108, odmah ispod headera — ništa iznad njega ne smije biti
odsječeno.

R2 — KORPA SJEMENA.
Danas je smeđa vreća 214 x 178 s vratom i brojačem, i izgleda smiješno. Drži
do 40 sjemenki; tap sipa sjeme u polje. Redizajniraj je, i neka se KOLIČINA
VIDI BEZ BROJAČA — sjeme mora viriti iz nje, više sjemena = više se vidi.
Danas vire tri cvijeta iz vrata i to je premalo. Dodir ostaje >= 280 x 250,
korpa ostaje centrirana 40 px iznad dna polja. Tri stanja: prazna, ima
sjemena, sipa (nagib -12°). Cvijeće koje viri su pravi crteži iz igre.

R3 — OSAM LIVADA, JEDNA PO SEZONI. (najveći dio)
Danas je Arena jedna tamnozelena livada za sve. Treba da prati sezonu koju
igrač igra. Osam sezona, njihovi taglineovi i mood boje su u §11.5 — Coral
Tide je plitka voda i pijesak, Ember Fen močvara s dimom, Frost Orchard
smrznuti voćnjak. NE isti brežuljci u osam paleta: mijenjaj horizont, slojeve,
elemente, gustoću.
Dva tvrda uslova:
 (a) Sjemenka ima krem rub i TAMNI well. Na tamnoj livadi to radi, na svijetloj
     (Country Bloom, Amber Canopy) se gubi. Riješi to i reci kako. Kontrast
     sjemenke prema polju >= 3:1 na svih osam.
 (b) BUDŽET: cijeli sadržaj igre je danas 0,44 MB od ~26 MB downloada. Osam
     punih PNG pozadina 1080 x 1589 dodalo bi višestruko više od cijele igre.
     Zato svaka livada mora biti RECEPT, NE SLIKA: boje, 2–4 sloja siluete kao
     poligoni u % širine/visine, 3–6 vrsta rasutih elemenata s brojem na nivou
     0 i na nivou 4, i gdje smiju stajati. Igra ih crta sama, kao danas.
     Ako neki motiv mora biti slika — jedan mali PNG po sezoni, <= 256 x 256.
Livada mora imati prazan i pun izgled: danas postaje bogatija sa svakim T3 u
sesiji (nivo 0 -> 4, crossfade 0,6 s). Reci šta konkretno raste u svakoj sezoni.
I: polje je pozadina, ne takmac. Igrač gleda 30 sjemenki.

R4 — COMBO.
Svaki merge unutar 1,4 s diže combo. Danas se to na polju NE VIDI — combo
pilula je obrisana skupa s HUD-om i ne vraća se. Treba čitljiv prikaz koji
živi u samom polju (ne traka, ne pilula u uglu) i POLJE MORA REAGOVATI dok
combo traje. Reci tačno šta se mijenja na kojem broju i kako se vraća kad
combo istekne. Pazi: reakcija na combo i „bujnost" od T3 su dvije stvari na
istoj površini — reci kako se slažu. Ne smije ometati igru ni na vrhuncu.
Iznos nagrade (+2 coina na combo 5) i dnevni limit (10) su ekonomija i NE
mijenjaju se — ne planiraj dizajn koji traži veću nagradu.

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920, sve u px
te baze. Ravne boje, poligoni, lukovi, tekst, male teksture. BEZ blura, glowa,
bloom shadera i gradijenata. Animacije su tweenovi (skala, pozicija, rotacija,
alpha, boja). Na polju je do 30 sjemenki + muncher + VFX odjednom — bez teških
čestica. Cozy flat cartoon, pastel, meki outline (art-direction).

ISPORUKA (§11.7): novi folder design_handoff_arena_v2/, cijeli u zipu:
ArenaScreen.dc.html (prop season 8 ključeva, lush 0–4, combo 0–8, state),
Arena Specs.dc.html (6 stanja munchera jedno pored drugog, 3 stanja korpe,
SVIH 8 LIVADA jedna pored druge na nivou 0 i na nivou 4, combo stepenice),
arena_v2_export.json (tokeni + „fields" po sezoni), ui_arena_v2.gd,
arena_tree.txt, README.md sa § Odlučeno i § Samoprovjera (9 stavki iz §11.7,
svaka da/ne, provjerene u browseru prije nego pošalješ zip).

NE RADI: promjene mehanike, povratak HUD-a ili Done dugmeta, druge stranice
huba, run, novi art cvijeća, više varijanti za biranje. Jedan dizajn, ti
odlučuješ dileme i upisuješ ih u § Odlučeno.
```

---

## Implementacija (2026-09-12)

> Dio ovoga je izmijenjen 2026-09-24 — HUD, traka s porukama i Done su uklonjeni, vidi [[#Izmjena (2026-09-24) — arena je samo polje|§ Izmjena]] niže.

| Fajl | Uloga |
|------|-------|
| `game/scripts/visual/ui_arena.gd` | Boje, mjere, stilovi, `spawn_slots()` (hex rešetka) — iz CD `ui_arena.gd`, dopunjen |
| `game/scripts/camp/arena_chip_draw.gd` | Crtež sjemenke (rim, well, T2 prsten, ★3 isprekidan gold, pulse/partner/merge prsteni, zagriz) |
| `game/scripts/camp/arena_seed_chip.gd` | Stanja: drag lift, partner, pulse 0,7 s, merge pop, wobble, pojedena, pour-in |
| `game/scripts/camp/arena_seed_bag.gd` | Vreća 214×178 + vrat + brojač, hit 280×250, 3 tipa vire, nagib −12° pri izbacivanju |
| `game/scripts/camp/arena_pest.gd` | Muncher 104 px, 6 stanja bez oslanjanja na boju, ledena ljuska, gnijezdo |
| `game/scripts/camp/arena_meadow_bg.gd` | Livada (brda, busenje, cvjetići) bujnija sa T3, crossfade 0,6 s |
| `game/scripts/camp/arena_hud.gd` | DailyTask, StashCounter, HintLine 128 px, ComboMeter, TutorialCue |
| `game/scripts/camp/arena_need_row.gd` | Red "You need more seeds!" overlaya |
| `game/scenes/camp/merge_arena.tscn` + `merge_arena_controller.gd` | Raspored 120 / 128 / polje / Done 140 (+60 do footera), rešetkasti spawn, T3 trenutak, novi tekstovi |
| `game/assets/ui/arena/*.svg` | `icon_crystal`, `icon_target`, `icon_check` |
| `game/scripts/dev/arena_redesign_smoke.gd` | Visinski budžet na 1597 px, 30 sjemenki bez preklapanja, T3 → StashCounter, najduži hint |

**Riješeno iz §10:** Done više nije pod NavLockPillom (140 px, 60 px do footera); 30 sjemenki staje na polje od 1133 px preko rešetke; T3 poruka koristi `get_seed_display_name()`; overlay se zatvara samo preko "Back to Camp".

**Odstupanja od handoff README-a (svjesna):**

1. **Pozadina se crta kodom** — `meadow_base.png` / `meadow_lush.png` nisu u paketu; livada prati `ArenaScreen.dc.html` (brda, busenje, cvjetići). PNG se koristi automatski kad stigne u `game/assets/sprites/arena/`.
2. **`spawn_slots()` gleda zauzeta mjesta** — auto-dopuna izbacuje među sjemenke koje su već na polju; keepout zone (vreća, Pip, gnijezdo, combo) računaju se iz stvarnog rasporeda, ne fiksnih px (na 1080 × 1133 i dalje ~39 pozicija).
3. **Tvrda sjena sjemenke** crta se kao pomaknut oblik — `StyleBoxFlat` sa `shadow_size = 0` u Godotu ne crta sjenu.
4. **Okvir sjemenke, vreća i Muncher su kod** (oblici i mjere iz specifikacije) — `seed_rim_*.svg`, `bag_*.svg`, `muncher_*.svg` iz "Isporuka 12" nisu u paketu; kad stignu, mogu zamijeniti crtež.
5. **Proceduralno cvijeće** (tipovi bez SVG-a) zadržava približno staru veličinu; SVG cvijeće popunjava okvir 78 / 84 px. Placeholder cvijeće iz `flowers/` nije uvezeno (nije za produkciju).
6. **Font:** default + embolden (Nunito nije uveden); labele na Done / Back to Camp su u default težini.
7. **`arena_pest_smoke`** iz README-a ne postoji — umjesto njega novi `arena_redesign_smoke` uz postojećih 16.
8. **Van zadatka, nije urađeno:** tap na StashCounter, long-press na sjemenku, Muncher koji nosi sjemenku 0,3 s.

## Izmjena (2026-09-24) — arena je samo polje

HUD red, traka s porukama i `Done` dugme su uklonjeni: pojeli su 464 px stranice, a nosili su informacije koje se ili nigdje ne koriste (dnevni zadatak se u igri ne preuzima) ili igraču ništa ne mijenjaju. **Mehanika je netaknuta** — nestao je samo prikaz.

| Prije | Sada |
|-------|------|
| `ArenaHud` 120 px (DailyTask lijevo, StashCounter desno) | nema; dnevni zadatak i garden stash se i dalje broje u `GameState` |
| `HintLine` 128 px (13 poruka) | nema; ostaje samo oblačić iznad vreće (tutorial prvog puta + Merge Hint booster) |
| `ComboMeter` gore desno + spawn keepout 380 × 130 | nema; combo i dalje broji i na 5 daje coine — javljaju Pip i „+N" pop kod coin chipa |
| `Done` 140 px + 76 px razmaka | nema; sesija se gasi sama |
| Playfield 1133 px | **1553 px** (sve osim 44 px pojasa u kojem viri NavLockPill) |
| Gnijezdo munchera 310 px od vrha stranice | **108 px** (više ne može — header odsijeca „zzz") |

**Kraj sesije bez dugmeta.** Nav lock ostaje: dok ima sjemenki na polju, hub se ne swipe-a. Prvi tap na vreću otvara sesiju (`_start_session_if_needed` — čisti pour lockove i livadu), a `_end_session_if_settled` je zatvara kad polje ostane prazno: ili si sve spojio pa je ostatak odletio natrag u vreću, ili je muncher pojeo sve. Muncher jede dok god ima T1/T2 na polju (spava samo kad nema hrane), pa polje uvijek dođe do kraja. Jedini ručni izlaz je „Back to Camp" u „You need more seeds" overlayu (`_end_session_to_camp`).

**Ostali feedback bez HUD-a:** T3 kristal leti u gornji desni ugao polja i nestaje (`CRYSTAL_EXIT_INSET`); odbijen tap na vreću (polje puno, vreća prazna) javlja punch vreće umjesto teksta.

**Datoteke:** novi `arena_cue.gd` (zamijenio `arena_hud.gd`), `ui_arena.gd` (`FIELD_BOTTOM_GAP`, `CRYSTAL_EXIT_INSET`, bez HUD/hint/Done/combo konstanti), `merge_arena.tscn`, `merge_arena_controller.gd`, `meta_hub_controller.show_coin_earn_pop()`. Testovi: novi `arena_session_end_smoke`, prepisani `arena_redesign_smoke` i `arena_nav_lock_smoke`, očišćeni `arena_combo_smoke` i `arena_daily_smoke`.

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-11 | Brief napisan. Pravila i brojevi Arene (§2) su fiksni; CD dizajnira izgled i osjećaj. Header/footer (smjer B) su zadati. |
| 2026-09-12 | Odabran **smjer B** (cream rim + tamni well) i prenesen. Naslov ukinut; StashCounter uveden; overlay samo preko CTA; tekstovi prema tabeli stari → novi; "Sort" dugme ne (CD). |
| 2026-09-24 | Arena ostaje samo polje: HUD, traka s porukama i Done uklonjeni (vizual, ne mehanika). Sesija se završava sama kad polje ostane prazno; combo nagradu javlja „+N" pop kod coin chipa. |

## Otvorena pitanja (nakon CD-a)

- [x] Naslov "Merge Arena" → **ukinut** (+52 px polju)
- [x] Brojač garden stasha u Areni → **da**, StashCounter gore desno
- [x] Veličina sjemenke → **ostaje 134 px** (balans netaknut)
- [x] Muncher → **104 px** (jedenje i dalje po radiusu 36)
- [ ] Pozadina: PNG ilustracija (`meadow_base` / `meadow_lush`) — zasad kod
- [x] Kraći tekstovi → prihvaćeni (13 poruka)
- [x] "Sort by type" → **ne** (rešetka već grupiše, dugme bi ukinulo magnet)
- [ ] Outline cvijeća: "~20 % tamniji" (brief) ili tvrdi `#2D3436` (postojeći `seed_clover.svg`) — riješiti prije cvijeća za 7 sezona

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — isti format; okvir u koji Arena ulazi
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — cvijeće unutar sjemenki (poseban zadatak)
- [[journal-cd-brief|journal-cd-brief]] — prvi CD → Godot prenos
- [[../../02-design/merge-arena-v1.1|merge-arena-v1.1]] — izvorni Arena spec (dijelom zastario, vidi §10)
- [[../../02-design/merge-arena-pest|merge-arena-pest]] — Muncher pravila
- [[../art-direction|art-direction]] — paleta, stil
- [[../pristupacnost|pristupačnost]] — touch 44 pt, font minimumi
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci (ovaj dokument ih ne mijenja)
