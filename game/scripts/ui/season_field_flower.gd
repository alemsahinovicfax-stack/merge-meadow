class_name SeasonFieldFlower
extends Control

## Decorative meadow bloom. IGNORE; not an arena chip.
## Season Kit (design_handoff_seasons, faza 2 § Odlučeno 4): Pip njuši → cvijet 1 → 1,08 → 1
## i −4° (0,3 s) + 3 čestice OBLIKA ambijenta sezone; novo izraslo mjesto → rast 0 → 1,12 → 1
## (0,42 s); njihanje ±3° postavlja SeasonField (jedna petlja za sve cvjetove).
## Skala čvora = layout (rect kartice u prelazu) × rast × naklon; pivot = sredina dna.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const PUFF_LIGHT := [Color("#FFEAA7"), Color("#B98A2E")]
const PUFF_DARK := [Color("#EDEBFF"), Color("#4A5290")]
const PUFF_BORDER := 3.0

var type_id: String = ""
var plant_tier: int = 3
## Sjena ispod cvijeta (tamni kit: rgba(0,0,10,.32)).
var shadow_color: Color = UiHomeField.FLOWER_SHADOW
var dark_kit: bool = false
## Season Kit: vidljivi crtež (odrez) puni mjesto po dužoj strani, dno na dnu kutije
## (crop(type, 3, size, bottom) u SeasonScreen.dc.html). false = draw_fitted_plant.
var crop_fill: bool = false
## Prvi sloj ambijenta sezone (UiSeasons.ambient_layers) — oblik i boje čestica njuškanja.
var puff_layer: Dictionary = {}
var _side: float = 76.0
var _layout_scale: float = 1.0
var _grow: float = 1.0
var _bow_rot: float = 0.0
var _bow_s: float = 1.0
var _sway: float = 0.0
var _fx_tween: Tween = null
var _puff_t: float = -1.0
var _puff_mesh: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	pivot_offset = Vector2(size.x * 0.5, size.y)


