---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, pitanja, ux, flowers, sezone, scratch]
povezano:
  - ideje-camp-link
  - ideje-camp-pitanja
  - ideje-camp-cliff-pitanja
  - plan-prompts-home-camp-field
  - CHECKPOINT
ai_sažetak: "CAMP-03 pitanja C22–C34 — naslovi only +10%; Flowers = Seeds; next-lock kartica link na Home. Override C7/C21; CAMP2-A superseded."
---

# IDEJE — CAMP-03 pitanja (C22–C34)

> [[ideje-camp-link|hub]]. Freeze **2026-09-02**.  
> C1–C21 ostaju osim override tablice. C8–C14 spend ostaje u GameState; UI je HOME-16 FIELD-D. **C21 kod = CAMP3-A** (CAMP2-A ne pasteati).

| # | Pitanje | Odluka |
|---|---------|--------|
| **C22** | GardenCliff? | UniqueName ostaje. Uvijek hidden + `text = ""`. `_garden_cliff_text` → `""`. Upija C21. |
| **C23** | `Seeds: n / 40`? | `%BagLabel` **hidden**. Naslov sekcije je samo **Seeds**. |
| **C24** | `Flowers: n`? | `%CrystalTotalLabel` **hidden**. Naslov samo **Flowers**. CrystalCliff ostaje hidden (C3). |
| **C25** | UniqueName / naslovi? | GardenTitle **Seeds**, CrystalTitle **Flowers**. GardenCard/CrystalCard imena ostaju. |
| **C26** | Veličina kartica? | Override **2026-09-03**: `SeedBagScroll` / `CrystalScroll` min y **280**, oba jednako. SeasonLink ista visina. |
| **C27** | UpgradeCards u kampu? | Ostaju **hidden** (FIELD-D). A ih **ne** vraća. UniqueName ostaje. |
| **C28** | Rarity na Flowers? | `rarity_bg_color` kao SeedBagChip (pozadina + selected). Zvijezdice u imenu kao Seeds. |
| **C29** | Auto-select Flowers? | Kao Seeds: default prvi ASC; persist ≥1; nakon deplete sljedeći tip. Exchange ostaje (C12). |
| **C30** | Crystal smoke? | `camp_crystal_select_smoke` očekuje next-select, ne clear-kad-ima-još-tipova. |
| **C31** | Next-lock kartica size? | Ista min visina kao GardenCard/CrystalCard **nakon** C26 (280). Treća kartica u Content. |
| **C32** | Kamp Unlock? | Override **2026-09-03**: kartica tap = Home locked poster, **ne** spend. Gumb (kad može) = Home + ~0.4 s + `unlock_free`. Sivi dok `!can_unlock_free`, gold kad može. |
| **C33** | Boje / empty? | Tint/contrast sezone koja se otključava. Nema next lock → kartica hidden. Samo **free** next-lock, ne paid. |
| **C34** | Smoke A–C? | A: cliff/counts hidden; naslovi; scroll ~280; UpgradeCards hidden. B: rarity bg; auto-select. C: kartica = gate ★3 brojke; kartica ne troši; gumb troši nakon delay. |

## Override mapa

| Staro | CAMP-03 |
|-------|---------|
| C7 ostali GardenCliff stringovi | C22 slot prazan/hidden |
| C21 rupa između naslova i **broja** | C23 i broj nestaje; samo naslov + grid |
| C13 caption na kamp karticama | FIELD-D sklonio kartice |
| C18 Home ruke dalje | C32 kartica = navigacija; gumb = delay unlock |

## Ostaje

C1 toast. C3 CrystalCliff hidden. C4–C6 naslovi UniqueName. C8–C14 spend API. C14 nema SAVE_VERSION. C15 companion API. C17 arena leftover.

## Nije otvoreno

- Unlock spend u kampu. Paid pack kartica. Vraćanje Sprinkler captiona u kamp. SAVE_VERSION.

## Povezano

- [[ideje-camp-pitanja|C1–C20]] · [[ideje-camp-cliff-pitanja|C21]] · [[ideje-home-meadow-field-pitanja|P215–P232]]
- [[../06-production/plan-prompts-home-camp-field|prompti]]
