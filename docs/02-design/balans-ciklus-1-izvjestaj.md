---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ekonomija, balans, run, leveli, endless, cijene, izvjestaj]
povezano:
  - ekonomija-brojevi
  - ekonomija
  - balans-ciklus-1-simulacija
  - leveli-endless-cd-brief
  - nivoi
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Balans ekonomije, ciklus 1 (2026-10-21): simulator pokazao da su leveli iste težine, ★3 sjeme jednako često kao ★1, coini u višku ~4× i magnet beskoristan. Urađeno: leveli 1–20 rastu (60 → 120 s, brži, prepreke, parovi, više plijena), sjeme po rijetkosti, Endless bez tajmera sa stepenicama i otključavanjem na levelu 15, cijene ×5–13, magnet max dohvata susjednu stazu, telemetrija za ciklus 2. CD brief za izgled."
---

# Balans ekonomije — ciklus 1 · izvještaj

> 2026-10-21 · kod je u igri, testovi zeleni, **ništa nije commitano**. Dizajn (kako sve ovo izgleda) ide Claude Designu: [[../04-experience/design-drafts/leveli-endless-cd-brief|leveli-endless-cd-brief]]. Sirovi izlaz simulacije: [[balans-ciklus-1-simulacija|balans-ciklus-1-simulacija]].

## Ukratko

