class_name LevelPathKit
extends RefCounted

## Level Path (design_handoff_level_path): raspored 20 kamenova, ruta, sanduci, zastavica i
## recept pozadine po sezoni. Brojevi su iz godot/level_path_layout.json (= level_path_kit.js);
## recept je kits[id].path u seasons_kit.json. Tri vrste sloja vezane za rutu (route,
## route_marks, spurs) i stripes se ovdje JEDNOM prevedu u obične slojeve Season Kita
## (line, shape, poly), pa pozadinu crta isti SeasonBackdrop kao polje — mreža se gradi jednom
## po sezoni, a skrol samo pomjera sadržaj.

const LAYOUT_PATH := "res://data/level_path/layout.json"
const STATES_PATH := "res://data/level_path/states.json"
const POPUP_PATH := "res://data/level_path/reward_popup.json"
const ASSET_DIR := "res://assets/level_path/"

const W := 1080.0
const H := 4900.0
const PAGE_H := 1633.0
const SCROLL_MAX := H - PAGE_H
const OPEN_Y := 1100.0
const VIEW_SAFE := Vector2(150.0, 1440.0)
const STONE_BOX := Vector2(180, 140)
const STONE_PIVOT := Vector2(90, 56)
const CURRENT_SCALE := 1.22
const NUM_PX := 46
const NUM_PX_CURRENT := 56
const CHEST_BOX := Vector2(200, 190)
const CHEST_ANCHOR := Vector2(100, 176)
const CHEST_BIG_SCALE := 1.3
const FLAG_BOX := Vector2(150, 250)
const FLAG_ANCHOR := Vector2(42, 240)
const PENNANT_BOX := Vector2(100, 64)
const PENNANT_UP := Vector2(44, 22)
const PENNANT_DOWN := Vector2(44, 128)
const PIP_BOX := 210.0
## Pip na polju (season_field_pip.gd PIP_SIDE) — skala na početku skoka polje → put.
const FIELD_PIP_BOX := 190.0
const TO_PATH_SEC := 0.56
const TO_FIELD_SEC := 0.44
const CHROME_LIFT := 16.0
## Stopala Pipa 44 px iznad centra lica kamena; UiPip ima ishodište na dnu boxa (stopala 240 / 256).
const PIP_FEET_DY := -44.0
const PIP_FEET_K := 0.9375
## Neuzeta nagrada do 560 px ispod Pipa mora biti u kadru iznad donjeg reda.
const READY_BELOW := 560.0
## Rasuti dekor ne sidri se na rutu, kamenje, sanduke ni zastavicu (AVOID u JS).
const ROUTE_AVOID := Vector2(84, 54)

## strings_en iz reward_popup.json
const S_TITLE := "Level %d reward!"
const S_CLAIM := "Claim"
const S_LOCKED := "Finish level %d to claim"
const S_COMPLETE := "Meadow complete!"
const S_REPLAY := "Play repeats Level 20"
const S_BACK := "Field"
const S_LOCATOR := "Pip"

static var _layout: Dictionary = {}
static var _states: Dictionary = {}
static var _popup: Dictionary = {}
static var _route := PackedVector2Array()
static var _cps: Array[Vector2] = []
static var _chests: Dictionary = {}
static var _avoid: Array = []
static var _tex: Dictionary = {}


