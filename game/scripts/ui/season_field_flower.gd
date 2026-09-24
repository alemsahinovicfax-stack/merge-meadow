class_name SeasonFieldFlower
extends Control

## Decorative meadow bloom. IGNORE; not an arena chip.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

var type_id: String = ""
var plant_tier: int = 3
var _side: float = 76.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	pivot_offset = size * 0.5


func setup_spot(seed_type: String, side: float, tier: int = 3) -> void:
	type_id = seed_type
	plant_tier = 3
	_side = maxf(side, 8.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	custom_minimum_size = Vector2(_side, _side)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	add_to_group("meadow_flower")
	queue_redraw()


func setup(seed_type: String, tier: int) -> void:
	setup_spot(seed_type, _side if _side > 8.0 else 76.0, tier)


func _draw() -> void:
	if type_id.is_empty() or plant_tier <= 0:
		return
	var shadow := Rect2(size * Vector2(0.22, 0.78), size * Vector2(0.56, 0.17))
	draw_rect(shadow, UiHomeField.FLOWER_SHADOW, true)
	PLANT_DRAW.draw_fitted_plant(self, size * 0.5, type_id, plant_tier, _side)
