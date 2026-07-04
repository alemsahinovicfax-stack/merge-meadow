class_name CampPlantDraw
extends RefCounted

## Placeholder biljke u kamp gredicama — T1 sadnica, T2 cvijet.

const SOIL := Color(0.42, 0.28, 0.18, 1.0)
const SOIL_EDGE := Color(0.32, 0.2, 0.12, 0.9)
const STEM := Color(0.35, 0.62, 0.32, 1.0)
const LEAF := Color(0.45, 0.78, 0.42, 1.0)
const PETAL := Color(0.55, 0.85, 0.5, 1.0)
const FLOWER_CENTER := Color(1.0, 0.92, 0.5, 1.0)


static func draw_bed_soil(canvas: CanvasItem, rect: Rect2, selected: bool) -> void:
	canvas.draw_rect(rect, SOIL, true)
	canvas.draw_rect(rect, SOIL_EDGE, false, 3.0)
	if selected:
		canvas.draw_rect(rect.grow(4.0), Color(1.0, 1.0, 1.0, 0.85), false, 4.0)


static func draw_plant(canvas: CanvasItem, center: Vector2, type_id: String, tier: int) -> void:
	if tier <= 0:
		return
	match type_id:
		GameState.SEED_TYPE_CLOVER:
			_draw_clover(canvas, center, tier)
		_:
			_draw_clover(canvas, center, tier)


static func _draw_clover(canvas: CanvasItem, center: Vector2, tier: int) -> void:
	if tier == 1:
		canvas.draw_line(center + Vector2(0.0, 8.0), center + Vector2(0.0, 22.0), STEM, 4.0)
		canvas.draw_circle(center + Vector2(-8.0, 4.0), 7.0, LEAF)
		canvas.draw_circle(center + Vector2(8.0, 4.0), 7.0, LEAF)
		canvas.draw_circle(center + Vector2(0.0, -6.0), 7.0, LEAF)
	else:
		canvas.draw_line(center + Vector2(0.0, 10.0), center + Vector2(0.0, 26.0), STEM, 5.0)
		for offset in [Vector2(-14.0, -4.0), Vector2(14.0, -4.0), Vector2(0.0, -16.0)]:
			canvas.draw_circle(center + offset, 12.0, PETAL)
		canvas.draw_circle(center + Vector2(0.0, -6.0), 8.0, FLOWER_CENTER)
