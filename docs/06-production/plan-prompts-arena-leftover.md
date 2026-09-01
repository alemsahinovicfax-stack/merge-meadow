---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, arena, leftover, pour, popup, plan, prompt]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-grupe
  - ideje-arena-leftover-pitanja
  - ideje-arena-leftover-math
  - ideje-arena-leftover-pour
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena-sort
  - plan-prompts-arena-sort
  - ideje-arena
  - plan-prompts-arena
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi ARENA-02 — P0/A/B/C-P0/C/D ✅; E-P0 ✅; E kod superseded od ARENA-03 SORT-B."
---

# Plan promptovi — ARENA-02 leftover / ÷4 pour / “You need more seeds”

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **LEFTOVER-P0 → A → B → C-P0 → C → D → E-P0**. **Ne LEFTOVER-E** — zamjena [[plan-prompts-arena-sort|SORT-B]]. Ne spajati A i B. Ne spajati **C i D**. Overlay prompti (B/C) se ne dira u sort. Ne COMB/FLOW rewrite.  
> **Nasljednik pour:** [[plan-prompts-arena-sort|ARENA-03 SORT-P0 → A → B]]. Overlay B+C i grant D **ostaju**.  
> **Grupe:** [[../03-content/ideje-arena-leftover-grupe|ideje-arena-leftover-grupe]] · freeze [[../03-content/ideje-arena-leftover-pitanja|pitanja]] · hub [[../03-content/ideje-arena-leftover|ideje-arena-leftover]]  
> **Grana:** **`master`**. Nije D0 blocker. Kanon [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] se **ne** prepisuje dok „dodaj u scope“.

**LEFTOVER-P0** ✅ 2026-08-28 (docs). **A** ✅ pour ÷4 + refill 12. **B** ✅ overlay n/4 → Camp. **C-P0** ✅ docs L21–L30. **C** ✅ hide + svijetli naslov. **E-P0** ✅ docs L31–L37 (field T1). **D** ✅ debug 100 T1. **E** **ne** — [[plan-prompts-arena-sort|SORT-B]].

## Freeze (sažetak za agente)

L0b: pour **uvijek** `floor(n/4)*4` **po `type_id`** (ručni tap **i** auto). 6 clover → 4 polje, 2 torba.  
L0c: `ARENA_AUTO_REFILL_AT = 12` (bilo 10). Cap polja **40**. Polje **0** ne auto-poura (FLOW-B). Done slobodan.  
L0d: kad pull==0 i bag>0 i ima slota → overlay **You need more seeds!** + kamp T1 lista **`n/4`**. Tap **bilo gdje** → Camp (isti commit kao Done). Nije IAP, nije fail. Done/Back bez overlaya ostaju.  
L2: A15 orphan **ne** trese 3 da se spoji s 1 na polju. Orphan samo ako pour `% 4 == 0`.  
L1 reopen / L31–L37: mid-session T1 **bez para** tog tipa ide u torbu. Po `type_id`, samo T1: `count % 2 == 1` → vrati **jedan** idle T1 (`add_seeds_to_bag` + `_remove_chip`). 1→bag; 3→1 bag + 2 polje; 5→1 bag + 4 polje. Nije `n%4`. Nije pour 1–3 iz torbe (L2). Trigger: `_pest_eat_chip` i nakon mergea; `_resolve_stranded_t1` **prije** `_resolve_stranded_t2`. Skip dragging. Bag full (`remaining_capacity < 1`) ostavi T1. Overlay B+C, pour A, refill 12, pest tajmeri/T3 freeze, combo HUD — **ne dirati**. FEEL-B ostaje. Mythic isto. Nema SAVE_VERSION. Debug bag 100 = D (`apply_debug_leftover_test_bag`); E to ne dira.  
L3 mythic isto ÷4. L5 hide 0. L6 nema tutorial. L8 redovi nisu trade. L9 EN copy. L13 nema SAVE_VERSION. L15 auto-refill **ne** otvara overlay.  
L21–L23: hide overlay + clear lista **prije** `go_to_camp_hub` (Done, Back, overlay tap); `set_arena_page_active(false)` hide; povratak Arena taba = čist ekran (prazno polje, overlay false), torba zadrži remainder.  
L24: naslov EN **You need more seeds!** **u popup-u**, svijetla boja (ne `UI_TEXT` `#4A4A4A` na tamnom panelu). Nema extra tutorial pasusa (L6).  
L25: C ne dira pour / kada se overlay otvara. L15 auto-refill i dalje ne otvara overlay.  
L26–L30: debug `DEBUG_DEV_RESOURCES` overwrite torbe **jednom po procesu** na freeze 100: clover 19, daisy 22, buttercup 13, tulip 28, sunflower 18. Ne na Arena tab return. Ugasiti `ensure_dev_unlocked_seeds(10)` top-up. `grant_test_seeds.gd` ista mapa. Soft cap 40 ostaje. Nema SAVE_VERSION.

