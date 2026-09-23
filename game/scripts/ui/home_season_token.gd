class_name HomeSeasonToken
extends Control

## Jedan token u SeasonBrowseru (120 px). Tap skace na sezonu; daleki lock se trese.

signal pressed(season_id: String)

const SIDE := 120.0
const TAP_SLOP := 12.0

var season_id: String = ""
var _focused: bool = false
var _pressing: bool = false
var _press_at: Vector2 = Vector2.ZERO
var _drag: float = 0.0
var _shake: Tween

var _face: Panel
var _center: CenterContainer
var _number: Label
var _soon: Label
var _check: Label
var _lock_well: Panel
var _gem_well: Panel
var _bar_track: ColorRect
var _bar_fill: ColorRect
var _dot: Panel
var _dot_label: Label
var _focus_bar: ColorRect


func _init() -> void:
	custom_minimum_size = Vector2(SIDE, SIDE)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _ready() -> void:
	resized.connect(_layout_face)


func configure(data: Dictionary) -> void:
	season_id = str(data.get("season_id", ""))
	_focused = bool(data.get("focused", false))
	var fill: Color = data.get("fill", Color.WHITE)
	var active := bool(data.get("active", false))
	var kind := str(data.get("kind", "number"))
	var style_name := "season_token_idle"
	if active:
		style_name = "season_token_active"
	elif _focused:
		style_name = "season_token_focus"
	var style := HomeSeasonStyles.get_style(style_name)
	style.bg_color = fill
	_face.add_theme_stylebox_override("panel", style)
	var ink: Color = SeasonColors.ink(fill)
	_number.visible = kind == "number"
	_number.text = str(int(data.get("number", 0)))
	UiHome.style(_number, 52, ink, UiHome.W_BLACK)
	_soon.visible = kind == "soon"
	UiHome.style(_soon, 38, Color("#FFF8F0"), UiHome.W_BLACK)
	_check.visible = kind == "check"
	UiHome.style(_check, 52, Color("#FFF8F0"), UiHome.W_BLACK)
	_lock_well.visible = kind == "lock"
	_gem_well.visible = kind == "gem"
	var show_bar := bool(data.get("show_bar", false))
	_bar_track.visible = show_bar
	if show_bar:
		_bar_fill.anchor_right = clampf(float(data.get("bar_ratio", 0.0)), 0.0, 1.0)
	_dot.visible = active
	_focus_bar.visible = _focused
	_layout_face()


func shake() -> void:
	if _shake:
		_shake.kill()
	var rest_y := -6.0 if _focused else 0.0
	_face.position = Vector2(0.0, rest_y)
	_face.pivot_offset = Vector2(SIDE, SIDE) * 0.5
	_face.rotation = 0.0
	if not is_inside_tree():
		return
	_shake = create_tween()
	_shake.tween_property(_face, "position:x", 8.0, 0.06)
	_shake.parallel().tween_property(_face, "rotation", deg_to_rad(3.0), 0.06)
	_shake.tween_property(_face, "position:x", -6.0, 0.06)
	_shake.parallel().tween_property(_face, "rotation", deg_to_rad(-2.0), 0.06)
	_shake.tween_property(_face, "position:x", 0.0, 0.06)
	_shake.parallel().tween_property(_face, "rotation", 0.0, 0.06)


func get_fill_color() -> Color:
	var style := _face.get_theme_stylebox("panel") as StyleBoxFlat
	return style.bg_color if style else Color.WHITE


func _layout_face() -> void:
	var y := -6.0 if _focused else 0.0
	if _shake == null or not _shake.is_running():
		_face.position = Vector2(0.0, y)
	_face.size = Vector2(SIDE, SIDE)
	_center.position = Vector2.ZERO
	_center.size = Vector2(SIDE, SIDE)
	_dot.position = Vector2(SIDE - 48.0 + 14.0, -14.0)
	_focus_bar.position = Vector2(30.0, SIDE + 14.0)
	_focus_bar.size = Vector2(60.0, 8.0)


func _build() -> void:
	_face = Panel.new()
	_face.name = "Face"
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.custom_minimum_size = Vector2(SIDE, SIDE)
	add_child(_face)
	_center = CenterContainer.new()
	_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.add_child(_center)
	_number = _label("Number")
	_center.add_child(_number)
	_soon = _label("Soon")
	_soon.text = "Soon"
	_center.add_child(_soon)
	_check = _label("Check")
	_check.text = "✓"
	_center.add_child(_check)
	_lock_well = _icon_well("LockWell", "icon_lock")
	_center.add_child(_lock_well)
	_gem_well = _icon_well("GemWell", "icon_diamond")
	_center.add_child(_gem_well)
	_bar_track = ColorRect.new()
	_bar_track.name = "NextBar"
	_bar_track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_track.color = Color(0.102, 0.141, 0.118, 0.45)
	_bar_track.position = Vector2(10, SIDE - 10 - 12)
	_bar_track.size = Vector2(SIDE - 20, 12)
	_face.add_child(_bar_track)
	_bar_fill = ColorRect.new()
	_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar_fill.color = Color("#FFD56B")
	_bar_fill.anchor_right = 0.0
	_bar_fill.anchor_bottom = 1.0
	_bar_fill.offset_right = 0.0
	_bar_fill.offset_bottom = 0.0
	_bar_track.add_child(_bar_fill)
	_dot = Panel.new()
	_dot.name = "ActiveDot"
	_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dot.custom_minimum_size = Vector2(48, 48)
	_dot.size = Vector2(48, 48)
	_dot.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style("active_dot"))
	add_child(_dot)
	_dot_label = _label("PlayMark")
	_dot_label.text = "▶"
	_dot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_dot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_dot_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	UiHome.style(_dot_label, 22, UiHome.INK, UiHome.W_BLACK)
	_dot.add_child(_dot_label)
	_focus_bar = ColorRect.new()
	_focus_bar.name = "FocusBar"
	_focus_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_focus_bar.color = Color("#FFF8F0")
	add_child(_focus_bar)


func _icon_well(node_name: String, icon_name: String) -> Panel:
	var well := Panel.new()
	well.name = node_name
	well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well.custom_minimum_size = Vector2(64, 64)
	var circle := StyleBoxFlat.new()
	circle.bg_color = Color("#FFF8F0")
	circle.set_corner_radius_all(32)
	well.add_theme_stylebox_override("panel", circle)
	var icon := TextureRect.new()
	icon.texture = UiAssets.get_chrome_icon(icon_name)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 12
	icon.offset_top = 12
	icon.offset_right = -12
	icon.offset_bottom = -12
	well.add_child(icon)
	return well


func _label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _gui_input(event: InputEvent) -> void:
	var pos := Vector2.ZERO
	var down := false
	var is_pointer := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		is_pointer = true
		down = mb.pressed
		pos = mb.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		is_pointer = true
		down = touch.pressed
		pos = touch.position
	elif event is InputEventMouseMotion and _pressing:
		_drag = maxf(_drag, (event as InputEventMouseMotion).position.distance_to(_press_at))
		return
	elif event is InputEventScreenDrag and _pressing:
		_drag = maxf(_drag, (event as InputEventScreenDrag).position.distance_to(_press_at))
		return
	if not is_pointer:
		return
	if down:
		_pressing = true
		_press_at = pos
		_drag = 0.0
	else:
		var tap := _pressing and _drag < TAP_SLOP
		_pressing = false
		if tap:
			pressed.emit(season_id)
	accept_event()
