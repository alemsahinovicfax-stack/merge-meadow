class_name UiChrome
extends RefCounted

## Hub chrome (header + footer) — smjer B, tamni livadski chrome iz Claude Designa.
## Handoff: design_handoff_hub_chrome/README.md · brief: docs/04-experience/design-drafts/hub-header-footer-cd-brief.md
## Sve mjere su u px baze 1080x1920 (prenos 1:1).

# --- Boje ---
const CHROME_DEEP := Color("#1A241E")  # tamnija varijanta hub pozadine #1F2B24
const PEACH_DEEP := Color("#E8A374")  # pritisnut aktivan tab
const COIN_GOLD := Color("#FFD56B")
const BADGE_PINK := Color("#FFCCD5")

# --- Header ---
const HEADER_PAD_LEFT := 20
const CHROME_EDGE_W := 3
const CHIP_H := 100
const CHIP_ICON_SIZE := 56
const CHIP_ICON_GAP := 12
const NUMBER_FONT_SIZE := 48
## Settings slot = 4 px lead + 100 px tile + 20 px do ruba ekrana → hit-zona 124 x 140.
const SETTINGS_SLOT_W := 124
const SETTINGS_HIT_H := 140
const SETTINGS_LEAD := 4
const SETTINGS_SIZE := 100
const SETTINGS_ICON_SIZE := 54

# --- Footer (y se mjeri od sadržaja footera, ispod 3 px ruba) ---
const FOOTER_CONTENT_H := 177
const TAB_TILE_W := 196
const TAB_TILE_H := 152
const TAB_TILE_TOP := 17
const TAB_ICON_SIZE := 52
const TAB_ICON_GAP := 10
const TAB_LABEL_FONT_SIZE := 40
const INDICATOR_W := 196
const INDICATOR_H := 8
const INDICATOR_TOP := 5
const BADGE_SIZE := 44
const BADGE_FONT_SIZE := 26
## Badge sjedi na gornjem desnom uglu tile-a: 8 px iznad, 2 px od desne ivice.
const BADGE_OFFSET := Vector2(-2.0, -8.0)
const LOCK_PILL_H := 64
const LOCK_PILL_RISE := 36  # px iznad gornjeg ruba footera
const LOCK_ICON_SIZE := 30
const LOCK_FONT_SIZE := 26
const LOCK_GLYPH_SPACING := 2  # ~0.08em na 26 px

const RADIUS := 20
## Zaključana navigacija: neaktivni tabovi na 60 % — labela drži 4,7:1 prema traci (0.45 pada na 3,3:1).
const LOCKED_TAB_ALPHA := 0.6
const INACTIVE_INK_ALPHA := 0.82

## Default font ima jednu težinu — embolden simulira 700/800 iz dizajna.
const EMBOLDEN_700 := 0.25
const EMBOLDEN_800 := 0.5

const TOAST_FONT_SIZE := 36

static var _fonts: Dictionary = {}


## Traka hub chromea. `bottom_edge` = header (rub dolje), `false` = footer (rub gore).
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
	s.shadow_color = Color(0.078, 0.102, 0.086, 0.34)
	s.shadow_size = 14
	s.shadow_offset = Vector2(0, 6 if bottom_edge else -6)
	return s


## Chip valute. `fill` = COIN_GOLD / UiPalette.MINT / UiPalette.LAVENDER.
static func chip_style(fill: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.OUTLINE, 0.14)
	s.content_margin_left = 18.0
	s.content_margin_right = 20.0
	s.content_margin_top = 0.0
	s.content_margin_bottom = 0.0
	return s


## Tab tile. state: "inactive" | "active" | "pressed" | "active_pressed"
static func tab_style(state: String) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.OUTLINE, 0.14)
	match state:
		"active":
			s.bg_color = UiPalette.PEACH
		"active_pressed":
			s.bg_color = PEACH_DEEP
		"pressed":
			s.bg_color = _alpha(UiPalette.WARM_WHITE, 0.12)
			s.border_color = Color(0, 0, 0, 0)
		_:
			s.bg_color = Color(0, 0, 0, 0)
			s.border_color = Color(0, 0, 0, 0)
	return s


## Ink taba (labela): tamni na peach, svijetli na traci.
static func tab_ink(active: bool) -> Color:
	if active:
		return UiPalette.OUTLINE
	return _alpha(UiPalette.WARM_WHITE, INACTIVE_INK_ALPHA)


## Settings tile u headeru.
static func icon_button_style(pressed: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = _alpha(UiPalette.WARM_WHITE, 0.18 if pressed else 0.10)
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.WARM_WHITE, 0.38)
	return s


static func indicator_style(locked: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = _alpha(UiPalette.PEACH, 0.4 if locked else 1.0)
	s.set_corner_radius_all(INDICATOR_H / 2)
	return s


static func badge_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BADGE_PINK
	s.set_corner_radius_all(BADGE_SIZE / 2)
	s.set_border_width_all(3)
	s.border_color = CHROME_DEEP
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	s.content_margin_top = 0.0
	s.content_margin_bottom = 0.0
	return s


static func lock_pill_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHROME_DEEP
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.GOLD, 0.85)
	s.content_margin_left = 28.0
	s.content_margin_right = 28.0
	s.content_margin_top = 0.0
	s.content_margin_bottom = 0.0
	return s


## Kratka poruka ispod headera (npr. Settings placeholder dok ne stigne D0-P ekran).
static func toast_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiPalette.WARM_WHITE
	s.set_corner_radius_all(RADIUS)
	s.set_border_width_all(2)
	s.border_color = _alpha(UiPalette.OUTLINE, 0.14)
	s.content_margin_left = 28.0
	s.content_margin_right = 28.0
	s.content_margin_top = 18.0
	s.content_margin_bottom = 18.0
	s.shadow_color = _alpha(UiPalette.OUTLINE, 0.10)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 4)
	return s


static func heavy_font(embolden: float, glyph_spacing: int = 0) -> Font:
	var key := "%.2f_%d" % [embolden, glyph_spacing]
	if _fonts.has(key):
		return _fonts[key] as Font
	var fv := FontVariation.new()
	fv.base_font = ThemeDB.fallback_font
	fv.variation_embolden = embolden
	fv.spacing_glyph = glyph_spacing
	_fonts[key] = fv
	return fv


## Separator hiljada do 6 cifara, kompakt tek od 7.
static func format_count(value: int) -> String:
	if value >= 1000000:
		return "%.1fM" % (value / 1000000.0)
	var digits := str(absi(value))
	var out := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if value < 0 else "") + out


static func _alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)
