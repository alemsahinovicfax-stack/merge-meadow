class_name PipAssets
extends RefCounted

## Shared Pip sprite — C2 art pass (Figma Make export).

const SPRITE_PATH := "res://assets/sprites/pip_idle.svg"
const SPRITE_FALLBACK := "res://assets/sprites/pip_idle.png"
const RUN_DISPLAY_HEIGHT := 112.0
const SOURCE_FRAME_SIZE := 256.0

static var _texture: Texture2D


static func get_texture() -> Texture2D:
	if _texture != null:
		return _texture
	for path in [SPRITE_PATH, SPRITE_FALLBACK]:
		if ResourceLoader.exists(path):
			_texture = load(path) as Texture2D
			if _texture != null:
				return _texture
	push_warning("PipAssets: sprite not loaded — using PipDraw fallback")
	return null


static func has_sprite() -> bool:
	return get_texture() != null


static func run_scale() -> float:
	return RUN_DISPLAY_HEIGHT / SOURCE_FRAME_SIZE


static func ui_scale_for_side(side: float) -> float:
	if side < 1.0:
		return 1.0
	return side / SOURCE_FRAME_SIZE
