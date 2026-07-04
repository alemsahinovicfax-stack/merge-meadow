extends Control

## Mali Pip preview za UI (main menu, HUD badge).

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
	var scale := side / 56.0
	var center := size * 0.5
	PIP_DRAW.draw_pip(self, center, scale)
