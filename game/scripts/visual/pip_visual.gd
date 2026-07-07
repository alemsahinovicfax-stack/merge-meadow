extends Sprite2D

## Pip u runu — flat cartoon sprite (C2); magnet arc ostaje _draw overlay.

const PIP_ASSETS := preload("res://scripts/visual/pip_assets.gd")
const PIP_DRAW := preload("res://scripts/visual/pip_draw.gd")
const MAGNET_DRAW_THRESHOLD := 50.0

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false


func _ready() -> void:
	z_index = 10
	var tex := PIP_ASSETS.get_texture()
	if tex != null:
		texture = tex
		centered = true
		scale = Vector2.ONE * PIP_ASSETS.run_scale()
	else:
		_use_draw_fallback = true
		texture = null
		scale = Vector2.ONE
	queue_redraw()


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	queue_redraw()


func _draw() -> void:
	if _use_draw_fallback:
		PIP_DRAW.draw_pip(self, Vector2.ZERO, PIP_ASSETS.run_scale())
	if _magnet_radius > MAGNET_DRAW_THRESHOLD:
		draw_arc(Vector2.ZERO, _magnet_radius, 0.0, TAU, 48, Color(0.5, 0.8, 1.0, 0.25), 3.0)
