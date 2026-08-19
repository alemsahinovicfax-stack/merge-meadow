---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, checkpoint, operativa]
povezano:
  - RADIONICA-razvoj
  - milestone-i
  - scope-i-granice
ai_sažetak: "Operativni hub — frontmatter prvo; prva [ ] u aktivnoj sekciji je sljedeći korak."
trenutna_faza: 5
podfaza: d0-prelaunch
aktivna_sekcija: D
b0_aktivan: false
sljedeci_korak: "Plan mode: HOME-A (flatten Home, kill Panel) — plan-prompts-home-polish"
zadnja_sesija: "HOME-P0 — Home polish docs (free 3-slot strip, kill Panel); SEZ-01 pushed"
zadnje_azurirano: 2026-08-19
spec_slice: "docs/02-design/spec-vertical-slice.md (source of truth) + ekonomija-brojevi.md"
dev_stroj: "HP laptop, Windows, AMD Radeon integrisana — Godot samo OpenGL"
godot_launch: "scripts/godot-open.ps1 (--rendering-driver opengl3)"
test_uredjaji:
  - "Android emulator Pixel_4_API33 (API 33, host GPU — primarni)"
  - "Android emulator Pixel_4 (API 30 — NE za Godot 4, samo GLES2 guest)"
  - "iPhone (iOS test — M7, C4)"
strategija_platforme: "android-first; iOS kad prikupi ~99 USD (Apple Developer)"
# --- Praćenje faza (agent + ti) ---
dokumentacija_zavrsena_do: "M5½ — CHECKPOINT Sekcija A (A1–A4)"
prva_faza_kodiranja: "M6 — CHECKPOINT Sekcija B (B1–B3) ✅"
sljedeca_runda_dokumentacije: "Prije store (D0/D4) — listing/ASO; inače samo sync uz kod"
---

# CHECKPOINT — operativni vodič

> **Otvori ovaj fajl na početku svake sesije.**  
> Redoslijed: `CHECKPOINT` → `RADIONICA-razvoj` → konkretni doc → tek onda `game/`.

## Gdje smo

| Polje | Vrijednost |
|-------|------------|
| **Milestone** | **M8** — Launch prep (Sekcija D) |
| **Podfaza** | `d0-prelaunch` + **SEZ-01** P0–E ✅ + **HOME-P0** docs; Bug-006–032 ✅ |
| **Igra** | Merge Meadow — hybrid casual lane run + merge kamp |
| **Engine** | Godot 4.x (HP laptop / Windows) |
| **Save** | Lokalni JSON (`user://player_save.json`) — **bez** server/baze u v1 |
| **Strategija** | **Android-first** — Play nakon D0 + **25 USD**; **iOS** kad ~**99 USD** |
| **Test** | Emulator (dnevno) → stariji Android (fizički) → iPhone (Faza 4) |

## Dokumentacija vs kod — kada što radiš

### Dokumentacija “faza 1” — **ZAVRŠENA**

| Do čega | Milestone | Checkpoint | Status |
|---------|-----------|------------|--------|
| Planiranje prije koda | **M5½** | **Sekcija A** (A1–A4) | ✅ **Gotovo** |

Od sada **ne pišeš** novu viziju, pitch, core loop ni scope osim ako nešto **svjesno mijenjaš** nakon playtesta (tada ažuriraj samo dotični doc + `otvorena-pitanja`). **Veliki docs refactor nije potreban** — samo sync uz kod.

### Kodiranje — **M8 / D0** (sada)

| Pitanje | Odgovor |
|---------|---------|
| **Do čega kodiram?** | **D0** (pre-launch) — funkcionalnost ✅, pa polish (D0-P) + monetizacija prod (D0-M) |
| **Što je gotovo?** | M6 greybox ✅ · M7 slice ✅ · D0 Blok A/B gameplay+sadržaj (većina) · D0-F F0–F4 ✅ |
| **Što slijedi?** | Bug lista → fix → 5-min playtest → **D0-P** (SFX, art, Settings) → D0-M → Play internal |
| **Je li ovo “verzija 1”?** | Još ne — v1 = D0 ✅ + Play naknada. Store listing draft već postoji (D4). |

```
M5½ docs ✅ → M6 ✅ → M7 ✅ → M8 D0-F ✅ → D0-P / D0-M → Play launch
                                         ↑ TI SI OVDJE
```

### Kada **nastaviti pisati** dokumentaciju (sljedeće runde)

| # | Kada (trigger) | Milestone | Checkpoint | Što ažurirati |
|---|----------------|-----------|------------|---------------|
| 1 | **Nakon M6 playtesta** | M6 | **B3** | ✅ urađeno |
| 2 | **Tijekom M7** | M7 | C1–C3 | ✅ urađeno (ekonomija, UI sitnice) |
| 3 | **Nakon M7 playtesta** | M7 | **C** exit | ✅ / po potrebi scope |
| 4 | **Prije store objave** | M8 | **Sekcija D** | store listing, ASO, screenshot plan (D4 draft ✅) |
| 5 | **Tjedno** (5 min) | — | — | `otvorena-pitanja` pregled |

