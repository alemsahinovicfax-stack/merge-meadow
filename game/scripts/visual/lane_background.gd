extends Sprite2D

## Lane run pozadina — Figma Make export, cover-scale na viewport.

const TEXTURE_PATH := "res://assets/backgrounds/lane_background.png"


func _ready() -> void:
	z_index = -10
	texture = _load_texture()
	centered = false
	_apply_meadow_cosmetic()
	_fit_to_viewport()
	get_viewport().size_changed.connect(_fit_to_viewport)


func _apply_meadow_cosmetic() -> void:
	var bg_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_MEADOW_BG)
	modulate = CosmeticCatalog.get_meadow_modulate(bg_id)


func _load_texture() -> Texture2D:
	if ResourceLoader.exists(TEXTURE_PATH):
		return load(TEXTURE_PATH) as Texture2D
	push_warning("LaneBackground: missing %s" % TEXTURE_PATH)
	return null


func _fit_to_viewport() -> void:
	if texture == null:
		return
	var vp := get_viewport_rect().size
	var tex_size := texture.get_size()
	if vp.x < 1.0 or vp.y < 1.0 or tex_size.x < 1.0:
		return
	var cover_scale := maxf(vp.x / tex_size.x, vp.y / tex_size.y)
	scale = Vector2.ONE * cover_scale
	var scaled := tex_size * cover_scale
	position = (vp - scaled) * 0.5
