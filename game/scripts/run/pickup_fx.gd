class_name PickupFx
extends Node2D

## Dodir pickupa sa Pipom (design_handoff_run_pickups · pickup_fx.json). Pickup na stazi nestaje
## čim ga Pip / magnet dotakne (brojanje je odmah, kao prije), a ovaj čvor preuzima njegov izgled:
##   1. let do Pipa — luk do tačke C (nos / šape), 0,12–0,2 s, quad_in, skala → 0,85;
##   2. događaj (coin_n1…n5, seed_r1…r3[_twin]) — sprite-ovi s ključevima x / y / s / sx / sy / r / a,
##      sidra C i B prate Pipa svaki frejm; z < 2 ispod Pipa, z ≥ 2 iznad;
##   3. krem pilula „+1" / „+2" leti do čipa u HUD-u; tek kad stigne, broj na čipu raste.
## Svi sprite-ovi su iz bazena (Sprite2D iz jednog atlasa), samo transformi — nijedan _draw po frejmu,
## nijedan novi čvor po dodiru kad se bazen zagrije. Ključevi su unaprijed „kompajlirani" u
## PackedFloat32Array (PickupArt.events()), pa jedan _process za sve dodire ne čita Dictionary.

signal touch_started(touch: Touch)
signal pill_arrived(touch: Touch)

const UNDER_Z := [0, 1]
const PILL_LIFT := 40.0


## Jedan sprite iz bazena (sloj po z) i šta trenutno nosi.
class Slot:
	var node: Sprite2D
	var z: int
	var tex: Texture2D = null
	var base: float = 1.0


## Jedan dodir: let, događaj, pilula.
class Touch:
	var is_coin: bool = true
	var type_id: String = ""
	var rarity: int = 1
	var amount: int = 1
	var s0: Vector2
	var side: float = 1.0
	var t0: float = 0.0
	var tf: float = 0.15
	var te: float = 0.0
	var started: bool = false
	var arrived: bool = false
	var streak: int = 0
	var ev_id: String = ""
	var ev: PickupArt.CEvent = null
	var slots: Array = []
	var fly: Array = [null, null, null]
	var sapling: Texture2D = null
	var bloom: Texture2D = null
	var pill: PickupPill = null
	var pill_from: Vector2


var player: Node2D
var fly_layer: Node
var coin_target: Control
var seed_target: Control

var _under: Node2D
var _layers: Array[Node2D] = []
var _free: Array = []
var _free_pills: Array[PickupPill] = []
var _touches: Array[Touch] = []
var _clock: float = 0.0
var _last_coin_te: float = -9.0
var _streak: int = 0
var _pull: float = 0.0
var _anchor_c: Vector2
var _anchor_b: Vector2
var _fly_tmin: float = 0.12
var _fly_tmax: float = 0.2
var _fly_arc: float = 0.22
var _fly_scale_end: float = 0.85
var _flight_dur: float = 0.3
var _flight_s: PackedFloat32Array
var _flight_a: PackedFloat32Array
var _streak_window: float = 0.6
var _streak_max: int = 5
var _tex_coin: Texture2D
var _tex_soil: Texture2D
var _icon_coin: Texture2D
var _icon_seed: Texture2D
var _max_sprites: int = 0
var _live_sprites: int = 0


