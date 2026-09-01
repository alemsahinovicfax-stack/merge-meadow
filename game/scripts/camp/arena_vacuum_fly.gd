class_name ArenaVacuumFly
extends Control

## Visual-only leftover seed flying into the bag. Not an ArenaSeedChip.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const CHIP_RADIUS := 48.0

var type_id: String = ""
var tier: int = 1


func setup(seed_type: String, seed_tier: int, center: Vector2) -> void:
	type_id = seed_type
	tier = seed_tier
	name = "VacuumFly"
	custom_minimum_size = Vector2(CHIP_RADIUS * 2.0, CHIP_RADIUS * 2.0)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	position = center - size * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 60
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	if tier >= 2:
		draw_set_transform(center + Vector2(0.0, 10.0), 0.0, Vector2(0.88, 0.88))
		PLANT_DRAW.draw_plant(self, Vector2.ZERO, type_id, tier)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		var fit_frac := PLANT_DRAW.FIT_FRAC
		if GameState.is_mythic_seed(type_id):
			fit_frac = 0.30
		PLANT_DRAW.draw_fitted_plant(
			self, center, type_id, 1, CHIP_RADIUS * 2.0, fit_frac
		)
	draw_arc(center, CHIP_RADIUS, 0.0, TAU, 32, Color(0.2, 0.28, 0.22, 0.35), 2.0)
	if tier >= 2:
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-14.0, CHIP_RADIUS + 14.0),
			"T%d" % tier,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16,
			Color(0.25, 0.38, 0.28, 0.9)
		)
