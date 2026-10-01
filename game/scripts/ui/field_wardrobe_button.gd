class_name FieldWardrobeButton
extends Control

## Ormar · WardrobeButton (design_handoff_wardrobe): pločica polja 180 iste porodice
## kao Gift / korpa / nadogradnje (UiHomeField.tile(), glyph 84, rub 3, tvrda sjena 8).
## Roze glyph s vješalicom + natpis „Looks". Mint tačka gore lijevo samo kad postoji
## tvoja stavka s new_since > zadnja viđena verzija kataloga.

signal clicked

var _dot_on: bool = false
var _pressed: bool = false
var _icon: Texture2D


func _ready() -> void:
	name = "WardrobeButton"
	custom_minimum_size = Vector2(UiHomeField.TILE, UiHomeField.TILE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if ResourceLoader.exists(UiWardrobe.ICON_WARDROBE):
		_icon = load(UiWardrobe.ICON_WARDROBE) as Texture2D


func set_dot(on: bool) -> void:
	if _dot_on == on:
		return
	_dot_on = on
	queue_redraw()


func is_dot_visible() -> bool:
	return _dot_on


func _draw() -> void:
	var tile := UiHomeField.tile()
	if _pressed:
		tile = UiHomeField.pressed_sticker(tile)
	draw_style_box(tile, Rect2(Vector2.ZERO, size))
	var glyph_px := float(UiWardrobe.WARDROBE_GLYPH)
	var top := (size.y - glyph_px - 10.0 - 38.0) * 0.5
	var glyph := Rect2((size.x - glyph_px) * 0.5, top, glyph_px, glyph_px)
	draw_style_box(UiWardrobe.wardrobe_glyph(), glyph)
	if _icon != null:
		var ic := float(UiWardrobe.WARDROBE_ICON)
		draw_texture_rect(_icon, Rect2(glyph.get_center() - Vector2(ic, ic) * 0.5, Vector2(ic, ic)), false)
	var f := UiStage.font(900, 38)
	UiStage.draw_text_centered(
		self, f, 38, UiWardrobe.BUTTON_LABEL, Rect2(0.0, glyph.end.y + 10.0, size.x, 38.0), UiWardrobe.INK
	)
	if _dot_on:
		var dot := Rect2(Vector2(UiWardrobe.WARDROBE_DOT_OFFSET), Vector2(UiHomeField.DOT, UiHomeField.DOT))
		draw_style_box(UiHomeField.corner_dot(UiWardrobe.MINT), dot)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb := event as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	accept_event()
	if mb.pressed:
		_pressed = true
		queue_redraw()
		return
	var was := _pressed
	_pressed = false
	queue_redraw()
	if was and Rect2(Vector2.ZERO, size).has_point(mb.position):
		clicked.emit()
