class_name UiSeasons
extends RefCounted

## Season Kit (design_handoff_seasons, faze 1 + 2 — svih 8 sezona) — jedan red podataka po
## sezoni, svaka površina je rez istog kita. Izvor brojeva: res://data/seasons/seasons_kit.json
## (= godot/seasons_export.json, generisan iz design/seasons_kit.js). Nova sezona = novi red
## u "kits", bez novog koda.
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
## Naklon cvijeta kad ga Pip njuši (faza 2): skala 1 → 1,08 → 1 i −4° za 0,3 s, pivot = baza.
const BOW := {"sec": 0.3, "scale": 1.08, "rot": -4.0}
## Čestice njuškanja (faza 2) su oblik PRVOG sloja ambijenta sezone (pahulja, svitac, list …):
## 3 × 14 px iz glave cvijeta, let (dx, −80), skala 0,6 → 1, alpha 0 → 1 (20 %) → 0.
const SNIFF_PUFF := {"n": 3, "sec": 0.7, "rise": 80.0, "stagger": 0.05, "dx": [-22.0, 0.0, 22.0], "d": 14.0}
const SLEEP_ZZZ := {"n": 3, "sec": 2.4, "stagger": 0.6, "fill": "#FFF8F0", "outline": 6, "sizes": [26, 32, 38]}
const GROW := {"sec": 0.42, "peak": 1.12}
## Ambijent polja ulazi poslije prelaza (Home v3: fade 0,3 s).
const AMBIENT_FADE_IN := 0.3
## Pip spava → ambijent se smiri (alpha 0,35 za 1,2 s).
const SLEEP_AMBIENT_ALPHA := 0.35
const SLEEP_AMBIENT_SEC := 1.2
## Njihanje cvijeća na polju: ±3°, period 3 + (i % 5) · 0,5 s, pivot = baza.
const SWAY_DEG := 3.0
const SWAY_SEC := 3.0
const SWAY_STEP := 0.5
## Reduce motion gasi i ambijent, ne samo njihanje (PREPORUKE § 12, odluka 2026-10-06):
## ambijent je čisti ukras — čestice stoje na srednjoj providnosti, bez petlje.
const REDUCE_MOTION_STOPS_AMBIENT := true
const PIP_ZONE := Rect2(151, 1306, 614, 131)   # ne mijenjati (§10.1)
const LOOKS_RECT := Rect2(876, 1265, 180, 180)
const CAMP_CARD := Vector2(1032, 318)
const SHOP_CARD := Vector2(1032, 364)
const SWIPE_SEC := 0.22
## Tekst na Camp kartici (recept "camp" je svijetao — #3D3D33 ≥ 4,5).
const CAMP_TEXT := Color("#3D3D33")
## Camp kartica: jedna tvrda sjena 0 8 0 (pravilo §8), ne meka iz paketa Camp link.
const CAMP_SHADOW := Color(26.0 / 255.0, 26.0 / 255.0, 20.0 / 255.0, 0.22)
const CAMP_SHADOW_Y := 8.0

## Zadane vrijednosti sloja ambijenta (ambientLayers u JS).
const _AMBIENT_DEFAULTS := {
	"fade": 0.12, "alpha": [0.0, 0.9], "sway": [0.0, 1.0], "rot": 0.0, "pulse": 0.0,
	"angle": [0.0, 0.0], "ph": [0.0, 0.0], "drift": [0.0, 0.0], "duty": 1.0, "pal2": [],
}

static var _data: Dictionary = {}
static var _colors: Dictionary = {}


static func data() -> Dictionary:
	if _data.is_empty() and FileAccess.file_exists(KIT_PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(KIT_PATH))
		if parsed is Dictionary:
			_data = parsed
	return _data


## Kit sezone ili prazno (svih 8 sezona ima kit od faze 2; nova sezona = novi red u kits).
static func kit(season_id: String) -> Dictionary:
	return data().get("kits", {}).get(season_id, {})


static func has_kit(season_id: String) -> bool:
	return not kit(season_id).is_empty()


