---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, roster, kontrast, sezone, scratch]
povezano:
  - ideje-home-cardfit
  - ideje-home-cardfit-pitanja
  - ideje-home-incard-roster
ai_sažetak: "HOME-09 roster — pozadina po sezoni iz mood palete (kontrast); širi panel da imena stanu; paid isti jezik; gate prati frame."
---

# IDEJE — HOME-09 roster kontrast i širina

> [[ideje-home-cardfit|hub]]. Parent, 6 redova, T3+★+ime, HIT-A IGNORE, L/R i preview bez rostera — ostaje [[ideje-home-incard-roster|HOME-08 roster]]. Ovaj doc overridea **boju okvira** (P90/P94 jedan tamni frame) i **širinu** panela.

## Što je krivo

`season_roster_panel.gd` crta **jedan** frame za sve sezone:

- `FRAME = Color("1A1A14")` @ 0.88 alpha
- tekst `CREAM = Color("FFF6D6")`
- panel `custom_minimum_size = Vector2(260, 348)`, `offset_right = 268`

Tri playtest prigovora, jedan uzrok (isti widget, krivi vizual):

1. **Nema sezonskog kontrasta.** Country Bloom kartica je `A8E6CF` (svijetlo mint). Moonlit je `3D3A6B` (tamno indigo). Roster je uvijek gotovo crn. Na Bloomu izgleda kao naljepnica koja ne pripada livadi. Na Moonlitu nestaje u kartici — cream na crnom na ljubičastom, bez „okvira koji odgovara sezoni“. Igrač je rekao: različita sezona, različita boja pozadine prikaza cvijeća, da se **lijepo vidi**.
2. **Tekst ne staje.** 260px minus padding 12×2 minus ikona 52 minus zvijezde 56 minus separation ≈ **~120px** za ime font 22. `Paper Lantern Bloom`, `Golden Oak Bloom`, `Dusk Firefly Grass` idu u ellipsis. Treba **raširiti** prikaz.
3. Gate (ako je vidljiv) koristi isti univerzalni tamni box — na Amberu treba jantar porodica, ne Bloom-crna.

## Boja po sezoni (P108)

Izvor palete već postoji: `season_stage.gd` `_mood_color(season_id)`. Roster (i gate u B) **ne** izmišlja treću paletu. Algoritam:

| Kartica | Mood (postojeći) | Roster / gate frame | Tekst (ime, zvijezde, gate labele) |
|---------|------------------|---------------------|-------------------------------------|
| Country Bloom | `A8E6CF` svijetlo | mood **darkened ~0.50–0.60** (tamno mint/šuma) | cream `FFF6D6` |
| Frost Orchard | `C5D5E8` svijetlo | darkened (hladni navy) | cream |
| Lantern Meadow | `C9B8E0` svijetlo | darkened (duboko ljubičasto) | cream |
| Amber Canopy | `E8C48A` svijetlo | darkened (hrast / rust) | cream |
| Coral Tide | `E8A090` svijetlo | darkened (tealy-coral, taman) | cream |
| Moonlit Warren | `3D3A6B` **tamno** | mood **lightened ~0.25–0.35** (lavanda / cream-lilac) | tamni `1A1A14` |
| Starfall Glade | `6B5B95` **tamno** | lightened | tamni |
| Ember Fen | `C45C26` (srednje, zasićeno) | darkened (ugljen / pepeo) | cream |

Pravilo, ne obavezni hex po sezoni (hexovi gore su **smjer**; agent smije računati `darkened`/`lightened` iz `_mood_color` umjesto hardkod tablice):

- Ako je luminance mooda **visoka** (Bloom, Frost, Lantern, Amber, Coral) → frame tamniji od kartice, cream tekst, tanki cream border @ ~0.35 alpha.
- Ako je luminance **niska** (Moonlit, Starfall) → frame svjetliji od kartice, tamni tekst, tamni border @ ~0.35.
- Ember: tretirati kao „treba cream tekst na tamnom“ (darken), da plamen kartice ne opere imena.

`apply_season(season_id)` **mora** ponovo `_apply_frame` (danas se frame gradi samo u `_ready` — zato je sve `1A1A14`). Paid i free isti kod.

Border radius 12 i padding ~12 ostaju.

### Zašto ne isti `1A1A14` s jačim borderom

