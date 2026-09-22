---
status: aktivan
tags: [meta, changelog]
---

# Changelog

## Sažetak

Promjene u dizajnu i dokumentaciji kroz vrijeme.

## 2026-09-22

- **Brief: Run — lane runner (Claude Design)** — pravila iz koda (3 lanea, swipe 0,12 s, 60 s, coin/seed/diamond/prepreka, magnet, Basket +5 %, fail 50% / finish 100%), pun ekran (ne hub chrome), HUD danas, 10 problema, gotov prompt §9; loot ekran van scopea; handoff cilj `design_handoff_run/`; [[../04-experience/design-drafts/run-cd-brief|brief]]

- **Brief: Home — polje sezone (Claude Design)** — pravila polja iz koda (korpa +5 %, Magnet / Loot Boost 4 nivoa × 2 cvijeta, Play / Play Endless, livada i Pip), današnji raspored, 11 problema i gotov prompt. Novi format: CD dobija slobodu da unaprijedi dizajn i isporučuje **jedan dizajn** bez varijanti, uz paket spreman za Godot (`design_handoff_home_field/godot/field_export.json` u šemi Home paketa, zip u chatu); [[../04-experience/design-drafts/home-field-cd-brief|brief]]

## 2026-09-21

- **Home redizajn — biranje sezone (Claude Design, smjer 1a Season Trail)** — iz `design_handoff_home/`: dvije trake s 3 slota zamijenjene jednom vertikalnom kolonom kartica (harmonika: tačno jedna otvorena, tween visine 0,22 s) — besplatni put redom, red „Premium seasons“ (tačkice mood boja, „4 ↓“) i premium kartice ispod; kartica sezone u 5 varijanti (zatvorena · otvorena s rosterom od 6 cvjetova i „Open meadow ↗“ · kompaktni next lock · puni unlock poster · premium pregled) i 10 stanja, zaključane i coming-soon boje se računaju iz mood boje; Unlock na posteru troši odmah uz prsten i „New“ čip; dolazak iz Campa dočekuje otključanu sezonu s „New“; premium kupovina („Get {season} · cijena · one-time“ → „Purchasing…“ → kupljena i aktivna); **Play pokreće run u aktivnoj sezoni odmah** (čip s imenom sezone), polje sezone samo s kartice; TopRow = Daily gift + „N / 4 free seasons“; pozadina `#2E4733` kao Camp; na Home ništa ne blokira hub swipe. Obrisani Browser, mrtav `SeasonUnlockSheet`, unlock gate/progress (s `split` režimom), roster panel, brežuljci, `PlayThemeBadge`. Shop zadržava `SeasonPackCard`; Ember Fen = Coming soon kartica. Polje sezone zadržava raspored (daily gift je sada samo na biranju). Novi `season_home_smoke`, ažurirani `season_meadow_smoke` / `camp_season_link_smoke` (oba season smokea čuvaju pravi save); [[../04-experience/design-drafts/home-season-select-cd-brief|brief + odstupanja]] · [[../04-experience/design-drafts/home-season-select-izvjestaj|izvještaj]]

## 2026-09-16

- **CD capability test — provjera paketa** — CD paket instaliran u `game/_cd_sandbox/` + `docs/_cd_sandbox/` (ne commitati); headless provjera (glTF/OBJ ✅, SurfaceTool mesh obrnut winding, `.tscn` bez `uid` ✅) i benchmark na laptopu + emulatoru Pixel_4_API33. Glavni nalaz: pulsiranje pravih arena chipova (`_process → queue_redraw` cijelog chipa) 29 chipova = 84 fps laptop / **10 fps emulator** (statično 490 / 49), dok sjene i broj tweenova ne koštaju mjerljivo; [[../04-experience/design-drafts/cd-capability-test-izvjestaj|izvještaj]] · [[../04-experience/design-drafts/cd_response|odgovor za CD]] · greske-katalog #14, #15

- **Swipe pager clip** — svaka stranica huba crta samo unutar svog pravougaonika (`clip_contents`); brda livade iz Arene više ne prekrivaju donji desni ugao Campa (Trade bar), a brežuljci s Home ne ulaze u Journal; guard u `meta_hub_flow_smoke`

- **Camp redizajn (Claude Design, smjer 1b)** — iz `design_handoff_camp/`: hero kartica sljedeće besplatne sezone na vrhu (422 px: "Next free season", Coins + ★3 cvijet s barovima, "Details ↗" → Home, Unlock s podnaslovom šta fali); ispod jedna sekcija s tabovima **Seeds · Flowers** (broj tipova, "Arena fuel" / "reward") + prečica **Merge** → Arena, grid 2 × do 4 reda (ostatak se skrola), prazna stanja s CTA ("Play a run ↗" / "Merge in Arena ↗") i **jedan Trade bar** (odabrani tip, cijena "N coins each", "Trade / hold 10 / s", "+N" leti do coin chipa u headeru, mint "empty — switched here"); novi chip za sjeme i cvijet (cream krug / gold kvadrat + tamni well, ★☆☆, CountPill, PricePill); **novo pravilo:** ★3 cvijeće koje sljedeća sezona traži nosi `Kept · N / 20`, držanje Trade staje na granici (amber "Hold stopped · … keeps 20 of these"), tap prodaje dalje (pink "needs N more"); Unlock troši odmah uz burst na kartici, pa Home; `UiClickButton.repeat_guard`; uklonjeni `UpgradeCards`, `StatusToast`, cliff labele i stari `seed_bag_chip` / `crystal_stash_chip`; novi `camp_hold_floor_smoke`, ažurirani ostali `camp_*_smoke` (backup/restore save-a); [[../04-experience/design-drafts/camp-cd-brief|brief + odstupanja]]

