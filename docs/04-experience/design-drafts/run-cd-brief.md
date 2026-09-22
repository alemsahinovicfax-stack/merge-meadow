---
type: dizajn
status: draft
milestone: "—"
tags: [dizajn, ui, run, lane-run, claude-design, mockup, feel]
povezano:
  - hub-header-footer-cd-brief
  - merge-arena-cd-brief
  - seeds-flowers-cd-brief
  - art-direction
  - pristupacnost
  - kontrole-i-input
  - CHECKPOINT
ai_sažetak: "Run (lane runner) — pravila iz koda koja ostaju fiksna, HUD i svijet danas, šta ne štima, šta CD mora/smije, gotov prompt za Claude Design i mapa za prenos u Godot."
---

# Run (lane) — Claude Design brief i referenca

> **Status: brief za CD** — još nije implementiran redizajn. §2–§3 = stanje u kodu danas. Handoff ide u `design_handoff_run/` nakon CD-a.

**Run** je lane runner u kojem igrač swipea lijevo/desno, skuplja coinove i sjemenke, izbjegava prepreke. To je **prva "igračka" petlje** — feel (odgovor swipea, pickup pop, čitljivost prepreke) jednako je važan kao izgled. Nije hub stranica: pun ekran, bez header/footer tabova.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl kao prilog (§1–§8) | Pravila, mjere, sloboda i ograničenja |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §5, §10 | Vrijednosti, poznati problemi, mapa "CD sloj → Godot node" |

Postupak: u CD priloži ovaj `.md`, pa zalijepi prompt iz §9. Kao stil referencu priloži `design_handoff_hub_chrome/` i/ili `design_handoff_merge_arena/` (isti pastel jezik). Kad CD završi, raspakiraj zip u repo root kao `design_handoff_run/`.

---

## 1. Kontekst (za CD)

- **Merge Meadow** — casual F2P merge/runner hibrid za mobitel, **portrait**. Flat 2D cartoon, pastel, meki outline, bez pixel-arta, bez 3D ([[../art-direction|art-direction]]). Mood: *cozy meadow, vedro, satisfying*.
- **Petlja:** **Run** → loot ekran → sjemenke u **vreću** → **Arena** (merge) → Camp / Home. Run je ulaz u petlju; Arena je "igračka nakon".
- Igrač trči kao **companion** (default Pip) u **3 lanea**. Svijet se **auto-scrolla** prema dolje (entiteti padaju odozgo).
- Sjemenke su iz **aktivne sezone** (8 sezona × 6 tipova, ★1–★3). Coinovi idu u wallet; sjemenke u run bag → nakon loot-a u seed bag; diamanti su rijetki.
- Fair F2P ([[../../01-vision/design-pillars|design-pillars]], Pillar 2): **u runu nema reklama, kupovine, energije ni paničnih tajmera**. Timer je samo preostalo vrijeme runde. Rewarded (Double / Revive) žive na **loot ekranu poslije** — van ovog zadatka.

---

## 2. Kako Run radi danas — pravila koja ostaju FIKSNA

> CD dizajnira **izgled i osjećaj**, ne pravila. Izvor: `run_controller.gd`, `player.gd`, `GameState` (run duration, magnet, loadout), `ekonomija-brojevi.md`.

### 2.1 Tok runde

1. Ulaz: **fresh** (Menu / Home Play / Camp Play / Retry) ili **resume** (Revive s loot ekrana — isti coin/seed broj i elapsed).
2. **Trajanje:** tutorial run1 = **45 s**, run2 = **60 s**, post-tutorial = **60 s** (`POST_TUTORIAL_RUN_DURATION`). Endless prikazuje label + preostalo vrijeme.
3. **Auto-scroll:** baza **400 px/s**; svakih **15 s** brzina × **1.05** (ramp).
4. **3 lanea** na **25% / 50% / 75%** širine. Swipe L/R = ±1 lane, tween **0,12 s** (ne teleport). Prag swipea **50 px**.
5. Igrač stoji na **~82%** visine ekrana (donja zona, thumb).
6. **Spawn** svakih ~**1,2 s** (šansa **0,7**): ili **prepreka** (udio ~0,25 ako su enabled), ili **sjeme** (~0,30 + loadout bonus), ili **coin** (ostatak). Rijetko (**1/300** seed spawnova) → **diamond**.
7. **Magnet:** `Area2D` oko igrača skuplja coin/seed/diamond u radiusu; **ne** skuplja prepreke. Radius = `40 + magnet_level × 48` (level 0–4).
8. **Fail:** sudar s preprekom → kraj, loot = **50%** (ceil) coinova i sjemenki.
9. **Finish:** istek vremena → loot = **100%**.
10. Nakon kraja → scena **Loot** (nije dio ovog redizajna).

