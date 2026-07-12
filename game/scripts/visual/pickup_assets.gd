class_name PickupAssets
extends RefCounted

## Coin + seed spriteovi — run pickupe i HUD ikone.

const COIN_PATH := "res://assets/pickups/coin.png"
const SEED_PATH := "res://assets/pickups/seed.png"
const COIN_RUN_SIZE := 40.0
const SEED_RUN_SIZE := 52.0
const HUD_ICON_SIZE := 32.0

static var _coin_tex: Texture2D
static var _seed_tex: Texture2D


static func get_coin_texture() -> Texture2D:
	if _coin_tex == null and ResourceLoader.exists(COIN_PATH):
		_coin_tex = load(COIN_PATH) as Texture2D
	return _coin_tex


static func get_seed_texture(_type_id: String = "") -> Texture2D:
	if _seed_tex == null and ResourceLoader.exists(SEED_PATH):
		_seed_tex = load(SEED_PATH) as Texture2D
	return _seed_tex


static func get_seed_tint(type_id: String) -> Color:
	return SeedVisualConfig.palette(type_id).seed


static func run_scale(tex: Texture2D, display_side: float) -> float:
	if tex == null:
		return 1.0
	var side := maxf(tex.get_size().x, tex.get_size().y)
	if side < 1.0:
		return 1.0
	return display_side / side