**Pravilo:** dok traje D0 → uglavnom **kod + playtest**, docs samo sync. Nova ideja? Prvo `scope-i-granice` + pillari — ako nije IN, ne kodiraj.

### ⚠️ Scope guard (agent + ti)

Ako ti ili agent predložite nešto **izvan tablice “Scope po milestoneu”** u [[scope-i-granice|scope-i-granice]], agent **mora** ispisati upozorenje `⚠️ SCOPE` i ne nastaviti kod bez tvoje potvrde.

Cursor rule: `.cursor/rules/scope-guard.mdc`

**Ti možeš pitati:** “Je li ovo u scopeu?” — agent provjerava CHECKPOINT + milestone + OUT listu.

### Pregled cijelog puta

| Faza | Tip rada | Milestone | Checkpoint | Trajanje (okvirno) |
|------|----------|-----------|------------|-------------------|
| Planiranje | 📝 dokumentacija | M0–M5½ | A | ✅ gotovo |
| Greybox | 💻 prvi kod | M6 | B | ✅ gotovo |
| Ažuriranje | 📝 kratko | — | B3 | ✅ gotovo |
| Vertical slice | 💻 drugi kod | M7 | C | ✅ gotovo (C4 iPhone build još otvoren) |
| **Launch prep** | **📝 + 💻** | **M8** | **D** | **D0-F ✅ → D0-P / D0-M → Play** |

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

1. Nađi **prvu neoznačenu** stavku u aktivnoj sekciji (**D**).
2. Radi **jednu** stavku po sesiji (ili jednu malu grupu).
3. Označi `[x]` kad je gotovo u ovom fajlu + u ciljnom `.md`.
4. Ažuriraj `zadnje_azurirano` u frontmatteru.
5. Aktivna sekcija = **D** — ne vraćaj se na A/B osim bugfixa u starom kodu.

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

- [x] 5 min igre — editor + `godot-watch` (emulator preskočen, System UI freeze)
- [x] Bilješke u [[../07-meta/changelog|changelog]]
- [x] Odluka lanea: **3 fiksna lanea + tween 0.12 s**; fluid swerve → otvoreno M7 ako treba

**Exit M6:** ✅ greybox feel potvrđen u editoru (APK/vanjski feedback opcionalno kasnije).

---

## Sekcija C — M7 Vertical slice

**Preduvjet:** M6 ✅

> **Source of truth za slice:** [[../02-design/spec-vertical-slice|spec-vertical-slice]] (ponašanje po ekranu + DoD) i [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] (sve konstante). **Prije kodiranja mehanike otvori spec — kod prati spec.**

### C1 — Kompletan loop (greybox → polish)

- [x] Loot ekran (×2 rewarded placeholder, revive, retry, kamp)
- [x] Kamp: merge 2→1 (min 2 tiera)
- [x] 1 upgrade linija (magnet)
- [x] Main menu → Play → run → loot → kamp → Play
- [x] Tutorial hint (prvi launch — main menu + run banner)
- [x] **Revive fix** — revive sada NASTAVLJA run (ne dira loot); Double+Revive više ne skaču broj

### C1½ — Build order (spec-driven, mali koraci)

> Svaki korak: otvori spec → kodiraj → headless smoke → 5 min test → `[x]`. Jedan korac po sesiji.

- [x] **Odluka: save na disk?** — **minimalni JSON v1** u M7 (`user://player_save.json`); F8.7 proširi
- [x] **Balans pass 1** — RUN **60 s** post-tutorial; spawn/magnet bez promjene ([[../02-design/ekonomija-brojevi|brojevi]] § pass 1)
- [x] **Fail/finish feedback** — loot ekran: boja trake/naslova + `X → Y` na failu
- [x] Prelazak na **C2 art pass** kad loop feel potvrđen

### C2 — Art pass (slice scope)

> **Operativni vodič:** [[../04-experience/ui-i-art-alati|ui-i-art-alati]] — flat cartoon; Krita/Figma (Pip) + Kenney flat UI.

- [x] Flat cartoon pickupe + pastel lane (art-direction paleta) — lane: `lane_background.png` Figma
- [x] Flat UI ikone (min set) — Kenney `game-icons` → `game/assets/ui/kenney/`
- [x] Pip flat cartoon sprite — **Figma Make** → `game/assets/sprites/pip_idle.svg`

### C3 — Monetizacija (test integracija)

- [x] AdMob rewarded test (test ad unit) — `AdManager` stub + plugin hook
- [x] IAP stub / test purchase flow (Android) — `IAPManager` + `shop_screen`

