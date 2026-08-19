extends Control

## Free-season gate overlay — coins + T3 check-only; no IAP.

signal unlocked(season_id: String)
signal closed

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"

@onready var dim: Control = $Dim
@onready var title_label: Label = %UnlockTitle
@onready var coins_label: Label = %UnlockCoins
@onready var t3_label: Label = %UnlockT3
@onready var unlock_button: UiClickButton = %UnlockButton
@onready var close_button: UiClickButton = %UnlockCloseButton

var _season_id: String = ""


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_as_top_level(true)
	add_to_group(BLOCK_HUB_SWIPE_GROUP)
	_fit_viewport()
	var vp := get_viewport()
	if vp:
		vp.size_changed.connect(_fit_viewport)
	if dim:
		dim.gui_input.connect(_on_dim_gui_input)
	if unlock_button:
		unlock_button.clicked.connect(_on_unlock_pressed)
	if close_button:
		close_button.clicked.connect(close)


func open_unlock_sheet(season_id: String) -> void:
	_season_id = season_id
	_refresh()
	visible = true


func close() -> void:
	visible = false
	_season_id = ""
	closed.emit()


func _fit_viewport() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var vr := vp.get_visible_rect()
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	global_position = vr.position
	set_deferred("size", vr.size)


func _refresh() -> void:
	var def: SeasonDef = GameState.get_season_def(_season_id)
	if def == null:
		title_label.text = "Unlock"
		coins_label.text = ""
		t3_label.text = ""
		if unlock_button:
			unlock_button.disabled = true
		return
	title_label.text = "Unlock %s" % def.display_name
	var coins := GameState.wallet_coins
	var t3 := GameState.t3_flower_count()
	coins_label.text = "Coins  %d / %d" % [coins, def.coins_cost]
	t3_label.text = "Flowers  %d / %d" % [t3, def.t3_flowers_required]
	if unlock_button:
		unlock_button.disabled = not GameState.can_unlock_free(_season_id)


func _on_unlock_pressed() -> void:
	if not GameState.unlock_free(_season_id):
		_refresh()
		return
	var unlocked_id := _season_id
	close()
	unlocked.emit(unlocked_id)
	for hub in get_tree().get_nodes_in_group("meta_hub"):
		if hub.has_method("refresh_top_bar"):
			hub.call("refresh_top_bar")


func _on_dim_gui_input(event: InputEvent) -> void:
	if _is_tap(event):
		close()


func _is_tap(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false
