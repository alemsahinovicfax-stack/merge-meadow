---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, kamp, ux, cliff, plan, prompt]
povezano:
  - ideje-camp-cliff
  - ideje-camp-cliff-pitanja
  - ideje-camp
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi CAMP-02 — CAMP2-P0 ✅ docs → A GardenCliff hidden."
---

# Plan promptovi — CAMP-02 Seeds cliff

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **CAMP2-P0 ✅ → A**.  
> **Ideje:** [[../03-content/ideje-camp-cliff|hub]] · [[../03-content/ideje-camp-cliff-pitanja|C21]]  
> **Grana:** **`master`**. Nije D0 blocker. Ne spajati s [[plan-prompts-seed-meadow|SEED/HOME-12]].

**CAMP2-P0** ✅ 2026-09-01 (docs). **A** još nije.

## Freeze

C21: `%GardenCliff` UniqueName ostaje; uvijek `visible = false` i `text = ""`; `_garden_cliff_text` vraća `""`. Override C7 za taj slot. C1–C6, C8–C20 ostaju.

Ne dirati: Flowers, Upgrade, Exchange, footer, Home, Shop, AdMob, arena leftover/sort, SAVE_VERSION.

---

## Prompt — CAMP2-P0 (Docs) — urađeno 2026-09-01

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow CAMP-02 docs freeze — prazna rupa između Seeds naslova i Seeds: n/cap.

Dokumentiraj C21: GardenCliff (Bag seeds are T1…) nestaje vizualno; node ostaje UniqueName; override CAMP-01 C7 samo za taj slot. Nema game/ u P0. Ne dirati Home meadow, Flowers spend, merge-arena-v1.1. CHECKPOINT sljedeci_korak ostaje D0-P. Grana master.

Fajlovi: ideje-camp-cliff.md hub; ideje-camp-cliff-pitanja.md C21; plan-prompts-camp-cliff.md P0 A. Wire ideje-camp, _index, ideje-kad-predloziti, CHECKPOINT CAMP-02 red + zadnja_sesija, changelog.
```

---

## Prompt — CAMP2-A (GardenCliff van)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow CAMP-02 CAMP2-A — između Seeds i Seeds: n/cap nema teksta.

Freeze C21: %GardenCliff UniqueName ostaje (camp_layout_smoke required). Uvijek visible = false i text = "". _garden_cliff_text vraća "". Tscn default text prazan (ne "Run → collect seeds…"). Override CAMP-01 C7 za taj slot — tutorial/bag/flowers/fallback nestaju iz GardenCliff; ne premještati u drugi label. CrystalCliff već hidden — isti pattern.

camp_controller.gd _refresh_garden_card: ako garden_cliff, text = "" i visible = false (ne setaj _garden_cliff_text rezultat u UI). BagLabel, SeedBagGrid, Exchange ostaju.

Smokes: camp_layout_smoke — GardenCliff node postoji; visible false ILI text prazan; cliff_text i _garden_cliff_text(0,0) NE sadrže "Bag seeds are", "New blooms in Journal", "1 more T2". Ostali A assertovi (Seeds/Flowers naslovi, toast hidden, nema PipSlot) ostaju.

Headless --rendering-driver opengl3. Ne GUI usred A. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch. Grana master.

Ne dirati: Flowers, Upgrade try_upgrade_*, Exchange rate, footer Merge/Play, Home, Shop, AdMob, arena leftover/sort, SAVE_VERSION, CAMP_BED_BONUS, donate_bloom.

Relevantno: docs/03-content/ideje-camp-cliff.md, ideje-camp-cliff-pitanja.md C21, camp_scene.tscn GardenCliff, camp_controller.gd _garden_cliff_text / _refresh_garden_card, camp_layout_smoke.gd.

Acceptance: Seeds kartica = naslov pa odmah Seeds: n/cap; nema "Bag seeds are"; UniqueName GardenCliff ostaje; Flowers/Upgrade netaknuti.
```

---

## Redoslijed i ovisnosti

1. **CAMP2-P0** docs — **✅ 2026-09-01**.  
2. **CAMP2-A** GardenCliff hide.  
3. Ne spajati s HOME-12 meadow kodom.

## Povezano

- [[../03-content/ideje-camp|CAMP-01]] · [[plan-prompts-camp|CAMP-01 prompti]]
- [[plan-prompts-seed-meadow|SEED-01 + HOME-12]] (odvojen track)
- [[CHECKPOINT|CHECKPOINT]]
