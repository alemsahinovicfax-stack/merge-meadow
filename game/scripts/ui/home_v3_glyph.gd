class_name HomeV3Glyph
extends Control

## Mali crtani znakovi donjeg reda polja (FieldScreen.dc.html):
## "chevron" — Seasons: kvadrat 18 + rub 7 lijevo/dolje, rotiran 45°, margin-left 8;
## "rings"   — Endless: dva prstena 30 (rub 6), drugi preklopljen 6 px.

@export var kind: String = "chevron"


func _init(k: String = "chevron") -> void:
	kind = k
	name = "Glyph"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(33, 25) if kind == "chevron" else Vector2(54, 30)


func _draw() -> void:
	var ink := UiHomeV3.INK
	if kind == "chevron":
		UiHomeV3.draw_chevron(self, Vector2(8.0 + 12.5, size.y * 0.5), 18.0, 7.0, true, ink)
		return
	var cy := size.y * 0.5
	for cx in [15.0, 39.0]:
		draw_arc(Vector2(cx, cy), 12.0, 0.0, TAU, 48, ink, 6.0, true)
