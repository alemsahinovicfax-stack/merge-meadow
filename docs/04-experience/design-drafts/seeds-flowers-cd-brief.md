---
type: dizajn
status: draft
milestone: "—"
tags: [dizajn, art, sjeme, cvijece, claude-design, sezone, test]
povezano:
  - ../art-direction
  - ../../03-content/svijet-i-lore
  - journal-cd-brief
  - ../../06-production/CHECKPOINT
ai_sažetak: "Art brief za SVIH 48 vrsta cvijeća (8 sezona × 6 tipova, 3 tier-a svaki) + pravilo rarity→kompleksnost dizajna, za Claude Design generisanje ilustracija."
---

# Sjeme i cvijeće — Claude Design brief

> **Status: priprema materijala.** Ne mijenja kod. Cilj je dokument iz kojeg CD generiše ilustracije koje ćeš mi proslijediti, pa ih ja uvezem na mjesta u igri gdje se sjeme/cvijeće prikazuje.

## 1. Zašto ovo postoji

Igra ima **48 vrsta cvijeća** kroz 8 sezona (`game/data/seasons/seasons.json`), svaka sa 3 tier-a (seed → bloom → crystal) — **144 vizuelne varijacije** ukupno. Trenutno se sve crta **proceduralno u kodu** (`camp_plant_draw.gd`, `seed_visual_config.gd`): samo **6 tipova iz prve sezone (Country Bloom)** imaju ručno napisan crtež po tipu; preostalih **42 tipa iz 7 sezona padaju na generički fallback** — hash-ovana boja + prazan krug, bez prepoznatljivog oblika. To je najveća vizuelna praznina u igri trenutno.

Ovaj dokument ne opisuje 48 cvjetova pojedinačno (to bi bilo neupotrebljivo dugo i nedosljedno) — daje **sistem pravila** (stil + tier-progresija + rarity-kompleksnost + sezonska paleta) i **tabelu podataka** iz koje CD generiše sve varijante dosljedno.

## 2. Opšti stil (nasljeđeno, ne izmišljam novo)

Iz [[../art-direction|art-direction]] — koristi tačno ovo, ne novi jezik:

- **Flat 2D cartoon**, pastel, bez pixel grida
- **Outline:** tamniji od fill-a (~20%), 2–4px pri exportu
- **Sjena:** jedna blaga drop shadow (offset 2–4px, niska opacity), ne 3D realizam
- **Export:** PNG transparent pozadina, izvor ~128–256px visine (Godot skalira)
- Referentna paleta (baza, ne za cvijeće specifično): mint `#A8E6CF`, lavanda `#D4A5FF`, peach `#FFB88C`, warm white `#FFF8F0`

## 3. Tier progresija (T1 → T2 → T3) — isto za SVAKI tip

Ovo već postoji konceptualno u kodu (`camp_plant_draw.gd`) — CD treba pratiti istu logiku, ne izmišljati novu:

| Tier | Ime u kodu | Vizuelno značenje | Trenutni proceduralni pristup |
|------|-----------|--------------------|-------------------------------|
| T1 | Seed / Sprout | Tek niknulo — stabljika + 1 mali element (pupoljak/list), skromno, malo boje | Kratka stabljika + 1 krug/oblik |
| T2 | Bloom | Puno otvoren cvijet — glavni oblik prepoznatljiv, više latica/detalja, puna boja | Stabljika + 3–8 latica oko centra |
| T3 | Crystal | "Kristalna" nagrada varijanta — isti cvijet ali sa sjajnim/prozirnim tretmanom, dodatni glow prsten, najbogatiji tier | Isti raspored latica + prsten svjetla + poluprozirna/sjajna boja |

**Pravilo:** T3 nije drugi cvijet — isti silhouette/motiv kao T1/T2 istog tipa, samo napredniji/sjajniji tretman (misli "isti cvijet, nagrađen kristalnim sjajem"), da igrač odmah prepozna da je isti tip u različitim fazama.

## 4. Rarity → kompleksnost dizajna (novo pravilo, tvoj zahtjev)

**Broj zvjezdica (★1–★3, iz `roster[].rarity`) direktno određuje vizuelnu kompleksnost — i to važi za SVA 3 tier-a tog cvijeta**, ne samo za T3:

