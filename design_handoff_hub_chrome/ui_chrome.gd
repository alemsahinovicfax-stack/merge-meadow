class_name UiChrome
extends RefCounted

## Hub chrome (header + footer) — docs/04-experience/design-drafts/hub-header-footer-cd-brief.md
## Dizajn: design_handoff_hub_chrome/README.md · smjer B (tamni livadski chrome)
## Sve mjere su u px baze 1080x1920.

# --- Boje ---
const CHROME_DEEP := Color("#1A241E")      # tamnija varijanta #1F2B24
const PEACH_DEEP := Color("#E8A374")       # tamnija varijanta #FFB88C (pritisnut aktivan tab)
const COIN_GOLD := Color("#FFD56B")
const BADGE_PINK := Color("#FFCCD5")

# --- Mjere ---
const HEADER_CONTENT_H := 140
const HEADER_EDGE_H := 3
const FOOTER_H := 180
const CHIP_W := 296
const CHIP_H := 100
const SETTINGS_SIZE := 100
const SETTINGS_HIT := 140
const TAB_SLOT_W := 216
const TAB_TILE_W := 196
const TAB_TILE_H := 152
const INDICATOR_W := 196
const INDICATOR_H := 8
const RADIUS := 20
const NUMBER_FONT_SIZE := 48
const TAB_LABEL_FONT_SIZE := 40
const TAB_ICON_SIZE := 52
const CHIP_ICON_SIZE := 56


## Traka (Header / Footer). `top_edge` = footer, `false` = header.
static func chrome_style(bottom_edge: bool, locked: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = CHROME_DEEP
	s.set_corner_radius_all(0)
	var edge := Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.55)
	if locked:
		edge = Color(UiPalette.GOLD.r, UiPalette.GOLD.g, UiPalette.GOLD.b, 0.85)
	if bottom_edge:
		s.border_width_bottom = HEADER_EDGE_H
	else:
		s.border_width_top = HEADER_EDGE_H
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
	s.border_color = Color(UiPalette.OUTLINE.r, UiPalette.OUTLINE.g, UiPalette.OUTLINE.b, 0.14)
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
	s.border_color = Color(UiPalette.OUTLINE.r, UiPalette.OUTLINE.g, UiPalette.OUTLINE.b, 0.14)
	match state:
		"active":
			s.bg_color = UiPalette.PEACH
		"active_pressed":
			s.bg_color = PEACH_DEEP
		"pressed":
			s.bg_color = Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.12)
			s.border_color = Color(0, 0, 0, 0)
		_:
			s.bg_color = Color(0, 0, 0, 0)
			s.border_color = Color(0, 0, 0, 0)
	return s


## Ink za tab (ikona modulate + label boja).
static func tab_ink(active: bool) -> Color:
	if active:
		return UiPalette.OUTLINE
	return Color(UiPalette.WARM_WHITE.r, UiPalette.WARM_WHITE.g, UiPalette.WARM_WHITE.b, 0.82)


## Zakljucana navigacija: neaktivni tabovi na 60 % (labela drzi 4,7:1 prema traci).
const LOCKED_TAB_ALPHA := 0.6


## Separator hiljada do 6 cifara, kompakt tek od 7.
static func format_count(value: int) -> String:
	if value >= 1000000:
		return "%.1fM" % (value / 1000000.0)
	var s := str(absi(value))
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if value < 0 else "") + out
