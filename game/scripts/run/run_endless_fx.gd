class_name RunEndlessFx
extends Control

## Endless trenuci (design_handoff_leveli_endless · endless_ui.json), u px baze 1080 iznad HUD-a:
## B4 · nova stepenica — pilula „⇈ Pace 9" ispod LevelChipa (h 88, boja toplote), 0,92 s;
## B5 · novi rekord — oko LevelChipa (nikad preko staze ispred Pipa): prsten + trofej + 8 konfeta
## 0,9 s, chip se trzne 1,1. Sprite-ovi u bazenu (stvaraju se jednom); po frejmu samo transform.

const CONFETTI := ["confetti_mint", "confetti_peach", "confetti_lav"]
const PILL_PAD := Vector2(18, 30)
const PILL_GAP := 12.0

var tier: int = 0
## Gornji lijevi ugao i širina LevelChipa (px baze) — sidro rekorda.
var chip_rect := Rect2(40, 60, 200, 128)
var top_offset: float = 0.0

var _pill: _Pill
var _pace_t: float = -1.0
var _best_t: float = -1.0
var _ring: Sprite2D
var _trophy: Sprite2D
var _confetti: Array[Sprite2D] = []
var _chip: Control
## Brojači za testove.
var pace_played: int = 0
var best_played: int = 0


func _init() -> void:
	name = "EndlessFx"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill = _Pill.new()
	_pill.fx = self
	_pill.visible = false
	add_child(_pill)
	set_process(false)


func play_pace(p_tier: int, offset_y: float) -> void:
	tier = p_tier
	top_offset = offset_y
	pace_played += 1
	_pill.queue_redraw()
	_pill.size = Vector2(_pill.width(), UiLevels.PACE_PILL_H)
	_pill.pivot_offset = Vector2(_pill.size.x * 0.2, 0.0)
	_pace_t = 0.0
	_apply_pace(0.0)
	set_process(true)


func play_best(p_chip_rect: Rect2, chip: Control) -> void:
	chip_rect = p_chip_rect
	_chip = chip
	best_played += 1
	if UiPip.reduce_motion():
		return
	_ensure_best_sprites()
	_best_t = 0.0
	_apply_best(0.0)
	set_process(true)


func pill_text() -> String:
	return UiLevels.S_PACE % tier


func is_pace_visible() -> bool:
	return _pill.visible


func live_sprites() -> int:
	var n := 3 if _pill.visible else 0
	for sp in [_ring, _trophy]:
		if sp != null and (sp as Sprite2D).visible:
			n += 1
	for c in _confetti:
		if c.visible:
			n += 1
	return n


func _ensure_best_sprites() -> void:
	if _ring != null:
		return
	_ring = _sprite(UiLevels.tex("fx/burst_ring.svg"))
	_trophy = _sprite(UiLevels.tex("endless/trophy.svg"))
	for i in UiLevels.BEST_CONFETTI_N:
		_confetti.append(_sprite(LevelPathKit.fx_tex(str(CONFETTI[i % 3]))))


func _sprite(tex: Texture2D) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.visible = false
	add_child(sp)
	return sp


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — miruj dok efekat ne krene.
	if _pace_t < 0.0 and _best_t < 0.0:
		set_process(false)
		return
	if _pace_t >= 0.0:
		_pace_t += delta
		_apply_pace(_pace_t)
		if _pace_t >= UiLevels.PACE_TOTAL:
			_pace_t = -1.0
			_pill.visible = false
	if _best_t >= 0.0:
		_best_t += delta
		_apply_best(_best_t)
		if _best_t >= UiLevels.BEST_TOTAL:
			_best_t = -1.0
			for sp in [_ring, _trophy]:
				(sp as Sprite2D).visible = false
			for c in _confetti:
				c.visible = false
			if is_instance_valid(_chip):
				_chip.scale = Vector2.ONE
	if _pace_t < 0.0 and _best_t < 0.0:
		set_process(false)


