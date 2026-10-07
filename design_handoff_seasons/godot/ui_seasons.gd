class_name UiSeasons
extends RefCounted

## Season Kit (faza 1 + 2, svih 8 sezona) — jedan red podataka po sezoni, svaka površina je rez istog kita.
## Izvor brojeva: godot/seasons_export.json (generisan iz design/seasons_kit.js). Kopiraj u
## res://data/seasons/seasons_kit.json. Nova sezona = novi red u "kits" — bez novog koda.
## Recept se računa JEDNOM (SeasonBackdrop._build_cache); po frejmu samo pomak / skala / alpha.

const KIT_PATH := "res://data/seasons/seasons_kit.json"
const PAGE := Vector2(1080, 1633)
const CARD_RECT := Rect2(24, 172, 1032, 1160)
const STICKER_MIN := 6.14   # naljepnica: max(c(ink rub, livada), c(fill, livada))
const TEXT_MIN := 4.5
const OBJECT_MIN := 3.0
const AMBIENT_MAX := 24
const LOOPS_MAX := 2

## Pip poze (polje)
const PIP_TEX := {
	"walk": "res://assets/sprites/pip_idle.svg",
	"sniff": "res://assets/sprites/pip_sniff.svg",
	"sleep": "res://assets/sprites/pip_sleep.svg",
}
const PIP_BOB_SEC := 0.42
const PIP_BOB_Y := -7.0
const SNIFF_BOW := {"sec": 0.6, "keys": [[0.0, 0.0, 1.0], [0.35, -9.0, 0.94], [0.7, 4.0, 1.0], [1.0, 0.0, 1.0]]}
const SNIFF_PUFF := {"n": 5, "sec": 0.7, "rise": 80.0, "stagger": 0.05}
const SLEEP_ZZZ := {"n": 3, "sec": 2.4, "stagger": 0.6, "fill": "#FFF8F0", "outline": 6}
const GROW := {"sec": 0.42, "peak": 1.12}

static var _data: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty():
		var f := FileAccess.open(KIT_PATH, FileAccess.READ)
		if f:
			_data = JSON.parse_string(f.get_as_text())
	return _data


## Kit sezone ili prazno (sezona bez kita → današnji izgled: trake + SeasonTheme tint).
static func kit(season_id: String) -> Dictionary:
	return data().get("kits", {}).get(season_id, {})


static func has_kit(season_id: String) -> bool:
	return not kit(season_id).is_empty()


static func palette(season_id: String) -> Dictionary:
	return kit(season_id).get("palette", {})


## Boja teksta direktno na livadi (#1A1A14 svijetli kitovi, #FFF8F0 tamni).
static func ink_field(season_id: String) -> Color:
	return Color(str(palette(season_id).get("ink_field", "#1A1A14")))


## Pozadina stranice izbora (ostaje svijetla i za tamne kitove — tabovi stoje na njoj).
static func page_color(season_id: String) -> Color:
	return Color(str(palette(season_id).get("page", "#F4F9EF")))


static func spots(season_id: String) -> Array:
	return kit(season_id).get("spots", UiHomeField.MEADOW_SPOTS)


static func recipe(season_id: String, surface: String) -> Dictionary:
	var k := kit(season_id)
	match surface:
		"field", "card":
			return k.get("field", {})
		"shop", "camp":
			var s: Variant = k.get(surface, null)
			return s if s is Dictionary else {}
		_:
			return {}



static func run_def(season_id: String) -> Dictionary:
	return kit(season_id).get("run", {})


## Greben: y(x) = y0 + Σ a·sin(2π·f·x/100 + p), sve u %.
static func ridge_y(r: Dictionary, x: float) -> float:
	var y := float(r["y"]) + float(r.get("tilt", 0.0)) * (x - 50.0) / 100.0
	for w in r.get("w", []):
		y += float(w[0]) * sin(TAU * float(w[1]) * x / 100.0 + float(w[2]))
	return y


