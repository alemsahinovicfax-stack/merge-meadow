extends Sprite2D

## Run companion sprite — Pip SVG or procedural fallback (Mochi / missing art).

const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")
const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
const MAGNET_DRAW_THRESHOLD := 50.0

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false


func _ready() -> void:
	z_index = 10
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
		scale = Vector2.ONE * CompanionConfig.run_scale()
		_use_draw_fallback = false
	else:
		_use_draw_fallback = true
		texture = null
		scale = Vector2.ONE


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	queue_redraw()


func _draw() -> void:
	if _use_draw_fallback:
		COMPANION_ASSETS.draw_run(self, GameState.get_active_companion_id(), CompanionConfig.run_scale())
	if _magnet_radius > MAGNET_DRAW_THRESHOLD:
		draw_arc(Vector2.ZERO, _magnet_radius, 0.0, TAU, 48, Color(0.5, 0.8, 1.0, 0.25), 3.0)
