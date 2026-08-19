---
status: aktivan
tags: [meta, changelog]
---

# Changelog

## Sažetak

Promjene u dizajnu i dokumentaciji kroz vrijeme.

## 2026-08-19

- **HOME-P0** — Home polish spec: ukinuti Panel; 3-slot **free** swipe traka; pitanja P16–P27; prompti [[../06-production/plan-prompts-home-polish|plan-prompts-home-polish]]
- **SEZ-E** — paid season IAP stub (`season_pack_moonlit_warren` / `coral_tide`); Shop Season packs + Browser Premium live; smoke `season_iap_smoke`
- **SEZ-D** — run spawn = SeasonDef ∩ unlocked; S2 stub pool clover/daisy/buttercup; BG + obstacle tint; smoke `season_run_smoke`
- **SEZ-C** — Home Season Stage + next-free teaser → Unlock sheet (P11); Browser free; paid placeholder; hub swipe isolation; smoke `season_home_smoke`
- **SEZ-B** — SeasonDef JSON katalog + GameState `active`/`unlocked`/`owned` + free unlock (T3 check-only) + save v9; smoke `season_unlock_smoke`
- **SEZ-P0** — SEZ-01 **IN v1.1** (nije v1 launch); P11 **Unlock sheet only**; CHECKPOINT → SEZ-B
- **SEZ-01** plan prompt paket — [[../06-production/plan-prompts-sez-01|plan-prompts-sez-01]] (P0 scope → B data → C Home → D run → E paid); freeze P1–P15 u [[../03-content/ideje-sezone-pitanja|pitanja]]

## 2026-08-18

- **SEZ-01** scratch docs — sezone/teme (Country Bloom S1, free linear + paid IAP, Home Stage): [[../03-content/ideje-sezone|ideje-sezone]] + UX / ekonomija / content / data-model / [[../03-content/ideje-sezone-pitanja|pitanja]]; OUT v1, kandidat v1.1+

## 2026-08-16

