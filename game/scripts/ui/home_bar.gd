class_name HomeBar
extends Control

## Traka napretka u unlock posteru (coini / ★3 cvijece). Crta se samo kad se
## vrijednost promijeni; animacija punjenja traje UiHome.T_BAR.

var ratio: float = 0.0
var track_color: Color = Color(0.102, 0.102, 0.078, 0.20)
var fill_color: Color = UiHome.COIN_GOLD
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_colors(track: Color, fill: Color) -> void:
	track_color = track
	fill_color = fill
	queue_redraw()


func set_ratio(value: float, animated: bool = false) -> void:
	var target := clampf(value, 0.0, 1.0)
	if _tween:
		_tween.kill()
		_tween = null
	if not animated or not is_inside_tree() or is_equal_approx(target, ratio):
		_set_ratio_raw(target)
		return
	_tween = create_tween()
	_tween.tween_method(_set_ratio_raw, ratio, target, UiHome.T_BAR) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _set_ratio_raw(value: float) -> void:
	ratio = value
	queue_redraw()


func _draw() -> void:
	var radius := int(size.y * 0.5)
	draw_style_box(UiHome.box(track_color, radius), Rect2(Vector2.ZERO, size))
	if ratio <= 0.001:
		return
	# HTML: fill je unutar tracka s overflow:hidden, pa je zaobljen samo lijevo dok nije pun.
	var fill := UiHome.box(fill_color, radius)
	if ratio < 0.999:
		fill.corner_radius_top_right = 0
		fill.corner_radius_bottom_right = 0
	draw_style_box(fill, Rect2(Vector2.ZERO, Vector2(size.x * ratio, size.y)))
