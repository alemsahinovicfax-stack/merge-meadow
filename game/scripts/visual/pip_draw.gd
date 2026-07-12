class_name PipDraw
extends RefCounted

## Placeholder Pip (zeko) — proceduralni crtaj dok nema final spritea.
## Isti izgled u runu, main menuu i HUD-u.

const BODY := Color(0.95, 0.98, 0.92, 1.0)
const EAR := Color(0.82, 0.94, 0.78, 1.0)
const EAR_INNER := Color(1.0, 0.82, 0.86, 1.0)
const OUTLINE := Color(0.35, 0.55, 0.4, 0.9)
const EYE := Color(0.2, 0.25, 0.22, 1.0)
const NOSE := Color(1.0, 0.55, 0.62, 1.0)


static func draw_pip(canvas: CanvasItem, center: Vector2, scale: float = 1.0) -> void:
	var palette := _resolve_palette()
	var body: Color = palette.get("body", BODY)
	var ear: Color = palette.get("ear", EAR)
	var ear_inner: Color = palette.get("ear_inner", EAR_INNER)
	var outline: Color = palette.get("outline", OUTLINE)
	var s := scale
	var body_r := 22.0 * s
	var body_center := center + Vector2(0.0, 4.0 * s)

	canvas.draw_circle(center + Vector2(-14.0 * s, -18.0 * s), 10.0 * s, ear)
	canvas.draw_circle(center + Vector2(14.0 * s, -18.0 * s), 10.0 * s, ear)
	canvas.draw_circle(center + Vector2(-14.0 * s, -18.0 * s), 5.5 * s, ear_inner)
	canvas.draw_circle(center + Vector2(14.0 * s, -18.0 * s), 5.5 * s, ear_inner)

	canvas.draw_circle(body_center, body_r, body)
	canvas.draw_arc(body_center, body_r, 0.0, TAU, 32, outline, 2.0 * s)

	canvas.draw_circle(center + Vector2(-8.0 * s, -2.0 * s), 3.0 * s, EYE)
	canvas.draw_circle(center + Vector2(8.0 * s, -2.0 * s), 3.0 * s, EYE)
	canvas.draw_circle(center + Vector2(0.0, 6.0 * s), 3.5 * s, NOSE)


static func _resolve_palette() -> Dictionary:
	var skin_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_PIP_SKIN)
	if skin_id.is_empty():
		return {}
	return CosmeticCatalog.get_pip_palette(skin_id)
