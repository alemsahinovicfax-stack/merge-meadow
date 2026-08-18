extends Sprite2D

## Sjeme u runu — Album T1 sprout (CampPlantDraw), footprint ~starog seed-ball-a.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const RUN_SIDE := 56.0

var _type_id: String = "clover"


func _ready() -> void:
	texture = null
	centered = true
	var parent_pickup := get_parent()
	if parent_pickup != null and "type_id" in parent_pickup:
		_type_id = str(parent_pickup.type_id)
	queue_redraw()


func setup(type_id: String) -> void:
	_type_id = type_id
	texture = null
	queue_redraw()


func _draw() -> void:
	PLANT_DRAW.draw_fitted_plant(self, Vector2.ZERO, _type_id, 1, RUN_SIDE)
