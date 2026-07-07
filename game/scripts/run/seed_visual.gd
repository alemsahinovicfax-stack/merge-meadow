extends Sprite2D

## Sjeme u runu — seed sprite.

const ASSETS := preload("res://scripts/visual/pickup_assets.gd")


func _ready() -> void:
	var tex := ASSETS.get_seed_texture()
	texture = tex
	centered = true
	if tex != null:
		scale = Vector2.ONE * ASSETS.run_scale(tex, ASSETS.SEED_RUN_SIZE)
	else:
		queue_redraw()


func _draw() -> void:
	if texture != null:
		return
	draw_circle(Vector2.ZERO, 22.0, Color("#FFEAA7"))
	draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color("#2D3436"), 2.0)
