---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, flowers, scratch]
povezano:
  - ideje-camp-link
  - ideje-camp-link-pitanja
  - plan-prompts-home-camp-field
ai_sažetak: "CAMP-03 B — Flowers chip rarity_bg kao Seeds; auto-select za Exchange kao Trade. CAMP3-B ✅."
---

# IDEJE — CAMP-03 flowers (kao Seeds)

> [[ideje-camp-link|hub]] · freeze C28–C30, C34.  
> **Kod:** **CAMP3-B ✅**. Smije paralelno s A. Ne next-lock (C). Ne mijenjati Exchange rate.

## Danas

[`seed_bag_chip.gd`](../../game/scripts/camp/seed_bag_chip.gd) `_apply_visual_state`: `UI_PALETTE.rarity_bg_color(_rarity)`. Auto-select: `_force_default_trade_select`, `_validate_trade_selection`, `_next_trade_type_after` — nakon deplete sljedeći ASC. Smoke: [`camp_trade_select_smoke.gd`](../../game/scripts/dev/camp_trade_select_smoke.gd).

[`crystal_stash_chip.gd`](../../game/scripts/camp/crystal_stash_chip.gd): bg `WARM_WHITE` (nema rarity). `_validate_crystal_selection` **briše** select kad count padne na 0. [`camp_crystal_select_smoke.gd`](../../game/scripts/dev/camp_crystal_select_smoke.gd) to **očekuje**.

Zvijezdice su već u imenu (`★`.repeat); rarity boja na Seeds je **pozadina chipa**, ne zaseban star shader — Flowers kopira to.

## B — parity

1. Crystal chip: `rarity_bg_color` + selected lighten kao SeedBagChip. Zvijezdice ostaju u imenu.
2. Default select prvi ASC entry kad `_force_default_trade_select` (isti flag ili crystal twin na page show).
3. Persist dok count ≥ 1. Nakon deplete: `_next_crystal_type_after` (kopija seed helpera na `garden_crystal_stash`).
4. Exchange gumb enabled dok ima select. Copy gumba može ostati „Exchange … → n coins“.
5. Ažurirati `camp_crystal_select_smoke`: nakon clover 0, ako daisy ostaje → select daisy, Exchange enabled (ne clear).

## Smoke (C34)

Dva tipa u stashu; page refresh → prvi ASC selected. Exchange deplete prvog → drugi selected. Chip bg ★1 ≠ ★3 (rarity_bg). Stari assert „select cleared when clover gone“ **ukloniti** ako ostaje drugi tip.

## Acceptance

- Flowers izgleda i trejda kao Seeds: rarity boje, spam Exchange skače na sljedeći tip.
