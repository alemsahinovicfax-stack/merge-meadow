extends Control

## Home basket card icon — empty outline or filled seed.

const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")

var _type_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func set_loadout_type(type_id: String) -> void:
	_type_id = type_id
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	var center := size * 0.5
	if _type_id.is_empty():
		_draw_empty_basket(center, side)
		return
	var tex := PICKUP_ASSETS.get_seed_texture(_type_id)
	var tint := PICKUP_ASSETS.get_seed_tint(_type_id)
	if tex != null:
		var display := side * 0.72
		var scale := display / maxf(tex.get_size().x, tex.get_size().y)
		var draw_size := tex.get_size() * scale
		var dest := Rect2(center - draw_size * 0.5, draw_size)
		draw_texture_rect(tex, dest, false, tint)
	else:
		draw_circle(center, side * 0.22, tint)
		draw_arc(center, side * 0.22, 0.0, TAU, 20, Color(0.2, 0.2, 0.2, 0.55), 2.0)


func _draw_empty_basket(center: Vector2, side: float) -> void:
	var w := side * 0.55
	var h := side * 0.42
	var top_y := center.y - h * 0.35
	var bot_y := center.y + h * 0.45
	var rim := Color(0.45, 0.28, 0.12, 1.0)
	var body := Color(0.72, 0.48, 0.28, 1.0)
	var pts := PackedVector2Array([
		Vector2(center.x - w * 0.55, top_y),
		Vector2(center.x + w * 0.55, top_y),
		Vector2(center.x + w * 0.42, bot_y),
		Vector2(center.x - w * 0.42, bot_y),
	])
	draw_colored_polygon(pts, body)
	draw_polyline(pts + PackedVector2Array([pts[0]]), rim, 2.5, true)
	# Open rim ellipse hint
	draw_arc(
		Vector2(center.x, top_y),
		w * 0.55,
		PI * 0.05,
		PI - PI * 0.05,
		16,
		rim,
		2.5
	)
	# Handle
	draw_arc(
		Vector2(center.x, top_y - side * 0.02),
		w * 0.28,
		PI * 1.05,
		PI * 1.95,
		12,
		rim,
		2.5
	)
