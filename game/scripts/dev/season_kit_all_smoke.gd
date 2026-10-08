extends SceneTree

## Season Kit faza 2 — svih 8 sezona iz kita (design_handoff_seasons, PREPORUKE § 0–11):
## recept polja / Shopa / Campa se gradi i ne izlazi iz recta, 18 crteža cvijeća i 2
## prepreke se učitavaju, ambijent ≤ 24 (polje i run), run ima materijal / daljinu / blizinu,
## Arena spaja kit (svaki ključ kita pogađa sloj ili rasuti element), i kontrast iz
## geometrije recepta: naljepnice polja ≥ 6,14, tekst na livadi ≥ 4,5, coin / staza ≥ 3
## (iste kontrole, ispune i pravougaonici kao samoprovjera u Season Specs.dc.html).

const IDS := ["country_bloom", "frost_orchard", "lantern_meadow", "amber_canopy",
	"moonlit_warren", "coral_tide", "starfall_glade", "ember_fen"]
const FILLS := {"cream": "#FFF8F0", "peach": "#FFB88C", "lavender": "#D4A5FF"}
const CTRL := [
	["Gift", [24, 24, 180, 180], "cream"], ["Basket", [24, 220, 180, 180], "cream"],
	["Upgrades", [876, 24, 180, 180], "cream"], ["Looks", [876, 1265, 180, 180], "cream"],
	["GrownChip", [300, 112, 480, 76], "cream"], ["Seasons", [70, 1477, 236, 124], "cream"],
	["Play", [324, 1461, 432, 140], "peach"], ["Endless", [774, 1477, 236, 124], "lavender"],
]
const TEXT := [["SeasonName", [240, 36, 600, 60]]]
const SAMPLE_STEP := 12
const CELL := 64.0
## Run pozadina se učitava u _run(): skripta koristi autoload GameState (greske-katalog #21).
const LANE_PATH := "res://scripts/visual/lane_background.gd"

var _backup: String = ""
var _failed: bool = false
var _report: PackedStringArray = []


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _fail(msg: String) -> void:
	_failed = true
	push_error("season_kit_all_smoke: %s" % msg)


func _run() -> void:
	await process_frame
	var bands: Array = UiSeasons.band(false) + UiSeasons.band(true)
	if bands != IDS:
		_fail("bands %s != %s" % [str(bands), str(IDS)])
	for id in IDS:
		_check_season(str(id))
	for line in _report:
		print(line)
	if _failed:
		_quit(1)
		return
	print("season_kit_all_smoke OK")
	_quit(0)


func _check_season(id: String) -> void:
	var kit := UiSeasons.kit(id)
	if kit.is_empty():
		_fail("%s has no kit" % id)
		return
	var def: SeasonDef = SeasonCatalog.get_def(id)
	# Polje = kartica (isti recept), sve u [0, 100] %.
	var field := SeasonBackdrop.field_scene(id)
	if field.is_empty():
		_fail("%s field scene empty" % id)
		return
	_check_inside(id, "field", field)
	# Shop (plaćene) i Camp (besplatne s prethodnom) recepti.
	if def != null and def.is_paid():
		var shop := UiSeasons.recipe(id, "shop")
		if shop.is_empty():
			_fail("%s paid season without shop recipe" % id)
		else:
			_check_inside(id, "shop", SeasonBackdrop.scene("shop:" + id, shop, float(shop.get("w", 1032)), []))
	var prev := str(kit.get("prev_free", "")) if kit.get("prev_free") != null else ""
	if not prev.is_empty():
		var camp := UiSeasons.recipe(id, "camp")
		if camp.is_empty():
			_fail("%s free season after %s without camp recipe" % [id, prev])
		else:
			_check_inside(id, "camp", SeasonBackdrop.scene("camp:" + id, camp, float(camp.get("w", 1032)), []))
		if UiSeasons.camp_flower(id) != str(get_root().get_node("GameState").call("star3_type_id_for_season", prev)):
			_fail("%s camp_flower %s != ★3 of %s" % [id, UiSeasons.camp_flower(id), prev])
	# Cvijeće: 6 tipova × 3 tiera.
	if def != null:
		for t in def.seed_type_ids:
			for tier in [1, 2, 3]:
				if FlowerAssets.get_texture(str(t), tier) == null:
					_fail("%s flower %s_t%d missing" % [id, t, tier])
	# Ambijent polja i runa.
	var amb_field := UiSeasons.ambient_count(UiSeasons.ambient(id))
	var amb_run := UiSeasons.ambient_count(UiSeasons.run_def(id).get("ambient", {}))
	if amb_field < 1 or amb_field > UiSeasons.AMBIENT_MAX:
		_fail("%s field ambient %d" % [id, amb_field])
	if amb_run < 1 or amb_run > UiSeasons.AMBIENT_MAX:
		_fail("%s run ambient %d" % [id, amb_run])
	if SeasonAmbient.build_parts(UiSeasons.ambient(id)).size() != amb_field:
		_fail("%s ambient parts mismatch" % id)
	# Run: materijal, daljina, blizina, 2 prepreke.
	var lane: Node = (load(LANE_PATH) as GDScript).new()
	lane.call("_build_kit", id)
	for key in ["_lane_tile", "_far", "_near"]:
		var m: Dictionary = lane.get(key)
		if m.is_empty() or (m["pts"] as PackedVector2Array).is_empty():
			_fail("%s run %s empty" % [id, key])
	lane.free()
	for kind in [0, 1]:
		var path := UiSeasons.obstacle_texture(id, kind)
		if path.is_empty() or not ResourceLoader.exists(path) or load(path) == null:
			_fail("%s obstacle %d missing (%s)" % [id, kind, path])
	# Arena: svaki ključ kita mora pogoditi sloj / rasuti element (inače boja kita ne stiže).
	_check_arena(id)
	# Kontrast iz geometrije recepta.
	_check_contrast(id, kit, field)