### 2.2 Pickup tipovi

| Tip | Šta radi | Hit danas |
|-----|----------|-----------|
| **Coin** | +1 u run counter | krug Ø ~36 px |
| **Seed** | +1 tipa u run bag; feed `+1 Clover` | krug Ø ~52 px |
| **Diamond** | +1 u wallet odmah | slično coinu |
| **Obstacle** | fail | kvadrat **64 × 64**, crvenkasti `Polygon2D` + season tint |

Sjemenke: tip bira `GameState.pick_random_run_seed_type()` iz aktivne sezone. **Loadout ("Basket")** +**5%** šanse za seed spawn ako je tip u poolu sezone.

### 2.3 Tutorial (samo prva 2 runa)

| Kad | Šta |
|-----|-----|
| Run1 @ 20 s | Banner `"Coins for the shop!"` (3 s) |
| Run1 @ 30 s | Guaranteed Clover seed u srednjem laneu |
| Run2 @ 25 s | Guaranteed prepreka u srednjem laneu |
| Banner default (scena) | `"Swipe left / right to change lanes"` (vidljivost po tutorijalu) |

### 2.4 HUD danas (EN)

| Element | Tekst / sadržaj |
|---------|-----------------|
| Companion | ime (npr. `Pip`) + portret 48×48 |
| Basket | `Basket: Clover` (samo ako je loadout set) |
| Timer | `75s` · ili `Lv 3 · 42s` · ili `Endless · Easy · 42s` |
| Brojači | coin / seed ukupno / diamond (wallet) |
| Feed | `+1 Coin` · `+1 Meadow Clover` (do 5 linija, fade 4 s) |
| Tutorial banner | gore |

**Nema Pause dugmeta u kodu danas** (docs ga spominju — CD smije predložiti Pause ≥ 120 px hit, gornji kut, bez promjene mehanike).

### 2.5 Šta Run NIJE

- Nije hub stranica — **nema** Shop/Journal/Home/Camp/Arena footera.
- Nema mergea, Munchera, vreće Arene.
- Nema mid-run ads / IAP / energije.

---

## 3. Trenutni raspored (uvod u dizajn)

Scena: `game/scenes/run/run_scene.tscn` · skripta: `game/scripts/run/run_controller.gd`

```
 1080 × 1920 (pun ekran)
┌──────────────────────────────────────────────┐
│ [Pip 48] Pip   [ Basket: Clover ]            │  TopHud (safe-area top)
│              42s          [●12][♣5][◆1]      │  timer + PickupBar
│                    +1 Clover                 │  PickupFeed (desno)
│              Coins for the shop!             │  TutorialBanner (kad treba)
│                                              │
│         ○ coin     ■ obstacle                │  World — padaju odozgo
│              ♣ seed                          │  3 lanea 25/50/75 %
│                                              │
│                                              │
│              (Pip / companion)               │  igrač @ y ≈ 82%
│                 magnet Ø                     │
│                                              │
│                                              │  (nema bottom chrome)
└──────────────────────────────────────────────┘
```

Pozadina: `lane_background.gd` — PNG cover-scale (`assets/backgrounds/lane_background.png` ili sezonski `run_bg_path`) × cosmetic modulate × season tint.

### 3.1 Elementi danas

| Element | Danas |
|---------|-------|
| Artboard | **1080 × 1920** pun ekran (Node2D + CanvasLayer HUD) |
| Igrač | `Area2D` 56×56; Pip SVG ili procedural companion; magnet krug od levela |
| Lane guides | node postoji, **hidden** |
| Coin / Seed / Diamond | Sprite2D + pickup asset / draw fallback |
| Obstacle | crveni kvadrat 64×64 (placeholder) |
| TopHud | MarginContainer, fontovi 18–36, outline bijeli |
| PickupBar | cream panel, radius 14, border @ 18% |
| Safe area | samo top margin na TopHud |

