class_name RunEndlessChip
extends Control

## B3 · Endless HUD u LevelChipu (design_handoff_leveli_endless · endless_ui.json → hud): dva reda
## u 128 px — prstenovi + sat (52/900, tabular, min 112) + pilula „Pace N" u boji toplote / trofej +
## „Best 4:25" (ili mint „New best!" poslije rekorda). Bez trake napretka. Crta se kad se promijeni
## sekunda (sat), stepenica ili rekord; trzaj pilule „Pace" (1,25, 0,2 s) jedini traži frejmove.

const ROW_GAP := 6.0
const ROW1_H := 52.0
const ROW2_H := 36.0
const GAP := 10.0
const PACE_PAD := 14.0
const PACE_BUMP := 0.25
const PACE_BUMP_SEC := 0.2

var clock_sec: int = 0
var tier: int = 0
## 0 = još nema rekorda (red sakriven).
var best_sec: float = 0.0
var new_best: bool = false

var _bump_t: float = -1.0


func _init() -> void:
	name = "EndlessChip"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func set_state(p_clock: int, p_tier: int, p_best: float, p_new_best: bool) -> void:
	var changed := p_clock != clock_sec or p_tier != tier or not is_equal_approx(p_best, best_sec) or p_new_best != new_best
	clock_sec = p_clock
	tier = p_tier
	best_sec = p_best
	new_best = p_new_best
	if changed:
		custom_minimum_size = Vector2(content_width(), UiRun.TOP_HUD_H)
		queue_redraw()


func bump_pace() -> void:
	if UiPip.reduce_motion():
		return
	_bump_t = 0.0
	set_process(true)


func clock_text() -> String:
	return UiLevels.clock(float(clock_sec))


func pace_text() -> String:
	return UiLevels.S_PACE % tier


func best_text() -> String:
	if new_best:
		return UiLevels.S_NEW_BEST
	return UiLevels.S_BEST % UiLevels.clock(best_sec) if best_sec > 0.0 else ""


func shows_best_row() -> bool:
	return new_best or best_sec > 0.0


func content_width() -> float:
	var row1 := UiLevels.HUD_RINGS.x + GAP + _clock_w() + GAP + _pace_w()
	var row2 := 0.0
	if new_best:
		row2 = _new_best_w()
	elif best_sec > 0.0:
		row2 = UiLevels.HUD_TROPHY + 8.0 + UiPopups.text_w(800, UiLevels.HUD_BEST_FONT, best_text())
	return maxf(row1, row2)


func _clock_w() -> float:
	return maxf(UiLevels.HUD_CLOCK_MIN_W, UiHomeV3.text_w(900, UiLevels.HUD_CLOCK_FONT, clock_text(), 0.0, true))


func _pace_w() -> float:
	return PACE_PAD * 2.0 + UiPopups.text_w(900, UiLevels.HUD_PACE_FONT, pace_text()) + 6.0


func _new_best_w() -> float:
	return 14.0 + 26.0 + 6.0 + UiPopups.text_w(900, UiLevels.HUD_NEW_BEST_FONT, UiLevels.S_NEW_BEST) + 14.0 + 6.0


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — miruj dok efekat ne krene.
	if _bump_t < 0.0:
		set_process(false)
		return
	_bump_t += delta
	queue_redraw()
	if _bump_t >= PACE_BUMP_SEC:
		_bump_t = -1.0
		set_process(false)


