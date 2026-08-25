---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, outline, lock, sezone, scratch]
povezano:
  - ideje-home-focus
  - ideje-home-focus-pitanja
  - ideje-home-glide
  - ideje-home-chrome
ai_sažetak: "HOME-06 chrome — visoki kontrast outline; ugašen PlayThemeBadge; TEST_LOCK_LAST_SEASONS na amber_canopy i ember_fen."
---

# IDEJE — HOME-06 chrome (outline, badge, test-lock)

> [[ideje-home-focus|HOME-06 hub]]. Play CTA: [[ideje-home-chrome|HOME-03]] — dva gumba ostaju. Badge između njih nestaje.

## Outline (P71, P75, P79)

Danas `_apply_card_color`: 3px `Color("E8D5A3")` kad `season_id == active_season_id` i playable. Na Country Bloom fill `DDE8DC` cream border nestaje. Na tamnom Moonlit je bolji, ali i dalje tanak.

**Pravilo:** outline = playable `active_season_id` (P61/P75). Nakon Browser fixa to je hero-centar kad je sezona playable. Locked / unowned centar: **nema** outline na katanac. Ako je `active` i dalje stara playable sezona koja sjedi kao susjed (npr. fokus na locked Amber), outline smije biti na tom susjedu — to je točan „Play tema“ signal, ne bug. Badge više ne postoji da to objasni, zato outline **mora** biti vidljiv.

**Vizual (P79):** Godot `StyleBoxFlat` ima jedan `border`. Opcije:

1. **Preferirano u kodu:** `set_border_width_all(5)` + `border_color = Color("FFF6D6")` + `set_shadow_size(2)` + `shadow_color = Color("1A1A14")` (tamna sjena kao vanjski stroke).
2. Fallback ako shadow ne čita: `border_width` 4, boja `Color("1A1A14")` (gotovo crni) — čita se na Bloom i na Moonlit; unutarnji cream nije moguć bez nested Panel. Jedan tamni 4–5px je bolji od nevidljivog cream 3px.
3. Ne koristiti samo `E8D5A3` 3px.

Corner radius 16 ostaje. Locked kartice: sivi fill + lock ikona, **bez** play-outline.

## PlayThemeBadge (P74)

U `main_menu.tscn` `HomeColumn` redoslijed: SeasonStage → PlayButton → **PlayThemeBadge** → EndlessPlayButton. Badge se pali kad `active_season_id != home_hero_center_id()` (`_refresh_play_theme_badge`). Igrač vidi „Theme: …“ između dva Play CTA — smetnja, ne informacija koju je tražio.

**Cilj:** između Play i Play Endless **nema** labele, hinta, theme imena, ni drugog iskačućeg teksta.

Kod:

- `PlayThemeBadge.visible = false` uvijek, ili maknuti node iz VBoxa (čistije: ostavi node, `visible = false` + `_refresh_play_theme_badge` early-return, da se lako vrati).
- Ne dodavati zamjenski subtitle.
- Play i Endless **interno** i dalje koriste `home_hero_center_id()` / zadnji playable (P50): unowned paid centar ne paywall-a Play. Samo UI badge nestaje.

## Test-lock zadnje sezone (P73, P76–P80)

Za playtest lock UI-a, **zadnja free** i **zadnja paid** u katalogu ponašaju se kao da nisu otključane, čak i nakon `debug_unlock_all_seasons`.

| Katalog | Id | Display | Uloga |
|---------|----|---------|--------|
| Zadnja free (`free_defs_sorted()` zadnji) | `amber_canopy` | Amber Canopy | S4 teaser / lock |
| Zadnja paid (`paid_defs()` zadnji) | `ember_fen` | Ember Fen | 4. pack, lock |

**Const:** `TEST_LOCK_LAST_SEASONS := true` na `GameState` (ili `SeasonCatalog`). Default **true** u ovom sliceu. Kad se ugasi, amber/ember se ponašaju kao normalan free gate / IAP.

Dok je true:

| Putanja | Ponašanje |
|---------|-----------|
| `is_season_playable(amber_canopy)` / `ember_fen` | **false** |
| `debug_unlock_all_seasons` | **ne** appenda ta dva id-a; ne stavlja ih u `active` |
| Coin / T3 unlock amber | **ne** grant-a (P77) |
| IAP stub / `grant_paid_season(ember_fen)` | **false** / no-op (P78) |
| Shop kartica ember | vidljiva, tap **no-op** (nije purchase) |
| Browser ember | vidljiva, tap **no-op** |
| Browser amber | vidljiva locked; tap **bounce**, ne unlock sheet (P77) |
| Home 3-slot | sivo + 🔒 kao postojeći locked-next (P11 vizual) |
| Cycle na amber kao free desni teaser | ostaje locked desno ili locked centar **bez** `set_active`; bounce ako pravila P11 zabranjuju fokus na locked — **isto kao lantern→amber prije debug unlocka** |
| Play | nikad ne starta amber/ember temu dok je flag |

Ne bumpaj `SAVE_VERSION`. Ako stari save već ima amber u `unlocked_seasons` ili ember u `owned_paid_seasons`, `is_season_playable` ih **ipak** tretira kao locked dok je flag. (Test override, ne migracija.)

Kad flag padne na false: postojeći unlock/IAP kod radi; debug_unlock ponovo grant-a sve.

## Acceptance (chrome)

- Outline vidljiv na Bloom centru (svijetla karta) i na Moonlit centru (tamna).
- Nema teksta između Play i Play Endless u hubu, uključujući mismatch paid/free.
- Novi save + debug unlock: Amber i Ember i dalje lock na Home; Shop 4. pack ne kupuje Ember; Play ne ide u te teme.
- `shop_open_smoke` i dalje vidi **4** pack kartice.
- `season_home_smoke`: amber nije playable.
