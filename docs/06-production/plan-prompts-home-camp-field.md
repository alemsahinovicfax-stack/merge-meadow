---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, kamp, sezone, meadow, basket, daily, swipe, upgrade, plan, prompt]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-field-pitanja
  - ideje-home-meadow-field-grupe
  - ideje-camp-link
  - ideje-camp-link-pitanja
  - ideje-camp-link-grupe
  - ideje-home-meadow-dock
  - ideje-camp-cliff
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode playlist HOME-16 FIELD + CAMP-03 CAMP3 — P0 docs; FIELD-A–D ✅; CAMP3-A ✅ CAMP3-B ✅ CAMP3-C ✅."
---

# Plan promptovi — HOME-16 field + CAMP-03 kamp link

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** fenced blok ispod → odobri → Agent.  
> **Ne** zalijepi dva bloka u isti chat. **Ne** spajati FIELD-D + CAMP3-A. **Ne** pasteati CAMP2-A.  
> **Ne** spajati s [[plan-prompts-home-meadow-dock|HOME-15 kod]] ni [[plan-prompts-camp|CAMP-01 kod]].  
> **Grana:** **`master`**. Fair F2P: Magnet/Loot = 2 T3 Flowers, ne IAP. Kamp Unlock **ne** troši coins.  
> Freeze: [[../03-content/ideje-home-meadow-field-pitanja|P215–P232]] · [[../03-content/ideje-camp-link-pitanja|C22–C34]] · override P203 P205 P207 C7 C21 C18.

**FIELD-P0 + CAMP3-P0** ✅ 2026-09-02 (docs, ovaj fajl). **FIELD-A ✅** 2026-09-02. **FIELD-B ✅** 2026-09-02. **FIELD-C ✅** 2026-09-02. **FIELD-D ✅** 2026-09-02. **CAMP3-A ✅** 2026-09-02. **CAMP3-B ✅** 2026-09-02. **CAMP3-C ✅** 2026-09-02.

## Paste redoslijed (kod)

| # | Prompt | Stavka | Što |
|---|---------|--------|-----|
| 0 | **FIELD-P0 + CAMP3-P0 ✅** | sve | Docs freeze (ne paste) |
| 1 | **FIELD-A ✅** | Daily | Overlay body bez eha |
| 2 | **FIELD-B ✅** | Basket | Jedan stupac, bez scrolla |
| 3 | **FIELD-C ✅** | Swipe | Hub Journal/Camp u polju |
| 4 | **FIELD-D ✅** | Upgrades | Magnet+Loot na polju; hide kamp kartice |
| 5 | **CAMP3-A ✅** | Chrome | Seeds/Flowers naslov; +10%; C21 |
| 6 | **CAMP3-B ✅** | Flowers | Rarity + auto-select |
| 7 | **CAMP3-C ✅** | Season | Next-lock kartica → Home |

A/B/C HOME-16 neovisni. **FIELD-D prije CAMP3-A.** CAMP3-B smije uz A. **CAMP3-C čeka A.** Ne spajati D+A kamp.

## Freeze

**P215–P232:** claimed overlay title Come back tomorrow, body `Daily chest already opened today.`; caption P206 ostaje; picker jedan stupac bez scrolla, panel raste (max 7); DOCK-A T3/★3/footer ostaju; karusel Stage i dalje `block_hub_swipe`; field open Stage nije, chrome jest; lijevo Journal, desno Camp; field session ostaje open; Magnet pa Loot Boost UR ispod Settings; kamp UpgradeCards hidden; spend `try_upgrade_*( "")` 2 T3; nema captiona na polju; safe rect + upgrades; v1.1+; nema SAVE_VERSION.

**C22–C34:** GardenCliff hidden prazan; BagLabel i CrystalTotalLabel hidden; naslovi Seeds/Flowers; scrollovi 220→242; UpgradeCards ostaju hidden; Flowers rarity_bg + auto-select; next-lock kartica iste visine; Unlock = go Home locked poster, ne `unlock_free`; hidden ako nema next; free only.

Ostaje HOME-12–15: jedan SeasonField; Play 3-koraka; Pip; Basket ispod Daily; Seasons u PlayRow; T3 picker. CAMP-01 spend API.

