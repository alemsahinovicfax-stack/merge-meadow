class_name SeedVisualConfig
extends RefCounted

## Boje i proceduralni crtež: Country Bloom 6 imaju bespoke paletu; ostali
## catalog id-evi dobiju paletu iz sezonske nijanse (SEASON_HUE) + mali
## per-type hue jitter, umjesto čistog hasha — sezone ostaju vizuelno
## dosljedne, tipovi unutar sezone i dalje razlikuju nijansu.

const STEM := Color(0.35, 0.62, 0.32, 1.0)
const LEAF := Color(0.42, 0.76, 0.38, 1.0)

## docs/04-experience/design-drafts/seeds-flowers-cd-brief.md §5 — akcent po sezoni.
const SEASON_HUE: Dictionary = {
	"frost_orchard": 0.55,
	"lantern_meadow": 0.10,
	"amber_canopy": 0.06,
	"moonlit_warren": 0.65,
	"coral_tide": 0.97,
	"starfall_glade": 0.78,
	"ember_fen": 0.02,
}

const PALETTES: Dictionary = {
	"clover": {
		"petal": Color(0.55, 0.85, 0.5, 1.0),
		"center": Color(1.0, 0.92, 0.5, 1.0),
		"seed": Color(0.5, 0.82, 0.45, 1.0),
		"crystal": Color(0.75, 0.55, 0.95, 1.0),
	},
	"daisy": {
		"petal": Color(0.98, 0.98, 0.96, 1.0),
		"center": Color(1.0, 0.82, 0.2, 1.0),
		"seed": Color(0.85, 0.88, 0.55, 1.0),
		"crystal": Color(0.95, 0.78, 0.35, 1.0),
	},
	"buttercup": {
		"petal": Color(1.0, 0.88, 0.15, 1.0),
		"center": Color(0.95, 0.65, 0.1, 1.0),
		"seed": Color(0.92, 0.82, 0.2, 1.0),
		"crystal": Color(1.0, 0.72, 0.12, 1.0),
	},
	"tulip": {
		"petal": Color(0.92, 0.28, 0.42, 1.0),
		"center": Color(0.55, 0.15, 0.22, 1.0),
		"seed": Color(0.78, 0.35, 0.45, 1.0),
		"crystal": Color(0.85, 0.35, 0.55, 1.0),
	},
	"sunflower": {
		"petal": Color(1.0, 0.78, 0.12, 1.0),
		"center": Color(0.45, 0.28, 0.12, 1.0),
		"seed": Color(0.88, 0.72, 0.18, 1.0),
		"crystal": Color(0.95, 0.62, 0.08, 1.0),
	},
	"pumpkin": {
		"petal": Color(0.95, 0.52, 0.12, 1.0),
		"center": Color(0.55, 0.32, 0.08, 1.0),
		"seed": Color(0.88, 0.55, 0.15, 1.0),
		"crystal": Color(0.92, 0.48, 0.05, 1.0),
	},
}


static func palette(type_id: String) -> Dictionary:
	if PALETTES.has(type_id):
		return PALETTES[type_id]
	return _seasonal_palette(type_id)


static func _seasonal_palette(type_id: String) -> Dictionary:
	var base_hue: float = SEASON_HUE.get(SeedCatalog.season_id_for(type_id), -1.0)
	if base_hue < 0.0:
		base_hue = float(absi(type_id.hash()) % 360) / 360.0
	var jitter := (float(absi(type_id.hash()) % 100) / 100.0 - 0.5) * 0.08
	var hue := fmod(base_hue + jitter + 1.0, 1.0)
	var petal := Color.from_hsv(hue, 0.55, 0.92)
	var center := Color.from_hsv(fmod(hue + 0.08, 1.0), 0.65, 0.78)
	var seed := Color.from_hsv(hue, 0.48, 0.85)
	var crystal := Color.from_hsv(fmod(hue + 0.15, 1.0), 0.55, 0.96)
	return {
		"petal": petal,
		"center": center,
		"seed": seed,
		"crystal": crystal,
	}


static func draw_run_seed(canvas: CanvasItem, type_id: String) -> void:
	var pal := palette(type_id)
	canvas.draw_circle(Vector2.ZERO, 22.0, pal.seed)
	canvas.draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color(0.18, 0.2, 0.18, 0.35), 2.0)
	match type_id:
		"clover":
			canvas.draw_circle(Vector2(-8, -4), 6.0, LEAF)
			canvas.draw_circle(Vector2(8, -4), 6.0, LEAF)
			canvas.draw_circle(Vector2(0, -10), 6.0, LEAF)
		"daisy":
			for i in 6:
				var a := float(i) / 6.0 * TAU
				canvas.draw_circle(Vector2(cos(a), sin(a)) * 14.0, 5.0, pal.petal)
			canvas.draw_circle(Vector2.ZERO, 7.0, pal.center)
		"buttercup":
			for i in 5:
				var a := float(i) / 5.0 * TAU - PI / 2.0
				canvas.draw_circle(Vector2(cos(a), sin(a)) * 12.0, 6.0, pal.petal)
			canvas.draw_circle(Vector2.ZERO, 6.0, pal.center)
		"tulip":
			canvas.draw_circle(Vector2(0, 4), 14.0, pal.petal)
			canvas.draw_circle(Vector2(-8, 8), 8.0, pal.petal.darkened(0.08))
			canvas.draw_circle(Vector2(8, 8), 8.0, pal.petal.darkened(0.08))
		"sunflower":
			for i in 8:
				var a := float(i) / 8.0 * TAU
				canvas.draw_circle(Vector2(cos(a), sin(a)) * 15.0, 4.5, pal.petal)
			canvas.draw_circle(Vector2.ZERO, 9.0, pal.center)
		"pumpkin":
			canvas.draw_circle(Vector2(0, 2), 16.0, pal.petal)
			canvas.draw_line(Vector2(0, -14), Vector2(0, -6), STEM, 3.0)
			canvas.draw_circle(Vector2(0, -16), 4.0, LEAF)
		_:
			_draw_generic_run_seed(canvas, pal, SeedCatalog.rarity(type_id))


## Rarity → kompleksnost (seeds-flowers-cd-brief.md §4): ★ malo latica jedne
## boje, ★★ više latica dvotonski, ★★★ najviše latica + dvotonski.
static func _draw_generic_run_seed(canvas: CanvasItem, pal: Dictionary, rarity: int) -> void:
	var petal_count := 4
	if rarity >= 2:
		petal_count = 6
	if rarity >= 3:
		petal_count = 8
	for i in petal_count:
		var a := float(i) / petal_count * TAU
		var petal_color: Color = pal.petal
		if rarity >= 2 and i % 2 == 1:
			petal_color = pal.petal.lightened(0.12)
		canvas.draw_circle(Vector2(cos(a), sin(a)) * 13.0, 5.0, petal_color)
	canvas.draw_circle(Vector2.ZERO, 7.0, pal.center)
