class_name UiAssets
extends RefCounted

## UI ikone — Figma play + Kenney game-icons (CC0) + hub chrome SVG (Claude Design).

const ICON_PLAY_PATH := "res://assets/ui/icon_play.png"
const KENNEY_DIR := "res://assets/ui/kenney/"
const CHROME_DIR := "res://assets/ui/chrome/"
const ARENA_DIR := "res://assets/ui/arena/"
const CAMP_DIR := "res://assets/ui/camp/"
const RUN_DIR := "res://assets/ui/run/"
const BUTTON_ICON_SIZE := 32.0
const HUD_ICON_SIZE := 24.0

const KENNEY_ICONS := {
	"settings": "icon_settings.png",
	"wallet": "icon_wallet.png",
	"retry": "icon_retry.png",
	"home": "icon_home.png",
	"revive": "icon_revive.png",
	"double": "icon_double.png",
}

static var _cache: Dictionary = {}


static func get_play_icon() -> Texture2D:
	return _load_icon(ICON_PLAY_PATH)


static func get_kenney_icon(name: String) -> Texture2D:
	var file_name: String = KENNEY_ICONS.get(name, "")
	if file_name.is_empty():
		return null
	return _load_icon(KENNEY_DIR + file_name)


## Hub chrome ikona po imenu fajla bez .svg — npr. "tab_home", "tab_home_light", "icon_coin".
static func get_chrome_icon(icon_name: String) -> Texture2D:
	return _load_icon(CHROME_DIR + icon_name + ".svg")


## Merge Arena HUD ikone — "icon_crystal", "icon_target", "icon_check".
static func get_arena_icon(icon_name: String) -> Texture2D:
	return _load_icon(ARENA_DIR + icon_name + ".svg")


## Camp ikone — "icon_merge_arrow", "icon_reserved", "icon_hold_stop".
static func get_camp_icon(icon_name: String) -> Texture2D:
	return _load_icon(CAMP_DIR + icon_name + ".svg")


## Run HUD ikone — "icon_pause", "icon_basket".
static func get_run_icon(icon_name: String) -> Texture2D:
	return _load_icon(RUN_DIR + icon_name + ".svg")


static func _load_icon(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path] as Texture2D
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	_cache[path] = tex
	return tex
