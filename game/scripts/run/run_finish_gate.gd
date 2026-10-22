class_name RunFinishGate
extends Node2D

## A6 · cilj na kraju levela (design_handoff_leveli_endless · level_finish.json). Dva stuba +
## sezonski luk + mint traka preko sve 3 staze; bez ovratnika, sjene i sudara (nije prepreka).
## Ishodište čvora = linija trake (y), x = lijeva ivica ekrana. Pojavi se na y −80 kad preostali
## put do kraja levela padne na 1654 px (RunController.remaining_distance, sa stepenicama brzine)
## i vozi se sa svijetom, pa traka pređe Pipa tačno na kraju. Prolaz: traka pukne na dvije
## polovine (78°, back-out 0,36 s + 3 prigušena zamaha 0,5 s), luk poskoči 1,06 (0,24 s), 10 konfeta
## iz Pipa (0,9 s). 4 sprite-a dok vozi, 12 u prolazu.

const CONFETTI := ["confetti_mint", "confetti_peach", "confetti_lav"]
const CONFETTI_SIZE := 26.0

var season_id: String = ""
var _s: float = 1.0
var _arch: Sprite2D
var _posts: Array[Sprite2D] = []
var _tape: Sprite2D
var _halves: Array[Sprite2D] = []
var _confetti: Array[Sprite2D] = []
var _origin := Vector2.ZERO
var _t: float = -1.0


func _init() -> void:
	name = "FinishGate"
	set_process(false)


func setup(p_season_id: String, ui_scale: float) -> RunFinishGate:
	season_id = p_season_id
	_s = ui_scale
	var post_tex := UiLevels.gate_tex(season_id, "post")
	for i in 2:
		var p := _sprite(post_tex)
		p.position = Vector2(float(UiLevels.GATE_POST_X[i]), UiLevels.GATE_POST_TOP) * _s
		p.flip_h = i == 1
		_posts.append(p)
	_arch = _sprite(UiLevels.gate_tex(season_id, "arch"))
	_arch.offset = -UiLevels.GATE_ARCH_PIVOT
	_arch.position = (UiLevels.GATE_ARCH.position + UiLevels.GATE_ARCH_PIVOT) * _s
	_tape = _sprite(UiLevels.tex("finish/tape.svg"))
	_tape.position = UiLevels.GATE_TAPE.position * _s
	var half := UiLevels.tex("finish/tape_half.svg")
	for i in 2:
		var h := _sprite(half)
		h.offset = -UiLevels.GATE_HALF_PIVOT
		h.position = Vector2(float(UiLevels.GATE_HALF_X[i]) + UiLevels.GATE_HALF_PIVOT.x, 0.0) * _s
		if i == 1:
			h.scale.x = -_s
		h.visible = false
		_halves.append(h)
	return self


func _sprite(tex: Texture2D) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.centered = false
	sp.scale = Vector2.ONE * _s
	add_child(sp)
	return sp


func has_art() -> bool:
	return _arch != null and _arch.texture != null and _tape.texture != null


func is_broken() -> bool:
	return _t >= 0.0


## Sprite-ovi koji se trenutno crtaju (budžet: 4 dok vozi, ≤ 12 u prolazu).
func live_sprites() -> int:
	var n := 0
	for c in get_children():
		if (c as CanvasItem).visible:
			n += 1
	for c in _confetti:
		if c.visible:
			n += 1
	return n


## Prolaz kroz cilj (početak _play_finish_beat). Konfete idu u `fx_parent` (prate ekran, ne svijet).
func pass_through(fx_parent: Node2D, pip_pos: Vector2) -> void:
	if _t >= 0.0:
		return
	_origin = pip_pos
	_tape.visible = false
	for h in _halves:
		h.visible = true
	if _confetti.is_empty() and fx_parent != null:
		for i in UiLevels.FINISH_CONFETTI_N:
			var c := Sprite2D.new()
			c.texture = LevelPathKit.fx_tex(str(CONFETTI[i % 3]))
			c.scale = Vector2.ONE * _s * CONFETTI_SIZE / maxf(1.0, c.texture.get_size().x if c.texture else CONFETTI_SIZE)
			c.visible = false
			fx_parent.add_child(c)
			_confetti.append(c)
	_t = 0.0
	_apply(0.0)
	set_process(true)


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — miruj dok efekat ne krene.
	if _t < 0.0:
		set_process(false)
		return
	_t += delta
	_apply(_t)
	if _t >= maxf(UiLevels.FINISH_CONFETTI, UiLevels.FINISH_TAPE + UiLevels.FINISH_FLAP):
		set_process(false)
		for c in _confetti:
			c.visible = false


func _exit_tree() -> void:
	for c in _confetti:
		if is_instance_valid(c):
			c.queue_free()
	_confetti.clear()


func _apply(u: float) -> void:
	var tv := UiLevels.out_back(UiLevels.clamp01(u / UiLevels.FINISH_TAPE))
	var fk := UiLevels.clamp01((u - UiLevels.FINISH_TAPE) / UiLevels.FINISH_FLAP)
	var flap := sin(fk * PI * 3.0) * (1.0 - fk)
	var deg := UiLevels.FINISH_TAPE_DEG * tv + UiLevels.FINISH_FLAP_DEG * flap
	_halves[0].rotation_degrees = deg
	# Desna polovina je zrcaljena (scale.x −1), pa isti vizuelni zamah traži suprotan ugao.
	_halves[1].rotation_degrees = -deg
	_arch.scale = Vector2(_s, _s * (1.0 + (UiLevels.FINISH_ARCH_BUMP - 1.0) * UiLevels.bell(u, 0.0, UiLevels.FINISH_ARCH)))
	var v := UiLevels.clamp01(u / UiLevels.FINISH_CONFETTI)
	for i in _confetti.size():
		var c := _confetti[i]
		c.visible = v < 1.0
		if not c.visible:
			continue
		var a := deg_to_rad(-170.0 + float(i) * 18.0)
		var d := (260.0 + float(i % 4) * 60.0) * UiLevels.out3(v)
		c.position = _origin + Vector2(cos(a) * d, -47.0 + sin(a) * d + 420.0 * UiLevels.in2(v)) * _s
		c.rotation_degrees = 400.0 * v * (1.0 if i % 2 == 1 else -1.0)
		c.modulate.a = 1.0 - UiLevels.clamp01((v - 0.8) / 0.2)
