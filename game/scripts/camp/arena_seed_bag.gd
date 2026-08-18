class_name ArenaSeedBag
extends Control

## Donja vrećica — otvorena + wiggle kad ima ≥2 sjemena; klik izbacuje sjeme u arenu.

signal bag_clicked

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const BAG_SIZE := Vector2(160, 130)
const DRAW_SCALE := 1.35

var _open: bool = false
var _seed_count: int = 0
var _preview_types: Array[String] = []
var _wiggle_t: float = 0.0
var _can_pour: bool = false
var _base_position: Vector2 = Vector2.ZERO


func set_layout_position(base: Vector2) -> void:
	_base_position = base
	position = _base_position


func set_state(seed_count: int, can_pour: bool, preview_types: Array) -> void:
	_seed_count = seed_count
	_can_pour = can_pour
	_open = seed_count >= 2
	_preview_types.clear()
	for t in preview_types:
		_preview_types.append(str(t))
	visible = true
	mouse_filter = (
		Control.MOUSE_FILTER_STOP if seed_count > 0
		else Control.MOUSE_FILTER_IGNORE
	)
	queue_redraw()


func _ready() -> void:
	custom_minimum_size = BAG_SIZE
	size = BAG_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	gui_input.connect(_on_gui_input)


func _process(delta: float) -> void:
	if not _open:
		rotation = 0.0
		position = _base_position
		return
	_wiggle_t += delta * 5.5
	rotation = sin(_wiggle_t) * 0.05
	position = _base_position + Vector2(0.0, sin(_wiggle_t * 1.7) * 4.0)
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if _seed_count <= 0:
		return
	if SceneRouter.is_input_blocked():
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed:
			bag_clicked.emit()
			accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed:
			bag_clicked.emit()
			accept_event()


func _draw() -> void:
	var s := DRAW_SCALE
	var cx := size.x * 0.5
	var base_y := size.y - 10.0
	var sack := Color(0.62, 0.48, 0.32, 1.0)
	var sack_dark := Color(0.45, 0.34, 0.22, 1.0)
	var lip := Color(0.72, 0.58, 0.4, 1.0)

	if _seed_count <= 0:
		draw_line(Vector2(cx - 28 * s, base_y - 6 * s), Vector2(cx + 28 * s, base_y - 6 * s), sack_dark, 5.0)
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 30 * s, base_y - 4 * s),
				Vector2(cx + 30 * s, base_y - 4 * s),
				Vector2(cx + 24 * s, base_y + 22 * s),
				Vector2(cx - 24 * s, base_y + 22 * s),
			]),
			sack
		)
		return

	if _open:
		draw_arc(Vector2(cx, base_y - 26 * s), 30.0 * s, PI, TAU, 24, lip, 7.0)
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 30 * s, base_y - 20 * s),
				Vector2(cx + 30 * s, base_y - 20 * s),
				Vector2(cx + 36 * s, base_y + 24 * s),
				Vector2(cx - 36 * s, base_y + 24 * s),
			]),
			sack
		)
		var peek := mini(_preview_types.size(), 3)
		for i in peek:
			var offset := Vector2(-24.0 * s + float(i) * 24.0 * s, -42.0 * s - float(i % 2) * 8.0)
			var type_id := _preview_types[i] if i < _preview_types.size() else "clover"
			PLANT_DRAW.draw_fitted_plant(
				self, Vector2(cx, base_y) + offset, type_id, 1, 40.0 * s
			)
	else:
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(cx - 32 * s, base_y - 32 * s),
				Vector2(cx + 32 * s, base_y - 32 * s),
				Vector2(cx + 34 * s, base_y + 22 * s),
				Vector2(cx - 34 * s, base_y + 22 * s),
			]),
			sack
		)
		draw_arc(Vector2(cx, base_y - 30 * s), 28.0 * s, PI, TAU, 20, sack_dark, 6.0)

	if _seed_count > 0:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(cx - 10.0, base_y + 18.0 * s),
			str(_seed_count),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			22,
			Color(1.0, 0.98, 0.9, 0.95)
		)
