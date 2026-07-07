class_name UiAssets
extends RefCounted

## UI ikone — Figma play + Kenney game-icons (CC0).

const ICON_PLAY_PATH := "res://assets/ui/icon_play.png"
const KENNEY_DIR := "res://assets/ui/kenney/"
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


static func _load_icon(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path] as Texture2D
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	_cache[path] = tex
	return tex
