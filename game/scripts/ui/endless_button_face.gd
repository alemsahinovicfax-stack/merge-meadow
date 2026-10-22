class_name EndlessButtonFace
extends Control

## Endless dugme u polju i na Level Pathu (design_handoff_leveli_endless · endless_ui.json → button),
## 236 × 124 na istom mjestu. Zaključano: krem + prsten napretka (pređeno / 15, mint) + zlatni
## katanac + „Endless / 9 / 15" — oblikom i bojom drugačije od otključanog (lavanda + prstenovi).
## Rekord sezone: krem pločica „🏆 3:12" na dnu dugmeta (Home i put), sakrivena dok rekorda nema.
## B1 tap na zaključano: tres 8 px (0,3 s) — toast šalje MainMenu. B2 otključavanje (jednom po
## sezoni, poslije skoka 15 → 16): katanac zadrhti, karika gore, tijelo iskoči i nestane, krem →
## lavanda, prstenovi uskoče, prsten fx; oblačić „Endless unlocked!" šalje MainMenu.
## Crta se kad se stanje promijeni; frejmovi samo dok traje tres / otključavanje.

signal unlock_bubble_due

const LABEL_X := 114.0
const LABEL_PAD_R := 12.0
const OPEN_RINGS := Vector2(54, 30)

var unlocked: bool = false
var progress: int = 0
var best_sec: float = 0.0

var _shackle: TextureRect
var _body: TextureRect
var _rings: TextureRect
var _burst: TextureRect
var _anim: String = ""
var _t: float = 0.0
var _flip: float = 0.0
var _button: Control
var _home_x: float = 0.0
var _bubble_sent: bool = false


func _init() -> void:
	name = "EndlessFace"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shackle = _tex("Shackle", "endless/lock_shackle.svg", UiLevels.BTN_SHACKLE)
	_body = _tex("LockBody", "endless/lock_body.svg", UiLevels.BTN_BODY)
	_rings = _tex("Rings", "endless/rings.svg", Rect2(Vector2.ZERO, OPEN_RINGS))
	_burst = _tex("Burst", "fx/burst_ring.svg", UiLevels.BTN_BURST)
	_burst.visible = false
	_shackle.pivot_offset = Vector2(0.0, UiLevels.BTN_SHACKLE.size.y)
	_body.pivot_offset = UiLevels.BTN_BODY.size * 0.5
	_rings.pivot_offset = OPEN_RINGS * 0.5
	_burst.pivot_offset = UiLevels.BTN_BURST.size * 0.5
	set_process(false)


func _tex(node_name: String, rel: String, r: Rect2) -> TextureRect:
	var t := TextureRect.new()
	t.name = node_name
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture = UiLevels.tex(rel)
	t.position = r.position
	t.size = r.size
	add_child(t)
	return t


## Stanje iz GameState (zove MainMenu); vraća true ako se izgled promijenio.
func apply(p_unlocked: bool, p_progress: int, p_best: float) -> bool:
	if _anim == "unlock":
		return false
	var changed := p_unlocked != unlocked or p_progress != progress or not is_equal_approx(p_best, best_sec)
	unlocked = p_unlocked
	progress = clampi(p_progress, 0, UiLevels.UNLOCK_LEVEL)
	best_sec = p_best
	_flip = 1.0 if unlocked else 0.0
	_sync_parts()
	queue_redraw()
	return changed


func is_animating() -> bool:
	return not _anim.is_empty()


func best_text() -> String:
	return UiLevels.clock(best_sec) if unlocked and best_sec > 0.0 else ""


func progress_text() -> String:
	return "%d / %d" % [progress, UiLevels.UNLOCK_LEVEL]


## B1: tres zaključanog dugmeta (8 px, 2 zamaha, 0,3 s).
func play_locked_tap(button: Control) -> void:
	if UiPip.reduce_motion() or _anim == "unlock":
		return
	_start("lock", button)


## B2: trenutak otključavanja (0,4 s čekanja + 1,1 s), oblačić od 0,62 s (signal).
func play_unlock(button: Control, p_best: float = 0.0) -> void:
	unlocked = false
	progress = UiLevels.UNLOCK_LEVEL
	best_sec = p_best
	_flip = 0.0
	_bubble_sent = false
	_sync_parts()
	queue_redraw()
	if UiPip.reduce_motion():
		_finish_unlock()
		unlock_bubble_due.emit()
		return
	_start("unlock", button)


