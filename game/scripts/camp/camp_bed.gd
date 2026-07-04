class_name CampBed
extends PanelContainer

signal bed_tapped(index: int)

var bed_index: int = -1
var _in_greenhouse: bool = false
var _type_id: String = ""
var _tier: int = 0
var _selected: bool = false
var _highlighted: bool = false
var _pressing: bool = false


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(140, 120)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty)
	gui_input.connect(_on_gui_input)


func setup(index: int, in_greenhouse: bool) -> void:
	bed_index = index
	_in_greenhouse = in_greenhouse


func set_bed_state(type_id: String, tier: int, selected: bool, in_greenhouse: bool) -> void:
	_type_id = type_id
	_tier = tier
	_selected = selected
	_in_greenhouse = in_greenhouse
	queue_redraw()


func set_highlighted(on: bool) -> void:
	_highlighted = on
	queue_redraw()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_pressing = true
		else:
			if _pressing:
				bed_tapped.emit(bed_index)
			_pressing = false
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			bed_tapped.emit(bed_index)
		accept_event()


func _draw() -> void:
	var rect := Rect2(Vector2(4.0, 4.0), size - Vector2(8.0, 8.0))
	if _in_greenhouse:
		draw_rect(rect, Color(0.15, 0.22, 0.28, 0.95), true)
		draw_rect(rect, Color(0.5, 0.75, 0.95, 0.6), false, 2.0)
	else:
		CampPlantDraw.draw_bed_soil(self, rect, _selected)
	if _highlighted and _tier == 0:
		draw_rect(rect.grow(6.0), Color(1.0, 0.92, 0.35, 0.95), false, 4.0)
	if _selected and _in_greenhouse:
		draw_rect(rect.grow(3.0), Color(0.7, 0.9, 1.0, 0.9), false, 3.0)
	if _tier > 0:
		var center := rect.position + rect.size * 0.5 + Vector2(0.0, 8.0)
		CampPlantDraw.draw_plant(self, center, _type_id, _tier)
