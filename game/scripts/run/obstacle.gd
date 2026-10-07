extends Area2D

## v1 visual motif. Collision shape stays 64×64 (not the drawn 176×150 body).
var kind: String = "stone"


func set_kind(p_kind: String) -> void:
	kind = "stump" if p_kind == "stump" else "stone"
	var visual := get_node_or_null("Visual")
	if visual:
		visual.queue_redraw()


func _ready() -> void:
	apply_season_tint()


## Season Kit (faza 2): svih 8 sezona ima svoje prepreke u svojim bojama — bez tinta
## sezone (tint sezone je ukinut). Ime ostaje jer ga run_controller zove pri spawnu.
func apply_season_tint() -> void:
	var visual := get_node_or_null("Visual") as CanvasItem
	if visual != null:
		visual.modulate = Color.WHITE
