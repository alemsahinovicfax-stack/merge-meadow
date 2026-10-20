extends Node2D

## Sjemenka na stazi (design_handoff_run_pickups · pickup_fx.json → idle.seed): sjena, zemljica,
## odrezana sadnica koja se njiše, kapljica rose; ★2 / ★3 dobijaju oreol od latica koji se vrti
## i iskrice u orbiti — rijetkost se vidi bez brojanja. Sprite2D iz atlasa (+ region teksture
## cvijeta za sadnicu), samo transformi — ništa se ne crta po frejmu. Parametri se čitaju jednom.
## Kolizija ostaje r 26.

var _type_id: String = "clover"
var _rarity: int = 1
var _t: float = 0.0
var _ph: float = 0.0
var _built: bool = false
var _halo: Sprite2D
var _sapling: Sprite2D
var _dew: Sprite2D
var _sparks: Array[Sprite2D] = []
## Iskrice stoje na krugu unutar _spin (rotacija), a _orbit (skala y 0,8) ga spljošti u elipsu
## kao u paketu — jedna rotacija po frejmu umjesto pozicije + rotacije po iskrici.
var _orbit: Node2D
var _spin: Node2D
var _sapling_base: float = 1.0
# Parametri (pickup_fx.json → idle.seed), keširani.
var _bob_amp: float = 3.0
var _bob_w: float = 2.4
var _sway_deg: float = 6.0
var _sway_period: float = 1.6
var _base_pos: Vector2 = Vector2(0, 20)
var _dew_at: Vector2 = Vector2(16, -44)
var _dew_amp: float = 2.0
var _dew_w: float = 3.1
var _halo_at: Vector2 = Vector2.ZERO
var _halo_rot: float = 0.0
var _pulse_amp: float = 0.0
var _pulse_period: float = 1.6
var _spark_deg_s: float = 0.0
var _spark_r: float = 0.0
var _spark_s: float = 0.8
var _sap_scale: float = 1.0


func _ready() -> void:
	var parent_pickup := get_parent()
	if parent_pickup != null and "type_id" in parent_pickup:
		_type_id = str(parent_pickup.type_id)
	if parent_pickup != null and "rarity" in parent_pickup:
		_rarity = clampi(int(parent_pickup.rarity), 1, 3)
	_ph = randf()
	_build()


func setup(type_id: String) -> void:
	_type_id = type_id
	var parent_pickup := get_parent()
	if parent_pickup != null and "rarity" in parent_pickup:
		_rarity = clampi(int(parent_pickup.rarity), 1, 3)
	if _built:
		_build()


func get_rarity() -> int:
	return _rarity


func _build() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_sparks.clear()
	var idle: Dictionary = PickupArt.data()["idle"].get("seed", {})
	var halo: Dictionary = idle.get("halo", {}).get(str(_rarity), {})
	var bob: Dictionary = idle.get("bob", {})
	_bob_amp = float(bob.get("amp", 3))
	_bob_w = float(bob.get("w", 2.4))
	var sway: Dictionary = idle.get("sway", {})
	_sway_deg = float(sway.get("deg", 6))
	_sway_period = float(sway.get("period", 1.6))
	var base: Array = idle.get("sapling_base", [0, 20])
	_base_pos = Vector2(float(base[0]), float(base[1]))
	var dew: Dictionary = idle.get("dew", {})
	var dat: Array = dew.get("at", [16, -44])
	_dew_at = Vector2(float(dat[0]), float(dat[1]))
	_dew_amp = float(dew.get("bob", {}).get("amp", 2))
	_dew_w = float(dew.get("bob", {}).get("w", 3.1))

	var shadow := _sprite(PickupArt.tex("shadow"))
	var sh: Dictionary = idle.get("shadow", {})
	var sh_at: Array = sh.get("at", [0, 34])
	var sh_s: Array = sh.get("s", [1.6, 1.3])
	shadow.position = Vector2(float(sh_at[0]), float(sh_at[1]))
	shadow.scale = Vector2(float(sh_s[0]), float(sh_s[1]))
	_halo = null
	if not halo.is_empty():
		_halo = _sprite(PickupArt.tex(str(halo.get("sprite", "halo2"))))
		var at: Array = halo.get("at", [0, -36])
		_halo_at = Vector2(float(at[0]), float(at[1]))
		_halo.position = _halo_at
		_halo_rot = float(halo.get("rot_deg_s", 40))
		_pulse_amp = float(halo.get("pulse", {}).get("amp", 0.04))
		_pulse_period = float(halo.get("pulse", {}).get("period", 1.6))
		var sp: Dictionary = halo.get("sparks", {})
		_spark_deg_s = float(sp.get("deg_s", 120))
		_spark_r = float(sp.get("radius", 62))
		_spark_s = float(sp.get("s", 0.8))
		_sap_scale = float(halo.get("sapling_scale", 1.0))
	else:
		_sap_scale = 1.0
	var soil := _sprite(PickupArt.tex("soil"))
	var so: Array = idle.get("soil_at", [0, 18])
	soil.position = Vector2(float(so[0]), float(so[1]))
	_sapling = _sprite(PickupArt.plant(_type_id, 1))
	_sapling_base = PickupArt.plant_scale(_sapling.texture)
	if _sapling.texture != null:
		# Sidro dolje (baza stabljike), kao u paketu.
		_sapling.offset = Vector2(0.0, -_sapling.texture.get_size().y * 0.5)
	_dew = _sprite(PickupArt.tex("dew"))
	_orbit = null
	_spin = null
	var n := int(halo.get("sparks", {}).get("n", 0)) if not halo.is_empty() else 0
	if n > 0:
		_orbit = Node2D.new()
		_orbit.position = _halo_at
		_orbit.scale = Vector2(1.0, 0.8)
		add_child(_orbit)
		_spin = Node2D.new()
		_orbit.add_child(_spin)
		var tex := PickupArt.tex("spark")
		for i in n:
			var sp := Sprite2D.new()
			sp.texture = tex
			var a := TAU * float(i) / float(n)
			sp.position = Vector2(cos(a), sin(a)) * _spark_r
			sp.rotation = a
			_spin.add_child(sp)
			_sparks.append(sp)
	_built = true
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
	if not _built:
		return
	var tt := t + _ph * 3.0
	var sway_s := sin(TAU * tt / _sway_period)
	if _halo != null:
		var p := 1.0 + _pulse_amp * sin(TAU * tt / _pulse_period)
		_halo.transform = Transform2D(deg_to_rad(_halo_rot * tt), Vector2(p, p), 0.0, _halo_at)
		if _spin != null:
			_spin.rotation = deg_to_rad(_spark_deg_s * tt)
			for i in _sparks.size():
				var s := _spark_s * (0.75 + 0.25 * sin(tt * 5.0 + float(i) * 2.0))
				_sparks[i].scale = Vector2(s, s)
	var wt := _bob_w * tt
	var bob := sin(wt)
	_sapling.transform = Transform2D(
		deg_to_rad(_sway_deg * sway_s),
		Vector2(_sap_scale, _sap_scale * (1.0 + 0.02 * bob)) * _sapling_base,
		0.0,
		Vector2(_base_pos.x, _base_pos.y + minf(0.0, _bob_amp * bob))
	)
	_dew.position = Vector2(_dew_at.x + _sway_deg * 0.9 * sway_s, _dew_at.y + _dew_amp * sin(_dew_w * tt))
