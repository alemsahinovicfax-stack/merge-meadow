class_name CampButton
extends UiClickButton

## Camp dugme (design_handoff_camp): stil iz UiCamp umjesto UiPalette varijanti,
## naslov + opcioni podnaslov, opciona ikona i hold fill (Trade). Hover/press/
## hold/disabled logika ostaje u UiClickButton.

var _custom_normal: StyleBoxFlat
var _custom_pressed: StyleBoxFlat
var _row_box: HBoxContainer
var _icon_rect: TextureRect
var _text_col: VBoxContainer
var _title: Label
var _sub: Label
var _hold_pct: float = 0.0
var _hold_color: Color = UiPalette.PEACH
var _hold_tween: Tween
var _press_scale: float = 1.0
var _scale_tween: Tween


func _ready() -> void:
	label_text = ""
	super()
	var parent_label := get_node_or_null("ContentRow/Label") as Label
	if parent_label:
		parent_label.visible = false
	_row_box = get_node_or_null("ContentRow") as HBoxContainer
	_ensure_camp_content()
	resized.connect(_on_resized)
	gui_input.connect(_on_scale_input)
	_on_resized()


func _ensure_camp_content() -> void:
	if _text_col != null or _row_box == null:
		return
	_row_box.add_theme_constant_override("separation", 14)
	_icon_rect = TextureRect.new()
	_icon_rect.name = "CampIcon"
	_icon_rect.visible = false
	_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row_box.add_child(_icon_rect)
	_text_col = VBoxContainer.new()
	_text_col.name = "TextCol"
	_text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_text_col.add_theme_constant_override("separation", 6)
	_text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row_box.add_child(_text_col)
	_title = Label.new()
	_title.name = "Title"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_col.add_child(_title)
	_sub = Label.new()
	_sub.name = "Sub"
	_sub.visible = false
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_col.add_child(_sub)
	UiCamp.style_label(_title, UiCamp.FONT_BTN, UiCamp.INK)
	UiCamp.style_label(_sub, UiCamp.FONT_BTN_SUB, UiCamp.INK, UiCamp.SEMI)


## Stil za mirno i pritisnuto stanje (hover = mirno).
func set_styles(normal: StyleBoxFlat, pressed: StyleBoxFlat = null) -> void:
	_custom_normal = normal
	_custom_pressed = pressed if pressed != null else normal
	_build_styles()
	_apply_panel_style()


func set_text(title: String, sub: String = "") -> void:
	_ensure_camp_content()
	if _title == null:
		return
	_title.text = title
	_sub.text = sub
	_sub.visible = not sub.is_empty()


func get_title() -> String:
	return _title.text if _title else ""


func get_sub() -> String:
	return _sub.text if _sub else ""


func get_title_label() -> Label:
	_ensure_camp_content()
	return _title


func get_sub_label() -> Label:
	_ensure_camp_content()
	return _sub


func get_text_column() -> VBoxContainer:
	_ensure_camp_content()
	return _text_col


func set_fonts(title_px: int, sub_px: int = UiCamp.FONT_BTN_SUB) -> void:
	_ensure_camp_content()
	if _title == null:
		return
	var ink := _title.get_theme_color("font_color")
	UiCamp.style_label(_title, title_px, ink)
	UiCamp.style_label(_sub, sub_px, ink, UiCamp.SEMI)


func set_ink(color: Color) -> void:
	_ensure_camp_content()
	if _title == null:
		return
	_title.add_theme_color_override("font_color", color)
	_sub.add_theme_color_override("font_color", color)


func set_icon(texture: Texture2D, side: float) -> void:
	_ensure_camp_content()
	if _icon_rect == null:
		return
	_icon_rect.texture = texture
	_icon_rect.custom_minimum_size = Vector2(side, side)
	_icon_rect.visible = texture != null


## 0..1 sirina fill-a iza teksta (Trade drzanje).
func set_hold_fill(pct: float, color: Color) -> void:
	if _hold_tween:
		_hold_tween.kill()
		_hold_tween = null
	_hold_pct = clampf(pct, 0.0, 1.0)
	_hold_color = color
	queue_redraw()


func get_hold_fill() -> float:
	return _hold_pct


func reset_hold_fill(duration: float) -> void:
	if _hold_tween:
		_hold_tween.kill()
	if duration <= 0.0 or not is_inside_tree():
		set_hold_fill(0.0, _hold_color)
		return
	_hold_tween = create_tween()
	_hold_tween.tween_method(_set_hold_pct_raw, _hold_pct, 0.0, duration)


func _set_hold_pct_raw(value: float) -> void:
	_hold_pct = value
	queue_redraw()


## Skala na pritisak (Trade tap = 0,97).
func set_press_scale(value: float) -> void:
	_press_scale = value


func _build_styles() -> void:
	if _custom_normal == null:
		super()
		return
	_style_normal = _custom_normal
	_style_hover = _custom_normal
	_style_pressed = _custom_pressed
	_style_ghost = _custom_normal


func _apply_disabled() -> void:
	super()
	# Camp stanja nose disabled izgled kroz stil i ink, ne kroz prozirnost.
	modulate = Color.WHITE


func _draw() -> void:
	if _hold_pct <= 0.001:
		return
	var box := _style_normal
	var inset := float(box.border_width_left) if box else 3.0
	var inner := Rect2(Vector2(inset, inset), size - Vector2(inset, inset) * 2.0)
	var fill := StyleBoxFlat.new()
	fill.bg_color = _hold_color
	var radius := maxi(int(box.corner_radius_top_left - inset) if box else 17, 0)
	fill.corner_radius_top_left = radius
	fill.corner_radius_bottom_left = radius
	if _hold_pct >= 0.98:
		fill.corner_radius_top_right = radius
		fill.corner_radius_bottom_right = radius
	draw_style_box(fill, Rect2(inner.position, Vector2(inner.size.x * _hold_pct, inner.size.y)))


func _on_resized() -> void:
	pivot_offset = size * 0.5


func _on_scale_input(event: InputEvent) -> void:
	if is_equal_approx(_press_scale, 1.0) or disabled:
		return
	var pressed := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		pressed = mb.pressed
	elif event is InputEventScreenTouch:
		pressed = (event as InputEventScreenTouch).pressed
	else:
		return
	if _scale_tween:
		_scale_tween.kill()
	_scale_tween = create_tween()
	var target := Vector2.ONE * (_press_scale if pressed else 1.0)
	_scale_tween.tween_property(self, "scale", target, UiCamp.T_CHIP_PRESS)
