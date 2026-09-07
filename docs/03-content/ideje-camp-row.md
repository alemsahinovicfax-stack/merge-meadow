---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, unlock, seeds, flowers, scratch]
povezano:
  - ideje-camp-read
  - ideje-camp-link
  - plan-prompts-camp-row
  - CHECKPOINT
ai_sažetak: "CAMP-05 — debug 2 free + paid locked; chip red (ikona 80, samo ★, ime/broj desno); SeasonLink iste dimenzije kao Seeds/Flowers."
---

# IDEJE — CAMP-05 camp row

> **ID:** **CAMP-05** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **CAMP-05 ✅** 2026-09-06. Jedan agent-plan (nema A/B/C paste). Freeze: [[../06-production/plan-prompts-camp-row|plan-prompts-camp-row]].  
> **Prethodnik:** [[ideje-camp-read|CAMP-04]] (chip stack 176 / uvijek 3 slota `☆` **superseded**).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — 500c + 20 Harvest Pumpkin ostaje.

## Pitch

Playtest CAMP-04: stari save / `debug_unlock_all` ostavi sve sezone playable pa Camp SeasonLink nestane. Chipovi su 176px jer su ime i broj ispod ikone; T1 pokazuje prazne `☆`.

## Freeze

- Editor/debug: samo `country_bloom` + `frost_orchard`. Paid prazan. Lantern/Amber locked. New-game i dalje samo Bloom.
- SeasonLink se vraća (next-lock Lantern). Vanjske dimenzije = Garden/Crystal. Unlock = Exchange.
- Chip: ikona 80; ispod slike samo popunjene ★; ime i broj desno. `CHIP_MIN_H` ~104–116.
- Scroll Seeds/Flowers **420**. Home HOME-18 netaknut.
- MainScroll+420 / `_match_garden_height` / chip TextCol stack **superseded** [[ideje-camp-fill|CAMP-06]].