| Rarity | Kompleksnost | Smjernica za CD |
|--------|-------------|-------------------|
| ★1 (Common) | **Jednostavno** | Minimalan broj oblika (1 centar + 2–4 latice max), jedna glavna boja + jedna akcentna, bez sitnih detalja/teksture, čist silhouette |
| ★2 (Uncommon) | **Umjereno** | Više latica (5–8), dvije nijanse iste boje (svjetlije/tamnije), mali dodatni detalj (npr. venu na latici, sitan centar-pattern) |
| ★3 (Rare) | **Razrađeno** | Najviše latica/slojeva, gradijent ili dvije-tri boje u kombinaciji, dodatni flourish (sparkle, dvostruki red latica, sjajniji obrub) — treba se ODMAH prepoznati kao "najbolji" cvijet u sezoni i na prvi pogled i u T1 obliku |

**Zašto po svim tierovima, ne samo T3:** igrač treba prepoznati rarity cvijeta i dok je još T1 sjeme (prije nego dostigne bloom/crystal), inače je rarity signal nevidljiv pola vremena. Kompleksnost T1 ★3 cvijeta i dalje treba biti manje razrađena od T2/T3 ISTOG cvijeta (tier progresija i rarity-kompleksnost se kombinuju — ne poništavaju jedna drugu), ali odmah vidljivo bogatija od T1 ★1 cvijeta iste sezone.

## 5. Sezonska paleta / mood (iz postojećih taglinea, ne izmišljam nove teme)

| Sezona (`id`) | Mood (iz `tagline`) | Predložena akcent-nijansa (da se sezone razlikuju na prvi pogled) |
|---|---|---|
| `country_bloom` | Warm fields, soft petals, home pastures | Topla zelena/žuta (već postoji, baseline) |
| `frost_orchard` | Crisp air, silver blossom | Hladna plava/srebrna, bijeli akcenti |
| `lantern_meadow` | Dusk lights among tall grass | Tamno-ljubičasta/indigo pozadina osjećaj, topli žuto-narandžasti "glow" akcenti (lantern light) |
| `amber_canopy` | Warm late-season light through high leaves | Jesenja paleta — bakar, rusa narandžasta, tamno zlatna |
| `moonlit_warren` | Night blooms under a quiet moon | Tamno-plava/mornarska, srebrno-plavi mjesečev sjaj |
| `coral_tide` | Salt breeze and seashell petals | Koralno-roza, akva/tirkiz, pjenasto bijela |
| `starfall_glade` | Petals that catch the night sky | Duboka ljubičasta/crna pozadina osjećaj, zvjezdano-bijeli/cyan sjaj akcenti |
| `ember_fen` | Low firelight over marsh blooms | Tamno-zelena mahovina + vatreno-narandžasti/crveni akcenti |

CD treba da svaku sezonu vizuelno "oboji" u ovom pravcu dok i dalje poštuje osnovnu flat-cartoon paletu iz §2 — ne potpuno druga paleta po sezoni, nego **naglašena varijacija** unutar iste porodice stila (isto kao što je Frost Orchard "ista igra, hladnija paleta", ne druga igra).

## 6. Puna tabela — svih 48 tipova

> `type_id` je interni kod (koristi se u imenu fajla, vidi §7). `★` = rarity/kompleksnost po §4.

### Country Bloom (postojeći, referenca — CD ih ne treba iznova crtati, već ih koristiti kao baseline ton za ostale)

| type_id | Ime | ★ |
|---|---|---|
| `clover` | Meadow Clover | ★ |
| `daisy` | Field Daisy | ★ |
| `buttercup` | Buttercup Lane | ★ |
| `tulip` | Barn Tulip | ★★ |
| `sunflower` | Sunfence | ★★ |
| `pumpkin` | Harvest Pumpkin | ★★★ |

### Frost Orchard

| type_id | Ime | ★ |
|---|---|---|
| `frost_snowdrop` | Frost Snowdrop | ★ |
| `ice_crocus` | Ice Crocus | ★ |
| `silver_aconite` | Silver Aconite | ★ |
| `winter_camellia` | Winter Camellia | ★★ |
| `hoarfrost_rose` | Hoarfrost Rose | ★★ |
| `crystal_peony` | Crystal Peony | ★★★ |

### Lantern Meadow

| type_id | Ime | ★ |
|---|---|---|
| `dusk_firefly_grass` | Dusk Firefly Grass | ★ |
| `paper_lantern_bloom` | Paper Lantern Bloom | ★ |
| `evening_primrose` | Evening Primrose | ★ |
| `foxfire_lily` | Foxfire Lily | ★★ |
| `glow_wisteria` | Glow Wisteria | ★★ |
| `midnight_lotus` | Midnight Lotus | ★★★ |

### Amber Canopy