func _start(kind: String, button: Control) -> void:
	if _button != null and is_instance_valid(_button):
		_button.position.x = _home_x
		_button.scale = Vector2.ONE
	_anim = kind
	_t = 0.0
	_button = button
	_home_x = button.position.x if button else 0.0
	set_process(true)


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — bez ovoga bi lice samo od sebe odigralo
	# otključavanje (i ostalo „otključano") ~0,4 s poslije učitavanja huba.
	if _anim.is_empty():
		set_process(false)
		return
	_t += delta
	if _anim == "lock":
		var k := UiLevels.clamp01(_t / UiLevels.LOCK_SHAKE_SEC)
		_shift(sin(k * PI * 4.0) * UiLevels.LOCK_SHAKE_PX * (1.0 - k), 1.0)
		if k >= 1.0:
			_end_anim()
		return
	var v := _t - UiLevels.UNLOCK_DELAY
	if v < 0.0:
		return
	var sk := UiLevels.clamp01(v / UiLevels.UNLOCK_SHAKE)
	_shift(sin(sk * PI * 4.0) * 6.0 * (1.0 - sk), 1.0 + 0.08 * UiLevels.bell(v, UiLevels.UNLOCK_POP.x, UiLevels.UNLOCK_POP.y))
	var s1 := UiLevels.out3(UiLevels.clamp01((v - UiLevels.UNLOCK_SHAKE) / 0.16))
	_shackle.position = UiLevels.BTN_SHACKLE.position + Vector2(0.0, -16.0 * s1)
	_shackle.rotation_degrees = -24.0 * s1
	var p := UiLevels.clamp01((v - UiLevels.UNLOCK_POP.x) / (UiLevels.UNLOCK_POP.y - UiLevels.UNLOCK_POP.x))
	_body.scale = Vector2.ONE * maxf(0.0, 1.0 + 0.25 * UiLevels.bell(p, 0.0, 0.5) - UiLevels.clamp01((p - 0.5) / 0.5))
	var fade := 1.0 - UiLevels.clamp01((p - 0.6) / 0.4)
	_shackle.modulate.a = fade
	_body.modulate.a = fade
	_flip = UiLevels.clamp01((v - UiLevels.UNLOCK_FLIP.x) / (UiLevels.UNLOCK_FLIP.y - UiLevels.UNLOCK_FLIP.x))
	_rings.visible = _flip > 0.0
	_rings.scale = Vector2.ONE * maxf(0.0, UiLevels.out_back(_flip))
	_rings.rotation_degrees = -90.0 * (1.0 - _flip)
	var br := UiLevels.clamp01((v - UiLevels.UNLOCK_BURST.x) / (UiLevels.UNLOCK_BURST.y - UiLevels.UNLOCK_BURST.x))
	_burst.visible = br > 0.0 and br < 1.0
	_burst.modulate.a = 1.0 - br
	_burst.scale = Vector2.ONE * (0.6 + 1.1 * UiLevels.out3(br))
	if v >= UiLevels.UNLOCK_BUBBLE and not _bubble_sent:
		_bubble_sent = true
		unlock_bubble_due.emit()
	queue_redraw()
	if v >= UiLevels.UNLOCK_BURST.y:
		_finish_unlock()


func _shift(dx: float, k: float) -> void:
	if _button == null or not is_instance_valid(_button):
		return
	_button.position.x = _home_x + dx
	_button.pivot_offset = _button.size * 0.5
	_button.scale = Vector2.ONE * k


func _finish_unlock() -> void:
	unlocked = true
	_flip = 1.0
	_end_anim()


func _end_anim() -> void:
	_anim = ""
	set_process(false)
	if _button != null and is_instance_valid(_button):
		_button.position.x = _home_x
		_button.scale = Vector2.ONE
	_sync_parts()
	queue_redraw()


## Djeca (katanac, prstenovi, prsten fx) prate stanje kad animacija ne traje.
func _sync_parts() -> void:
	if not _anim.is_empty():
		return
	_shackle.visible = not unlocked
	_body.visible = not unlocked
	_shackle.position = UiLevels.BTN_SHACKLE.position
	_shackle.rotation = 0.0
	_shackle.modulate.a = 1.0
	_body.scale = Vector2.ONE
	_body.modulate.a = 1.0
	_rings.visible = unlocked
	_rings.scale = Vector2.ONE
	_rings.rotation = 0.0
	_burst.visible = false
	_place_rings()


