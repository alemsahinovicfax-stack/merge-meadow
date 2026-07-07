class_name UiPalette
extends RefCounted

## Pastel UI paleta — docs/04-experience/art-direction.md

const MINT := Color("#A8E6CF")
const LAVENDER := Color("#D4A5FF")
const PEACH := Color("#FFB88C")
const WARM_WHITE := Color("#FFF8F0")
const OUTLINE := Color("#2D3436")
const UI_TEXT := Color("#4A4A4A")
const ICON_MODULATE := Color("#2D3436")

const CORNER_RADIUS := 12
const CORNER_RADIUS_PANEL := 20


static func button_style(variant: String, state: String) -> StyleBoxFlat:
	var bg := MINT
	match variant:
		"primary":
			bg = PEACH if state == "normal" else PEACH.lightened(0.07) if state == "hover" else PEACH.darkened(0.07)
		"accent":
			bg = LAVENDER if state == "normal" else LAVENDER.lightened(0.05) if state == "hover" else LAVENDER.darkened(0.05)
		"subtle":
			bg = WARM_WHITE if state == "normal" else Color("#FFFDF9") if state == "hover" else Color("#F5EDE0")
		_:
			bg = MINT if state == "normal" else MINT.lightened(0.05) if state == "hover" else MINT.darkened(0.06)

	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(CORNER_RADIUS)
	style.set_border_width_all(2)
	style.border_color = Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 0.14)
	if variant == "subtle":
		style.content_margin_left = 10.0
		style.content_margin_top = 10.0
		style.content_margin_right = 10.0
		style.content_margin_bottom = 10.0
	else:
		style.content_margin_left = 16.0
		style.content_margin_top = 12.0
		style.content_margin_right = 16.0
		style.content_margin_bottom = 12.0
	return style


static func panel_style(tint: String = "warm") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(CORNER_RADIUS_PANEL)
	style.set_border_width_all(2)
	style.border_color = Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, 0.12)
	style.content_margin_left = 32.0
	style.content_margin_top = 32.0
	style.content_margin_right = 32.0
	style.content_margin_bottom = 32.0
	match tint:
		"mint":
			style.bg_color = Color(MINT.r, MINT.g, MINT.b, 0.9)
		_:
			style.bg_color = Color(WARM_WHITE.r, WARM_WHITE.g, WARM_WHITE.b, 0.95)
	return style
