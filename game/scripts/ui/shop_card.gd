class_name ShopCard
extends Control

## Shop v2 · zajednička kartica: bijela (ili `#FFF6D6` kad je tvoje), rub 4 ink, radius 36,
## tvrda sjena 0 10 0. Kartica crta pozadinu, ime i mali PurchaseStatus ispod imena; dugme
## (ShopBuyButton) je dijete koje kartica postavlja u red od 120 px.

const PAD := 20.0
const NAME_PX := 52
const SUB_PX := 36
const STATUS_H := 56.0

var card_h: float = 200.0
var yours: bool = false
var status_text: String = ""
var status_bg: Color = UiShopV2.STATUS_FAIL_BG
var buy: ShopBuyButton


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _make_buy() -> ShopBuyButton:
	buy = ShopBuyButton.new()
	buy.name = "BuyButton"
	add_child(buy)
	buy.resized.connect(_place_buy)
	return buy


func set_card_height(h: float) -> void:
	card_h = h
	custom_minimum_size = Vector2(UiShopV2.CARD_W, h + UiShopV2.SHADOW_CARD_Y)
	size = custom_minimum_size
	_place_buy()
	queue_redraw()


## Red s dugmetom: počinje na `row_top` (unutar kartice), dugme desno, 20 od ruba.
func row_top() -> float:
	return card_h - 4.0 - PAD - float(UiShopV2.BUTTON_H)


func _place_buy() -> void:
	if buy == null:
		return
	buy.size = buy.custom_minimum_size
	buy.position = Vector2(UiShopV2.CARD_W - 4.0 - PAD - buy.size.x, row_top())


func show_status(text: String, bg: Color) -> void:
	status_text = text
	status_bg = bg
	queue_redraw()


func clear_status() -> void:
	if status_text.is_empty():
		return
	status_text = ""
	queue_redraw()


func get_status_text() -> String:
	return status_text


func _draw_card_bg(fill: Color) -> void:
	var r := Rect2(Vector2.ZERO, Vector2(UiShopV2.CARD_W, card_h))
	UiHomeV3.draw_panel(self, r, fill, UiShopV2.RADIUS_CARD, UiShopV2.BORDER, UiShopV2.INK, UiShopV2.SHADOW_CARD_Y, UiShopV2.SHADOW_CARD)


## Ime (52) + opcioni status ili podnaslov u redu dugmeta, vertikalno centrirano.
func _draw_name_block(name_text: String, sub: String = "", x: float = 4.0 + PAD, ink: Color = UiShopV2.INK) -> void:
	var top := row_top()
	var lines := NAME_PX * 1.05
	var second := ""
	var second_h := 0.0
	if not status_text.is_empty():
		second_h = STATUS_H
	elif not sub.is_empty():
		second = sub
		second_h = SUB_PX * 1.1
	var gap := 10.0 if second_h > 0.0 else 0.0
	var y := top + (float(UiShopV2.BUTTON_H) - (lines + gap + second_h)) * 0.5
	UiHomeV3.draw_text(self, 900, NAME_PX, name_text, Vector2(x, y + (lines - NAME_PX) * 0.5), ink)
	y += lines + gap
	if not status_text.is_empty():
		_draw_status(Vector2(x, y))
	elif not second.is_empty():
		UiHomeV3.draw_text(self, 800, SUB_PX, second, Vector2(x, y + (second_h - SUB_PX) * 0.5), UiShopV2.INK_SUB)


func _draw_status(pos: Vector2) -> void:
	var w := 22.0 * 2.0 + UiHomeV3.text_w(900, UiShopV2.FONT_STATUS, status_text)
	draw_style_box(UiShopV2.box(status_bg, 28, 3), Rect2(pos, Vector2(w, STATUS_H)))
	UiHomeV3.draw_text(self, 900, UiShopV2.FONT_STATUS, status_text, pos + Vector2(22.0, (STATUS_H - UiShopV2.FONT_STATUS) * 0.5), UiShopV2.INK)


## Ink krug s krem rubom i kvačicom (EquippedBadge iz Ormara).
func _draw_badge(center: Vector2, d: float) -> void:
	draw_circle(center, d * 0.5, UiShopV2.DISC)
	draw_circle(center, d * 0.5 - 4.0, UiShopV2.INK)
	var k := d / 64.0
	var pts := PackedVector2Array([
		center + Vector2(-9, 1) * k, center + Vector2(-3, 7) * k, center + Vector2(9, -5) * k
	])
	draw_polyline(pts, UiShopV2.DISC, 5.0 * k, true)


## Okvir pregleda (rub 4, radius 24) preko djece koja se ne režu po uglovima: uglovi van
## zaobljenja se prekriju bojom kartice (`bg`), pa nema clip maske ni shadera.
static func draw_frame_masked(canvas: CanvasItem, rect: Rect2, radius: float, border: float, bg: Color) -> void:
	for k in 4:
		var corner := rect.position + Vector2(rect.size.x if k in [1, 2] else 0.0, rect.size.y if k >= 2 else 0.0)
		var sx := -1.0 if k in [1, 2] else 1.0
		var sy := -1.0 if k >= 2 else 1.0
		var c := corner + Vector2(sx * radius, sy * radius)
		var pts := PackedVector2Array([corner])
		var a0 := atan2(-sy, 0.0)
		var a1 := atan2(0.0, -sx)
		for i in 9:
			var t := float(i) / 8.0
			var a := lerp_angle(a1, a0, t)
			pts.append(c + Vector2(cos(a), sin(a)) * radius)
		canvas.draw_colored_polygon(pts, bg)
	var edge := UiShopV2.box(Color.TRANSPARENT, int(radius), int(border))
	edge.draw_center = false
	canvas.draw_style_box(edge, rect)
