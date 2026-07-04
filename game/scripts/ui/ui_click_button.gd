class_name UiClickButton
extends PanelContainer

## Klikabilni panel — ne nasljeđuje BaseButton (Godot 4.7 lomi pressed/clicked na desktopu).

signal clicked

@export var label_text: String = "":
	set(value):
		label_text = value
		_update_label()

@export var font_size: int = 32:
	set(value):
		font_size = value
		_update_label()

var disabled: bool = false:
	set(value):
		disabled = value
		_apply_disabled()


var _label: Label
var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_pressed: StyleBoxFlat
var _hovering: bool = false
var _pressing: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE
	_build_styles()
	_ensure_label()
	_update_label()
	_apply_panel_style()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func _build_styles() -> void:
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = Color(0.22, 0.28, 0.34, 1.0)
	_style_normal.corner_radius_top_left = 12
	_style_normal.corner_radius_top_right = 12
	_style_normal.corner_radius_bottom_right = 12
	_style_normal.corner_radius_bottom_left = 12
	_style_normal.content_margin_left = 16.0
	_style_normal.content_margin_top = 12.0
	_style_normal.content_margin_right = 16.0
	_style_normal.content_margin_bottom = 12.0

	_style_hover = _style_normal.duplicate() as StyleBoxFlat
	_style_hover.bg_color = Color(0.28, 0.36, 0.44, 1.0)

	_style_pressed = _style_hover.duplicate() as StyleBoxFlat
	_style_pressed.bg_color = Color(0.18, 0.24, 0.30, 1.0)


func _ensure_label() -> void:
	_label = get_node_or_null("Label") as Label
	if _label == null:
		_label = Label.new()
		_label.name = "Label"
		_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(_label)


func _update_label() -> void:
	if _label == null:
		return
	_label.text = label_text
	if font_size > 0:
		_label.add_theme_font_size_override("font_size", font_size)


func _apply_disabled() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	modulate = Color(1.0, 1.0, 1.0, 0.45) if disabled else Color.WHITE
	_apply_panel_style()


func _apply_panel_style() -> void:
	if disabled:
		add_theme_stylebox_override("panel", _style_normal)
	elif _pressing:
		add_theme_stylebox_override("panel", _style_pressed)
	elif _hovering:
		add_theme_stylebox_override("panel", _style_hover)
	else:
		add_theme_stylebox_override("panel", _style_normal)


func _on_mouse_entered() -> void:
	if disabled:
		return
	_hovering = true
	_apply_panel_style()


func _on_mouse_exited() -> void:
	_hovering = false
	_pressing = false
	_apply_panel_style()


func _on_gui_input(event: InputEvent) -> void:
	if disabled:
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_pressing = true
			_apply_panel_style()
		else:
			if _pressing:
				clicked.emit()
			_pressing = false
			_apply_panel_style()
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_pressing = true
			_apply_panel_style()
			clicked.emit()
		else:
			_pressing = false
			_apply_panel_style()
		accept_event()
