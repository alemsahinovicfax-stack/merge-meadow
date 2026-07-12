extends Sprite2D

## Sjeme u runu — proceduralno po tipu (7 distinct vizuala).

const CONFIG := preload("res://scripts/visual/seed_visual_config.gd")

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
	CONFIG.draw_run_seed(self, _type_id)