G3 ne kodirati kao feature. Citiraj „Ne dirati“ u C, D i E. G5 Field = E-P0 / E (nije ARENA-01 G5).

Ne dirati (svi sliceovi): combo HUD/coins/pulse, daily keys, Pip/tint, pest FSM, Home, Shop, AdMob, bloom panel, Sort, energy, fail u areni, pay-to-merge, kanon `merge-arena-v1.1.md`. C ne dira pour math. D ne dira overlay hide. E ne dira overlay, pour, `ensure_dev` (D).

---

## Prompt — LEFTOVER-P0 (Docs)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow ARENA-02 docs freeze — leftover T1, pour ÷4 po tipu, refill 12, overlay You need more seeds.

Dokumentiraj L0–L20: odd T1 ne smiju na playfield; ručni tap i auto-pour uvijek trese floor(n/4)*4 po type_id (6 clover → 4 van, 2 bag); ARENA_AUTO_REFILL_AT 10 → 12; polje 0 i dalje ne auto-poura; kad nijedan tip nema ≥4, vreća ostaje klikabilna → overlay + ista kamp T1 lista s count n/4; tap bilo gdje → Camp kao Done. Fair F2P: nije IAP, nije pay-to-merge.

Nema game/ u P0 osim citata postojećeg koda. Ne dirati merge-arena-v1.1.md. Ne CHECKPOINT sljedeci_korak (ostaje D0-P). Grana master.

Fajlovi: ideje-arena-leftover.md hub; leftover-math / pour / popup / pitanja / grupe; plan-prompts-arena-leftover.md P0 A B. Wire _index, ideje-arena (link ARENA-02, ne brisati ARENA-01), ideje-kad-predloziti, CHECKPOINT samo ARENA red + povezano, changelog.

Relevantno: merge_arena_controller.gd ARENA_AUTO_REFILL_AT, game_state.gd pull_seeds_to_arena, seed_bag_chip.gd, plan-prompts-arena.md FLOW-B, ideje-arena A14 A15 A25.
```

---

## Prompt — LEFTOVER-A (Pour floor-4 + refill 12)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-02 LEFTOVER-A — pour samo višekratnik 4 po tipu; auto-refill prag 12.

Freeze G1: L0b uvijek floor(bag[type]/4)*4 u pull_seeds_to_arena / _build_arena_pour_queue (ručni tap I auto-pour). 20 clover → svih 20 ako ima slota. 7 daisy → 4 van, 3 bag. 3 daisy → 0 pulled. L0c ARENA_AUTO_REFILL_AT := 12 (bilo 10); ARENA_MAX_CHIPS 40; polje 0 i dalje NE auto-poura; Done slobodan. L2 A15 orphan prefer SAMO ako količina poura % 4 == 0 — NE tresti 3 da se spoji s 1 na polju. L3 mythic isto ÷4. L7 ne dirati SEED_BAG_SOFT_CAP. L11 FLOW-A leftover T2 recycle ostaje. L14 remainder tap nije "Nothing to pour." — overlay je B.

Ne overlay u A. Kad queue nema ×4, pull vraća [] i bag ostaje; auto-refill ne spam-a overlay (L15).

Kod: game_state.gd pull_seeds_to_arena, _build_arena_pour_queue; merge_arena_controller.gd ARENA_AUTO_REFILL_AT i _try_auto_refill usporedba <= 12. Komentar: A15 podređen ÷4, nije ukinut zauvijek.

Smokes: 6 clover u bagu, 0 na polju → pulled 4, bag clover 2. 3 daisy → pulled 0, daisy ostaje 3, nijedan chip na polju. Mixed: clover 6 + daisy 3 → samo 4 clover. Auto: polje s 13 chipova, merge na 12 → pour (prag <= 12, raspon 1..12); polje 0 ne auto. Ažurirati arena_flow_b_smoke prag 10 → 12. Cap 40 ostaje. Ne dirati combo/daily/Pip smokes osim ako FLOW-B assertira 10.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: combo HUD/coins/pulse, daily keys, Pip/tint, FEEL-B VFX, pest FSM, Home, Shop, AdMob, SAVE_VERSION, bloom panel, Sort, kanon merge-arena-v1.1.md, overlay / SeedBagChip u areni (to je B).

Relevantno: docs/03-content/ideje-arena-leftover-pour.md, ideje-arena-leftover-math.md, ideje-arena-leftover-pitanja.md L0b L0c L2 L3 L7, ideje-arena-leftover-grupe.md G1, plan-prompts-arena-leftover.md, merge_arena_controller.gd, game_state.gd, arena_flow_b_smoke.gd.

Acceptance: 6 clover → 4 na polje 2 u torbi; 3 daisy nikad na polje; auto-pour pali se na 12 ne na 10; polje 0 ne auto; Done radi; FLOW-A T2 recycle i combo HUD netaknuti.
```

