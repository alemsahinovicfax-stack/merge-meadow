class_name UiSeasons
extends RefCounted

## Season Kit (design_handoff_seasons, faza 1) — jedan red podataka po sezoni, svaka
## površina je rez istog kita. Izvor brojeva: res://data/seasons/seasons_kit.json
## (= godot/seasons_export.json, generisan iz design/seasons_kit.js). Nova sezona = novi
## red u "kits", bez novog koda. Sezona bez kita crta današnji izgled (trake + tint).
## Recept se pretvara u mrežu jednom (SeasonBackdrop.scene); po frejmu samo tačke.

const KIT_PATH := "res://data/seasons/seasons_kit.json"
const PAGE := Vector2(1080, 1633)
const STICKER_MIN := 6.14   # naljepnica: max(c(ink rub, livada), c(fill, livada))
const TEXT_MIN := 4.5
const OBJECT_MIN := 3.0
const AMBIENT_MAX := 24
const LOOPS_MAX := 2

## Pip poze na polju (iste boje kao pip_idle.svg, pa skin recolor radi i na njima).
const PIP_TEX := {
	"walk": "res://assets/sprites/pip_idle.svg",
	"sniff": "res://assets/sprites/pip_sniff.svg",
	"sleep": "res://assets/sprites/pip_sleep.svg",
}
const PIP_BOB_SEC := 0.42
const PIP_BOB_Y := -7.0
const PIP_BOB_SQUASH := Vector2(0.97, 1.03)
const PIP_SLEEP_SQUASH := Vector2(1.04, 0.94)
## Naklon cvijeta kad ga Pip njuši: [t, rotacija°, skala y], pivot = baza.
const SNIFF_BOW := {"sec": 0.6, "keys": [[0.0, 0.0, 1.0], [0.35, -9.0, 0.94], [0.7, 4.0, 1.0], [1.0, 0.0, 1.0]]}
const SNIFF_PUFF := {"n": 5, "sec": 0.7, "rise": 80.0, "stagger": 0.05, "dx": [-30.0, -14.0, 0.0, 14.0, 30.0], "d": 14.0}
const SLEEP_ZZZ := {"n": 3, "sec": 2.4, "stagger": 0.6, "fill": "#FFF8F0", "outline": 6, "sizes": [26, 32, 38]}
const GROW := {"sec": 0.42, "peak": 1.12}
## Ambijent polja ulazi poslije prelaza (Home v3: fade 0,3 s).
const AMBIENT_FADE_IN := 0.3

static var _data: Dictionary = {}
static var _colors: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty() and FileAccess.file_exists(KIT_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(KIT_PATH))
		if parsed is Dictionary:
			_data = parsed
	return _data


## Kit sezone ili prazno (sezona bez kita → današnji izgled: trake + SeasonTheme tint).
static func kit(season_id: String) -> Dictionary:
	return data().get("kits", {}).get(season_id, {})


static func has_kit(season_id: String) -> bool:
	return not kit(season_id).is_empty()


static func palette(season_id: String) -> Dictionary:
	return kit(season_id).get("palette", {})


static func shapes() -> Dictionary:
	return data().get("shapes", {})


static func r2() -> Dictionary:
	return data().get("r2", {"a1": UiArenaV2.R2_A1, "a2": UiArenaV2.R2_A2, "size": UiArenaV2.R2_SIZE, "rot": UiArenaV2.R2_ROT})


## Keepout kontrola polja (v2) u % stranice — rasuti elementi tu ne crtaju centar.
static func field_avoid() -> Array:
	return data().get("field_avoid", [])


## Boja teksta direktno na livadi (#1A1A14 svijetli kitovi, #FFF8F0 tamni).
static func ink_field(season_id: String, fallback: Color = UiHomeV3.INK_DEEP) -> Color:
	var p := palette(season_id)
	return col(str(p["ink_field"])) if p.has("ink_field") else fallback


## Tamni kit (tekst na livadi je svijetao) — tamne pilule zemlje i sjene cvijeća.
static func is_dark(season_id: String) -> bool:
	return has_kit(season_id) and ink_field(season_id).get_luminance() > 0.5


## Pozadina stranice izbora (ostaje svijetla i za tamne kitove — tabovi stoje na njoj).
static func page_color(season_id: String, fallback: Color) -> Color:
	var p := palette(season_id)
	return col(str(p["page"])) if p.has("page") else fallback


## 13 mjesta: [x %, y % od dna, veličina, indeks u rosteru, prag ★3].
static func spots(season_id: String) -> Array:
	return kit(season_id).get("spots", UiHomeField.MEADOW_SPOTS)


