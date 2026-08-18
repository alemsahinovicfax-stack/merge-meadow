extends Control

## Mini preview — T1 sprout, T2 bloom, T3 crystal (CampPlantDraw), fit-scaled for journal icons.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

@export var type_id: String = "clover"
@export var plant_tier: int = 0
@export var dim_locked: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	resized.connect(_on_resized)
	_on_resized()


func _on_resized() -> void:
	custom_minimum_size = Vector2(minf(size.x, size.y), minf(size.x, size.y))
	queue_redraw()


func apply(type: String, tier: int, locked: bool) -> void:
	type_id = type
	plant_tier = tier
	dim_locked = locked
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	var center := size * 0.5
	if dim_locked or plant_tier <= 0:
		draw_circle(center, side * 0.22, Color(0.55, 0.58, 0.55, 0.35))
		draw_arc(center, side * 0.22, 0.0, TAU, 24, Color(0.4, 0.42, 0.4, 0.5), 2.0)
		return
	PLANT_DRAW.draw_fitted_plant(self, center, type_id, plant_tier, side)
