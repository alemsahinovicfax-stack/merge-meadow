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
- **C1 fix** — kamp 6→**9 slotova**, magnet cost 4→**2× T2** (prije nemoguć: 6 slotova → max 3 T2)
- **Magnet stvarni efekt** — `MagnetField` Area2D skuplja orbove u dometu (40 + 48/level px), vidljiv prsten; ne reagira na prepreke
- Kamp/loot tekst jasniji: "orbovi stižu kao T1 → merge → T2 → magnet"; orb guard protiv dvostrukog pickupa
- **godot-run.ps1** — jednokratno paljenje igre (agent pali JEDNOM na kraju, ne watch po izmjeni)
- **Revive bug fix** — "Revive" je samo prepisivao `last_loot` (kolizija s Double → broj orbova skakao gore/dolje "kako kad") i **nije nastavljao run**. Sad `request_revive()` vraća u run scenu i nastavlja tamo gdje si stao (zadržava skupljene orbove + preostalo vrijeme, čisti prepreke); max 1×/run; ne dira loot broj. `finish_run()` sada prima `elapsed`; dodan `_state` guard protiv dvostrukog `_end_run`.
- **Dokumentacija smjera (source of truth):** [[../02-design/spec-vertical-slice|spec-vertical-slice]] — tačno ponašanje svakog ekrana/mehanike + DoD; [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] — sve balans-konstante na jednom mjestu. CHECKPOINT Sekcija C dobila **C1½ build order** (spec-driven, mali koraci). Linkano u `gdd-overview`, `_index`. Cilj: kod prati spec, ne nagađamo dok kodiramo.
- **F1 identitet u kodu** — `PipDraw` proceduralni placeholder (zeko); main menu tagline + Pip portrait; run HUD `PipBadge` (Pip + ime). Uklonjen plavi kvadratić. Sljedeće: F2 novčići + sjeme.
- **F2 dvije valute u runu** — zlatni novčići (~70% pickupa) + zeleno Clover sjeme ★ (~30%); HUD Coins/Seeds; loot ekran oboje; `wallet_coins`; revive nosi coins+seeds. Stari `orb.tscn` zamijenjen `seed_pickup` + `coin`.
- **Bugfix run raspad** — viewport 0×0 u `_ready()` → Pip u (0,0), bez laneova; `_wait_for_viewport()` + `Line2D` guideovi. Fail: **50% sjemena i 50% novčića**. Scratch: progress traka umjesto tajmera; pitanja ekonomije/kamp brojača (`ideje-gameplay-ekonomija`).

## 2026-07-05

- **Art smjer:** **flat cartoon** cijela igra — bez pixel grida. Ažurirano: art-direction, ui-i-art-alati, scope, pitch, CHECKPOINT C2.
- **C2 alati:** Krita/Figma (Pip), Kenney flat UI.
- **C1½ save** — `user://player_save.json` v1; balans pass 1 (60 s run); fail/finish loot UI; UX-01 Main menu u kampu.

## 2026-07-04

- **F3 loot inventar po tipu** — `finish_run(seeds_by_type, coins, …)`; `last_seed_bag` / `carry_seed_bag`; loot ekran `+X Coins` / `+Y Clover`; `deposit_loot_to_camp()` deponira po tipu u slotove. `RUN_DURATION` ostaje **20 s** za playtest.
- **F4 kamp vrt** — 6 gredica; … (vidi changelog 2026-07-04 kasnije)
- **Kamp ekonomija (E2)** — 9 gredica, T2 keep/donate, staklenik 2 slota ★★★, zamjena 3 sjeme→8 coins, `discovered_blooms`.
- **F5 loadout** — 1 basket slot, +5% spawn; debug 20 coins + 20 seeds u kampu.
- **F6 tutorial** — Run1 45s / Run2 60s, vođenje, loadout nakon mergea.
- **F7 playtest ✅** — DoD prošao.
- **Post-tutorial hub** — main menu **Play** + **Camp**; tutorial save.

## 2026-07-07

- **M8 D1 run leveli** — `levels_1_10.json` + `RunLevelLibrary` curve 11–100; HUD `Lv X · Ys`; save `run_level`
- **M8 D2 endless** — main menu sekcija; Easy/Normal/Hard (Lv 20/50/85, spawn ×0.9); odvojeno od kampanje
- **C4 iOS pipeline** — `export_presets.cfg` (Android Debug + iOS), GitHub Actions `ios-xcode-export.yml`, `ios-export.md`
- **C4 safe area** — `safe_area_helper.gd` na run HUD + settings gumbima
- **C3 AdManager** — rewarded stub (~1s) za Double/Revive; hook za Poing AdMob plugin
- **C3 IAPManager** — shop ekran (remove ads, starter pack); save `ads_removed` / `starter_pack_owned`
- **C2 Kenney UI ikone** — 6 PNG iz `game-icons` (settings, wallet, retry, home, revive, double) → loot + kamp + main menu
- **C2 pastel gumbi** — `ui_palette.gd`; `UiClickButton` varijante primary/accent/secondary/subtle; paneli warm white / mint
- **C2 play ikona** — Figma Make `Play Button.make` zamijenio tamni placeholder

## 2026-07-06

- **Godot asset import** — `godot-import.ps1`; `godot-run.ps1` auto-import; rule `godot-assets-import.mdc`; greske-katalog #6 (nevidljiv sprite)
- **C2 Pip sprite** — izvučen iz Figma Make `.make` exporta; `pip_idle.svg` u `game/assets/sprites/`; `PipDraw` zamijenjen `Sprite2D` (run) + texture draw (main menu, HUD badge)

## Template za nove unose

```
## YYYY-MM-DD
- Promjena i razlog
```

## Povezano

- [[../00-home|Home]]
- [[otvorena-pitanja|otvorena-pitanja]]
