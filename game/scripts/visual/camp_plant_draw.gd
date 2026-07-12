class_name CampPlantDraw
extends RefCounted

## Biljke u kamp gredicama — T1 sadnica, T2 cvijet, T3 crystal po tipu.

const CONFIG := preload("res://scripts/visual/seed_visual_config.gd")

const SOIL := Color(0.42, 0.28, 0.18, 1.0)
const SOIL_EDGE := Color(0.32, 0.2, 0.12, 0.9)


static func draw_bed_soil(canvas: CanvasItem, rect: Rect2, selected: bool) -> void:
	canvas.draw_rect(rect, SOIL, true)
	canvas.draw_rect(rect, SOIL_EDGE, false, 3.0)
	if selected:
		canvas.draw_rect(rect.grow(4.0), Color(1.0, 1.0, 1.0, 0.85), false, 4.0)


static func draw_plant(canvas: CanvasItem, center: Vector2, type_id: String, tier: int) -> void:
	if tier <= 0:
		return
	if tier >= 3:
		_draw_crystal(canvas, center, type_id)
	elif tier == 2:
		_draw_bloom(canvas, center, type_id)
	else:
		_draw_sprout(canvas, center, type_id)


static func _pal(type_id: String) -> Dictionary:
	return CONFIG.palette(type_id)


static func _draw_sprout(canvas: CanvasItem, center: Vector2, type_id: String) -> void:
	var pal := _pal(type_id)
	canvas.draw_line(center + Vector2(0.0, 8.0), center + Vector2(0.0, 22.0), CONFIG.STEM, 4.0)
	match type_id:
		"clover":
			canvas.draw_circle(center + Vector2(-8.0, 4.0), 7.0, CONFIG.LEAF)
			canvas.draw_circle(center + Vector2(8.0, 4.0), 7.0, CONFIG.LEAF)
			canvas.draw_circle(center + Vector2(0.0, -6.0), 7.0, CONFIG.LEAF)
		"daisy", "buttercup":
			canvas.draw_circle(center + Vector2(-6.0, 2.0), 5.0, pal.petal)
			canvas.draw_circle(center + Vector2(6.0, 2.0), 5.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -8.0), 6.0, pal.center)
		"tulip":
			canvas.draw_circle(center + Vector2(0.0, -4.0), 8.0, pal.seed)
		"sunflower":
			canvas.draw_circle(center + Vector2(0.0, -6.0), 9.0, pal.center)
			for i in 4:
				var a := float(i) / 4.0 * TAU
				canvas.draw_circle(center + Vector2(cos(a), sin(a)) * 10.0, 4.0, pal.petal)
		"pumpkin":
			canvas.draw_circle(center + Vector2(0.0, 0.0), 9.0, pal.seed)
			canvas.draw_line(center + Vector2(0.0, -10.0), center + Vector2(0.0, -4.0), CONFIG.STEM, 3.0)
		"watermelon":
			canvas.draw_circle(center + Vector2(0.0, 0.0), 10.0, pal.petal)
			canvas.draw_line(center + Vector2(-8.0, 0.0), center + Vector2(8.0, 0.0), Color(0.15, 0.35, 0.18), 2.0)
		_:
			canvas.draw_circle(center + Vector2(0.0, -4.0), 7.0, pal.seed)


static func _draw_bloom(canvas: CanvasItem, center: Vector2, type_id: String) -> void:
	var pal := _pal(type_id)
	canvas.draw_line(center + Vector2(0.0, 10.0), center + Vector2(0.0, 26.0), CONFIG.STEM, 5.0)
	match type_id:
		"clover":
			for offset in [Vector2(-14.0, -4.0), Vector2(14.0, -4.0), Vector2(0.0, -16.0)]:
				canvas.draw_circle(center + offset, 12.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -6.0), 8.0, pal.center)
		"daisy":
			for i in 8:
				var a := float(i) / 8.0 * TAU
				canvas.draw_circle(center + Vector2(cos(a), sin(a)) * 14.0 + Vector2(0, -6), 7.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -6.0), 9.0, pal.center)
		"buttercup":
			for i in 5:
				var a := float(i) / 5.0 * TAU - PI / 2.0
				canvas.draw_circle(center + Vector2(cos(a), sin(a)) * 13.0 + Vector2(0, -4), 8.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -4.0), 7.0, pal.center)
		"tulip":
			canvas.draw_circle(center + Vector2(0.0, -6.0), 14.0, pal.petal)
			canvas.draw_circle(center + Vector2(-9.0, 0.0), 9.0, pal.petal.darkened(0.06))
			canvas.draw_circle(center + Vector2(9.0, 0.0), 9.0, pal.petal.darkened(0.06))
		"sunflower":
			for i in 10:
				var a := float(i) / 10.0 * TAU
				canvas.draw_circle(center + Vector2(cos(a), sin(a)) * 16.0 + Vector2(0, -8), 5.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -8.0), 11.0, pal.center)
		"pumpkin":
			canvas.draw_circle(center + Vector2(0.0, -2.0), 16.0, pal.petal)
			canvas.draw_line(center + Vector2(0.0, -20.0), center + Vector2(0.0, -8.0), CONFIG.STEM, 4.0)
			canvas.draw_circle(center + Vector2(0.0, -22.0), 5.0, CONFIG.LEAF)
		"watermelon":
			canvas.draw_circle(center + Vector2(0.0, -4.0), 17.0, pal.petal)
			canvas.draw_line(center + Vector2(-15.0, -4.0), center + Vector2(15.0, -4.0), Color(0.12, 0.32, 0.15), 3.0)
			canvas.draw_arc(center + Vector2(0.0, -2.0), 9.0, 0.0, PI, 14, pal.center, 10.0)
		_:
			for offset in [Vector2(-14.0, -4.0), Vector2(14.0, -4.0), Vector2(0.0, -16.0)]:
				canvas.draw_circle(center + offset, 12.0, pal.petal)
			canvas.draw_circle(center + Vector2(0.0, -6.0), 8.0, pal.center)


static func _draw_crystal(canvas: CanvasItem, center: Vector2, type_id: String) -> void:
	var crystal: Color = _pal(type_id).crystal
	canvas.draw_line(center + Vector2(0.0, 12.0), center + Vector2(0.0, 28.0), CONFIG.STEM, 5.0)
	for offset in [Vector2(-16.0, -6.0), Vector2(16.0, -6.0), Vector2(0.0, -18.0), Vector2(0.0, 6.0)]:
		canvas.draw_circle(center + offset, 10.0, crystal)
	canvas.draw_circle(center + Vector2(0.0, -8.0), 10.0, Color(1.0, 0.95, 0.75, 1.0))
	canvas.draw_arc(center + Vector2(0.0, -8.0), 14.0, 0.0, TAU, 24, crystal.lightened(0.2), 3.0)