| type_id | Ime | ★ |
|---|---|---|
| `copper_leaf` | Copper Leaf | ★ |
| `maple_aster` | Maple Aster | ★ |
| `russet_mallow` | Russet Mallow | ★ |
| `cider_dahlia` | Cider Dahlia | ★★ |
| `golden_oak_bloom` | Golden Oak Bloom | ★★ |
| `amber_magnolia` | Amber Magnolia | ★★★ |

### Moonlit Warren (paid)

| type_id | Ime | ★ |
|---|---|---|
| `moon_moss` | Moon Moss | ★ |
| `nightshade_petal` | Nightshade Petal | ★ |
| `silver_harebell` | Silver Harebell | ★ |
| `lunar_orchid` | Lunar Orchid | ★★ |
| `star_jasmine` | Star Jasmine | ★★ |
| `umbral_lily` | Umbral Lily | ★★★ |

### Coral Tide Garden (paid)

| type_id | Ime | ★ |
|---|---|---|
| `sea_thrift` | Sea Thrift | ★ |
| `salt_daisy` | Salt Daisy | ★ |
| `tide_anemone` | Tide Anemone | ★ |
| `coral_hibiscus` | Coral Hibiscus | ★★ |
| `pearl_waterlily` | Pearl Waterlily | ★★ |
| `reef_crown` | Reef Crown | ★★★ |

### Starfall Glade (paid)

| type_id | Ime | ★ |
|---|---|---|
| `comet_sprig` | Comet Sprig | ★ |
| `nebula_clover` | Nebula Clover | ★ |
| `meteor_daisy` | Meteor Daisy | ★ |
| `aurora_tulip` | Aurora Tulip | ★★ |
| `galaxy_sunburst` | Galaxy Sunburst | ★★ |
| `nova_bloom` | Nova Bloom | ★★★ |

### Ember Fen (paid)

| type_id | Ime | ★ |
|---|---|---|
| `marsh_rush` | Marsh Rush | ★ |
| `peat_violet` | Peat Violet | ★ |
| `cinder_buttercup` | Cinder Buttercup | ★ |
| `flame_iris` | Flame Iris | ★★ |
| `smoke_lotus` | Smoke Lotus | ★★ |
| `fenfire_crown` | Fenfire Crown | ★★★ |

## 7. Gdje se ovo koristi u igri (13 mjesta, 4 "uloge")

| Uloga | Kontekst | Fajlovi (referenca, ne diraj sad) | Veličina/napomena |
|---|---|---|---|
| **Run pickup** | Sitna ikona koja pada niz lane, pokupi se u trku | `run/seed_visual.gd` | Mora biti čitljiva sitno i u pokretu — jak silhouette, ne previše detalja čak ni na ★3 |
| **Camp** | Gredica (bed), seed bag/crystal chip, basket | `camp_bed.gd`, `seed_bag_icon.gd`, `crystal_stash_icon.gd`, `arena_seed_chip.gd`, `arena_seed_bag.gd`, `arena_vacuum_fly.gd`, `home_basket_*.gd`, `season_field_flower.gd` | Srednja veličina, gleda se stacionarno — ovdje detalj ★2/★3 dolazi do izražaja |
| **Journal** | Tier ikona u Bloom Album redu | `collection_bloom_icon.gd` | Malo, ali gleda se pažljivo/uporedo (T1/T2/T3 jedno pored drugog) — najbolje mjesto da se tier-progresija i rarity-kompleksnost VIDE jasno uporedo |
| **Arena** | Merge chip drag-and-drop | `arena_seed_chip.gd`, `arena_seed_bag.gd` | Slično Camp veličini, mora izdržati drag/hover state |

**Imenovanje za predaju:** kad CD napravi slike i ti mi ih proslijediš, najlakše za uvoz je fajl po `type_id` + tier, npr. `clover_t1.png`, `clover_t2.png`, `clover_t3.png` — tako ih mogu direktno mapirati na postojeći `type_id` sistem bez nagađanja koje slike idu uz koji cvijet.

**Napomena o integraciji (za kasnije, ne sad):** kod danas sve crta proceduralno preko `CampPlantDraw`/`SeedVisualConfig`. Kad slike stignu, trebat će odluka — potpuno zamijeniti procedural crtež PNG-ovima (kao Journal naslov), ili zadržati procedural kao fallback dok sve slike ne stignu (kao `PipAssets` fallback na `PipDraw` obrazac iz CLAUDE.md). Prelazimo na to kad slike budu tu, ne prije.

## 8. Prompt za Claude Design

