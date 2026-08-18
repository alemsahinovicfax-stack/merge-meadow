extends Control

## T3 flower preview for CrystalStashChip (CampPlantDraw fitted).

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

var type_id: String = "clover"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(48, 48)
	resized.connect(queue_redraw)


func setup(crystal_type: String) -> void:
	type_id = crystal_type
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	PLANT_DRAW.draw_fitted_plant(self, size * 0.5, type_id, 3, side)
