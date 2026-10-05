class_name SeasonBackdrop
extends RefCounted

## Season Kit renderer (design_handoff_seasons § Odlučeno 1–2): recept kita → mreža trokuta,
## JEDNOM po receptu. Slojevi (band, ridge, mow) su u % recta, oblici (shape, scatter,
## stubovi ograde) uniformno k = w / 1080 — isto kao buildScene u design/seasons_kit.js.
## Zato ista mreža crta polje (1080 x 1633), karticu izbora (minijatura) i svaki kadar
## prelaza između: po crtanju se računaju samo tačke (Transform2D * PackedVector2Array),
## indeksi i boje ostaju. Generalizovani ArenaMeadowBg; 0 PNG, 0 gradijenata.
## Ništa ne izlazi iz recta: GL Compat na laptopu ne reže crtanje (ni clip_contents ni
## scissor RenderingServera nisu rezali u probi 2026-10-05), a kartice Homea i Shopa nemaju
## šta drugo da ih odreže. Slojevi u % se režu na [0, 100] jednom pri gradnji (ne zavise od
## omjera recta); oblik koji viri preko ivice reže se pri crtanju, trokut po trokut.

const ELLIPSE_STEPS := 20
const ARC_STEPS := 8
const RECT_CORNER_STEPS := 4
## Preklop traka neba (u %) — kao u JS, bez AA šava između traka.
const BAND_OVERLAP := 0.6
const CORNER_STEPS := 12
const PCT_BOX := [Vector2(0, 0), Vector2(100, 0), Vector2(100, 100), Vector2(0, 100)]

static var _scenes: Dictionary = {}
static var _shape_cache: Dictionary = {}


## Mreža recepta (keš po ključu). base_w = širina za koju su zadane veličine oblika
## (1080 za polje i karticu; 1032 za Shop karticu). avoid = keepout zone u %.
static func scene(key: String, recipe: Dictionary, base_w: float = 1080.0, avoid: Array = []) -> Dictionary:
	if _scenes.has(key):
		return _scenes[key]
	var s := _build(recipe, base_w, avoid)
	_scenes[key] = s
	return s


## Polje i kartica sezone: isti recept, iste keepout zone kontrola polja.
static func field_scene(season_id: String) -> Dictionary:
	var r := UiSeasons.recipe(season_id, "field")
	if r.is_empty():
		return {}
	return scene("field:" + season_id, r, UiSeasons.PAGE.x, UiSeasons.field_avoid())


static func clear_cache() -> void:
	_scenes.clear()


## Crta mrežu u `rect` (lokalne koordinate platna). Isti recept na rect = stranica daje
## iste piksele kao polje; na rect kartice je minijatura (oblici k = w / base_w).
static func draw(canvas: CanvasItem, sc: Dictionary, rect: Rect2) -> void:
	if sc.is_empty() or rect.size.x < 2.0 or rect.size.y < 2.0:
		return
	var w := rect.size.x
	var h := rect.size.y
	var k := w / float(sc["base_w"])
	var pct := Vector2(w / 100.0, h / 100.0)
	var pct_xf := Transform2D(0.0, pct, 0.0, rect.position)
	var ci := canvas.get_canvas_item()
	for chunk in sc["chunks"]:
		if bool(chunk["line"]):
			var off: Vector2 = chunk["off"]
			var lxf := Transform2D(0.0, pct, 0.0, rect.position + off * k)
			canvas.draw_polyline(lxf * (chunk["pts"] as PackedVector2Array), chunk["col"], float(chunk["w"]) * k, true)
			continue
		var pts := PackedVector2Array()
		var cross: Array = []
		for it in chunk["items"]:
			if bool(it["pct"]):
				pts.append_array(pct_xf * (it["pts"] as PackedVector2Array))
				continue
			var at: Vector2 = it["at"]
			var anchor := rect.position + at * pct + (it["off"] as Vector2) * k
			var s := float(it["size"]) * k
			pts.append_array(Transform2D(0.0, Vector2(s, s), 0.0, anchor) * (it["pts"] as PackedVector2Array))
			var b: Rect2 = it["bounds"]
			if not rect.encloses(Rect2(anchor + b.position * s, b.size * s)):
				cross.append(it)
		if cross.is_empty():
			RenderingServer.canvas_item_add_triangle_array(ci, chunk["idx"], pts, chunk["cols"])
		else:
			_add_clipped(ci, chunk, pts, cross, rect)