Ne dirati: Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum, hub pager osim field swipe, SeedCatalog JSON, run Pip, Endless Hard brojke, `arena_daily_*` save, `donate_bloom`.

---

## P0 arhiva — urađeno 2026-09-02 (ne paste)

### FIELD-P0 + CAMP3-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow HOME-16 + CAMP-03 docs freeze — Daily overlay body; basket bez scrolla; hub swipe u polju; Magnet/Loot na polju; kamp Seeds/Flowers naslov +10%; Flowers = Seeds; next-lock kartica vodi na Home.

Dokumentiraj P215–P232 i C22–C34; override P203 P205 P207 C7 C21 C18. CAMP2-A superseded. Nema game/ u P0. CHECKPOINT sljedeci_korak ostaje D0-P. Grana master.

Fajlovi: ideje-home-meadow-field.md hub + daily/basket/swipe/upgrades/pitanja/grupe; ideje-camp-link.md hub + chrome/flowers/season/pitanja/grupe; plan-prompts-home-camp-field.md P0 FIELD-A–D CAMP3-A–C. Wire _index, ideje-kad-predloziti, dock/camp/cliff sljedeće, CHECKPOINT zadnja_sesija, changelog.
```

---

## 1 — FIELD-A (Daily overlay body) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-16 FIELD-A — claimed Daily overlay: title ostaje Come back tomorrow; body bez ponovljenog come back tomorrow.

Ovisi o FIELD-P0. Freeze P215 P216 P217 P231. Ne picker (B). Ne swipe (C). Ne Magnet (D). Ne SAVE_VERSION.

Danas: main_menu.gd _on_daily_chest_pressed CLAIMED zove _show_reward_overlay("Come back tomorrow", "Daily chest already opened today — come back tomorrow!"). game_state.gd claim_daily_chest early-return isti suffix. Caption kartice P206 Tap to open / Back tomorrow.

FIELD-A:
1) Overlay title ostaje "Come back tomorrow".
2) Body: "Daily chest already opened today." Nema " — come back tomorrow!".
3) claim_daily_chest already-claimed string isti trim. Success gift stringovi ne dirati.
4) Ne dirati caption, claim_arena_daily, arena_daily_*.

Smokes: home meadow ili postojeći daily helper — claimed tap: title sadrži Come back tomorrow; body sadrži already opened today; body ne sadrži come back tomorrow (case-insensitive). Caption claimed i dalje Back tomorrow.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, PlayRow, Basket picker, Play routing, MeadowPip, SeedCatalog JSON, arena daily HUD.

Relevantno: ideje-home-meadow-field-daily.md, P215–P217, main_menu.gd _on_daily_chest_pressed / _show_reward_overlay, game_state.gd claim_daily_chest.

Acceptance: overlay se ne ponavlja; title sutra, body već otvoreno danas.
```

---

## 2 — FIELD-B (Basket no-scroll) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-16 FIELD-B — basket picker jedan stupac, bez scrolla; panel raste da svi T3 redovi i footer stanu na ekran.

Ovisi o FIELD-P0. A smije biti gotov. Freeze P218 P219 P220 P231. Override P203 samo „ispod scrolla“ → ispod liste. Ne Daily (A). Ne swipe (C). Ne Magnet (D).

Danas: main_menu.tscn PickerScroll custom_minimum_size.y 400, size_flags expand. PickerPanel ~±360. PickerList VBox T3 iznad imena. Footer Clear pa Close. Bloom 7 tipova.

FIELD-B:
1) Jedan stupac. Ne 2-col grid.
2) Nema aktivnog scroll clipa: ukloni PickerScroll ili vertical_scroll off + size-to-content. PickerList nije u containeru koji siječe redove.
3) PickerPanel visinu raste: title + svi flower-redovi (max 7) + PickerFooter. Ne clipati T3 ikone.
4) PickerList samo cvijeće. Clear i Close u footeru, Close ispod Clear (DOCK-A). ★3 i T3 ostaju.

Smokes: home_basket_picker_smoke + meadow — Bloom open picker: svi flower-redovi get_global_rect unutar PickerPanel; nema clip-scroll ILI content <= viewport; Clear nije dijete PickerList; Close ispod Clear; rarity-3 i dalje u listi ako unlockan. Frost pool ostaje Frost.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP, SAVE_VERSION, PlayRow, Daily overlay, MeadowPip, Play routing, SeedCatalog JSON, plant_tier.

