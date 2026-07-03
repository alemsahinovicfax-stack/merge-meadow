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
	if tier == 0:
		_selected_slot = -1
		_refresh_ui()
		return

	if _selected_slot < 0:
		_selected_slot = index
	elif _selected_slot == index:
		_selected_slot = -1
	else:
		if GameState.try_merge_slots(_selected_slot, index):
			info_label.text = "Merged!"
		else:
			info_label.text = "Pick two matching orbs to merge."
		_selected_slot = -1

	_refresh_ui()


func _refresh_ui() -> void:
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

	magnet_label.text = "Magnet Lv %d / %d" % [GameState.magnet_level, GameState.MAGNET_MAX_LEVEL]
	magnet_button.text = "Upgrade Magnet (%d T2)" % GameState.MAGNET_COST_T2
	magnet_button.disabled = (
		GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
		or GameState.count_tier(2) < GameState.MAGNET_COST_T2
	)
	info_label.text = "Tap two matching orbs to merge (T1 + T1 → T2)."


func _on_magnet_pressed() -> void:
	if GameState.try_upgrade_magnet():
		info_label.text = "Magnet upgraded!"
	_refresh_ui()


func _on_play_pressed() -> void:
	GameState.go_to_scene(GameState.SCENE_RUN)
