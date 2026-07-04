extends Node2D

## Pip u runu — Node2D _draw (pouzdanije od Area2D _draw).

const PIP_DRAW := preload("res://scripts/visual/pip_draw.gd")
const MAGNET_DRAW_THRESHOLD := 50.0

var _magnet_radius: float = 0.0


func _ready() -> void:
	z_index = 10
	queue_redraw()


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	queue_redraw()


func _draw() -> void:
	PIP_DRAW.draw_pip(self, Vector2.ZERO, 1.0)
	if _magnet_radius > MAGNET_DRAW_THRESHOLD:
		draw_arc(Vector2.ZERO, _magnet_radius, 0.0, TAU, 48, Color(0.5, 0.8, 1.0, 0.25), 3.0)