## Komad u kojem neki oblik viri preko recta: ostali trokuti idu kakvi jesu, a trokut
## oblika koji izlazi zamijeni se presjekom s rectom (konveksan → lepeza).
static func _add_clipped(ci: RID, chunk: Dictionary, pts: PackedVector2Array, cross: Array, rect: Rect2) -> void:
	var src_idx: PackedInt32Array = chunk["idx"]
	var src_cols: PackedColorArray = chunk["cols"]
	var out_pts := pts.duplicate()
	var cols := src_cols.duplicate()
	var idx := PackedInt32Array()
	var box := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	var inside := rect.grow(0.01)
	var at := 0
	for it in cross:
		var i0: int = it["i0"]
		var i1: int = it["i1"]
		if i0 > at:
			idx.append_array(src_idx.slice(at, i0))
		at = i1
		for t in range(i0, i1, 3):
			var a := src_idx[t]
			var pa := pts[a]
			var pb := pts[src_idx[t + 1]]
			var pc := pts[src_idx[t + 2]]
			if inside.has_point(pa) and inside.has_point(pb) and inside.has_point(pc):
				idx.append_array(src_idx.slice(t, t + 3))
				continue
			for poly in Geometry2D.intersect_polygons(PackedVector2Array([pa, pb, pc]), box):
				if poly.size() < 3:
					continue
				var base := out_pts.size()
				out_pts.append_array(poly)
				for _v in poly.size():
					cols.append(src_cols[a])
				for v in range(1, poly.size() - 1):
					idx.append_array([base, base + v, base + v + 1])
	if at < src_idx.size():
		idx.append_array(src_idx.slice(at))
	if not idx.is_empty():
		RenderingServer.canvas_item_add_triangle_array(ci, idx, out_pts, cols)


## Uglovi kartice: površina između kvadrata ugla i luka radiusa r, u boji stranice —
## livada se ne vidi izvan zaobljenog ruba (kartica nema clip_children u GL Compat).
static func draw_corner_masks(canvas: CanvasItem, rect: Rect2, radius: float, color: Color) -> void:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	# Kraj prelaza (radius → 0): maska < 2 px se ne vidi, a skoro degenerisan
	# poligon ne prolazi triangulaciju.
	if r < 2.0:
		return
	var corners := [
		[rect.position, rect.position + Vector2(r, r), 180.0],
		[Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x - r, rect.position.y + r), 270.0],
		[rect.end, rect.end - Vector2(r, r), 0.0],
		[Vector2(rect.position.x, rect.end.y), Vector2(rect.position.x + r, rect.end.y - r), 90.0],
	]
	for cn in corners:
		var pts := PackedVector2Array([cn[0]])
		for i in CORNER_STEPS + 1:
			var a := deg_to_rad(float(cn[2]) + 90.0 * float(i) / CORNER_STEPS)
			pts.append((cn[1] as Vector2) + Vector2(cos(a), sin(a)) * r)
		canvas.draw_colored_polygon(pts, color)


## Zaobljeni pravougaonik kao poligon (sjena kartice izvan tijela).
static func round_rect_points(rect: Rect2, radius: float) -> PackedVector2Array:
	return _rect_points(rect.position.x, rect.position.y, rect.size.x, rect.size.y, radius, CORNER_STEPS)


# --- gradnja mreže ---

