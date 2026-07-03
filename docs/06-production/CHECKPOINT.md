---
type: produkcija
status: aktivan
milestone: M6
tags: [produkcija, checkpoint, operativa]
povezano:
  - RADIONICA-razvoj
  - milestone-i
  - scope-i-granice
ai_sažetak: "Operativni hub — frontmatter prvo; prva [ ] u aktivnoj sekciji je sljedeći korak."
trenutna_faza: 5
podfaza: greybox-aktivan
aktivna_sekcija: B
b0_aktivan: false
sljedeci_korak: "B3: 5 min playtest na Pixel_4 emulatoru — bilješke feela + odluka swerve vs 3 lanea"
zadnja_sesija: "Godot priručnik (docs/05-technical/godot/) + fix bug #1 (loot_overlay tip) + start dugme/state"
zadnje_azurirano: 2026-07-03
dev_stroj: "HP laptop, Windows, AMD Radeon integrisana — Godot samo OpenGL"
godot_launch: "scripts/godot-open.ps1 (--rendering-driver opengl3)"
test_uredjaji:
  - "Android emulator Pixel_4 (primarni — svaki dan)"
  - "iPhone (iOS test — M7, C4)"
strategija_platforme: android-first
# --- Praćenje faza (agent + ti) ---
dokumentacija_zavrsena_do: "M5½ — CHECKPOINT Sekcija A (A1–A4)"
prva_faza_kodiranja: "M6 — CHECKPOINT Sekcija B (B1–B3)"
sljedeca_runda_dokumentacije: "CHECKPOINT B3 — nakon greybox playtesta"
---

# CHECKPOINT — operativni vodič

> **Otvori ovaj fajl na početku svake sesije.**  
> Redoslijed: `CHECKPOINT` → `RADIONICA-razvoj` → konkretni doc → tek onda `game/`.

## Gdje smo

| Polje | Vrijednost |
|-------|------------|
| **Faza** | 5 — Gate prošao ✅ |
| **Podfaza** | `greybox-spreman` — dokumentacija detalji **završena**; sljedeće M6 (`game/`) |
| **Igra** | Merge Meadow — hybrid casual lane run + merge kamp |
| **Engine** | Godot 4.x (HP laptop / Windows) |
| **Strategija** | **Android-first** — jedan kod, iOS export kasnije (M7) |
| **Test** | Emulator (dnevno) → stariji Android (fizički) → iPhone (M7) |

## Dokumentacija vs kod — kada što radiš

### Dokumentacija “faza 1” — **ZAVRŠENA**

| Do čega | Milestone | Checkpoint | Status |
|---------|-----------|------------|--------|
| Planiranje prije koda | **M5½** | **Sekcija A** (A1–A4) | ✅ **Gotovo** |

Od sada **ne pišeš** novu viziju, pitch, core loop ni scope osim ako nešto **svjesno mijenjaš** nakon playtesta (tada ažuriraj samo dotični doc + `otvorena-pitanja`).

### Prva faza kodiranja — **M6 greybox** (sada)

| Pitanje | Odgovor |
|---------|---------|
| **Do čega kodiram?** | **CHECKPOINT B1 → B3** (M6), **ne** do launcha / v1 |
| **Što gradim?** | Samo **lane run** + placeholder loot — bez mergea, shopa, 100 levela |
| **Kada M6 završava?** | APK na emulatoru + **5 min playtest** + bilješke (B3) |
| **Je li ovo “verzija 1”?** | **Ne.** Ovo je **greybox prototip** — dokaz feela. v1 launch = **M8 / Sekcija D** |

```
M5½ docs ✅  →  M6 kod (B1–B3)  →  kratko docs  →  M7 kod (C)  →  docs D  →  M8 launch
              ↑ TI SI OVDJE
```

### Kada **nastaviti pisati** dokumentaciju (sljedeće runde)

| # | Kada (trigger) | Milestone | Checkpoint | Što ažurirati |
|---|----------------|-----------|------------|---------------|
| 1 | **Nakon M6 playtesta** | M6 završen | **B3** | `changelog`, `lane-run.md` (swerve vs 3 lanea), `otvorena-pitanja` |
| 2 | **Tijekom M7** | M7 | C1–C3 | `ekonomija` brojke ako treba, `ui-ux` sitnice, test bilješke |
| 3 | **Nakon M7 playtesta** | M7 završen | **C** exit | `milestone-i`, `scope` samo ako se scope promijenio |
| 4 | **Prije store objave** | M8 | **Sekcija D** | store listing, ASO keywords, screenshot plan |
| 5 | **Tjedno** (5 min) | — | — | `otvorena-pitanja` pregled |

**Pravilo:** između triggera **1–2** → uglavnom **kodiraš**, ne širiš dokumentaciju. Nova ideja? Prvo `scope-i-granice` + pillari — ako nije IN, ne kodiraj.

### ⚠️ Scope guard (agent + ti)

Ako ti ili agent predložite nešto **izvan tablice “Scope po milestoneu”** u [[scope-i-granice|scope-i-granice]], agent **mora** ispisati upozorenje `⚠️ SCOPE` i ne nastaviti kod bez tvoje potvrde.

