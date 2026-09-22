extends Area2D

const SeasonThemeScript := preload("res://scripts/seasons/season_theme.gd")

## v1 visual motif. Collision shape stays 64×64 (not the drawn 176×150 body).
var kind: String = "stone"


func set_kind(p_kind: String) -> void:
	kind = "stump" if p_kind == "stump" else "stone"
	var visual := get_node_or_null("Visual")
	if visual:
		visual.queue_redraw()


func _ready() -> void:
	apply_season_tint()


func apply_season_tint() -> void:
	var visual := get_node_or_null("Visual") as CanvasItem
	if visual == null:
		return
	visual.modulate = SeasonThemeScript.obstacle_modulate(GameState.active_season_id)
