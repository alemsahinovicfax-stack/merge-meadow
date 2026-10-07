class_name SeasonAmbient
extends Control

## Ambijent polja sezone (design_handoff_seasons § Novi primitivi · Generički ambijent):
## isti format za svih 8 sezona i za run — slojevi {motion: drift | fall | rise | float |
## twinkle | streak, n, shape, size, pal, pal2, zone, …}. Čestica = oblik iz kita (isti
## primitivi kao livada), mreža se pravi JEDNOM; po frejmu samo UiSeasons.ambient_at()
## (pomak, rotacija, skala, alpha). Deterministički R2 niz (bez RNG-a), ≤ 24 čestice,
## JEDNA petlja i jedan draw poziv. Crta se u rectu ovog čvora (polje = stranica).
## Ne radi dok je skriven.

var _parts: Array = []
var _time: float = 0.0
var _fade: float = 1.0
var _calm: float = 1.0
var _fade_tween: Tween = null
var _calm_tween: Tween = null
var _still: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_sync_process)
	_sync_process()


## Sezona bez kita → prazno (ništa se ne crta ni ne vrti).
func set_season(season_id: String) -> void:
	_parts = build_parts(UiSeasons.ambient(season_id))
	_sync_process()
	queue_redraw()


func particle_count() -> int:
	return _parts.size()


func is_looping() -> bool:
	return is_processing()


## Mirno stanje (Reduce motion): čestice stoje, alpha srednja, bez petlje.
func set_still(still: bool) -> void:
	if _still == still:
		return
	_still = still
	_sync_process()
	queue_redraw()


func is_still() -> bool:
	return _still


## Ulaz poslije prelaza: alpha 0 → 1 za 0,3 s (Home v3 · ambijent tek na u = 1).
func fade_in() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade = 0.0
	if not is_inside_tree():
		_fade = 1.0
		return
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "_fade", 1.0, UiSeasons.AMBIENT_FADE_IN)


## Pip spava → ambijent se smiri (alpha 0,35 za 1,2 s); budan → nazad na 1.
func set_calm(calm: bool) -> void:
	var target := UiSeasons.SLEEP_AMBIENT_ALPHA if calm else 1.0
	if _calm_tween != null and _calm_tween.is_valid():
		_calm_tween.kill()
	if not is_inside_tree():
		_calm = target
		return
	_calm_tween = create_tween()
	_calm_tween.tween_property(self, "_calm", target, UiSeasons.SLEEP_AMBIENT_SEC)


func calm_alpha() -> float:
	return _calm


## Čestice sa mrežom u px baze (oblik × veličina × stalni nagib), boje [col] + pal2.
## Svaka čestica dobija svoju varijantu sloja (2026-10-06, playtest: „ne kreću se dovoljno
## nasumično"): po kitu sve čestice sloja imaju istu brzinu, isti vektor, isto njihanje i
## istu rotaciju, pa svaka crta istu putanju pomaknutu u vremenu. Sada brzina, jačina i
## smjer (bočni dio) puta, njihanje i okretanje variraju po čestici, a i faza je svoja.
## Seed = sloj + indeks, pa je slika ista pri svakom pokretanju. ambient_at ostaje CD-ov.
static func build_parts(def: Dictionary) -> Array:
	var out: Array = []
	var li := 0
	for entry in UiSeasons.ambient_layers(def):
		var L: Dictionary = entry["layer"]
		var pal2: Array = L.get("pal2", [])
		for p in entry["parts"]:
			var pal: Array = [p["col"]]
			pal.append_array(pal2)
			var mesh := SeasonBackdrop.shape_at(str(L["shape"]), pal, Vector2.ZERO, float(p["size"]), float(p["angle"]))
			var rng := RandomNumberGenerator.new()
			rng.seed = hash("%s:%d:%d" % [str(L["shape"]), li, int(p["i"])])
			var lv := vary_layer(L, rng)
			out.append({
				"layer": lv, "pos": p["pos"], "delay": -rng.randf() * float(lv["sec"]), "sec": float(lv["sec"]),
				"pts": mesh["pts"], "idx": mesh["idx"], "cols": mesh["cols"],
			})
		li += 1
	return out


