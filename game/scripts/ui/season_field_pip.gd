extends Control

## HOME-14 LIFE-D — decorative Pip on SeasonField. IGNORE; FSM lives on SeasonField.
## Home v3: isti crtez (pip_idle.svg) i senka kao putujuci Pip s kartice, pa je
## predaja na kraju prelaza bez skoka.
## Ormar · ApplyMoment: play_apply() — Pip skoči u novom skinu (1,18 / 280 ms, pivot
## stopala, kao combo hop u Areni) + jedan krem prsten oko stopala (500 ms). Nije loop.

const PIP_SIDE := 190.0
## Stopala u kutiji Pipa (dno sjenke PIP_SHADOW_FIELD: bottom 6, h 26).
const FEET_FROM_BOTTOM := 19.0

var _hop_k: float = 0.0
var _ring_r: float = 0.0
var _ring_a: float = 0.0
var _apply_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PIP_SIDE, PIP_SIDE)
	size = custom_minimum_size
	z_index = 20
	# Ormar: Pip na polju odmah nosi novi skin (ApplyMoment skok vodi SeasonField).
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)


func _on_cosmetics_changed(_slots: Array) -> void:
	queue_redraw()


func play_apply() -> void:
	if _apply_tween != null and _apply_tween.is_valid():
		_apply_tween.kill()
	_hop_k = 0.0
	_ring_r = UiWardrobe.RING_R.x
	_ring_a = 1.0
	_apply_tween = create_tween().set_parallel()
	_apply_tween.tween_method(_set_hop, 0.0, 1.0, UiWardrobe.T_FIELD_HOP).set_delay(UiWardrobe.T_APPLY_DELAY)
	_apply_tween.tween_method(_set_ring_r, UiWardrobe.RING_R.x, UiWardrobe.RING_R.y, UiWardrobe.T_RING) \
		.set_delay(UiWardrobe.T_APPLY_DELAY).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_apply_tween.tween_method(_set_ring_a, 1.0, 0.0, UiWardrobe.T_RING).set_delay(UiWardrobe.T_APPLY_DELAY)
	_apply_tween.chain().tween_callback(_end_apply)


func is_apply_playing() -> bool:
	return _apply_tween != null and _apply_tween.is_running()


func _end_apply() -> void:
	_hop_k = 0.0
	_ring_a = 0.0
	queue_redraw()


func _set_hop(k: float) -> void:
	_hop_k = k
	queue_redraw()


func _set_ring_r(r: float) -> void:
	_ring_r = r
	queue_redraw()


func _set_ring_a(a: float) -> void:
	_ring_a = a
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 8.0:
		return
	var feet := Vector2(side * 0.5, side - FEET_FROM_BOTTOM)
	if _ring_a > 0.001:
		# ApplyRing: elipsa (r, 0.42 r), rub 10, krem .55 → 0 — iza Pipa.
		draw_set_transform(feet, 0.0, Vector2(1.0, 0.42))
		draw_arc(Vector2.ZERO, _ring_r, 0.0, TAU, 64, Color(UiWardrobe.RING, UiWardrobe.RING.a * _ring_a), float(UiWardrobe.RING_W), true)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	var arc := sin(PI * _hop_k)
	if arc > 0.0001:
		var sc := 1.0 + (UiWardrobe.FIELD_HOP_SCALE - 1.0) * arc
		draw_set_transform(feet + Vector2(0.0, -float(UiWardrobe.FIELD_HOP_Y) * arc), 0.0, Vector2(sc, sc))
		UiHomeV3.draw_pip(self, Rect2(-feet, Vector2(side, side)), UiHomeV3.PIP_SHADOW_FIELD)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	UiHomeV3.draw_pip(self, Rect2(Vector2.ZERO, Vector2(side, side)), UiHomeV3.PIP_SHADOW_FIELD)
