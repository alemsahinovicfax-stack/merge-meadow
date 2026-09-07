extends RefCounted

## Blink + shake presets for Home chrome (basket vs daily chest).

enum Kind { BASKET, CHEST }

var kind: Kind = Kind.BASKET
var active: bool = false

var _target: Control = null
var _t: float = 0.0
var _rest_x: float = 0.0


func bind(target: Control, attention_kind: Kind) -> void:
	_target = target
	kind = attention_kind
	if _target == null:
		return
	_target.pivot_offset = _target.size * 0.5
	_rest_x = _target.position.x
	if not _target.resized.is_connected(_on_resized):
		_target.resized.connect(_on_resized)


func set_active(on: bool) -> void:
	if active == on:
		if on:
			return
	active = on
	_t = 0.0
	if not on:
		_reset_visual()


func tick(delta: float) -> void:
	if not active or _target == null:
		return
	_t += delta
	_target.pivot_offset = _target.size * 0.5
	if kind == Kind.BASKET:
		_tick_basket()
	else:
		_tick_chest()


func _tick_basket() -> void:
	var wave := 0.5 + 0.5 * sin(_t * 1.55)
	_target.modulate = Color.WHITE.lerp(Color(1.14, 0.90, 0.48), wave * 0.62)
	var cycle := fmod(_t, 2.5)
	var shake := 0.0
	if cycle < 0.32:
		shake = sin(cycle * 38.0) * 0.045
	_target.rotation = shake
	_target.scale = Vector2.ONE


func _tick_chest() -> void:
	var wave := 0.5 + 0.5 * sin(_t * 3.15)
	_target.modulate = Color.WHITE.lerp(Color(1.22, 1.10, 0.72), wave * 0.78)
	var cycle := fmod(_t, 1.7)
	var tilt := 0.0
	var pop := 1.0
	if cycle < 0.24:
		tilt = sin(cycle * 52.0) * 0.07
		pop = 1.0 + absf(sin(cycle * 40.0)) * 0.05
	_target.rotation = tilt
	_target.scale = Vector2(pop, pop)


func _reset_visual() -> void:
	if _target == null:
		return
	_target.modulate = Color.WHITE
	_target.rotation = 0.0
	_target.scale = Vector2.ONE


func _on_resized() -> void:
	if _target == null:
		return
	_target.pivot_offset = _target.size * 0.5
	if not active:
		_rest_x = _target.position.x
