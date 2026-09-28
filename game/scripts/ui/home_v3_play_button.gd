class_name HomeV3PlayButton
extends Control

## PlayButton (HomeScreen.dc.html) — JEDAN objekat za sva tri koraka:
## biranje 520 x 180 (rub 4, sjenka 10, tekst 76), u prelazu interpolira sve
## mjere, a na polju JESTE FieldPlayButton 432 x 140 (rub 3, sjenka 8, tekst 64).
## Mod "back": disk aktivne sezone 104 + chevron + „Back" 66 — vraca karticu na
## sezonu u kojoj se igra, ne pali run. Cvor je tacno rect dugmeta (mijenja se
## svaki frame prelaza), pa dodir ide direktno njemu.

signal pressed

const MODE_PLAY := "play"
const MODE_BACK := "back"

var mode: String = MODE_PLAY
var back_ground := Color.WHITE
var back_type: String = ""
var enabled: bool = true
var _p: Dictionary = UiHomeV3.PLAY_CARD.duplicate()
var _down: bool = false


func _init() -> void:
	name = "PlayButton"
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_progress(0.0)


func set_progress(e: float) -> void:
	_p = UiHomeV3.play_params(e)
	var r := button_rect()
	position = r.position
	size = r.size
	queue_redraw()


## Rect dugmeta u koordinatama stranice.
func button_rect() -> Rect2:
	return _p.get("rect", UiHomeV3.PLAY_CARD.rect) as Rect2


func set_mode(m: String, ground: Color = Color.WHITE, type_id: String = "") -> void:
	if mode == m and back_ground == ground and back_type == type_id:
		return
	mode = m
	back_ground = ground
	back_type = type_id
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pos := Vector2.ZERO
	var is_press := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		pos = mb.position
		is_press = mb.pressed
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		pos = st.position
		is_press = st.pressed
	else:
		return
	accept_event()
	var inside := Rect2(Vector2.ZERO, size).has_point(pos)
	if is_press:
		_set_down(inside and enabled)
		return
	var fire := _down and inside and enabled
	_set_down(false)
	if fire:
		pressed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_set_down(false)


func cancel_press() -> void:
	_set_down(false)


func is_down() -> bool:
	return _down


func _set_down(v: bool) -> void:
	if _down == v:
		return
	_down = v
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var bw := float(_p.border)
	var sy := float(_p.shadow_y)
	if _down:
		var push := minf(4.0, sy * 0.5)
		r = Rect2(r.position + Vector2(0.0, push), r.size)
		sy -= push
	var shadow := Color(0.102, 0.102, 0.078, float(_p.shadow_a))
	UiHomeV3.draw_panel(self, r, UiHomeV3.PEACH, r.size.y * 0.5, bw, UiHomeV3.INK, sy, shadow)
	if mode == MODE_BACK:
		_draw_back(r)
	else:
		_draw_play(r)


func _draw_play(r: Rect2) -> void:
	var fs := float(_p.text)
	var th := float(_p.tri_h)
	var tw := float(_p.tri_w)
	var gap := float(_p.gap)
	var ml := float(_p.margin)
	var text_w := UiHomeV3.text_w(900, fs, "Play")
	var row := ml + tw + gap + text_w
	var x := r.get_center().x - row * 0.5
	var cy := r.get_center().y
	x += ml
	draw_colored_polygon(PackedVector2Array([
		Vector2(x, cy - th), Vector2(x + tw, cy), Vector2(x, cy + th)
	]), UiHomeV3.INK)
	x += tw + gap
	UiHomeV3.draw_text(self, 900, fs, "Play", Vector2(x, cy - fs * 0.5), UiHomeV3.INK)


func _draw_back(r: Rect2) -> void:
	var d := UiHomeV3.PLAY_BACK_DISC
	var fs := float(UiHomeV3.PLAY_BACK_LABEL)
	var chev := 22.0 + 8.0
	var text_w := UiHomeV3.text_w(900, fs, "Back")
	var row := d + 22.0 + 4.0 + chev + 22.0 + text_w
	var x := r.get_center().x - row * 0.5
	var cy := r.get_center().y
	var disc := Rect2(x, cy - d * 0.5, d, d)
	UiHomeV3.draw_panel(self, disc, back_ground, d * 0.5, 4.0)
	UiHomeV3.draw_flower(self, disc.get_center(), back_type, d)
	x += d + 22.0 + 4.0
	UiHomeV3.draw_chevron(self, Vector2(x + chev * 0.5, cy), 22.0, 8.0, true, UiHomeV3.INK)
	x += chev + 22.0
	UiHomeV3.draw_text(self, 900, fs, "Back", Vector2(x, cy - fs * 0.5), UiHomeV3.INK)