---

## Prompt — LEFTOVER-B (Overlay n/4 → Camp)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-02 LEFTOVER-B — kad pour ne može ×4, bag tap otvara You need more seeds + kamp lista n/4; tap overlay → Camp.

Freeze G2: L0d vreća ostaje klikabilna. Kad pulled==0 i bag>0 i ima slota → overlay, NE spawn chipova, NE "Nothing to pour." kao dead-end. L4 tap bilo gdje na overlay = isti commit kao Done (_on_done_pressed / go_to_camp_hub) — hub Arena tab I standalone scena. L5 tipovi s 0 skriveni. L8 redovi liste NISU tappable trade; tap bilo gdje = camp. L6 nema tutorial toast. L9 EN "You need more seeds!". L15 auto-refill pull 0 NE otvara overlay. L16 arena full = postojeća full poruka, nije ovaj overlay. L17 bag 0 = postojeća empty poruka.

Reuse: GameState.get_seed_bag_entries() isti redoslijed rarity+ime kao kamp; SeedBagChip look; u overlayu count copy = "n/4" (npr. 3/4), ne trade. Lista read-only.

Ne dirati pour math iz A (floor-4, refill 12). Ne IAP, ne ads, ne coin sink za odd T1 (L18). Overlay nije persist (L13 nema SAVE_VERSION).

Smokes: 3 unique T1 u bagu (npr. clover 1, daisy 2, tulip 3), 0 na polju, tap bag → 0 chipova spawnano, overlay vidljiv, labeli n/4, tap overlay → camp hub, wallet ne raste. Bag s 4 clover i dalje poura 4, nema overlaya. Auto-refill na remainder-only ne diže overlay. Done/Back bez overlaya i dalje rade.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred B. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: pull_seeds_to_arena floor-4, ARENA_AUTO_REFILL_AT, combo/daily/Pip, pest, Home, Shop, AdMob, kanon spec.

Relevantno: docs/03-content/ideje-arena-leftover-popup.md, ideje-arena-leftover-pitanja.md L0d L4–L9 L15–L17, ideje-arena-leftover-grupe.md G2, camp_controller get_seed_bag_entries, seed_bag_chip.gd, merge_arena_controller _on_bag_clicked _on_done_pressed.

