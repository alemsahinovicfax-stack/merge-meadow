extends Control

## Companion portrait — run HUD, main menu, camp. Uses active companion from GameState by default.

const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")

@export var companion_id: String = ""
@export var follow_active_companion: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_size()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func refresh_portrait() -> void:
	queue_redraw()


func _ensure_size() -> void:
	if size.x < 1.0 or size.y < 1.0:
		size = custom_minimum_size


func _resolve_companion_id() -> String:
	if follow_active_companion:
		return GameState.get_active_companion_id()
	if not companion_id.is_empty():
		return companion_id
	return CompanionConfig.ID_PIP


func _draw() -> void:
	_ensure_size()
	var side := minf(size.x, size.y)
	if side < 1.0:
		return
	var center := size * 0.5
	COMPANION_ASSETS.draw_portrait(self, _resolve_companion_id(), center, side)
