extends Control

## Pip portrait za UI (main menu, HUD badge) — isti sprite kao u runu.

const PIP_ASSETS := preload("res://scripts/visual/pip_assets.gd")
const PIP_DRAW := preload("res://scripts/visual/pip_draw.gd")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_size()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _ensure_size() -> void:
	if size.x < 1.0 or size.y < 1.0:
		size = custom_minimum_size


func _draw() -> void:
	_ensure_size()
	var side := minf(size.x, size.y)
	if side < 1.0:
		return
	var tex := PIP_ASSETS.get_texture()
	if tex != null:
		var draw_scale := PIP_ASSETS.ui_scale_for_side(side)
		var draw_size := Vector2.ONE * PIP_ASSETS.SOURCE_FRAME_SIZE * draw_scale
		var top_left := (size - draw_size) * 0.5
		draw_texture_rect(tex, Rect2(top_left, draw_size), false)
		return
	var center := size * 0.5
	var scale := side / 56.0
	PIP_DRAW.draw_pip(self, center, scale)
