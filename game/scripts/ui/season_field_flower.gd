class_name SeasonFieldFlower
extends Control

## HOME-12 B — decorative meadow bloom. IGNORE; not an arena chip.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const FLOWER_SIDE := 76.0

var type_id: String = ""
var plant_tier: int = 3


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	custom_minimum_size = Vector2(FLOWER_SIDE, FLOWER_SIDE)
	size = custom_minimum_size


func setup(seed_type: String, tier: int) -> void:
	type_id = seed_type
	plant_tier = 3
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	custom_minimum_size = Vector2(FLOWER_SIDE, FLOWER_SIDE)
	size = custom_minimum_size
	add_to_group("meadow_flower")
	queue_redraw()


func _draw() -> void:
	if type_id.is_empty() or plant_tier <= 0:
		return
	PLANT_DRAW.draw_fitted_plant(self, size * 0.5, type_id, plant_tier, FLOWER_SIDE)
