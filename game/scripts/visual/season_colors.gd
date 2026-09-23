class_name SeasonColors
## Derives every season colour from its mood hex. Mirrors SeasonCard.dc.html.
## Use: style.bg_color = SeasonColors.card_fill(mood, state)

const MEADOW := Color("#3A4A40")
const CHROME := Color("#1A241E")
const SOON_BASE := Color("#243329")
const INK_DARK := Color("#2D3436")
const INK_LIGHT := Color("#FFF8F0")

const MOODS := {
	&"country_bloom": Color("#A8E6CF"),
	&"frost_orchard": Color("#C5D5E8"),
	&"lantern_meadow": Color("#C9B8E0"),
	&"amber_canopy": Color("#E8C48A"),
	&"moonlit_warren": Color("#3D3A6B"),
	&"coral_tide_garden": Color("#E8A090"),
	&"starfall_glade": Color("#6B5B95"),
	&"ember_fen": Color("#C45C26"),
}

enum State { ACTIVE, OPEN, GATHER, READY, UNLOCKING, FAR, PREMIUM, PURCHASING, SOON }

static func card_fill(mood: Color, state: State) -> Color:
	match state:
		State.SOON: return mood.lerp(SOON_BASE, 0.55)
		State.GATHER, State.READY, State.UNLOCKING, State.FAR: return mood.lerp(MEADOW, 0.42)
		_: return mood

static func art_slot(fill: Color) -> Color:
	return fill.lerp(CHROME, 0.16)

static func far_token(mood: Color) -> Color:
	return mood.lerp(CHROME, 0.62)

static func ink(fill: Color) -> Color:
	return INK_LIGHT if fill.get_luminance() < 0.2 else INK_DARK

static func sub_ink(fill: Color) -> Color:
	return Color("#E9E1F0") if fill.get_luminance() < 0.2 else Color("#3F4648")
