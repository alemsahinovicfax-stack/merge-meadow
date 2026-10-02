class_name ArenaCue
extends RefCounted

## A1 / A2 · oblačići Arene (design_handoff_popups): CoachBubble sistema iznad polja. Tutorial prvog
## pokretanja (dva reda sa slikama, rep dolje na korpu) stoji dok se ne prospe sjeme; „Muncher's
## awake!" (vodeći red + crtež T3, rep gore na munchera) je prolazan (3,5 s) i privremeno ga preuzme.

const MESSAGE_SEC := 3.5
const FADE_SEC := 0.25
const BAG_TIP_GAP := 6.0
const PEST_TIP_GAP := 46.0

var cue: CoachBubble

var _owner: Control
var _tutorial_on: bool = false
var _message_on: bool = false
var _message_tween: Tween = null


func _init(owner: Control) -> void:
	_owner = owner
	cue = CoachBubble.new()
	cue.name = "TutorialCue"
	cue.z_index = 56
	cue.visible = false
	owner.get_node("RootVBox/Playfield").add_child(cue)


## Tutorial oblačić stoji dok se ne prospe sjeme; poruka munchera ga privremeno preuzme.
func set_tutorial_visible(on: bool) -> void:
	var was := _tutorial_on and cue.visible and not _message_on
	_tutorial_on = on
	if _message_on:
		return
	if not on:
		cue.visible = false
		return
	cue.setup(tutorial_rows(), "down")
	layout(_field_size())
	if not was:
		cue.pop_in()


## Prolazna poruka — isti oblačić, sam se gasi. Tekst „Muncher's awake — …" daje dva reda sistema.
func show_message(text: String, sec: float = MESSAGE_SEC) -> void:
	if text.is_empty():
		return
	_kill_message_tween()
	_message_on = true
	cue.setup(message_rows(text), "up")
	layout(_field_size())
	cue.modulate.a = 1.0
	cue.pop_in()
	_message_tween = _owner.create_tween()
	_message_tween.tween_interval(sec)
	_message_tween.tween_property(cue, "modulate:a", 0.0, FADE_SEC)
	_message_tween.tween_callback(_restore_tutorial)


func get_text() -> String:
	return cue.text()


func is_cue_visible() -> bool:
	return cue.visible and cue.modulate.a > 0.01


static func tutorial_text() -> String:
	return "%s / %s" % [UiPopups.S_ARENA_TAP, UiPopups.S_ARENA_JOIN]


static func tutorial_rows() -> Array:
	return [
		{"text": UiPopups.S_ARENA_TAP, "icon": UiPopups.icon("icon_basket"), "disc": UiPopups.COIN_GOLD},
		{"text": UiPopups.S_ARENA_JOIN, "art": "clover", "tier": 1, "disc": UiPopups.ACTIVE_RIM},
	]


static func message_rows(text: String) -> Array:
	if text.begins_with("Muncher"):
		return [
			{"text": UiPopups.S_MUNCHER_AWAKE, "lead": true},
			{"text": UiPopups.S_MUNCHER_FREEZE, "art": "clover", "tier": 3, "disc": UiPopups.ACTIVE_RIM},
		]
	return [{"text": text, "lead": true}]


func layout(field_size: Vector2) -> void:
	if field_size.x < 10.0 or not cue.is_inside_tree():
		return
	var bounds := Rect2(24.0, 24.0, field_size.x - 48.0, field_size.y - 48.0)
	if cue.dir == "up":
		cue.point_at(_pest_tip(field_size), 0.5, bounds)
	else:
		cue.point_at(_bag_tip(field_size), 0.5, bounds)


func _bag_tip(field_size: Vector2) -> Vector2:
	var bag: Control = _owner.get("_seed_bag")
	if bag != null:
		var r := bag.get_rect()
		return Vector2(r.get_center().x, r.position.y + BAG_TIP_GAP)
	return Vector2(field_size.x * 0.5, field_size.y - 330.0)


func _pest_tip(field_size: Vector2) -> Vector2:
	var pest: Control = _owner.get("_pest")
	if pest != null:
		var c: Vector2 = pest.get("_pest_center")
		return pest.position + c + Vector2(0.0, PEST_TIP_GAP)
	return Vector2(field_size.x * 0.5, UiArena.NEST_Y + 60.0)


func _field_size() -> Vector2:
	var field := cue.get_parent() as Control
	return field.size if field else Vector2.ZERO


func _restore_tutorial() -> void:
	_message_tween = null
	_message_on = false
	cue.modulate.a = 1.0
	cue.visible = false
	set_tutorial_visible(_tutorial_on)


func _kill_message_tween() -> void:
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	_message_tween = null
