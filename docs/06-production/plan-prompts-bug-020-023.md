---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, plan, prompt]
povezano:
  - d0-functional-audit
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi Bug-020–023 — Home, basket, journal, dijamanti."
---

# Plan promptovi — Bug-020 do Bug-023

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** **022 → 023 → 021 → 020**

Defaulti: dijamant = soft valuta (nema IAP/shop spend u 020); bag basket UX nestaje iz Campa; Home zadržava središnji Panel; DailyChest seli s Campa na Home; Fair F2P (dijamant nije paywall).

---

## Prompt — Bug-022 (Home refactor) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, meta hub Home (main_menu).

Bug-022:
1) Ukloniti Camp i Shop dugmad s Home — hub bottom tabovi već vode tamo.
2) Veliki Home layout polish: zadrži središnji Panel/prozor; oko njega dodaj kontekst (ne dashboard clutter).
3) Settings: makni iz hub TopBar headera → Home, gornji desni kut.
4) DailyChest: premjesti s Campa na Home (claim flow ostaje GameState).

Relevantno: main_menu.tscn / main_menu.gd (CampButton, ShopButton, SettingsButton, Panel, PlayButton), meta_hub.tscn TopBar SettingsButton, meta_hub_controller, camp_controller DailyChestCard + claim, MetaHubPages.

U planu:
- Što brišeš vs sakrivaš; wire Settings + DailyChest na Home
- Camp više ne prikazuje daily chest (hub-embedded i standalone)
- Acceptance: Home bez Camp/Shop CTA; Settings s Home; chest claim radi; bottom nav OK
- Ne dirati Shop/Arena gameplay
```

---

## Prompt — Bug-023 (Basket na Home; ukloni iz Campa)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Home run prep + Camp cleanup.

Bug-023:
1) Na Home: Basket kontrola — tap otvara ponudu SVIH otključanih tipova sjemena; tap tipa → odmah set_loadout_from_bag (ili clear ako treba).
2) Iz Campa OBRISATI sav basket UX: LoadoutButton, chip set_in_basket / tap→loadout; trade select (≥3) ostaje.
3) Ovisi o Bug-022 (Home shell).

Relevantno: GameState loadout_* / set_loadout_from_bag / clear_loadout / is_seed_type_unlocked, camp_controller + seed_bag_chip (Bug-018), main_menu.gd, run LoadoutLabel.

Default: picker = modal/sheet liste unlocked tipova (ne cycle); mythic i dalje ne ulazi u basket; prazan basket dozvoljen (clear).

U planu:
- UI picker + refresh label; uklanjanje camp basket koda/scena
- Acceptance: Home odabir → run bias; Camp bag samo trade/crystal; smoke
- Ne dirati Arena bloom Basket (donate panel) osim ako dijeli API imena
```

---

## Prompt — Bug-021 (Journal — T1/T2/T3 visuals)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, Collection Journal.

Bug-021:
Za svaki tip cvijeta prikaži TRI vizuala (T1, T2, T3). Neotključani tier = sivi/locked; otključani = prava boja/ikona.

Relevantno: collection_journal.gd / collection_journal_row.gd / collection_bloom_icon.gd, GameState.get_collection_journal_entries / collection_kept_tiers / discovered_blooms.

U planu:
- Row layout: 3 ikone umjesto jedne + text chipova (ili ikone + chipovi)
- Pravilo unlock: T1 discovered/spawn; T2/T3 prema kept_tiers / journal entry flags
- Acceptance: locked sivo, unlocked u boji; scroll/readable na 1080×1920
- Ne dirati merge ekonomiju
```

---

## Prompt — Bug-020 (Dijamant valuta + rare run drop)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, wallet + run loot.

Bug-020:
1) Nova valuta: Dijamant — chip u hub headeru (pored coins/seeds) i u run HUD top stripu.
2) U runu: dijamant pickup, BAŠ rijedak (~1 na 300 seed pickupa / ekvivalentna rate).

Relevantno: GameState wallet/save, meta_hub TopBar CoinChip/SeedChip, run PickupBar / run_controller spawn+pickup, pickup_assets / UI palette.

Default: wallet_diamonds u save; spawn rate ~1/300 seeds; UI-only + collect u ovom ticketu — NE shop spend / IAP sink (kasnije). Fair F2P: nije paywall.

U planu:
- Save + header/run UI + spawn/pickup wiring + visual placeholder
- Acceptance: brojač raste na rare pickup; hub i run sync; smoke/rate sanity
- Ne dirati coin/seed balance osim diamond rate
```

---

## Povezano

- [[d0-functional-audit|d0-functional-audit]] — Bug-020+ tablica
- [[plan-prompts-bug-015-019|plan-prompts-bug-015-019]] — prethodni paket (✅)
- [[plan-prompts-bug-010-014|plan-prompts-bug-010-014]] — (✅)
- [[CHECKPOINT|CHECKPOINT]]
