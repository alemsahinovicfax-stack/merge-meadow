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
	# Senka = pilula 56 % x 17 %, 2 px od dna (FieldScreen.dc.html · shade).
	var sh := Vector2(roundf(size.x * 0.56), roundf(size.y * 0.17))
	var shadow := Rect2(Vector2((size.x - sh.x) * 0.5, size.y - 2.0 - sh.y), sh)
	draw_style_box(UiStage.box(UiHomeField.FLOWER_SHADOW, roundi(sh.y * 0.5)), shadow)
	PLANT_DRAW.draw_fitted_plant(self, size * 0.5, type_id, plant_tier, _side)
