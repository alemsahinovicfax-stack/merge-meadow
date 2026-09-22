extends Sprite2D

## Diamond pickup — placeholder 88 px. Kolizija ostaje r 18.

var _phase: float = 0.0


func _ready() -> void:
	texture = null
	centered = true
	_phase = randf() * TAU
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta * 2.8
	position.y = sin(_phase) * 5.0


func _draw() -> void:
	_draw_shadow()
	var s := float(UiRun.DIAMOND_SIZE) * 0.5
	var pts := PackedVector2Array([
		Vector2(0, -s),
		Vector2(s * 0.72, -s * 0.12),
		Vector2(0, s),
		Vector2(-s * 0.72, -s * 0.12),
	])
	draw_colored_polygon(pts, UiRun.DIAMOND_FILL)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -s * 0.62),
		Vector2(s * 0.28, -s * 0.06),
		Vector2(0, s * 0.08),
		Vector2(-s * 0.22, -s * 0.10),
	]), UiRun.DIAMOND_FACET)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, UiRun.DIAMOND_EDGE, 4.0, true)


func _draw_shadow() -> void:
	var size := UiRun.PICKUP_SHADOW_SIZE
	var center := Vector2(0.0, float(UiRun.PICKUP_SHADOW_OFFSET))
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, UiRun.PICKUP_SHADOW)
