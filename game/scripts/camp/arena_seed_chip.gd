class_name ArenaSeedChip
extends Control

## Sjeme u merge areni — T1/T2, drag + magnet snap merge.

signal drag_started(chip: ArenaSeedChip)
signal drag_released(chip: ArenaSeedChip)

const CHIP_RADIUS := 48.0
const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

var chip_id: int = -1
var type_id: String = ""
var tier: int = 1

var _pulse_highlight: bool = false
var pulse_highlight: bool:
	set(value):
		if _pulse_highlight == value:
			return
		_pulse_highlight = value
		set_process(value)
		queue_redraw()
	get:
		return _pulse_highlight

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_start_global: Vector2 = Vector2.ZERO


func setup(id: int, seed_type: String, at: Vector2, seed_tier: int = 1) -> void:
	chip_id = id
	type_id = seed_type
	tier = seed_tier
	position = at - Vector2(CHIP_RADIUS, CHIP_RADIUS)
	custom_minimum_size = Vector2(CHIP_RADIUS * 2.0, CHIP_RADIUS * 2.0)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)
	queue_redraw()


func set_tier(new_tier: int) -> void:
	tier = new_tier
	queue_redraw()


func get_center() -> Vector2:
	return position + size * 0.5


func set_center(center: Vector2) -> void:
	position = center - size * 0.5


func is_dragging() -> bool:
	return _dragging


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_drag(touch.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _dragging:
			global_position = drag.position - _drag_offset
		accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_begin_drag(mouse.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset


func _begin_drag(local_pos: Vector2) -> void:
	_dragging = true
	_drag_offset = local_pos
	_drag_start_global = get_global_mouse_position()
	z_index = 10
	drag_started.emit(self)


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	z_index = 0
	drag_released.emit(self)


func _process(_delta: float) -> void:
	if pulse_highlight:
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	if tier >= 2:
		draw_set_transform(center + Vector2(0.0, 10.0), 0.0, Vector2(0.88, 0.88))
		PLANT_DRAW.draw_plant(self, Vector2.ZERO, type_id, tier)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		var fit_frac := PLANT_DRAW.FIT_FRAC
		if GameState.is_mythic_seed(type_id):
			fit_frac = 0.30
		PLANT_DRAW.draw_fitted_plant(
			self, center, type_id, 1, CHIP_RADIUS * 2.0, fit_frac
		)
	draw_arc(center, CHIP_RADIUS, 0.0, TAU, 32, Color(0.2, 0.28, 0.22, 0.35), 2.0)
	if pulse_highlight:
		var pulse := 0.45 + 0.35 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012))
		draw_arc(center, CHIP_RADIUS + 6.0, 0.0, TAU, 32, Color(0.95, 0.85, 0.25, pulse), 4.0)
	if tier >= 2:
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-14.0, CHIP_RADIUS + 14.0),
			"T%d" % tier,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			16,
			Color(0.25, 0.38, 0.28, 0.9)
		)
