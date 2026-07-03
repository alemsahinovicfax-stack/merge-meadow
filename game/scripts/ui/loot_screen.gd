extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var loot_label: Label = $Panel/VBox/LootLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var double_button: Button = $Panel/VBox/DoubleButton
@onready var revive_button: Button = $Panel/VBox/ReviveButton
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var camp_button: Button = $Panel/VBox/CampButton


func _ready() -> void:
	double_button.pressed.connect(_on_double_pressed)
	revive_button.pressed.connect(_on_revive_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	camp_button.pressed.connect(_on_camp_pressed)
	_refresh_ui()


func _refresh_ui() -> void:
	if GameState.last_failed:
		title_label.text = "Run Failed"
		status_label.text = "You kept 50% of your orbs."
	else:
		title_label.text = "Run Complete!"
		status_label.text = "Great run!"

	loot_label.text = "+%d Orbs" % GameState.last_loot
	double_button.disabled = GameState.loot_doubled or GameState.last_loot <= 0
	revive_button.visible = GameState.last_failed
	revive_button.disabled = GameState.revive_used_this_run


func _on_double_pressed() -> void:
	if GameState.double_loot_placeholder():
		status_label.text = "Rewarded ad placeholder — loot doubled!"
		_refresh_ui()


func _on_revive_pressed() -> void:
	if GameState.revive_placeholder():
		status_label.text = "Rewarded revive placeholder — full loot restored!"
		_refresh_ui()


func _on_retry_pressed() -> void:
	GameState.go_to_scene(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	var deposited := GameState.deposit_loot_to_camp()
	if deposited == 0 and GameState.last_loot > 0:
		status_label.text = "Camp is full — go merge orbs first, then bring more."
		return
	GameState.go_to_scene(GameState.SCENE_CAMP)