static func _build(recipe: Dictionary, base_w: float, avoid: Array) -> Dictionary:
	var chunks: Array = []
	var chunk := _new_chunk()
	for L in recipe.get("layers", []):
		var kind := str(L["k"])
		match kind:
			"band":
				var y0 := clampf(float(L["y0"]), 0.0, 100.0)
				var y1 := minf(100.0, float(L["y1"]) + BAND_OVERLAP)
				if y1 <= y0:
					continue
				var pts := PackedVector2Array([Vector2(0, y0), Vector2(100, y0), Vector2(100, y1), Vector2(0, y1)])
				_add_pct(chunk, pts, PackedInt32Array([0, 1, 2, 0, 2, 3]), UiSeasons.col(str(L["c"])))
			"ridge":
				var top := UiSeasons.ridge_points(L["r"])
				_add_ground(chunk, top, UiSeasons.col(str(L["c"])))
				if L.has("rim"):
					var rim: Array = L["rim"]
					chunks.append(chunk)
					chunks.append_array(_lines(top, Vector2.ZERO, float(rim[1]), UiSeasons.col(str(rim[0]))))
					chunk = _new_chunk()
			"mow":
				var ys: Array = L["ys"]
				var cols: Array = L["c"]
				var flat := float(L.get("flat", 0.0))
				var r: Dictionary = L["r"]
				for i in ys.size():
					var t := float(i) / float(maxi(1, ys.size() - 1))
					var waves: Array = []
					for wv in r.get("w", []):
						waves.append([float(wv[0]) * (1.0 - t * (1.0 - flat)), wv[1], wv[2]])
					var col_s := str(L["last"]) if i == ys.size() - 1 else str(cols[i % cols.size()])
					_add_ground(chunk, UiSeasons.ridge_points({"y": ys[i], "w": waves}), UiSeasons.col(col_s))
			"fence":
				var r: Dictionary = L["r"]
				var x0 := float(L["x0"])
				var x1 := float(L["x1"])
				var size := float(L["size"])
				var rail_col := UiSeasons.col(str(L["rail"]))
				chunks.append(chunk)
				for rl in L.get("rails", []):
					var top := PackedVector2Array()
					for q in UiSeasons.ridge_points(r):
						if q.x >= x0 - 0.5 and q.x <= x1 + 0.5:
							top.append(q)
					chunks.append_array(_lines(top, Vector2(0.0, 2.0 - float(rl[0]) * size), float(rl[1]), rail_col))
				chunk = _new_chunk()
				var x := x0
				while x <= x1 + 0.01:
					_add_shape(chunk, "post", L["pal"], Vector2(x, UiSeasons.ridge_y(r, x)), Vector2(0, 2), size, 0.0)
					x += float(L["step"])
			"shape":
				var at: Array = L["at"]
				_add_shape(chunk, str(L["shape"]), L["pal"], Vector2(float(at[0]), float(at[1])), Vector2.ZERO, float(L["size"]), 0.0)
			"scatter":
				for i in int(L["n"]):
					var it := UiSeasons.scatter_at(L, i)
					if not avoid.is_empty() and UiSeasons.in_avoid(it["pos"], avoid):
						continue
					_add_shape(chunk, str(L["shape"]), L["pal"], it["pos"], Vector2.ZERO, float(it["size"]), float(it["rot"]))
	chunks.append(chunk)
	return {"base_w": base_w, "chunks": chunks}


static func _new_chunk() -> Dictionary:
	return {"line": false, "items": [], "idx": PackedInt32Array(), "cols": PackedColorArray(), "verts": 0}


## Linija u % odrezana na [0, 100] (greben ide od −2 do 102 %) — dio po dio.
static func _lines(pts: PackedVector2Array, off: Vector2, w: float, c: Color) -> Array:
	var out: Array = []
	for part in Geometry2D.intersect_polyline_with_polygon(pts, PackedVector2Array(PCT_BOX)):
		if part.size() >= 2:
			out.append({"line": true, "pts": part, "off": off, "w": w, "col": c})
	return out


