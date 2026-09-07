---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, sezone, meadow, basket, daily, swipe, upgrade, scratch]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-dock-pitanja
  - plan-prompts-home-camp-field
  - CHECKPOINT
ai_sažetak: "HOME-16 pitanja P215–P232 — Daily overlay body; basket no-scroll; hub swipe u polju; Magnet/Loot na polju. Override P203 scroll, P205 chrome, P207 CAMP ruke."
---

# IDEJE — HOME-16 pitanja (P215–P232)

> [[ideje-home-meadow-field|hub]]. Freeze **2026-09-02**.  
> P1–P214 ostaju osim override tablice. DOCK picker T3/★3/footer ostaju. LIFE Play/Pip/count ostaju.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P215** | Claimed Daily overlay body? | Title ostaje **Come back tomorrow**. Body: **Daily chest already opened today.** Nema ` — come back tomorrow!`. |
| **P216** | `claim_daily_chest` already-claimed string? | Isti trim kao P215. Ne dirati success gift stringove. |
| **P217** | Daily kartica caption? | **Ne dirati** P206: Tap to open / Back tomorrow. Arena HUD ostaje. |
| **P218** | Basket picker scroll? | **Nema scrolla.** Jedan stupac. `%PickerPanel` visinu raste da stanu title + redovi + Clear/Close. Ne 2-col. |
| **P219** | Clip / overflow? | Svi redovi (max 7 Bloom) + footer **u potpunosti** unutar panela. Ne clipati T3 ikone. |
| **P220** | DOCK-A picker sadržaj? | T3 ikona iznad imena; ★3 smije; Clear+Close stacked footer; `%PickerList` samo cvijeće. Override samo P203 „ispod scrolla“ → ispod liste. |
| **P221** | Hub swipe na karuselu? | Stage **ostaje** u `block_hub_swipe` (L/R sezona). Postojeći home smoke ostaje. |
| **P222** | Hub swipe u polju (livada)? | Kad `home_season_field_open`: Stage **nije** u `block_hub_swipe`. Mid-field swipe mijenja hub page. |
| **P223** | Hub swipe preko chromea u polju? | Daily, Basket, Settings, chip, PlayRow, Magnet/Loot **jesu** u grupi. Tap ne mijenja page. |
| **P224** | Smjer i session? | Lijevo = Journal (`COLLECTION`), desno = Camp. Polje **ostaje otvoreno** (session flag) kad odeš s Homea. Close i dalje Seasons / Back / Escape. |
| **P225** | Gdje su Magnet / Loot Boost? | Polje, gore desno **ispod Settings**, VBox Magnet pa Loot Boost. Vidljivo samo field open. |
| **P226** | Kamp upgrade kartice? | `%UpgradeCards` `visible = false`. UniqueName ostaje. Ne brisati API / save levele. |
| **P227** | Spend? | `try_upgrade_magnet("")` / `try_upgrade_multiplier("")`. 2 T3, atomic, cheapest ≥2. Nema IAP. Nema `SAVE_VERSION`. C8–C14 ostaju. |
| **P228** | Copy na polju? | Naslov **Magnet** (ne Sprinkler) i **Loot Boost**. Gumb Upgrade / Maxed. **Nema** caption / px / ×. |
| **P229** | Safe rect? | `_chrome_controls` / `meadow_safe_rect` + Magnet/Loot (+ pad). Pip FSM ne dirati. Override P205 samo dodatak. |
| **P230** | Milestone / ne dirati? | **v1.1+**. Ne Shop, AdMob, Unlock JSON, leftover/vacuum, Pip, Play routing, Endless Hard, SeedCatalog JSON, 8 tscn, CAMP3 chrome/next-lock (osim hide UpgradeCards). |
| **P231** | Smoke A + B? | A: claimed overlay body bez „come back tomorrow“. B: picker bez clip/scroll; svi redovi u panelu; footer stacked. |
| **P232** | Smoke C + D? | C: field mid ne blokira hub swipe; chrome blokira; karusel Stage i dalje blokira; field ostaje open nakon page hop. D: field Magnet/Loot stacked ispod Settings; kamp UpgradeCards hidden; close hide. |

## Override mapa (HOME-15 / CAMP-01)

| Staro | HOME-16 |
|-------|---------|
| P203 Clear/Close ispod **scrolla** | P218/P220 ispod **liste**, nema scrolla |
| P205 safe: Daily, Basket, Settings, chip, PlayRow | P229 + Magnet/Loot |
| P206/P214 caption / arena | P215–P217 overlay body; caption ostaje |
| P207 CAMP ruke dalje | P226 hide UpgradeCards; spend ostaje; CAMP-03 radi Seeds/next-lock |
| C13 caption px/× u kampu | P228 nema captiona na polju; kamp kartice hidden |
| Stage uvijek `block_hub_swipe` | P221 karusel da; P222 polje ne |

## Ostaje iz HOME-12–15

P137–P143 open field. P146 session. P153 jedan Field. P161–P163 tint. P164 Basket nije na karuselu. P169–P172 Endless u polju. P174 Back/Escape. P179–P183 Play 3-koraka. P187–P189 Pip. P185 count 12–14. P197–P202, P204, P206, P208–P214.

## Nije otvoreno

- 2-col picker. Chevron. Easy Endless. Merge na polju. IAP na upgrade. Unlock iz kampa (to je CAMP-03 link, ne spend). Brisanje `magnet_level`.

## Povezano

- [[ideje-home-meadow-dock-pitanja|P197–P214]] · [[ideje-camp-link-pitanja|C22–C34]]
- [[../06-production/plan-prompts-home-camp-field|prompti]]
