@tool
class_name UiClickButton
extends PanelContainer

## Klikabilni panel — ne nasljeđuje BaseButton (Godot 4.7 lomi pressed/clicked na desktopu).

signal clicked
signal press_ended
## Hold je zaustavljen guardom (`repeat_guard`); pritisak traje do otpuštanja.
signal repeat_blocked

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")

@export var label_text: String = "":
	set(value):
		label_text = value
		_update_label()

@export var font_size: int = 32:
	set(value):
		font_size = value
		_update_label()

@export_enum("secondary", "primary", "accent", "subtle", "gold", "price", "cta") var button_variant: String = "secondary":
	set(value):
		button_variant = value
		_build_styles()
		_apply_panel_style()
		_apply_label_theme()

@export_enum("none", "play", "settings", "wallet", "retry", "home", "revive", "double") var button_icon: String = "none":
	set(value):
		button_icon = value
		_update_icon()

@export var use_play_icon: bool = false:
	set(value):
		use_play_icon = value
		_update_icon()

@export var label_autowrap: bool = false:
	set(value):
		label_autowrap = value
		_apply_label_layout()

## Identifikator za UiClickGuard log / debounce (postavi u editoru).
@export var click_action_id: String = ""

## Ako je postavljeno, guarded klik otvara scenu preko UiClickGuard (bez ručnog handlera).
@export_file("*.tscn") var navigation_scene: String = ""

@export var guarded_click: bool = false

## Drži-za-ponavljanje: tap = 1 klik, držanje = auto_repeat_rate klikova u sekundi.
@export var auto_repeat: bool = false
@export var auto_repeat_delay: float = 0.35
@export var auto_repeat_rate: float = 6.0

## Kad je disabled: providna ispuna umjesto zatamnjenja cijelog dugmeta.
@export var ghost_when_disabled: bool = false

## Pita se prije svakog auto-tika (ne prije prvog klika). `false` zaustavlja
## ponavljanje do kraja ovog pritiska — tap ide netaknut.
var repeat_guard: Callable = Callable()
## `true` dok traje emit klika koji je došao iz auto-repeat-a.
var last_click_was_repeat: bool = false

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
var _style_ghost: StyleBoxFlat
var _hovering: bool = false
var _pressing: bool = false
var _repeat_active: bool = false
var _repeat_touch: bool = false
var _repeat_delay_left: float = 0.0
var _repeat_accum: float = 0.0
var _repeat_blocked: bool = false


func _ready() -> void:
	set_process(false)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE
	_build_styles()
	_ensure_content()
	_apply_label_layout()
	_update_label()
	_update_icon()
	_apply_label_theme()
	_apply_panel_style()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func _notification(what: int) -> void:
	if Engine.is_editor_hint() and what == NOTIFICATION_ENTER_TREE:
		call_deferred("_validate_in_editor")
		return
	match what:
		NOTIFICATION_EXIT_TREE, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			end_press()


func _validate_in_editor() -> void:
	if not Engine.is_editor_hint():
		return
	var guard := get_node_or_null("/root/UiClickGuard")
	if guard == null:
		return
	for issue in guard.validate_button_exports(self):
		push_warning("UiClickButton %s: %s" % [name, issue])


func _build_styles() -> void:
	_style_normal = UI_PALETTE.button_style(button_variant, "normal")
	_style_hover = UI_PALETTE.button_style(button_variant, "hover")
	_style_pressed = UI_PALETTE.button_style(button_variant, "pressed")
	_style_ghost = UI_PALETTE.button_style(button_variant, "normal")
	_style_ghost.bg_color = Color(
		_style_ghost.bg_color.r, _style_ghost.bg_color.g, _style_ghost.bg_color.b, 0.0
	)


