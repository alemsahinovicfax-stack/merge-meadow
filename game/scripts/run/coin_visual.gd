extends Sprite2D

## Novčić u runu — placeholder krug 96 px. Kolizija ostaje r 18 na roditelju.

var _phase: float = 0.0


func _ready() -> void:
	texture = null
	centered = true
	_phase = randf() * TAU
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta * 2.6
	position.y = sin(_phase) * 5.0


func _draw() -> void:
	_draw_shadow()
	var radius := float(UiRun.COIN_SIZE) * 0.5
	draw_circle(Vector2.ZERO, radius, UiRun.COIN_FILL)
	draw_arc(Vector2.ZERO, radius - 2.0, 0.0, TAU, 40, UiRun.COIN_EDGE, 5.0, true)
	draw_circle(Vector2.ZERO, radius * 0.62, UiRun.COIN_INNER)
	draw_circle(Vector2(-14, -16), 8.0, UiRun.COIN_GLINT)


func _draw_shadow() -> void:
	var size := UiRun.PICKUP_SHADOW_SIZE
	var center := Vector2(0.0, float(UiRun.PICKUP_SHADOW_OFFSET))
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, UiRun.PICKUP_SHADOW)
