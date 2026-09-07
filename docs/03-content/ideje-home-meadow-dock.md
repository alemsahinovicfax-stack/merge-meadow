---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, basket, daily, scratch]
povezano:
  - ideje-home-meadow-dock-pitanja
  - ideje-home-meadow-dock-grupe
  - ideje-home-meadow-dock-basket
  - ideje-home-meadow-dock-layout
  - ideje-home-meadow-dock-daily
  - ideje-home-meadow-life
  - ideje-home-meadow-chrome
  - ideje-home-meadow-field
  - plan-prompts-home-meadow-dock
  - plan-prompts-home-camp-field
  - CHECKPOINT
ai_sažetak: "HOME-15 hub — DOCK-A–D ✅. Sljedeće: HOME-16 field."
---

# IDEJE — Home meadow dock (HOME-15 hub)

> **ID:** **HOME-15** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **DOCK-P0** docs ✅ · **DOCK-A ✅** **DOCK-B ✅** **DOCK-C ✅** **DOCK-D ✅**. Playlist gotova. Grupe: [[ideje-home-meadow-dock-grupe|grupe]].  
> **Sljedeće:** [[ideje-home-meadow-field|HOME-16]] Daily overlay / basket no-scroll / hub swipe u polju / Magnet na polju · [[../06-production/plan-prompts-home-camp-field|prompti]].  
> **Prethodnik:** [[ideje-home-meadow-life|HOME-14]] LIFE-P0 ✅ A–D ✅ — Play 3-koraka, PlayRow, cvijeće, Pip.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — ★3 u basketu = spawn bias **teme**, ne IAP snaga.

## Pitch

U pickeru igrač vidi **T3 sliku iznad imena** i može izabrati cvijet s **tri zvijezdice**. Clear i Close stoje **jedno iznad drugog** na dnu; lista je gore.

Basket ide **gore lijevo ispod Daily gifta** (dimenzije kao Daily). Umjesto basketa u donjem redu stoji **Seasons** (ista veličina kao Play / Play Endless) — vraća na izbor sezona. Ime sezone na chipu **više ne** zatvara polje.

Daily gift na Homeu **nema** arena streak tekst ni claim.

## Zašto sada

HOME-14 je zatvorio meadow life. Basket u PlayRow guta mjesto Seasons gumbu; picker je sam tekst; ★3 (`is_mythic_seed`) se ne može izabrati; basket T3 crystal i polje T1/T2 bloom nisu isti draw; Daily caption vuče arena streak.

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Picker: samo `ime ★`; Clear u scroll listi | T3 ikona **iznad** imena; Clear+Close stacked footer |
| ★3 skip (`set_loadout` / season picker) | ★3 **smije** ako je u season pool ∩ unlocked |
| Basket T3, polje T1/T2 | Isti `draw_fitted_plant(type_id, 3)` |
| Basket lijevo od Play (320×96) | Basket ispod Daily (**336×104**) |
| Chip tap → close field | Chip samo ime; **Seasons** u PlayRow → close |
| Daily caption + arena streak / claim | Samo gift copy; arena HUD ostaje u areni |

## Što HOME-15 **jest**

- Override P165 / P184: Basket **nije** PlayRow dijete; red je Seasons \| Play \| Endless.
- Override P166: mythic/★3 u Home basketu.
- Override P185 vizual: meadow flowers **T3** (count 12–14 ostaje).
- Override CHROME-E tap na chip (P173 close s chipa) — close prelazi na Seasons row gumb. P174 Back/Escape ostaje.
- Home Daily: skini `get_arena_daily_home_line` i `claim_arena_daily` s chesta.

## Što HOME-15 **nije**

- Shop IAP, AdMob, CAMP-01/02, leftover/vacuum, hub pager, `SAVE_VERSION`.
- Pip FSM, Play 3-koraka, Endless Hard, SeedCatalog JSON rewrite, 8 tscn polja.
- Brisanje `arena_daily_*` iz savea. Arena daily HUD u merge areni.

## Agent

- Picker T3 / ★3 / Clear+Close footer → **DOCK-A ✅**.
- Polje i basket ista T3 slika → **DOCK-B ✅**.
- Basket pod Daily, Seasons u redu, chip ne close → **DOCK-C ✅**.
- Daily bez streaka → **DOCK-D**.
- Ne spajati A+C. Ne spajati s LIFE/CHROME kod promptima ni CAMP.

## Paket

| Doc | Što |
|-----|-----|
| ovaj hub | pitch + override |
| [[ideje-home-meadow-dock-basket\|basket]] | picker + T3 match (A+B) |
| [[ideje-home-meadow-dock-layout\|layout]] | Basket/Daily/Seasons/chip (C) |
| [[ideje-home-meadow-dock-daily\|daily]] | streak van Home chesta (D) |
| [[ideje-home-meadow-dock-pitanja\|pitanja]] | P197–P214 |
| [[ideje-home-meadow-dock-grupe\|grupe]] | A–D mapa |
| [[../06-production/plan-prompts-home-meadow-dock\|prompti]] | copy-paste |

## Povezano

- [[ideje-home-meadow-life|HOME-14]] · [[ideje-home-meadow-chrome|HOME-13]] · [[ideje-home-meadow|HOME-12]] · [[ideje-home-meadow-field|HOME-16]]
- [[../06-production/plan-prompts-home-meadow-dock|prompti]] · [[CHECKPOINT|CHECKPOINT]]
