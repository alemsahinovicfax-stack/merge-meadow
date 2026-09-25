## UiChrome — DIFF za hub chrome v2 (design_handoff_hub_chrome_v2).
## Samo izmijenjene / nove konstante i StyleBoxFlat fabrike, isti nazivi kao
## game/scripts/visual/ui_chrome.gd. Sve što ovdje nije navedeno ostaje kako jeste.
## Mjere u px baze 1080x1920 (prenos 1:1).

# --- Boje ---------------------------------------------------------------
const CHROME_DEEP := Color("#2A2233")      # bilo #1A241E — dusk plum, ista za header i footer
const CHIP_WELL := Color("#1F1926")        # NOVO — udubljen chip (CHROME_DEEP tamnije)
const CHIP_WELL_EDGE_ALPHA := 0.14         # NOVO — warm white @ 14 %
const CHROME_SHADOW := Color(0.078, 0.055, 0.102, 0.34)  # bilo (0.078,0.102,0.086) — ljubičasta umjesto zelene sjene
# PEACH_DEEP, COIN_GOLD, BADGE_PINK — bez promjene

# --- Header (visina i lanac širina bez promjene) ------------------------
const CHIP_ICON_SIZE := 64                 # bilo 56
const CHIP_ICON_GAP := 10                  # bilo 12
const CHIP_PAD_LEFT := 14                  # NOVO (bilo hardkodirano 18 u chip_style)
const CHIP_PAD_RIGHT := 18                 # NOVO (bilo 20) → broj ima 190 px (isto kao v1)
const NUMBER_INK := Color("#FFF8F0")       # NOVO — broj je sada svijetao (bio OUTLINE na zlatnom/mint/lavanda chipu)
const SETTINGS_ICON_SIZE := 56             # bilo 54 (novi zupčanik icon_settings_light.svg)
# NUMBER_FONT_SIZE 48, CHIP_H 100, SETTINGS_* — bez promjene

# --- Footer --------------------------------------------------------------
const FOOTER_H := 144                      # NOVO — ukupno (rub 3 + sadržaj 141); bilo 180
const FOOTER_CONTENT_H := 141              # bilo 177
const FOOTER_DELTA := 36                   # NOVO — 180 − 144; svaka stranica raste za ovo
const PAGE_H := 1633                       # NOVO — 1920 − 143 − 144 (bilo 1597 po stranicama)
const TAB_SLOT_W := 216                    # NOVO (bilo implicitno) — hit-zona 216 x 141
const TAB_TILE_W := 184                    # bilo 196
const TAB_TILE_H := 108                    # bilo 152
const TAB_TILE_TOP := 20                   # bilo 17
const TAB_ICON_SIZE := 64                  # bilo 52 — neaktivan (_light, alpha INACTIVE_INK_ALPHA)
const TAB_ICON_SIZE_ACTIVE := 72           # NOVO — aktivan (fajl u boji)
const TAB_ICON_ACTIVE_LIFT := -2           # NOVO — y pomak ikone na aktivnom tile-u
# TAB_ICON_GAP i TAB_LABEL_FONT_SIZE — BRIŠU SE (nema labele)
const INDICATOR_W := 72                    # bilo 196
const INDICATOR_H := 8
const INDICATOR_TOP := 6                   # bilo 5
const INDICATOR_X_IN_SLOT := 72            # NOVO — (216 − 72) / 2
const BADGE_OFFSET := Vector2(6.0, -8.0)   # bilo (-2, -8) — izlazi 6 px desno od tile-a (tile je uži)
const LOCK_ICON_SIZE := 34                 # bilo 30
const LOCK_FONT_SIZE := 38                 # bilo 26 — minimum teksta iz pristupacnost.md
const LOCK_GLYPH_SPACING := 2              # ~0.04em na 38 px (bez promjene broja)
# BADGE_SIZE 44, BADGE_FONT_SIZE 26, LOCK_PILL_H 64, LOCK_PILL_RISE 36, RADIUS 20,
# LOCKED_TAB_ALPHA 0.6, INACTIVE_INK_ALPHA 0.82 — bez promjene

# --- Ikone (game/assets/ui/chrome/) -------------------------------------
const ICON_COIN := "res://assets/ui/chrome/icon_coin.svg"      # u boji, fiksna — NE modulate
const ICON_SEED := "res://assets/ui/chrome/icon_seed.svg"      # u boji, fiksna
const ICON_FLOWER := "res://assets/ui/chrome/icon_flower.svg"  # NOVO — u boji, fiksna (zamjenjuje arena/icon_crystal.svg u hubu i Campu)
const ICON_SETTINGS := "res://assets/ui/chrome/icon_settings_light.svg"


## Aktivan tab = fajl u boji, neaktivan = krem linijski (_light). Obje fiksne boje:
## kod smije mijenjati samo modulate.a, nikad RGB.
static func tab_icon_path(page_key: String, active: bool) -> String:
	return "res://assets/ui/chrome/tab_%s%s.svg" % [page_key, "" if active else "_light"]


## Traka hub chromea. Ista kao v1, nova boja i sjena.
static func chrome_style(bottom_edge: bool, locked: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHROME_DEEP
	var edge := _alpha(UiPalette.WARM_WHITE, 0.55)
	if locked:
		edge = _alpha(UiPalette.GOLD, 0.85)
	if bottom_edge:
		s.border_width_bottom = CHROME_EDGE_W
	else:
		s.border_width_top = CHROME_EDGE_W
	s.border_color = edge
	s.shadow_color = CHROME_SHADOW
	s.shadow_size = 14
	s.shadow_offset = Vector2(0, 6 if bottom_edge else -6)
	return s


## Chip valute — v2: jedan neutralan well za sva tri chipa (boju nosi ikona).
## Stari potpis chip_style(fill) se uklanja; pozivi u meta_hub_controller._setup_chip() gube argument.
static func chip_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHIP_WELL
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.WARM_WHITE, CHIP_WELL_EDGE_ALPHA)
	s.content_margin_left = float(CHIP_PAD_LEFT)
	s.content_margin_right = float(CHIP_PAD_RIGHT)
	s.content_margin_top = 0.0
	s.content_margin_bottom = 0.0
	return s


## Tab tile — ista stanja kao v1; mijenja se samo pressed (bez ruba, kao prije) i veličina (u hub_tab.gd).
## tab_ink() se BRIŠE (nema labele).


static func indicator_style(locked: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = _alpha(UiPalette.PEACH, 0.4 if locked else 1.0)
	s.set_corner_radius_all(INDICATOR_H / 2)
	return s


## badge_style() i lock_pill_style() — bez promjene koda; automatski preuzimaju novi CHROME_DEEP.
