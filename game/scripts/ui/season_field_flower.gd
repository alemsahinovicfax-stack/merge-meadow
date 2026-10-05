class_name SeasonFieldFlower
extends Control

## Decorative meadow bloom. IGNORE; not an arena chip.
## Season Kit (design_handoff_seasons § Odlučeno 7): Pip njuši → cvijet se nakloni oko
## baze (0,6 s) i pusti 5 čestica polena; novo izraslo mjesto → rast 0 → 1,12 → 1 (0,42 s).
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
var _side: float = 76.0
var _layout_scale: float = 1.0
var _grow: float = 1.0
var _bow_rot: float = 0.0
var _bow_sy: float = 1.0
var _fx_tween: Tween = null
var _puff_t: float = -1.0


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


## Novo izraslo mjesto: 0 → 1,12 → 1 za 0,42 s (TRANS_BACK, EASE_OUT).
func play_grow(delay: float = 0.0) -> void:
	_kill_fx()
	_grow = 0.0
	_apply_xform()
	_fx_tween = create_tween()
	_fx_tween.tween_method(_set_grow, 0.0, 1.0, float(UiSeasons.GROW["sec"])) \
		.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Pip njuši: naklon po ključevima SNIFF_BOW + 5 čestica polena iz glave cvijeta.
func play_sniff() -> void:
	_kill_fx()
	_grow = 1.0
	var bow: Dictionary = UiSeasons.SNIFF_BOW
	var puff: Dictionary = UiSeasons.SNIFF_PUFF
	var sec := float(bow["sec"])
	var puff_total := float(puff["sec"]) + float(puff["stagger"]) * (int(puff["n"]) - 1)
	_fx_tween = create_tween().set_parallel()
	_fx_tween.tween_method(_set_bow, 0.0, 1.0, sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_fx_tween.tween_method(_set_puff, 0.0, puff_total, puff_total)
	_fx_tween.chain().tween_callback(_end_fx)


func _kill_fx() -> void:
	if _fx_tween != null and _fx_tween.is_valid():
		_fx_tween.kill()
	_fx_tween = null
	_end_fx()


func _end_fx() -> void:
	_bow_rot = 0.0
	_bow_sy = 1.0
	_puff_t = -1.0
	_apply_xform()
	queue_redraw()


func _set_grow(k: float) -> void:
	_grow = k
	_apply_xform()


## Ključevi [t, rotacija°, skala y] — linearno između ključeva.
func _set_bow(t: float) -> void:
	var keys: Array = UiSeasons.SNIFF_BOW["keys"]
	for i in keys.size() - 1:
		var a: Array = keys[i]
		var b: Array = keys[i + 1]
		if t <= float(b[0]) or i == keys.size() - 2:
			var f := clampf((t - float(a[0])) / maxf(0.0001, float(b[0]) - float(a[0])), 0.0, 1.0)
			_bow_rot = lerpf(float(a[1]), float(b[1]), f)
			_bow_sy = lerpf(float(a[2]), float(b[2]), f)
			break
	_apply_xform()


func _set_puff(t: float) -> void:
	_puff_t = t
	queue_redraw()


func _apply_xform() -> void:
	var s := _layout_scale * _grow
	scale = Vector2(s, s * _bow_sy)
	rotation = deg_to_rad(_bow_rot)


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


## SniffPuff: 5 krugova 14 px (rub 3) iz glave cvijeta (dno − 0,7 visine), let (dx, −80),
## skala 1 → 0,5, alpha 1 → 0, ease out, razmak 0,05 s.
func _draw_puffs() -> void:
	var puff: Dictionary = UiSeasons.SNIFF_PUFF
	var dxs: Array = puff["dx"]
	var sec := float(puff["sec"])
	var d := float(puff["d"])
	var cols: Array = PUFF_DARK if dark_kit else PUFF_LIGHT
	var origin := Vector2(size.x * 0.5, size.y * 0.3)
	for i in dxs.size():
		var t := clampf((_puff_t - float(puff["stagger"]) * i) / sec, 0.0, 1.0)
		if t >= 1.0:
			continue
		var e := 1.0 - pow(1.0 - t, 3.0)
		var dx := float(dxs[i])
		var at := origin + Vector2(dx * 0.4 + dx * e, -float(puff["rise"]) * e)
		var r := d * 0.5 * lerpf(1.0, 0.5, e)
		var a := 1.0 - e
		draw_circle(at, r, Color(cols[0], a))
		draw_arc(at, r - PUFF_BORDER * 0.5, 0.0, TAU, 16, Color(cols[1], a), PUFF_BORDER, true)