static func _load(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("LevelPathKit: missing %s" % path)
		return {}
	var d: Variant = JSON.parse_string(f.get_as_text())
	return d if d is Dictionary else {}


static func layout() -> Dictionary:
	if _layout.is_empty():
		_layout = _load(LAYOUT_PATH)
		_cps.clear()
		_chests.clear()
		for c in _layout.get("checkpoints", []):
			_cps.append(Vector2(float(c["x"]), float(c["y"])))
			var rw: Variant = c.get("reward", null)
			if rw is Dictionary:
				var ch: Dictionary = rw["chest"]
				_chests[int(c["n"])] = {"pos": Vector2(float(ch["x"]), float(ch["y"])), "big": bool(ch["big"])}
		_route = PackedVector2Array()
		for q in _layout.get("route", {}).get("points", []):
			_route.append(Vector2(float(q[0]), float(q[1])))
	return _layout


static func locked_text(n: int) -> String:
	return S_LOCKED % n


static func states() -> Dictionary:
	if _states.is_empty():
		_states = _load(STATES_PATH)
	return _states


static func popup_spec() -> Dictionary:
	if _popup.is_empty():
		_popup = _load(POPUP_PATH)
	return _popup


## Centar lica kamena levela n (1…20) u px sadržaja.
static func cp(n: int) -> Vector2:
	layout()
	return _cps[clampi(n, 1, _cps.size()) - 1]


static func cp_count() -> int:
	layout()
	return _cps.size()


## Sanduk nagrade n: {pos (sredina dna), big}.
static func chest(n: int) -> Dictionary:
	layout()
	return _chests.get(n, {})


static func flag_bottom() -> Vector2:
	var fb: Array = layout()["goal_flag"]["pole_bottom"]
	return Vector2(float(fb[0]), float(fb[1]))


static func route() -> PackedVector2Array:
	layout()
	return _route


static func cp_index(n: int) -> int:
	var idx: Array = layout()["route"]["cp_index"]
	return int(idx[clampi(n, 1, idx.size()) - 1])


## Pređeni dio rute: od ulaza do kamena trenutnog levela (complete → do 20).
static func passed_points(level: int) -> PackedVector2Array:
	return route().slice(0, cp_index(clampi(level, 1, 20)) + 1)


## Stopala Pipa na kamenu levela (complete → na 20).
static func pip_feet(level: int) -> Vector2:
	return cp(clampi(level, 1, 20)) + Vector2(0.0, PIP_FEET_DY)


## Ishodište UiPip (dno boxa) za stopala.
static func pip_origin(feet: Vector2) -> Vector2:
	return feet + Vector2(0.0, PIP_BOX * (1.0 - PIP_FEET_K))


## Skrol na otvaranju: Pipov kamen na y 1100 stranice; neuzeta nagrada do 560 px ispod
## njega spušta kadar tako da „Claim" stoji iznad donjeg reda (openScroll u JS).
static func open_scroll(level: int, ready: Array) -> float:
	var c := cp(clampi(level, 1, 20))
	var y := c.y - OPEN_Y
	var bottom := -INF
	for n in ready:
		var ch := chest(int(n))
		if ch.is_empty():
			continue
		var p: Vector2 = ch["pos"]
		if p.y > c.y and p.y - c.y < READY_BELOW:
			bottom = maxf(bottom, p.y + 100.0)
	if bottom > -INF and bottom - y > VIEW_SAFE.y - 20.0:
		y = bottom - (VIEW_SAFE.y - 20.0)
	return clampf(y, 0.0, SCROLL_MAX)


static func path_recipe(season_id: String) -> Dictionary:
	return UiSeasons.recipe(season_id, "path")


static func stone_spec(season_id: String) -> Dictionary:
	return path_recipe(season_id).get("stone", {})


## Boja broja na kamenu: locked = kits[id].path.stone.locked.num, inače ink.
static func number_color(season_id: String, state: String) -> Color:
	if state == LevelPathDomain.STATE_LOCKED:
		var num := str(stone_spec(season_id).get("locked", {}).get("num", "#2D3436"))
		return UiSeasons.col(num)
	return UiHomeField.OUTLINE


## Pređeni put: 2–3 poteza [širina, boja] (široki prvi).
static func passed_strokes(season_id: String) -> Array:
	return path_recipe(season_id).get("road", {}).get("passed", [])


static func tex(rel: String) -> Texture2D:
	if _tex.has(rel):
		return _tex[rel]
	var path := ASSET_DIR + rel
	var t: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_tex[rel] = t
	return t


static func stone_tex(season_id: String, state: String) -> Texture2D:
	return tex("path/%s/checkpoint_%s.svg" % [season_id, state])


static func chest_tex(state: String, big: bool) -> Texture2D:
	return tex("path/chest_%s%s.svg" % ["big_" if big else "", state.trim_prefix("reward_")])


static func fx_tex(id: String) -> Texture2D:
	return tex("fx/%s.svg" % id)


# --- pozadina ---

## Mreža pozadine sezone (keš u SeasonBackdrop). Prazno ako sezona nema recept puta.
static func scene(season_id: String) -> Dictionary:
	var r := path_recipe(season_id)
	if r.is_empty():
		return {}
	return SeasonBackdrop.scene("path:" + season_id, expand(r), W, avoid())


## Recept puta → slojevi Season Kita (u % sadržaja 1080 x 4900).
static func expand(r: Dictionary) -> Dictionary:
	var layers: Array = []
	for L in r.get("layers", []):
		match str(L["k"]):
			"route":
				layers.append({"k": "line", "pts": _pct_list(route()), "w": L["w"], "c": L["c"]})
			"spurs":
				for n in LevelPathDomain.REWARD_LEVELS:
					var ch := chest(n)
					if ch.is_empty():
						continue
					var a := cp(n)
					var b: Vector2 = (ch["pos"] as Vector2) - Vector2(0, 14)
					layers.append({"k": "line", "pts": _pct_list(PackedVector2Array([a, b])), "w": L["w"], "c": L["c"]})
			"route_marks":
				layers.append(_marks_layer(L))
			"stripes":
				layers.append_array(_stripe_layers(L))
			_:
				layers.append(L)
	return {"layers": layers}


static func _pct(p: Vector2) -> Array:
	return [p.x / W * 100.0, p.y / H * 100.0]


static func _pct_list(pts: PackedVector2Array) -> Array:
	var out: Array = []
	for p in pts:
		out.append(_pct(p))
	return out


## Oblik na svakih `every` px rute (marksAlong u JS), bez onih na kamenju.
static func _marks_layer(L: Dictionary) -> Dictionary:
	var every := float(L["every"])
	var next := float(L.get("offset", every * 0.5))
	var skip := float(L.get("skip", 80))
	var size := float(L["size"])
	var rot_v: Variant = L.get("rot", 0)
	var fixed := str(rot_v) == "fixed"
	var leaf := str(L["shape"]) == "leaf"
	var pts := route()
	var at: Array = []
	var run := 0.0
	for i in range(1, pts.size()):
		var a := pts[i - 1]
		var b := pts[i]
		var seg := a.distance_to(b)
		while run + seg >= next:
			var t := (next - run) / (seg if seg > 0.0 else 1.0)
			var p := a.lerp(b, t)
			var ang := rad_to_deg(atan2(b.y - a.y, b.x - a.x))
			if p.y < H + 30.0 and not _near_cp(p, skip):
				var rot: float
				if fixed:
					rot = float(at.size() % 2) * 45.0
				else:
					var base := float(rot_v)
					rot = float(roundi(ang)) + base * ((-1.0 if at.size() % 2 == 1 else 1.0) if leaf else 1.0)
				var q := _pct(p)
				at.append([q[0], q[1], size, rot])
			next += every
		run += seg
	return {"k": "shape", "shape": L["shape"], "pal": L["pal"], "at": at}


static func _near_cp(p: Vector2, r: float) -> bool:
	for c in _cps:
		if Vector2(c.x - p.x, (c.y - p.y) * 1.25).length() < r:
			return true
	return false


## Pokošene pruge bez preklapanja: traka i između grebena ys[i] i ys[i + 1].
static func _stripe_layers(L: Dictionary) -> Array:
	var out: Array = []
	var ys: Array = L["ys"]
	var cols: Array = L["c"]
	var waves: Array = L["r"].get("w", [])
	for i in ys.size() - 1:
		var top: Array = []
		var bot: Array = []
		var x := 0.0
		while x <= 100.01:
			top.append([x, UiSeasons.ridge_y({"y": ys[i], "w": waves}, x)])
			var yb := 100.6 if i + 1 == ys.size() - 1 else UiSeasons.ridge_y({"y": ys[i + 1], "w": waves}, x) + 0.02
			bot.push_front([x, yb])
			x += 2.5
		out.append({"k": "poly", "pts": top + bot, "c": cols[i % 2]})
	return out


## Mirne zone za scatter (u % sadržaja).
static func avoid() -> Array:
	if not _avoid.is_empty():
		return _avoid
	var pts := route()
	for i in range(0, pts.size(), 2):
		_avoid.append(_rect_pct(pts[i].x - ROUTE_AVOID.x, pts[i].y - ROUTE_AVOID.y, 168.0, 118.0))
	for c in _cps:
		_avoid.append(_rect_pct(c.x - 104.0, c.y - 86.0, 208.0, 156.0))
	for n in _chests:
		var ch: Dictionary = _chests[n]
		var s := CHEST_BIG_SCALE if bool(ch["big"]) else 1.0
		var p: Vector2 = ch["pos"]
		_avoid.append(_rect_pct(p.x - 140.0 * s, p.y - 220.0 * s, 280.0 * s, 310.0 * s))
	for n in LevelPathDomain.REWARD_LEVELS:
		var ch := chest(n)
		if ch.is_empty():
			continue
		var a := cp(n)
		var b: Vector2 = ch["pos"]
		for k in 5:
			var q := a.lerp(b, float(k) / 4.0)
			_avoid.append(_rect_pct(q.x - 60.0, q.y - 50.0, 120.0, 100.0))
	var f := flag_bottom()
	_avoid.append(_rect_pct(f.x - 70.0, f.y - 250.0, 140.0, 280.0))
	return _avoid


static func _rect_pct(x: float, y: float, w: float, h: float) -> Array:
	return [x / W * 100.0, y / H * 100.0, w / W * 100.0, h / H * 100.0]
