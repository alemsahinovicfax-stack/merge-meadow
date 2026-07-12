extends Label

## Desni feed — +1 Clover, +1 Coin tokom runa.

const MAX_LINES := 5
const FADE_SEC := 4.0

const CONFIG := preload("res://scripts/visual/seed_visual_config.gd")

var _lines: Array[Dictionary] = []


func _ready() -> void:
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_theme_font_size_override("font_size", 22)
	add_theme_color_override("font_color", Color(0.22, 0.32, 0.22, 1.0))
	text = ""


func push_coin() -> void:
	_push_line("+1 Coin", Color(0.85, 0.72, 0.2))


func push_seed(type_id: String) -> void:
	var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
	var tint: Color = CONFIG.palette(type_id).seed
	_push_line("+1 %s" % name, tint.darkened(0.25))


func _push_line(line: String, color: Color) -> void:
	_lines.push_front({"text": line, "color": color, "at": Time.get_ticks_msec()})
	while _lines.size() > MAX_LINES:
		_lines.pop_back()
	_refresh_text()


func _process(_delta: float) -> void:
	if _lines.is_empty():
		return
	var now := Time.get_ticks_msec()
	var changed := false
	while not _lines.is_empty():
		var age_ms := now - int(_lines[_lines.size() - 1].at)
		if age_ms < int(FADE_SEC * 1000.0):
			break
		_lines.pop_back()
		changed = true
	if changed:
		_refresh_text()


func _refresh_text() -> void:
	if _lines.is_empty():
		text = ""
		return
	var parts: PackedStringArray = []
	for entry in _lines:
		parts.append(str(entry.text))
	text = "\n".join(parts)
