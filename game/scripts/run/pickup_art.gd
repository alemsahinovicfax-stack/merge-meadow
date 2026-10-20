class_name PickupArt
extends RefCounted

## Pickupi u runu (design_handoff_run_pickups): podaci iz `data/run/pickup_fx.json` (idle, dodiri,
## magnet, HUD let), jedan atlas 512 × 512 za sve efekte i odrezane sadnice / cvjetove (region
## postojeće teksture cvijeta). Sve se učitava jednom i dijeli — pickup na stazi i efekat dodira
## samo mijenjaju transformu i teksturu Sprite2D-a, ništa se ne crta po frejmu.

const DATA_PATH := "res://data/run/pickup_fx.json"
const FLOWER_ASSETS := preload("res://scripts/visual/flower_assets.gd")
const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

## Staze ključeva u CSpr.tracks (redoslijed).
const T_X := 0
const T_Y := 1
const T_S := 2
const T_SX := 3
const T_SY := 4
const T_R := 5
const T_A := 6
const TRACK_KEYS := ["x", "y", "s", "sx", "sy", "r", "a"]
const KIND_ATLAS := 0
const KIND_SAPLING := 1
const KIND_BLOOM := 2
const BAKE_HZ := 120.0
const EASE_CODES := {"lin": 0, "quad_in": 1, "quad_out": 2, "quad_inout": 3, "back_out": 4, "sine_inout": 5}


## Sprite događaja, unaprijed preveden: tekstura / vrsta, sidro, vrijeme i 7 staza
## [t, v, ease_code, t, v, ease_code, …] (prazna staza = podrazumijevana vrijednost).
class CSpr:
	var id: String
	var kind: int = 0
	var tex: Texture2D = null
	var frame_t: PackedFloat32Array = PackedFloat32Array()
	var frame_kind: PackedInt32Array = PackedInt32Array()
	var frame_tex: Array[Texture2D] = []
	var z: int = 0
	var at_b: bool = false
	var t0: float = 0.0
	var t1: float = 0.0
	var tracks: Array[PackedFloat32Array] = []
	## Ispečeno: BAKE_HZ uzoraka u sekundi od t0 do t1, po 7 vrijednosti (x, y, s, sx, sy, r, a);
	## runtime čita dva uzorka i linearno ih miješa — bez poziva funkcija po stazi.
	var baked: PackedFloat32Array = PackedFloat32Array()
	var baked_n: int = 0
	## Alfa se ne mijenja kroz cijeli sprite → modulate se postavi jednom.
	var alpha_const: bool = true


class CEvent:
	var id: String
	var length: float = 0.4
	var pip: String = ""
	var hud_coin: bool = true
	var hud_t0: float = 0.08
	var hud_text: String = "+1"
	var pill_scale: float = 1.0
	var bump: float = 1.08
	var sprites: Array[CSpr] = []


static var _data: Dictionary = {}
static var _events: Dictionary = {}
static var _atlas: Texture2D = null
static var _regions: Dictionary = {}
static var _plants: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var text := FileAccess.get_file_as_string(DATA_PATH)
		var parsed: Variant = JSON.parse_string(text)
		if parsed is Dictionary:
			_data = parsed
		else:
			push_warning("PickupArt: missing %s" % DATA_PATH)
			_data = {"regions": {}, "events": {}, "idle": {}, "anchors": {}}
	return _data


static func anchor(id: String) -> Vector2:
	var a: Array = data()["anchors"].get(id, [0, -46])
	return Vector2(float(a[0]), float(a[1]))


## Regija atlasa kao AtlasTexture (dijeli istu teksturu → isti batch u GL Compatibility).
static func tex(id: String) -> Texture2D:
	if _regions.has(id):
		return _regions[id]
	if _atlas == null:
		var path := str(data().get("texture", ""))
		if ResourceLoader.exists(path):
			_atlas = load(path) as Texture2D
	var r: Array = data()["regions"].get(id, [])
	if _atlas == null or r.size() < 4:
		return null
	var at := AtlasTexture.new()
	at.atlas = _atlas
	at.region = Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3]))
	at.filter_clip = true
	_regions[id] = at
	return at


## Odrezana sadnica (tier 1) ili cvijet (tier 3) sezone — region teksture cvijeta, bez kopije.
static func plant(type_id: String, tier: int) -> Texture2D:
	var key := "%s:%d" % [type_id, tier]
	if _plants.has(key):
		return _plants[key]
	var src: Texture2D = FLOWER_ASSETS.get_texture(type_id, tier)
	if src == null:
		_plants[key] = null
		return null
	var at := AtlasTexture.new()
	at.atlas = src
	at.region = PLANT_DRAW._crop_rect(src)
	at.filter_clip = true
	_plants[key] = at
	return at


## Visina sadnice / cvijeta na stazi i u dodiru (pickup_idle.json → sprites.sapling.h).
static func plant_scale(t: Texture2D) -> float:
	if t == null:
		return 1.0
	return float(data().get("sapling_h", 104)) / maxf(1.0, t.get_size().y)


## Unaprijed odreže sadnice bazena sjemena (get_image je skup — ne smije pasti usred runa).
static func prewarm(type_ids: Array) -> void:
	for id in type_ids:
		plant(str(id), 1)
		plant(str(id), 3)
	for id in data()["regions"]:
		tex(str(id))


