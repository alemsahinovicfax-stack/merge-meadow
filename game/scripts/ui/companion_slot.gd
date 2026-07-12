extends Control

## Tap-to-select companion portrait (camp picker).

signal slot_pressed(companion_id: String)

const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")
const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")

@export var companion_id: String = CompanionConfig.ID_PIP

var selected: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(72, 72)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			slot_pressed.emit(companion_id)
			accept_event()


func set_selected(is_selected: bool) -> void:
	if selected == is_selected:
		return
	selected = is_selected
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side < 1.0:
		return
	var center := size * 0.5
	var unlocked := GameState.is_companion_unlocked(companion_id)

	if selected and unlocked:
		draw_circle(center, side * 0.48, Color(1.0, 0.92, 0.45, 0.35))
		draw_arc(center, side * 0.46, 0.0, TAU, 32, Color(1.0, 0.82, 0.2, 0.95), 3.0)
	elif not unlocked:
		draw_circle(center, side * 0.42, Color(0.2, 0.22, 0.24, 0.35))

	COMPANION_ASSETS.draw_portrait(self, companion_id, center, side * 0.82)

	if not unlocked:
		draw_circle(center, side * 0.16, Color(0.12, 0.14, 0.16, 0.82))
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-5.0, 5.0),
			"?",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			int(side * 0.2),
			Color(0.92, 0.94, 0.96, 1.0)
		)

	var name := CompanionConfig.display_name(companion_id)
	var label_color := Color(1.0, 0.95, 0.7, 1.0) if selected and unlocked else Color(0.85, 0.88, 0.9, 0.95)
	if not unlocked:
		label_color = Color(0.65, 0.68, 0.72, 0.9)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(4.0, size.y - 4.0),
		name,
		HORIZONTAL_ALIGNMENT_LEFT,
		int(size.x - 8.0),
		16,
		label_color
	)
