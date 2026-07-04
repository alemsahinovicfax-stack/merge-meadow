extends Node2D

## Clover ★ sjeme — placeholder vizual.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 22.0, Color(0.45, 0.78, 0.42, 1.0))
	draw_circle(Vector2(-10.0, -8.0), 10.0, Color(0.55, 0.85, 0.5, 1.0))
	draw_circle(Vector2(10.0, -8.0), 10.0, Color(0.55, 0.85, 0.5, 1.0))
	draw_circle(Vector2(0.0, 10.0), 10.0, Color(0.55, 0.85, 0.5, 1.0))
	draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color(0.3, 0.55, 0.32, 0.9), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(-6.0, -26.0), "★", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.92, 0.5, 1.0))