- **Bug-030** — Rarity theme bg: ★1 plava / ★2 ljubičasta / ★3 zlatna (Album redovi + Garden seed chipovi); locked sivo
- **Bug-032** — Garden/Flower UX: SeedBagScroll parity; T3 fitted flower icon; UI Crystal→Flower (API UniqueName ostaje)
- **Bug-031 UI** — Garden chip price: soft-gold pill + OUTLINE 28px broj + veći coin (čitljivost)
- **Bug-031 UI** — Garden chip price badge: desno broj + coin ikona (bez "seed = N C")
- **Bug-031** — Exchange po rarity: seed ★1/2/3 = 1/2/4 C; flower 5/10/20; chip cost captions; leftover n×rate
- **Bug-029** — T1 Album sprout unify: `CampPlantDraw.draw_fitted_plant`; bag / arena chip+peek / run pickup
- **Bug-029–032** plan prompt paket — [[../06-production/plan-prompts-bug-029-032|plan-prompts-bug-029-032]] (T1 unify, rarity theme, exchange balance, Garden/Flower UX); redoslijed **029 → 030 → 031 → 032**
- **Bug-028** — `stash_garden_crystal` diže `collection_kept_tiers` na T3 (Journal T3 nakon arena merge)
- **Bug-026** — Journal: T1/T2/T3 ikone scale-fit (bez clipa); 64px; unlock pravila ista; paket 024–027 ✅
- **Bug-025** — Garden trade: rarity ASC grid; default TL select on page show; leftover 1–2 tradeable (proporcionalni coins)
- **Bug-024** — Home BasketCard ispod DailyChest (prazna/filled korpa); uklonjen iz središnjeg Panela
- **Bug-027** — SwipePager: capture mid-tween offset + ensure align na finish/cancel (nema stuck mid-page)
- **Bug-024–027** plan prompt paket — [[../06-production/plan-prompts-bug-024-027|plan-prompts-bug-024-027]] (swipe snap, Home basket kartica, Garden trade leftover, journal T1–T3 fix)
- **Bug-020** — soft valuta `wallet_diamonds` (SAVE_VERSION 8); rare run drop ~1/300 seed-branch; hub DiamondChip + run DiamondRow; bez shop spend
- **Bug-021** — Journal: tri bloom ikone T1/T2/T3 po tipu (locked sivo, unlocked boja)
- **Bug-023** — Basket picker na Home (unlocked tipovi + Clear); Camp bez LoadoutButton/chip→loadout (trade-only)
- **Bug-022** — Home: uklonjeni Camp/Shop CTA; Settings samo na Home; DailyChest+overlay s Campa na Home; meadow dekor
- **Bug-020–023** plan prompt paket — [[../06-production/plan-prompts-bug-020-023|plan-prompts-bug-020-023]] (Home refactor, basket na Home, journal T1–T3 visuals, dijamant valuta)
- **Bug-016** — odd T2: Done/Back više ne briše bloom (keep→donate→recycle T1); Arena hint/panel copy; Camp bag = T1-only
- **Bug-018** — Garden bag tap → basket loadout + badge; LoadoutButton clear; hub-embedded sakriva Footer Merge/Play
- **Bug-019** — hub bottom nav: uklonjen CaptionLabel; niži PageIndicator; tabovi+swipe ostaju
- **Bug-017** — shop cosmetics buy: uklonjen `.bind` na signalima (dupli arg); wallet− + equip; booster connect isto
- **Bug-015** — run HUD top strip: Pip | Timer/Lv | coin+seed brojevi na vrhu; feed ispod; compact counters
- **Bug-015–019** plan prompt paket — [[../06-production/plan-prompts-bug-015-019|plan-prompts-bug-015-019]] (run HUD, T2 leftover, shop cosmetics, garden basket/footer, hub caption)
- **Bug-010–014** plan prompt paket — [[../06-production/plan-prompts-bug-010-014|plan-prompts-bug-010-014]] (arena swipe lock, seed trade select, crystal panel, ukloni Shop Almanac, header brojevi)
- **Bug-014** — hub header: `header_chip_count` (tamni ink, no clip); gušći chip bg; smoke assert brojeva
- **Bug-010** — merge arena session lock (swipe+tabs); `process_mode` pause off-page; Done/Back unlock
- **Bug-013** — uklonjen Seed Almanac (i TopProgress) iz Shop UI; Cosmetics/Boosters/IAP ostaju; unlock ostaje u GameState (lifetime)
- **Bug-012** — Crystal stash kartica odvojena od Garden seed trade; select tipa + Exchange 1→coins; scroll grid
- **Bug-011** — Garden seed trade: tap chip (count≥3) to select, then Trade; select persists after Trade while count≥3 (spam Trade without re-tap)

## 2026-08-15

- [[../06-production/CHECKPOINT|CHECKPOINT]] sync — „Gdje smo“ i putanja usklađeni s **M8 / D0** (više ne piše M6 greybox); potvrda: lokalni JSON save, bez server/baze u v1; bez velikog docs refactora
- **Bug-006** — meta hub redoslijed Shop → Journal → Home → Camp → Arena; uklonjene page dots; navigacija preko `MetaHubPages` konstanti
- **Bug-008** — camp UX: zone Daily → Garden → Upgrades → Run prep → Footer; daily chest READY/CLAIMED + reward overlay; hub mode sakriva dupli chrome
- **Bug-009** — shared hub header: coin/seed pickup ikone, pastel pill chipovi, page ResourceBar skriven kad je embedded
- **Bug-007** — shop UX: veći tekst (section 32 / rows 28); hub sakriva TopBar+ResourceBar+TopProgress; coin unlock CTA u Seed Almanac redu; veći Almanac/Cosmetics + scroll spacer
- **Garden seed bag grid** — vizualni prikaz tipova u bagu (ikona + ime + broj) u Garden kartici; `get_seed_bag_entries()`

## 2026-07-29