### 3.2 Šta danas ne štima (zapažanja, nisu odluke)

1. **Prepreka je sivi/crveni kvadrat** — teško se čita na livadi; nema "prirodnog" motiva (kamen, panj, grm).
2. **HUD je zbijen u jedan red** — timer, Pip, Basket, 3 brojača; na uskom telefonu se guši; fontovi 26–36 s outlineom izgledaju "dev".
3. **Nema Pause** — docs ga očekuju; izlaz samo fail/finish.
4. **Magnet je nevidljiv** ili jedva naznačen — igrač ne vidi domet upgradea.
5. **Pickup feed je sirovi tekst** desno — nema fly-to-HUD ni pop ikone.
6. **Laneovi nisu vizuelno označeni** (guides off) — novi igrač ne vidi 3 staze.
7. **Coin/seed/diamond** imaju assete, ali stil nije usklađen s novim hub chrome / Arena jezikom.
8. **Companion** skalira se iz configa; Pip skin path je djelomično procedural — CD ne redizajnira lika, samo prezentaciju u runu.
9. **Kraj runa nema in-run beat** — instant cut na loot (freeze/shake iz lane-run.md nisu u kodu).
10. **Endless / Lv label** u istom timer slotu — dugački stringovi lako prelaze.

---

## 4. Zahtjevi za redizajn

Trenutni izgled je **polazna tačka, ne šablon.**

### 4.1 MORA

- **Pravila i brojevi iz §2 ostaju.** Ne mijenjaj trajanje, 3 lanea, swipe, spawn šanse, 50%/100% loot, magnet formulu.
- **Pun ekran 1080 × 1920** — Run **nije** unutar hub chromea. Ne crtaј footer tabove.
- **Igrač u donjoj trećini** (oko 80–85% visine) — thumb zone.
- **3 jasna lanea** — vizuelno čitljiva bez oslanjanja samo na boju (oblik/trava/staza).
- **Prepreka ≠ pickup** na grayscale screenshotu.
- **Coin / Seed / Diamond** međusobno razlikoviti; Seed pokazuje tip (mini cvijet ili boja) — **cvijeće ne ilustriraš od nule** ako već postoji u `seeds-flowers` / handoff; smiješ kontejner/sjaj oko njega.
- **HUD:** preostalo vrijeme uvijek vidljivo; coin + seed counters uvijek; diamond smije biti diskretniji.
- **Tekst** ≥ **38 px**, brojevi ≥ **44 px**; EN; najduži timer string (`Endless · Hard · 60s`) mora stati.
- **Touch:** Pause (ako ga dodaš) i bitni brojači ≥ **120 px** hit.
- **Fair F2P:** bez mid-run ads, IAP, energije, "hurry" odbrojavanja koje stvara paniku. Timer smije biti miran countdown.
- **Companion lik** — ne mijenjaj dizajn Pipa/Mochija; samo pozu, sjenu, magnet ring, lane dust.

### 4.2 SMIJE (sloboda)

- Cijeli HUD raspored (gore/dolje, chips, progress ring umjesto `42s`).
- Vizuelni jezik laneova, scroll parallax (1–2 sloja, lagano).
- Prepreke po sezonama (mood tint već postoji — smiješ oblike).
- Pickup: idle bob, collect pop, **fly-to-counter**.
- Magnet ring / soft pulse kad je level > 0.
- Basket badge stil.
- Tutorial banner kao speech bubble / Pip cue.
- **Pause** overlay (Continue / Quit to Camp) — Quit = fail ili abandon? Predloži; default preporuka: Quit → loot kao fail **ili** potvrdi pa fail — **ne** troši revive.
- Fail / finish **1–2 kadra** prijelaza prije loot scene (freeze 0,2 s + soft shake).
- Kraći HUD tekstovi (tabela stari → novi).

Ideje van zadatka (power-ups mid-run, 4. lane, boss) — **odvojeno na kraju**, ne u glavnom mockupu.

---

## 5. Paleta i tokeni

Ista hub/Arena paleta:

