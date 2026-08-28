class_name SeasonCardContrast
extends RefCounted

## HOME-09 — roster/gate/title colors from the same mood palette as the season card.

const CREAM := Color("FFF6D6")
const INK := Color("1A1A14")
const TITLE_DARK := Color(0.18, 0.22, 0.2)
const FRAME_ALPHA := 0.28
const BORDER_ALPHA := 0.35
const LUM_SPLIT := 0.45


static func mood_color(season_id: String) -> Color:
	match season_id:
		"country_bloom":
			return Color("A8E6CF")
		"frost_orchard":
			return Color("C5D5E8")
		"lantern_meadow":
			return Color("C9B8E0")
		"amber_canopy":
			return Color("E8C48A")
		"moonlit_warren":
			return Color("3D3A6B")
		"coral_tide":
			return Color("E8A090")
		"starfall_glade":
			return Color("6B5B95")
		"ember_fen":
			return Color("C45C26")
		_:
			return Color("DDE8DC")


static func uses_dark_frame(season_id: String) -> bool:
	if season_id == "ember_fen":
		return true
	var mood := mood_color(season_id)
	var lum := 0.2126 * mood.r + 0.7152 * mood.g + 0.0722 * mood.b
	return lum >= LUM_SPLIT


static func frame_bg(season_id: String) -> Color:
	var mood := mood_color(season_id)
	var tint: Color
	if uses_dark_frame(season_id):
		tint = mood.darkened(0.18)
	else:
		tint = mood.lightened(0.20)
	tint.a = FRAME_ALPHA
	return tint


static func text_color(season_id: String) -> Color:
	return CREAM if uses_dark_frame(season_id) else INK


static func border_color(season_id: String) -> Color:
	var ink := text_color(season_id)
	return Color(ink.r, ink.g, ink.b, BORDER_ALPHA)


static func title_color(season_id: String) -> Color:
	var mood := mood_color(season_id)
	var lum := 0.2126 * mood.r + 0.7152 * mood.g + 0.0722 * mood.b
	if lum < LUM_SPLIT:
		return CREAM
	return TITLE_DARK


static func make_frame(season_id: String, padding: int = 12) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = frame_bg(season_id)
	box.set_corner_radius_all(12)
	box.set_content_margin_all(padding)
	box.set_border_width_all(1)
	box.border_color = border_color(season_id)
	return box