func _place_rings() -> void:
	var lw := UiPopups.text_w(900, 38, UiLevels.S_ENDLESS)
	var row := OPEN_RINGS.x + 12.0 + lw
	_rings.position = Vector2((size.x - row) * 0.5, (size.y - OPEN_RINGS.y) * 0.5)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_place_rings()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var show_locked := not unlocked or _flip < 1.0
	if show_locked and _flip < 1.0:
		_draw_locked()
	if _flip > 0.0:
		# Krem → lavanda: lavanda ploča preko krem (alfa 2 × flip), pa sadržaj otključanog.
		var a := UiLevels.clamp01(_flip * 2.0) if not unlocked or not _anim.is_empty() else 1.0
		if not _anim.is_empty():
			var sb := UiHomeField.sticker(UiLevels.LAVENDER, 28, false)
			sb.bg_color.a = a
			sb.border_color.a = a
			draw_style_box(sb, r)
		var lw := UiPopups.text_w(900, 38, UiLevels.S_ENDLESS)
		var row := OPEN_RINGS.x + 12.0 + lw
		var x := (size.x - row) * 0.5 + OPEN_RINGS.x + 12.0
		UiPopups.draw_text(self, 900, 38, UiLevels.S_ENDLESS, Vector2(x, r.get_center().y - 19.0), Color(UiLevels.INK, a))
	var best := best_text()
	if not best.is_empty() and _anim.is_empty():
		_draw_best(best)


func _draw_locked() -> void:
	var ring := UiLevels.BTN_RING
	var c := ring.get_center()
	var rad := UiLevels.BTN_RING_R
	draw_arc(c, rad, 0.0, TAU, 48, UiLevels.INK_18, 9.0, true)
	if progress > 0:
		var a0 := -PI * 0.5
		var a1 := a0 + TAU * float(progress) / float(UiLevels.UNLOCK_LEVEL)
		var steps := maxi(4, int(48.0 * float(progress) / float(UiLevels.UNLOCK_LEVEL)))
		draw_arc(c, rad, a0, a1, steps, UiLevels.INK, 13.0, true)
		draw_circle(c + Vector2(cos(a0), sin(a0)) * rad, 6.5, UiLevels.INK)
		draw_circle(c + Vector2(cos(a1), sin(a1)) * rad, 6.5, UiLevels.INK)
		draw_arc(c, rad, a0, a1, steps, UiLevels.MINT, 7.0, true)
		draw_circle(c + Vector2(cos(a0), sin(a0)) * rad, 3.5, UiLevels.MINT)
		draw_circle(c + Vector2(cos(a1), sin(a1)) * rad, 3.5, UiLevels.MINT)
	var y := (size.y - (28.0 + 6.0 + 40.0)) * 0.5
	UiPopups.draw_text(self, 900, 28, UiLevels.S_ENDLESS, Vector2(LABEL_X, y), UiLevels.SOFT)
	# „14 / 15" u 40 px je širi od mjesta desno od prstena — smanji da stane (min 30).
	var room := size.x - LABEL_X - LABEL_PAD_R
	var px := 40.0
	var tw := UiHomeV3.text_w(900, px, progress_text(), 0.0, true)
	if tw > room:
		px = maxf(30.0, px * room / tw)
	UiHomeV3.draw_text(self, 900, px, progress_text(), Vector2(LABEL_X, y + 34.0 + (40.0 - px) * 0.5), UiLevels.INK, 0.0, true)


## B8: krem pločica „🏆 3:12" (180 × 48) na dnu dugmeta.
func _draw_best(text: String) -> void:
	var r := UiLevels.BTN_BEST
	UiHomeV3.draw_panel(self, r, UiLevels.CREAM, 24.0, 3.0, UiLevels.INK)
	var trophy := UiLevels.tex("endless/trophy.svg")
	var tw := UiHomeV3.text_w(900, 28, text, 0.0, true)
	var x := r.get_center().x - (30.0 + 8.0 + tw) * 0.5
	if trophy:
		draw_texture_rect(trophy, Rect2(x, r.get_center().y - 15.0, 30.0, 30.0), false)
	UiHomeV3.draw_text(self, 900, 28, text, Vector2(x + 38.0, r.get_center().y - 14.0), UiLevels.INK, 0.0, true)
