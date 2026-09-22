extends Node2D

## Jedan prsten (pickup burst ili finish). Skala nodea je radijus.

var ring_color: Color = Color(1, 0.973, 0.941, 0.9)
var ring_width: float = 6.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, 1.0, 0.0, TAU, 48, ring_color, ring_width, true)
