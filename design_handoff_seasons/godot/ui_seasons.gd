class_name UiSeasons
extends RefCounted

## Season Kit (faza 1) — jedan red podataka po sezoni, svaka površina je rez istog kita.
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
		"shop":
			var s: Variant = k.get("shop", null)
			return s if s is Dictionary else {}
		_:
			return {}


static func run_def(season_id: String) -> Dictionary:
	return kit(season_id).get("run", {})


## Greben: y(x) = y0 + Σ a·sin(2π·f·x/100 + p), sve u %.
static func ridge_y(r: Dictionary, x: float) -> float:
	var y := float(r["y"])
	for w in r.get("w", []):
		y += float(w[0]) * sin(TAU * float(w[1]) * x / 100.0 + float(w[2]))
	return y


static func ridge_points(r: Dictionary, size: Vector2, step: float = 2.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x := -2.0
	while x <= 102.01:
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
