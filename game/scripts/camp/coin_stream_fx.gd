class_name CoinStreamFx
extends Node2D

## Letači novčića Campa (FIX-TEL-2 2026-11-12) — isti recept kao pickupi u runu (PickupFx), gdje
## skupljanje ide glatko: bazen Sprite2D stvoren jednom, jedan _process za sve letače, samo
## transformi. Ranije je svaki trejd pravio Tween na Control čvoru + prsten (Panel) s drugim
## Tweenom na dolasku; dok se dugme drži to je 10 puta u sekundi.
## Let: luk od dugmeta do coin chipa u headeru (quad-in, skala 1 → 0,7), a na dolasku chip
## kratko poskoči (skala 1 → 1,06 → 1) — bez novih čvorova.
## Čvor je top_level dijete huba: pozicije su globalne (kanvas), iznad stranica (z 100).

const NODE_NAME := "CoinStream"
const POOL := 5
const COIN_PX := 44.0
const FLY_SEC := 0.30
const ARC := 0.16
const END_SCALE := 0.7
const BUMP_SEC := 0.14
const BUMP_GROW := 0.06

var _sprites: Array[Sprite2D] = []
var _busy: PackedByteArray = PackedByteArray()
var _t: PackedFloat32Array = PackedFloat32Array()
var _from: PackedVector2Array = PackedVector2Array()
var _to: PackedVector2Array = PackedVector2Array()
var _base_scale: float = 1.0
var _chip: Control
var _bump_t: float = -1.0
## Ukupno lansirano / stiglo (testovi).
var launched: int = 0
var arrived: int = 0


## Nađi ili napravi tok novčića na hubu.
static func on(hub: Node, tex: Texture2D) -> CoinStreamFx:
	var found := hub.get_node_or_null(NODE_NAME) as CoinStreamFx
	if found != null:
		return found
	var fx := CoinStreamFx.new()
	fx.name = NODE_NAME
	fx.top_level = true
	fx.z_index = 100
	hub.add_child(fx)
	fx._build(tex)
	return fx


func _build(tex: Texture2D) -> void:
	set_process(false)
	_base_scale = COIN_PX / maxf(1.0, tex.get_size().x) if tex != null else 1.0
	for i in POOL:
		var s := Sprite2D.new()
		s.texture = tex
		s.visible = false
		add_child(s)
		_sprites.append(s)
	_busy.resize(POOL)
	_t.resize(POOL)
	_from.resize(POOL)
	_to.resize(POOL)


func live_count() -> int:
	var n := 0
	for b in _busy:
		n += int(b)
	return n


## Novčić od `from_global` do centra chipa. false = bazen je pun (novčić se preskače, broj u
## headeru se svejedno mijenja odmah).
func launch(from_global: Vector2, chip: Control) -> bool:
	if chip == null or not is_instance_valid(chip):
		return false
	for i in POOL:
		if _busy[i] == 0:
			_busy[i] = 1
			_t[i] = 0.0
			_from[i] = from_global
			_to[i] = chip.get_global_rect().get_center()
			_chip = chip
			var s := _sprites[i]
			s.position = from_global
			s.scale = Vector2.ONE * _base_scale
			s.visible = true
			launched += 1
			set_process(true)
			return true
	return false


func _process(delta: float) -> void:
	var any := false
	for i in POOL:
		if _busy[i] == 0:
			continue
		var t := _t[i] + delta
		_t[i] = t
		var u := clampf(t / FLY_SEC, 0.0, 1.0)
		var s := _sprites[i]
		if u >= 1.0:
			_busy[i] = 0
			s.visible = false
			arrived += 1
			_bump_t = 0.0
			continue
		any = true
		var e := u * u
		var a := _from[i]
		var b := _to[i]
		var side := (b - a).orthogonal() * (ARC * sin(PI * u))
		s.position = a.lerp(b, e) + side
		s.scale = Vector2.ONE * (_base_scale * lerpf(1.0, END_SCALE, u))
	if _bump_t >= 0.0:
		_bump_t += delta
		var k := clampf(_bump_t / BUMP_SEC, 0.0, 1.0)
		if is_instance_valid(_chip):
			_chip.pivot_offset = _chip.size * 0.5
			_chip.scale = Vector2.ONE * (1.0 + BUMP_GROW * sin(PI * k))
		if k >= 1.0:
			_bump_t = -1.0
			if is_instance_valid(_chip):
				_chip.scale = Vector2.ONE
		else:
			any = true
	if not any:
		set_process(false)