Playtest nije tražio „čitljiviji univerzalni HUD“. Tražio je da **prikaz cvijeća pripada toj sezoni** i da kontrast radi **na toj** kartici. Univerzalni crni box na Moonlitu i na Bloomu je točno HOME-08 P90 — override.

## Širina (P109)

Cilj: imena stanu **bez** ellipsisa na hero-centru za svih 48 `display_name` (najduži stubovi: `Dusk Firefly Grass`, `Paper Lantern Bloom`, `Golden Oak Bloom`, `Pearl Waterlily`, …).

| Danas | Cilj |
|-------|------|
| `custom_minimum_size.x` 260, `offset_right` 268 | min **~320px**, rasteži do **~0.42–0.50** širine `CenterFill` |
| `text_overrun_behavior` TRIM_ELLIPSIS | ostaje kao **fallback** ako Fill stvarno nema mjesta (rotacija / uski desktop window); prvo širina |
| Visina 348 / 6×56 | ostaje; ako clip reže donje redove na `HERO_MIN` 300, smanjiti `ROW_H` ~48 prije nego suziti |

Sidro ostaje **donji lijevi** kut. Ne puzati preko cijele kartice — gate treba desni kut (P110). Gruba podjela hero širine ~400px: roster ~42–50% lijevo, razmak, gate ~220px desno. Ako se preklapaju, gate `z_index` veći; roster **ne** smije gurati gate van clipa.

`clip_contents` na slotu ostaje da redovi ne curu na L/R susjede.

Ikona 52 / font 22 / zvijezde 18 / red 56 **ostaju** (P94). Širina panela, ne smanjenje tipa.

## Paid (P113)

`PaidRoster` isti algoritam boje + ista širina. Coral unowned: koraljni tamni frame, Reef Crown čitljiv. Moonlit paid-hero: svijetli frame, tamni tekst. **Nema** Unlock gatea na paid.

Ember TEST_LOCK: roster da (ako je u paid centru), coin Unlock ne.

## Gate frame (isti jezik)

`season_unlock_gate.gd` `_apply_frame` danas hardkodira `1A1A14`. U CARDFIT-B, `refresh_gate` / `apply` na gateu koristi **isti** contrast helper kao roster za `hero_id`. Tako Amber gate nije Bloom-crn na jantar kartici.

Ako helper živi u jednom mjestu (npr. statička funkcija na roster panelu ili mali `season_card_contrast.gd`), ne duplicirati luminance if-else u dva fajla. Nije obavezan novi fajl — dva `match` smiju dijeliti iste konstante.

## Što ne dirati

- 48 stubova, red T3 → zvijezde → ime, `seed_type_ids`
- Parent / sidro (child Fill, bottom-left)
- IGNORE na cijelom rosteru
- L/R i preview bez rostera
- CARDFIT-A TEST_LOCK (već gotovo prije B)

## Tehnički (za CARDFIT-B, ne P0 kod)

- [`season_roster_panel.gd`](../../game/scripts/ui/season_roster_panel.gd): `apply_season` postavlja StyleBox + `font_color` na name/star labele; širina preko layouta u tscn ili `offset_right` / anchor.
- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn): `FreeRoster` / `PaidRoster` širi; ne Stage overlay.
- [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd): frame + label color iz iste palete.
- Naslov center (isti prompt B) — vidi [[ideje-home-cardfit-naslov|naslov]].
- Smoke: Bloom roster `bg_color` ≠ Moonlit roster `bg_color`; `FreeRoster.size.x > 260` na hero Bloom; `Golden Oak Bloom` / `Harvest Pumpkin` vidljivi (nema praznog name labela). Ellipsis dopušten samo ako širina Fill < min.

## Acceptance

- Country Bloom hero: roster **tamno-zeleni/šumski** okvir unutar mint kartice; Harvest Pumpkin ★★★ čitljiv, cream na tamnom.
- Moonlit paid-hero: roster **svijetli** okvir unutar tamne kartice; Umbral Lily čitljiv, tamni tekst na svijetlom.
- Amber (nakon A): roster jantar-taman; imena `Golden Oak Bloom` / `Amber Magnolia` stanu bez ellipsisa na normalnom hero Fillu.
- Coral: druga boja od Bloom i od Moonlit — tri sezone, tri framea.
- L/R i preview i dalje bez rostera.
