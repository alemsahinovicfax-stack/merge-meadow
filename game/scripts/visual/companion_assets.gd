class_name CompanionAssets
extends RefCounted

const COMPANION_CONFIG := preload("res://scripts/visual/companion_config.gd")
const PIP_ASSETS := preload("res://scripts/visual/pip_assets.gd")
const PIP_DRAW := preload("res://scripts/visual/pip_draw.gd")
const MOCHI_DRAW := preload("res://scripts/visual/mochi_draw.gd")


static func get_run_texture(companion_id: String) -> Texture2D:
	if companion_id == CompanionConfig.ID_PIP:
		return PIP_ASSETS.get_texture()
	return null


static func draw_run(canvas: CanvasItem, companion_id: String, scale: float = 1.0) -> void:
	match companion_id:
		CompanionConfig.ID_MOCHI:
			MOCHI_DRAW.draw_mochi(canvas, Vector2.ZERO, scale)
		_:
			PIP_DRAW.draw_pip(canvas, Vector2.ZERO, scale)


static func draw_portrait(canvas: CanvasItem, companion_id: String, center: Vector2, side: float) -> void:
	var tex := get_run_texture(companion_id)
	if tex != null:
		var draw_scale := CompanionConfig.ui_scale_for_side(side)
		var draw_size := Vector2.ONE * CompanionConfig.SOURCE_FRAME_SIZE * draw_scale
		var top_left := center - draw_size * 0.5
		canvas.draw_texture_rect(tex, Rect2(top_left, draw_size), false)
		return
	var scale := side / 56.0
	match companion_id:
		CompanionConfig.ID_MOCHI:
			MOCHI_DRAW.draw_mochi(canvas, center, scale)
		_:
			PIP_DRAW.draw_pip(canvas, center, scale)