func setup_spot(seed_type: String, side: float, tier: int = 3) -> void:
	type_id = seed_type
	plant_tier = 3
	_side = maxf(side, 8.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	custom_minimum_size = Vector2(_side, _side)
	size = custom_minimum_size
	pivot_offset = Vector2(size.x * 0.5, size.y)
	add_to_group("meadow_flower")
	queue_redraw()


func setup(seed_type: String, tier: int) -> void:
	setup_spot(seed_type, _side if _side > 8.0 else 76.0, tier)


## Skala iz rasporeda (rect kartice × ulaz cvijeća); rast i naklon se množe preko nje.
func set_layout_scale(s: float) -> void:
	_layout_scale = s
	_apply_xform()


func is_fx_playing() -> bool:
	return _fx_tween != null and _fx_tween.is_running()


## Njihanje u stepenima (SeasonField · jedna petlja); 0 = miruje.
func set_sway(deg: float) -> void:
	if is_equal_approx(_sway, deg):
		return
	_sway = deg
	_apply_xform()


func get_sway() -> float:
	return _sway


## Novo izraslo mjesto: 0 → 1,12 → 1 za 0,42 s (TRANS_BACK, EASE_OUT).
func play_grow(delay: float = 0.0) -> void:
	_kill_fx()
	_grow = 0.0
	_apply_xform()
	_fx_tween = create_tween()
	_fx_tween.tween_method(_set_grow, 0.0, 1.0, float(UiSeasons.GROW["sec"])) \
		.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Pip njuši: naklon (BOW, ease-out) + 3 čestice oblika ambijenta iz glave cvijeta.
func play_sniff() -> void:
	_kill_fx()
	_grow = 1.0
	var puff: Dictionary = UiSeasons.SNIFF_PUFF
	var puff_total := float(puff["sec"]) + float(puff["stagger"]) * (int(puff["n"]) - 1)
	_fx_tween = create_tween().set_parallel()
	_fx_tween.tween_method(_set_bow, 0.0, 1.0, float(UiSeasons.BOW["sec"])).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_fx_tween.tween_method(_set_puff, 0.0, puff_total, puff_total)
	_fx_tween.chain().tween_callback(_end_fx)


func _kill_fx() -> void:
	if _fx_tween != null and _fx_tween.is_valid():
		_fx_tween.kill()
	_fx_tween = null
	_end_fx()


func _end_fx() -> void:
	_bow_rot = 0.0
	_bow_s = 1.0
	_puff_t = -1.0
	_apply_xform()
	queue_redraw()


func _set_grow(k: float) -> void:
	_grow = k
	_apply_xform()


## flowerBow: 0 % → 50 % (1,08, −4°) → 100 %, linearno između ključeva.
func _set_bow(t: float) -> void:
	var k := t / 0.5 if t < 0.5 else (1.0 - t) / 0.5
	_bow_rot = float(UiSeasons.BOW["rot"]) * k
	_bow_s = lerpf(1.0, float(UiSeasons.BOW["scale"]), k)
	_apply_xform()


func _set_puff(t: float) -> void:
	_puff_t = t
	queue_redraw()


func _apply_xform() -> void:
	var s := _layout_scale * _grow * _bow_s
	scale = Vector2(s, s)
	rotation = deg_to_rad(_bow_rot + _sway)


func _draw() -> void:
	if type_id.is_empty() or plant_tier <= 0:
		return
	# Senka = pilula 56 % x 17 %, 2 px od dna (FieldScreen.dc.html · shade).
	var sh := Vector2(roundf(size.x * 0.56), roundf(size.y * 0.17))
	var shadow := Rect2(Vector2((size.x - sh.x) * 0.5, size.y - 2.0 - sh.y), sh)
	draw_style_box(UiStage.box(shadow_color, roundi(sh.y * 0.5)), shadow)
	var tex := FlowerAssets.get_texture(type_id, plant_tier) if crop_fill else null
	if tex != null:
		var src := PLANT_DRAW._crop_rect(tex)
		var k := size.y / maxf(1.0, maxf(src.size.x, src.size.y))
		var dest := src.size * k
		draw_texture_rect_region(tex, Rect2(Vector2((size.x - dest.x) * 0.5, size.y - dest.y), dest), src)
	else:
		PLANT_DRAW.draw_fitted_plant(self, size * 0.5, type_id, plant_tier, _side)
	if _puff_t >= 0.0:
		_draw_puffs()


## SniffPuff (faza 2): 3 oblika prvog sloja ambijenta (14 px, boje [pal[0]] + pal2) iz glave
## cvijeta (dno − 0,7 visine), start dx / 2, let (dx, −80), skala 0,6 → 1, alpha 0 → 1 (20 %)
## → 0, ease out, razmak 0,05 s. Bez sloja ambijenta: krugovi polena (rub 3).
func _draw_puffs() -> void:
	var puff: Dictionary = UiSeasons.SNIFF_PUFF
	var dxs: Array = puff["dx"]
	var sec := float(puff["sec"])
	var d := float(puff["d"])
	var origin := Vector2(size.x * 0.5, size.y * 0.3)
	var mesh := _puff_shape_mesh()
	var cols: Array = PUFF_DARK if dark_kit else PUFF_LIGHT
	for i in dxs.size():
		var t := clampf((_puff_t - float(puff["stagger"]) * i) / sec, 0.0, 1.0)
		if t >= 1.0 or t <= 0.0:
			continue
		var e := 1.0 - pow(1.0 - t, 3.0)
		var dx := float(dxs[i])
		var at := origin + Vector2(dx * 0.5 + dx * e, -float(puff["rise"]) * e)
		var a := t / 0.2 if t < 0.2 else (1.0 - t) / 0.8
		var s := lerpf(0.6, 1.0, e)
		if mesh.is_empty():
			var r := d * 0.5 * s
			draw_circle(at, r, Color(cols[0], a))
			draw_arc(at, r - PUFF_BORDER * 0.5, 0.0, TAU, 16, Color(cols[1], a), PUFF_BORDER, true)
			continue
		var faded := PackedColorArray()
		for c in mesh["cols"]:
			faded.append(Color(c, (c as Color).a * a))
		var pts: PackedVector2Array = Transform2D(0.0, Vector2(s, s), 0.0, at) * (mesh["pts"] as PackedVector2Array)
		RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), mesh["idx"], pts, faded)


## Mreža oblika čestice (14 px, oko 0, 0) — jednom po cvijetu.
func _puff_shape_mesh() -> Dictionary:
	if puff_layer.is_empty():
		return {}
	if _puff_mesh.is_empty():
		var pal: Array = [str((puff_layer["pal"] as Array)[0])]
		pal.append_array(puff_layer.get("pal2", []))
		_puff_mesh = SeasonBackdrop.shape_at(str(puff_layer["shape"]), pal, Vector2.ZERO, float(UiSeasons.SNIFF_PUFF["d"]))
	return _puff_mesh
