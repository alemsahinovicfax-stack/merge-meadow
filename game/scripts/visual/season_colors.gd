class_name SeasonColors
## Derives every season colour from its mood hex. Mirrors SeasonCard.dc.html:
## mix() rounds each channel to 8 bits and lum() is WCAG relative luminance.

const MEADOW := Color("#3A4A40")
const CHROME := Color("#1A241E")
const SOON_BASE := Color("#243329")
const CREAM := Color("#FFF8F0")
const INK_DARK := Color("#2D3436")
const INK_LIGHT := Color("#FFF8F0")
const SUB_DARK := Color("#3F4648")
const SUB_LIGHT := Color("#E9E1F0")
const DARK_LUM := 0.2

const MOODS := {
	"country_bloom": Color("#A8E6CF"),
	"frost_orchard": Color("#C5D5E8"),
	"lantern_meadow": Color("#C9B8E0"),
	"amber_canopy": Color("#E8C48A"),
	"moonlit_warren": Color("#3D3A6B"),
	"coral_tide": Color("#E8A090"),
	"coral_tide_garden": Color("#E8A090"),
	"starfall_glade": Color("#6B5B95"),
	"ember_fen": Color("#C45C26"),
}


static func mood_of(season_id: String) -> Color:
	if MOODS.has(season_id):
		return MOODS[season_id]
	return Color("#A8E6CF")


static func mix(a: Color, b: Color, t: float) -> Color:
	return Color8(
		roundi(a.r8 + (b.r8 - a.r8) * t),
		roundi(a.g8 + (b.g8 - a.g8) * t),
		roundi(a.b8 + (b.b8 - a.b8) * t)
	)


## Card fill per state string (HomeSeasonCard.ST_*).
static func card_fill(mood: Color, state: String) -> Color:
	match state:
		"soon":
			return soon_fill(mood)
		"gather", "ready", "unlocking", "far":
			return locked_fill(mood)
	return mood


static func locked_fill(mood: Color) -> Color:
	return mix(mood, MEADOW, 0.42)


static func soon_fill(mood: Color) -> Color:
	return mix(mood, SOON_BASE, 0.55)


static func art_slot(fill: Color) -> Color:
	return mix(fill, CHROME, 0.16)


static func far_token(mood: Color) -> Color:
	return mix(mood, CHROME, 0.62)


## Border of the placeholder dot in roster tiles.
static func dot_edge(mood: Color) -> Color:
	return mix(mood, CREAM, 0.55)


static func luminance(c: Color) -> float:
	return 0.2126 * _linear(c.r) + 0.7152 * _linear(c.g) + 0.0722 * _linear(c.b)


static func is_dark(fill: Color) -> bool:
	return luminance(fill) < DARK_LUM


static func ink(fill: Color) -> Color:
	return INK_LIGHT if is_dark(fill) else INK_DARK


static func sub_ink(fill: Color) -> Color:
	return SUB_LIGHT if is_dark(fill) else SUB_DARK


static func _linear(v: float) -> float:
	if v <= 0.03928:
		return v / 12.92
	return pow((v + 0.055) / 1.055, 2.4)
