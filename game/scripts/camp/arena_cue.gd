class_name ArenaCue
extends RefCounted

## Bijeli oblacic iznad vrece — jedini tekst koji je ostao u areni. Nosi tutorial
## poruku prvog pokretanja i prolaznu poruku Merge Hint boostera. HUD red, traka s
## porukama i combo pilula uklonjeni su 2026-09-24 (merge-arena-cd-brief § Izmjena).

const CUE_FONT_SIZE := 40
const CUE_MAX_W := 760.0
const CUE_BOTTOM := 330.0
const MESSAGE_SEC := 3.5
const FADE_SEC := 0.25

var cue: VBoxContainer
var cue_label: Label
var cue_arrow: Control

var _owner: Control
var _tutorial_on: bool = false
var _message_tween: Tween = null


func _init(owner: Control) -> void:
	_owner = owner
	var field := "RootVBox/Playfield/"
	cue = owner.get_node(field + "TutorialCue")
	cue_label = owner.get_node(field + "TutorialCue/CuePanel/CueLabel")
	cue_arrow = owner.get_node(field + "TutorialCue/CueArrow")
	_style()


## Tutorial oblacic stoji dok se ne prospe sjeme; poruka boostera ga privremeno preuzme.
func set_tutorial_visible(on: bool) -> void:
	_tutorial_on = on
	if _message_tween != null and _message_tween.is_valid():
		return
	cue_label.text = tutorial_text()
	cue.modulate.a = 1.0
	cue.visible = on
	if on:
		layout(_field_size())


## Prolazna poruka (Merge Hint booster) — isti oblacic, sam se gasi.
func show_message(text: String, sec: float = MESSAGE_SEC) -> void:
	if text.is_empty():
		return
	_kill_message_tween()
	cue_label.text = text
	cue.modulate.a = 1.0
	cue.visible = true
	cue_arrow.visible = false
	layout(_field_size())
	_message_tween = _owner.create_tween()
	_message_tween.tween_interval(sec)
	_message_tween.tween_property(cue, "modulate:a", 0.0, FADE_SEC)
	_message_tween.tween_callback(_restore_tutorial)


func get_text() -> String:
	return cue_label.text


func is_cue_visible() -> bool:
	return cue.visible and cue.modulate.a > 0.01


static func tutorial_text() -> String:
	return "Tap the bag to pour seeds. Drag matching seeds together."


## Autowrap labela javlja visinu po svojoj trenutnoj sirini, a container je dobije tek
## u sljedecem sort prolazu — zato se oblacic mjeri dva puta (odmah i frejm kasnije).
func layout(field_size: Vector2) -> void:
	if field_size.x < 10.0 or not cue.is_inside_tree():
		return
	cue_label.custom_minimum_size.x = minf(CUE_MAX_W - 64.0, field_size.x - 160.0)
	_place(field_size)
	await cue.get_tree().process_frame
	if cue.is_inside_tree():
		_place(field_size)


func _place(field_size: Vector2) -> void:
	var cue_size := cue.get_combined_minimum_size()
	cue_size.x = maxf(cue_size.x, cue_label.custom_minimum_size.x)
	cue_size.y = minf(cue_size.y, field_size.y * 0.5)
	cue.size = cue_size
	cue.position = Vector2((field_size.x - cue_size.x) * 0.5, field_size.y - CUE_BOTTOM - cue_size.y)


func _field_size() -> Vector2:
	var field := cue.get_parent() as Control
	return field.size if field else Vector2.ZERO


func _restore_tutorial() -> void:
	_message_tween = null
	cue_arrow.visible = true
	set_tutorial_visible(_tutorial_on)


func _kill_message_tween() -> void:
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	_message_tween = null


func _style() -> void:
	cue_label.add_theme_font_size_override("font_size", CUE_FONT_SIZE)
	cue_label.add_theme_font_override("font", UiChrome.heavy_font(UiChrome.EMBOLDEN_800))
	cue_label.add_theme_color_override("font_color", UiPalette.OUTLINE)
	(cue_label.get_parent() as PanelContainer).add_theme_stylebox_override("panel", UiArena.cue_style())
	cue_arrow.draw.connect(_draw_cue_arrow)


func _draw_cue_arrow() -> void:
	var w := cue_arrow.size.x
	var h := cue_arrow.size.y
	cue_arrow.draw_colored_polygon(
		PackedVector2Array([Vector2(0.0, 0.0), Vector2(w, 0.0), Vector2(w * 0.5, h)]), UiPalette.WARM_WHITE
	)