func _check_inside(id: String, what: String, sc: Dictionary) -> void:
	for chunk in sc["chunks"]:
		if bool(chunk["line"]):
			for q in chunk["pts"]:
				if not _in_pct(q):
					_fail("%s %s line point %s outside 0–100" % [id, what, str(q)])
					return
			continue
		for it in chunk["items"]:
			if bool(it["pct"]):
				for q in it["pts"]:
					if not _in_pct(q):
						_fail("%s %s fill point %s outside 0–100" % [id, what, str(q)])
						return


func _in_pct(q: Vector2) -> bool:
	return q.x >= -0.01 and q.x <= 100.01 and q.y >= -0.01 and q.y <= 100.01


func _check_arena(id: String) -> void:
	var a := UiSeasons.arena_def(id)
	var f := UiArenaV2.field(id)
	if not bool(f.get("kit", false)):
		_fail("%s arena field not merged with kit" % id)
		return
	var layer_ids := {}
	for L in f["layers"]:
		layer_ids[str(L.get("id", ""))] = true
	for key in a.get("layers", {}):
		if not layer_ids.has(str(key)):
			_fail("%s arena kit layer '%s' matches no FIELDS layer %s" % [id, key, str(layer_ids.keys())])
	var scatter_ids := {}
	for s in f["scatter"]:
		scatter_ids[str(s.get("id", ""))] = true
	for key in a.get("scatter", {}):
		if not scatter_ids.has(str(key)):
			_fail("%s arena kit scatter '%s' matches no FIELDS scatter %s" % [id, key, str(scatter_ids.keys())])


func _check_contrast(id: String, kit: Dictionary, field: Dictionary) -> void:
	var page := UiSeasons.PAGE
	var tris := _triangles(field, Rect2(Vector2.ZERO, page))
	var grid := _bin(tris, page)
	var worst_sticker := 99.0
	var worst_name := ""
	for c in CTRL:
		var r: Array = c[1]
		var fill := Color(str(FILLS[str(c[2])]))
		for p in _samples(r):
			var bg := _color_at(tris, grid, p)
			var v := UiSeasons.sticker_contrast(fill, bg)
			if v < worst_sticker:
				worst_sticker = v
				worst_name = "%s @ %s bg %s" % [c[0], str(p), bg.to_html(false)]
	if worst_sticker < UiSeasons.STICKER_MIN:
		_fail("%s sticker contrast %.2f < %.2f (%s)" % [id, worst_sticker, UiSeasons.STICKER_MIN, worst_name])
	var ink := UiSeasons.ink_field(id)
	var worst_text := 99.0
	var text_name := ""
	for t in TEXT:
		for p in _samples(t[1]):
			var bg := _color_at(tris, grid, p)
			var v := UiSeasons.contrast(ink, bg)
			if v < worst_text:
				worst_text = v
				text_name = "%s @ %s bg %s" % [t[0], str(p), bg.to_html(false)]
	if worst_text < UiSeasons.TEXT_MIN:
		_fail("%s text contrast %.2f < %.2f (%s)" % [id, worst_text, UiSeasons.TEXT_MIN, text_name])
	var lane := UiSeasons.col(str(UiSeasons.run_def(id)["lane"]))
	var coin := UiSeasons.contrast(Color("#FFD56B"), lane)
	if coin < UiSeasons.OBJECT_MIN:
		_fail("%s run coin / lane %.2f < 3" % [id, coin])
	_report.append("  %-15s sticker %.2f (%s) · text %.2f · coin/lane %.2f · tris %d" % [id, worst_sticker, worst_name.get_slice(" ", 0), worst_text, coin, tris.size()])


