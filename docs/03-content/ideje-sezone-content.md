---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, content, art, scratch]
povezano:
  - ideje-sezone
  - ideje-sezone-pitanja
  - ideje-identitet-lore
ai_sažetak: "SEZ-01 content bible — Country Bloom S1 + free/paid placeholder sezone (art, seeds, animal)."
---

# IDEJE — Sezone content bible

> Scratch · [[ideje-sezone|SEZ-01]]. Placeholder imena i art briefovi — nisu finalni asseti.

## Šablon po sezoni

Za svaku sezonu popuniti:

| Polje | Opis |
|-------|------|
| `id` | snake_case |
| `kind` | free / paid |
| `order` | free only |
| Display name + tagline | UI |
| Mood / palette | 3–5 hex draft |
| Seed list | id, rarity ★, unlock order u sezoni |
| Animal / clear rabbit | opis + kad se „otključa“ |
| Run BG | opis |
| Obstacles / enemies | reskin notes |
| Home thumbnail | kompozicija |
| Clear condition | draft |

---

## S1 — Country Bloom (free, order 1)

| | |
|--|--|
| **id** | `country_bloom` |
| **Tagline** | „Warm fields, soft petals, home pastures.“ |
| **Mood** | Seoska livada, jutro, zlatna prašina, pastel zelena + krem |
| **Palette draft** | `#A8E6CF` mint · `#FFE8B8` gold · `#FFF8F0` warm white · `#FFB88C` peach |

### Seeds (draft 6)

| Unlock order | Placeholder id | ★ | Notes |
|--------------|----------------|---|--------|
| 1 | `meadow_clover` | 1 | Tutorial / first runs |
| 2 | `daisy_path` | 1 | |
| 3 | `buttercup_lane` | 1 | |
| 4 | `barn_tulip` | 2 | Mid season |
| 5 | `sunfence` | 2 | |
| 6 | `harvest_pumpkin` | 3 | End / mythic feel |

> Može mapirati na postojeće `clover, daisy, buttercup, tulip, sunflower, pumpkin` kao **reskin imena** — odluka u [[ideje-sezone-pitanja|pitanja]].

### Animal

- Default run: **Pip**
- Clear reward art: „Country rabbit“ (slamnati šešir / cvjetni vijenac) — **kozmetika** dok se ne odluči run swap

### Run / enemies

- BG: rolling hills, fence posts, soft clouds
- Obstacles: wood crates, hay bales (ista hitbox familija)
- Enemies / pests (ako postoje u runu): rural critters tint

### Thumbnail

- Pip ili country rabbit u donjem trećem
- 2–3 seed ikone + 1 T3 flower
- Title banner **Country Bloom**
- Warm daylight grade

### Clear condition (draft)

- Otključaj svih 6 season seeds u Almanac/spawn **ili**
- N merge T3 flowera te sezone **ili**
- N uspješnih runova na S1  
→ točno jedno pravilo birati u playtestu.

---

## S2 — Frost Orchard (free, order 2) — placeholder

| | |
|--|--|
| **id** | `frost_orchard` |
| **Tagline** | „Crisp air, silver blossom.“ |
| **Mood** | Zimski voćnjak, plavo-srebrni pasteli |
| **Unlock draft** | 80 coins + 5 T3 flowers |
| **Seeds** | 6 novih ili zimski reskin S1 seta |
| **Animal** | Snow-collar rabbit |
| **BG** | Snow orchard rows, soft blizzard particles (low cost) |

---

## S3 — Lantern Meadow (free, order 3) — placeholder

| | |
|--|--|
| **id** | `lantern_meadow` |
| **Tagline** | „Dusk lights among tall grass.“ |
| **Mood** | Sumrak, lampioni, lavanda + amber |
| **Unlock draft** | 150 coins + 8 T3 flowers |
| **Animal** | Lantern rabbit |
| **BG** | Evening meadow, warm lanterns |

---

## P1 — Moonlit Warren (paid) — placeholder

| | |
|--|--|
| **id** | `moonlit_warren` |
| **kind** | paid |
| **IAP** | `season_pack_moonlit_warren` |
| **Tagline** | „Night blooms under a quiet moon.“ |
| **Mood** | Noć, indigo, silver petal |
| **Exclusive** | Unique seed names + night Pip/rabbit skin + moon BG |
| **Fair F2P** | Nema boljeg loot %; paralelni set |

---

## P2 — Coral Tide Garden (paid) — placeholder

| | |
|--|--|
| **id** | `coral_tide` |
| **kind** | paid |
| **IAP** | `season_pack_coral_tide` |
| **Tagline** | „Salt breeze and seashell petals.“ |
| **Mood** | Obala, coral, aqua |
| **Exclusive** | Beach BG, shell obstacles, tide rabbit |

---

## Shared art rules

- Jedan **thumbnail template** (safe title zone, seed row, rabbit pocket).
- Seed ikone i dalje mogu biti procedural `CampPlantDraw` + theme tint dok nema final art.
- Locked free: desaturate + lock overlay (shared shader/modulate).

## Volume za prvi drop featurea (preporuka)

| | Count |
|--|-------|
| Free | 3 (S1 ship-ready art lite, S2–S3 placeholder OK) |
| Paid | 2 |

Vidi [[ideje-sezone-pitanja|pitanje 9]].

## Povezano

- [[ideje-identitet-lore|identitet Pip]]
- [[ideje-sezone|hub]] · [[ideje-sezone-ekonomija|ekonomija]]