Relevantno: ideje-home-meadow-field-basket.md, P218–P220, main_menu.tscn BasketPickerOverlay PickerScroll PickerPanel, main_menu.gd _rebuild_picker_list, home_basket_picker_smoke.gd.

Acceptance: svi cvjetovi sezone vidljivi bez scrolla; T3/★3/footer ostaju.
```

---

## 3 — FIELD-C (Hub swipe u polju) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-16 FIELD-C — hub swipe Journal lijevo i Camp desno radi dok je season field otvoren; karusel Stage i dalje blokira.

Ovisi o FIELD-P0. A/B smiju biti gotovi. Freeze P221–P224 P232. Ne Daily (A). Ne picker (B). Ne Magnet UI (D) osim što chrome lista smije uključiti UniqueName ako D još nije — dodaj Daily/Basket/Settings/chip/PlayRow sad; D doda Magnet/Loot u istu grupu.

Danas: season_stage.gd add_to_group(block_hub_swipe) uvijek. swipe_pager should_block_hub_swipe_at. Full-bleed field = cijeli Home blokiran. meta_hub_pages COLLECTION=1 MAIN=2 CAMP=3.

FIELD-C:
1) home_season_field_open false: Stage ostaje u grupi (karusel L/R sezona).
2) Field open: Stage remove_from_group. Close/karusel: add natrag.
3) Field open: Daily, Basket, Settings, SeasonNameChip, PlayRow (i Magnet/Loot ako postoje) u block_hub_swipe.
4) Lijevo Journal, desno Camp. home_season_field_open ostaje true kad pager ode s MAIN. Seasons/Back/Escape i dalje close (P174/P199).

Smokes: season_meadow_smoke + season_home_smoke — Bloom field open: mid-field should_block_hub_swipe_at false; Daily ili PlayRow rect true. Karusel field closed: Stage mid true (postojeći assert). go_to_page CAMP pa MAIN: home_season_field_open true, field_id isti.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, CAMP scene chrome, SAVE_VERSION, picker lista, Daily copy, Play routing, Pip FSM, SeedCatalog JSON, Endless Hard.

Relevantno: ideje-home-meadow-field-swipe.md, P221–P224, season_stage.gd BLOCK_HUB_SWIPE_GROUP, swipe_pager.gd should_block_hub_swipe_at, meta_hub_pages.gd, season_meadow_smoke.gd, season_home_smoke.gd.

Acceptance: iz polja swipe na Journal/Camp; karusel sezona L/R ostaje; polje se ne zatvara samim pagerom.
```

---

## 4 — FIELD-D (Magnet / Loot na polju) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow HOME-16 FIELD-D — Magnet i Loot Boost kompaktno gore desno na polju; kamp UpgradeCards hidden; spend 2 T3 ostaje.

Ovisi o FIELD-P0. C smije biti gotov (chrome grupa). Freeze P225–P229 P232. Ne Daily (A). Ne picker (B). Ne swipe logika osim add u block_hub_swipe. Ne CAMP3 Seeds/next-lock. Ne spajati s CAMP3-A.

Danas: camp_scene.tscn UpgradeCards SprinklerCard + LootCard s captionima. camp_controller try_upgrade_magnet(_selected_crystal_type). game_state try_upgrade_* 2 T3. Settings top-right na main_menu.

FIELD-D:
1) Kamp %UpgradeCards visible = false. UniqueName ostaje (camp_layout_smoke / camp_donate_smoke node lookup). Ne brisati try_upgrade_*, magnet_level, multiplier_level.
2) Field open: VBox gore desno ispod Settings — Magnet pa Loot Boost. Svaki: naslov + Upgrade (Maxed). Nema caption/px/×/Spend 2 flowers. Label Magnet ne Sprinkler.
3) Tap: try_upgrade_magnet("") / try_upgrade_multiplier(""). C11 cheapest ≥2. Nema IAP.
4) Karusel/close: hidden. meadow_safe_rect / _chrome_controls + ovi kontroleri. FIELD-C grupa: i ovi u block_hub_swipe kad visible.
5) camp_donate_smoke: GameState API ostaje; UI assertove prebaci na field UniqueNames ili skip visible kamp gumbe.