## Tlo ispod grebena: vrh u %, dno na dnu recta; greben (−2 … 102 %) odrezan na [0, 100].
static func _add_ground(chunk: Dictionary, top: PackedVector2Array, c: Color) -> void:
	var poly := top.duplicate()
	poly.append(Vector2(102.0, 101.0))
	poly.append(Vector2(-2.0, 101.0))
	for pts in Geometry2D.intersect_polygons(poly, PackedVector2Array(PCT_BOX)):
		if pts.size() < 3:
			continue
		var idx := Geometry2D.triangulate_polygon(pts)
		if idx.is_empty():
			for v in range(1, pts.size() - 1):
				idx.append_array([0, v, v + 1])
		_add_pct(chunk, pts, idx, c)


static func _add_pct(chunk: Dictionary, pts: PackedVector2Array, idx: PackedInt32Array, c: Color) -> void:
	_append(chunk, {"pct": true, "pts": pts}, pts.size(), idx, _filled(pts.size(), c))


## Oblik u jedinicnom prostoru (rotacija pečena), sidro u % + pomak u px baze.
static func _add_shape(chunk: Dictionary, shape_id: String, pal: Array, at: Vector2, off: Vector2, size: float, rot_deg: float) -> void:
	var parts := shape_mesh(shape_id)
	if parts.is_empty() or pal.is_empty():
		return
	var rot := Transform2D(deg_to_rad(rot_deg), Vector2.ZERO)
	var pts := PackedVector2Array()
	var idx := PackedInt32Array()
	var cols := PackedColorArray()
	for part in parts:
		var base := pts.size()
		var p: PackedVector2Array = part["pts"]
		pts.append_array(rot * p)
		for v in part["idx"]:
			idx.append(base + v)
		cols.append_array(_filled(p.size(), UiSeasons.col(str(pal[mini(int(part["ci"]), pal.size() - 1)]))))
	var lo := pts[0]
	var hi := pts[0]
	for q in pts:
		lo = lo.min(q)
		hi = hi.max(q)
	var item := {"pct": false, "at": at, "off": off, "size": size, "pts": pts, "bounds": Rect2(lo, hi - lo)}
	_append(chunk, item, pts.size(), idx, cols)


## item i0 … i1 = njegovi trokuti u idx komada (rez oblika koji viri preko recta).
static func _append(chunk: Dictionary, item: Dictionary, n: int, idx: PackedInt32Array, cols: PackedColorArray) -> void:
	var base: int = chunk["verts"]
	var all_idx: PackedInt32Array = chunk["idx"]
	item["i0"] = all_idx.size()
	for v in idx:
		all_idx.append(base + v)
	item["i1"] = all_idx.size()
	chunk["idx"] = all_idx
	var all_cols: PackedColorArray = chunk["cols"]
	all_cols.append_array(cols)
	chunk["cols"] = all_cols
	chunk["verts"] = base + n
	(chunk["items"] as Array).append(item)


## Oblik triangulisan jednom (jedinicni prostor): [{ci, pts, idx}]. Primitivi:
## c krug · e elipsa · p poligon · l linija · a luk · r pravougaonik (zaobljen).
static func shape_mesh(shape_id: String) -> Array:
	if _shape_cache.has(shape_id):
		return _shape_cache[shape_id]
	var out: Array = []
	var prims: Array = UiSeasons.shapes().get(shape_id, UiArenaV2.SHAPES.get(shape_id, []))
	for p in prims:
		var ci := int(p[p.size() - 1])
		var pts := PackedVector2Array()
		var idx := PackedInt32Array()
		match str(p[0]):
			"c":
				pts = _ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[3]))
			"e":
				pts = _ellipse(Vector2(p[1], p[2]), float(p[3]), float(p[4]))
			"p":
				for q in p[1]:
					pts.append(Vector2(q[0], q[1]))
			"r":
				pts = _rect_points(float(p[1]), float(p[2]), float(p[3]), float(p[4]), float(p[5]), RECT_CORNER_STEPS)
			"l":
				_append_stroke(pts, idx, [Vector2(p[1], p[2]), Vector2(p[3], p[4])], float(p[5]))
			"a":
				var arc: Array = []
				for k in ARC_STEPS + 1:
					var a := deg_to_rad(lerpf(float(p[4]), float(p[5]), float(k) / ARC_STEPS))
					arc.append(Vector2(p[1], p[2]) + Vector2(cos(a), sin(a)) * float(p[3]))
				_append_stroke(pts, idx, arc, float(p[6]))
		if idx.is_empty() and pts.size() >= 3:
			idx = Geometry2D.triangulate_polygon(pts)
			if idx.is_empty():
				for k in range(1, pts.size() - 1):
					idx.append_array([0, k, k + 1])
		if not idx.is_empty():
			out.append({"ci": ci, "pts": pts, "idx": idx})
	_shape_cache[shape_id] = out
	return out