## Varijanta sloja za jednu česticu. Smjer vjetra (drift po x kod „drift") i pravac
## padanja / dizanja ostaju; meteor (streak) zadrži putanju, mijenja se samo tempo.
static func vary_layer(L: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var v := L.duplicate()
	var motion := str(L["motion"])
	v["sec"] = float(L["sec"]) * rng.randf_range(0.75, 1.3)
	if motion == "streak":
		return v
	var d: Array = L["drift"]
	var dx := float(d[0])
	var dy := float(d[1])
	match motion:
		"fall", "rise":
			# Bočni pomak: i lijevo i desno, uz osnovni nagib vjetra.
			dx = dx * rng.randf_range(0.3, 1.7) + rng.randf_range(-1.0, 1.0) * maxf(absf(dx), absf(dy) * 0.12)
			dy *= rng.randf_range(0.8, 1.2)
		"drift":
			dx *= rng.randf_range(0.6, 1.4)
			dy = dy * rng.randf_range(0.3, 1.7) + rng.randf_range(-1.0, 1.0) * absf(float(d[0])) * 0.35
		"float":
			dx *= rng.randf_range(0.6, 1.4) * (1.0 if rng.randf() < 0.5 else -1.0)
			dy *= rng.randf_range(0.6, 1.4)
	v["drift"] = [dx, dy]
	var sw: Array = L["sway"]
	var amp := float(sw[0]) * rng.randf_range(0.5, 1.5)
	var freq := maxf(0.5, float(sw[1]) * rng.randf_range(0.7, 1.4))
	if motion == "drift" and is_zero_approx(amp):
		# Latica / mrvica na vjetru bez njihanja ide pravo kao po lenjiru — blago lepršanje.
		amp = rng.randf_range(6.0, 20.0)
		freq = rng.randf_range(0.8, 2.0)
	v["sway"] = [amp, freq]
	v["rot"] = float(L["rot"]) * rng.randf_range(0.6, 1.4) * (1.0 if rng.randf() < 0.5 else -1.0)
	v["pulse"] = float(L["pulse"]) * rng.randf_range(0.7, 1.3)
	return v


## Jedan kadar svih čestica u jednu mrežu: rect = prostor zona (%), k = skala oblika
## (rect.size.x / bazna širina), alpha_mul = fade × calm. still = bez kretanja.
static func append_frame(
	parts: Array, time: float, rect: Rect2, k: float, alpha_mul: float, still: bool,
	pts: PackedVector2Array, cols: PackedColorArray, idx: PackedInt32Array
) -> void:
	for p in parts:
		var L: Dictionary = p["layer"]
		var st: Dictionary
		if still:
			var a: Array = L["alpha"]
			var still_a := 0.0 if str(L["motion"]) == "streak" else minf(1.0, (float(a[0]) + float(a[1])) * 0.5 + 0.25)
			st = {"offset": Vector2.ZERO, "rot": 0.0, "scale": 1.0, "alpha": still_a}
		else:
			var t := fposmod((time - float(p["delay"])) / float(p["sec"]), 1.0)
			st = UiSeasons.ambient_at(L, t)
		var alpha := float(st["alpha"]) * alpha_mul
		if alpha <= 0.002:
			continue
		var pos: Vector2 = p["pos"]
		var anchor := rect.position + Vector2(pos.x * rect.size.x, pos.y * rect.size.y) / 100.0 + (st["offset"] as Vector2) * k
		var s := float(st["scale"]) * k
		var xf := Transform2D(deg_to_rad(float(st["rot"])), Vector2(s, s), 0.0, anchor)
		var base := pts.size()
		pts.append_array(xf * (p["pts"] as PackedVector2Array))
		for v in p["idx"]:
			idx.append(base + v)
		for c in p["cols"]:
			var cc: Color = c
			cc.a *= alpha
			cols.append(cc)


func _sync_process() -> void:
	set_process(is_visible_in_tree() and not _parts.is_empty() and not _still)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _parts.is_empty() or size.x < 2.0:
		return
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	append_frame(_parts, _time, Rect2(Vector2.ZERO, size), size.x / UiSeasons.PAGE.x, _fade * _calm, _still, pts, cols, idx)
	if not idx.is_empty():
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), idx, pts, cols)
