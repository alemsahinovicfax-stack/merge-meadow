extends Sprite2D

## Run companion sprite — Pip SVG or procedural fallback (Mochi / missing art).

const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")
const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
const _LEVEL0_RADIUS := 40.5

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false


func _ready() -> void:
	z_index = 10
	set_process(false)
	_apply_companion_visual()
	queue_redraw()


func refresh_companion_visual() -> void:
	_apply_companion_visual()
	queue_redraw()


func _apply_companion_visual() -> void:
	var companion_id := GameState.get_active_companion_id()
	var pip_skin := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_PIP_SKIN)
	if companion_id == CompanionConfig.ID_PIP and not pip_skin.is_empty():
		_use_draw_fallback = true
		texture = null
		scale = Vector2.ONE
		return
	var tex := COMPANION_ASSETS.get_run_texture(companion_id)
	if tex != null:
		texture = tex
		centered = true
		scale = Vector2.ONE * CompanionConfig.run_scale()
		_use_draw_fallback = false
	else:
		_use_draw_fallback = true
		texture = null
		scale = Vector2.ONE


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	set_process(radius > _LEVEL0_RADIUS)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	_draw_ground_shadow()
	_draw_magnet_fill()
	if _use_draw_fallback:
		COMPANION_ASSETS.draw_run(self, GameState.get_active_companion_id(), CompanionConfig.run_scale())
	_draw_magnet_ring()


func _draw_ground_shadow() -> void:
	var pts := PackedVector2Array()
	var center := Vector2(0, 40)
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(a) * 36.0, sin(a) * 12.0))
	draw_colored_polygon(pts, Color(0.071, 0.110, 0.086, 0.28))


func _magnet_pulse() -> float:
	if _magnet_radius <= _LEVEL0_RADIUS:
		return 1.0
	var t := Time.get_ticks_msec() / 1000.0
	return 1.0 + 0.045 * sin(TAU * t / 1.8)


func _draw_magnet_fill() -> void:
	if _magnet_radius <= _LEVEL0_RADIUS:
		return
	var cream := Color(1.0, 0.973, 0.941, 0.07)
	draw_circle(Vector2.ZERO, _magnet_radius * _magnet_pulse(), cream)


func _draw_magnet_ring() -> void:
	if _magnet_radius <= 0.0:
		return
	if _magnet_radius <= _LEVEL0_RADIUS:
		draw_arc(
			Vector2.ZERO,
			_magnet_radius,
			0.0,
			TAU,
			48,
			Color(1.0, 0.973, 0.941, 0.20),
			4.0,
			true
		)
		return
	var radius := _magnet_radius * _magnet_pulse()
	var color := Color(1.0, 0.973, 0.941, 0.42)
	var dashes := 14
	var span := TAU / float(dashes)
	for i in dashes:
		var a0 := float(i) * span
		var a1 := a0 + span * 0.55
		draw_arc(Vector2.ZERO, radius, a0, a1, 8, color, 7.0, true)
