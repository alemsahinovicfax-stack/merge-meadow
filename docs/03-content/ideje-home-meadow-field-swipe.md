---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, swipe, hub, scratch]
povezano:
  - ideje-home-meadow-field
  - ideje-home-meadow-field-pitanja
  - plan-prompts-home-camp-field
ai_sažetak: "HOME-16 C ✅ — hub swipe Journal/Camp radi dok je season field otvoren; karusel i dalje blokira Stage."
---

# IDEJE — HOME-16 swipe (hub pager u polju)

> [[ideje-home-meadow-field|hub]] · freeze P221–P224, P232.  
> **Kod:** **FIELD-C ✅**. Ne Daily (A). Ne picker (B). Ne Magnet UI (D) osim što D kasnije doda chrome u istu `block_hub_swipe` listu.

## Danas

[`season_stage.gd`](../../game/scripts/ui/season_stage.gd) `add_to_group("block_hub_swipe")`. [`swipe_pager.gd`](../../game/scripts/ui/swipe_pager.gd) `should_block_hub_swipe_at` — ako pointer padne na Stage rect, hub swipe ne krene. Karusel: namjerno (L/R sezona). Polje je full-bleed dijete Stagea → **cijeli Home** blokira pager. Igrač ne može otići u Camp/Journal dok je u sezoni.

Stranice: [`meta_hub_pages.gd`](../../game/scripts/meta/meta_hub_pages.gd) Journal=`COLLECTION` (1), Home=`MAIN` (2), Camp=`CAMP` (3).

## C — swipe u polju ✅

1. **Karusel** (`home_season_field_open == false`): Stage **ostaje** u `block_hub_swipe` (L/R sezona).
2. **Polje otvoreno:** Stage **nije** u grupi (remove on open, add on close).
3. Chrome **jest** u grupi dok je polje otvoreno: Daily, Basket, Settings, SeasonNameChip, PlayRow, (nakon D) Magnet/Loot. Tap na gumbe ne mijenja hub page.
4. Swipe po livadi / praznom fieldu → hub pager. Lijevo = Journal, desno = Camp.
5. `home_season_field_open` **ostaje true** kad odeš s Homea (session). Povratak na Home i dalje pokazuje polje. Close i dalje Seasons / Back / Escape (P174 / P199).

## Smoke (P232) ✅

Bloom field open: mid-field `should_block_hub_swipe_at` == false. Daily ili PlayRow rect == true. Karusel (field closed): Stage mid i dalje true (postojeći `season_home_smoke` assert). Simulated/go_to_page Camp pa natrag Home: `home_season_field_open` i dalje true, `field_id` isti.

## Acceptance

- Iz unutrašnjosti sezone možeš swipeati na Journal i Camp kao s karusela.
- Sezona L/R na karuselu ne puca.
- Polje se ne zatvara samo zato što si otišao na drugu hub stranicu.