| Uloga | Hex |
|-------|-----|
| Primary — mint | `#A8E6CF` |
| Secondary — lavanda | `#D4A5FF` |
| Accent / CTA — peach | `#FFB88C` |
| Coin gold | `#FFD56B` |
| UI gold | `#E8C44A` |
| Warm white | `#FFF8F0` |
| Soft sky | `#B8E0F5` |
| UI tekst | `#4A4A4A` |
| Outline | `#2D3436` |
| Fail / danger | npr. `#E88B8B` (označi ako nova) |
| Diamond | hladni cyan/teal uz postojeći soft sky |

**Tokeni:** radius 12 / 20 / 26 · border 2 px @ 10–14% · jedna drop sjena · outline ~20% tamniji od fill-a.

**Font:** Nunito OK u mockupu; mjere ostaju.

Sezonske mood boje smiju tretirati **pozadinu i prepreke**, ne cijeli HUD chrome (HUD ostaje čitljiv na svim sezonama).

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

**Lako:**

- HUD = `CanvasLayer` + `StyleBoxFlat` / TextureRect / Label.
- Entiteti = `Area2D` + Sprite2D (SVG/PNG) ili lagani `_draw`.
- Animacije = **tween** (pozicija, skala, alpha); fly-to-HUD OK.
- Pozadina = 1 PNG (+ opcioni 2. sloj parallax sprite).
- Season tint = `modulate` (već u kodu).

**Izbjegavati:**

- Blur / glow / bloom shadere; teške čestice po svakom pickupu (burst od 4–8 OK).
- Fiziku rigid body — ostaje kinematic scroll.
- Više od ~15–20 živih entiteta odjednom u mockupu gušće scene (balans spawna ostaje kodu).

**Layout:**

- Artboard **1080 × 1920**; mjere u px te baze.
- 1 dp ≈ 2,75 px → 44 pt ≈ **120 px**.
- Safe area: top notch / status — HUD ispod.

**Referentni tajming danas:**

| Pokret | Trajanje |
|--------|----------|
| Lane swipe tween | 0,12 s |
| Spawn interval | ~1,2 s |
| Speed ramp | svakih 15 s ×1,05 |
| Feed fade | 4 s |

---

## 7. Šta tražimo od CD (isporuka)

**P1 — obavezno:**

1. **Glavni ekran 1080 × 1920** — mid-run: mix coin + seed + 1 prepreka, Pip u srednjem laneu, HUD s timerom ~42s, brojači, Basket badge.
2. **Isti ekran — prazan start** (prvih ~2 s, malo entiteta) + **tutorial** varijanta (swipe banner).
3. **Spec sheet pickupa:** Coin, Seed (★1/★2/★3), Diamond — idle / collect / fly-to-HUD.
4. **Spec sheet prepreke:** 2–3 motiva (npr. kamen, panj, grm) + season tint primjer.
5. **HUD komponente:** timer (normal / Lv / Endless), counters, Basket, companion chip, Pause (ako predlažeš).
6. **Magnet:** level 0 vs level 2+ (vidljiv ring).
7. **Fail trenutak** (1–2 kadra) i **Finish** (timer 0).

**P2 — poželjno:**

8. Parallax / lane markings close-up.
9. Tabela animacija (swipe, collect, fail shake).
10. Lista asseta za export (SVG/PNG).

**Max 2 vizuelna smjera**, labelirana, s preporukom.

**Imena slojeva:** `RunHud`, `TimerChip`, `PickupBar`, `PickupFeed`, `BasketBadge`, `CompanionChip`, `PauseButton`, `LaneField`, `PlayerRunner`, `MagnetRing`, `CoinPickup`, `SeedPickup`, `DiamondPickup`, `Obstacle`, `TutorialBanner`, `FailFlash`, `FinishFlash`.

---

## 8. Ne tražimo

- Promjenu pravila, brojeva, spawn formula, 50%/100% loota.
- Loot ekran (Double / Revive / Retry / To Camp) — **zaseban brief kasnije**.
- Hub header/footer, Arena, Camp, Journal, Shop.
- Novi mid-run power-upi, ads, IAP.
- Redizajn lika Pipa (postoji) / pun set cvijeća (seeds-flowers brief).

---

## 9. Prompt za Claude Design

> Priloži ovaj fajl u CD, pa kopiraj sve iz bloka ispod.

