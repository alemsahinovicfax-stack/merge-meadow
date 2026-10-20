class_name PickupPill
extends Control

## Krem pilula „+1" / „+2" koja leti do CoinChipa / SeedChipa (pickup_fx.json → hud.pill):
## h 64, radius 32, rub 3 #2D3436, ikona 44, tekst 900 44, tvrda sjena 0 4 0. Crta se jednom kad
## se promijeni sadržaj; let je samo pozicija / skala / alfa. Iz bazena u PickupFx.

const H := 64.0
const ICON := 44.0
const PAD_L := 12.0
const PAD_R := 18.0
const GAP := 8.0
const BORDER := 3
const FONT_PX := 44
const BG := Color("#FFF8F0")
const INK := Color("#2D3436")
const SHADOW := Color(18.0 / 255.0, 28.0 / 255.0, 22.0 / 255.0, 0.42)

static var _body: StyleBoxFlat
static var _shade: StyleBoxFlat

var _icon: Texture2D
var _text: String = ""
var _font: Font


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UiCamp.tight_font(FONT_PX)
	if _body == null:
		_body = StyleBoxFlat.new()
		_body.bg_color = BG
		_body.border_color = INK
		_body.set_border_width_all(BORDER)
		_body.set_corner_radius_all(int(H * 0.5))
		_body.anti_aliasing = true
		_shade = StyleBoxFlat.new()
		_shade.bg_color = SHADOW
		_shade.set_corner_radius_all(int(H * 0.5))
		_shade.anti_aliasing = true


func show_pill(icon: Texture2D, text: String) -> void:
	if icon == _icon and text == _text:
		return
	_icon = icon
	_text = text
	var tw := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX).x
	size = Vector2(float(BORDER) * 2.0 + PAD_L + ICON + GAP + tw + PAD_R, H)
	pivot_offset = size * 0.5
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_style_box(_shade, Rect2(Vector2(0.0, 4.0), size))
	draw_style_box(_body, r)
	var x := float(BORDER) + PAD_L
	if _icon != null:
		draw_texture_rect(_icon, Rect2(Vector2(x, (H - ICON) * 0.5), Vector2(ICON, ICON)), false)
	x += ICON + GAP
	var ascent := _font.get_ascent(FONT_PX)
	var descent := _font.get_descent(FONT_PX)
	var baseline := (H - (ascent + descent)) * 0.5 + ascent
	draw_string(_font, Vector2(x, baseline), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_PX, INK)