- Napravio sam **simulator ekonomije** (`game/scripts/dev/economy_sim.gd`) koji čita prave podatke igre i simulira hiljade runova i „put igrača" kroz 4 besplatne sezone — za 3 tipa igrača (casual / average / skilled) i 3 načina trošenja. Pušten je na **starim** pravilima (stanje prije) i na **novim** (poslije).
- **Run je prvi:** leveli 1–20 sad stvarno rastu — duži (1:00 → 2:00), brži, sve više prepreka, od levela 6 **parovi** (prepreka u dvije staze, treća slobodna) — ali i više plijena po levelu (coini po prolazu 21 → 42, sjeme 7 → 17).
- **Sjeme po rijetkosti:** ★3 („zlatno") je sada 3–7 % sjemena umjesto 16,7 % — više ne dolazi prije ★1/★2.
- **Endless** nema tajmer: kreće lagano, svakih 20 s teže, dok Pip ne padne; plijen ostaje cijeli; rekord po sezoni; **otključava se poslije levela 15** svake sezone.
- **Cijene gore** (sezone, nadogradnje, izgledi za coine ×5–13). Vrijednost cvijeća i sjemena (Trade) i nagrade Level Patha nisu dirane.
- Rezultat: coini više nisu u višku (ranije se zaradi ~4× više nego što ima šta kupiti), a sezone i nadogradnje se otključavaju postepeno — za prosječnog igrača Frost **dan 2–5**, Lantern **dan 4–10**, Amber **dan 9–16** (zavisi štedi li ili kupuje nadogradnje usput); sve za coine ~3–4 sedmice.

## 1. Šta si tražio → šta je urađeno

| Traženo | Urađeno | Gdje |
|---|---|---|
| Puni balans test ekonomije | Simulator (leveli, Endless, vrijednost nadogradnji, put kroz 4 sezone × 3 profila × 3 politike), prije / poslije | `scripts/dev/economy_sim.gd`, [[balans-ciklus-1-simulacija\|simulacija]] |
| Prvo balans runa: % coina i sjemena | Gustina spawna, udio sjemena i plijen po levelu u tabeli 1–20 | `data/run_levels/levels.json` |
| Leveli sve teži do 20, brzina, više prepreka, više loota, duži | Level 1 → 20: 1:00 → 2:00, 400 → 520 px/s (+ ubrzanje u levelu), prepreke 6 → 30 %, parovi od L6, plijen ×2 | isto, `run_controller.gd` |
| Endless lagan pa sve teži dok ne umreš / izađeš | Stepenica svakih 20 s, bez tajmera, brzina raste bez kraja; plijen cijeli | `run_level_library.gd`, `run_controller.gd` |
| Endless od 15. levela svake sezone | Otključan kad je level 15 te sezone **pređen**; do tada prigušeno dugme + poruka | `level_path.gd`, `main_menu.gd` |
| CD da isplanira kako izgleda | Brief po šablonu + slike | [[../04-experience/design-drafts/leveli-endless-cd-brief\|leveli-endless-cd-brief]] |
| Rijetkost sjemena (★3 prije ★1/★2) | Izbor tipa po težini rijetkosti | `run_balance.gd` |
| Vrijednost cvijeća i sjemena OK | Nije dirana (Trade ★1/★2/★3 = 1/2/4 po sjemenki, 5/10/20 po cvijetu) | — |
| Povećati cijene boostova, sezona, skinova, „free" stvari u Shopu | Nadogradnje, besplatne sezone, izgledi za coine, + dnevni poklon / combo / Starter Pack da prate | `seasons.json`, `cosmetics.json`, `ui_camp.gd`… |

## 2. Šta je simulator našao (stara pravila)

| Nalaz | Brojka (prosječan igrač) |
|---|---|
| Leveli skoro iste težine | prolaz 99 % (L1) → 94 % (L20); trajanje 50 → 62 s |
| ★3 sjeme jednako često kao svaki ★1 tip | 16,7 % sjemena (svaki od 6 tipova isto) |
| Coini u višku | do kraja zaradi ~17 000, a ima šta kupiti za ~4 000 |
| Svi izgledi za coine | kupljeni za **~20 minuta** igre (dan 0,8) |
| Sve 4 besplatne sezone | dan 3 (ako štedi) — Level Path nagrade (2200 coina + 22 ★3 po sezoni) same plate sljedeću sezonu |
| Magnet (Sprinkler) | max 232 px ne dohvata susjednu stazu (270) → **+1 % coina** na max nivou |
| Endless | uvijek „Hard", s tajmerom ~89 s; pad = pola plijena |

## 3. Promjene

### 3.1 Leveli 1–20 (svaka sezona ista težina)

| | Level 1 | Level 10 | Level 15 | Level 20 |
|---|---|---|---|---|
| Trajanje | 1:00 | 1:28 | 1:44 | 2:00 |
| Brzina start → kraj (px/s) | 400 → 424 | 456 → 521 | 488 → 586 | 520 → 662 |
| Prepreka / min | 1,6 | 6,5 | 12,2 | 20,6 |
| Parova (od prepreka) | 0 % | 11 % | 20 % | 30 % |
| Prolaz casual · average · skilled | 98 · 100 · 100 % | 86 · 94 · 96 % | 62 · 81 · 93 % | 39 · 61 · 74 % |
| Coina / prolaz (average) | 21 | 31 | 37 | 42 |
| Sjemena / prolaz (average) | 7 | 11 | 14 | 17,5 |
| ★3 u sjemenu | 3 % | 5 % | 6 % | 7 % |

Puna tabela (sva 20 levela): [[../04-experience/design-drafts/leveli-endless-cd-brief#4. Podaci (fiksno — već u igri)|brief §4]] i `docs/02-design/ekonomija-balans.csv` (za Excel).

- Par prepreka uvijek ostavlja **jednu slobodnu stazu**; ne dolazi u nagradni grm (isto pravilo „fer grma").
- Coini po minuti ostaju ~20 — „više loota" dolazi od dužih levela i gušćeg spawna, a level 20 je 2× vredniji od levela 1.

### 3.2 Sjeme po rijetkosti

| | ★1 (svaki tip) | ★2 (svaki tip) | ★3 |
|---|---|---|---|
| Prije | 16,7 % | 16,7 % | 16,7 % |
| Level 1 | 25,5 % | 10,2 % | 3,1 % |
| Level 20 | 22,2 % | 13,3 % | 6,7 % |
| Endless 8 min | 19,6 % | 13,7 % | 11 % |

Country Bloom (lanac otključavanja sjemena) dobio niže pragove (8 / 8 / 8 / 6 / 6) jer je ★2 sad rjeđe — Harvest Pumpkin (★3) stiže oko levela 12–14 (dan ~1).

### 3.3 Endless

- Bez tajmera i bez Easy / Normal / Hard. **Stepenica svakih 20 s**: brže, gušće, više prepreka i parova, rijetko sjeme češće. Kreće kao level 2–3, na ~3 min je kao kraj levela 20, na 8 min 920 px/s, poslije toga brzina raste +4 % po stepenici bez kraja.
- Preživljeno (simulacija, medijan): casual **3:17**, average **4:25**, skilled **5:28**.
- Pad ili izlazak iz pauze = **cijeli plijen** (u levelu pad i dalje = pola). Revive nastavlja Endless.
- **Rekord po sezoni** (najduže preživljeno) se pamti u saveu; Loot ekran piše „Endless · 4:25" ili „Best! 4:25".
- **Otključavanje:** poslije pređenog levela 15 te sezone (isti trenutak kad nagrada 15 postane spremna). Stari save koji je već preko 15 ima Endless odmah.
- Plijen po minuti u Endlessu ≈ level 20 (average: 21,5 coina / 8 sjemena po min) — nije „farma" bolja od levela, ali je mjesto gdje dobar igrač nalazi više ★3.

### 3.4 Cijene

| Šta | Prije | Sada |
|---|---|---|
| Frost Orchard | 500 C + 20 ★3 | **2500 C + 22 ★3** |
| Lantern Meadow | 500 C + 20 ★3 | **4500 C + 26 ★3** |
| Amber Canopy | 500 C + 20 ★3 | **6500 C + 30 ★3** |
| Nadogradnja nivo 1 / 2 / 3 / 4 (Magnet, Loot Boost, Twin — po sezoni) | 10 / 20 / 40 / 60 C + 2 ★3 | **100 / 250 / 500 / 800 C + 2 / 2 / 3 / 3 ★3** |
| Golden Album | 120 | **800** |
| Sunset Meadow | 150 | **1000** |
| Lavender Meadow | 180 | **1200** |
| Pip Sky | 200 | **2000** |
| Pip Blossom | 250 | **2500** |
| Dnevni poklon | 8 C + 3 sjemena | **75 C + 5 sjemena** |
| Arena combo | 2 C (max 10 / dan) | **5 C (max 30 / dan)** |
| Starter Pack (€1,99) | 100 C + Pip Blossom + 50 sjemena | **1000 C** + isto |
| **Nepromijenjeno** | Trade vrijednosti, Level Path nagrade (2/4/6/10 ★3 + 200/400/600/1000 C), sve € cijene, Loot Burst (+5 ★3) | |

### 3.5 Magnet

40 + 48 × nivo → **40 + 55 × nivo**. Max (260 px) prvi put dohvata pickupe u susjednoj stazi. Na levelu 20 (average): bez nadogradnji 18,3 coina / 8 sjemena po min → Magnet max **+34 % / +38 %**, Twin max +24 % sjemena, Loot Boost max ×2, sve tri **50,8 / 27,9** (prije: Magnet max +1 % coina).

## 4. Rezultat — put igrača (dani po 25 min igre, medijan 20 simulacija)

**Prosječan igrač** — tri načina trošenja: *štedi* (prvo sljedeća sezona), *nadogradnje* (kupuje boost čim može), *izgled* (prvo skin / tema iz Shopa):

| Milestone | Prije: štedi | Sada: štedi | Sada: nadogradnje | Sada: izgled |
|---|---|---|---|---|
| Country Bloom level 20 | 1,1 | 1,7 | 1,7 | 1,7 |
| Frost Orchard otključan | 1,1 | 1,7 | 5,1 | 8,2 |
| Lantern Meadow otključan | 2,2 | 4,0 | 10,4 | 13,5 |
| Amber Canopy otključan | 3,3 | 9,5 | 16,1 | 19,2 |
| Prvi izgled za coine | 0,5 | 11,0 | 4,5 | **0,7** |
| Pip Sky (prvi skin) | 0,8 | 20,4 | 19,1 | **5,7** |
| Svi izgledi za coine | 0,8 | 28,7 | 20,5 | 7,0 |
| Sve nadogradnje 4 besplatne sezone | 11,9 | 27,7 | 19,1 | 21,7 |

**Casual** (štedi / nadogradnje): Frost 1,9 / 6,0 · Lantern 4,9 / 12,6 · Amber 11,5 / 20,1. **Skilled**: Frost 1,7 / 4,3 · Lantern 3,4 / 8,5 · Amber 8,2 / 13,7.

**Tok coina** (prosječan igrač, do kraja svega): prije zaradi ~17 000, potroši ~4 000; sada zaradi ~41 000 (runovi 18 k, prodaja cvijeća 12 k, Level Path 9 k, poklon + combo 2,5 k) i potroši ~41 000 (sezone 13,5 k, nadogradnje 19,8 k, izgledi 7,5 k). **Coini sad imaju vrijednost do kraja.**

**Šta to znači:** pravi igrač je negdje između tri kolone — npr. kupi koji boost i jedan skin, pa Amber dođe oko 2. sedmice. Prva besplatna sezona dolazi brzo (cijela Country Bloom staza plati Frost), svaka sljedeća traži malo više grinda (Endless!). Pillar 2: ništa se ne mora kupiti — sve je dostižno igrom; Loot Burst (€) i Starter Pack samo ubrzavaju.

## 5. Model i ograničenja (važno za ciklus 2)

Simulator koristi **prava pravila igre** (spawn, brzine, grm, Twin, Loot Boost, magnet, pad = pola, Level Path nagrade, cijene, lanac sjemena), ali **igrač je model**:

| Profil | Uzme pickup | Rizik po prepreci (na 400 px/s) |
|---|---|---|
| casual | 55 % | 1,0 % |
| average | 70 % | 0,5 % |
| skilled | 85 % | 0,25 % |

Rizik raste s brzinom², ×1,8 za par i s gužvom na ekranu; skupljanje pada s brzinom i gustinom prepreka; magnet koji dohvata susjednu stazu podigne skupljanje. Pretpostavke: sve sjeme se merguje u Areni (4 → ★3 cvijet), višak cvijeća koje ne treba se proda, 25 min igre dnevno, ~20 s između runova. **Brojevi su orijentir, ne tačna istina** — zato:

- u **debug buildu** (editor ili debug APK) svaki run upiše red u `user://balance_log.csv` (šta je izašlo na stazu, šta je Pip uzeo / promašio, prepreke, brzina, kraj, plijen). U release buildu i testovima ne piše ništa i ništa ne šalje.
- `economy_sim.gd -- --calibrate` iz tog loga izračuna stvarni % skupljanja i rizik po prepreci → u ciklusu 2 profili postaju tvoji pravi brojevi.

## 6. Šta čeka tebe (odluke)

- [ ] **Playtest (debug build): 10–15 runova** — L1, L5, L10, L15, L20 + Endless 2–3 puta. Za skok: Settings → Developer → **„Level +5"** (aktivna sezona 1 → 6 → 11 → 16 → 21 → 1; poslije zatvori i otvori polje) i „+1000 coins" za probu cijena. Pitanja: osjeti li se rast? Je li 16–20 preteško / prelagano? Je li Endless start dosadan?
- [x] **Endless otključavanje:** poslije **pređenog** levela 15 (Pip na 16) — odlučeno 2026-10-21 po preporuci.
- [x] **Starter Pack 100 → 1000 coina** — odlučeno 2026-10-21. Opis proizvoda u Play Consoleu treba ažurirati kad ga budeš unosio.
- [x] **Magnet max dohvata susjednu stazu** — ostaje (40 + 55 × nivo); krug u runu prozirniji (alfa 0,6 → 0,32) jer se previše vidio — 2026-10-21.
- [ ] **€ cijene** (plaćene sezone €2,99–3,49, Loot Burst, Merge Hint, Sir Pip) nisu dirane — ★3 je sad rjeđi, pa Loot Burst (+5 ★3) vrijedi više; to je u redu za Pillar 2 (ubrzava, ne zaključava).
- [ ] **Level Path nagrade** ostale iste (2/4/6/10 ★3 + 200/400/600/1000). Coini od puta su sad ~20 % zarade (bilo ~50 %).
- [ ] **CD brief** — commit + push, pa pošalji [[../04-experience/design-drafts/leveli-endless-cd-brief\|leveli-endless-cd-brief]] (§9 prompt). Do paketa Endless izgleda privremeno (sat u čipu, prigušeno dugme, Loot naslov).
- [ ] **Ciklus 2** — poslije playtesta pošalji mi log (`%APPDATA%\Godot\app_userdata\Merge Meadow\balance_log.csv`; s telefona: `adb exec-out run-as com.mergemeadow.game cat files/balance_log.csv > balance_log.csv`) i utiske.

## 6b. Poslije prvog playtesta (2026-10-21)

| Prijava | Urađeno |
|---|---|
| Magnet krug se previše vidi dok Pip trči | alfa tačkica 0,6 → **0,32** (`pip_visual.gd` `MAGNET_ALPHA`); domet ostaje |
| Na kraju levela ispred Pipa ostaje plijen koji ne može pokupiti | pred kraj se ništa ne stvara ako ne bi stiglo do Pipa (`_spawn_reaches_pip`): zadnjih ~2,5–4 s staza je prazna. Simulator je to već pretpostavljao, pa brojevi plijena ostaju isti |
| Cilj na vrhu kroz koji Pip prođe + animacija kraja | u CD briefu (A6) — cilj stiže tačno na kraju, po sezoni |
| „Claim" na putu ne radi, radi samo sanduk | pilula izbačena (crtala se van zone dodira); dodir hvata sanduk i traku ispod; privremeno sanduk skače 26 px, doskoči sa squashom i klima se ±8° (ciklus 1,8 s); konačni izgled u CD briefu (C) |

## 7. Provjere

| Provjera | Rezultat |
|---|---|
| `economy_balance_smoke` (novo) | OK — svaki level ≥ prethodni, Endless samo teži i bez tajmera, ★1 > ★2 > ★3 (30 000 izvlačenja = formula), Endless od levela 15, rekord u saveu, pad u Endlessu čuva sve, par nikad ne zatvori 3 staze, max magnet dohvata stazu, dugme nadogradnje stane i za 800, run u Endlessu primijeni stepenicu i sat |
| GUT | **78 / 78** (8 novih u `test_run_balance.gd`) |
| Smoke suite | svih 77 OK; 20 testova je imalo zakucane stare cijene (500 / 20 / 2 / 250…) — sada čitaju cijene iz `seasons.json` / `cosmetics.json` / `UiCamp` |
| Telemetrija | pravi run (ne headless) do kraja levela 1 upiše ispravan red (`balance_capture.gd`) |
| FPS (laptop, `balance_perf_bench.gd`) | level 1: 3,5 ms prosjek / 5,8 p95 · level 20 (~640 px/s): 4,4 / 6,3 · Endless 8 min (920 px/s, parovi): 2,8 / 4,1 — gustina ne podiže cijenu frejma (razlike su od pozadine sezone); budžet 16,6 ms |
| Izvoz | `--export-pack "Android Debug"` sadrži `data/run_levels/levels.json`, `seasons.json`, `cosmetics.json` i nove skripte |
| Izgled cijena | 4-cifrene cijene staju: Shop Looks „2500", Camp kartica „1830 / 2500" i „9 / 22", nadogradnja „×3 · 800" (kontrolne snimke) |

## 8. Kako pokrenuti

```powershell
# simulacija (piše markdown)
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path game -s res://scripts/dev/economy_sim.gd -- --out=C:/temp/sim.md --runs=400 --reps=20
# kalibracija iz loga
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path game -s res://scripts/dev/economy_sim.gd -- --calibrate --log=C:/temp/balance_log.csv --runs=50 --reps=2
# pravila
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path game -s res://scripts/dev/economy_balance_smoke.gd
```

## 9. Fajlovi

| Fajl | Šta |
|---|---|
| `game/data/run_levels/levels.json` | 20 levela + Endless ključevi (zamjenjuje `levels_1_10.json`) |
| `game/scripts/run/run_level_library.gd`, `run_level_config.gd` | čitanje, Endless stepenice |
| `game/scripts/run/run_balance.gd` (novo) | rijetkost sjemena, par prepreka |
| `game/scripts/run/run_telemetry.gd` (novo) | log runova (debug) |
| `game/scripts/run/run_controller.gd` | brzina po levelu, parovi, Endless bez tajmera, sat, pauza, telemetrija |
| `game/scripts/autoload/game_state.gd`, `economy/level_path.gd` | pun plijen u Endlessu, rekord, otključavanje, težinski izbor sjemena, cijene |
| `game/scripts/ui/main_menu.gd`, `loot_screen.gd`, `visual/ui_run.gd`, `visual/ui_camp.gd` | zaključan Endless, Endless Loot naslov, sat, cijena nadogradnje po nivou |
| `game/scripts/ui/settings_screen.gd` | Developer (samo debug): „Level +5", „Level 1" za playtest |
| `game/scripts/visual/pip_visual.gd`, `game/scripts/ui/level_path_view.gd` | poslije playtesta: magnet krug alfa 0,32; sanduk bez „Claim", skok + klimanje, šira zona dodira |
| `game/data/seasons/seasons.json`, `cosmetics/cosmetics.json` | cijene |
| `game/scripts/dev/economy_sim.gd`, `economy_balance_smoke.gd`, `balance_capture.gd`, `test/unit/test_run_balance.gd` (novo) | alati i testovi |
| `docs/02-design/ekonomija-balans.csv` | tabela levela za Excel |

## Povezano

- [[_index|02-design]] · [[ekonomija-brojevi|ekonomija-brojevi]] · [[ekonomija|ekonomija]] · [[balans-ciklus-1-simulacija|simulacija]]
- [[../03-content/nivoi/_index|nivoi]] · [[../04-experience/design-drafts/leveli-endless-cd-brief|leveli-endless-cd-brief]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] · [[../01-vision/design-pillars|design-pillars]] — Pillar 2
