---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, pitanja, ux, donate, scratch]
povezano:
  - ideje-camp
  - ideje-camp-chrome
  - ideje-camp-donate
  - ideje-camp-grupe
  - plan-prompts-camp
ai_sažetak: "CAMP-01 pitanja C1–C20 — toast/cliff/companion/rename; Flowers plaćaju oba upgradea; atomic 2 T3; nema arena donate."
---

# IDEJE — CAMP-01 pitanja (C1–C20)

> [[ideje-camp|hub]]. Freeze **2026-08-30**.  
> ARENA-01 A11c (nema bloom spend u areni) i FLOW-A (T2 → 2× T1) **ostaju**. Ovaj track ih ne overridea.

| # | Pitanje | Odluka |
|---|---------|--------|
| **C1** | StatusToast na vrhu kampa? | **Obrisati.** Žuti box (`StatusToast` / `StatusLabel`) nestaje ili permanently hidden. `_set_status_toast` no-op. Nema „Sprinkler upgraded!“ ni Mochi unlock toasta u kampu. |
| **C2** | „New blooms in Journal…“? | **Obrisati** tu granu u `_garden_cliff_text`. Journal tab i badge van ovog slicea. |
| **C3** | CrystalCliff pod Flowers? | **Cijeli skloniti** (node hidden/uklonjen). I „Merge T3 in Arena → flowers here“ i „Tap a flower type, then Exchange for coins.“ |
| **C4** | Companion picker dolje? | **Obrisati** `RunPrepCard` (naslov, hint, Pip/Mochi slotovi). |
| **C5** | Garden naslov? | Tekst **Seeds**. Node `GardenCard` / `GardenTitle` / `%GardenCliff` **ostaju** (smoke). |
| **C6** | Flower stash naslov? | Tekst **Flowers**. Node `CrystalCard` / `CrystalTitle` ostaju. |
| **C7** | Ostali GardenCliff hintovi? | **Ostaju** u CAMP-01 A (tutorial merge, bag T1, flowers ready, run→collect). Samo C2 i C20 grane idu. **CAMP-02 C21 override:** slot uvijek hidden + prazan. |
| **C8** | Što se donira / plaća upgrade? | **T3 iz Flowers za oba** (Sprinkler i Loot Boost). Nema T2 donate. Nema arena donate. |
| **C9** | Koliko? | **2 T3 po levelu** (isti broj kao stari `MAGNET_COST_T2` / `MULTIPLIER_COST_T3`; resurs = flower stash). |
| **C10** | Incremental „donated 1/2“? | **Ne.** Atomic spend na Upgrade tap. Gumb enabled kad postoji tip s `count >= 2` i level < max. |
| **C11** | Koji cvijet? | Selektirani tip ako `count >= 2`; inače **najniža rarity** s `count >= 2` (pa veći count). Nema 1+1 s dva tipa. |
| **C12** | Exchange za coins? | **Ostaje.** Rate se ne dira. |
| **C13** | Caption na karticama? | **Efekat + broj + cost.** Nema „donate in Arena“. Primjer: magnet px now→next; loot × now / next; „Spend 2 flowers“. Maxed ostaje. |
| **C14** | SAVE_VERSION? | **Ne.** Stari `sprinkler_donations` / `multiplier_donations` ignorirati ili reset 0; `magnet_level` / `multiplier_level` ostaju. |
| **C15** | Companion u saveu / runu? | **Ostaje.** `active_companion_id`, Pip u runu, Mochi unlock flag. Default Pip. Nema camp pickera (C4). |
| **C16** | Milestone? | **v1.1+**, nije launch blocker, nije D0-P. |
| **C17** | Arena leftover / sort? | **Ne dirati.** FLOW-A, SORT, overlay, grant D. |
| **C18** | Home / Shop / AdMob? | **Ne dirati.** Band, IAP, ads, sezone. |
| **C19** | Mochi unlock toast? | Nema camp toasta (C1). Unlock u saveu ostaje; igrač ga ne vidi kao banner u kampu. |
| **C20** | „1 more T2 to upgrade Sprinkler“? | **Obrisati** tu GardenCliff granu u A (laž i prije B). |

## Zašto ove odluke