func _draw() -> void:
	var two := shows_best_row()
	var block := ROW1_H + (ROW_GAP + ROW2_H if two else 0.0)
	var y0 := (size.y - block) * 0.5
	var cy := y0 + ROW1_H * 0.5
	var x := 0.0
	var rings := UiLevels.tex("endless/rings.svg")
	if rings:
		draw_texture_rect(rings, Rect2(Vector2(x, cy - UiLevels.HUD_RINGS.y * 0.5), UiLevels.HUD_RINGS), false)
	x += UiLevels.HUD_RINGS.x + GAP
	UiHomeV3.draw_text(self, 900, UiLevels.HUD_CLOCK_FONT, clock_text(), Vector2(x, cy - UiLevels.HUD_CLOCK_FONT * 0.5), UiLevels.INK, 0.0, true)
	x += _clock_w() + GAP
	var pw := _pace_w()
	var pr := Rect2(x, cy - UiLevels.HUD_PACE_H * 0.5, pw, UiLevels.HUD_PACE_H)
	var k := 1.0 + PACE_BUMP * UiLevels.bell(_bump_t, 0.0, PACE_BUMP_SEC) if _bump_t >= 0.0 else 1.0
	if k > 1.001:
		draw_set_transform(pr.get_center() * (1.0 - k), 0.0, Vector2(k, k))
	draw_style_box(UiPopups._box(UiLevels.band_fill(UiLevels.pace_band(tier)), int(UiLevels.HUD_PACE_H * 0.5), 3), pr)
	UiPopups.draw_text_centered(self, 900, UiLevels.HUD_PACE_FONT, pace_text(), pr, UiLevels.INK)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if not two:
		return
	var cy2 := y0 + ROW1_H + ROW_GAP + ROW2_H * 0.5
	var trophy := UiLevels.tex("endless/trophy.svg")
	if new_best:
		var nr := Rect2(0.0, cy2 - UiLevels.HUD_NEW_BEST_H * 0.5, _new_best_w(), UiLevels.HUD_NEW_BEST_H)
		draw_style_box(UiPopups._box(UiLevels.MINT, int(UiLevels.HUD_NEW_BEST_H * 0.5), 3), nr)
		if trophy:
			draw_texture_rect(trophy, Rect2(nr.position.x + 14.0, cy2 - 13.0, 26.0, 26.0), false)
		UiPopups.draw_text(self, 900, UiLevels.HUD_NEW_BEST_FONT, UiLevels.S_NEW_BEST, Vector2(nr.position.x + 14.0 + 26.0 + 6.0, cy2 - UiLevels.HUD_NEW_BEST_FONT * 0.5), UiLevels.INK)
		return
	if trophy:
		draw_texture_rect(trophy, Rect2(0.0, cy2 - UiLevels.HUD_TROPHY * 0.5, UiLevels.HUD_TROPHY, UiLevels.HUD_TROPHY), false)
	UiPopups.draw_text(self, 800, UiLevels.HUD_BEST_FONT, best_text(), Vector2(UiLevels.HUD_TROPHY + 8.0, cy2 - UiLevels.HUD_BEST_FONT * 0.5), UiLevels.SOFT)


## B7 · zaglavlje pauze u Endlessu: prstenovi 64 × 36 · sat 72/900 · pilula „Pace N" (h 64).
class PauseHeader extends Control:
	const H := 72.0
	const RINGS := Vector2(64, 36)
	const CLOCK_FONT := 72
	const PILL_H := 64.0
	const PILL_FONT := 36
	const GAP := 16.0

	var clock_text: String = "0:00"
	var tier: int = 0

	func _init() -> void:
		name = "EndlessPauseHeader"
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func setup(sec: float, p_tier: int) -> void:
		clock_text = UiLevels.clock(sec)
		tier = p_tier
		custom_minimum_size = Vector2(width(), H)
		queue_redraw()

	func pace_text() -> String:
		return UiLevels.S_PACE % tier

	func _clock_w() -> float:
		return UiHomeV3.text_w(900, CLOCK_FONT, clock_text, 0.0, true)

	func _pill_w() -> float:
		return 22.0 * 2.0 + UiPopups.text_w(900, PILL_FONT, pace_text())

	func width() -> float:
		return RINGS.x + GAP + _clock_w() + GAP + _pill_w()

	func _draw() -> void:
		var cy := size.y * 0.5
		var x := (size.x - width()) * 0.5
		var rings := UiLevels.tex("endless/rings.svg")
		if rings:
			draw_texture_rect(rings, Rect2(Vector2(x, cy - RINGS.y * 0.5), RINGS), false)
		x += RINGS.x + GAP
		UiHomeV3.draw_text(self, 900, CLOCK_FONT, clock_text, Vector2(x, cy - CLOCK_FONT * 0.5), UiLevels.INK, 0.0, true)
		x += _clock_w() + GAP
		var pr := Rect2(x, cy - PILL_H * 0.5, _pill_w(), PILL_H)
		draw_style_box(UiPopups._box(UiLevels.band_fill(UiLevels.pace_band(tier)), int(PILL_H * 0.5), 4), pr)
		UiPopups.draw_text_centered(self, 900, PILL_FONT, pace_text(), pr, UiLevels.INK)
