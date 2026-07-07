class_name UiClickButton
extends PanelContainer

## Klikabilni panel — ne nasljeđuje BaseButton (Godot 4.7 lomi pressed/clicked na desktopu).

signal clicked

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")

@export var label_text: String = "":
	set(value):
		label_text = value
		_update_label()

@export var font_size: int = 32:
	set(value):
		font_size = value
		_update_label()

@export_enum("secondary", "primary", "accent", "subtle") var button_variant: String = "secondary":
	set(value):
		button_variant = value
		_build_styles()
		_apply_panel_style()

@export_enum("none", "play", "settings", "wallet", "retry", "home", "revive", "double") var button_icon: String = "none":
	set(value):
		button_icon = value
		_update_icon()

@export var use_play_icon: bool = false:
	set(value):
		use_play_icon = value
		_update_icon()

var disabled: bool = false:
	set(value):
		disabled = value
		_apply_disabled()

var _row: HBoxContainer
var _icon: TextureRect
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
	_ensure_content()
	_update_label()
	_update_icon()
	_apply_label_theme()
	_apply_panel_style()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func _build_styles() -> void:
	_style_normal = UI_PALETTE.button_style(button_variant, "normal")
	_style_hover = UI_PALETTE.button_style(button_variant, "hover")
	_style_pressed = UI_PALETTE.button_style(button_variant, "pressed")


func _apply_label_theme() -> void:
	if _label == null:
		return
	_label.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)


func _ensure_content() -> void:
	_row = get_node_or_null("ContentRow") as HBoxContainer
	if _row == null:
		var legacy_label := get_node_or_null("Label") as Label
		_row = HBoxContainer.new()
		_row.name = "ContentRow"
		_row.alignment = BoxContainer.ALIGNMENT_CENTER
		_row.add_theme_constant_override("separation", 12)
		_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if legacy_label:
			remove_child(legacy_label)
			_row.add_child(legacy_label)
		add_child(_row)

	_label = _row.get_node_or_null("Label") as Label
	if _label == null:
		_label = Label.new()
		_label.name = "Label"
		_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_row.add_child(_label)

	_icon = _row.get_node_or_null("Icon") as TextureRect
	if _icon == null:
		_icon = TextureRect.new()
		_icon.name = "Icon"
		_icon.visible = false
		_icon.custom_minimum_size = Vector2(UI_ASSETS.BUTTON_ICON_SIZE, UI_ASSETS.BUTTON_ICON_SIZE)
		_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_row.add_child(_icon)
		_row.move_child(_icon, 0)


func _update_label() -> void:
	if _label == null:
		return
	_label.text = label_text
	if font_size > 0:
		_label.add_theme_font_size_override("font_size", font_size)
	_apply_label_theme()


func _update_icon() -> void:
	if _icon == null:
		return
	var tex: Texture2D = null
	if use_play_icon or button_icon == "play":
		tex = UI_ASSETS.get_play_icon()
	elif button_icon != "none":
		tex = UI_ASSETS.get_kenney_icon(button_icon)
	_icon.texture = tex
	_icon.visible = tex != null
	if tex != null:
		_icon.modulate = Color.WHITE if button_icon == "play" else UI_PALETTE.ICON_MODULATE


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
