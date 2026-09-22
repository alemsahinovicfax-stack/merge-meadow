extends HubPressable

## Pause — 128 px hit. Ikona iz assets/ui/run; dva stupca ako SVG još nije importan.

var _style: StyleBoxFlat
var _icon: Texture2D


func _ready() -> void:
	super._ready()
	custom_minimum_size = Vector2(UiRun.PAUSE_RECT.size.x, UiRun.PAUSE_RECT.size.y)
	_style = UiRun.chip_style(32)
	_icon = UiAssets.get_run_icon("icon_pause")
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 1.0 or _style == null:
		return
	_style.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))
	if _icon != null:
		var side := minf(size.x, size.y) * 0.5
		var rect := Rect2((size.x - side) * 0.5, (size.y - side) * 0.5, side, side)
		draw_texture_rect(_icon, rect, false)
		return
	var bar_w := size.x * 0.14
	var bar_h := size.y * 0.42
	var y := (size.y - bar_h) * 0.5
	var ink := Color("#2D3436")
	draw_rect(Rect2(size.x * 0.30, y, bar_w, bar_h), ink, true)
	draw_rect(Rect2(size.x * 0.56, y, bar_w, bar_h), ink, true)
