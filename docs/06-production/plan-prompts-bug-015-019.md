---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, plan, prompt]
povezano:
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi Bug-015–019 — jedan chat + Plan mode po stavci."
---

# Plan promptovi — Bug-015 do Bug-019

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** **015 → 017 → 019 → 018 → 016**

Defaulti: T2 uvijek ima akciju (ne zaglavi zauvijek na playfieldu); basket = tap tipa u Garden bagu; hub-embedded Camp bez footer Merge/Play; hub bez bottom CaptionLabel.

---

## Prompt — Bug-015 (Run HUD — top strip) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, lane run HUD.

Bug-015:
1) Prikaz brojeva coins/seeds u runu je poremećen — premjestiti tu sekciju na GORNJI dio ekrana.
2) Uredi cijeli gornji HUD: pickup pop-up/feed (sjeme koje skupljaš), level, preostale sekunde, ime charactera/companiona — layout, kontrast, safe area, bez preklapanja.

Relevantno: run_scene.tscn HUD (PickupBar, PickupFeed, TimerLabel, PipBadge), run_controller.gd, SAFE_AREA, run_palette HUD_*, pickup_assets.

U planu:
- Root cause zašto counters izgledaju poremećeno (pozicija, anchor, font, clip)
- Konkretan top layout (jedan strip: timer/level | companion | coins+seeds; feed ispod ili toast)
- Acceptance: portrait 1080×1920 — sve čitljivo ispod notch/safe area; brojevi se ažuriraju na pickup
- Ne dirati spawn/gameplay balance
```

---

## Prompt — Bug-017 (Shop cosmetics buy)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Shop Cosmetics.

Bug-017:
Dugmad za kozmetiku ne rade — klik ne oduzima coins (možda signal/UI stub, ne samo „nema art“).

Relevantno: shop_cosmetic_row.gd (buy_pressed/equip_pressed, native Button), shop_screen.gd _on_cosmetic_buy / buy_cosmetic_with_coins, GameState.owned_cosmetics / wallet, CosmeticCatalog, UiClickGuard ako gutaju klik.

U planu:
- Root cause: signal connect, disabled, bind item_id, refresh wallet/header, guard
- Fix: kupovina smanjuje wallet, owned+equip, UI refresh (hub header ako embedded)
- Acceptance: smoke ili koraci — coins N → buy → N-cost, gumb Equip/Equipped
- Ne dirati IAP/boosters osim ako dijele isti bug
```

---

## Prompt — Bug-019 (Hub — ukloni page caption)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, meta hub bottom nav.

Bug-019:
U swipe meniju dolje ukloniti naslov/caption trenutne sekcije (CaptionLabel). Tab dugmad + swipe logika OSTAJU; caption oduzima prostor.

Relevantno: meta_hub.tscn PageIndicator (CaptionLabel, tabovi), meta_hub_controller.gd (page_caption.text = PAGE_LABELS / Settings toast).

U planu:
- Sakriti ili obrisati CaptionLabel; sačuvati tab highlight + swipe_pager
- Settings toast ne smije ovisiti o captionu (ili kratki status drugdje)
- Acceptance: manji bottom chrome; swipe Shop↔Arena radi; meta_hub_flow_smoke OK
```

---

## Prompt — Bug-018 (Garden basket select + ukloni footer Merge/Play)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Camp Garden / Run prep.

Bug-018:
1) Igrač ne može BIRATI koje sjeme ide u basket/loadout (sada cycle gumb / nejasan UX).
2) Ukloniti Play i Merge dugmad s donjeg dijela Campa (hub-embedded) — navigacija preko hub tabova Home/Arena.

Relevantno: camp_controller loadout_button / cycle_loadout_from_bag, GameState.set_loadout_from_bag, SeedBagGrid/chips, FooterBar MergeButton/PlayButton, set_meta_hub_mode, MetaHubPages.

U planu (konkretno):
- Tap eligible seed u bag gridu ILI jasan „Basket“ mode: odaberi tip → loadout; vizual badge na chipu
- Hub-embedded: FooterBar / Merge+Play HIDDEN; standalone camp smije zadržati ako treba
- Acceptance: odaberi tip → format_loadout / run bias; u hubu nema donjih Merge/Play
```

---

## Prompt — Bug-016 (T2 leftover — Arena + Camp)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Merge Arena + Camp.

Bug-016:
Što s T2 kad ostane JEDAN (nema para za merge)? Isto jasno u Camp/bag kontekstu.

Relevantno: merge_arena_controller (bloom panel Donate/Keep/Basket na tap T2), merge-arena-v1.1 (T2→inbox preporuka), GameState sprinkler donate / seed_bag, pest jede T1/T2.

Default (obavezan u planu): T2 ne ostaje zauvijek „mrtav“ na playfieldu — igrač uvijek ima akciju (Donate / Keep / Basket) ili auto-put u bloom flow; dokumentiraj Camp: T2 u bagu = za Arena pour ili trade pravila ako postoje.

U planu:
- Trenutno ponašanje odd T2 + edge (donate maxed)
- Konkretan UX + acceptance + smoke ako treba
- Ne krši Fair F2P (ne forsiraj spend)
```

---

## Povezano

- [[d0-functional-audit|d0-functional-audit]] — Bug-015+ tablica
- [[plan-prompts-bug-010-014|plan-prompts-bug-010-014]] — prethodni paket (✅)
- [[CHECKPOINT|CHECKPOINT]]
