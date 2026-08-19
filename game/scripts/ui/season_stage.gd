extends Control

## Home Season Stage — playable swipe + next-free teaser (P11 sheet).

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const SWIPE_LOCK_PX := 20.0

@onready var active_card: PanelContainer = %ActiveCard
@onready var teaser_card: PanelContainer = %TeaserCard
@onready var stage_title: Label = %StageTitle
@onready var stage_tagline: Label = %StageTagline
@onready var stage_seeds: Label = %StageSeeds
@onready var stage_badge: Label = %StageBadge
@onready var teaser_title: Label = %TeaserTitle
@onready var teaser_hint: Label = %TeaserHint
@onready var browser: Control = %SeasonBrowser
@onready var unlock_sheet: Control = %SeasonUnlockSheet

var _pressing: bool = false
var _swiped: bool = false
var _press_start: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_to_group(BLOCK_HUB_SWIPE_GROUP)
	if active_card:
		active_card.gui_input.connect(_on_active_gui_input)
	if teaser_card:
		teaser_card.gui_input.connect(_on_teaser_gui_input)
	if browser:
		if browser.has_signal("unlock_requested"):
			browser.unlock_requested.connect(open_unlock_sheet)
		if browser.has_signal("season_selected"):
			browser.season_selected.connect(_on_browser_selected)
	if unlock_sheet and unlock_sheet.has_signal("unlocked"):
		unlock_sheet.unlocked.connect(_on_unlocked)
	refresh()


func refresh() -> void:
	var def: SeasonDef = GameState.get_season_def(GameState.active_season_id)
	if def == null:
		stage_title.text = "Season"
		stage_tagline.text = ""
		stage_seeds.text = ""
		stage_badge.text = ""
	else:
		stage_title.text = def.display_name
		stage_tagline.text = def.tagline
		var peek: Array[String] = []
		for i in mini(3, def.seed_type_ids.size()):
			peek.append(str(def.seed_type_ids[i]))
		stage_seeds.text = " · ".join(peek)
		stage_badge.text = "Free" if def.is_free() else "Owned"
		_apply_card_color(active_card, _mood_color(def.id), false)
	var next_id := GameState.next_locked_free_id()
	if next_id.is_empty():
		teaser_card.visible = false
	else:
		teaser_card.visible = true
		var next_def: SeasonDef = GameState.get_season_def(next_id)
		teaser_title.text = next_def.display_name if next_def else next_id
		teaser_hint.text = "🔒 Locked"
		_apply_card_color(teaser_card, _mood_color(next_id), true)


func cycle_playable(dir: int) -> void:
	if dir == 0:
		return
	var ids: Array[String] = GameState.list_playable_season_ids()
	if ids.size() < 2:
		return
	var idx := ids.find(GameState.active_season_id)
	if idx < 0:
		idx = 0
	var next_idx := posmod(idx + dir, ids.size())
	var next := ids[next_idx]
	if GameState.set_active_season(next):
		refresh()


func open_unlock_sheet(season_id: String) -> void:
	if unlock_sheet and unlock_sheet.has_method("open_unlock_sheet"):
		unlock_sheet.call("open_unlock_sheet", season_id)


func open_browser() -> void:
	if browser and browser.has_method("open_browser"):
		browser.call("open_browser")


func _on_browser_selected(_season_id: String) -> void:
	refresh()


func _on_unlocked(_season_id: String) -> void:
	refresh()
	if browser and browser.visible and browser.has_method("open_browser"):
		browser.call("open_browser")


func _on_active_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_begin_press(mb.position)
			active_card.accept_event()
		else:
			_end_press()
			active_card.accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_press(touch.position)
			active_card.accept_event()
		else:
			_end_press()
			active_card.accept_event()
	elif event is InputEventMouseMotion and _pressing:
		_update_press((event as InputEventMouseMotion).position)
		active_card.accept_event()
	elif event is InputEventScreenDrag and _pressing:
		_update_press((event as InputEventScreenDrag).position)
		active_card.accept_event()


func _on_teaser_gui_input(event: InputEvent) -> void:
	if not _is_tap(event):
		return
	teaser_card.accept_event()
	var next_id := GameState.next_locked_free_id()
	if not next_id.is_empty():
		open_unlock_sheet(next_id)


func _begin_press(pos: Vector2) -> void:
	_pressing = true
	_swiped = false
	_press_start = pos


func _update_press(pos: Vector2) -> void:
	if not _pressing or _swiped:
		return
	var dx := pos.x - _press_start.x
	if absf(dx) < SWIPE_LOCK_PX:
		return
	_swiped = true
	cycle_playable(-1 if dx < 0.0 else 1)


func _end_press() -> void:
	if _pressing and not _swiped:
		open_browser()
	_pressing = false
	_swiped = false


func _is_tap(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false


func _mood_color(season_id: String) -> Color:
	match season_id:
		"country_bloom":
			return Color("A8E6CF")
		"frost_orchard":
			return Color("C5D5E8")
		"lantern_meadow":
			return Color("C9B8E0")
		"moonlit_warren":
			return Color("3D3A6B")
		"coral_tide":
			return Color("E8A090")
		_:
			return Color("DDE8DC")


func _apply_card_color(card: PanelContainer, color: Color, locked: bool) -> void:
	if card == null:
		return
	var box := StyleBoxFlat.new()
	box.bg_color = color.darkened(0.25) if locked else color
	box.set_corner_radius_all(16)
	box.set_content_margin_all(12)
	if locked:
		box.bg_color.a = 0.72
	card.add_theme_stylebox_override("panel", box)
