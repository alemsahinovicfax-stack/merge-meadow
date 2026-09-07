---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, basket, daily, swipe, upgrade, scratch]
povezano:
  - ideje-home-meadow-field-pitanja
  - ideje-home-meadow-field-grupe
  - ideje-home-meadow-field-daily
  - ideje-home-meadow-field-basket
  - ideje-home-meadow-field-swipe
  - ideje-home-meadow-field-upgrades
  - ideje-home-meadow-dock
  - ideje-camp-link
  - plan-prompts-home-camp-field
  - CHECKPOINT
ai_sažetak: "HOME-16 hub — FIELD-P0 docs; FIELD-A ✅ Daily overlay; FIELD-B ✅ basket; FIELD-C ✅ swipe; FIELD-D ✅ Magnet/Loot."
---

# IDEJE — Home meadow field (HOME-16 hub)

> **ID:** **HOME-16** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **FIELD-A ✅** **FIELD-B ✅** **FIELD-C ✅** **FIELD-D ✅**. Docs **FIELD-P0 ✅**. Prompti: [[../06-production/plan-prompts-home-camp-field|plan-prompts-home-camp-field]] **FIELD-P0 ✅ → A ✅ → B ✅ → C ✅ → D ✅**. Grupe: [[ideje-home-meadow-field-grupe|grupe]].  
> **Prethodnik:** [[ideje-home-meadow-dock|HOME-15]] DOCK-P0 ✅ A–D ✅ — picker T3/★3; Basket ispod Daily; Seasons u PlayRow; Daily bez arena streaka.  
> **Paralelni kamp:** [[ideje-camp-link|CAMP-03]] — Seeds/Flowers chrome; Flowers = Seeds; next-lock kartica. FIELD-D **prije** CAMP3-A.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — Magnet / Loot Boost i dalje troše **2 T3** iz Flowers; nema IAP na upgrade.

## Pitch

U polju sezone Daily gift popup **ne ponavlja** „come back tomorrow“ u bodyju. Basket picker **nema scroll** — svi cvjetovi (jedan stupac) stanu na ekran. Hub swipe **lijevo = Journal, desno = Camp** radi i dok si **unutar** sezone, ne samo na karuselu. Sprinkler / Loot Boost **nestaju iz kampa** (API ostaje) i stoje **kompaktno gore desno na polju**: Magnet pa Loot Boost, svaki s Upgrade.

## Zašto sada

HOME-15 je zatvorio dock. Claimed Daily overlay i dalje kaže isto dvaput. Picker ima 400 px scroll iako sezona ima ≤7 tipova. `SeasonStage` u `block_hub_swipe` gutа cijeli full-bleed field pa se ne može otići u Camp/Journal. Upgrade kartice u kampu zauzimaju prostor koji CAMP-03 treba za Seeds/Flowers + next-lock.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Overlay title *i* body: come back tomorrow | Title **Come back tomorrow**; body **Daily chest already opened today.** |
| `PickerScroll` 400 px, clip | Jedan stupac, **nema scrolla**; panel raste; sve T3 ikone vidljive |
| Hub swipe u polju mrtav | Field open: Stage **nije** u `block_hub_swipe`; chrome **jest** |
| Sprinkler + Loot Boost kartice u kampu | Kartice hidden; **Magnet** / **Loot Boost** na polju, UR ispod Settings |

## Što HOME-16 **jest**

- Override Daily claimed copy (P206 caption ostaje Tap to open / Back tomorrow).
- Override picker visine: bez scrolla, jedan stupac (DOCK-A T3/★3/footer ostaju).
- Override hub swipe samo dok je field open (karusel Stage i dalje blokira L/R sezona).
- Premještaj upgrade UI: kamp `%UpgradeCards` hidden; polje dobije kompaktne gumbe. Spend **ne** mijenja (C8–C11).

## Što HOME-16 **nije**

- Shop IAP, AdMob, Unlock JSON 500/20, leftover/vacuum, Pip FSM, Play 3-koraka, SeedCatalog JSON, `SAVE_VERSION`.
- Kamp Seeds/Flowers naslovi, +10%, next-lock kartica — to je [[ideje-camp-link|CAMP-03]].
- Brisanje `magnet_level` / `multiplier_level` / `try_upgrade_*`.
- 8 tscn polja.

## Agent

- Daily overlay body → **FIELD-A ✅**.
- Basket bez scrolla → **FIELD-B ✅**.
- Hub swipe u polju → **FIELD-C ✅**.
- Magnet/Loot na polju + hide camp cards → **FIELD-D ✅**.
- Ne spajati D s CAMP3-A. Ne spajati s DOCK/LIFE/CHROME kod promptima.

## Paket

| Doc | Što |
|-----|-----|
| ovaj hub | pitch + override |
| [[ideje-home-meadow-field-daily\|daily]] | overlay body (A) |
| [[ideje-home-meadow-field-basket\|basket]] | no-scroll picker (B) |
| [[ideje-home-meadow-field-swipe\|swipe]] | hub pager u polju (C) |
| [[ideje-home-meadow-field-upgrades\|upgrades]] | Magnet/Loot na polju (D) |
| [[ideje-home-meadow-field-pitanja\|pitanja]] | P215–P232 |
| [[ideje-home-meadow-field-grupe\|grupe]] | A–D mapa |
| [[../06-production/plan-prompts-home-camp-field\|prompti]] | copy-paste (HOME-16 + CAMP-03) |

## Povezano

- [[ideje-home-meadow-dock|HOME-15]] · [[ideje-camp-link|CAMP-03]] · [[ideje-camp|CAMP-01]]
- [[../06-production/plan-prompts-home-camp-field|prompti]] · [[CHECKPOINT|CHECKPOINT]]