## 2026-09-12

- **Merge Arena redizajn (Claude Design, smjer B)** — iz `design_handoff_merge_arena/`: raspored 120 HUD / 128 hint / polje / Done 140 (+60 px do footera, NavLockPill više ne pokriva Done); naslov ukinut; sjemenka = cream rim + tamni well (T1 krug, T2 zaobljen kvadrat s unutrašnjim prstenom, ★3 gold + isprekidan prsten), bez `T2` natpisa; rešetkasti spawn (`UiArena.spawn_slots`) — 30 sjemenki bez preklapanja na 1133 px; vreća 214×178 s brojačem i 3 tipa koja vire; Muncher 104 px sa 6 stanja razlučivih bez boje + gnijezdo; livada bujnija sa T3 (crossfade 0,6 s); StashCounter + T3 trenutak (prsten, kristal leti u brojač, punch); combo pluta u polju (+2 coina osvježi header); DailyTask pill s precrtom; overlay "You need more seeds!" samo preko "Back to Camp"; 13 kraćih poruka; T3 poruka koristi pravo ime cvijeta; nova `cta` varijanta dugmeta; novi `arena_redesign_smoke`; ažurirani `arena_daily_smoke` / `arena_feel_a_smoke` / `arena_leftover_b_smoke`; [[../04-experience/design-drafts/merge-arena-cd-brief|brief + odstupanja]]

## 2026-09-11

- **Hub chrome (Claude Design, smjer B)** — header i footer iz CD handoffa (`design_handoff_hub_chrome/`): tamna livadska traka `#1A241E` s 3 px rubom, ista na svih 5 stranica i produžena u safe area; header = Coins · Seeds · Diamonds (chip 296×100, broj 48 px kroz `UiChrome.format_count` → `12,450` / `1.2M`) + **Settings** (vraćen s Home u header — poništava Bug-022 t. 3; tap = placeholder toast do D0-P ekrana); footer 180 px, 5 `HubTab` (ikona + labela uvijek vidljiva, aktivan = peach tile + tamni ink), `ActiveIndicator` prati prst preko `SwipePager.get_scroll_page()`, Journal badge iz `count_collection_journal_news()`, nav lock = gold rub + `NavLockPill` "ROUND IN PROGRESS" + neaktivni tabovi 60 %; novi `ui_chrome.gd`, `hub_pressable.gd`, `hub_tab.gd`, `hub_icon_button.gd`, 16 SVG u `assets/ui/chrome/`; Home `FieldUpgradeStack` na mjestu starog Settingsa; novi `hub_chrome_smoke`, ažurirani `meta_hub_flow_smoke` / `arena_nav_lock_smoke` / `season_meadow_smoke`; [[../04-experience/design-drafts/hub-header-footer-cd-brief|brief + odstupanja]]

## 2026-09-08

- **CAMP-06 Camp polish (runda 4)** — hold trguje 10/s (`TRADE_HOLD_RATE`, prije 6); ime/brojčanik/cjenovnik vraćeni na vertikalni centar okvira (uklonjen `RightWrap`/`TextTopSpacer` iz runde 3 — slika ostaje ~15 px niža, svjestan izbor, okvir ostaje ~119 px); header i link-season kartica prate **svaki pojedini trade** uživo (`_refresh_live_chrome()` zove `refresh_top_bar` na hub-u i `season_link_card.refresh()` iz brzog hold-puta, ne više samo iz punog `_refresh_ui`); `camp_trade_hold_smoke` kodira 10/s i žive brojeve usred holda

- **CAMP-06 Camp polish (runda 3)** — okvir chipa niži ~150→~119 px bez diranja elemenata: prazan spacer ispod ikone zamijenjen `RightWrap`-om koji desnu stranu spušta za izmjerenu visinu zvjezdica (isto poravnanje, manje praznine), padding 6→5; link-season `SeasonLinkSpacer` skriven a `SeasonUnlockProgress` dobio EXPAND pa blok stoji u sredini između naslova i dugmeta; balans-spacer na vrhu obje kolone spušta coin i cvijet na tačan vertikalni centar polovine; slotovi se mjere (`get_combined_minimum_size`) umjesto fiksnih konstanti pa barovi i brojevi padaju red-u-red; linija ide do dugmeta, jednako odmaknuta kao od naslova (`CAMP_VLINE_INSET` 18, separacije 8/8); `camp_season_link_smoke` dobio geometrijske tvrdnje (ikone i barovi u istom redu, ikone na centru, jednaki razmaci linije)