## `under` = prazan Node2D odmah ISPRED Playera u stablu (crta se ispod Pipa); ovaj čvor stoji
## odmah IZA Playera i iznad Pipa (PipVisual je na z 10).
func setup(p_player: Node2D, under: Node2D, p_fly_layer: Node, coin: Control, seed: Control) -> void:
	player = p_player
	_under = under
	z_index = 11
	fly_layer = p_fly_layer
	coin_target = coin
	seed_target = seed
	var d := PickupArt.data()
	_anchor_c = PickupArt.anchor("C")
	_anchor_b = PickupArt.anchor("B")
	var fly: Dictionary = d.get("magnet", {}).get("fly", {})
	_fly_tmin = float(fly.get("t_min", 0.12))
	_fly_tmax = float(fly.get("t_max", 0.2))
	_fly_arc = float(fly.get("arc", 0.22))
	_fly_scale_end = float(fly.get("scale_end", 0.85))
	var flight: Dictionary = d.get("hud", {}).get("flight", {})
	_flight_dur = float(flight.get("dur", 0.3))
	_flight_s = PickupArt.compile_track(flight.get("s"))
	_flight_a = PickupArt.compile_track(flight.get("a"))
	_streak_window = float(d.get("streak", {}).get("window", 0.6))
	_streak_max = int(d.get("streak", {}).get("max", 5))
	_tex_coin = PickupArt.tex("coin")
	_tex_soil = PickupArt.tex("soil")
	_icon_coin = UiAssets.get_chrome_icon("icon_coin")
	_icon_seed = UiAssets.get_chrome_icon("icon_seed")
	PickupArt.events()
	for z in 6:
		var parent: Node2D = _under if z in UNDER_Z else self
		var n := Node2D.new()
		n.name = "Z%d" % z
		parent.add_child(n)
		_layers.append(n)
		_free.append([])


## Zagrije bazen (prvi dodir u runu ne smije praviti čvorove).
func prewarm(per_layer: int = 6, pills: int = 4) -> void:
	for z in 6:
		for i in per_layer:
			var s := Sprite2D.new()
			s.visible = false
			_layers[z].add_child(s)
			(_free[z] as Array).append(s)
	for i in pills:
		var p := PickupPill.new()
		p.visible = false
		fly_layer.add_child(p)
		_free_pills.append(p)


func start_coin(at_global: Vector2) -> void:
	var t := Touch.new()
	_start(t, at_global)


func start_seed(type_id: String, rarity: int, amount: int, at_global: Vector2) -> void:
	var t := Touch.new()
	t.is_coin = false
	t.type_id = type_id
	t.rarity = clampi(rarity, 1, 3)
	t.amount = amount
	t.sapling = PickupArt.plant(type_id, 1)
	t.bloom = PickupArt.plant(type_id, 3)
	_start(t, at_global)


## Snaga trzaja magnetnog kruga (0…1) — prvih 0,1 s leta.
func get_pull() -> float:
	return _pull


func active_touches() -> int:
	return _touches.size()


func max_sprites() -> int:
	return _max_sprites


func clear() -> void:
	for t in _touches:
		_release_all(t)
	_touches.clear()


func _start(t: Touch, at_global: Vector2) -> void:
	if player == null:
		return
	t.s0 = to_local(at_global) - player.position
	t.tf = lerpf(_fly_tmin, _fly_tmax, clampf(t.s0.distance_to(_anchor_c) / 232.0, 0.0, 1.0))
	if is_zero_approx(t.s0.x):
		t.side = 1.0 if _touches.size() % 2 == 0 else -1.0
	else:
		t.side = signf(t.s0.x)
	t.t0 = _clock
	t.te = _clock + t.tf
	_touches.append(t)


func _process(delta: float) -> void:
	if player == null:
		return
	_clock += delta
	_pull = 0.0
	_live_sprites = 0
	if _touches.is_empty():
		return
	var pip := player.position
	var i := _touches.size() - 1
	while i >= 0:
		var t: Touch = _touches[i]
		if _update(t, pip):
			_release_all(t)
			_touches.remove_at(i)
		i -= 1
	_max_sprites = maxi(_max_sprites, _live_sprites)