> Zbog obima (144 varijacije), preporuka: traži od CD da radi **po sezoni** (6 tipova × 3 tier-a = 18 slika po zahtjevu), ne sve odjednom — lakše za pregled i manje šanse da model "zaboravi" pravila na pola posla. Kopiraj i prilagodi `{SEZONA}` blok za svaku sezonu.

```
Radim set ilustracija cvijeća za mobilnu igru (Merge Meadow — casual F2P
merge/runner hibrid, flat pastel cartoon stil, bez pixel-arta, PNG
transparent pozadina).

STIL (iz cijele igre, ne mijenjaj):
- Flat 2D cartoon, pastel boje, zaobljeni oblici
- Outline: ~20% tamniji od fill-a ispod sebe, 2-4px
- Blaga drop shadow (offset 2-4px, niska opacity) — ne 3D realizam
- Bez teksture/dithering/retro efekata

TIER SISTEM — svaki cvijet ima 3 varijante istog motiva:
- T1 "Seed/Sprout": tek niknulo, kratka stabljika + 1 mali pupoljak/element,
  skromna boja, najjednostavniji oblik ove biljke
- T2 "Bloom": puno otvoren cvijet, glavni prepoznatljiv oblik, više latica,
  puna zasićena boja
- T3 "Crystal": ISTI cvijet kao T2 (isti raspored latica/silhouette), ali sa
  sjajnim/poluprozirnim kristalnim tretmanom + suptilan glow prsten oko
  cvijeta — nagradna, najsjajnija verzija, ne drugi cvijet

RARITY → KOMPLEKSNOST (primjenjuje se na SVA 3 tier-a istog cvijeta, ne samo
na T3):
- ★ (common): minimalno — 1 centar + 2-4 latice max, jedna glavna + jedna
  akcentna boja, čist jednostavan silhouette, bez sitnih detalja
- ★★ (uncommon): umjereno — 5-8 latica, dvije nijanse iste boje, jedan mali
  dodatni detalj (vena na latici ili šara na centru)
- ★★★ (rare): razrađeno — najviše latica/slojeva, gradijent ili kombinacija
  2-3 boje, dodatni flourish (sparkle/dvostruki red latica/sjajniji obrub) —
  mora se ODMAH prepoznati kao najbolji cvijet u sezoni, čak i u T1 obliku
  (T1 ★★★ i dalje jednostavniji od T2/T3 ISTOG cvijeta, ali vidljivo
  razrađeniji od T1 ★ drugog cvijeta iz iste sezone)

SEZONA: {SEZONA display_name} — mood: "{tagline}"
Akcent paleta za ovu sezonu: {predložena nijansa iz §5 tabele iznad}
(naglašena varijacija unutar iste flat-cartoon porodice stila — ne potpuno
druga paleta/stil, kao Frost Orchard biva "ista igra, hladnija paleta")

CVIJEĆE U OVOJ SEZONI (napravi T1+T2+T3 za svaki, 18 slika ukupno):
- {type_id_1} "{Display Name 1}" — ★{rarity}
- {type_id_2} "{Display Name 2}" — ★{rarity}
- {type_id_3} "{Display Name 3}" — ★{rarity}
- {type_id_4} "{Display Name 4}" — ★{rarity}
- {type_id_5} "{Display Name 5}" — ★{rarity}
- {type_id_6} "{Display Name 6}" — ★{rarity}

OGRANIČENJA:
- Svaka slika: kvadratni canvas, cvijet centriran, transparent pozadina
- Silhouette mora biti čitljiv i sitno (koristi se i kao mala pickup ikona
  u igri) — ne oslanjaj se na sitne detalje da nosi prepoznatljivost
- Imenuj fajlove jasno: {type_id}_t1, {type_id}_t2, {type_id}_t3 (ili
  navedi u odgovoru koja slika je koji type_id + tier ako imena fajlova
  nisu moguća)
- Ne izmišljaj nove tipove cvijeća van liste iznad
- Ne dizajniraj UI okvire/kartice oko cvijeta — samo sam motiv cvijeta,
  ja ga uklapam u postojeći UI

IZLAZ: 18 zasebnih slika (6 cvjetova × 3 tier-a), jasno označenih koja je koja.
```

## Povezano

- [[journal-cd-brief|journal-cd-brief]] — isti obrazac dokumenta, prvi test
- [[../art-direction|art-direction]] — osnovni stil
- [[../../03-content/svijet-i-lore|svijet-i-lore]] — lore pozadina sezona
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci (ovaj dokument ih ne mijenja)
