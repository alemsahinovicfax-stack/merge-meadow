## Season Kit faza 2 (PREPORUKE § 11): UiSeasons.ridge_y, scatter_at, ambient_layers i
## ambient_at daju iste brojeve kao CD-ov design/seasons_kit.js — 8 sezona, po 5–6 ulaza.
## Referenca: fixtures/season_kit_parity.json, generisana iz JS-a:
##   node scripts/art/gen_season_kit_parity.mjs > game/test/unit/fixtures/season_kit_parity.json
## Čiste funkcije — ne dira GameState ni save.
extends GutTest

const FIXTURE := "res://test/unit/fixtures/season_kit_parity.json"
const EPS := 0.0005

var _ref: Dictionary = {}


func before_all() -> void:
	_ref = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))


func test_fixture_covers_all_seasons() -> void:
	assert_eq(_ref.size(), 8, "8 sezona u referenci")
	for id in _ref:
		assert_false(UiSeasons.kit(str(id)).is_empty(), "%s ima kit" % id)


func test_ridge_y_matches_js() -> void:
	for id in _ref:
		var ref: Dictionary = _ref[id]
		var layer: Dictionary = UiSeasons.recipe(str(id), "field")["layers"][int(ref["ridge_layer"])]
		for row in ref["ridge"]:
			var got := UiSeasons.ridge_y(layer["r"], float(row[0]))
			assert_almost_eq(got, float(row[1]), EPS, "%s ridge_y(%s)" % [id, str(row[0])])


func test_scatter_at_matches_js() -> void:
	for id in _ref:
		var ref: Dictionary = _ref[id]
		var layer: Dictionary = UiSeasons.recipe(str(id), "field")["layers"][int(ref["scatter_layer"])]
		for row in ref["scatter"]:
			var it := UiSeasons.scatter_at(layer, int(row[0]))
			var tag := "%s scatter_at(%d)" % [id, int(row[0])]
			assert_almost_eq((it["pos"] as Vector2).x, float(row[1]), EPS, tag + " x")
			assert_almost_eq((it["pos"] as Vector2).y, float(row[2]), EPS, tag + " y")
			assert_almost_eq(float(it["size"]), float(row[3]), EPS, tag + " size")
			assert_almost_eq(float(it["rot"]), float(row[4]), EPS, tag + " rot")


func test_ambient_parts_match_js() -> void:
	for id in _ref:
		var ref: Dictionary = _ref[id]
		var entry: Dictionary = UiSeasons.ambient_layers(UiSeasons.ambient(str(id)))[int(ref["ambient_layer"])]
		var parts: Array = entry["parts"]
		for row in ref["parts"]:
			var p: Dictionary = parts[int(row[0])]
			var tag := "%s ambient part %d" % [id, int(row[0])]
			assert_almost_eq((p["pos"] as Vector2).x, float(row[1]), EPS, tag + " x")
			assert_almost_eq((p["pos"] as Vector2).y, float(row[2]), EPS, tag + " y")
			assert_almost_eq(float(p["size"]), float(row[3]), EPS, tag + " size")
			assert_almost_eq(float(p["angle"]), float(row[4]), EPS, tag + " angle")
			assert_almost_eq(float(p["delay"]), float(row[5]), EPS, tag + " delay")


func test_ambient_at_matches_js_for_every_motion() -> void:
	var motions := {}
	for id in _ref:
		var ref: Dictionary = _ref[id]
		var layers := UiSeasons.ambient_layers(UiSeasons.ambient(str(id)))
		for row in ref["at"]:
			var L: Dictionary = layers[int(row[0])]["layer"]
			motions[str(L["motion"])] = true
			var st := UiSeasons.ambient_at(L, float(row[1]))
			var tag := "%s %s ambient_at(%s)" % [id, L["motion"], str(row[1])]
			assert_almost_eq((st["offset"] as Vector2).x, float(row[2]), EPS, tag + " dx")
			assert_almost_eq((st["offset"] as Vector2).y, float(row[3]), EPS, tag + " dy")
			assert_almost_eq(float(st["rot"]), float(row[4]), EPS, tag + " rot")
			assert_almost_eq(float(st["scale"]), float(row[5]), EPS, tag + " scale")
			assert_almost_eq(float(st["alpha"]), float(row[6]), EPS, tag + " alpha")
	assert_eq(motions.size(), 6, "sve vrste kretanja pokrivene: %s" % str(motions.keys()))