Cursor rule: `.cursor/rules/scope-guard.mdc`

**Ti možeš pitati:** “Je li ovo u scopeu?” — agent provjerava CHECKPOINT + milestone + OUT listu.

### Pregled cijelog puta

| Faza | Tip rada | Milestone | Checkpoint | Trajanje (okvirno) |
|------|----------|-----------|------------|-------------------|
| Planiranje | 📝 dokumentacija | M0–M5½ | A | ✅ gotovo |
| **Greybox** | **💻 prvi kod** | **M6** | **B** | dok B3 nije ✅ |
| Ažuriranje | 📝 kratko | — | B3 | 1 sesija |
| Vertical slice | 💻 drugi kod | M7 | C | dok C nije ✅ |
| Launch prep | 📝 + 💻 | M8 | D | 100 runova, shop, store |

## Android-first — zašto i kako

**Jedna igra, jedan Godot projekt** — ne pišemo dvije verzije. Razlika je samo u **exportu** na kraju.

| Faza | Android | iOS |
|------|---------|-----|
| M6 greybox | ✅ svaki dan | ❌ preskoči |
| M7 slice | ✅ emulator + Android tel. | ⚠️ tek kad loop radi (Mac/CI) |
| Launch | ✅ Play prvi | ✅ App Store nakon |

**Ne radi oba paralelno na startu** — iOS s Windowsa ne možeš buildati; paralelno bi gubio vrijeme. Prvo dokazati loop na Androidu, pa **isti projekt** exportati na iOS.

## Tvoj setup (HP Windows + uređaji)

```
┌─────────────────┐     export APK      ┌──────────────────────┐
│  HP Laptop      │ ──────────────────► │ 1. Android emulator   │  ← svaki dan
│  Windows        │                     │ 2. Stariji Android tel│  ← kad imaš
│  Godot 4 editor │                     └──────────────────────┘
└────────┬────────┘
         │ isti projekt, export IPA (M7+)
         │ ⚠️ samo Mac ili cloud CI
         ▼
┌─────────────────┐                     ┌──────────────────────┐
│  Mac (kasnije)  │ ──────────────────► │  iPhone (tvoj)       │
└─────────────────┘                     └──────────────────────┘
```

| Korak | Gdje | Kada |
|-------|------|------|
| Dnevni dev | HP + Godot | uvijek |
| Brzi test | **Android emulator** | svaka sesija M6+ |
| Fizički Android | Stariji telefon (USB debug) | kad nabaviš — test performansi |
| iOS na iPhoneu | Mac/CI → IPA | **M7 (CHECKPOINT C4)** |
| Store | Play prvi, App Store drugi | Launch |

---

## Kako koristiti ovaj fajl

1. Nađi **prvu neoznačenu** stavku u aktivnoj sekciji.
2. Radi **jednu** stavku po sesiji (ili jednu malu grupu).
3. Označi `[x]` kad je gotovo u ovom fajlu + u ciljnom `.md`.
4. Ažuriraj `zadnje_azurirano` u frontmatteru.
5. Kad je **Sekcija A = 100%** → promijeni `podfaza` u `greybox` i kreni `game/`.

---

## Sekcija A — Dokumentacija detalji (PRIJE koda)

**Cilj:** Nijedan kritični doc ne smije biti prazan TBD kad otvoriš Godot.

### A1 — Vizija i dizajn (jezgro)

- [x] [[../01-vision/pitch|pitch]]
- [x] [[../01-vision/koncept|koncept]]
- [x] [[../01-vision/ciljana-publika|ciljana-publika]]
- [x] [[../01-vision/design-pillars|design-pillars]]
- [x] [[../01-vision/konkurencija-i-inspiracija|konkurencija]]
- [x] [[../02-design/core-loop|core-loop]]
- [x] [[../02-design/mehanike/_index|mehanike]] (3 fajla)
- [x] [[../02-design/progresija|progresija]]
- [x] [[../02-design/kontrole-i-input|kontrole-i-input]]
- [x] [[../02-design/gdd-overview|gdd-overview]] — executive index
- [x] [[../02-design/monetizacija|monetizacija]] — ads + IAP detalji
- [x] [[../02-design/ekonomija|ekonomija]] — valute, sinkovi, brojke draft

### A2 — Iskustvo i sadržaj

- [x] [[../03-content/svijet-i-lore|svijet-i-lore]]
- [x] [[../04-experience/ui-ux|ui-ux]]
- [x] [[../04-experience/art-direction|art-direction]]
- [x] [[../04-experience/audio-direction|audio-direction]]
- [x] [[../04-experience/pristupacnost|pristupacnost]] — minimalni standardi
- [x] [[../03-content/likovi/_index|likovi]] — Pip + Mochi kartice
- [x] [[../03-content/nivoi/_index|nivoi]] — run level struktura (1–100)

### A3 — Tehničko i produkcija

