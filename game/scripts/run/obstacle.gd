extends Area2D

const SeasonThemeScript := preload("res://scripts/seasons/season_theme.gd")

# Collision handled by player.gd via area_entered groups.


func _ready() -> void:
	apply_season_tint()


func apply_season_tint() -> void:
	var visual := get_node_or_null("Visual") as CanvasItem
	if visual == null:
		return
	visual.modulate = SeasonThemeScript.obstacle_modulate(GameState.active_season_id)
