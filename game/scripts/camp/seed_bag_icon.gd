extends Control

## Icon half of SeedBagChip — procedural run seed art.

const CONFIG := preload("res://scripts/visual/seed_visual_config.gd")

var type_id: String = "clover"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(48, 48)
	resized.connect(queue_redraw)


func setup(seed_type: String) -> void:
	type_id = seed_type
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	var scale := (side * 0.42) / 22.0
	draw_set_transform(size * 0.5, 0.0, Vector2(scale, scale))
	CONFIG.draw_run_seed(self, type_id)