### C4 — iOS na iPhoneu

- [x] iOS export pipeline — `export_presets.cfg` + `.github/workflows/ios-xcode-export.yml` + [[../05-technical/godot/ios-export|ios-export]]
- [ ] Build na tvoj iPhone (TestFlight ili dev install) — **zahtijeva Mac ili GHA artifact**
- [ ] Test: run + merge na stvarnom uređaju

**Exit M7:** Vanjski playtester igra 5 min bez vođenja.

---

## Sekcija D — Launch prep (nakon M7)

> **Plan objave (2026-07-11):** [[troskovi-launcha|troskovi-launcha]] — **Faza 1** polish + sve v1 ideje (**0 USD**) → **Faza 2** Play **25 USD** (Android only) → **Faza 3** updates dok se ne prikupi **~99 USD** → **Faza 4** iOS.

### D0 — Pre-launch polish (prije store naknade)

> Detaljna tablica: [[d0-prelaunch-checklist|d0-prelaunch-checklist]] (~55% gotovo, 2026-07-11).

**Blok A — gameplay (scope IN)**
- [x] Merge **T3** (MAX_MERGE_TIER 3)
- [x] Upgrade **množitelj** (Loot Boost Lv 4, ×2.0)
- [x] Spawn pool — **Seed Almanac** (lifetime unlock + coins shortcut)
- [x] **Kamp A+C** — torba soft cap, auto-plant, Keep oslobađa gredicu, +3 gredice na max Sprinkler
- [x] **Daily chest** u kampu

**Blok B — sadržaj**
- [ ] Spriteovi sjemena/cvijeta po tipu (min 7, cilj 10) — 🟡 7 procedural — **odgođeno u D0-P**
- [x] **Mochi** ljubimac unlock (cosmetic) — kamp Lv 2, companion picker, run skin
- [x] **Dnevnik** kolekcije (zaseban ekran) — Bloom Album, 📖 u kampu, NEW badge
- [x] Shop: kozmetika + **booster consumables**

### D0-F — Funkcionalnost prije polish (sada)

> Redoslijed promijenjen 2026-07-29. Detaljna matrica: [[d0-functional-audit|d0-functional-audit]].

- [x] **F0** — CHECKPOINT + checklist + audit doc
- [x] **F1** — funkcionalni audit (meta hub matrica + headless smokes)
- [x] **F2** — debug (meta hub page slot, run HUD guard, settings placeholder)
- [x] **F3** — spec sync (`spec-vertical-slice` → merge arena + meta hub)
- [x] **F4** — balans pass 1 (`balance_snapshot`, `ekonomija-brojevi`); **5-min playtest** → ručno

**Blok C — polish** *(nakon F4 + playtest — D0-P)*
- [ ] **SFX** (pickup, merge, fail)
- [ ] Art pass (kamp biljke, splash/branding)
- [ ] Settings ekran (sound, restore)
- [ ] `DEBUG_DEV_RESOURCES` off + release AAB test
- [ ] Vanjski playtest 5 min (M7 exit ponovno)

**Blok D — monetizacija production** *(nakon F4 — D0-M)*
- [ ] Poing **AdMob + Billing** plugin na Androidu
- [ ] Production ad unit ID-evi (ne test)

**Već gotovo (D0)**
- [x] 100 run level konfiguracija — **D1a** JSON 1–10 + **D1b** curve 11–100 (`RunLevelLibrary`)
- [x] Endless mode — **D2 stub** main menu, Easy/Normal/Hard (Lv 20/50/85 base, spawn ×0.9), odvojeno od kampanje 1–100
- [x] Shop: remove ads + starter pack — **D3** `IAPManager` billing hook, restore, shop UI, interstitial respects `ads_removed`
- [x] EN store listing + screenshots — **D4** 8× PNG u `marketing/store/screenshots/`, copy u `store-listing-en.md`
- [ ] Google Play internal test — **Faza 2** (nakon D0 + **25 USD**)
- [ ] Google Play production launch — **Faza 2**
- [ ] App Store Connect (iOS) — **Faza 4** (nakon ~**99 USD** + iOS prilagođavanje)
- [ ] €50–100 CPI test kampanja — **Faza 3** (nakon Android launcha)

---

## Sljedeća akcija (sada)

1. **Plan mode:** HOME-A — zalijepi prompt **Prompt — HOME-A** iz [[plan-prompts-home-polish|plan-prompts-home-polish]]
2. **Ne** plaćati Play Console dok D0 nije ✅

## Povezano

- [[RADIONICA-razvoj|RADIONICA-razvoj]] — faze 0–7
- [[milestone-i|milestone-i]] — milestone sažetak
- [[roadmap|roadmap]]
- [[../00-home|Home]]
