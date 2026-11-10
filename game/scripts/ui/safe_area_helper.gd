class_name SafeAreaHelper
extends RefCounted

## iPhone notch / home indicator — vidi docs/05-technical/godot/ios-export.md


## True when the window is taller than the 16:9 design (19.5:9, 20:9).
## A 16:9 window and a wider one (desktop, square headless) stay on keep,
## so the viewport remains 1080x1920 and existing layout does not shift.
static func wants_expand(window_size: Vector2i, design: Vector2i) -> bool:
	if window_size.x < 2 or window_size.y < 2 or design.x < 2 or design.y < 2:
		return false
	var design_aspect := float(design.x) / float(design.y)
	var window_aspect := float(window_size.x) / float(window_size.y)
	return window_aspect < design_aspect - 0.01


static func get_insets(viewport: Viewport) -> Vector4:
	# top, right, bottom, left — viewport px.
	# get_window_safe_area() is in window pixels. canvas_items scales the viewport
	# to the window, so a 1440-wide phone with a 1080-wide viewport must not apply
	# the raw window inset or the header grows by the wrong amount.
	var window := viewport.get_window()
	if window == null or not window.has_method("get_window_safe_area"):
		return Vector4.ZERO
	var safe: Rect2i = window.get_window_safe_area()
	var win := window.get_size()
	if safe.size.x <= 0 or safe.size.y <= 0 or win.x <= 0 or win.y <= 0:
		return Vector4.ZERO
	var view := viewport.get_visible_rect().size
	if view.x < 1.0 or view.y < 1.0:
		view = Vector2(win)
	var sx := view.x / float(win.x)
	var sy := view.y / float(win.y)
	return Vector4(
		float(safe.position.y) * sy,
		float(win.x - safe.end.x) * sx,
		float(win.y - safe.end.y) * sy,
		float(safe.position.x) * sx
	)


static func apply_top_margin(control: Control, extra: float = 0.0) -> void:
	var top := get_insets(control.get_viewport()).x + extra
	control.offset_top += top
	control.offset_bottom += top


static func apply_bottom_margin(control: Control, extra: float = 0.0) -> void:
	var bottom := get_insets(control.get_viewport()).z + extra
	control.offset_top -= bottom
	control.offset_bottom -= bottom


static func apply_horizontal_margins(control: Control) -> void:
	var insets := get_insets(control.get_viewport())
	control.offset_left += insets.w
	control.offset_right -= insets.y