## Recept površine: "field" (polje i kartica — isti recept), "shop" (null = trake).
static func recipe(season_id: String, surface: String) -> Dictionary:
	var k := kit(season_id)
	var r: Variant = null
	match surface:
		"field", "card":
			r = k.get("field", null)
		"shop":
			r = k.get("shop", null)
	return r if r is Dictionary else {}


static func ambient(season_id: String) -> Dictionary:
	return kit(season_id).get("ambient", {})


static func run_def(season_id: String) -> Dictionary:
	return kit(season_id).get("run", {})


static func arena_def(season_id: String) -> Dictionary:
	return kit(season_id).get("arena", {})


## Prepreka po vrsti spawna (0 = "stone", 1 = "stump") — SVG kita ili "".
static func obstacle_texture(season_id: String, kind_index: int) -> String:
	var obs: Array = run_def(season_id).get("obstacles", [])
	if obs.is_empty():
		return ""
	var o: Dictionary = obs[kind_index % obs.size()]
	return "res://" + str(o["svg"]).replace("assets/seasons/", "assets/sprites/seasons/")


## Greben: y(x) = y0 + Σ a·sin(2π·f·x/100 + p), sve u %.
static func ridge_y(r: Dictionary, x: float) -> float:
	var y := float(r["y"])
	for w in r.get("w", []):
		y += float(w[0]) * sin(TAU * float(w[1]) * x / 100.0 + float(w[2]))
	return y


## Tačke grebena u % od x −2 do 102 (isto kao ridgePts u JS).
static func ridge_points(r: Dictionary, step: float = 2.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x := -2.0
	while x <= 102.01:
		pts.append(Vector2(x, ridge_y(r, x)))
		x += step
	return pts


## Rasuti element i (R2 niz, bez RNG-a) — isto kao scatterAt u JS. Pozicija u %.
static func scatter_at(layer: Dictionary, i: int) -> Dictionary:
	var q := r2()
	var zones: Array = layer["zones"]
	var z: Array = zones[i % zones.size()]
	var k := i / zones.size()
	var ph: Array = layer["phase"]
	var x := float(z[0]) + fposmod(float(ph[0]) + float(q["a1"]) * (k + 1), 1.0) * float(z[2])
	var y := float(z[1]) + fposmod(float(ph[1]) + float(q["a2"]) * (k + 1), 1.0) * float(z[3])
	var sz: Array = layer["size"]
	var rt: Array = layer.get("rot", [0, 0])
	var size := lerpf(float(sz[0]), float(sz[1]), fposmod(float(ph[2]) + float(q["size"]) * (i + 1), 1.0))
	var rot := lerpf(float(rt[0]), float(rt[1]), fposmod(float(ph[3]) + float(q["rot"]) * (i + 1), 1.0))
	return {"pos": Vector2(x, y), "size": size, "rot": rot}


static func in_avoid(pos_pct: Vector2, avoid: Array) -> bool:
	for a in avoid:
		if pos_pct.x >= float(a[0]) and pos_pct.x <= float(a[0]) + float(a[2]) \
				and pos_pct.y >= float(a[1]) and pos_pct.y <= float(a[1]) + float(a[3]):
			return true
	return false


## 13 mjesta u px recta: {i, base (sredina dna), size, idx, need}. Kartica i prelaz:
## rect = trenutni rect kartice; na rect = stranica isti pikseli kao polje.
static func spot_rects(season_id: String, rect_size: Vector2) -> Array:
	var out: Array = []
	var k := rect_size.x / PAGE.x
	var list := spots(season_id)
	for i in list.size():
		var s: Array = list[i]
		out.append({
			"i": i,
			"base": Vector2(float(s[0]) / 100.0 * rect_size.x, rect_size.y - float(s[1]) / 100.0 * rect_size.y),
			"size": float(s[2]) * k, "idx": int(s[3]), "need": int(s[4]),
		})
	return out


## "#RRGGBB", "#RRGGBBAA" ili "rgba(r,g,b,a)" (run, sjene) — keš po stringu.
static func col(value: String) -> Color:
	if _colors.has(value):
		return _colors[value]
	var c := UiArenaV2.col(value) if value.begins_with("rgba(") else Color(value)
	_colors[value] = c
	return c


## WCAG kontrast (sRGB → linearno prije luminanse, kao lum() u seasons_kit.js).
static func contrast(a: Color, b: Color) -> float:
	var la := a.srgb_to_linear().get_luminance()
	var lb := b.srgb_to_linear().get_luminance()
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)


static func sticker_contrast(fill: Color, bg: Color, ink: Color = Color("#2D3436")) -> float:
	return maxf(contrast(ink, bg), contrast(fill, bg))