static func palette(season_id: String) -> Dictionary:
	return kit(season_id).get("palette", {})


static func shapes() -> Dictionary:
	return data().get("shapes", {})


## R2 niz (bez RNG-a). Faza 2 ga drži u tokens.r2; faza 1 je imala r2 na vrhu.
static func r2() -> Dictionary:
	var d := data()
	var t: Dictionary = d.get("tokens", {})
	if t.has("r2"):
		return t["r2"]
	return d.get("r2", {"a1": UiArenaV2.R2_A1, "a2": UiArenaV2.R2_A2, "size": UiArenaV2.R2_SIZE, "rot": UiArenaV2.R2_ROT})


## Keepout kontrola polja (v2 + Looks) u % stranice — rasuti elementi tu ne crtaju centar.
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


## Recept površine: "field" (polje i kartica — isti recept), "shop", "camp" (prazno = nema).
static func recipe(season_id: String, surface: String) -> Dictionary:
	var k := kit(season_id)
	var r: Variant = null
	match surface:
		"field", "card":
			r = k.get("field", null)
		"shop", "camp":
			r = k.get(surface, null)
	return r if r is Dictionary else {}


static func ambient(season_id: String) -> Dictionary:
	return kit(season_id).get("ambient", {})


static func run_def(season_id: String) -> Dictionary:
	return kit(season_id).get("run", {})


static func arena_def(season_id: String) -> Dictionary:
	return kit(season_id).get("arena", {})


## Sezone u trakama Home tabova (Free / Premium), redom.
static func band(premium: bool) -> Array:
	return data().get("bands", {}).get("premium" if premium else "free", [])


## Ember Fen: crteži 50 %, „Coming soon", bez cijene i dugmeta.
static func is_soon(season_id: String) -> bool:
	return bool(kit(season_id).get("soon", false))


## Cvijet u Camp okviru = ★3 prethodne besplatne sezone ("" = nema).
static func camp_flower(season_id: String) -> String:
	var v: Variant = kit(season_id).get("camp_flower", null)
	return "" if v == null else str(v)


## Prepreka po vrsti spawna (0 = "stone", 1 = "stump") — SVG kita ili "".
static func obstacle_texture(season_id: String, kind_index: int) -> String:
	var obs: Array = run_def(season_id).get("obstacles", [])
	if obs.is_empty():
		return ""
	var o: Dictionary = obs[kind_index % obs.size()]
	return "res://" + str(o["svg"]).replace("assets/seasons/", "assets/sprites/seasons/")


## Pločica materijala staze (izračunata u exportu, laneTile u JS):
## {period, items: [{k: rect | circle, x, y, w, h, r, f}]} u px pločice širine staze 192.
static func lane_tile(season_id: String) -> Dictionary:
	return run_def(season_id).get("material_tile", {})


## Daljina / blizina runa: [{shape, pal, at: [[x, y, size, rot]]}] u px pločice 1080 × period.
static func run_items(season_id: String, which: String) -> Array:
	return run_def(season_id).get(which, {}).get("items", [])


## Greben: y(x) = y0 + tilt · (x − 50) / 100 + Σ a·sin(2π·f·x/100 + p), sve u %.
static func ridge_y(r: Dictionary, x: float) -> float:
	var y := float(r["y"]) + float(r.get("tilt", 0.0)) * (x - 50.0) / 100.0
	for w in r.get("w", []):
		y += float(w[0]) * sin(TAU * float(w[1]) * x / 100.0 + float(w[2]))
	return y