### C1 — toast je eho, ne informacija

`_refresh_ui(status)` pali žuti panel na vrhu `Content`. Igrač je upravo tapnuo Upgrade / Trade. Ponavljanje „Sprinkler upgraded!“ gura Seeds karticu dolje. Playtest: skloni.

### C2 / C20 / C7 — cliff nije cijeli mrtav

Seeds i dalje smije reći „pour in Arena“ ili „Play to collect“. Journal swipe i T2 donate su **pogrešan** next-step. C7 drži ostalo da A ne ostavi prazan `GardenCliff` (smoke traži node).

### C3 — ista poruka pod Flowers

„Merge T3 in…“ je tutorial ispod naslova. „Tap a flower type…“ je isti caption node. Playtest: skloni **cijeli** `CrystalCliff`. Exchange gumb i dalje uči select (label „Select a flower to exchange“).

### C4 / C15 / C19 — picker ≠ ljubimac

D0 G7 (Pip + Mochi) ostaje u saveu i runu. Kamp nije character select. `RunPrepCard` nema drugog sadržaja — ide cijela kartica.

### C5 / C6 — rename je copy, ne refactor

`camp_layout_smoke` traži `%GardenCliff`. UniqueName ostaju. Samo `text` na `GardenTitle` / `CrystalTitle`.

### C8–C11 — jedan sink, T3 već postoji

T2 inventar ne postoji. T3 inventar postoji (`garden_crystal_stash`). Isti trošak 2, isti gumb. Atomic da nema „donate pa Upgrade“ dva koraka. 1+1 s dva tipa je zamka (igrač misli da čuva rare); v1 ovog slicea traži 2 ista tipa.

### C13 — caption mora reći magnet / ×loot

Playtest je pitao „šta rade“. Broj levela 0/4 nije dovoljan. Px i × su isti izvori kao `get_magnet_radius` / `MULTIPLIER_VALUES`.

### C14 / C16–C18 — uzak slice

Nema save bump. Arena i Home su zatvoreni trackovi.

## Otvoreno (ne blokira A; B smije koristiti preporuku)

Agent **ne** mora pitati da krene. Ako treba izbor, koristi preporuku.

1. **Toast node.** Preporuka: ostavi u tscn, `visible = false`, `_set_status_toast` early return. Manji diff od brisanja UniqueName.
2. **CrystalCliff node.** Preporuka: `visible = false` ili ukloni iz stabla; smoke: null **ili** hidden.
3. **Ime spend helpera.** `spend_flowers_for_upgrade(count)` ili u `try_upgrade_magnet` / `try_upgrade_multiplier`.
4. **Caption copy EN.** Preporuka: `Wider seed magnet next run · %d→%d px` / `More loot next run · now ×%.2g, next ×%.2g` + `Spend 2 flowers`.
5. **Tie-break rarity.** Ista rarity, veći count; pa `CHAIN` red ako i to isto.

## Nije otvoreno (namjerno)

- Vratiti donate u arenu.
- T2 stash kartica.
- Coins kao jedini Sprinkler sink (odbijeno — flowers_both).
- Nevidljivi auto-count T3 prema upgradeu (odbijeno).
- 1+1 s dva tipa.
- SAVE_VERSION, brisanje `user://player_save.json`.
- Companion picker u Settings u ovom tracku.
- `CAMP_BED_BONUS` / gredice UI.
- Produkcijski starting flowers.

## Override mapa (brzi lookup)

| Staro | Novo |
|-------|------|
| Caption „donate in Arena“ | C13 efekat + Spend 2 flowers |
| `sprinkler_donations` prag | C8–C10 atomic 2 T3 |
| T2 za Sprinkler | C8 T3 Flowers |
| StatusToast | C1 gone |
| Garden / Flower stash | C5 Seeds / C6 Flowers |
| RunPrep companion | C4 gone; C15 API ostaje |

## Povezano

- [[ideje-camp|hub]] · [[ideje-camp-chrome|chrome]] · [[ideje-camp-donate|donate]] · [[ideje-camp-cliff|CAMP-02 C21]]
- [[../06-production/plan-prompts-camp|prompti]] · [[../06-production/plan-prompts-camp-cliff|CAMP-02 prompti]]