Acceptance: remainder-only bag, tap vreće ne stavlja T1 na polje; overlay "You need more seeds!" + 3/4 redovi; tap bilo gdje → Camp s chipovima u bagu; Done i dalje radi bez popup-a; Fair F2P — nema buy/ad gumba.
```

---

## Prompt — LEFTOVER-C-P0 (Docs dismiss + grant freeze)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow ARENA-02 LEFTOVER-C-P0 docs — leftover overlay se gasi pri odlasku u Camp; Arena tab izgleda kao prije; naslov You need more seeds čitljiv u popup-u; debug 100 T1 freeze.

Dokumentiraj L21–L30 opširno (hrvatski scratch). Hub persist: meta_hub drži Arena page; _on_done_pressed ne hidea NeedMoreSeedsOverlay. Naslov postoji u tscn ali section_title_scroll stavlja UI_TEXT #4A4A4A na tamni panel. Debug: ensure_dev_unlocked_seeds(10) diže remainder 1–3 na 10.

Freeze: hide prije go_to_camp_hub (Done/Back/overlay tap) + set_arena_page_active(false); povratak = overlay false, prazno polje, bag remainder ostaje; naslov EN You need more seeds! svijetao u panelu, bez tutorial pasusa; C ne dira pour. Debug svaki play jednom po procesu overwrite clover 19 daisy 22 buttercup 13 tulip 28 sunflower 18 (zbroj 100); ne na Arena tab return; ugasiti min-10; grant_test_seeds ista mapa; soft cap 40; nema SAVE_VERSION. Fair F2P: nije IAP.

Nema game/ u C-P0 osim citata. Ne dirati merge-arena-v1.1.md. Ne CHECKPOINT sljedeci_korak (ostaje D0-P). Grana master.

Fajlovi: ideje-arena-leftover.md hub; ideje-arena-leftover-popup.md; NOVI ideje-arena-leftover-grant.md; pitanja L21–L30; grupe G2 nastavak + G4; plan-prompts-arena-leftover.md C-P0 C D (P0/A/B arhiva ✅). Wire _index, ideje-arena nasljednik, ideje-kad-predloziti, CHECKPOINT samo ARENA red + zadnja_sesija, changelog. Math/pour samo kratki link.

Relevantno: merge_arena_controller.gd _on_done_pressed set_arena_page_active need_more_overlay; ui_text_layout.gd section_title_scroll; ui_palette.gd UI_TEXT; game_state.gd ensure_dev_unlocked_seeds DEBUG_DEV_RESOURCES; tools/grant_test_seeds.gd; meta_hub_controller.gd _arena_page.
```

---

## Prompt — LEFTOVER-C (Hide overlay + čitljiv naslov)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-02 LEFTOVER-C — leftover popup se zatvori kad igrač ide u Camp; povratak na Arena tab je čist ekran; You need more seeds! čitljiv u popup-u.

