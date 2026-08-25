---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, roster, sezone, scratch]
povezano:
  - ideje-home-incard
  - ideje-home-incard-pitanja
  - ideje-home-unlock-roster
ai_sažetak: "HOME-08 roster — child hero-centar slota, donji lijevi kut tog panela; veći T3+★+ime; paid i free; L/R i preview bez rostera."
---

# IDEJE — HOME-08 roster u prozoru sezone

> [[ideje-home-incard|hub]]. Katalog 48 stubova ostaje [[ideje-home-unlock-roster|HOME-07 roster]]. Ovaj doc overridea **gdje** i **koliko veliko**.

## Što je krivo

HOME-07 je stavio `SeasonRoster` kao dijete `SeasonStage` (anchor bottom-left cijelog Stagea, ~232×188, ikona 28, font 13). Igrač čita to kao HUD Homea, ne kao sadržaj **Country Bloom** / **Coral Tide** prozora. Na Bloom (svijetlo) i Moonlit (tamno) overlay može vizualno sjediti **preko granice** kartice ili pored nje — nikad „u prozoru“.

## Parent (P92)

Roster je **child hero-centar slota**, ne Stagea:

| `home_band` | Parent panela | Sezona koju crta |
|-------------|---------------|------------------|
| `"free"` | `%CenterSlot` | `strip_focus_id` / `home_hero_center_id()` |
| `"paid"` | `%PaidCenterSlot` | `paid_strip_focus_id` |

Sidro: **donji lijevi kut tog panela**. `clip_contents = true` na slotu da redovi ne curi na L/R susjede. `mouse_filter = IGNORE` na cijelom rosteru (HIT-A — swipe i tap centar i dalje idu na Stage).

Naslov sezone (`CenterTitle` / `PaidCenterTitle`) ostaje **gore**, centriran (P100). Roster ne prekriva ime.

## Tko vidi roster, tko ne (P93, P95)

**Vidi** — samo hero-centar prozor, bez obzira je li sezona playable, next-lock, paid unowned, ili Ember TEST_LOCK (fokus OK, roster da).

**Ne vidi:**

- `%LeftSlot` / `%RightSlot` / paid L/R — uske, samo ime + 🔒.
- Preview traka (~20% visine) — nema mjesta. Kad igrač **tapne preview** i band postane hero, roster se pojavi u **novom** hero-centru (ta sezona).

Kad L/R in-place pretapanje (HOME-06) zamijeni Bloom → Frost, roster u istom `CenterSlot` pretapa sadržaj (isti parent, novi `apply_season`). Nema drugog overlaya koji „kasni“ na Stageu.

## Veličina (P94)

HOME-07 je nečitljiv. Cilj na hero kartici (~80% Stage visine, stretch 1.35 širine):

| Element | HOME-07 | HOME-08 |
|---------|---------|---------|
| Plant ikona (T3 `draw_fitted_plant`) | 28px | **~52px** |
| Ime (`display_name`) | font 13 | **~22** |
| Zvijezde | font 14 | **~18** |
| Visina reda | 28 | **~56** |
| Okvir | tamni `1A1A14` / krem `FFF6D6` | ostaje, veći padding (~10–12) |

Šest redova jedan ispod drugog. Red UI **ne** mijenjati: T3 crtež | `★`×rarity | ime. Unique 48 id-eva iz HOME-07 tablice.

Ako hero visina ne stane 6×56 + naslov: smanjiti red na ~48 prije nego vratiti font 13. Nikad Stage overlay kao fallback.

## Paid

Isti widget, isti stil. Coral unowned u paid-hero centru: Coral roster (Reef Crown ★★★), **bez** Unlock gumba. Ember TEST_LOCK: roster da, grant ne, coin Unlock ne.

## Tehnički (za INCARD-A, ne P0 kod)

- Ukloniti Stage-level `[node name="SeasonRoster"]` iz [`game/scenes/ui/season_stage.tscn`](../../game/scenes/ui/season_stage.tscn).
- Instancirati panel unutar `CenterSlot` i unutar `PaidCenterSlot` (dva nodea ili jedan koji se reparenta — dvostruki instance jednostavniji uz `visible` prema `home_band`).
- [`season_roster_panel.gd`](../../game/scripts/ui/season_roster_panel.gd): povećati `ICON_S` / `ROW_H` / fontove; `apply_season(home_hero_center_id())` u `refresh`.
- `_ignore_hits` na strip_motion već IGNORE-a djecu slota — roster mora ostati IGNORE.

## Acceptance

- Free-hero Bloom centar: 6 Country redova **unutar** zelene kartice, donji lijevo; Harvest Pumpkin ★★★ čitljiv; naslov gore.
- L/R Frost: roster se mijenja u Frost (Crystal Peony) **u istom** prozoru; lijeva Bloom kartica nema mini-roster.
- Paid-hero Coral unowned: Coral roster u koraljnom prozoru, ne na dnu Stagea.
- Preview 20% free dok je paid-hero: nema rostera na uskoj traci.
- Swipe preko rostera i dalje L/R / select (IGNORE).