## Mreža jednog oblika u px (za run i ambijent): {pts, idx, cols} sa sidrom, veličinom i rotacijom.
static func shape_at(shape_id: String, pal: Array, pos: Vector2, size: float, rot_deg: float = 0.0) -> Dictionary:
	var xf := Transform2D(deg_to_rad(rot_deg), Vector2(size, size), 0.0, pos)
	var pts := PackedVector2Array()
	var idx := PackedInt32Array()
	var cols := PackedColorArray()
	for part in shape_mesh(shape_id):
		var base := pts.size()
		var p: PackedVector2Array = part["pts"]
		pts.append_array(xf * p)
		for v in part["idx"]:
			idx.append(base + v)
		cols.append_array(_filled(p.size(), UiSeasons.col(str(pal[mini(int(part["ci"]), pal.size() - 1)]))))
	return {"pts": pts, "idx": idx, "cols": cols}


## Spaja mreže u jednu (jedan draw poziv): [{pts, idx, cols}] → {pts, idx, cols}.
static func merge_meshes(meshes: Array) -> Dictionary:
	var pts := PackedVector2Array()
	var idx := PackedInt32Array()
	var cols := PackedColorArray()
	for m in meshes:
		var base := pts.size()
		pts.append_array(m["pts"])
		for v in m["idx"]:
			idx.append(base + v)
		cols.append_array(m["cols"])
	return {"pts": pts, "idx": idx, "cols": cols}


## Linija sirine w kao niz cetvorouglova (isto kao u ArenaMeadowBg).
static func _append_stroke(pts: PackedVector2Array, idx: PackedInt32Array, line: Array, w: float) -> void:
	for k in line.size() - 1:
		var a: Vector2 = line[k]
		var b: Vector2 = line[k + 1]
		var d := b - a
		if d.length_squared() < 1e-8:
			continue
		var n := Vector2(-d.y, d.x).normalized() * w * 0.5
		var base := pts.size()
		pts.append_array([a + n, b + n, b - n, a - n])
		idx.append_array([base, base + 1, base + 2, base, base + 2, base + 3])


static func _filled(n: int, c: Color) -> PackedColorArray:
	var out := PackedColorArray()
	out.resize(n)
	out.fill(c)
	return out


static func _ellipse(c: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for k in ELLIPSE_STEPS:
		var a := TAU * float(k) / ELLIPSE_STEPS
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	return pts


static func _rect_points(x: float, y: float, w: float, h: float, rad: float, steps: int) -> PackedVector2Array:
	var r := minf(rad, minf(w, h) * 0.5)
	if r <= 0.0:
		return PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])
	var pts := PackedVector2Array()
	var corners := [
		[Vector2(x + w - r, y + r), -90.0], [Vector2(x + w - r, y + h - r), 0.0],
		[Vector2(x + r, y + h - r), 90.0], [Vector2(x + r, y + r), 180.0],
	]
	for cn in corners:
		for k in steps + 1:
			var a := deg_to_rad(float(cn[1]) + k * 90.0 / steps)
			pts.append((cn[0] as Vector2) + Vector2(cos(a), sin(a)) * r)
	return pts
