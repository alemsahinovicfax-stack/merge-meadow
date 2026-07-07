class_name SafeAreaHelper
extends RefCounted

## iPhone notch / home indicator — vidi docs/05-technical/godot/ios-export.md


static func get_insets(viewport: Viewport) -> Vector4:
	# top, right, bottom, left (px u viewport koordinatama)
	var window := viewport.get_window()
	if window == null or not window.has_method("get_window_safe_area"):
		return Vector4.ZERO
	var safe: Rect2i = window.get_window_safe_area()
	var size := window.get_size()
	if safe.size.x <= 0 or safe.size.y <= 0:
		return Vector4.ZERO
	return Vector4(
		float(safe.position.y),
		float(size.x - safe.end.x),
		float(size.y - safe.end.y),
		float(safe.position.x)
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
