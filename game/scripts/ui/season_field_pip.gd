extends Control

## HOME-14 LIFE-D — decorative Pip on SeasonField. IGNORE; FSM lives on SeasonField.
## Home v3: isti crtez (pip_idle.svg) i senka kao putujuci Pip s kartice, pa je
## predaja na kraju prelaza bez skoka.
## Ormar · ApplyMoment: play_apply() — Pip skoči u novom skinu (1,18 / 280 ms, pivot
## stopala, kao combo hop u Areni) + jedan krem prsten oko stopala (500 ms). Nije loop.
## Season Kit (design_handoff_seasons § Odlučeno 7): poza po FSM stanju — hod = bob
## 0,42 s (−7 px, 0,97 / 1,03); njuši = pip_sniff.svg + nagib ±7° prema cvijetu; spava =
## pip_sleep.svg + sabijanje 1,04 / 0,94 + tri „z". Sjena ostaje na tlu.

const PIP_SIDE := 190.0
## Stopala u kutiji Pipa (dno sjenke PIP_SHADOW_FIELD: bottom 6, h 26).
const FEET_FROM_BOTTOM := 19.0
const POSE_WALK := "walk"
const POSE_SNIFF := "sniff"
const POSE_SLEEP := "sleep"
const SNIFF_TILT := 7.0
const SNIFF_DROP := 6.0
## „z" iz Zzz sloja: početak (120, 10) u kutiji Pipa, svaki sljedeći +18 / −16, let (34, −90).
const ZZZ_ORIGIN := Vector2(120.0, 10.0)
const ZZZ_STEP := Vector2(18.0, -16.0)
const ZZZ_FLIGHT := Vector2(34.0, -90.0)
const ZZZ_INK := Color("#2D3436")

var _hop_k: float = 0.0
var _ring_r: float = 0.0
var _ring_a: float = 0.0
var _apply_tween: Tween
var _pose: String = POSE_WALK
var _walking: bool = false
var _tilt: float = 0.0
var _anim_t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PIP_SIDE, PIP_SIDE)
	size = custom_minimum_size
	z_index = 20
	set_process(false)
	# Ormar: Pip na polju odmah nosi novi skin (ApplyMoment skok vodi SeasonField).
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)


func _on_cosmetics_changed(_slots: Array) -> void:
	queue_redraw()


## Poza po FSM stanju. walking = bob samo dok se Pip kreće; tilt_dir = smjer cvijeta (±1).
func set_pose(pose: String, walking: bool = false, tilt_dir: float = 1.0) -> void:
	_pose = pose
	_walking = walking and pose == POSE_WALK
	_tilt = SNIFF_TILT * signf(tilt_dir) if pose == POSE_SNIFF else 0.0
	_anim_t = 0.0
	set_process(is_visible_in_tree() and (_walking or _pose == POSE_SLEEP))
	queue_redraw()


func get_pose() -> String:
	return _pose


func is_walking() -> bool:
	return _walking


func _process(delta: float) -> void:
	_anim_t += delta
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(is_visible_in_tree() and (_walking or _pose == POSE_SLEEP))


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
	var tex := PipAssets.get_pose_texture(_pose)
	if tex == null:
		UiHomeV3.draw_pip(self, Rect2(Vector2.ZERO, Vector2(side, side)), UiHomeV3.PIP_SHADOW_FIELD)
		return
	var shadow: Array = UiHomeV3.PIP_SHADOW_FIELD
	var sh := Rect2(float(shadow[0]), side - float(shadow[1]) - float(shadow[3]), float(shadow[2]), float(shadow[3]))
	draw_style_box(UiStage.box(UiHomeV3.PIP_SHADOW, roundi(sh.size.y * 0.5)), sh)
	var sc := Vector2.ONE
	var lift := 0.0
	var rot := 0.0
	var arc := sin(PI * _hop_k)
	if arc > 0.0001:
		var h := 1.0 + (UiWardrobe.FIELD_HOP_SCALE - 1.0) * arc
		sc = Vector2(h, h)
		lift = -float(UiWardrobe.FIELD_HOP_Y) * arc
	else:
		match _pose:
			POSE_WALK:
				if _walking:
					var b := 0.5 - 0.5 * cos(TAU * _anim_t / UiSeasons.PIP_BOB_SEC)
					lift = UiSeasons.PIP_BOB_Y * b
					sc = Vector2.ONE.lerp(UiSeasons.PIP_BOB_SQUASH, b)
			POSE_SNIFF:
				rot = deg_to_rad(_tilt)
				lift = SNIFF_DROP
			POSE_SLEEP:
				sc = UiSeasons.PIP_SLEEP_SQUASH
	draw_set_transform(feet + Vector2(0.0, lift), rot, sc)
	draw_texture_rect(tex, Rect2(-feet, Vector2(side, side)), false)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if _pose == POSE_SLEEP and arc <= 0.0001:
		_draw_zzz()


## Tri „z" (26 / 32 / 38 px, krem s tamnim rubom 6): 2,4 s, razmak 0,6 s; let (34, −90),
## skala 0,6 → 1,1, alpha 0 → 1 (25 %) → 0.
func _draw_zzz() -> void:
	var z: Dictionary = UiSeasons.SLEEP_ZZZ
	var sizes: Array = z["sizes"]
	var sec := float(z["sec"])
	var fill := Color(str(z["fill"]))
	for i in int(z["n"]):
		var local := _anim_t - float(z["stagger"]) * i
		if local < 0.0:
			continue
		var t := fposmod(local / sec, 1.0)
		var a := t / 0.25 if t < 0.25 else (1.0 - t) / 0.75
		var px := maxi(8, roundi(float(sizes[i]) * lerpf(0.6, 1.1, t)))
		var font := UiStage.font(900, px)
		var at := ZZZ_ORIGIN + ZZZ_STEP * i + ZZZ_FLIGHT * t + Vector2(0.0, px)
		draw_string_outline(font, at, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, px, int(z["outline"]), Color(ZZZ_INK, a))
		draw_string(font, at, "z", HORIZONTAL_ALIGNMENT_LEFT, -1, px, Color(fill, a))