Freeze G2 nastavak: L21 helper _hide_need_more_overlay() — visible=false + clear NeedMoreSeedsList children — PRIJE go_to_camp_hub. Zvati iz _on_done_pressed, _on_back_pressed (overlay tap već zove Done). L22 set_arena_page_active(false) također hide. L23 povratak: overlay false, 0 chipova, combo/feel već reset; seed_bag remainder OSTAJE. L24 NeedMoreSeedsTitle ostaje "You need more seeds!"; NE section_title_scroll ink (UI_TEXT #4A4A4A); svijetla font_color na dim panelu; naslov shrink, scroll lista expand. L25 ne dirati pour floor-4, ARENA_AUTO_REFILL_AT 12, kada se overlay OTVARA, L15 auto-refill.

Hub: meta_hub_controller drži _arena_page — zato hide mora biti eksplicitan. Fair F2P: nema IAP/ad/buy u overlayu.

Smokes: novi ili prošireni arena_leftover_c_smoke — overlay visible → Done ili overlay gui_input → overlay visible==false, lista prazna; set_arena_page_active(true) overlay i dalje false, chipova 0; set_arena_page_active(false) hide remen; title text sadrži You need more seeds, font_color nije #4A4A4A. leftover_b_smoke i dalje prolazi. Ne čekati SceneRouter meta hub (deferred).

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred C. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: pull_seeds_to_arena, ARENA_AUTO_REFILL_AT, combo/daily/Pip, pest, Home, Shop, AdMob, SAVE_VERSION, grant/ensure_dev (to je D), kanon merge-arena-v1.1.md.

Relevantno: docs/03-content/ideje-arena-leftover-popup.md, ideje-arena-leftover-pitanja.md L21–L25, ideje-arena-leftover-grupe.md G2, plan-prompts-arena-leftover.md, merge_arena_controller.gd, merge_arena.tscn NeedMoreSeedsTitle, ui_text_layout.gd, ui_palette.gd.

Acceptance: tap overlay → Camp; vrati se na Arena = nema popup-a, prazno polje, vreća s remainderom; dok je overlay otvoren naslov You need more seeds! se VIDI; pour A netaknut.
```

---

## Prompt — LEFTOVER-D (Debug 100 T1 freeze)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-02 LEFTOVER-D — svaki debug play prepisuje torbu na freeze 100 T1, 5 tipova, isti brojevi svaki F5.

Freeze G4: L26 DEBUG_DEV_RESOURCES: jednom po OS procesu NAKON load savea overwrite seed_bag. Process flag (nije save key) — drugi call u istom playu NE vraća freeze ako je igrač potrošio. NE overwrite na set_arena_page_active / Arena tab return. L27 clover daisy buttercup tulip sunflower; seed_unlock_index 4; tutorial_complete; discovered_blooms tih 5; SEED_BAG_SOFT_CAP ostaje 40 (overwrite smije biti 100 u dict kao grant_test_seeds). Produkcija flag false = no-op. L28 TOČNO: clover 19, daisy 22, buttercup 13, tulip 28, sunflower 18 (zbroj 100). Nije randi(). L29 merge_arena_controller _deferred_boot PRESTAJE zvati ensure_dev_unlocked_seeds(10) — remainder 3 ne smije postati 10. L30 grant_test_seeds.gd ista mapa. L13 nema SAVE_VERSION.

Ne dirati overlay hide (C), pour math (A), refill 12. Ne spajati s E (field T1 return nije grant).

Smokes: arena_leftover_d_smoke ili grant smoke — apply → bag točno freeze, zbroj 100; drugi apply nakon clover=1 ne resetira na 19; DEBUG_DEV_RESOURCES false no-op; grant_test_seeds headless ista tablica. Soft cap konstanta 40.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred D. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay, _hide_need_more_overlay, pull_seeds_to_arena floor-4, combo/daily/Pip, pest, Home, Shop, AdMob, kanon spec.

Relevantno: docs/03-content/ideje-arena-leftover-grant.md, ideje-arena-leftover-pitanja.md L26–L30, ideje-arena-leftover-grupe.md G4, game_state.gd DEBUG_DEV_RESOURCES ensure_dev_unlocked_seeds, merge_arena_controller.gd _deferred_boot, game/tools/grant_test_seeds.gd.

Acceptance: F5 / godot-run → torba 19/22/13/28/18 svaki put; kamp loot u istoj sesiji ostaje kad se vratiš na Arena tab; produkcija path ne dira bag; leftover overlay i dalje testabilan (remainderi nakon poura).
```

---

## Prompt — LEFTOVER-E-P0 (Docs field leftover T1)

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow ARENA-02 LEFTOVER-E-P0 docs — mid-session unpaired T1 of a type leave the field back to the bag (Muncher no longer leaves dead seeds). Overlay stays as-is.

Dokumentiraj L31–L37 opširno (hrvatski scratch). L1 reopen: FLOW-A `_resolve_stranded_t2` vraća samo T2 bez para; odd T1 ostaju na polju do Done. Pour A drži remainder u torbi (n%4). Muncher jede 1 od 4 → 3 T1. Overlay You need more seeds ostaje B+C (ne dirati). Pour ÷4 / refill 12 ostaju. Fair F2P: nema IAP.

Freeze: po type_id, samo T1; count % 2 == 1 → vrati JEDAN T1 u torbu (1→bag; 3→1 bag + 2 polje; 5→1 bag + 4 polje). Nije n%4 (ne sva 3). Nije pour 1–3 iz torbe da se popravi ×4 (L2). Trigger: isti kao FLOW-A — _pest_eat_chip i nakon uspješnog mergea; _resolve_stranded_t1 PRIJE _resolve_stranded_t2. Chip: ne dragging, idle; skip ako nijedan slobodan. Bag full remaining_capacity < 1 → ostavi T1. Soft cap 40. Overlay / C hide / pour A / refill 12 / combo HUD / pest FSM — ne dirati osim što eat zove resolve. FEEL-B ostaje. Mythic isto. Nema SAVE_VERSION.

Zašto 50 ne 100: stari playtest = ensure_dev(10)×5. LEFTOVER-D ✅ freeze 19/22/13/28/18. E ne kodira D. Ne spajati D i E.

Nema game/ u E-P0 osim citata. Ne dirati merge-arena-v1.1.md. Ne CHECKPOINT sljedeci_korak (ostaje D0-P). Grana master.

Fajlovi: NOVI ideje-arena-leftover-field.md; hub leftover; leftover-math (polje n%2 vs torba n%4); pitanja L1 + L31–L37; grupe G5 Field + G3 bez L1 blokade; plan-prompts-arena-leftover.md E-P0 E (D ostaje pending zasebno). Overlay prompti ne dirati. Popup/grant kratki link „E nije overlay / E nije 100 grant“. Wire _index, ideje-kad-predloziti, CHECKPOINT samo ARENA red + zadnja_sesija, changelog.

Relevantno: merge_arena_controller.gd _pest_eat_chip _resolve_stranded_t2 _t2_has_pair_chance; ideje-arena-leftover-popup; ideje-arena-leftover-grant.
```

---

## Prompt — LEFTOVER-E (Field unpaired T1 → bag)

> **Ne zalijevati.** E kod superseded — koristi [[plan-prompts-arena-sort|SORT-B]]. Ostaje ovdje kao povijesni prompt.

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-02 LEFTOVER-E — mid-session neparni T1 tog tipa ide u torbu; Muncher više ne ostavlja mrtvo sjeme na polju.

Freeze G5: L31 po type_id, samo T1; ako je T1 count neparan, add_seeds_to_bag(type, 1) + _remove_chip jednog idle T1. 1→bag; 3→1 bag + 2 polje; 5→1 bag + 4 polje. Nije n%4. Nije pour remainder da se spoji s poljem (L2). L32 _resolve_stranded_t1 pored _resolve_stranded_t2; zvati s istih mjesta (eat + merge); T1 PRIJE T2. L33 ne dragging; skip ako nijedan idle (kao T2 kad bag nema mjesta). L34 seed_bag_remaining_capacity() < 1 → ostavi T1. Soft cap 40 se ne dize. L35 overlay B+C, pour floor-4, refill 12, combo HUD, pest tajmeri/eat duration/T3 freeze — ne dirati osim eat callback zove novi resolve. L36 FEEL-B ostaje. L37 mythic isto n%2. Nema SAVE_VERSION.

Ne dirati overlay, pour, leftover D apply. D već stavlja 100 T1; to nije muncher bug. Ne spajati D i E.

Smokes: 4 clover na polju, simulirani eat 1 → 2 na polju, bag +1 clover; 1 daisy T1 sam → 0 na polju, bag +1; 2 clover ostaju (ne diraj par); leftover_a/b/c i FLOW-A T2 recycle i dalje prolaze. Overlay se ne otvara od eat/resolve.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred E. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: NeedMoreSeedsOverlay, _hide_need_more_overlay, pull_seeds_to_arena floor-4, ARENA_AUTO_REFILL_AT, ensure_dev_unlocked_seeds, combo/daily/Pip, pest FSM osim eat→resolve, Home, Shop, AdMob, kanon spec.

Relevantno: docs/03-content/ideje-arena-leftover-field.md, ideje-arena-leftover-pitanja.md L1 L31–L37, ideje-arena-leftover-grupe.md G5, plan-prompts-arena-leftover.md, merge_arena_controller.gd _pest_eat_chip _resolve_stranded_t2 _t2_has_pair_chance.

Acceptance: 4 clover eat 1 → 2 polje + bag clover +1; solo daisy → bag; par 2 ostaje; overlay i pour netaknuti; FLOW-A T2 recycle radi.
```

---

## Redoslijed i ovisnosti

1. **LEFTOVER-P0** prvo (docs) — **✅ 2026-08-28**.  
2. **LEFTOVER-A** pour math + refill 12 — **✅ 2026-08-28**.  
3. **LEFTOVER-B** overlay — **✅ 2026-08-28**.  
4. **LEFTOVER-C-P0** docs dismiss + grant freeze — **✅ 2026-08-28**.  
5. **LEFTOVER-C** hide overlay + naslov — **✅ 2026-08-28**.  
6. **LEFTOVER-E-P0** docs field T1 — **✅ 2026-08-28**.  
7. **LEFTOVER-D** debug 100 — **✅ 2026-08-28**.  
8. **LEFTOVER-E** `_resolve_stranded_t1` — **ne raditi** (ARENA-03 SORT-B).  
9. Ne spajati A i B. Ne spajati **C i D**. Overlay B/C prompti se ne dira u sort. Ne COMB-A / FLOW rewrite u istom chatu.  
10. G3 (FEEL-B, combo, SAVE_VERSION, coin sink) nema prompta. L1 je G5, ne G3.

## Povezano

- [[../03-content/ideje-arena-leftover|hub]] · [[../03-content/ideje-arena-leftover-grupe|grupe]] · [[../03-content/ideje-arena-leftover-pitanja|pitanja]]
- [[../03-content/ideje-arena-leftover-popup|popup]] · [[../03-content/ideje-arena-leftover-grant|grant]] · [[../03-content/ideje-arena-leftover-field|field]]
- [[plan-prompts-arena|ARENA-01 prompti]] COMB-A…FEEL-B ✅
- [[plan-prompts-arena-sort|ARENA-03 sort]] SORT-P0 → A → B
- [[CHECKPOINT|CHECKPOINT]]
