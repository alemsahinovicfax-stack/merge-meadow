---
status: aktivan
tags: [meta, changelog]
---

# Changelog

## Sažetak

Promjene u dizajnu i dokumentaciji kroz vrijeme.

## 2026-06-30

- Inicijalna struktura dokumentacije (7 slojeva)
- Hub stranice, predlošci, seed dokumenti
- Faza 1 (Vizija) — scaffold s pitanjima za popunjavanje
- Dodan master razvoj dokument [[../06-production/RADIONICA-razvoj|RADIONICA-razvoj]] (faze 0–7) + Cursor pravilo za workflow ispitanja
- Faza 1 Korak 1: popunjen [[../01-vision/pitch|pitch]] — Merge Meadow (hybrid casual merge + runner)
- Faza 1 Korak 2: popunjen [[../01-vision/koncept|koncept]] — power fantasy + cozy kamp, player promise, anti-fantasy
- Faza 1 Korak 3: popunjen [[../01-vision/ciljana-publika|ciljana-publika]] — segmenti, session length, monetizacijski profil
- Faza 1 Korak 4: popunjen [[../01-vision/design-pillars|design-pillars]] — 3 pillara s prioritetom Fair F2P
- Faza 1 Korak 5: popunjen [[../01-vision/konkurencija-i-inspiracija|konkurencija]] — Mob Control, Merge Mansion, Subway Surfers
- **Faza 1 Vizija završena** — `trenutna_faza: 2` u [[../06-production/RADIONICA-razvoj|RADIONICA-razvoj]]
- **Faza 2 Core dizajn završena** — core loop, 3 mehanike, progresija, kontrole; `trenutna_faza: 3`
- **Faza 3 Sadržaj i iskustvo završena** — svijet, UI/UX flow, art direction; `trenutna_faza: 4`
- **Faza 4 Tehničko i scope** — Godot 4 (slab laptop), platforme, IN/OUT
- **Faza 5 Gate prolaz** — DoD 7/7
- Dodan [[../06-production/CHECKPOINT|CHECKPOINT]] — operativni vodič (HP Windows + iPhone workflow)
- M5½ dokumentacija detalji: monetizacija, ekonomija, arhitektura, likovi, nivoi, QA, rizici
- `podfaza: greybox-spreman` — spremno za M6 / `game/` folder
- Android-first strategija; emulator setup u [[../05-technical/platforme|platforme]]; Cursor rule ažuriran za session bootstrap
- CHECKPOINT: sekcija "Dokumentacija vs kod" — M5½ docs gotovo; prvi kod M6 B1–B3; sljedeći docs nakon B3
- Scope guard rule (`scope-guard.mdc`); `sigurnost.md`; `verzije-nakon-launcha.md`
- CHECKPOINT B0: `b0_aktivan` flag — kad zatvoreno, sekcija se briše, rule ne troši tokene
- **Obsidian full paket:** `AGENTS.md`, `.gitignore`, `00-personal/`, `frontmatter-shema`, `obsidian-setup`, daily notes template, `ai_sažetak` na ključnim docovima

## 2026-07-02

- Godot OpenGL fix (HP AMD): `scripts/godot-open.ps1` + `godot-dev-setup.md`; agent rule + CHECKPOINT `godot_launch`

## 2026-07-03

- **B0 zatvoreno** — mood board (`ref-01`, `ref-02`), privacy `mergemeadow.support@gmail.com`, `credentials.local.md` (gitignore)
- CHECKPOINT: `b0_aktivan: false`; B1 djelomično (Android Studio, Pixel_4, test APK)
- **GitHub** — private repo `merge-meadow`, početni commit dokumentacije
- **B1+B2 greybox kod** — `game/` Godot projekt (1080×1920, gl_compatibility), lane run: 3 lanea, swipe, auto-scroll, orbovi, prepreka, 75 s timer, loot overlay, 50% na fail, Retry
- `godot-open.ps1` otvara `game/` po defaultu

- **Godot priručnik** (`docs/05-technical/godot/`) — konvencije-koda, scene-node-pravila, fizika-kolizije, signali-komunikacija, input-touch, resursi-save, greske-katalog, dev-workflow; linkano u `_index`, `AGENTS.md`
- **Playtest B2 (prvi)** — bug: `loot_overlay` deklariran kao `Control` a scena `CanvasLayer` → `_ready()` pukao, run se nije pokretao (tajmer/orbovi/spawn mrtvi, swipe radio). Zabilježeno kao `greske-katalog` #1.

### B3 playtest — bilješke (2026-07-03)

- **Vizuelno / funkcionalnost / UX:** dobro nakon fixa #1 + start dugmeta
- **Swipe:** radi; instant snap osjećaj teleporta → **tween 0.12 s** (3 lanea, ne swerve)
- **Brzina scrolla:** neutralno — bez promjene
- **Fail loot:** floor na neparnim brojevima (5→2) osjećaj nepravedno → **`round(50%)`**
- **Swerve vs 3 lanea:** odloženo — odluka nakon tween playtesta (M7 ako treba)
- **Emulator Pixel_4:** System UI freeze pri pokretanju APK — preskočiti do M7/M8; greybox test F5 u editoru dovoljan

### B3 zatvoreno (2026-07-03, drugi krug)

- **Tween 0.12 s:** OK — nema više teleport feela
- **round(50%) fail loot:** OK (5 orbova → 3)
- **godot-watch:** radi — auto-restart na spremanje koda
- **Lane odluka:** **3 fiksna lanea + tween** za greybox/M7; fluid swerve ostaje otvoreno u `lane-run.md`
- **M6 exit:** greybox feel potvrđen u editoru; emulator/APK odgođeno

## 2026-07-03 (M7)

- **M7 C1 start** — `GameState` autoload, `main_menu` → `run` → `loot_screen` → `camp` loop
- Loot: Double/Revive placeholder gumbi; kamp merge T1+T1→T2; magnet upgrade (4× T2)
- Run: uklonjen inline loot/start overlay; tutorial banner na prvom runu

## Template za nove unose

```
## YYYY-MM-DD
- Promjena i razlog
```

## Povezano

- [[../00-home|Home]]
- [[otvorena-pitanja|otvorena-pitanja]]