- [x] [[engine-odluka|engine-odluka]]
- [x] [[platforme|platforme]] — uklj. Windows + iPhone workflow
- [x] [[scope-i-granice|scope-i-granice]]
- [x] [[arhitektura|arhitektura]] — Godot scene tree moduli
- [x] [[performanse|performanse]] — FPS, RAM ciljevi
- [x] [[rizici|rizici]] — top rizici + mitigacija
- [x] [[testiranje|testiranje]] — QA plan za greybox
- [x] [[../07-meta/glossary|glossary]] — run, session, merge termini

### A4 — Gate provjera (ponovno)

- [x] [[../00-home|00-home]] DoD 7/7
- [x] Svi A1–A3 checkboxovi gore = `[x]`
- [x] Nema kritičnih TBD u monetizacija / ekonomija / arhitektura

**Exit Sekcija A:** ✅ **2026-06-30** — dopušten `game/` folder kad kreneš M6.

---

## B0 — zatvoreno ✅ (2026-07-03)

- **Mood board** — `ref-01-lane-runner.png`, `ref-02-merge-camp.png` + [[../07-meta/reference/images/README|images/README]]
- **Privacy email** — `mergemeadow.support@gmail.com` u [[../05-technical/privacy-policy-draft|privacy-policy-draft]]
- **Narativ** OUT v1 · **ekonomija-balans.csv** predložak (ranije)

---

## Sekcija B — M6 Greybox (Godot prototip)

**Preduvjet:** Sekcija A ✅  
**Cilj:** Lane run igriv 60–90 s, placeholder art, Android APK na HP-u.

### B1 — Projekt setup

- [x] Instalirati **Godot 4.7** na HP Windows — pokretanje: `scripts/godot-open.bat` ([[../05-technical/godot-dev-setup|godot-dev-setup]])
- [x] Instalirati **Android Studio** (samo za SDK + emulator, ne za kod)
- [x] Kreirati AVD emulator — **Pixel_4** ([[../05-technical/platforme#Android emulator (HP)|platforme]])
- [x] Kreirati `game/` Godot projekt (portrait 1080×1920)
- [x] Git init + `.gitignore` za Godot (repo: `merge-meadow`)
- [x] Android export template + prvi debug APK na emulatoru (test: `Documents\new-game-projecttt`; export za `game/` — jednom u editoru)

### B2 — Lane run (prva mehanika)

- [x] Scena: Player + 3 lanea + auto-scroll
- [x] Swipe L/R input
- [x] Spawn orbova + jedna prepreka
- [x] Kraj runa → placeholder loot broj
- [x] 50% loot na fail
- [x] Start dugme + READY/RUNNING/ENDED state (jasan start/kraj) — nakon 1. playtesta
- [x] Fix: `loot_overlay` tip `CanvasLayer` (bug #1, `godot/greske-katalog`)

> **Godot kod:** prije izmjena u `game/` vidi [[../05-technical/godot/_index|Godot priručnik]].

### B3 — Playtest greybox

- [ ] 5 min igre na emulatoru — bilješke feela
- [ ] Bilješke u [[../07-meta/changelog|changelog]]
- [ ] Odluka: fluid swerve vs 3 fiksna lanea

**Exit M6:** APK koji možeš poslati prijatelju za feel feedback.

---

## Sekcija C — M7 Vertical slice

**Preduvjet:** M6 ✅

### C1 — Kompletan loop (greybox → polish)

- [ ] Loot ekran (×2 rewarded placeholder, revive, retry, kamp)
- [ ] Kamp: merge 2→1 (min 2 tiera)
- [ ] 1 upgrade linija (magnet ili množitelj)
- [ ] Main menu → Play → run → loot → kamp → Play
- [ ] Tutorial run (prvi launch)

### C2 — Art pass (slice scope)

- [ ] Flat orbs + pastel lane (art-direction paleta)
- [ ] Pixel UI ikone (min set)
- [ ] Pip placeholder sprite

### C3 — Monetizacija (test integracija)

- [ ] AdMob rewarded test (test ad unit)
- [ ] IAP stub / test purchase flow (Android)

### C4 — iOS na iPhoneu

- [ ] iOS export pipeline riješen (Mac ili CI)
- [ ] Build na tvoj iPhone (TestFlight ili dev install)
- [ ] Test: run + merge na stvarnom uređaju

**Exit M7:** Vanjski playtester igra 5 min bez vođenja.

---

## Sekcija D — Launch prep (nakon M7)

- [ ] 100 run level konfiguracija
- [ ] Endless mode
- [ ] Shop: remove ads + starter pack
- [ ] EN store listing + screenshots
- [ ] Google Play internal test
- [ ] App Store Connect (iOS)
- [ ] €50–100 CPI test kampanja

---

## Sljedeća akcija (sada)

1. **B3:** Export APK iz `game/` → 5 min playtest na Pixel_4 → bilješke u changelog
2. Odluka: fluid swerve vs 3 fiksna lanea (trenutno: 3 lane snap)

## Povezano

- [[RADIONICA-razvoj|RADIONICA-razvoj]] — faze 0–7
- [[milestone-i|milestone-i]] — milestone sažetak
- [[roadmap|roadmap]]
- [[../00-home|Home]]
