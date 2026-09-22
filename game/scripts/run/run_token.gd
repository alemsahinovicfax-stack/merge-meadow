extends Node2D

## Fail spill — vizualni token, bez kolizije i bez uticaja na loot.


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0, 10), 10.0, Color(0.071, 0.110, 0.086, 0.25))
	draw_circle(Vector2.ZERO, 16.0, UiRun.COIN_FILL)
	draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 20, UiRun.COIN_EDGE, 3.0, true)
