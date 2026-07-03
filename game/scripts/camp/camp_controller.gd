extends Control

const TIER_COLORS: Dictionary = {
	0: Color(0.2, 0.22, 0.25, 0.5),
	1: Color(1.0, 0.85, 0.2, 1.0),
	2: Color(0.55, 0.85, 1.0, 1.0),
}

@onready var slots_grid: GridContainer = $Panel/VBox/SlotsGrid
@onready var info_label: Label = $Panel/VBox/InfoLabel
@onready var magnet_label: Label = $Panel/VBox/MagnetLabel
@onready var magnet_button: Button = $Panel/VBox/MagnetButton
@onready var play_button: Button = $Panel/VBox/PlayButton

var _selected_slot: int = -1
var _slot_buttons: Array[Button] = []


func _ready() -> void:
	magnet_button.pressed.connect(_on_magnet_pressed)
	play_button.pressed.connect(_on_play_pressed)
	_build_slots()
	_refresh_ui()


func _build_slots() -> void:
	for child in slots_grid.get_children():
		child.queue_free()
	_slot_buttons.clear()

	for i in GameState.CAMP_SLOT_COUNT:
		var button := Button.new()
		button.custom_minimum_size = Vector2(140, 140)
		button.focus_mode = Control.FOCUS_NONE
		var slot_index := i
		button.pressed.connect(func() -> void: _on_slot_pressed(slot_index))
		slots_grid.add_child(button)
		_slot_buttons.append(button)


func _on_slot_pressed(index: int) -> void:
	var tier := GameState.camp_slots[index]
	var status := ""

	if tier == 0:
		_selected_slot = -1
		status = "That slot is empty. Tap an orb to select it."
	elif _selected_slot < 0:
		_selected_slot = index
		status = "Selected T%d. Now tap another T%d to merge." % [tier, tier]
	elif _selected_slot == index:
		_selected_slot = -1
		status = "Deselected."
	else:
		if GameState.try_merge_slots(_selected_slot, index):
			status = "Merged into T%d!" % GameState.camp_slots[index]
		else:
			status = "No match — orbs must be the same tier."
		_selected_slot = -1

	_refresh_ui(status)


func _refresh_ui(status: String = "") -> void:
	for i in _slot_buttons.size():
		var tier := GameState.camp_slots[i]
		var button := _slot_buttons[i]
		var style := StyleBoxFlat.new()
		style.bg_color = TIER_COLORS.get(tier, TIER_COLORS[0])
		style.corner_radius_top_left = 16
		style.corner_radius_top_right = 16
		style.corner_radius_bottom_right = 16
		style.corner_radius_bottom_left = 16
		if i == _selected_slot:
			style.border_width_left = 4
			style.border_width_top = 4
			style.border_width_right = 4
			style.border_width_bottom = 4
			style.border_color = Color(1, 1, 1, 1)
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
		match tier:
			0:
				button.text = ""
			1:
				button.text = "T1"
			2:
				button.text = "T2"
			_:
				button.text = "?"

	var t1 := GameState.count_tier(1)
	var t2 := GameState.count_tier(2)
	magnet_label.text = "Magnet Lv %d / %d  (reach %dpx)   |   T1: %d   T2: %d" % [
		GameState.magnet_level, GameState.MAGNET_MAX_LEVEL,
		int(GameState.get_magnet_radius()), t1, t2
	]

	if GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL:
		magnet_button.text = "Magnet maxed out"
		magnet_button.disabled = true
	else:
		magnet_button.text = "Upgrade Magnet  (needs %d× T2)" % GameState.MAGNET_COST_T2
		magnet_button.disabled = t2 < GameState.MAGNET_COST_T2

	if status != "":
		info_label.text = status
	else:
		info_label.text = "Each run's orbs land here as T1. Tap two matching orbs to merge (T1+T1 = T2). Spend %d× T2 to upgrade the magnet (bigger pickup reach next run)." % GameState.MAGNET_COST_T2


func _on_magnet_pressed() -> void:
	if GameState.try_upgrade_magnet():
		info_label.text = "Magnet upgraded!"
	_refresh_ui()


func _on_play_pressed() -> void:
	GameState.go_to_scene(GameState.SCENE_RUN)
