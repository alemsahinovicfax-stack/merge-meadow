extends Control

## Prsten tajmera — 104 px, debljina 14. Peach ispod 17 %, bez crvenog panic stanja.

var progress: float = 1.0
var ring_color: Color = UiRun.RING_OK


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(UiRun.TIMER_RING, UiRun.TIMER_RING)
	resized.connect(queue_redraw)


func set_progress(p: float, color: Color) -> void:
	progress = clampf(p, 0.0, 1.0)
	ring_color = color
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - float(UiRun.TIMER_RING_THICK) * 0.5
	if radius < 4.0:
		return
	draw_arc(center, radius, 0.0, TAU, 64, UiRun.RING_TRACK, float(UiRun.TIMER_RING_THICK), true)
	if progress <= 0.001:
		return
	var start := -PI * 0.5
	var end := start + TAU * progress
	draw_arc(center, radius, start, end, 64, ring_color, float(UiRun.TIMER_RING_THICK), true)
