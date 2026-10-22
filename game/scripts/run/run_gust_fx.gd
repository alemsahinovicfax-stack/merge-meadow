class_name RunGustFx
extends Node2D

## A3 · nalet ubrzanja (design_handoff_leveli_endless · run_difficulty.json → gust), bez teksta:
## 5 krem linija niz šavove / ivice staza putuje 900 px (0,36 s, pomak 0,03 s), Pip se spljošti
## (scale.y 1 → 0,94 → 1, 0,30 s) i svijet trzne 10 px (0,16 s). Ukupno 0,42 s.
## Bazen od 5 sprite-ova stvoren jednom; po frejmu samo transform / alpha dok traje.

var _streaks: Array[Sprite2D] = []
var _t: float = -1.0
var _pip: Node2D
var _world: Node2D
var _s: float = 1.0
## Koliko je naleta odigrano (testovi).
var played: int = 0


func _init() -> void:
	name = "GustFx"
	set_process(false)


func setup(pip_visual: Node2D, world: Node2D) -> void:
	_pip = pip_visual
	_world = world
	var tex := UiLevels.tex("fx/gust_streak.svg")
	for i in UiLevels.GUST_X.size():
		var sp := Sprite2D.new()
		sp.texture = tex
		sp.visible = false
		add_child(sp)
		_streaks.append(sp)


func play(ui_scale: float) -> void:
	if UiPip.reduce_motion():
		return
	_s = ui_scale
	_t = 0.0
	played += 1
	set_process(true)


func is_playing() -> bool:
	return _t >= 0.0


func live_sprites() -> int:
	var n := 0
	for sp in _streaks:
		if sp.visible:
			n += 1
	return n


func stop() -> void:
	_t = -1.0
	set_process(false)
	for sp in _streaks:
		sp.visible = false
	if is_instance_valid(_pip):
		_pip.scale = Vector2.ONE
	if is_instance_valid(_world):
		_world.position.y = 0.0


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — miruj dok efekat ne krene.
	if _t < 0.0:
		set_process(false)
		return
	_t += delta
	var u := _t
	var any := false
	for i in _streaks.size():
		var sp := _streaks[i]
		var v := UiLevels.clamp01((u - float(i) * UiLevels.GUST_STAGGER) / UiLevels.GUST_STREAK)
		var on := v > 0.0 and v < 1.0
		sp.visible = on
		if not on:
			continue
		any = true
		var b := UiLevels.bell(v, 0.0, 1.0)
		var top := float(UiLevels.GUST_Y[i]) + UiLevels.GUST_TRAVEL * UiLevels.out3(v)
		sp.position = Vector2(float(UiLevels.GUST_X[i]), top + UiLevels.GUST_SIZE.y * 0.5) * _s
		sp.scale = Vector2(_s, (0.5 + 0.8 * b) * _s)
		sp.modulate.a = UiLevels.GUST_ALPHA * b
	if is_instance_valid(_pip):
		_pip.scale = Vector2(1.0, 1.0 - UiLevels.GUST_LEAN_Y * UiLevels.bell(u, 0.0, UiLevels.GUST_LEAN))
	if is_instance_valid(_world):
		_world.position.y = UiLevels.GUST_JOLT_PX * _s * UiLevels.bell(u, 0.0, UiLevels.GUST_JOLT)
	if not any and u >= UiLevels.GUST_TOTAL:
		stop()
