class_name PickupAssets
extends RefCounted

## Coin + seed spriteovi — run pickupe i HUD ikone.

const COIN_PATH := "res://assets/pickups/coin.png"
const SEED_PATH := "res://assets/pickups/seed.png"
const COIN_RUN_SIZE := 40.0
const SEED_RUN_SIZE := 52.0
const DIAMOND_RUN_SIZE := 36.0
const HUD_ICON_SIZE := 32.0

static var _coin_tex: Texture2D
static var _seed_tex: Texture2D
static var _diamond_tex: Texture2D


static func get_coin_texture() -> Texture2D:
	if _coin_tex == null and ResourceLoader.exists(COIN_PATH):
		_coin_tex = load(COIN_PATH) as Texture2D
	return _coin_tex


static func get_seed_texture(_type_id: String = "") -> Texture2D:
	if _seed_tex == null and ResourceLoader.exists(SEED_PATH):
		_seed_tex = load(SEED_PATH) as Texture2D
	return _seed_tex


static func get_diamond_texture() -> Texture2D:
	if _diamond_tex != null:
		return _diamond_tex
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Soft teal gem silhouette (placeholder).
	var cx := 16.0
	var cy := 16.0
	for y in 32:
		for x in 32:
			var dx := float(x) - cx
			var dy := float(y) - cy
			var in_diamond := absf(dx) * 0.9 + absf(dy) * 1.15 < 11.0
			if not in_diamond:
				continue
			var edge := absf(absf(dx) * 0.9 + absf(dy) * 1.15 - 11.0)
			var c := Color(0.35, 0.85, 0.92, 1.0)
			if dy < -2.0:
				c = Color(0.75, 0.97, 1.0, 1.0)
			elif edge < 1.5:
				c = Color(0.12, 0.45, 0.55, 1.0)
			img.set_pixel(x, y, c)
	_diamond_tex = ImageTexture.create_from_image(img)
	return _diamond_tex


static func get_seed_tint(type_id: String) -> Color:
	return SeedVisualConfig.palette(type_id).seed


static func run_scale(tex: Texture2D, display_side: float) -> float:
	if tex == null:
		return 1.0
	var side := maxf(tex.get_size().x, tex.get_size().y)
	if side < 1.0:
		return 1.0
	return display_side / side