func _apply_label_theme() -> void:
	if _label == null:
		return
	var ink := UI_PALETTE.UI_TEXT
	if button_variant == "gold":
		ink = UI_PALETTE.GOLD_INK
	elif button_variant == "cta":
		ink = UI_PALETTE.OUTLINE
	_label.add_theme_color_override("font_color", ink)


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
		_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if legacy_label:
			legacy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_row.add_child(_label)

	_icon = _row.get_node_or_null("Icon") as TextureRect
	if _icon == null:
		_icon = TextureRect.new()
		_icon.name = "Icon"
		_icon.visible = false
		_icon.custom_minimum_size = Vector2(UI_ASSETS.BUTTON_ICON_SIZE, UI_ASSETS.BUTTON_ICON_SIZE)
		_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_row.add_child(_icon)
		_row.move_child(_icon, 0)

	if _row:
		_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _label:
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _icon:
		_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _apply_label_layout() -> void:
	if _label == null:
		return
	if label_autowrap:
		_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	else:
		_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func _update_label() -> void:
	if _label == null:
		return
	_label.text = label_text
	if font_size > 0:
		_label.add_theme_font_size_override("font_size", READABILITY.font(font_size))
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
	# Dok traje hold input mora ostati na dugmetu, inače release nikad ne stigne.
	var block_input := disabled and not _repeat_active
	mouse_filter = Control.MOUSE_FILTER_IGNORE if block_input else Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	if disabled:
		modulate = Color(1.0, 1.0, 1.0, 0.6 if ghost_when_disabled else 0.45)
	else:
		modulate = Color.WHITE
	_apply_panel_style()


func begin_press(from_touch: bool = false) -> void:
	if disabled or SceneRouter.is_input_blocked() or _repeat_active:
		return
	_repeat_active = true
	_repeat_touch = from_touch
	_repeat_delay_left = auto_repeat_delay
	_repeat_accum = 0.0
	_repeat_blocked = false
	set_process(true)
	last_click_was_repeat = false
	_emit_clicked()


func end_press() -> void:
	if not _repeat_active:
		return
	_repeat_active = false
	_repeat_touch = false
	set_process(false)
	_apply_disabled()
	press_ended.emit()


func is_holding() -> bool:
	return _repeat_active


func is_repeat_blocked() -> bool:
	return _repeat_active and _repeat_blocked


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_tick_repeat(delta)


func _tick_repeat(delta: float) -> void:
	if not _repeat_active:
		return
	if disabled or not is_inside_tree() or not is_visible_in_tree():
		end_press()
		return
	if SceneRouter.is_input_blocked() or _pointer_released():
		end_press()
		return
	if _repeat_delay_left > 0.0:
		_repeat_delay_left -= delta
		return
	if _repeat_blocked:
		return
	var interval := 1.0 / maxf(auto_repeat_rate, 0.001)
	_repeat_accum = minf(_repeat_accum + delta, interval)
	if _repeat_accum >= interval:
		_repeat_accum -= interval
		if repeat_guard.is_valid() and not bool(repeat_guard.call()):
			_repeat_blocked = true
			repeat_blocked.emit()
			return
		last_click_was_repeat = true
		_emit_clicked()
		last_click_was_repeat = false


func _pointer_released() -> bool:
	# Touch hold nema globalni poll — oslanja se na release event.
	if _repeat_touch:
		return false
	return not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)


func _apply_panel_style() -> void:
	if disabled and ghost_when_disabled:
		add_theme_stylebox_override("panel", _style_ghost)
	elif disabled:
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
	end_press()
	_apply_panel_style()


func _emit_clicked() -> void:
	if guarded_click and not navigation_scene.is_empty():
		var guard := get_node_or_null("/root/UiClickGuard")
		if guard:
			guard.safe_change_scene(
				navigation_scene,
				click_action_id if not click_action_id.is_empty() else name
			)
			return
	clicked.emit()


func _on_gui_input(event: InputEvent) -> void:
	if disabled or SceneRouter.is_input_blocked():
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			# Hold koji je usput postao disabled mora primiti svoj release.
			if not event.is_pressed():
				end_press()
			accept_event()
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_pressing = true
			_apply_panel_style()
			if auto_repeat:
				begin_press(false)
		else:
			if auto_repeat:
				end_press()
			elif _pressing:
				_emit_clicked()
			_pressing = false
			_apply_panel_style()
		accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_pressing = true
			_apply_panel_style()
			if auto_repeat:
				begin_press(true)
			else:
				_emit_clicked()
		else:
			if auto_repeat:
				end_press()
			_pressing = false
			_apply_panel_style()
		accept_event()
