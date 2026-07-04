extends Node2D

## Vizual novčića u runu (Node2D _draw).


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 16.0, Color(1.0, 0.82, 0.2, 1.0))
	draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 24, Color(0.85, 0.6, 0.05, 1.0), 2.5)
	draw_circle(Vector2(-4.0, -5.0), 4.0, Color(1.0, 1.0, 0.85, 0.5))