func _apply_pace(u: float) -> void:
	var i := UiLevels.out_back(UiLevels.clamp01(u / UiLevels.PACE_IN))
	var o := UiLevels.clamp01((u - UiLevels.PACE_OUT.x) / (UiLevels.PACE_OUT.y - UiLevels.PACE_OUT.x))
	_pill.visible = u < UiLevels.PACE_TOTAL
	_pill.position = UiLevels.PACE_PILL_POS + Vector2(0.0, top_offset - 26.0 * (1.0 - i) - 30.0 * o)
	_pill.scale = Vector2.ONE * (0.8 + 0.2 * i)
	_pill.modulate.a = UiLevels.clamp01(u / 0.06) * (1.0 - o)


func _apply_best(u: float) -> void:
	var c := Vector2(chip_rect.position.x + chip_rect.size.x * 0.5, chip_rect.get_center().y)
	var rv := UiLevels.clamp01(u / UiLevels.BEST_RING)
	_ring.visible = rv < 1.0
	_ring.position = c
	_ring.scale = Vector2.ONE * (0.5 + 1.6 * UiLevels.out3(rv)) * 200.0 / maxf(1.0, _ring.texture.get_size().x if _ring.texture else 200.0)
	_ring.modulate.a = 1.0 - rv
	var tv := UiLevels.clamp01(u / UiLevels.BEST_TROPHY)
	_trophy.visible = u < UiLevels.BEST_TOTAL
	_trophy.position = Vector2(c.x + 150.0 + 32.0, chip_rect.position.y + 90.0 + 32.0 - 40.0 * UiLevels.out3(tv))
	var tk := 64.0 / maxf(1.0, _trophy.texture.get_size().x if _trophy.texture else 64.0)
	_trophy.scale = Vector2.ONE * tk * UiLevels.out_back(tv)
	_trophy.rotation_degrees = -12.0 + 12.0 * tv
	_trophy.modulate.a = 1.0 - UiLevels.clamp01((u - 0.7) / 0.2)
	var v := UiLevels.clamp01(u / UiLevels.BEST_CONFETTI)
	for i in _confetti.size():
		var e := _confetti[i]
		e.visible = v < 1.0
		var a := deg_to_rad(-160.0 + float(i) * 26.0)
		var d := (150.0 + float(i % 3) * 40.0) * UiLevels.out3(v)
		e.position = c + Vector2(cos(a) * d, sin(a) * d + 260.0 * UiLevels.in2(v))
		e.rotation_degrees = 360.0 * v * (1.0 if i % 2 == 1 else -1.0)
		e.scale = Vector2.ONE * 24.0 / maxf(1.0, e.texture.get_size().x if e.texture else 24.0)
		e.modulate.a = 1.0 - UiLevels.clamp01((v - 0.75) / 0.25)
	if is_instance_valid(_chip):
		_chip.pivot_offset = _chip.size * 0.5
		_chip.scale = Vector2.ONE * (1.0 + 0.1 * UiLevels.bell(u, 0.0, 0.24))


## Pilula nove stepenice: boja toplote, rub 4, tvrda sjena 6, ikona pace_up 40 + „Pace N" 48/900.
class _Pill extends Control:
	var fx: RunEndlessFx

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func width() -> float:
		return RunEndlessFx.PILL_PAD.x + UiLevels.PACE_PILL_ICON + RunEndlessFx.PILL_GAP \
			+ UiPopups.text_w(900, UiLevels.PACE_PILL_FONT, fx.pill_text()) + RunEndlessFx.PILL_PAD.y

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, Vector2(width(), UiLevels.PACE_PILL_H))
		var fill := UiLevels.band_fill(UiLevels.pace_band(fx.tier))
		var sb := UiPopups._hard_shadow(UiPopups._box(fill, int(UiLevels.PACE_PILL_H * 0.5), 4), 6, Color(0.039, 0.055, 0.047, 0.45))
		draw_style_box(sb, r)
		var x := RunEndlessFx.PILL_PAD.x
		var icon := UiLevels.tex("fx/pace_up.svg")
		var cy := r.get_center().y
		if icon:
			draw_texture_rect(icon, Rect2(x, cy - UiLevels.PACE_PILL_ICON * 0.5, UiLevels.PACE_PILL_ICON, UiLevels.PACE_PILL_ICON), false)
		x += UiLevels.PACE_PILL_ICON + RunEndlessFx.PILL_GAP
		UiPopups.draw_text(self, 900, UiLevels.PACE_PILL_FONT, fx.pill_text(), Vector2(x, cy - UiLevels.PACE_PILL_FONT * 0.5), UiLevels.INK)