## Svi događaji dodira, prevedeni jednom (id → CEvent).
static func events() -> Dictionary:
	if not _events.is_empty():
		return _events
	for id in data().get("events", {}):
		var src: Dictionary = data()["events"][id]
		var ev := CEvent.new()
		ev.id = str(id)
		ev.length = float(src.get("len", 0.4))
		ev.pip = str(src.get("pip", ""))
		var hud: Dictionary = src.get("hud", {})
		ev.hud_coin = str(hud.get("chip", "coin")) == "coin"
		ev.hud_t0 = float(hud.get("t0", 0.08))
		ev.hud_text = str(hud.get("text", "+1"))
		ev.pill_scale = float(hud.get("pill_scale", 1.0))
		ev.bump = float(hud.get("bump", 1.08))
		for sd in src.get("sprites", []):
			var d: Dictionary = sd
			var sp := CSpr.new()
			sp.id = str(d.get("id", ""))
			sp.kind = _kind_of(str(d.get("sprite", "")))
			sp.tex = tex(str(d.get("sprite", ""))) if sp.kind == KIND_ATLAS else null
			for fr in d.get("frame", []):
				var f: Array = fr
				var name := str(f[1])
				sp.frame_t.append(float(f[0]))
				sp.frame_kind.append(_kind_of(name))
				sp.frame_tex.append(tex(name) if _kind_of(name) == KIND_ATLAS else null)
			sp.z = int(d.get("z", 0))
			sp.at_b = str(d.get("at", "C")) == "B"
			sp.t0 = float(d.get("t0", 0.0))
			sp.t1 = float(d.get("t1", 0.0))
			var keys: Dictionary = d.get("keys", {})
			for k in TRACK_KEYS:
				sp.tracks.append(compile_track(keys.get(k)))
			_bake(sp)
			ev.sprites.append(sp)
		_events[ev.id] = ev
	return _events


static func _bake(sp: CSpr) -> void:
	const DEF := [0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0]
	sp.baked_n = int(ceil((sp.t1 - sp.t0) * BAKE_HZ)) + 1
	sp.baked.resize(sp.baked_n * 7)
	for i in sp.baked_n:
		var t := minf(sp.t0 + float(i) / BAKE_HZ, sp.t1)
		for k in 7:
			sp.baked[i * 7 + k] = eval_track(sp.tracks[k], t, float(DEF[k]))
		if not is_equal_approx(sp.baked[i * 7 + 6], sp.baked[6]):
			sp.alpha_const = false


static func _kind_of(sprite_id: String) -> int:
	if sprite_id == "sapling":
		return KIND_SAPLING
	if sprite_id == "bloom":
		return KIND_BLOOM
	return KIND_ATLAS


## [[t, v, ease], …] → PackedFloat32Array [t, v, ease_code, …].
static func compile_track(keys: Variant) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	if not (keys is Array):
		return out
	for kv in keys:
		var k: Array = kv
		out.append(float(k[0]))
		out.append(float(k[1]))
		out.append(float(EASE_CODES.get(str(k[2]) if k.size() > 2 else "lin", 0)))
	return out


## Brza verzija key() nad prevedenom stazom.
static func eval_track(k: PackedFloat32Array, t: float, d: float) -> float:
	var n := k.size()
	if n == 0:
		return d
	if t <= k[0]:
		return k[1]
	var i := 3
	while i < n:
		if t <= k[i]:
			var ta := k[i - 3]
			var span := k[i] - ta
			var u := (t - ta) / span if span > 0.0 else 1.0
			var va := k[i - 2]
			return va + (k[i + 1] - va) * ease_code(int(k[i - 1]), u)
		i += 3
	return k[n - 2]


static func ease_code(code: int, u: float) -> float:
	match code:
		1:
			return u * u
		2:
			return 1.0 - (1.0 - u) * (1.0 - u)
		3:
			return 2.0 * u * u if u < 0.5 else 1.0 - 2.0 * (1.0 - u) * (1.0 - u)
		4:
			var y := u - 1.0
			return 1.0 + 2.70158 * y * y * y + 1.70158 * y * y
		5:
			return 0.5 - 0.5 * cos(PI * u)
	return u


static func ease_value(name: String, u: float) -> float:
	match name:
		"quad_in":
			return u * u
		"quad_out":
			return 1.0 - (1.0 - u) * (1.0 - u)
		"quad_inout":
			return 2.0 * u * u if u < 0.5 else 1.0 - 2.0 * (1.0 - u) * (1.0 - u)
		"back_out":
			var c := 1.70158
			var y := u - 1.0
			return 1.0 + (c + 1.0) * y * y * y + c * y * y
		"sine_inout":
			return 0.5 - 0.5 * cos(PI * u)
	return u


## Ključevi [t, vrijednost, ease] — ease vrijedi od tog ključa do sljedećeg (pickup_fx.json).
static func key(keys: Variant, t: float, d: float) -> float:
	if not (keys is Array) or (keys as Array).is_empty():
		return d
	var k: Array = keys
	var first: Array = k[0]
	if t <= float(first[0]):
		return float(first[1])
	for i in range(1, k.size()):
		var b: Array = k[i]
		if t <= float(b[0]):
			var a: Array = k[i - 1]
			var span := float(b[0]) - float(a[0])
			var u := (t - float(a[0])) / span if span > 0.0 else 1.0
			var e := ease_value(str(a[2]) if a.size() > 2 else "lin", u)
			return float(a[1]) + (float(b[1]) - float(a[1])) * e
	var last: Array = k[k.size() - 1]
	return float(last[1])


static func frame_at(frames: Array, t: float) -> String:
	var f := str((frames[0] as Array)[1])
	for fr in frames:
		if t >= float((fr as Array)[0]):
			f = str((fr as Array)[1])
	return f
