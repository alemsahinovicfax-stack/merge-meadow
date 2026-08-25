---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, roster, sezone, scratch]
povezano:
  - ideje-home-unlock
  - ideje-home-unlock-pitanja
  - ideje-sezone-content
ai_sažetak: "HOME-07 roster — 48 jedinstvenih stubova; T3 art + zvijezde + ime; tamni okvir dolje-lijevo; paid locked pregled."
---

# IDEJE — HOME-07 flower roster

> [[ideje-home-unlock|hub]]. Run `seed_type_ids` **ne** dirati ovaj track (P91). Roster = Home katalog.

## Pravilo reda

Svaka sezona: **3×★1, 2×★2, 1×★3**. Svi `id` globalno jedinstveni. Red UI: T3 crtež (`CampPlantDraw` tier 3) | `★`×rarity | `display_name`. Šest redova, jedan ispod drugog.

## Layout

Panel **dolje-lijevo** na `SeasonStage` — **overrideano HOME-08:** child hero-centar slota, vidi [[ideje-home-incard-roster|HOME-08 roster]]. Tamni okvir (`1A1A14` / krem tekst) radi kontrasta na Bloom i Moonlit. `mouse_filter = IGNORE` (swipe prolazi). Prati **fokus** (hero centar), uključujući paid unowned i next-lock free.

## Tablica (48)

### Country Bloom

| id | ★ | Ime |
|----|---|-----|
| meadow_clover | 1 | Meadow Clover |
| field_daisy | 1 | Field Daisy |
| buttercup_lane | 1 | Buttercup Lane |
| barn_tulip | 2 | Barn Tulip |
| sunfence | 2 | Sunfence |
| harvest_pumpkin | 3 | Harvest Pumpkin |

### Frost Orchard

| id | ★ | Ime |
|----|---|-----|
| frost_snowdrop | 1 | Frost Snowdrop |
| ice_crocus | 1 | Ice Crocus |
| silver_aconite | 1 | Silver Aconite |
| winter_camellia | 2 | Winter Camellia |
| hoarfrost_rose | 2 | Hoarfrost Rose |
| crystal_peony | 3 | Crystal Peony |

### Lantern Meadow

| id | ★ | Ime |
|----|---|-----|
| dusk_firefly_grass | 1 | Dusk Firefly Grass |
| paper_lantern_bloom | 1 | Paper Lantern Bloom |
| evening_primrose | 1 | Evening Primrose |
| foxfire_lily | 2 | Foxfire Lily |
| glow_wisteria | 2 | Glow Wisteria |
| midnight_lotus | 3 | Midnight Lotus |

### Amber Canopy

| id | ★ | Ime |
|----|---|-----|
| copper_leaf | 1 | Copper Leaf |
| maple_aster | 1 | Maple Aster |
| russet_mallow | 1 | Russet Mallow |
| cider_dahlia | 2 | Cider Dahlia |
| golden_oak_bloom | 2 | Golden Oak Bloom |
| amber_magnolia | 3 | Amber Magnolia |

### Moonlit Warren

| id | ★ | Ime |
|----|---|-----|
| moon_moss | 1 | Moon Moss |
| nightshade_petal | 1 | Nightshade Petal |
| silver_harebell | 1 | Silver Harebell |
| lunar_orchid | 2 | Lunar Orchid |
| star_jasmine | 2 | Star Jasmine |
| umbral_lily | 3 | Umbral Lily |

### Coral Tide Garden

| id | ★ | Ime |
|----|---|-----|
| sea_thrift | 1 | Sea Thrift |
| salt_daisy | 1 | Salt Daisy |
| tide_anemone | 1 | Tide Anemone |
| coral_hibiscus | 2 | Coral Hibiscus |
| pearl_waterlily | 2 | Pearl Waterlily |
| reef_crown | 3 | Reef Crown |

### Starfall Glade

| id | ★ | Ime |
|----|---|-----|
| comet_sprig | 1 | Comet Sprig |
| nebula_clover | 1 | Nebula Clover |
| meteor_daisy | 1 | Meteor Daisy |
| aurora_tulip | 2 | Aurora Tulip |
| galaxy_sunburst | 2 | Galaxy Sunburst |
| nova_bloom | 3 | Nova Bloom |

### Ember Fen

| id | ★ | Ime |
|----|---|-----|
| marsh_rush | 1 | Marsh Rush |
| peat_violet | 1 | Peat Violet |
| cinder_buttercup | 1 | Cinder Buttercup |
| flame_iris | 2 | Flame Iris |
| smoke_lotus | 2 | Smoke Lotus |
| fenfire_crown | 3 | Fenfire Crown |

## Paleta

Nepoznati `id` u `SeedVisualConfig.palette`: hash → hue (ne fallback clover za sve).

## Paid

L/R kroz sve packove. Ember TEST_LOCK: fokus OK, roster vidi, nema grant, nema coin Unlock.

## Acceptance

- Bloom centar: 6 Country redova, Harvest Pumpkin ★★★.
- Lantern centar: Lantern roster + gate (B).
- Coral unowned centar: Coral roster, bez Unlock gumba.