func _update(t: Touch, pip: Vector2) -> bool:
	if _clock < t.te:
		_update_flight(t, pip)
		return false
	if not t.started:
		_begin_event(t)
	var e := _clock - t.te
	var ev := t.ev
	var sprites := ev.sprites
	for k in sprites.size():
		var sp: PickupArt.CSpr = sprites[k]
		var slot: Slot = t.slots[k]
		if e < sp.t0 or e > sp.t1:
			if slot != null and e > sp.t1:
				_release(slot)
				t.slots[k] = null
			continue
		var fresh := slot == null
		if fresh:
			slot = _take(sp.z)
			t.slots[k] = slot
		var kind := sp.kind
		var tex := sp.tex
		if not sp.frame_t.is_empty():
			var fi := 0
			for f in sp.frame_t.size():
				if e >= sp.frame_t[f]:
					fi = f
			kind = sp.frame_kind[fi]
			tex = sp.frame_tex[fi]
		if kind == PickupArt.KIND_SAPLING:
			tex = t.sapling
		elif kind == PickupArt.KIND_BLOOM:
			tex = t.bloom
		if tex != slot.tex:
			_set_tex(slot, tex, kind != PickupArt.KIND_ATLAS)
		# Ispečene staze: dva uzorka i linearno miješanje (PickupArt._bake); jedan upis
		# transforma umjesto tri (pozicija, skala, rotacija), alfa samo kad se mijenja.
		var b := sp.baked
		var fpos := (e - sp.t0) * PickupArt.BAKE_HZ
		var i0 := mini(int(fpos), sp.baked_n - 1)
		var i1 := mini(i0 + 1, sp.baked_n - 1)
		var fr := fpos - float(i0)
		var o0 := i0 * 7
		var o1 := i1 * 7
		var s := lerpf(b[o0 + 2], b[o1 + 2], fr) * slot.base
		slot.node.transform = Transform2D(
			deg_to_rad(lerpf(b[o0 + 5], b[o1 + 5], fr)),
			Vector2(s * lerpf(b[o0 + 3], b[o1 + 3], fr), s * lerpf(b[o0 + 4], b[o1 + 4], fr)),
			0.0,
			pip + (_anchor_b if sp.at_b else _anchor_c) + Vector2(lerpf(b[o0], b[o1], fr), lerpf(b[o0 + 1], b[o1 + 1], fr))
		)
		if not sp.alpha_const or fresh:
			slot.node.modulate.a = clampf(lerpf(b[o0 + 6], b[o1 + 6], fr), 0.0, 1.0)
		_live_sprites += 1
	var arrived := _update_pill(t, e)
	return arrived and e >= ev.length


func _begin_event(t: Touch) -> void:
	t.started = true
	for k in 3:
		if t.fly[k] != null:
			_release(t.fly[k])
			t.fly[k] = null
	if t.is_coin:
		_streak = mini(_streak + 1, _streak_max) if t.te - _last_coin_te <= _streak_window else 1
		_last_coin_te = t.te
		t.streak = _streak
		t.ev_id = "coin_n%d" % _streak
	else:
		t.ev_id = "seed_r%d%s" % [t.rarity, "_twin" if t.amount >= 2 else ""]
	var evs := PickupArt.events()
	t.ev = evs.get(t.ev_id)
	if t.ev == null:
		t.ev = evs.get("coin_n1" if t.is_coin else "seed_r1")
	t.slots.resize(t.ev.sprites.size())
	t.slots.fill(null)
	touch_started.emit(t)


func _update_flight(t: Touch, pip: Vector2) -> void:
	var el := _clock - t.t0
	if el < 0.1:
		_pull = maxf(_pull, 1.0 - el / 0.1)
	var u := clampf(el / t.tf, 0.0, 1.0)
	u *= u  # quad_in
	var dv := _anchor_c - t.s0
	var dd := maxf(dv.length(), 1.0)
	var n := Vector2(-dv.y, dv.x) * (t.side / dd)
	var p := pip + t.s0 + dv * u + n * (_fly_arc * dd * sin(PI * u))
	var sc := lerpf(1.0, _fly_scale_end, u)
	if t.is_coin:
		var c := _fly_slot(t, 0, 2, _tex_coin, false)
		c.node.position = p
		c.node.scale = Vector2(sc, sc)
		_live_sprites += 1
		return
	var so := _fly_slot(t, 0, 0, _tex_soil, false)
	so.node.position = p + Vector2(0.0, 18.0 * sc)
	so.node.scale = Vector2(sc, sc)
	var sa := _fly_slot(t, 1, 1, t.sapling, true)
	sa.node.position = p + Vector2(0.0, 20.0 * sc)
	sa.node.scale = Vector2(sc, sc) * sa.base
	sa.node.rotation_degrees = -8.0 * sin(PI * u)
	_live_sprites += 2