```
Radim redizajn jednog ekrana mobilne igre: RUN (lane runner) — mjesto gdje
igrač swipea po 3 lanea, skuplja coinove i sjemenke, izbjegava prepreke.
Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D, bez retro efekata). Mood: cozy livada,
vedro, "satisfying".

Uz ovu poruku prilažem fajl "run-cd-brief.md". To je tvoja referenca: pravila
(§2), tekstovi (§2.4), trenutni raspored (§3), šta ne štima (§3.2), mora/smije
(§4), paleta (§5), tehnika (§6), isporuka (§7). Pročitaj ga cijelog prije rada
— §10 je za kasniji prenos u Godot, možeš ga preskočiti. Ako se nešto razlikuje,
važi fajl.

CILJ: Run treba da izgleda i osjeća se kao zabavan, čitljiv one-thumb runner
u istom vizuelnom jeziku kao hub/Arena — a da se 1:1 prenese u Godot 4.
Imaš punu slobodu u izgledu, HUD-u, animacijama i feedbacku. Pravila i brojevi
su fiksni.

KAKO RUN RADI (detalji u §2):
- 3 fiksna lanea (25/50/75 % širine). Swipe L/R = ±1 lane, tween 0,12 s.
- Svijet auto-scrolla odozgo; brzina raste blago svakih 15 s.
- Trajanje ~60 s (tutorial kraći). Istek = finish (100% loot). Sudar s
  preprekom = fail (50% loot). Zatim Loot ekran (NIJE dio ovog zadatka).
- Spawn: coin, seed (sezonski tipovi), rijetko diamond, ili prepreka.
- Magnet oko igrača skuplja pickupe (ne prepreke); radius raste s upgradeom.
- Basket loadout = +5% šanse za seed (badge u HUD-u kad je aktivan).
- Companion (Pip) trči u donjoj trećini ekrana.

GDJE ŽIVI: PUN ekran 1080 × 1920 — NIJE hub stranica. NE crtaj Shop/Journal/
Home/Camp/Arena footer. NE crtaj hub header valuta.

DIZAJNIRAJ (sloboda):
- HUD: timer, coin/seed(/diamond) counters, companion chip, Basket badge,
  opcioni Pause.
- 3 lanea čitljiva; pozadina livade (smije parallax 1–2 sloja).
- Pickupe: coin, seed, diamond — stanja idle/collect/fly-to-HUD.
- Prepreke: cozy, ne horror; razlikuju se od pickupa i bez boje.
- Magnet ring; tutorial banner; fail/finish 1–2 kadra prijelaza.
- Smiješ kraće HUD tekstove (tabela stari → novi).

MORA:
- Pravila/brojevi netaknuti. Igrač ~80–85% visine. Tekst ≥ 38 px, brojevi
  ≥ 44 px. Bez mid-run ads/IAP/energije. Ne redizajniraj lika Pipa.
- Prepreka ≠ pickup na grayscale. Endless/Lv timer stringovi moraju stati.

PALETA: mint #A8E6CF · lavanda #D4A5FF · peach #FFB88C · coin gold #FFD56B ·
UI gold #E8C44A · warm white #FFF8F0 · soft sky #B8E0F5 · tekst #4A4A4A ·
outline #2D3436. Zaobljeno, jedna blaga sjena, outline ~20% tamniji.

TEHNIČKI (Godot 4, OpenGL, slabiji Android):
- Artboard 1080 × 1920 px; mjere 1:1.
- Tween animacije; SVG/PNG spriteovi; bez blur/glow shadera; bez teških
  čestica. Paneli = ravna boja + border + jedna sjena.

ISPORUKA (statični artboardi, labelirani):
P1: (1) mid-run glavni ekran (2) start + tutorial (3) pickup spec sheet
(4) obstacle spec (5) HUD komponente (6) magnet 0 vs upgrade (7) fail + finish
P2: parallax/lane detail, tabela animacija, lista asseta.
Max 2 vizuelna smjera + preporuka.

IMENA SLOJEVA: RunHud, TimerChip, PickupBar, PickupFeed, BasketBadge,
CompanionChip, PauseButton, LaneField, PlayerRunner, MagnetRing, CoinPickup,
SeedPickup, DiamondPickup, Obstacle, TutorialBanner, FailFlash, FinishFlash.

NE RADI: loot ekran, hub chrome, Arena/Camp/Shop/Journal, nove mehanike,
ads/IAP, redizajn Pipa, pun cvjetni atlas. Ideje van zadatka — odvojeno na kraju.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot node / fajl | Napomena |
|---------|-------------------|----------|
| `RunHud` / `TimerChip` / `PickupBar` | `run_scene.tscn` → `HUD/TopHud/...` | `_update_hud()` u `run_controller.gd` |
| `PickupFeed` | `HUD/.../PickupFeed` (`run_pickup_feed.gd`) | `push_coin` / `push_seed` |
| `BasketBadge` | `LoadoutLabel` | `Basket: %s` |
| `CompanionChip` | `PipBadge` / `PipPortrait` / `PipName` | `get_companion_display_name()` |
| `PauseButton` | **ne postoji** — novi node + pause state | Ne miješati s loot Revive |
| `LaneField` | `Background` (`lane_background.gd`) + opcioni lane overlays | Season + cosmetic modulate |
| `PlayerRunner` | `Player` + `PipVisual` (`player.gd`, `pip_visual.gd`) | Lane tween 0,12 s; y = 0.82×H |
| `MagnetRing` | `Player/MagnetField` + draw u `pip_visual` | Radius iz `get_magnet_radius()` |
| `CoinPickup` | `scenes/run/coin.tscn` + `coin_visual.gd` | group `coin`/`pickup` |
| `SeedPickup` | `seed_pickup.tscn` + `seed_visual.gd` | `setup(type_id, rarity)` |
| `DiamondPickup` | `diamond_pickup.tscn` | 1/300 seed roll |
| `Obstacle` | `obstacle.tscn` (`Polygon2D` Visual) | `apply_season_tint()` |
| `TutorialBanner` | `TutorialBanner` label | run1/run2 eventi |
| `FailFlash` / `FinishFlash` | `_end_run` — danas instant `go_to_scene(LOOT)` | Dodati kratki beat prije transition |
| Novi asseti | `game/assets/sprites/run/` | `godot-import.ps1` + commit `.import` |

**Poznato pri pisanju briefa:**

1. Spec/docs još ponekad kažu "orb" — u kodu su **coin + seed + diamond**.
2. Pause je u `kontrole-i-input.md`, **nije** u `run_scene.tscn`.
3. Fail shake / freeze iz `lane-run.md` **nisu** implementirani.
4. Loot ekran je zaseban — ne rastezati ovaj handoff na Double/Revive UI.

**Gotovo kad (implementacija):**

- [ ] Mid-run ekran čitljiv na emulatoru; prepreka ≠ pickup na grayscale
- [ ] HUD stringovi (uključujući Endless) staju; brojevi ≥ 44 px
- [ ] Swipe i dalje 3 lanea / 0,12 s; magnet i spawn netaknuti
- [ ] Smokes: postojeći run_* + novi `run_redesign_smoke` po uzoru na arena
- [ ] Nema mid-run IAP/ads

---

## Odluke

| Datum | Odluka |
|-------|--------|
| 2026-09-22 | Brief napisan. Run = pun ekran (ne hub chrome). Loot ekran van scopea. Pravila/brojevi fiksni; CD = izgled + feel. |

## Otvorena pitanja (nakon CD-a)

- [ ] Pause — da / ne; Quit = fail loot ili potvrda?
- [ ] Fail/finish beat trajanje prije loot scene
- [ ] Koliko sezonskih varijanti prepreke u v1 (1 set + tint vs 3 motiva)
- [ ] Smjer A vs B

## Povezano

- [[../_index|Iskustvo]] — roditeljski hub
- [[hub-header-footer-cd-brief|hub-header-footer-cd-brief]] — stil referenca (Run nije u chromeu)
- [[merge-arena-cd-brief|merge-arena-cd-brief]] — isti format; sljedeća petlja nakon runa
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — cvijeće na seed pickupu
- [[../../02-design/mehanike/lane-run|lane-run]] — feel / monetizacija trenutak
- [[../../02-design/kontrole-i-input|kontrole-i-input]] — swipe, HUD zone
- [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]] — konstante
- [[../../02-design/spec-vertical-slice|spec-vertical-slice]] — §2 Run (dijelom zastario: "orb")
- [[../art-direction|art-direction]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