- **v1.1 paket (kod)** — UX-04 hub carousel (`meta_hub`, swipe L/R, Main Menu centar); MA-01b Arena Muncher pest ([[../02-design/merge-arena-pest|merge-arena-pest]]); navigacija preko `GameState.go_to_meta_page()`

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

## 2026-07-09

- **M8 D3 shop production** — `IAPManager` BillingClient hook (purchase, acknowledge, restore); shop UI + opisi proizvoda; `AdManager` interstitial hook poštuje remove ads; `iap-billing-setup.md`
- **M8 D3 dev reset** — `Reset Purchases (dev)` u stub shopu; restore klikabilan s jasnom porukom
- **M8 D4 store listing** — `store-listing-en.md`, `store-screenshots.md`, `marketing/store/`, capture skripta + screenshot save tool
- **Git solo workflow** — rule `git-solo-workflow.mdc` + AGENTS.md sekcija (master direct push, English remote)

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

## 2026-07-10

- **M8 D3–D4** — production shop/IAP hooks, 8× store screenshots, EN listing, Android emulator scripts (API 33), loot→camp click-through fix, shop dev UI hidden on export
- **D5 runbook** — [[../06-production/play-internal-test|play-internal-test]]

## 2026-07-11 (kod)

- **Seed Almanac** — linear unlock (lifetime auto + coins shortcut); spawn pool = unlocked types; Shop UI; save v3
- **D0 Blok A.1–A.2** — merge T3; Loot Boost upgrade (4 levela)
- **Kamp A+C + daily chest** — Keep, auto-plant, soft cap 40, +3 gredice; daily chest u kampu; save v4
- **Shop UX** — almanac tier 1→3, top progress bar, coin unlock fix
- **Kamp UX faza A** — resource strip, context panel, sticky Play
- **7 seed vizuala** — `seed_visual_config.gd`, camp T1/T2/T3 + run pickup po tipu
- **Mochi companion** — unlock kamp Lv 2 (Sprinkler+Boost); picker u kampu; procedural cat u runu; save `active_companion_id`

## 2026-07-11

- **Merge Arena + Daily Goals (v1.1)** — odobren dizajn [[../02-design/merge-arena-v1.1|merge-arena-v1.1]]: zamjena gredica, magnet drag, Bloom inbox, daily chest → 3 zadatka; MA-01 / DG-01 u [[../06-production/verzije-nakon-launcha|verzije-nakon-launcha]]
- **Plan objave** — [[../06-production/troskovi-launcha|troskovi-launcha]]: tablica troškova; Faza 1 polish (0 USD) → Faza 2 Android (25 USD) → Faza 3 updates → Faza 4 iOS (99 USD/god kad prikupi kapital)
- **CHECKPOINT D0** — pre-launch polish prije Play Console; D5/iOS/CPI odgođeni po fazama
- **D0 checklist** — [[../06-production/d0-prelaunch-checklist|d0-prelaunch-checklist]]: gap analiza koda vs v1 IN (~45% gotovo); Blok A–E redoslijed rada
- **Projekcija prihoda** — [[../06-production/troskovi-launcha#Projekcija: koliko do prvih ~100 USD? (pretpostavka)|troskovi-launcha]]: realistično **2–4 mj.** do ~100 USD neto nakon Android launcha

## 2026-07-12

- **Play fix** — `mochi_unlock_seen` var u `game_state.gd` (autoload parse error); `UiClickButton` child mouse_filter
- **Bloom Album (U8)** — `collection_journal.tscn`, 7-tip lista, NEW badge, 📖 u kamp top baru; save `collection_journal_pending`
- **Merge Arena MA-01** — vrećica, pour prioritet, T3 → garden stash, crystal exchange u kampu
- **Shop U6/U7** — 5 coin kozmetika (`cosmetic_catalog.gd`), 2 IAP boostera (Merge Hint, Loot Burst), shop UI paneli

## Template za nove unose

```
## YYYY-MM-DD
- Promjena i razlog
```

## Povezano

- [[../00-home|Home]]
- [[otvorena-pitanja|otvorena-pitanja]]
