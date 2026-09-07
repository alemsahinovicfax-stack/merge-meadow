extends Control

## Picker row crystal — same CampPlantDraw T3 path as HomeBasketVisual.

const CampPlantDraw := preload("res://scripts/visual/camp_plant_draw.gd")

const ICON_SIDE := 72.0

var icon_side: float = ICON_SIDE:
	set(value):
		icon_side = maxf(value, 1.0)
		custom_minimum_size = Vector2(icon_side, icon_side)
		queue_redraw()

var type_id: String = "":
	set(value):
		type_id = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var existing := maxf(custom_minimum_size.x, custom_minimum_size.y)
	if existing > ICON_SIDE:
		icon_side = existing
	else:
		custom_minimum_size = Vector2(ICON_SIDE, ICON_SIDE)
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if type_id.is_empty():
		return
	var side := minf(size.x, size.y)
	CampPlantDraw.draw_fitted_plant(self, size * 0.5, type_id, 3, side)