- **CAMP-06 Camp polish** — chip: zvjezdice u fiksnom slotu + spacer ispod ikone (ikona centrirana s tekstom), ime centrirano između ikone i broja, count pill = visina/zaobljenost price pilla (`PILL_H` 60, radius 8); swipe/drag skrol preko chipova (`drag_scroll.gd`, tap tek ispod 12 px pomaka) i `vertical_scroll_mode = 3` (bez trake); sva tri dugmeta 460×64 centrirana, Trade dugmad `price` varijanta (#FFE8B8) s providnom ispunom kad nema selekcije; **Trade = 1 sjeme po tapu**, držanje 6/s uz automatski prelazak na sljedeći tip (`UiClickButton.auto_repeat`, save odgođen do otpuštanja); SeasonLink kolone dijele slotove (zvjezdice/slika/ime/broj/bar) pa su slike i barovi na istoj visini, linija 72 % visine reda

## 2026-09-06

- **CAMP-06 Camp fill** — bez Pip's Garden; Seeds/Flowers/Link ~⅓ bez vanjskog scrolla; SeasonLink simetrija + deblja kratka linija; chip ime lijevo + broj desno; debug design stash; [[../03-content/ideje-camp-fill|hub]] · [[../06-production/plan-prompts-camp-fill|freeze]]

- **CAMP-05 Camp row** — editor fixture Bloom+Frost, paid locked; chip red (ikona 80, samo popunjene ★, ime/broj desno); SeasonLink iste dimenzije kao Seeds/Flowers; [[../03-content/ideje-camp-row|hub]] · [[../06-production/plan-prompts-camp-row|freeze]]

- **CAMP-04 Camp read** — SeasonLink dva stupca coins|flower; Unlock širina = Exchange; chip poster-stack (ikona, 3-slot zvijezde, ime, broj); scroll 420; [[../03-content/_archive/ideje-camp-read|hub]] · [[../06-production/_archive/plan-prompts-camp-read|freeze]]

- **HOME-18 Poster fit** — locked 🔒+ime vraćen na sredinu (`CenterTitle` CENTER); `%UnlockGate` `anchor_top` 0.60; shared poster divider + coin 40 / flower 92; `watermelon` izbačen (Bloom 6 tipova); [[../03-content/ideje-home-poster-fit|hub]] · [[../06-production/plan-prompts-home-poster-fit|freeze]]

- **HOME-17 Unlock poster** — jedan ★3 po sezoni; shared coin+cvijet poster na Home gate i Camp SeasonLink; basket prikazuje sva sjemena (locked siva); prazan basket i claimable daily chest blink+shake; title-TOP / gate 0.26 / watermelon ★2 **superseded** HOME-18; [[../03-content/_archive/ideje-home-unlock-poster|hub]] · [[../06-production/_archive/plan-prompts-home-unlock-poster|freeze]]

## 2026-09-03

- **Playtest fixture** — debug boot stavlja **22** T1 `pumpkin` (★3) u `seed_bag` (uz 19 pumpkin cvijeća)

- **Star-3 unlock + Journal swipe + Camp link** — Journal staggered rows (nema 49-row hitch na swipe); free S2+ = 500 coins + 20 rarity-3 T3 **prethodne** sezone, `unlock_free` troši oba; Bloom roster + `watermelon`; kamp kartica = Home locked poster, Unlock gumb (gold kad može) = Home + 0.4 s + spend; Seeds/Flowers scroll **280**; debug fixture S1 + 19 pumpkin; [[../06-production/plan-prompts-star3-unlock-hub|freeze]] · [[../03-content/ideje-sezone-ekonomija|ekonomija]]

## 2026-09-02

- **CAMP-03 CAMP3-C** — kamp kartica next locked free sezone (barovi + Unlock); Unlock vodi na Home locked poster, ne `unlock_free`; [[../03-content/ideje-camp-link|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] CAMP3-C ✅

- **CAMP-03 CAMP3-B** — Flowers chip `rarity_bg` kao Seeds; Exchange auto-select sljedeći ASC nakon deplete; crystal grid ASC; [[../03-content/ideje-camp-link|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] CAMP3-B ✅

- **CAMP-03 CAMP3-A** — Seeds/Flowers samo naslov; GardenCliff/BagLabel/CrystalTotalLabel hidden; scrollovi 220→242; UpgradeCards ostaju hidden; [[../03-content/ideje-camp-link|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] CAMP3-A ✅

- **HOME-16 FIELD-D** — Magnet pa Loot Boost kompaktno ispod Settings na otvorenom polju; kamp `%UpgradeCards` hidden; spend `try_upgrade_*("")` 2 T3 ostaje; [[../03-content/ideje-home-meadow-field|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] FIELD-D ✅

- **HOME-16 FIELD-C** — hub swipe Journal/Camp dok je season field otvoren; Stage van `block_hub_swipe`; Daily/Basket/Settings/chip/PlayRow u grupi; session ostaje open na CAMP/MAIN hop; karusel Stage i dalje blokira; [[../03-content/ideje-home-meadow-field|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] FIELD-C ✅

- **HOME-16 FIELD-B** — basket picker jedan stupac, bez `PickerScroll`; `%PickerPanel` visina wrap title + T3 redovi + footer; T3/★3/Clear+Close ostaju; [[../03-content/ideje-home-meadow-field|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] FIELD-B ✅

- **HOME-16 FIELD-A** — claimed Daily overlay title Come back tomorrow; body `Daily chest already opened today.`; `claim_daily_chest` already-claimed isti trim; caption Back tomorrow ostaje; [[../03-content/ideje-home-meadow-field|hub]] · [[../06-production/plan-prompts-home-camp-field|prompti]] FIELD-A ✅

- **HOME-16 FIELD-P0 + CAMP-03 CAMP3-P0** — docs freeze: Daily overlay body; basket bez scrolla; hub swipe u polju; Magnet/Loot na polju; kamp Seeds/Flowers naslov +10%; Flowers = Seeds; next-lock kartica → Home; CAMP2-A superseded; [[../03-content/ideje-home-meadow-field|HOME-16]] · [[../03-content/ideje-camp-link|CAMP-03]] · [[../06-production/plan-prompts-home-camp-field|prompti]] FIELD-P0 ✅ CAMP3-P0 ✅ → A–D / A–C (nema `game/` u P0)

- **HOME-15 DOCK-D** — Home Daily caption samo Tap to open / Back tomorrow; tap ne `claim_arena_daily`; arena HUD ostaje; [[../03-content/ideje-home-meadow-dock|hub]] · [[../06-production/plan-prompts-home-meadow-dock|prompti]] DOCK-D ✅

- **HOME-15 DOCK-C** — Basket 336×104 ispod Daily; PlayRow Seasons|Play|Endless; chip ne close; `meadow_safe_rect` + Basket; [[../03-content/ideje-home-meadow-dock|hub]] · [[../06-production/plan-prompts-home-meadow-dock|prompti]] DOCK-C ✅

- **HOME-15 DOCK-B** — meadow flowers `plant_tier = 3`; isti crystal draw kao BasketVisual; count 12–14 ostaje; [[../03-content/ideje-home-meadow-dock|hub]] · [[../06-production/plan-prompts-home-meadow-dock|prompti]] DOCK-B ✅

- **HOME-15 DOCK-A** — basket picker: T3 ikona iznad imena; ★3 (`pumpkin`) selectable; Clear+Close stacked footer; [[../03-content/ideje-home-meadow-dock|hub]] · [[../06-production/plan-prompts-home-meadow-dock|prompti]] DOCK-A ✅

- **HOME-15 DOCK-P0** — docs freeze meadow dock: T3/★3 picker; Basket ispod Daily; Seasons u PlayRow; Daily bez arena streaka; [[../03-content/ideje-home-meadow-dock|hub]] · [[../06-production/plan-prompts-home-meadow-dock|prompti]] DOCK-P0 ✅ → A–D

## 2026-09-01

- **HOME-14 LIFE-D** — MeadowPip Walk/Sniff/Sleep u `meadow_safe_rect`; close/karusel hide; PipPortrait off; [[../03-content/ideje-home-meadow-life|hub]] · [[../06-production/plan-prompts-home-meadow-life|prompti]] LIFE-D ✅

- **HOME-14 LIFE-C** — 13 dekorativnih cvjetova u `meadow_safe_rect` (Daily/Settings/chip/PlayRow); clip SeasonField; smoke 12–14 + no chrome overlap; [[../03-content/ideje-home-meadow-life|hub]] · [[../06-production/plan-prompts-home-meadow-life|prompti]] LIFE-C ✅

- **HOME-14 LIFE-B** — PlayRow Basket/Play/Endless **320×96**, shrink-center; karusel samo Play iste visine; [[../03-content/ideje-home-meadow-life|hub]] · [[../06-production/plan-prompts-home-meadow-life|prompti]] LIFE-B ✅

- **HOME-14 LIFE-A** — karusel Play nikad run; locked/unowned → `snap_carousel_to_active`; playable → polje; polje Play → run; [[../03-content/ideje-home-meadow-life|hub]] · [[../06-production/plan-prompts-home-meadow-life|prompti]] LIFE-A ✅

- **HOME-14 LIFE-P0** — docs freeze meadow life: Play 3-koraka (nikad run s karusela); jednaki PlayRow; 12–14 cvjetova u chrome-safe zoni; MeadowPip hod/njuh/spavanje; [[../03-content/ideje-home-meadow-life|hub]] · [[../06-production/plan-prompts-home-meadow-life|prompti]] LIFE-P0 ✅ → A–D

- **HOME-13 CHROME-E** — `%SeasonNameChip` gore (ime sezone); tap/Back/Escape → `close_season_field`; `%SeasonsButton` UniqueName hidden; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] CHROME-E ✅

- **HOME-13 CHROME-D** — Play Endless samo u otvorenom polju, desno od Play; `set_active_season(home_season_field_id)` pa Hard; karusel hidden; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] CHROME-D ✅

- **HOME-13 CHROME-C** — Basket samo u otvorenom polju, lijevo od Play; picker `types_for_season` ∩ unlocked; T3 `CampPlantDraw`; `clear_loadout` van poola; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] CHROME-C ✅

- **HOME-13 CHROME-B** — `%FieldBackdrop` full-bleed MainMenu tint iza Daily/Settings/Play; karusel tamni bg; `SeasonTheme.home_field_tint`; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] CHROME-B ✅

- **HOME-13 CHROME-A** — `%PipPortrait` i `%MeadowPip` hidden; wander stop; UniqueName ostaje; smokes `season_home_smoke` / `season_meadow_smoke`; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] CHROME-A ✅

- **HOME-13 CHROME-P0** — docs freeze meadow chrome: Basket/Endless samo u polju; full-bleed; Pip van; name-chip natrag; [[../03-content/ideje-home-meadow-chrome|hub]] · [[../06-production/plan-prompts-home-meadow-chrome|prompti]] P0 ✅ A–E

- **HOME-12 MEADOW-C** — jedan `MeadowPip` na SeasonField; Tween wander među cvijećem otvorene sezone; IGNORE; isti node za Frost; [[../03-content/ideje-home-meadow|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] MEADOW-C ✅

- **HOME-12 MEADOW-B** — 6–10 dekorativnih cvjetova iz `seed_type_ids` otvorenog fielda; `apply_season` rebuild; IGNORE; [[../03-content/ideje-home-meadow|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] MEADOW-B ✅

- **HOME-12 MEADOW-A** — jedan `SeasonField` + `apply_season`; Play/tap playable → polje; Play na polju → run; Seasons → karusel; smoke `season_meadow_smoke`; [[../03-content/ideje-home-meadow|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] MEADOW-A ✅

- **SEED-01 SEED-C** — T1–T3 fallback draw (hash paleta; frost T2 nije clover 3-list); pour `SeedCatalog.all_type_ids()` ∩ bag; smoke `seed_draw_pour_smoke`; [[../03-content/ideje-seed-pool|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] SEED-C ✅

- **SEED-01 SEED-B** — Bloom album `SeedCatalog.all_type_ids()` (49); Frost locked dok nije discovered; camp Trade/Exchange `get_seed_display_name`; [[../03-content/ideje-seed-pool|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] SEED-B ✅

- **SEED-01 SEED-A** — `SeedCatalog`; `seed_type_ids` = roster merge id; Bloom CHAIN 7 ostaje; Frost run pool `frost_snowdrop` (nije clover); [[../03-content/ideje-seed-pool|hub]] · [[../06-production/plan-prompts-seed-meadow|prompti]] SEED-A ✅

- **plan-prompts-seed-meadow** — SEED-01 + HOME-12 copy-paste u jednom fajlu (1 SEED-A … 6 MEADOW-C); stari `plan-prompts-seed-pool` / `plan-prompts-home-meadow` = stub; [[../06-production/plan-prompts-seed-meadow|prompti]]

- **SEED-01 SEED-P0** — docs: jedan `type_id` namespace; `seed_type_ids` = merge tipovi sezone; journal/arena/camp; Bloom CHAIN 7 ostaje; [[../03-content/ideje-seed-pool|hub]] · [[../06-production/plan-prompts-seed-pool|prompti]] SEED-P0 ✅ → A → B → C (nema `game/` u P0)

- **HOME-12 amend** — jedno `SeasonField` + `apply_season` za **sve playable** sezone (P141 Bloom-only povučen); [[../03-content/ideje-home-meadow|hub]] · [[../06-production/plan-prompts-home-meadow|prompti]]

- **CAMP-02 CAMP2-P0** — docs: prazna rupa između Seeds i `Seeds: n/cap`; GardenCliff hidden + prazan (C21, override C7); [[../03-content/ideje-camp-cliff|hub]] · [[../06-production/plan-prompts-camp-cliff|prompti]] CAMP2-P0 ✅ → A (nema `game/` u P0)

- **HOME-12 MEADOW-P0** — docs: polje na Homeu (tap/Play → polje, Play na polju → run, gumb Seasons natrag); [[../03-content/ideje-home-meadow|hub]] · [[../06-production/plan-prompts-home-meadow|prompti]] MEADOW-P0 ✅ → A → B → C (nema `game/` u P0)

## 2026-08-30

- **CAMP-01 CAMP-B** — Sprinkler i Loot Boost atomic 2 T3 iz Flowers; caption magnet px / loot ×; `camp_donate_smoke`

- **CAMP-01 CAMP-A** — StatusToast no-op; GardenCliff bez journal/T2 grana; CrystalCliff hidden; naslovi Seeds / Flowers; RunPrep companion picker uklonjen; smoke `camp_layout_smoke`

- **CAMP-01 CAMP-P0** — docs: kamp chrome (toast, journal/crystal cliff, companion picker, Seeds/Flowers); Sprinkler i Loot Boost troše 2 T3 iz Flowers (atomic); arena donate ostaje mrtav; [[../03-content/ideje-camp|hub]] · [[../06-production/plan-prompts-camp|prompti]] P0 ✅ A ✅ B ✅ (nema `game/` u P0)

## 2026-08-29

- **ARENA-03 VAC-L** — lock samo dok `bag &lt; 4`; nakupljeni leftover ≥4 ide u tap/autopour; S32 pour nakon vacuuma na praznom polju; smoke `arena_vacuum_l_smoke`

- **ARENA-03 VAC-F** — leftover T1/T2 (i FLOW-A T2 recycle) ghostom lete u korpicu; bag punch; state odmah; smoke `arena_vacuum_fly_smoke`

- **ARENA-03 VAC-A** — vacuum vraća leftover i kad je debug bag preko 40; `t1_eq` broji bag samo ako ≥4 i unlocked; drugi vacuum nakon refill/pour i drop bez mergea; smoke `arena_vacuum_stuck_smoke`

- **ARENA-03 SORT-B** — čim `t1_eq < 4`, idle T1/T2 tog tipa u torbu kao T1 + lock pour do Done; 3 T1 asap (ne leftover-E par); smoke `arena_sort_b_smoke`

- **ARENA-03 SORT-A** — pour sav T1 po `CHAIN` ako ≥4 i nije locked; ukinut leftover-A `floor(n/4)*4` i petlja prva 2 rarity; `max_count` bez floor-4; cap 40 / refill 12 / polje 0 ne auto; smoke `arena_leftover_a_smoke` (31 daisy + 9 buttercup)

- **ARENA-03 SORT-P0** — docs: pour sav T1 po `CHAIN` (ne floor-4); skip bag &lt;4 i locked; vacuum kad t1_eq &lt; 4 (T2→2 T1, lock do Done); overlay B+C i grant D ostaju; leftover-E kod superseded; [[../03-content/ideje-arena-sort|hub]] · [[plan-prompts-arena-sort|prompti]] SORT-P0 → A → B (nema `game/` u P0)

## 2026-08-28

- **ARENA-02 LEFTOVER-D** — debug torba freeze 100 T1 jednom po procesu (clover 19, daisy 22, buttercup 13, tulip 28, sunflower 18); Arena bez min-10; smoke `arena_leftover_d_smoke`

- **ARENA-02 LEFTOVER-E-P0** — docs: mid-session neparni T1 tog tipa ide u torbu (3 clover → 1 bag + 2 polje); L1 reopen L31–L37; overlay B+C ostaje; D (100 T1) zasebno; [[../03-content/ideje-arena-leftover-field|field]] · [[plan-prompts-arena-leftover|prompti]] E-P0 → E (nema `game/` u E-P0)

- **ARENA-02 LEFTOVER-C** — overlay hide prije Camp (Done/Back + page inactive); povratak Arena taba bez popup-a; naslov **You need more seeds!** `WARM_WHITE`; smoke `arena_leftover_c_smoke`

- **ARENA-02 LEFTOVER-C-P0** — docs: overlay hide prije Camp (hub persist), čist Arena tab, naslov **You need more seeds!** svijetao u popup-u; debug 100 T1 freeze 19/22/13/28/18 jednom po procesu; L21–L30; [[../03-content/ideje-arena-leftover-grant|grant]] · [[plan-prompts-arena-leftover|prompti]] C-P0 → C → D (nema `game/` u C-P0)

- **ARENA-02 LEFTOVER-B** — stuck vreća (nema tipa ≥4) otvara overlay **You need more seeds!** + kamp T1 lista **`n/4`**; tap = Done → Camp; auto-refill ne otvara; smoke `arena_leftover_b_smoke`
- **ARENA-02 LEFTOVER-A** — pour uvijek `floor(n/4)*4` po tipu; `max_count` floor-4; `ARENA_AUTO_REFILL_AT` 10→12; auto-refill stane kad pull vrati `[]`; A15 ne trese 3 na orphan; smoke `arena_leftover_a_smoke` + `arena_flow_b_smoke` prag 12
- **ARENA-02 LEFTOVER-P0** — leftover docs: pour uvijek ÷4 po tipu (6 clover → 4 polje, 2 torba); auto-refill 10→12; stuck vreća → overlay **You need more seeds!** + kamp T1 lista **`n/4`**, tap → Camp; freeze L0–L20; [[../03-content/ideje-arena-leftover|hub]] · [[plan-prompts-arena-leftover|prompti]] P0 → A → B (nema `game/` u P0)

## 2026-08-26

- **ARENA-01 FEEL-B** — clear-field VFX kad nema legalnog para (odd leftover OK); jednom po pouru; bez coina; smoke `arena_feel_b_smoke` (grana `ARENA`)
- **ARENA-01 FEEL-A** — mali Pip na rubu playfielda (IGNORE, nije eat target); bounce na combo ≥2 / T3; `$Bg` livada tint raste s T3 u sesiji, reset na Done/Back; smoke `arena_feel_a_smoke` (grana `ARENA`)
- **ARENA-01 DAILY-A** — jedan local-day arena zadatak (merge 3× T2 / 1 T3 / combo 5); `DailyLabel` n/N; Home chest tap za streak badge bez coina/sjemena; `SAVE_VERSION` 12; smoke `arena_daily_smoke` (grana `ARENA`)
- **ARENA-01 FLOW-B** — auto-pour kad polje padne na ≤10 (do 40 ili praznog baga); pour preferira tip s točno 1 chipom na polju; Done ostaje slobodan; smoke `arena_flow_b_smoke` (grana `ARENA`)
- **ARENA-01 FLOW-A** — uklonjen Donate/Album/Basket panel u areni; leftover T2 bez para → 2× T1 u bag; T2 ostaje dok ima T2 para / pour / 2 T1 na polju; Done T2 također 2× T1; smoke `arena_flow_a_smoke` (grana `ARENA`)

## 2026-08-26

- **HOME-11 BARFIT-A** — UnlockGate `anchor_top` 0.62 (ispod 🔒+ime); frameless panel; debug floor 500 coins + 20 T3
- **HOME-11 BARFIT-P0** — docs + prompti: locked barovi ispod 🔒+ime; bez gate okvira; debug floor 500 coins + 20 T3; [[../06-production/plan-prompts-home-barfit|plan-prompts-home-barfit]] BARFIT-P0 → A
- **HOME-10 LOCKFLOW-B** — roster `anchor_right` 0.85 (raste desno, bez lijevog clipa); puna imena bez ellipsisa; wash `FRAME_ALPHA` 0.28; `apply_season` na morph midpoint
- **HOME-10 LOCKFLOW-A** — locked free poster: ime sredina, Coins/Seeds 500/20, Unlock sivi→zlatni; roster skriven dok je next-lock; Lantern+Amber locked bez TEST_LOCK
- **HOME-10 LOCKFLOW-P0** — docs + prompti: locked free = ime sredina + Coins/Seeds 500/20 + Unlock sivi→zlatni; roster skriven dok locked, pa širi desno bez ellipsisa; blaga transparentna wash (nema swipe glitcha); Lantern+Amber locked bez TEST_LOCK; [[../06-production/plan-prompts-home-lockflow|plan-prompts-home-lockflow]] LOCKFLOW-P0 → A → B

## 2026-08-25

- **ARENA-01 COMB-A** — Combo HUD od 2 (`Combo N`), prozor 1.4 s (timeout/Done/Back gase; pest eat ne); 2 coins jednom na pragu 5, dnevni cap 10 (`SAVE_VERSION` 11); pair pulse istog `type_id`+`tier`; smoke `arena_combo_smoke` (grana `ARENA`)
- **HOME-09 CARDFIT-B** — ime sezone na sredini kartice; roster/gate okvir iz mood palete (kontrast po sezoni); širi roster (~0.48 / min 320)
- **ARENA-01 prompti** — grupe G1–G5 ([[../03-content/ideje-arena-grupe|ideje-arena-grupe]]); Plan-only [[plan-prompts-arena|plan-prompts-arena]] COMB-A → FLOW-A → FLOW-B → DAILY-A → FEEL-A → FEEL-B
- **HOME-09 CARDFIT-A** — Amber skinut s TEST_LOCK; Unlock gate na next-lock free (Amber 220c/12 T3); debug skip lantern+amber po id-u; Ember ostaje paid lock
- **HOME-09 CARDFIT-P0** — docs + prompti: Amber skinut s TEST_LOCK (gate na next-lock free, npr. Amber Canopy); naslov sezone opet na sredini kartice; roster/gate pozadina po sezoni (kontrast); širi roster; Ember ostaje paid TEST_LOCK; [[../06-production/plan-prompts-home-cardfit|plan-prompts-home-cardfit]] CARDFIT-P0 → A → B

## 2026-08-20

- **HOME-08 INCARD-B** — Unlock gate u free hero-centar kartici (Lantern); Seeds + sivo→primary; Stage overlay uklonjen
- **HOME-08 INCARD-A** — roster u hero-centar kartici (`FreeRoster`/`PaidRoster`); veći T3+★+ime; Stage overlay uklonjen; Unlock gate još Stage (B)
- **HOME-08 INCARD-P0** — docs + prompti: roster i Unlock u hero-centar prozoru sezone (ne Stage overlay); veći tip; Lantern gate na kartici
- **ARENA-01 freeze** — A0–A35: Combo HUD + coins na 5+; pulse; auto-refill na 10; leftover T2→2×T1; nema bloom panela u areni; daily badge; prompti sljedeći
- **ARENA-01 docs** — Merge Arena zabavnija: hub + ciljevi/feel/bloom/pest; A0 smjer (mješavina + goals_on_top); A1–A35 otvoreno; nije D0 blocker; prompti nakon freezea
- **HOME-07 UNLOCK-A–C** — swipe dolje = select; next-lock inline Unlock; debug skip lantern; 48 T3 roster dolje-lijevo
- **HOME-07 UNLOCK-P0** — docs + prompti: swipe dolje = select; next-lock Unlock; lantern test-lock skip; 48 T3 roster
- **HOME-06 FOCUS-D** — L/R sezone: in-place pretapanje `BAND_TWEEN_SEC` (nema HBox pomaka); ista glatkoća kao free↔paid visine
- **HOME-06 FOCUS-A–C** — invert V swipe; L/R stretch pretapanje bez cuta; Browser → band+centar; outline 5px+sjena; test-lock amber/ember; ugašen PlayThemeBadge; smoke `season_home_smoke`
- **HOME-06 FOCUS-P0** — korekcija HOME-05: band-swap ostaje; L/R bez cuta; invert swipe; Browser fokus; outline; test-lock amber/ember; bez Theme badgea; prompti [[../06-production/plan-prompts-home-focus|plan-prompts-home-focus]]
- **HOME-05 GLIDE-A–C** — full-slot L/R glajd ~250ms; vertikalni swipe = band swap (tap ostaje); Play-active outline; S4 Amber Canopy + paid Starfall Glade / Ember Fen; Shop 2×2
- **HOME-04 PAID-C** — Home dual-band: visina tween ~250ms; izolirani hero swipe (`cycle_paid`); preview tap-swap; P11 sheet iz locked preview; smoke `season_home_smoke`
- **HOME-04 PAID-B** — Home dual-band: PaidBand gore / FreeBand dolje; 20/80 instant visine; `home_band` + `paid_strip_focus_id`; tap preview = swap; smoke `season_home_smoke`
- **HOME-04 PAID-A** — Shop Season packs: 2-col `SeasonPackCard` (Browser shared); owned tap no-op (nema Select); smoke `shop_open_smoke` + `season_iap_smoke`
- **HOME-04 PAID-P0** — Paid dual-band + shop packs spec: Shop 2-col Browser kartice bez Select; Home PaidBand top / FreeBand bottom 20/80; preview statičan; tap okvira = swap; P45–P59 freeze; prompti [[../06-production/plan-prompts-home-paid|plan-prompts-home-paid]]

## 2026-08-19

- **HOME-03 CHROME-C** — strip snap-slide ~220ms (`StripMotion` offsets); bounce na rubu
- **HOME-03 CHROME-B** — Browser samo tap na srednju karticu; gap no-op
- **HOME-03 CHROME-A** — Home: Pip + Play + Play Endless; Endless uvijek Hard; bez wordmarka/difficulty
- **HOME-03 CHROME-P0** — Home chrome spec: 2 gumba; Browser samo centar; Endless Hard + ista sezona; strip slide; prompti [[../06-production/plan-prompts-home-chrome|plan-prompts-home-chrome]]
- **HOME-02 HIT-A** — Season Stage hit-through: `Row`/slotovi `MOUSE_FILTER_IGNORE`; swipe+tap na karticama
- **HOME-02 HIT-P0** — Home hit targets: paneli gutaju swipe/tap; P28–P35; prompti [[../06-production/plan-prompts-home-hit-targets|plan-prompts-home-hit-targets]]
- **HOME-C** — Play `Theme:` badge kad active ≠ strip; debug unlock svih sezona za swipe test
- **HOME-B** — 3-slot free Home traka (`strip_focus_id`, save v10); uže Play/Endless Play; smoke `season_home_smoke`
- **HOME-A** — ukinut Home `Panel`; flatten `HomeColumn` (compact Pip+title, SEZ-C Stage, Play)
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
- **Bug-029–032** plan prompt paket — [[../06-production/_archive/plan-prompts-bug-029-032|plan-prompts-bug-029-032]] (T1 unify, rarity theme, exchange balance, Garden/Flower UX); redoslijed **029 → 030 → 031 → 032**
- **Bug-028** — `stash_garden_crystal` diže `collection_kept_tiers` na T3 (Journal T3 nakon arena merge)
- **Bug-026** — Journal: T1/T2/T3 ikone scale-fit (bez clipa); 64px; unlock pravila ista; paket 024–027 ✅
- **Bug-025** — Garden trade: rarity ASC grid; default TL select on page show; leftover 1–2 tradeable (proporcionalni coins)
- **Bug-024** — Home BasketCard ispod DailyChest (prazna/filled korpa); uklonjen iz središnjeg Panela
- **Bug-027** — SwipePager: capture mid-tween offset + ensure align na finish/cancel (nema stuck mid-page)
- **Bug-024–027** plan prompt paket — [[../06-production/_archive/plan-prompts-bug-024-027|plan-prompts-bug-024-027]] (swipe snap, Home basket kartica, Garden trade leftover, journal T1–T3 fix)
- **Bug-020** — soft valuta `wallet_diamonds` (SAVE_VERSION 8); rare run drop ~1/300 seed-branch; hub DiamondChip + run DiamondRow; bez shop spend
- **Bug-021** — Journal: tri bloom ikone T1/T2/T3 po tipu (locked sivo, unlocked boja)
- **Bug-023** — Basket picker na Home (unlocked tipovi + Clear); Camp bez LoadoutButton/chip→loadout (trade-only)
- **Bug-022** — Home: uklonjeni Camp/Shop CTA; Settings samo na Home; DailyChest+overlay s Campa na Home; meadow dekor
- **Bug-020–023** plan prompt paket — [[../06-production/_archive/plan-prompts-bug-020-023|plan-prompts-bug-020-023]] (Home refactor, basket na Home, journal T1–T3 visuals, dijamant valuta)
- **Bug-016** — odd T2: Done/Back više ne briše bloom (keep→donate→recycle T1); Arena hint/panel copy; Camp bag = T1-only
- **Bug-018** — Garden bag tap → basket loadout + badge; LoadoutButton clear; hub-embedded sakriva Footer Merge/Play
- **Bug-019** — hub bottom nav: uklonjen CaptionLabel; niži PageIndicator; tabovi+swipe ostaju
- **Bug-017** — shop cosmetics buy: uklonjen `.bind` na signalima (dupli arg); wallet− + equip; booster connect isto
- **Bug-015** — run HUD top strip: Pip | Timer/Lv | coin+seed brojevi na vrhu; feed ispod; compact counters
- **Bug-015–019** plan prompt paket — [[../06-production/_archive/plan-prompts-bug-015-019|plan-prompts-bug-015-019]] (run HUD, T2 leftover, shop cosmetics, garden basket/footer, hub caption)
- **Bug-010–014** plan prompt paket — [[../06-production/_archive/plan-prompts-bug-010-014|plan-prompts-bug-010-014]] (arena swipe lock, seed trade select, crystal panel, ukloni Shop Almanac, header brojevi)
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
