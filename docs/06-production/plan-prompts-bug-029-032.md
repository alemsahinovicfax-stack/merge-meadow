---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, plan, prompt]
povezano:
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi Bug-029–032 — T1 unify, rarity theme, exchange balance, Garden/Flower UX."
---

# Plan promptovi — Bug-029 do Bug-032

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** **029 → 030 → 031 → 032**

Defaulti: Album T1 = source of truth za sprout look; rarity bg ★1 plava / ★2 ljubičasta / ★3 zlatna; seed trade ★1=1 / ★2=2 / ★3=4 C po sjemeniu; Flower (ex-crystal) ★1=5 / ★2=10 / ★3=20; UI rename Flower, API `garden_crystal_stash` ostaje; Fair F2P.

---

## Prompt — Bug-029 (T1 visual unify) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, T1 seed/sprout visuals.

Bug-029:
T1 u Bloom Albumu ne izgleda isto kao T1 u runu, Camp bagu i Areni. Uskladi run/camp/arena da prate Album T1 look (fit-scaled CampPlantDraw sprout / journal bloom icon style).

Relevantno: collection_bloom_icon.gd, camp_plant_draw.gd (_draw_sprout), seed_bag_icon.gd, seed_visual_config / pickup_assets, arena_seed_chip.gd, run seed_pickup visual.

Default: Album T1 = source of truth; ne mijenjaj T2/T3 merge ekonomiju.

U planu:
- Inventura trenutnih T1 draw pathova; jedan shared helper ili isti scale/offset
- Acceptance: vizualno usklađen T1 na 4 mjesta; smoke/regresija pickupa
- Ne dirati rarity bg (030) ni exchange rates (031)
```

---

## Prompt — Bug-030 (Rarity theme backgrounds)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Journal + Camp Garden chips.

Bug-030:
Rarity theme po ★: ★1 plava pozadina, ★2 ljubičasta, ★3 zlatna — u Bloom Album redovima i u Camp Garden seed trade chipovima.

Relevantno: collection_journal_row.gd, seed_bag_chip.gd, SEED_RARITY / get_seed_rarity, ui_palette.

Default: pastel pill StyleBoxFlat po rarity; locked Album redovi ostaju sivi/muted.

U planu:
- Shared rarity_bg_style(rarity) helper; apply u journal row + seed chip
- Acceptance: clover★1 plavo, tulip★2 ljubičasto, pumpkin★3 zlatno
- Ne dirati coin math (031)
```

---

## Prompt — Bug-031 (Exchange balance + cost labels)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp seed + flower exchange.

Bug-031:
1) Balans: skuplja rarity → više coins. Seed: po-sjeme rate ★1=1, ★2=2, ★3=4; trade take n (1–3) → n×rate. Flower (crystal): ★1=5, ★2=10, ★3=20 po komadu.
2) UI: pored svakog seed/flower chipa prikaži cijenu npr. "seed = 1 C" / "3× = 3 C" (ili ekvivalent čitljiv na chipu).

Relevantno: seed_exchange_* / exchange_seeds_from_bag, CRYSTAL_EXCHANGE_COINS, camp_controller, seed_bag_chip, crystal_stash_chip, ekonomija-brojevi.md.

Default: zamijeni flat EXCHANGE_COINS_REWARD=8 i CRYSTAL_EXCHANGE_COINS=10 rarity tablicom; leftover math = n×rate (Bug-025 kompatibilno). Fair F2P.

U planu:
- GameState rate tables + button copy; chip cost caption
- Update camp_trade_select_smoke / crystal smoke expectations
- Sync ekonomija-brojevi checklist “exchange po rarity”
- Ne dirati Home basket / IAP
```

---

## Prompt — Bug-032 (Garden ↔ Flower stash UX + icons)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp Garden vs Crystal/Flower stash.

Bug-032:
1) Uskladi dizajn strukturu Garden seed trade i Crystal stash (scroll, grid, kartica) — ako jedan ima scroll, drugi isto.
2) Seed razmjena: T1 sprout ikona (sjeme). Flower razmjena: T3 plant draw (ne isti vizual kao seed).
3) UI rename Crystal → Flower (naslovi, captioni, gumbi). API garden_crystal_stash / UniqueName Crystal* ostaju u ovom ticketu.

Relevantno: camp_scene.tscn GardenCard/CrystalCard, camp_controller, seed_bag_chip/icon, crystal_stash_chip/icon, camp_plant_draw.

Ovisi o 029 (T1 look) i korisno nakon 030/031.

U planu:
- Layout parity; icon tier 1 vs 3; copy Flower
- Acceptance: chipovi vizualno različiti; scroll/grid usklađeni; smoke UniqueName OK
- Ne full API rename
```

---

## Povezano

- [[d0-functional-audit|d0-functional-audit]] — Bug-029+ tablica
- [[plan-prompts-bug-024-027|plan-prompts-bug-024-027]] — prethodni paket (✅)
- [[plan-prompts-bug-020-023|plan-prompts-bug-020-023]] — (✅)
- [[CHECKPOINT|CHECKPOINT]]
