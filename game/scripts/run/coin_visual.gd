extends Node2D

## Novčić na stazi (design_handoff_run_pickups · pickup_fx.json → idle.coin): sjena, novčić koji
## se povremeno okrene (frejm coin_edge kad je „na ivici") i blijesak iskrice. Tri Sprite2D iz
## atlasa, samo transformi — ništa se ne crta po frejmu. Parametri se čitaju jednom (_ready).
## Kolizija ostaje r 18 na roditelju.

var _t: float = 0.0
var _ph: float = 0.0
var _edge: bool = false
var _shadow: Sprite2D
var _coin: Sprite2D
var _glint: Sprite2D
var _tex_coin: Texture2D
var _tex_edge: Texture2D
var _bob_amp: float = 5.0
var _bob_w: float = 2.6
var _period: float = 1.6
var _turn: float = 0.48
var _g_t0: float = 0.62
var _g_t1: float = 0.92
var _g_at: Vector2 = Vector2(30, -30)
var _g_r0: float = 0.0
var _g_r1: float = 90.0
var _g_s: PackedFloat32Array


func _ready() -> void:
	var idle: Dictionary = PickupArt.data()["idle"].get("coin", {})
	var bob: Dictionary = idle.get("bob", {})
	_bob_amp = float(bob.get("amp", 5))
	_bob_w = float(bob.get("w", 2.6))
	var spin: Dictionary = idle.get("spin", {})
	_period = float(spin.get("period", 1.6))
	_turn = float(spin.get("turn", 0.48))
	var g: Dictionary = idle.get("glint", {})
	var gt: Array = g.get("t", [0.62, 0.92])
	_g_t0 = float(gt[0])
	_g_t1 = float(gt[1])
	var gat: Array = g.get("at", [30, -30])
	_g_at = Vector2(float(gat[0]), float(gat[1]))
	var gr: Array = g.get("r", [0, 90])
	_g_r0 = float(gr[0])
	_g_r1 = float(gr[1])
	_g_s = PickupArt.compile_track(g.get("s"))
	_tex_coin = PickupArt.tex("coin")
	_tex_edge = PickupArt.tex("coin_edge")
	_ph = randf()
	_shadow = _sprite(PickupArt.tex("shadow"))
	var sh: Array = idle.get("shadow", {}).get("at", [0, 40])
	_shadow.position = Vector2(float(sh[0]), float(sh[1]))
	_coin = _sprite(_tex_coin)
	_glint = _sprite(PickupArt.tex("spark"))
	_glint.visible = false
	_step(0.0)


func _sprite(tex: Texture2D) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	add_child(s)
	return s


func _process(delta: float) -> void:
	_t += delta
	_step(_t)


func _step(t: float) -> void:
	var dy := _bob_amp * sin(_bob_w * t + _ph * TAU)
	var cyc := fmod(t + _ph * _period, _period)
	var u := cyc / _turn
	var sx := 1.0
	var edge := false
	if u < 1.0:
		var c := absf(cos(TAU * u))
		sx = maxf(0.12, c)
		edge = c < 0.25
	if edge != _edge:
		_edge = edge
		_coin.texture = _tex_edge if edge else _tex_coin
	_coin.transform = Transform2D(Vector2(1.0 if edge else sx, 0.0), Vector2(0.0, 1.0), Vector2(0.0, dy))
	var f := cyc / _period
	var on := f >= _g_t0 and f <= _g_t1
	if on != _glint.visible:
		_glint.visible = on
	if on:
		var s := PickupArt.eval_track(_g_s, f, 0.0)
		_glint.transform = Transform2D(
			deg_to_rad(lerpf(_g_r0, _g_r1, (f - _g_t0) / (_g_t1 - _g_t0))), Vector2(s, s), 0.0,
			Vector2(_g_at.x, _g_at.y + dy)
		)
