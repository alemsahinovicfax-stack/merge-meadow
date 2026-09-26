class_name FieldBasketButton
extends Control

## Korpa u polju sezone (design_handoff_home_field_v2) — plocica 180 x 180 iz iste
## porodice kao Gift iznad nje. Tri stanja: zakljucana (lokot) · prazna (sjeme +
## prsten paznje, jedini loop na ekranu) · izabrano (portret + "+5 %").

const BASKET_VISUAL := preload("res://scripts/ui/home_basket_visual.gd")

signal clicked

var _state: String = "locked"
var _ring: Panel = null
var _frame: Panel = null
var _well: Panel = null
var _visual: Control = null
var _lock: TextureRect = null
var _pill: PanelContainer = null
var _label: Label = null
var _attention: Tween = null


func _ready() -> void:
	custom_minimum_size = Vector2(UiHomeField.TILE, UiHomeField.TILE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_build()
	gui_input.connect(_on_gui_input)
	apply_state(_state, "")


## state: locked | empty | chosen
func apply_state(state: String, type_id: String) -> void:
	_state = state
	if _frame == null:
		return
	add_theme_stylebox_override(
		"panel", UiHomeField.tile("locked" if state == "locked" else "normal")
	)
	var locked := state == "locked"
	_frame.add_theme_stylebox_override(
		"panel",
		UiHomeField.art_frame_locked(UiHomeField.TILE_ICON) if locked
		else UiHomeField.art_frame(UiHomeField.TILE_ICON)
	)
	_well.visible = not locked
	_visual.visible = not locked
	_lock.visible = locked
	if not locked:
		_visual.call("set_loadout_type", type_id if state == "chosen" else "")
	var chosen := state == "chosen"
	_pill.visible = chosen
	_label.text = UiHomeField.basket_label(state)
	_label.add_theme_color_override(
		"font_color", UiHomeField.INK_SOFT if locked else UiHomeField.INK
	)
	_set_attention(state == "empty")
	queue_redraw()


func get_state() -> String:
	return _state


func is_attention_running() -> bool:
	return _attention != null and _attention.is_running()


func stop_attention() -> void:
	_set_attention(false)


func shake() -> void:
	pivot_offset = size * 0.5
	var t := create_tween()
	t.tween_property(self, "position:x", position.x - 10.0, 0.05)
	t.tween_property(self, "position:x", position.x + 10.0, 0.08)
	t.tween_property(self, "position:x", position.x, 0.05)


func _draw() -> void:
	var sb := get_theme_stylebox("panel") as StyleBoxFlat
	if sb:
		draw_style_box(sb, Rect2(Vector2.ZERO, size))


func _build() -> void:
	_ring = Panel.new()
	_ring.name = "AttentionRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.add_theme_stylebox_override("panel", UiHomeField.attention_ring())
	_ring.size = Vector2(UiHomeField.TILE, UiHomeField.TILE)
	_ring.visible = false
	add_child(_ring)

	var frame_side := float(UiHomeField.TILE_ICON)
	var frame_x := (float(UiHomeField.TILE) - frame_side) * 0.5
	_frame = Panel.new()
	_frame.name = "Frame"
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.position = Vector2(frame_x, 17.0)
	_frame.size = Vector2(frame_side, frame_side)
	add_child(_frame)

	var inset := 7.0
	_well = Panel.new()
	_well.name = "Well"
	_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_well.add_theme_stylebox_override("panel", UiHomeField.tile_well())
	_well.position = Vector2(inset, inset)
	_well.size = Vector2(frame_side - inset * 2.0, frame_side - inset * 2.0)
	_frame.add_child(_well)

	_visual = BASKET_VISUAL.new()
	_visual.name = "BasketVisual"
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual.position = Vector2.ZERO
	_visual.size = _well.size
	_well.add_child(_visual)

	_lock = TextureRect.new()
	_lock.name = "LockIcon"
	_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock.texture = UiAssets.get_chrome_icon("icon_lock")
	_lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lock.size = Vector2(44, 44)
	_lock.position = (Vector2(frame_side, frame_side) - _lock.size) * 0.5
	_frame.add_child(_lock)

	_pill = PanelContainer.new()
	_pill.name = "BonusPill"
	_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill.add_theme_stylebox_override("panel", UiHomeField.bonus_pill())
	_pill.position = Vector2(24.0, 111.0)
	_pill.size = Vector2(float(UiHomeField.TILE) - 48.0, 52.0)
	add_child(_pill)

	_label = Label.new()
	_label.name = "Label"
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.position = Vector2(0.0, 111.0)
	_label.size = Vector2(UiHomeField.TILE, 52.0)
	_label.add_theme_font_override("font", UiStage.font(900, 44))
	_label.add_theme_font_size_override("font_size", 44)
	add_child(_label)


func _set_attention(on: bool) -> void:
	if _ring == null:
		return
	if not on:
		if _attention:
			_attention.kill()
			_attention = null
		_ring.visible = false
		_ring.scale = Vector2.ONE
		_ring.modulate.a = 0.0
		return
	if _attention and _attention.is_running():
		return
	_ring.visible = true
	_attention = UiHomeField.tween_attention(_ring)


func _on_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	accept_event()
	clicked.emit()
