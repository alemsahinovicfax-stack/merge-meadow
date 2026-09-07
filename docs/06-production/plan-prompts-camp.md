---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, kamp, ux, donate, plan, prompt]
povezano:
  - ideje-camp
  - ideje-camp-pitanja
  - ideje-camp-chrome
  - ideje-camp-donate
  - ideje-camp-grupe
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi CAMP-01 — P0 ✅ A ✅ B ✅."
---

# Plan promptovi — CAMP-01 razvoj kampa

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **CAMP-P0 ✅ → A ✅ → B ✅**. Ne spajati A i B.  
> **Grupe:** [[../03-content/ideje-camp-grupe|ideje-camp-grupe]] · freeze [[../03-content/ideje-camp-pitanja|pitanja]] · hub [[../03-content/ideje-camp|ideje-camp]]  
> **Grana:** **`master`**. Nije D0 blocker. Kanon [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] se **ne** prepisuje dok „dodaj u scope“.

**CAMP-P0** ✅ 2026-08-30 (docs). **A** ✅ 2026-08-30 (chrome). **B** ✅ 2026-08-30 (Flowers spend).

## Freeze (sažetak za agente)

C1: StatusToast no-op / hidden. C2: nema „New blooms in Journal…“. C20: nema „1 more T2 to upgrade Sprinkler.“ C7: ostali GardenCliff ostaju. C3: CrystalCliff cijeli sklonjen. C5/C6: naslov Seeds / Flowers; UniqueName ostaju. C4: RunPrepCard van. C15: companion API + Pip u runu. C19: nema Mochi camp toasta.

C8: oba upgradea = 2× T3 iz Flowers. C9: cost 2. C10: atomic tap, nema donated 1/2. C11: select ≥2 else cheapest rarity ≥2; nema 1+1. C12: Exchange ostaje. C13: caption = magnet px / loot × + Spend 2 flowers. C14: nema SAVE_VERSION.

C17/C18: Arena leftover/sort, Home, Shop, AdMob — ne dirati. Ne oživljavati `donate_bloom`. Ne `CAMP_BED_BONUS` rewrite.

Fair F2P: nema IAP na upgrade.

---

## Prompt — CAMP-P0 (Docs) — urađeno 2026-08-30

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow CAMP-01 docs freeze — kamp chrome + Flowers plaćaju Sprinkler i Loot Boost.

Dokumentiraj C1–C20 opširno (hrvatski scratch). Playtest: StatusToast van; Garden→Seeds; Flower stash→Flowers; companion picker van; journal i CrystalCliff tutorijal van; arena više ne donira — oba upgradea troše 2 T3 iz Flowers, atomic, caption kaže magnet/loot. Fair F2P: nema IAP.

Nema game/ u P0 osim citata. Ne dirati merge-arena-v1.1.md. Ne CHECKPOINT sljedeci_korak (ostaje D0-P). Grana master.

Fajlovi: NOVI ideje-camp.md hub; camp-pitanja / chrome / donate / grupe; plan-prompts-camp.md P0 A B. Wire _index, ideje-kad-predloziti, CHECKPOINT samo CAMP red + zadnja_sesija, changelog.
```

---

## Prompt — CAMP-A (Chrome) — urađeno 2026-08-30

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-01 CAMP-A — kamp chrome: manje tutorijala, jasniji naslovi, bez companion pickera.

Freeze G1: StatusToast + StatusLabel nestaju ili permanently hidden + _set_status_toast no-op (nema “Sprinkler upgraded!” na vrhu). GardenCliff ostaje, ali UKLONITI granu “New blooms in Journal — swipe to the Journal tab.” i granu “1 more T2 to upgrade Sprinkler.” Ostali cliff stringovi ostaju. CrystalCliff cijeli skloniti (Merge T3 in Arena… i Tap a flower type…). GardenTitle tekst “Seeds”. CrystalTitle tekst “Flowers”. RunPrepCard (For next run + Companion + Pip/Mochi) UKLONITI iz camp_scene; camp_controller bez _refresh_companion_ui / slot signala. GameState companion API, active_companion_id, Pip u runu NE dirati. Node imena GardenCard/GardenCliff/CrystalCard ostaju (camp_layout_smoke traži %GardenCliff).

Ne donate, ne GameState MAGNET_COST, ne caption rewrite Upgrade kartica (to je B). Ne Arena, Home, Shop, AdMob, Journal scene, SAVE_VERSION.

Smokes: camp_layout_smoke i dalje %GardenCliff postoji; dodati assert naslova Seeds i Flowers; StatusToast nije vidljiv nakon _refresh_ui(“x”); nema CompanionTitle/PipSlot u stablu ili nisu visible; CrystalCliff null ili hidden. Ažurirati string assertove ako postoje.

Headless --rendering-driver opengl3. Ne GUI usred A. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Relevantno: docs/03-content/ideje-camp-chrome.md, ideje-camp-pitanja.md C1–C7 C15 C19 C20, camp_scene.tscn, camp_controller.gd, camp_layout_smoke.gd.

Acceptance: nema žutog toasta; nema journal/T2/crystal tutorial captiona; Seeds + Flowers; nema companion izbora; trade/exchange/upgrade gumbi i dalje tu.
```

