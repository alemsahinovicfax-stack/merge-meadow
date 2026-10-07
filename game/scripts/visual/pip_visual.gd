extends Sprite2D

## Run companion sprite — Pip SVG or procedural fallback (Mochi / missing art).
## Ormar: Pip skin je ista SVG tekstura s recolorom (PipAssets), ne PipDraw.
## Magnet (ispuna + isprekidan prsten) je u djetetu `_magnet`, nacrtan jednom; „disanje"
## prstena je skala tog čvora — prije se prsten (14 AA lukova) crtao iznova svaki frejm.

const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")
const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
const _LEVEL0_RADIUS := 40.5

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false
var _magnet: _Magnet = null


## Ispuna i prsten magneta u lokalnom prostoru Pipa (isti kao prije); puls = skala čvora.
class _Magnet:
	extends Node2D

	var owner_visual: Node

	func _draw() -> void:
		owner_visual._draw_magnet(self)


func _ready() -> void:
	z_index = 10
	set_process(false)
	_magnet = _Magnet.new()
	_magnet.name = "MagnetRing"
	_magnet.owner_visual = self
	add_child(_magnet)
	_apply_companion_visual()
	queue_redraw()


func refresh_companion_visual() -> void:
	_apply_companion_visual()
	queue_redraw()


func _apply_companion_visual() -> void:
	var companion_id := GameState.get_active_companion_id()
	var tex := COMPANION_ASSETS.get_run_texture(companion_id)
	if tex != null:
		texture = tex
		centered = true
		# Skin se rasterizuje 2× (512 px) — visina u runu ostaje 112.
		scale = Vector2.ONE * (CompanionConfig.RUN_DISPLAY_HEIGHT / maxf(1.0, float(tex.get_height())))
		_use_draw_fallback = false
	else:
		_use_draw_fallback = true
		texture = null
		scale = Vector2.ONE


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	set_process(radius > _LEVEL0_RADIUS)
	if _magnet != null:
		_magnet.scale = Vector2.ONE
		_magnet.queue_redraw()
	queue_redraw()


## Puls magneta bez crtanja: samo skala djeteta.
func _process(_delta: float) -> void:
	if _magnet != null:
		_magnet.scale = Vector2.ONE * _magnet_pulse()


func _draw() -> void:
	_draw_ground_shadow()
	if _use_draw_fallback:
		COMPANION_ASSETS.draw_run(self, GameState.get_active_companion_id(), CompanionConfig.run_scale())


func _draw_magnet(canvas: CanvasItem) -> void:
	_draw_magnet_fill(canvas)
	_draw_magnet_ring(canvas)


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


func _draw_magnet_fill(canvas: CanvasItem) -> void:
	if _magnet_radius <= _LEVEL0_RADIUS:
		return
	var cream := Color(1.0, 0.973, 0.941, 0.07)
	canvas.draw_circle(Vector2.ZERO, _magnet_radius, cream)


func _draw_magnet_ring(canvas: CanvasItem) -> void:
	if _magnet_radius <= 0.0:
		return
	if _magnet_radius <= _LEVEL0_RADIUS:
		canvas.draw_arc(
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
	var radius := _magnet_radius
	var color := Color(1.0, 0.973, 0.941, 0.42)
	var dashes := 14
	var span := TAU / float(dashes)
	for i in dashes:
		var a0 := float(i) * span
		var a1 := a0 + span * 0.55
		canvas.draw_arc(Vector2.ZERO, radius, a0, a1, 8, color, 7.0, true)