Smokes: season_meadow_smoke Bloom open: Magnet i Loot visible, y >= Settings end.y, Loot.y > Magnet.y; nema caption teksta px/×. Kamp: UpgradeCards hidden. try_upgrade_magnet s 2 T3 i dalje true. Close: field chrome hidden. Flowers ne sijeku novi chrome.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, SAVE_VERSION, Unlock JSON, leftover/vacuum, Pip FSM, Play routing, SeedCatalog JSON, Seeds/Flowers naslovi, next-lock kartica.

Relevantno: ideje-home-meadow-field-upgrades.md, P225–P229, camp_scene.tscn UpgradeCards, camp_controller.gd _on_upgrade_pressed, game_state.gd try_upgrade_magnet / try_upgrade_multiplier, season_field.gd _chrome_controls, camp_donate_smoke.gd.

Acceptance: upgrade se bira na polju; kamp kartice nestale; 2 T3 sink ostaje.
```

---

## 5 — CAMP3-A (Seeds / Flowers chrome + 10%) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-03 CAMP3-A — Seeds i Flowers samo naslov; GardenCliff/BagLabel/CrystalTotalLabel hidden; scrollovi +10%.

Ovisi o CAMP3-P0 i FIELD-D (UpgradeCards već hidden). Freeze C22–C27 C34. Upija C21. Ne Flowers rarity/select (B). Ne next-lock kartica (C). Ne spajati s FIELD-D.

Danas: GardenCliff hint; BagLabel Seeds: n/40; CrystalTotalLabel Flowers: n; SeedBagScroll i CrystalScroll min y 220.

CAMP3-A:
1) %GardenCliff UniqueName: visible false, text "". _garden_cliff_text vraca "". Ne setaj hint u UI.
2) %BagLabel hidden. %CrystalTotalLabel hidden. CrystalCliff ostaje hidden.
3) GardenTitle Seeds, CrystalTitle Flowers.
4) SeedBagScroll i CrystalScroll custom_minimum_size.y 220 -> 242, oba jednako.
5) UpgradeCards ostaju hidden. Exchange gumbi ostaju. StatusToast no-op.

Smokes: camp_layout_smoke — GardenCliff postoji, hidden ili prazan, nema Bag seeds are / Journal / 1 more T2. BagLabel i CrystalTotalLabel nisu visible. Naslovi Seeds/Flowers. Oba scrola min y ~242. UpgradeCards hidden. Toast hidden.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: try_upgrade_* API, Exchange rate, FIELD Magnet UI, Home UnlockGate, leftover/vacuum, SAVE_VERSION, Shop, AdMob.

Relevantno: ideje-camp-link-chrome.md, C22–C27, camp_scene.tscn GardenCliff BagLabel CrystalTotalLabel SeedBagScroll, camp_controller.gd _refresh_garden_card / _garden_cliff_text, camp_layout_smoke.gd.

Acceptance: Seeds = naslov pa grid pa Trade; Flowers = naslov pa grid pa Exchange; oba +10%.
```

---

## 6 — CAMP3-B (Flowers kao Seeds) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-03 CAMP3-B — Flowers chip rarity boje kao Seeds; auto-select za Exchange kao Trade.

Ovisi o CAMP3-P0. A smije biti gotov. Freeze C28 C29 C30 C34. Ne chrome hide/counts (A). Ne next-lock (C). Ne mijenjati crystal_exchange rate.

Danas: crystal_stash_chip WARM_WHITE bg. _validate_crystal_selection clear kad count 0. camp_crystal_select_smoke ocekuje clear. seed_bag_chip rarity_bg + _next_trade_type_after.

CAMP3-B:
1) CrystalStashChip rarity_bg_color + selected lighten kao SeedBagChip. Zvijezdice u imenu ostaju.
2) Default select prvi ASC na page show (_force_default ili crystal twin). Persist dok count >= 1. Nakon deplete sljedeci tip (_next_crystal_type_after).
3) Azurirati camp_crystal_select_smoke: clover 0 + daisy ostaje -> daisy selected, Exchange enabled.

