---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, plan, prompt]
povezano:
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi Bug-010–014 — jedan chat + Plan mode po stavci."
---

# Plan promptovi — Bug-010 do Bug-014

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** 014 → 010 → 011 → 012 → 013

Defaulti: Almanac van Shopa (unlock ostaje u GameState); crystal = zaseban panel; seed trade = tap select.

---

## Prompt — Bug-014 (Header brojevi) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, meta hub header.

Bug-014:
Header pokazuje ikone coins/seeds ali NE VIDI SE koliko čega ima (broj nečitljiv / nestaje / kontrast / layout).

Relevantno: meta_hub.tscn TopBar CoinChip/SeedChip, meta_hub_controller.refresh_top_bar (već piše str(wallet) / sum_seed_bag_only), ui_text_layout.stat_label (svijetli ink), UI_PALETTE, chip StyleBox.

U planu:
- Reproduciraj zašto broj nije vidljiv (boja na svijetlom chipu, font_size, min width, clip, modulate)
- Fix: jamči čitljiv broj pored ikone (tamni ink na warm chip, dovoljan prostor, refresh nakon wallet promjene)
- Acceptance: boot hub vidi npr. „12“ coins i „5“ seeds; nakon run/loot/shop broj se ažurira
- Ne dirati Arena/Camp logiku
```

---

## Prompt — Bug-010 (Merge Arena + hub swipe)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow (Godot 4.7), M8 D0. Meta hub + Merge Arena.

Bug-010 (Merge Arena — kritično):
1) Kad tapnem vrećicu i sjeme se sipa, pa krene pest (neprijatelj) i jede sjeme, i dalje mogu swipe L/R / tabove na hubu i napustiti Arena stranicu — to potpuno poremeti merge arenu.
2) Kad se vratim na Arena, stanje je polu-aktivno: sjeme razbacano, pest ne jede / ne radi, nema jasnog načina da „ponovo igram“ merge (vrećica/restart).

Relevantno:
- merge_arena_controller.gd (već postoji set_swipe_enabled / lock prema hubu — provjeri kad je locked=true/false)
- meta_hub_controller.gd set_swipe_enabled, tabovi, go_to_page
- swipe_pager.gd
- GameState arena chip / pour / pest tutorial

U planu obavezno:
- Root cause: zašto swipe/tabovi nisu blokirani cijelo vrijeme aktivne arene (pour + pest + idle s chipovima)
- Što se dogodi s pest/_process kad se page unload/hide (pause? free? orphan)
- Fix: lock hub swipe+tabovi dok je arena „session aktivna“; unlock kad session završi ili igrač eksplicitno napusti s potvrdom
- Resume vs soft-reset pri povratku na Arena tab (preporuka: pause session dok je off-page ILI full reset + Clear/Pour opet — odaberi jedan konkretan pristup i obrazloži)
- Acceptance + smoke (merge_arena_smoke + hub flow dok je arena locked)
- Rizici: ne zaključati hub zauvijek ako arena crasha
```

---

## Prompt — Bug-011 (Seed trade — izbor tipa)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp Garden.

Bug-011:
Trade 3 same → coins trenutno uzima first_exchangeable_type_in_bag() — igrač nema kontrolu koji tip mijenja.

Cilj: igrač SELEKTUJE tip sjemena za razmjenu (samo tipovi s count >= EXCHANGE_SEED_COUNT / 3), zatim potvrdi Trade.

Relevantno: camp_controller.gd (_on_exchange_pressed, _refresh_garden_card), GameState.exchange_seeds_from_bag / first_exchangeable_*, SeedBagGrid / seed_bag_chip.gd (može reuse select highlight).

U planu:
- UX: tap chip u Garden bag gridu = select; vizualni selected state; Trade disabled dok nema valida selecta
- Ne mijenjati ekonomiju (3→EXCHANGE_COINS_REWARD)
- Acceptance + smoke (selektuj tip, trade skine 3, coins+)
```

---

## Prompt — Bug-012 (Zaseban T3 crystal exchange)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp.

Bug-012:
Razmjena T3 kristala (garden_crystal_stash) ne smije biti u istom „prozoru“/bloku kao seed trade.
Napraviti SLIČAN novi prozor/panel samo za kristale: popis tipova + broj + select + Exchange → coins.
Ako treba — scroll (kao shop) da sve stane na portrait 1080×1920.

Relevantno: camp_scene GardenCard (CrystalRow, CrystalExchangeButton), GameState.garden_crystal_stash / exchange_garden_crystal / format_garden_crystal_*, SeedVisualConfig / chip pattern.

U planu:
- Layout: nova zona „Crystal stash“ (kartica ili overlay) odvojena od seed bag + seed trade
- Select tipa kristala (ne first_garden_crystal_type automatski)
- ScrollContainer ako lista raste
- Ukloniti zbunjujući spoj seed trade + crystal u jednoj liniji
- Spec sync jedna rečenica; acceptance
```

---

## Prompt — Bug-013 (Izbaci Seed Almanac iz Shopa)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Shop.

Bug-013:
Seed Almanac sekcija u shopu je suvišna — IZBACI je iz Shop UI.

Relevantno: shop_screen.tscn/gd (AlmanacHeader, AlmanacList), shop_almanac_row.gd, GameState.get_almanac_chain_ui_data / coin unlock CTA, meta_hub_flow_smoke assert na AlmanacList==7, spec/ekonomija almanac.

U planu (konkretno, bez opcija):
- Ukloniti Almanac UI iz shop scene + build/refresh kod
- Zadržati GameState unlock/progresiju (run discovery) — samo nema shop sekcije za almanac/coin unlock redove
- Ažurirati smokes i docs koji spominju Shop Almanac
- Acceptance: shop otvara bez Almanac; cosmetics/boosters/IAP ostaju
```

---

## Povezano

- [[d0-functional-audit|d0-functional-audit]] — Bug-010+ tablica
- [[CHECKPOINT|CHECKPOINT]]
