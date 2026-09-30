class_name ArenaComboMark
extends Control

## Combo „×N" na mjestu spajanja (Arena v2, design_handoff_arena_v2 § Combo): krem ili zlatan
## tekst s obrubom 8 px #2D3436, velicina 52 / 58 / 64 / 70.
## Crta sam sebe umjesto Labela: promjena velicine/boje Labela preko theme overridea ponovo
## oblikuje tekst i trosi 0,3–2 ms bas u frejmu spajanja. Ovdje je to samo queue_redraw, a
## glifovi svih velicina se pripreme unaprijed (prewarm), pa prvi combo ne steka.

const PREWARM_TEXT := "×0123456789"

var text: String = ""
var font_size: int = 52
var fill_color: Color = Color.WHITE

var _font: Font = null
var _ink: Color = Color.BLACK
var _outline: int = 8
var _prewarm_sizes: Array[int] = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = UiChrome.heavy_font(UiChrome.EMBOLDEN_800)
	var cfg := UiArenaV2.COMBO_MARK
	_ink = UiArenaV2.col(str(cfg["ink"]))
	_outline = int(cfg["outline"])


## Iscrta sve combo velicine jednom (nevidljivo), da glifovi i obrub budu u kesu fonta.
func prewarm() -> void:
	_prewarm_sizes.clear()
	for step in UiArenaV2.COMBO_STEPS:
		var px := int(step["mark"])
		if not _prewarm_sizes.has(px):
			_prewarm_sizes.append(px)
	visible = true
	modulate.a = 0.0
	queue_redraw()


## Postavi tekst, velicinu i boju; velicina kontrole prati tekst (pivot = centar).
func show_mark(value: String, px: int, color: Color) -> void:
	text = value
	font_size = px
	fill_color = color
	var w := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + _outline
	size = Vector2(w, _font.get_height(font_size) + _outline)
	pivot_offset = size * 0.5
	queue_redraw()


func _draw() -> void:
	if not _prewarm_sizes.is_empty():
		for px in _prewarm_sizes:
			_draw_text(PREWARM_TEXT, px, fill_color)
		_prewarm_sizes.clear()
		return
	if text.is_empty():
		return
	_draw_text(text, font_size, fill_color)


func _draw_text(value: String, px: int, color: Color) -> void:
	var pos := Vector2(_outline * 0.5, _outline * 0.5 + _font.get_ascent(px))
	draw_string_outline(_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, px, _outline, _ink)
	draw_string(_font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, px, color)