Smokes: camp_crystal_select_smoke + po potrebi layout — rarity bg ★1 != ★3; auto-select next; Exchange ostaje za leftover 1.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: GardenCliff/BagLabel, scroll size, UpgradeCards, Home, Shop, AdMob, SAVE_VERSION, try_upgrade_*, SeedCatalog JSON.

Relevantno: ideje-camp-link-flowers.md, C28–C30, crystal_stash_chip.gd, camp_controller.gd _validate_crystal_selection / _on_crystal_exchange_pressed, camp_crystal_select_smoke.gd, camp_trade_select_smoke.gd (uzor).

Acceptance: Flowers izgleda i trejda kao Seeds.
```

---

## 7 — CAMP3-C (Next-lock kartica → Home) ✅ 2026-09-02

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-03 CAMP3-C — kamp kartica zaključane free sezone (barovi + Unlock); Unlock vodi na Home locked poster, ne zove unlock_free.

Ovisi o CAMP3-A (ista visina kartica). B smije biti gotov. Freeze C31–C34. Ne Flowers parity. Ne Magnet. Fair F2P: kamp gumb ne trosi coins.

Danas: season_unlock_gate.gd refresh_gate za next_locked_free_id: coins/T3 bari + Unlock -> unlock_free. Kamp nema ekvivalenta.

CAMP3-C:
1) Nova kartica %SeasonLinkCard (ime slobodno uz UniqueName) u camp Content. custom_minimum_size.y ista kao GardenCard/CrystalCard nakon +10%.
2) Sadrzaj kao Home gate: Coins n/need, Seeds n/need, ProgressBari, Unlock. Boje SeasonTheme / season_card_contrast te sezone.
3) Samo Unlock MOUSE_FILTER_STOP. Ostalo IGNORE. Tap gumba: set_free_strip_focus(id), home_band free, close_season_field, go_to_meta_page(MAIN). NE unlock_free.
4) next_locked_free_id prazan -> kartica hidden. Paid ne.

Smokes: camp + hub — Bloom unlocked Frost next lock: kartica visible; bar values match gate; Unlock clicked -> page MAIN, strip_focus next lock, home_season_field_open false, wallet_coins ne padaju; Home UnlockGate visible. Nema next: kartica hidden. Height ≈ GardenCard.

Headless --rendering-driver opengl3 --path game --script. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Shop, AdMob, Unlock JSON cost, leftover/vacuum, SAVE_VERSION, try_upgrade_*, SeedCatalog JSON, FIELD picker/Daily.

Relevantno: ideje-camp-link-season.md, C31–C33, season_unlock_gate.gd refresh_gate, game_state.gd next_locked_free_id / unlock_free / go_to_meta_page / set_free_strip_focus, camp_scene.tscn, meta_hub_pages.gd MAIN.

Acceptance: kamp pokazuje isti progres kao locked free na Homeu; Unlock je link, ne spend.
```

---

## Redoslijed i ovisnosti

1. **FIELD-P0 + CAMP3-P0** docs — **✅ 2026-09-02**.  
2. **FIELD-A** Daily body — **✅ 2026-09-02**.  
3. **FIELD-B** Basket no-scroll — **✅ 2026-09-02**.  
4. **FIELD-C** Hub swipe u polju — **✅ 2026-09-02**.  
5. **FIELD-D** Magnet/Loot na polju + hide kamp kartice — **✅ 2026-09-02**.  
6. **CAMP3-A** Seeds/Flowers chrome +10% — **✅ 2026-09-02**.  
7. **CAMP3-B** Flowers = Seeds — **✅ 2026-09-02**.  
8. **CAMP3-C** Next-lock kartica — **✅ 2026-09-02**.  
9. Ne spajati D+A. Ne pasteati CAMP2-A. Ne spajati s DOCK/CAMP-01 kodom.

## Povezano

- [[../03-content/ideje-home-meadow-field|HOME-16 hub]] · [[../03-content/ideje-camp-link|CAMP-03 hub]]  
- [[../03-content/ideje-home-meadow-dock|HOME-15]] · [[../03-content/ideje-camp-cliff|CAMP-02]]  
- [[CHECKPOINT|CHECKPOINT]]
