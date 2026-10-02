class_name PopupToast
extends Control

## Pop-up sistem · Toast (design_handoff_popups § Sistem): ink pilula h 100, radius 50, krem rub 3,
## tekst 44/900 krem, opcioni disk 60 (ikona 40 na kremu, ✓ na mintu, katanac na zlatu). Bez sjene,
## nije dodirljiv. Ovaj čvor je TRAKA: toastovi se slažu nadolje od `lane_y` (korak 116), najviše 2 —
## treći gura najstariji. Ulaz y +24 + alpha (180 ms), izlaz alpha (160 ms).

const PAD := 32.0
const DISC_PAD := 23.0
const DISC_GAP := 16.0
const DISC_ICON := 40.0

## Gornja ivica prvog toasta u koordinatama roditelja; vodoravno centrirano na `center_x`.
var lane_y: float = 0.0
var center_x: float = 540.0
var hold_sec: float = 1.6

var _pills: Array[Control] = []


func _init() -> void:
	name = "PopupToast"
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(p_lane_y: float, p_hold: float = 1.6, p_center_x: float = 540.0) -> PopupToast:
	lane_y = p_lane_y
	hold_sec = p_hold
	center_x = p_center_x
	return self


## glyph: "" | "check" | "lock" ; icon: tekstura na kremastom disku.
func show_text(text: String, icon: Texture2D = null, glyph: String = "", hold: float = -1.0) -> Control:
	var pill := _Pill.new()
	pill.text = text
	pill.icon = icon
	pill.glyph = glyph
	pill.size = Vector2(pill.width(), UiPopups.TOAST_H)
	add_child(pill)
	_pills.append(pill)
	while _pills.size() > UiPopups.TOAST_MAX:
		var old: Control = _pills.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	_relayout(pill)
	visible = true
	if is_inside_tree():
		UiPopups.tween_toast_in(pill)
		var t := pill.create_tween()
		t.tween_interval(hold if hold > 0.0 else hold_sec)
		t.tween_property(pill, "modulate:a", 0.0, UiPopups.ANIM.toast_out)
		t.tween_callback(_drop.bind(pill))
	return pill


func clear() -> void:
	for p in _pills:
		if is_instance_valid(p):
			p.queue_free()
	_pills.clear()


func get_texts() -> PackedStringArray:
	var out: PackedStringArray = []
	for p in _pills:
		if is_instance_valid(p) and p.modulate.a > 0.01:
			out.append((p as _Pill).text)
	return out


func last_text() -> String:
	var t := get_texts()
	return t[t.size() - 1] if not t.is_empty() else ""


func _drop(pill: Control) -> void:
	_pills.erase(pill)
	if is_instance_valid(pill):
		pill.queue_free()
	_relayout(null)


func _relayout(fresh: Control) -> void:
	var y := lane_y
	for p in _pills:
		if not is_instance_valid(p):
			continue
		var target := Vector2(roundf(center_x - p.size.x * 0.5), y)
		if p == fresh or not p.is_inside_tree():
			p.position = target
		else:
			p.create_tween().tween_property(p, "position", target, UiPopups.ANIM.toast_in)
		y += UiPopups.TOAST_STEP


## Širina pilule (tekst + opcioni disk).
static func pill_width(text: String, has_disc: bool) -> float:
	var w := UiPopups.text_w(900, UiPopups.TOAST_TEXT, text) + PAD * 2.0
	if has_disc:
		w += UiPopups.TOAST_DISC + DISC_GAP - (PAD - DISC_PAD)
	return ceilf(w)


## Pilula sistema u `r` (svaki toast u igri crta ovo): ink, krem rub 3, disk 60 lijevo.
static func draw_pill(canvas: CanvasItem, r: Rect2, text: String, icon: Texture2D = null, glyph: String = "") -> void:
	canvas.draw_style_box(UiPopups.toast(), r)
	var x := r.position.x + PAD
	var cy := r.get_center().y
	if icon != null or not glyph.is_empty():
		x = r.position.x + DISC_PAD
		var d := float(UiPopups.TOAST_DISC)
		var fill := UiPopups.WARM_WHITE
		if glyph == "check":
			fill = UiPopups.MINT
		elif glyph == "lock":
			fill = UiPopups.COIN_GOLD
		var dc := Vector2(x + d * 0.5, cy)
		canvas.draw_style_box(UiPopups.toast_disc(fill), Rect2(dc - Vector2(d, d) * 0.5, Vector2(d, d)))
		if icon != null:
			UiPopups.draw_icon(canvas, icon, dc, DISC_ICON)
		elif glyph == "check":
			UiPopups.draw_check(canvas, dc, 34.0, UiPopups.OUTLINE, 5.0)
		elif glyph == "lock":
			UiPopups.draw_icon(canvas, UiPopups.icon("icon_lock"), dc, 36.0)
		x += d + DISC_GAP
	UiPopups.draw_text(canvas, 900, UiPopups.TOAST_TEXT, text, Vector2(x, cy - UiPopups.TOAST_TEXT * 0.5), UiPopups.WARM_WHITE)


class _Pill extends Control:
	var text: String = ""
	var icon: Texture2D = null
	var glyph: String = ""

	func _init() -> void:
		name = "Toast"
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func width() -> float:
		return PopupToast.pill_width(text, icon != null or not glyph.is_empty())

	func _draw() -> void:
		PopupToast.draw_pill(self, Rect2(Vector2.ZERO, size), text, icon, glyph)
