class_name NeedCoinsBubble
extends Control

## „Need N more coins" (design_handoff_ads_only · coin_price.json need_bubble): jedan oblačić
## #FFE8B8 za Shop, Home i Camp — zamjenjuje toast / pilulu. h 64, radius 32, rub 3 ink, sjena
## 0 4 0, tekst 34/900. Iznad dugmeta, desno poravnat s dugmetom, rep na sredini dugmeta;
## u Campu ispod. Živi 1,6 s (1 Timer), ulaz 0,15 s. Smije prekriti susjede (namjerno).
## Jedna instanca po ekranu; roditelj je ekran, anchor je u koordinatama roditelja. U Container
## roditelju (Camp kartica je PanelContainer) oblačić je top_level i anchor je globalan.

const H := 64.0
const RADIUS := 32
const FONT := 34
const PAD_X := 26.0
const BORDER := 3
const SHADOW_Y := 4.0
const TAIL_W := 28.0
const TAIL_H := 14.0
const GAP := 6.0
const MARGIN := 24.0
const FILL := Color("#FFE8B8")
const SHADOW := Color(0.102, 0.102, 0.078, 0.22)
const LIFE := 1.6
const T_IN := 0.15

var text: String = ""
var _below: bool = false
var _tail_x: float = 0.0
var _timer: Timer
var _tween: Tween


func _init() -> void:
	name = "NeedCoinsBubble"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	z_index = 20


func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = LIFE
	_timer.timeout.connect(hide_now)
	add_child(_timer)


## `anchor` = pravougaonik dugmeta u koordinatama roditelja.
func show_need(p_text: String, anchor: Rect2, below: bool = false) -> void:
	text = p_text
	_below = below
	var w := ceilf(PAD_X * 2.0 + UiHomeV3.text_w(900, FONT, text, 0.0, true))
	size = Vector2(w, H + TAIL_H + SHADOW_Y)
	var limit := get_viewport_rect().size.x
	if not top_level and get_parent() is Control:
		limit = (get_parent() as Control).size.x
	var x := clampf(anchor.end.x - w, MARGIN, maxf(MARGIN, limit - MARGIN - w))
	var y := anchor.end.y + GAP if below else anchor.position.y - GAP - H - TAIL_H
	position = Vector2(x, y)
	_tail_x = clampf(anchor.get_center().x - x, float(RADIUS), w - float(RADIUS))
	pivot_offset = Vector2(_tail_x, 0.0 if below else H + TAIL_H)
	visible = true
	queue_redraw()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	scale = Vector2.ONE * 0.9
	if is_inside_tree():
		_tween = create_tween()
		_tween.tween_property(self, "scale", Vector2.ONE, T_IN).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_timer.start(LIFE)
	else:
		scale = Vector2.ONE


func hide_now() -> void:
	visible = false
	text = ""
	if _timer != null:
		_timer.stop()


func get_text() -> String:
	return text if visible else ""


func _draw() -> void:
	var top := TAIL_H if _below else 0.0
	var pill := Rect2(Vector2(0.0, top), Vector2(size.x, H))
	draw_style_box(UiStage.box(SHADOW, RADIUS), Rect2(pill.position + Vector2(0.0, SHADOW_Y), pill.size))
	var tip_y := 0.0 if _below else H + TAIL_H
	var base_y := top + (1.0 if _below else H - 1.0)
	var tail := PackedVector2Array([
		Vector2(_tail_x - TAIL_W * 0.5, base_y), Vector2(_tail_x + TAIL_W * 0.5, base_y), Vector2(_tail_x, tip_y)
	])
	draw_colored_polygon(tail, UiCoinPrice.INK)
	draw_style_box(UiStage.box(FILL, RADIUS, BORDER, UiCoinPrice.INK), pill)
	var inner := PackedVector2Array([
		Vector2(_tail_x - TAIL_W * 0.5 + 5.0, base_y + (1.0 if _below else -1.0) * 2.0),
		Vector2(_tail_x + TAIL_W * 0.5 - 5.0, base_y + (1.0 if _below else -1.0) * 2.0),
		Vector2(_tail_x, tip_y + (4.5 if _below else -4.5)),
	])
	draw_colored_polygon(inner, FILL)
	var tw := UiHomeV3.text_w(900, FONT, text, 0.0, true)
	UiHomeV3.draw_text(self, 900, FONT, text, Vector2((size.x - tw) * 0.5, top + (H - FONT) * 0.5), UiCoinPrice.INK, 0.0, true)
