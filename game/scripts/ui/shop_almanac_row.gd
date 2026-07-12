class_name ShopAlmanacRow
extends VBoxContainer

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")

var _entry: Dictionary = {}
var _title: Label
var _caption: Label
var _built: bool = false


func apply(entry: Dictionary) -> void:
	_entry = entry
	if _built:
		_refresh()


func _ready() -> void:
	_ensure_built()
	if not _entry.is_empty():
		_refresh()


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	custom_minimum_size = Vector2(0, 64)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 4)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", READABILITY.font(20))
	_title.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)
	add_child(_title)

	_caption = Label.new()
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", READABILITY.font(15))
	_caption.add_theme_color_override("font_color", Color(0.38, 0.42, 0.38))
	add_child(_caption)


func _refresh() -> void:
	if not _built:
		return
	var name: String = str(_entry.get("name", "?"))
	var stars: String = str(_entry.get("stars", ""))
	var spawn_unlocked := bool(_entry.get("spawn_unlocked", false))
	var prog: Dictionary = _entry.get("tier_progress", {})
	_title.text = "%s %s" % [name, stars]
	if spawn_unlocked and bool(prog.get("complete", false)):
		_caption.text = "All tiers discovered"
	elif str(prog.get("caption", "")).is_empty():
		_caption.text = ""
	else:
		var have := int(prog.get("have", 0))
		var need := maxi(1, int(prog.get("need", 1)))
		_caption.text = "%s  (%d / %d)" % [str(prog.get("caption", "")), have, need]
