class_name FieldUpgradesButton
extends Control

## Ulaz u nadogradnje (design_handoff_home_field_v2) — treca plocica iste porodice,
## gore desno. Nosi znak ︽ i dvije mini trake nivoa (Magnet, Loot), pa se napredak
## vidi prije tapa; zlatna tacka znaci da se nesto moze kupiti sada.

signal clicked

const GLYPH_BOX := 84.0
const ROWS := 2
const SEGMENTS := 4

var _magnet_level: int = 0
var _loot_level: int = 0
var _dot_on: bool = false
var _glyph: Panel = null
var _dot: Panel = null
var _rows: Array[Array] = []


func _ready() -> void:
	custom_minimum_size = Vector2(UiHomeField.TILE, UiHomeField.TILE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_stylebox_override("panel", UiHomeField.tile())
	_build()
	gui_input.connect(_on_gui_input)
	set_levels(_magnet_level, _loot_level, _dot_on)


func set_levels(magnet: int, loot: int, ready_dot: bool) -> void:
	_magnet_level = magnet
	_loot_level = loot
	_dot_on = ready_dot
	if _rows.is_empty():
		return
	for r in ROWS:
		var level: int = _magnet_level if r == 0 else _loot_level
		var segs: Array = _rows[r]
		for i in segs.size():
			var seg: Panel = segs[i]
			seg.add_theme_stylebox_override(
				"panel", UiHomeField.level_segment(i < level, UiHomeField.LEVEL_SEG.y)
			)
	if _dot:
		_dot.visible = ready_dot


func is_dot_visible() -> bool:
	return _dot != null and _dot.visible


func _draw() -> void:
	var sb := get_theme_stylebox("panel") as StyleBoxFlat
	if sb:
		draw_style_box(sb, Rect2(Vector2.ZERO, size))


func _build() -> void:
	var glyph_x := (float(UiHomeField.TILE) - GLYPH_BOX) * 0.5
	_glyph = Panel.new()
	_glyph.name = "Glyph"
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glyph.add_theme_stylebox_override("panel", UiHomeField.tile_icon(UiHomeField.MINT))
	_glyph.position = Vector2(glyph_x, 25.0)
	_glyph.size = Vector2(GLYPH_BOX, GLYPH_BOX)
	_glyph.draw.connect(_draw_chevrons.bind(_glyph))
	add_child(_glyph)

	var row_w := SEGMENTS * UiHomeField.LEVEL_SEG.x + (SEGMENTS - 1) * UiHomeField.LEVEL_SEG_GAP
	var row_x := (float(UiHomeField.TILE) - float(row_w)) * 0.5
	_rows.clear()
	for r in ROWS:
		var segs: Array = []
		for i in SEGMENTS:
			var seg := Panel.new()
			seg.name = "Seg_%d_%d" % [r, i]
			seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
			seg.position = Vector2(
				row_x + i * (UiHomeField.LEVEL_SEG.x + UiHomeField.LEVEL_SEG_GAP),
				121.0 + r * float(UiHomeField.LEVEL_SEG.y + UiHomeField.LEVEL_SEG_GAP)
			)
			seg.size = Vector2(UiHomeField.LEVEL_SEG)
			add_child(seg)
			segs.append(seg)
		_rows.append(segs)

	_dot = Panel.new()
	_dot.name = "UpgradeDot"
	_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dot.add_theme_stylebox_override("panel", UiHomeField.corner_dot(UiHomeField.COIN_GOLD))
	_dot.size = Vector2(UiHomeField.DOT, UiHomeField.DOT)
	_dot.position = Vector2(UiHomeField.DOT_OFFSET)
	_dot.visible = false
	add_child(_dot)


## Dvostruki chevron nagore — panel se ne oslanja na glyph iz fonta.
func _draw_chevrons(host: Panel) -> void:
	var w := host.size.x
	var cx := w * 0.5
	var half := w * 0.26
	for i in 2:
		var y := w * (0.40 + 0.22 * float(i))
		host.draw_polyline(
			PackedVector2Array([
				Vector2(cx - half, y),
				Vector2(cx, y - half * 0.62),
				Vector2(cx + half, y),
			]),
			UiHomeField.STICKER_EDGE,
			7.0,
			true
		)


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
