class_name SeasonBrowser
extends Control

## Dock 1080 x 222 ispod kartice (SeasonStage.dc.html · SeasonBrowser):
## "Free path N / 4" + "Premium" i 8 tokena. Tap na token = skok na sezonu;
## horizontalni drag ide hub pageru (dock nije u block_hub_swipe grupi), pa
## token reaguje tek na otpustanje bez pomaka.

signal token_pressed(season_id: String)

const EDGE := Color(1.0, 0.973, 0.941, 0.55)

var _tokens: Dictionary = {}
var _free_ids: Array[String] = []
var _paid_ids: Array[String] = []
var _free_open: int = 0
var _press_id: String = ""
var _press_pos := Vector2.ZERO


func _init() -> void:
	name = "SeasonBrowser"
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = UiStage.DOCK.size
	custom_minimum_size = UiStage.DOCK.size


## status po id: HomeDockToken.S_* ; progress = next-lock bar 0..1.
func configure(
	free_ids: Array[String],
	paid_ids: Array[String],
	focus_id: String,
	active_id: String,
	status: Dictionary,
	progress: float,
	animated: bool = false
) -> void:
	_free_ids = free_ids
	_paid_ids = paid_ids
	_free_open = 0
	for id in free_ids:
		if str(status.get(id, "")) == HomeDockToken.S_OPEN:
			_free_open += 1
	var seen: Dictionary = {}
	_place_group(free_ids, "free", UiStage.DOCK_PAD, focus_id, active_id, status, progress, animated, seen)
	_place_group(paid_ids, "paid", paid_group_x(), focus_id, active_id, status, progress, animated, seen)
	for id in _tokens.keys():
		(_tokens[id] as Control).visible = seen.has(id)
	queue_redraw()


static func paid_group_x() -> float:
	return UiStage.DOCK_PAD + 4.0 * UiStage.TOKEN + 3.0 * UiStage.TOKEN_GAP + UiStage.GROUP_GAP


func _place_group(
	ids: Array[String],
	kind: String,
	x0: float,
	focus_id: String,
	active_id: String,
	status: Dictionary,
	progress: float,
	animated: bool,
	seen: Dictionary
) -> void:
	for i in ids.size():
		var id := ids[i]
		seen[id] = true
		var token := _token(id)
		var st := str(status.get(id, HomeDockToken.S_FAR))
		token.place(Vector2(x0 + float(i) * (UiStage.TOKEN + UiStage.TOKEN_GAP), UiStage.TOKEN_TOP))
		token.configure(kind, st, i + 1, id == active_id, id == focus_id, progress if st == HomeDockToken.S_NEXT else 0.0, animated)


func get_free_path_text() -> String:
	return "Free path %d / %d" % [_free_open, _free_ids.size()]


func get_token(season_id: String) -> HomeDockToken:
	return _tokens.get(season_id) as HomeDockToken


func shake_token(season_id: String) -> void:
	var token := get_token(season_id)
	if token:
		token.shake()


func token_at(local_pos: Vector2) -> String:
	for id in _tokens:
		var token := _tokens[id] as HomeDockToken
		if token.visible and Rect2(token.base_position, token.size).has_point(local_pos):
			return str(id)
	return ""


func _token(season_id: String) -> HomeDockToken:
	var token := _tokens.get(season_id) as HomeDockToken
	if token:
		return token
	token = HomeDockToken.new()
	token.name = "Token_%s" % season_id
	token.season_id = season_id
	add_child(token)
	_tokens[season_id] = token
	return token


func _gui_input(event: InputEvent) -> void:
	var pos := Vector2.ZERO
	var pressed := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		pos = mb.position
		pressed = mb.pressed
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		pos = st.position
		pressed = st.pressed
	else:
		return
	if pressed:
		_press_id = token_at(pos)
		_press_pos = pos
		return
	var id := _press_id
	_press_id = ""
	if id.is_empty() or pos.distance_to(_press_pos) > UiStage.TAP_SLOP:
		return
	if token_at(pos) == id:
		accept_event()
		token_pressed.emit(id)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, UiStage.CHROME)
	var edge := UiStage.over(UiStage.CHROME, EDGE)
	draw_rect(Rect2(0, 0, size.x, UiStage.DOCK_EDGE), edge)
	draw_rect(Rect2(0, size.y - UiStage.DOCK_EDGE, size.x, UiStage.DOCK_EDGE), edge)
	var f_label := UiStage.font(800, 38)
	var f_count := UiStage.font(900, 44)
	var above_label := f_label.get_ascent(38)
	var above_count := f_count.get_ascent(44)
	var above := maxf(above_label, above_count)
	var below := maxf(38.0 - above_label, 44.0 - above_count)
	var box_top := UiStage.DOCK_LABEL_TOP + (UiStage.DOCK_LABEL_H - above - below) * 0.5
	var base := box_top + above
	var x := UiStage.DOCK_PAD
	draw_string(f_label, Vector2(x, base), "Free path", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.CREAM)
	x += UiStage.text_w(f_label, 38, "Free path") + 14.0
	draw_string(f_count, Vector2(x, base), "%d / %d" % [_free_open, _free_ids.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 44, UiStage.COIN)
	var premium_x := paid_group_x()
	var premium_top := UiStage.DOCK_LABEL_TOP + (UiStage.DOCK_LABEL_H - 38.0) * 0.5
	draw_string(f_label, Vector2(premium_x, UiStage.baseline(f_label, 38, premium_top)), "Premium", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, UiStage.LAVENDER)