---

## Prompt — CAMP-B (Donate + copy) — urađeno 2026-08-30

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-01 CAMP-B — Sprinkler i Loot Boost se plaćaju iz Flowers; captioni objašnjavaju šta rade.

Freeze G2: Arena se NE vraća donate. Upgrade magnet i multiplier: ako level < max i postoji flower tip s count >= 2, gumb enabled. Tap skine 2 T3 s tog tipa (selektirani ako >= 2, inače najniža rarity s >= 2), zatim try_upgrade_* bez sprinkler_donations/multiplier_donations praga. Nema “donate in Arena”. Caption: efekat + trenutni/next broj (radius px / loot ×) + “Spend 2 flowers”. Maxed ostaje. Exchange 1 flower → coins ostaje, ne dira se rate. Ne 1+1 s dva tipa. Ne T2 stash. Ne oživljavati donate_bloom / bloom panel.

Smokes: novi camp_donate_smoke — 2 clover T3, magnet 0 → Upgrade → magnet 1, stash clover 0; 1 flower → gumb disabled; multiplier isto; max level ne troši. camp_layout_smoke i A assertovi prolaze. Arena leftover/sort smokes netaknuti.

Headless --rendering-driver opengl3. Ne GUI usred B. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: StatusToast (već mrtav), RunPrep, naslove Seeds/Flowers, Home, Shop, AdMob, kanon merge-arena-v1.1, FLOW-A leftover, SAVE_VERSION, CAMP_BED_BONUS logiku.

Relevantno: docs/03-content/ideje-camp-donate.md, ideje-camp-pitanja.md C8–C20, game_state.gd try_upgrade_magnet/try_upgrade_multiplier/garden_crystal_stash, camp_controller _refresh_upgrade_cards, ekonomija-brojevi.md.

Acceptance: Upgrade radi iz Flowers; caption kaže magnet/loot efekat; “donate in Arena” nestalo; arena i dalje ne donira.
```

---

## Redoslijed i ovisnosti

1. **CAMP-P0** docs — **✅ 2026-08-30**.  
2. **CAMP-A** chrome — **✅ 2026-08-30**.  
3. **CAMP-B** Flowers spend + caption — **✅ 2026-08-30**.  
4. Ne spajati A i B. Ne vraćati arena donate. Ne LEFTOVER/SORT rewrite.

## Povezano

- [[../03-content/ideje-camp|hub]] · [[../03-content/ideje-camp-grupe|grupe]] · [[../03-content/ideje-camp-pitanja|pitanja]]
- [[plan-prompts-camp-cliff|CAMP-02 cliff]] (GardenCliff — **CAMP2-A superseded** → CAMP3-A)
- [[plan-prompts-home-camp-field|HOME-16 + CAMP-03]]
- [[../03-content/ideje-arena|ARENA-01]] A11c · [[plan-prompts-arena|ARENA-01 prompti]]
- [[CHECKPOINT|CHECKPOINT]]
