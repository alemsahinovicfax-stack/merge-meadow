## Home — biranje sezone · paket za prenos u Godot 4

Izvor dizajna: `design_handoff_home/HomeScreen.dc.html` (smjer **1a Season Trail**).
Referenca briefa: `docs/04-experience/design-drafts/home-season-select-cd-brief.md` §10.

### Šta je u paketu

| Fajl | Šta je | Kome |
|---|---|---|
| `home_export.json` | cijeli ekran kao podaci: tokeni, mjere, varijante kartice, stanja, animacije, tekstovi, asseti, mapa na node-ove, smoke delta | agent / skripta |
| `ui_home.gd` | gotove `StyleBoxFlat` fabrike i konstante iz istih tokena | Godot runtime |
| ovaj README | red prenosa i šta se briše | čovjek |

Sve mjere su u px baze **1080 × 1920** i prenose se 1:1. Home je **1080 × 1597** između headera (143) i footera (180).

### Kako čitati `home_export.json`

```
meta            baza, rect stranice, minimumi dodira i teksta
tokens          paleta, alpha fillovi, radiusi, borderi, sjene, font veličine
season_colors   mood boja + koji naslov (ink | cream) po sezoni
derived_fills   locked / coming_soon / border se RAČUNAJU, ne hardkodiraju
layout          rect i mjere svakog bloka stranice (TopRow, SeasonStage, Play…)
SeasonCard      varijante (visine) + svaki child s mjerama i stanjima
scenes          11 stanja s tačnim brojevima (coini, cvjetovi, aktivna, fokus)
animations      tween tabela: target property, trajanje, easing
strings_en      svi novi tekstovi s placeholderima
assets          šta postoji, šta treba exportati, šta je StyleBoxFlat
godot_map       CD sloj → node / skripta, s listom šta se briše
smoke_tests     koji testovi moraju pasti i zašto
open_decisions  pet odluka koje traže potvrdu prije implementacije
```

Ključno pravilo: **boje zaključanih i coming-soon kartica se izvode iz mood boje**, ne pišu ručno — `derived_fills` daje formule, `ui_home.gd` ih već implementira.

### Red prenosa

1. **Tokeni.** Ubaci `ui_home.gd` kao autoload ili `class_name`, i proširi `season_card_contrast.gd` s `locked_fill()` / `soon_fill()`.
2. **Kartica.** Napravi `season_card.tscn` s jednim korijenom `Panel` i child-ovima iz `SeasonCard.children`. Varijanta je **samo visina** (`custom_minimum_size:y`) + vidljivost child-ova — nema posebnih scena po stanju.
3. **Stage.** `season_stage.tscn` postaje `ScrollContainer > VBoxContainer`. Brišu se `BandColumn`, `PaidBand`, `BandSep`, `FreeBand`, svi `*Motion` i `*Slot` node-ovi, i funkcije `swap_home_band`, `cycle_free_strip`, `cycle_paid_strip`, `_play_inplace_morph`.
4. **Stranica.** `main_menu.tscn`: `DailyChestCard` ide u novi `TopRow` uz novi `ProgressIndicator`; brišu se `DecorMoundLeft/Right` (pozadina je ravna `#2E4733`).
5. **Gesta.** Izvadi cijeli `SeasonStage` iz grupe `block_hub_swipe` — u smjeru 1a grupa ostaje **prazna**.
6. **Brisanje.** `season_browser.tscn` + `season_browser.gd`, mrtav `SeasonUnlockSheet`, `split` režim u `season_unlock_progress.gd`.
7. **Smoke.** Ažuriraj četiri testa iz `smoke_tests.must_update`.

### Šta se NE mijenja

Ekonomija (500 coina + 20 ★3), redoslijed i linearnost besplatnog puta, IAP tok i cijene, header i footer, broj sezona (`seasons.json` ostaje izvor).

### Odlučeno 2026-09-21 — Play

`Play` na Home **pokreće run u aktivnoj sezoni odmah** (1 korak umjesto 3). Na dugmetu stoji ime te sezone u `SeasonNameChip` na desnom kraju, pa dugme čita kao `Play · Country Bloom`; ime je u čipu a ne u labeli da dugačka imena (`Coral Tide Garden`) ne skraćuju riječ Play. `main_menu.home_play_action()` gubi grane `open_field` i `snap`. `PlayThemeBadge` (danas uvijek skriven) se briše.

**Polje sezone** se otvara samo tapom na karticu aktivne sezone ili na `Open meadow ↗`. `season_meadow_smoke` se mijenja pri prenosu.

### Prije implementacije treba potvrda

Četiri stavke iz `open_decisions` (Browser, pozadina, Ember Fen, Shop).