func _samples(r: Array) -> Array:
	var out: Array = []
	var y := float(r[1])
	while y < float(r[1]) + float(r[3]):
		var x := float(r[0])
		while x < float(r[0]) + float(r[2]):
			out.append(Vector2(x, y))
			x += SAMPLE_STEP
		y += SAMPLE_STEP
	return out


## Trokuti scene u redoslijedu crtanja (isto kao SeasonBackdrop.draw): [a, b, c, color].
## Linije (rub grebena, letve, girlanda) idu kao četverouglovi širine w · k.
func _triangles(sc: Dictionary, rect: Rect2) -> Array:
	var out: Array = []
	var w := rect.size.x
	var k := w / float(sc["base_w"])
	var pct := Vector2(w / 100.0, rect.size.y / 100.0)
	var pct_xf := Transform2D(0.0, pct, 0.0, rect.position)
	for chunk in sc["chunks"]:
		if bool(chunk["line"]):
			var lxf := Transform2D(0.0, pct, 0.0, rect.position + (chunk["off"] as Vector2) * k)
			var line: PackedVector2Array = lxf * (chunk["pts"] as PackedVector2Array)
			var half := float(chunk["w"]) * k * 0.5
			for i in line.size() - 1:
				var d := line[i + 1] - line[i]
				if d.length_squared() < 1e-6:
					continue
				var n := Vector2(-d.y, d.x).normalized() * half
				out.append([line[i] + n, line[i + 1] + n, line[i + 1] - n, chunk["col"]])
				out.append([line[i] + n, line[i + 1] - n, line[i] - n, chunk["col"]])
			continue
		var pts := PackedVector2Array()
		for it in chunk["items"]:
			if bool(it["pct"]):
				pts.append_array(pct_xf * (it["pts"] as PackedVector2Array))
			else:
				var anchor := rect.position + (it["at"] as Vector2) * pct + (it["off"] as Vector2) * k
				var s := float(it["size"]) * k
				pts.append_array(Transform2D(0.0, Vector2(s, s), 0.0, anchor) * (it["pts"] as PackedVector2Array))
		var idx: PackedInt32Array = chunk["idx"]
		var cols: PackedColorArray = chunk["cols"]
		for t in range(0, idx.size(), 3):
			out.append([pts[idx[t]], pts[idx[t + 1]], pts[idx[t + 2]], cols[idx[t]]])
	return out


## Mreža ćelija → indeksi trokuta (rastući = redoslijed crtanja). Array, ne Packed:
## Packed nizovi su copy-on-write, pa append na grid[key] ne bi stigao u rječnik.
func _bin(tris: Array, page: Vector2) -> Dictionary:
	var grid := {}
	for i in tris.size():
		var t: Array = tris[i]
		var lo: Vector2 = (t[0] as Vector2).min(t[1]).min(t[2])
		var hi: Vector2 = (t[0] as Vector2).max(t[1]).max(t[2])
		for cy in range(int(floorf(lo.y / CELL)), int(floorf(hi.y / CELL)) + 1):
			for cx in range(int(floorf(lo.x / CELL)), int(floorf(hi.x / CELL)) + 1):
				var key := Vector2i(cx, cy)
				if not grid.has(key):
					grid[key] = []
				(grid[key] as Array).append(i)
	return grid


func _color_at(tris: Array, grid: Dictionary, p: Vector2) -> Color:
	var out := Color(1, 1, 1, 1)
	var key := Vector2i(int(floorf(p.x / CELL)), int(floorf(p.y / CELL)))
	if not grid.has(key):
		return out
	for i in grid[key]:
		var t: Array = tris[i]
		if Geometry2D.point_is_inside_triangle(p, t[0], t[1], t[2]):
			var c: Color = t[3]
			out = Color(lerpf(out.r, c.r, c.a), lerpf(out.g, c.g, c.a), lerpf(out.b, c.b, c.a), 1.0)
	return out
