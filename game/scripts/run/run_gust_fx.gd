class_name RunGustFx
extends Node2D

## A3 · nalet ubrzanja (design_handoff_leveli_endless · run_difficulty.json → gust), bez teksta:
## 5 krem linija niz šavove / ivice staza putuje 900 px (0,36 s, pomak 0,03 s), Pip se spljošti
## (scale.y 1 → 0,88 → 1, 0,30 s) i staza skoči prema Pipu (50 px × jačina, 0,24 s). Ukupno 0,42 s.
## Skok staze ne radi ovaj čvor: run_controller svaki frejm uzme `surge_step()` px i pomjeri
## svijet i pozadinu (kao da je brzina na tren veća) — pa pauza i kraj runa vrijede i za nalet.
## Bazen od 5 sprite-ova stvoren jednom; po frejmu samo transform / alpha dok traje.

var _streaks: Array[Sprite2D] = []
var _t: float = -1.0
var _pip: Node2D
var _world: Node2D
var _s: float = 1.0
var _strength: float = 1.0
## Koliko je px skoka već predato kontroleru i koliko ih je ukupno u ovom naletu.
var _surge_done: float = 0.0
var _surge_total: float = 0.0
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


## `strength`: brzina staze / osnovna brzina (1 = level 1); jači nalet na višim levelima.
func play(ui_scale: float, strength: float = 1.0) -> void:
	if UiPip.reduce_motion():
		return
	_s = ui_scale
	_strength = clampf(strength, 1.0, UiLevels.GUST_STRENGTH_MAX)
	_surge_done = 0.0
	_surge_total = UiLevels.GUST_JOLT_PX * _s * _strength
	_t = 0.0
	played += 1
	set_process(true)


func is_playing() -> bool:
	return _t >= 0.0


## Novi run: prekini efekat i zaboravi ostatak skoka (ne smije preći u sljedeći run).
func reset() -> void:
	stop()
	_surge_done = 0.0
	_surge_total = 0.0


func strength() -> float:
	return _strength


## Px za koje staza treba skočiti od prošlog poziva (out-cubic kroz GUST_JOLT). Kad nalet
## završi, vrati ostatak jednom — ukupno uvijek tačno `_surge_total`.
func surge_step() -> float:
	if _surge_done >= _surge_total:
		return 0.0
	var want := _surge_total
	if _t >= 0.0:
		want = _surge_total * UiLevels.out3(UiLevels.clamp01(_t / UiLevels.GUST_JOLT))
	var step := maxf(0.0, want - _surge_done)
	_surge_done += step
	return step


## Pauza runa: nalet stoji (inače bi poslije pauze staza skočila odjednom).
func set_paused(paused: bool) -> void:
	set_process(not paused and _t >= 0.0)


func live_sprites() -> int:
	var n := 0
	for sp in _streaks:
		if sp.visible:
			n += 1
	return n


## Kraj efekta. Ostatak skoka (ako ga ima) kontroler još pokupi kroz surge_step().
func stop() -> void:
	_t = -1.0
	set_process(false)
	for sp in _streaks:
		sp.visible = false
	if is_instance_valid(_pip):
		_pip.scale = Vector2.ONE


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
		sp.scale = Vector2(_s * (1.0 + 0.5 * (_strength - 1.0)), (0.5 + 0.8 * b) * _s * (1.0 + 0.25 * (_strength - 1.0)))
		sp.modulate.a = UiLevels.GUST_ALPHA * b
	if is_instance_valid(_pip):
		_pip.scale = Vector2(1.0, 1.0 - UiLevels.GUST_LEAN_Y * UiLevels.bell(u, 0.0, UiLevels.GUST_LEAN))
	if not any and u >= UiLevels.GUST_TOTAL:
		stop()
