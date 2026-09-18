class_name ArenaMeadowBg
extends Control

## Livada iza Arene (smjer B): ravna brda, busenje i cvjetici — bujnija sa svakim T3 u rundi
## (0 → 4, crossfade 0,6 s). Ako postoje meadow_base.png / meadow_lush.png
## (design_handoff_merge_arena § Pozadina), crta njih; inace isti motiv proceduralno.

const BASE_TEX_PATH := "res://assets/sprites/arena/meadow_base.png"
const LUSH_TEX_PATH := "res://assets/sprites/arena/meadow_lush.png"
const MAX_LEVEL := 4.0
const CROSSFADE_SEC := 0.6
const LAYOUT_SEED := 9021
const REF_H := 1597.0
const TUFTS_BASE := 10
const TUFTS_PER_T3 := 6
const BLOOMS_PER_T3 := 5
const TUFT_ALPHA := 0.85
const BLOOM_ALPHA := 0.9
const HILL_FAR_BASE := Color("#22342A")
const HILL_FAR_LUSH := Color("#2E5233")
const HILL_NEAR_BASE := Color("#2F4636")
const HILL_NEAR_LUSH := Color("#3C6B40")
const TUFT_BASE := Color("#334C3A")
const TUFT_LUSH := Color("#4A8250")
const BLOOM_COLORS: Array[Color] = [
	Color("#FFEAA7"), Color("#FFCCD5"), Color("#B8E0F5"), Color("#D4A5FF")
]

## Ciljna boja livade (bez animacije) — ono sto je ranije bio ColorRect.color.
var color: Color:
	get:
		return UiArena.MEADOW_BASE.lerp(UiArena.MEADOW_LUSH, _target_level / MAX_LEVEL)

var _level: float = 0.0
var _target_level: float = 0.0
var _tween: Tween = null
var _tufts: Array[Vector3] = []  # x frac, y frac, visina
var _blooms: Array[Vector3] = []  # x frac, y frac, velicina
var _base_tex: Texture2D = null
var _lush_tex: Texture2D = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base_tex = _load_optional(BASE_TEX_PATH)
	_lush_tex = _load_optional(LUSH_TEX_PATH)
	var rng := RandomNumberGenerator.new()
	rng.seed = LAYOUT_SEED
	for _i in TUFTS_BASE + TUFTS_PER_T3 * int(MAX_LEVEL):
		_tufts.append(Vector3(rng.randf(), rng.randf(), 30.0 + rng.randf() * 34.0))
	for _i in BLOOMS_PER_T3 * int(MAX_LEVEL):
		_blooms.append(Vector3(rng.randf(), rng.randf(), 14.0 + rng.randf() * 12.0))
	resized.connect(queue_redraw)


func set_t3_level(level: float, animated: bool) -> void:
	_target_level = clampf(level, 0.0, MAX_LEVEL)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not animated or not is_inside_tree():
		_set_level(_target_level)
		return
	_tween = create_tween()
	_tween.tween_method(_set_level, _level, _target_level, CROSSFADE_SEC)


func get_level() -> float:
	return _level


func _draw() -> void:
	var t := _level / MAX_LEVEL
	draw_rect(Rect2(Vector2.ZERO, size), UiArena.MEADOW_BASE.lerp(UiArena.MEADOW_LUSH, t))
	if _base_tex != null:
		_draw_cover(_base_tex, Color.WHITE)
		if _lush_tex != null:
			_draw_cover(_lush_tex, Color(1.0, 1.0, 1.0, t))
		return
	_draw_hills(t)
	_draw_tufts(t)
	_draw_blooms()


func _draw_hills(t: float) -> void:
	var w := size.x
	var h := size.y
	var far := Rect2(-80.0, h - 190.0 - 420.0, w + 160.0, 420.0)
	draw_colored_polygon(
		_top_round_points(far, far.size.x * 0.5, far.size.y * 0.5), HILL_FAR_BASE.lerp(HILL_FAR_LUSH, t)
	)
	var near := Rect2(-120.0, h + 60.0 - 430.0, w + 240.0, 430.0)
	draw_colored_polygon(
		_top_round_points(near, near.size.x * 0.46, near.size.y * 0.46), HILL_NEAR_BASE.lerp(HILL_NEAR_LUSH, t)
	)


func _draw_tufts(t: float) -> void:
	var count := float(TUFTS_BASE) + float(TUFTS_PER_T3) * _level
	var col := TUFT_BASE.lerp(TUFT_LUSH, t)
	for i in _tufts.size():
		var alpha := clampf(count - float(i), 0.0, 1.0)
		if alpha <= 0.0:
			break
		var d := _tufts[i]
		var x := 20.0 + d.x * (size.x - 40.0)
		var y := (300.0 + d.y * 1250.0) / REF_H * size.y
		var tw := d.z * 0.5
		draw_colored_polygon(
			PackedVector2Array([Vector2(x + tw * 0.5, y), Vector2(x + tw, y + d.z), Vector2(x, y + d.z)]),
			Color(col, TUFT_ALPHA * alpha)
		)


func _draw_blooms() -> void:
	var count := float(BLOOMS_PER_T3) * _level
	for i in _blooms.size():
		var alpha := clampf(count - float(i), 0.0, 1.0)
		if alpha <= 0.0:
			break
		var d := _blooms[i]
		var x := 30.0 + d.x * (size.x - 60.0)
		var y := (340.0 + d.y * 1200.0) / REF_H * size.y
		var col := BLOOM_COLORS[i % BLOOM_COLORS.size()]
		draw_circle(Vector2(x, y) + Vector2(d.z, d.z) * 0.5, d.z * 0.5, Color(col, BLOOM_ALPHA * alpha))


## Tekstura pokriva sirinu, sjedi na dnu; iznad nje ostaje boja livade.
func _draw_cover(tex: Texture2D, tint: Color) -> void:
	var tex_size := tex.get_size()
	if tex_size.x < 1.0:
		return
	var s := size.x / tex_size.x
	var h := tex_size.y * s
	draw_texture_rect(tex, Rect2(0.0, size.y - h, size.x, h), false, tint)


## Pravougaonik s eliptickim gornjim uglovima i ravnim dnom (CSS border-radius x% x% 0 0).
static func _top_round_points(r: Rect2, rx: float, ry: float, steps: int = 24) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var left_c := r.position + Vector2(rx, ry)
	var right_c := r.position + Vector2(r.size.x - rx, ry)
	for i in steps + 1:
		var a := PI + PI * 0.5 * float(i) / float(steps)
		pts.append(left_c + Vector2(cos(a) * rx, sin(a) * ry))
	for i in steps + 1:
		var a := PI * 1.5 + PI * 0.5 * float(i) / float(steps)
		pts.append(right_c + Vector2(cos(a) * rx, sin(a) * ry))
	pts.append(r.end)
	pts.append(Vector2(r.position.x, r.end.y))
	return pts


func _set_level(value: float) -> void:
	_level = value
	queue_redraw()


static func _load_optional(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
