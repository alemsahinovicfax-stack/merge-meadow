extends Control

## Home basket card icon — empty outline or T3 plant for the selected seed.

const CampPlantDraw := preload("res://scripts/visual/camp_plant_draw.gd")

var _type_id: String = ""
## v2: well je 70 px, portret 60 i ikona sjemena 56 (design_handoff_home_field_v2).
var _plant_ratio: float = 0.86
var _icon_ratio: float = 0.80


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
		var seed_tex := UiAssets.get_chrome_icon("icon_seed")
		if seed_tex:
			var art := side * _icon_ratio
			draw_texture_rect(seed_tex, Rect2(center - Vector2(art, art) * 0.5, Vector2(art, art)), false)
		else:
			_draw_empty_basket(center, side)
		return
	CampPlantDraw.draw_fitted_plant(self, center, _type_id, 3, side * _plant_ratio)


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
