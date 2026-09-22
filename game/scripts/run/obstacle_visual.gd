extends Node2D

## Prepreka — tijelo 176×150 + ovratnik. Kolizija ostaje 64×64 na roditelju.
## v1 motivi: stone i stump. Hay je u UiRun.obstacle_colors, ali se ne spawna.


func _ready() -> void:
	queue_redraw()


func _kind() -> String:
	var parent := get_parent()
	if parent != null and "kind" in parent:
		return str(parent.kind)
	return "stone"


func _draw() -> void:
	var body := UiRun.OBSTACLE_BODY
	var body_rect := Rect2(-body * 0.5, body)
	var collar := UiRun.OBSTACLE_COLLAR
	var collar_rect := Rect2(
		-collar.x * 0.5,
		body_rect.end.y - collar.y * 0.62,
		collar.x,
		collar.y
	)
	_draw_ellipse(collar_rect.get_center(), collar, UiRun.COLLAR)
	_draw_ellipse_outline(collar_rect.get_center(), collar * 0.5, UiRun.COLLAR_EDGE, 3.0)
	var colors: Array = UiRun.obstacle_colors(_kind())
	if _kind() == "stump":
		_draw_stump(body_rect, colors)
	else:
		_draw_stone(body_rect, colors)


func _draw_stone(body: Rect2, colors: Array) -> void:
	var fill: Color = colors[0]
	var edge: Color = colors[1]
	var light: Color = colors[2]
	var left := body.position.x
	var top := body.position.y
	var w := body.size.x
	var h := body.size.y
	var pts := PackedVector2Array([
		Vector2(left + w * 0.08, top + h * 0.30),
		Vector2(left + w * 0.24, top + h * 0.08),
		Vector2(left + w * 0.58, top + h * 0.02),
		Vector2(left + w * 0.90, top + h * 0.20),
		Vector2(left + w * 0.98, top + h * 0.52),
		Vector2(left + w, top + h),
		Vector2(left, top + h),
		Vector2(left + w * 0.02, top + h * 0.56),
	])
	draw_colored_polygon(pts, fill)
	var facet := PackedVector2Array([
		Vector2(left + w * 0.30, top + h * 0.24),
		Vector2(left + w * 0.55, top + h * 0.16),
		Vector2(left + w * 0.48, top + h * 0.40),
	])
	draw_colored_polygon(facet, light)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, edge, 4.0, true)


func _draw_stump(body: Rect2, colors: Array) -> void:
	var fill: Color = colors[0]
	var edge: Color = colors[1]
	var cap: Color = colors[2]
	var trunk := Rect2(body.position.x + 14.0, body.position.y + 28.0, body.size.x - 28.0, body.size.y - 28.0)
	draw_rect(trunk, fill, true)
	draw_rect(trunk, edge, false, 4.0)
	var cap_center := Vector2(body.position.x + body.size.x * 0.5, body.position.y + 34.0)
	var cap_size := Vector2(body.size.x * 0.92, 52.0)
	_draw_ellipse(cap_center, cap_size, cap)
	_draw_ellipse_outline(cap_center, cap_size * 0.5, edge, 3.0)
	draw_arc(cap_center, 22.0, 0.0, TAU, 24, UiRun.STUMP_RING, 3.0, true)
	draw_arc(cap_center, 10.0, 0.0, TAU, 16, UiRun.STUMP_RING, 2.0, true)


func _draw_ellipse(center: Vector2, size: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in 20:
		var a := TAU * float(i) / 20.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, color)


func _draw_ellipse_outline(center: Vector2, radius: Vector2, color: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var steps := 24
	for i in steps + 1:
		var a := TAU * float(i) / float(steps)
		pts.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_polyline(pts, color, width, true)
