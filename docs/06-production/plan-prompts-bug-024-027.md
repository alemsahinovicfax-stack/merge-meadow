---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, plan, prompt]
povezano:
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi Bug-024–027 — basket kartica, garden trade, journal tiers, swipe snap."
---

# Plan promptovi — Bug-024 do Bug-027

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** **027 → 024 → 025 → 026**

Defaulti: Basket kartica ispod DailyChest (prazna korpa vizual); Garden default select gornji-lijevi + rarity ASC + leftover 1–2 trade `floor(n * 8 / 3)`; Journal slot 1=T1 / 2=T2 / 3=T3 (fix clip); Swipe uvijek snap na punu stranicu; Fair F2P.

---

## Prompt — Bug-027 (Swipe stuck mid-page) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, meta hub SwipePager.

Bug-027:
Ručni swipe (ne tab click) ponekad ostavi PagesHost između dvije stranice (polovičan offset). Popravi da svaki završeni ili prekinuti gesture završi na punoj stranici.

Relevantno: swipe_pager.gd (_start_pointer/_finish_pointer/_kill_snap_tween/_snap_to_page/_apply_offset), meta_hub_controller, Arena set_nav_locked.

U planu:
- Root cause: interrupted snap tween + finish bez re-snap
- Fix: kill tween → re-snap to current_page (ili target); nikad ostaviti host X između page width-ova
- Acceptance: brzi/spori/djelomični swipe; tab click i dalje OK; Arena lock OK
- Smoke: force mid-offset pa assert snap (ako izvedivo headless)
- Ne dirati page sadržaj / tab redoslijed
```

---

## Prompt — Bug-024 (Home Basket kartica ispod DailyChest)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Home (main_menu).

Bug-024:
1) Izvaditi BasketButton iz središnjeg Panel/VBox (pored Play).
2) Staviti Basket odmah ISPOD DailyChestCard — zaseban frejm/kartica sličan DailyChestu (veličina/stil kartice).
3) Vizual: prazna korpa kad loadout prazan; kad igrač odabere tip — prikaži seed/basket filled (procedural OK). Picker logika (unlocked tipovi + Clear) ostaje.

Relevantno: main_menu.tscn / main_menu.gd (DailyChestCard, BasketButton, BasketPickerOverlay), GameState loadout_*, home_basket_picker_smoke.

U planu:
- Layout: chest → basket kartica (top-left stack); Panel/Play bez basket reda
- Empty vs selected visual + refresh nakon pickera
- Acceptance: tap basket → picker; select/clear radi; smoke; ne dirati Camp/Shop
```

---

## Prompt — Bug-025 (Garden trade — default select, order, leftover)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp Garden seed trade.

Bug-025:
1) Default: pri ulasku na Camp / show page automatski selektuj sjeme u gornjem-lijevom slotu grida (igrač i dalje može tapati drugi tip).
2) Nakon promjene scene ili hub page away→back: reset na taj default.
3) Redoslijed grida: od “T1” (niža rarity ★) gornji-lijevo do “T3” (★★★) donji-desno — rarity ASC (ne DESC).
4) Ako selektovani tip ima 1 ili 2 sjemena (ostatak), dozvoli Trade s proporcionalnim coins: floor(n * EXCHANGE_COINS_REWARD / EXCHANGE_SEED_COUNT); 3+ i dalje puni batch.

Relevantno: camp_controller (_selected_trade_type, _rebuild_seed_bag_grid, _on_exchange_pressed), get_seed_bag_entries / exchange_seeds_from_bag, seed_bag_chip, EXCHANGE_* konstante.

U planu:
- Sort + auto-select + reset na refresh_for_meta_hub / _ready
- API: exchange N (1..3+) ili poseban leftover path; UI copy “Trade N → coins”
- Acceptance: default select vidljiv; leftover ne zaglavi 1–2; Fair F2P (nema paywall)
- Ne dirati Home basket ni Arena bloom Basket
```

---

## Prompt — Bug-026 (Journal — ispravan T1/T2/T3)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Collection Journal.

Bug-026:
Journal trenutno zbunjuje: T3 se ne vidi jasno; slotovi izgledaju kao da pokazuju T2/T3 na mjestima T1/T2; T1 (sprout/sjeme) izgleda kao da nedostaje. Ispravi vizuale tako da slot 1=T1, 2=T2, 3=T3 jasno čitljivi.

Relevantno: collection_journal_row.gd, collection_bloom_icon.gd, camp_plant_draw.gd (sprout/bloom/crystal), get_collection_journal_entries, collection_journal_smoke.

Sumnja: T1 sprout clip u 52px ikoni (offset/scale), ne krivi unlock flags — potvrdi u planu.

U planu:
- Fit T1 u ikonu (scale/offset); caption T1/T2/T3 ispod svakog slota
- Unlock pravila ostaju (T1 unlocked kad discovered; T2/T3 po kept_tier) osim ako audit pokaže bug
- Acceptance: za kept_tier=2 vidi se T1+T2 boja, T3 locked; kept_tier=3 sva tri; smoke
- Ne dirati merge ekonomiju
```

---

## Povezano

- [[d0-functional-audit|d0-functional-audit]] — Bug-024+ tablica
- [[plan-prompts-bug-020-023|plan-prompts-bug-020-023]] — prethodni paket (✅)
- [[plan-prompts-bug-015-019|plan-prompts-bug-015-019]] — (✅)
- [[CHECKPOINT|CHECKPOINT]]