static func ridge_points(r: Dictionary, size: Vector2, step: float = 2.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x := 0.0
	while x <= 100.01:  # faza 2: sve unutar 0–100 % recta
		pts.append(Vector2(x * size.x / 100.0, ridge_y(r, x) * size.y / 100.0))
		x += step
	return pts


## Rasuti element i (R2 niz, bez RNG-a) — isto kao scatterAt u JS.
static func scatter_at(layer: Dictionary, i: int) -> Dictionary:
	var r2: Dictionary = data()["r2"]
	var zones: Array = layer["zones"]
	var z: Array = zones[i % zones.size()]
	var k := i / zones.size()
	var ph: Array = layer["phase"]
	var x := float(z[0]) + fposmod(float(ph[0]) + float(r2["a1"]) * (k + 1), 1.0) * float(z[2])
	var y := float(z[1]) + fposmod(float(ph[1]) + float(r2["a2"]) * (k + 1), 1.0) * float(z[3])
	var sz: Array = layer["size"]
	var rt: Array = layer.get("rot", [0, 0])
	var size := lerpf(sz[0], sz[1], fposmod(float(ph[2]) + float(r2["size"]) * (i + 1), 1.0))
	var rot := lerpf(rt[0], rt[1], fposmod(float(ph[3]) + float(r2["rot"]) * (i + 1), 1.0))
	return {"pos": Vector2(x, y), "size": size, "rot": rot}


static func avoided(pos_pct: Vector2) -> bool:
	for a in data().get("field_avoid", []):
		if pos_pct.x >= a[0] and pos_pct.x <= a[0] + a[2] and pos_pct.y >= a[1] and pos_pct.y <= a[1] + a[3]:
			return true
	return false


## 13 mjesta u px recta (baza cvijeta). Za karticu i prelaz: rect = trenutni rect kartice.
static func spot_rects(season_id: String, rect_size: Vector2) -> Array:
	var out: Array = []
	var k := rect_size.x / PAGE.x
	var list := spots(season_id)
	for i in list.size():
		var s: Array = list[i]
		out.append({
			"i": i, "base": Vector2(float(s[0]) / 100.0 * rect_size.x, rect_size.y - float(s[1]) / 100.0 * rect_size.y),
			"size": float(s[2]) * k, "idx": int(s[3]), "need": int(s[4]),
		})
	return out


## Uniformna skala oblika/cvijeća u rectu (kartica 1032 → 0,956; polje 1).
static func shape_scale(rect_size: Vector2) -> float:
	return rect_size.x / PAGE.x


static func obstacle_texture(season_id: String, kind_index: int) -> String:
	var obs: Array = run_def(season_id).get("obstacles", [])
	if obs.is_empty():
		return ""
	var o: Dictionary = obs[kind_index % obs.size()]
	return "res://" + str(o["svg"]).replace("assets/seasons/", "assets/sprites/seasons/")


static func contrast(a: Color, b: Color) -> float:
	var la := a.get_luminance()
	var lb := b.get_luminance()
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func sticker_contrast(fill: Color, bg: Color, ink: Color = Color("#2D3436")) -> float:
	return maxf(contrast(ink, bg), contrast(fill, bg))


# ─────────────── faza 2 ───────────────
const PIP_ZONE := Rect2(151, 1306, 614, 131)   # ne mijenjati (§10.1)
const LOOKS_RECT := Rect2(876, 1265, 180, 180)
const CAMP_CARD := Vector2(1032, 318)
const SHOP_CARD := Vector2(1032, 364)
const SWIPE_SEC := 0.22
const AMBIENT_FADE_IN := 0.3
const SLEEP_AMBIENT_ALPHA := 0.35
const SWAY_DEG := 3.0
const BOW := {"sec": 0.3, "scale": 1.08, "rot": -4.0}


## Sezone u trakama Home tabova (Free / Premium).
static func band(premium: bool) -> Array:
	return data().get("bands", {}).get("premium" if premium else "free", [])


static func is_soon(season_id: String) -> bool:
	return bool(kit(season_id).get("soon", false))


## Cvijet u Camp okviru = ★3 prethodne besplatne sezone.
static func camp_flower(season_id: String) -> String:
	return str(kit(season_id).get("camp_flower", ""))


## Čestice ambijenta (polje ili run): isti format za svih 8 sezona.
## Vraća [{layer, parts:[{pos_pct, size, col, angle, delay}]}]; po frejmu samo ambient_at().
static func ambient_layers(def: Dictionary) -> Array:
	var r2: Dictionary = data()["r2"]
	var left := AMBIENT_MAX
	var out: Array = []
	for L in def.get("layers", []):
		var n := mini(int(L["n"]), left)
		left -= n
		var z: Array = L["zone"]
		var ph: Array = L.get("ph", [0, 0])
		var sz: Array = L["size"]
		var ang: Array = L.get("angle", [0, 0])
		var pal: Array = L["pal"]
		var parts: Array = []
		for i in n:
			parts.append({
				"pos_pct": Vector2(float(z[0]) + fposmod(float(ph[0]) + float(r2["a1"]) * (i + 1), 1.0) * float(z[2]), float(z[1]) + fposmod(float(ph[1]) + float(r2["a2"]) * (i + 1), 1.0) * float(z[3])),
				"size": lerpf(sz[0], sz[1], fposmod(float(r2["size"]) * (i + 1), 1.0)),
				"col": Color(str(pal[i % pal.size()])),
				"angle": lerpf(ang[0], ang[1], fposmod(0.5 + float(r2["rot"]) * (i + 1), 1.0)),
				"delay": -fposmod(float(r2["rot"]) * (i + 1), 1.0) * float(L["sec"]),
			})
		out.append({"layer": L, "parts": parts})
	return out


## Stanje čestice u t ∈ [0,1) ciklusa → {offset, rot, scale, alpha}. Petlja bez šava (= ambientAt u JS).
static func ambient_at(L: Dictionary, t: float) -> Dictionary:
	var fade := float(L.get("fade", 0.12))
	var a: Array = L.get("alpha", [0, 0.9])
	var drift: Array = L.get("drift", [0, 0])
	var sway: Array = L.get("sway", [0, 1])
	var pulse := float(L.get("pulse", 0.0))
	var edge := t / fade if t < fade else ((1.0 - t) / fade if t > 1.0 - fade else 1.0)
	var wave := 0.5 - 0.5 * cos(TAU * t)
	match str(L["motion"]):
		"float":
			return {"offset": Vector2(drift[0] * sin(TAU * t), drift[1] * sin(2.0 * TAU * t) * 0.5), "rot": float(L.get("rot", 0)) * sin(TAU * t), "scale": 1.0 + pulse * sin(TAU * t), "alpha": lerpf(a[0], a[1], wave)}
		"twinkle":
			return {"offset": Vector2.ZERO, "rot": 0.0, "scale": 1.0 + pulse * wave, "alpha": lerpf(a[0], a[1], wave)}
		"streak":
			var duty := float(L.get("duty", 0.22))
			if t > duty:
				return {"offset": Vector2(drift[0], drift[1]), "rot": 0.0, "scale": 1.0, "alpha": 0.0}
			var u := t / duty
			return {"offset": Vector2(drift[0], drift[1]) * u, "rot": 0.0, "scale": 1.0, "alpha": float(a[1]) * sin(PI * u)}
		_:
			var sw := float(sway[0]) * sin(TAU * float(sway[1]) * t)
			return {"offset": Vector2(drift[0] * t + sw, drift[1] * t), "rot": float(L.get("rot", 0)) * t, "scale": 1.0 + pulse * sin(TAU * t), "alpha": lerpf(a[0], a[1], edge)}


## Pločica materijala staze (izračunata u exportu): {period, items:[{k: rect|circle, x, y, w, h, r, f}]}.
static func lane_tile(season_id: String) -> Dictionary:
	return run_def(season_id).get("material_tile", {})


## Daljina / blizina runa: [{shape, pal, at:[[x, y, size, rot]]}] u pločici period × 1080.
static func run_items(season_id: String, which: String) -> Array:
	return run_def(season_id).get(which, {}).get("items", [])