## Tačke grebena u % od x 0 do 100 (faza 2: sve unutar recta — ridgePts u JS).
static func ridge_points(r: Dictionary, step: float = 2.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x := 0.0
	while x <= 100.01:
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


## Čestice ambijenta (polje ili run) — isti format za svih 8 sezona (ambientLayers u JS).
## [{layer (sa zadanim vrijednostima), parts: [{i, pos (%), size, col, angle, delay}]}];
## ukupno ≤ AMBIENT_MAX. Po frejmu samo ambient_at().
static func ambient_layers(def: Dictionary) -> Array:
	var out: Array = []
	if def.is_empty():
		return out
	var q := r2()
	var a1 := float(q["a1"])
	var a2 := float(q["a2"])
	var qs := float(q["size"])
	var qr := float(q["rot"])
	var left := AMBIENT_MAX
	for L0 in def.get("layers", []):
		var L: Dictionary = _AMBIENT_DEFAULTS.duplicate(true)
		L.merge(L0, true)
		var n := mini(int(L["n"]), left)
		left -= n
		var z: Array = L["zone"]
		var ph: Array = L["ph"]
		var sz: Array = L["size"]
		var ang: Array = L["angle"]
		var pal: Array = L["pal"]
		var sec := float(L["sec"])
		var parts: Array = []
		for i in n:
			parts.append({
				"i": i,
				"pos": Vector2(
					float(z[0]) + fposmod(float(ph[0]) + a1 * (i + 1), 1.0) * float(z[2]),
					float(z[1]) + fposmod(float(ph[1]) + a2 * (i + 1), 1.0) * float(z[3])
				),
				"size": lerpf(float(sz[0]), float(sz[1]), fposmod(qs * (i + 1), 1.0)),
				"col": str(pal[i % pal.size()]),
				"angle": lerpf(float(ang[0]), float(ang[1]), fposmod(0.5 + qr * (i + 1), 1.0)),
				"delay": -fposmod(qr * (i + 1), 1.0) * sec,
			})
		out.append({"layer": L, "parts": parts})
	return out


static func ambient_count(def: Dictionary) -> int:
	var n := 0
	for entry in ambient_layers(def):
		n += (entry["parts"] as Array).size()
	return n


## Stanje čestice u t ∈ [0, 1) ciklusa (ambientAt u JS) → {offset px, rot °, scale, alpha}.
## drift / fall / rise: klizi drift po ciklusu (+ njihanje sway), ivice fade · float: ljulja se
## oko tačke · twinkle: stoji, alpha + pulse · streak: preleti drift u duty dijelu ciklusa.
static func ambient_at(L: Dictionary, t: float) -> Dictionary:
	var fade := float(L["fade"])
	var a: Array = L["alpha"]
	var drift: Array = L["drift"]
	var sway: Array = L["sway"]
	var pulse := float(L["pulse"])
	var rot := float(L["rot"])
	var edge := 1.0
	if t < fade:
		edge = t / fade
	elif t > 1.0 - fade:
		edge = (1.0 - t) / fade
	var wave := 0.5 - 0.5 * cos(TAU * t)
	var pul := 1.0 + pulse * sin(TAU * t)
	match str(L["motion"]):
		"float":
			return {
				"offset": Vector2(float(drift[0]) * sin(TAU * t), float(drift[1]) * sin(2.0 * TAU * t) * 0.5),
				"rot": rot * sin(TAU * t), "scale": pul, "alpha": lerpf(float(a[0]), float(a[1]), wave),
			}
		"twinkle":
			return {"offset": Vector2.ZERO, "rot": 0.0, "scale": 1.0 + pulse * wave, "alpha": lerpf(float(a[0]), float(a[1]), wave)}
		"streak":
			var duty := float(L["duty"])
			if t > duty:
				return {"offset": Vector2(float(drift[0]), float(drift[1])), "rot": 0.0, "scale": 1.0, "alpha": 0.0}
			var u := t / duty
			return {"offset": Vector2(float(drift[0]), float(drift[1])) * u, "rot": 0.0, "scale": 1.0, "alpha": float(a[1]) * sin(PI * u)}
	var sw := float(sway[0]) * sin(TAU * float(sway[1]) * t)
	return {
		"offset": Vector2(float(drift[0]) * t + sw, float(drift[1]) * t),
		"rot": rot * t, "scale": pul, "alpha": lerpf(float(a[0]), float(a[1]), edge),
	}


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
