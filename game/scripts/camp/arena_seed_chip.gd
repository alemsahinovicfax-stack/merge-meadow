class_name ArenaSeedChip
extends Control

## Sjeme u merge areni — T1/T2, drag + magnet snap merge.

signal drag_released(chip: ArenaSeedChip)
signal bloom_tapped(chip: ArenaSeedChip)

const CHIP_RADIUS := 48.0
const CONFIG := preload("res://scripts/visual/seed_visual_config.gd")
const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

var chip_id: int = -1
var type_id: String = ""
var tier: int = 1

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


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	z_index = 0
	var moved := _drag_start_global.distance_to(get_global_mouse_position())
	if tier >= 2 and moved < 14.0:
		bloom_tapped.emit(self)
	drag_released.emit(self)


func _draw() -> void:
	var center := size * 0.5
	var draw_scale := 1.12
	if GameState.is_mythic_seed(type_id) and tier <= 1:
		draw_scale = 0.92
	if tier >= 2:
		draw_set_transform(center + Vector2(0.0, 10.0), 0.0, Vector2(0.88, 0.88))
		PLANT_DRAW.draw_plant(self, Vector2.ZERO, type_id, tier)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_set_transform(center, 0.0, Vector2(draw_scale, draw_scale))
		CONFIG.draw_run_seed(self, type_id)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(center, CHIP_RADIUS, 0.0, TAU, 32, Color(0.2, 0.28, 0.22, 0.35), 2.0)
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
