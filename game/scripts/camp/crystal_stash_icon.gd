extends Control

## T3 crystal preview for CrystalStashChip (CampPlantDraw).

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
	var center := size * 0.5
	PLANT_DRAW.draw_plant(self, center + Vector2(0.0, side * 0.08), type_id, 3)
