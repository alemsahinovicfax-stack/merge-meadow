extends Sprite2D

## Diamond pickup visual — procedural gem from PickupAssets.

const ASSETS := preload("res://scripts/visual/pickup_assets.gd")


func _ready() -> void:
	var tex := ASSETS.get_diamond_texture()
	texture = tex
	centered = true
	if tex != null:
		scale = Vector2.ONE * ASSETS.run_scale(tex, ASSETS.DIAMOND_RUN_SIZE)
	else:
		queue_redraw()


func _draw() -> void:
	if texture != null:
		return
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, -16),
			Vector2(12, -4),
			Vector2(0, 16),
			Vector2(-12, -4),
		]),
		Color(0.35, 0.85, 0.92, 1.0)
	)