func _fly_slot(t: Touch, k: int, z: int, tex: Texture2D, plant: bool) -> Slot:
	var slot: Slot = t.fly[k]
	if slot == null:
		slot = _take(z)
		t.fly[k] = slot
		_set_tex(slot, tex, plant)
	return slot


## Pilula „+1" od C do čipa (kvadratna kriva, kontrola 260 px iznad). true kad je stigla.
func _update_pill(t: Touch, e: float) -> bool:
	if t.arrived:
		return true
	var ev := t.ev
	var tf := e - ev.hud_t0
	if tf < 0.0:
		return false
	var target := coin_target if ev.hud_coin else seed_target
	if tf >= _flight_dur or fly_layer == null or target == null:
		if t.pill != null:
			_release_pill(t.pill)
			t.pill = null
		t.arrived = true
		pill_arrived.emit(t)
		return true
	var pill := t.pill
	if pill == null:
		pill = _take_pill()
		t.pill = pill
		pill.show_pill(_icon_coin if ev.hud_coin else _icon_seed, ev.hud_text)
		var from_local := player.position + _anchor_c - Vector2(0.0, PILL_LIFT)
		t.pill_from = get_global_transform_with_canvas() * from_local
	var x0 := t.pill_from
	var dst := target.get_global_rect().get_center()
	var u := tf / _flight_dur
	u = 2.0 * u * u if u < 0.5 else 1.0 - 2.0 * (1.0 - u) * (1.0 - u)  # quad_inout
	var ctrl := Vector2(x0.x + 0.25 * (dst.x - x0.x), x0.y - 260.0)
	var q := (1.0 - u) * (1.0 - u) * x0 + 2.0 * (1.0 - u) * u * ctrl + u * u * dst
	var s := PickupArt.eval_track(_flight_s, tf, 1.0) * ev.pill_scale
	pill.position = q - pill.size * 0.5
	pill.scale = Vector2(s, s)
	pill.modulate.a = clampf(PickupArt.eval_track(_flight_a, tf, 1.0), 0.0, 1.0)
	_live_sprites += 1
	return false


func _set_tex(slot: Slot, tex: Texture2D, plant: bool) -> void:
	slot.tex = tex
	slot.node.texture = tex
	if plant and tex != null:
		slot.node.offset = Vector2(0.0, -tex.get_size().y * 0.5)
		slot.base = PickupArt.plant_scale(tex)
	else:
		slot.node.offset = Vector2.ZERO
		slot.base = 1.0


func _take(z: int) -> Slot:
	var zz := clampi(z, 0, 5)
	var list: Array = _free[zz]
	var slot := Slot.new()
	slot.z = zz
	if list.is_empty():
		slot.node = Sprite2D.new()
		_layers[zz].add_child(slot.node)
	else:
		slot.node = list.pop_back()
	slot.node.visible = true
	slot.node.rotation = 0.0
	slot.node.scale = Vector2.ONE
	slot.node.modulate = Color.WHITE
	return slot


func _release(slot: Slot) -> void:
	if slot == null or not is_instance_valid(slot.node):
		return
	slot.node.visible = false
	(_free[slot.z] as Array).append(slot.node)


func _release_all(t: Touch) -> void:
	for k in t.slots.size():
		if t.slots[k] != null:
			_release(t.slots[k])
			t.slots[k] = null
	for k in 3:
		if t.fly[k] != null:
			_release(t.fly[k])
			t.fly[k] = null
	if t.pill != null:
		_release_pill(t.pill)
		t.pill = null


func _take_pill() -> PickupPill:
	var p: PickupPill
	if _free_pills.is_empty():
		p = PickupPill.new()
		fly_layer.add_child(p)
	else:
		p = _free_pills.pop_back()
	p.visible = true
	return p


func _release_pill(p: PickupPill) -> void:
	if not is_instance_valid(p):
		return
	p.visible = false
	_free_pills.append(p)
