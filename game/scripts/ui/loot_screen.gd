extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var loot_label: Label = $Panel/VBox/LootLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var double_button: UiClickButton = $Panel/VBox/DoubleButton
@onready var revive_button: UiClickButton = $Panel/VBox/ReviveButton
@onready var retry_button: UiClickButton = $Panel/VBox/RetryButton
@onready var camp_button: UiClickButton = $Panel/VBox/CampButton


func _ready() -> void:
	$Dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	double_button.clicked.connect(_on_double_pressed)
	revive_button.clicked.connect(_on_revive_pressed)
	retry_button.clicked.connect(_on_retry_pressed)
	camp_button.clicked.connect(_on_camp_pressed)
	_refresh_ui()


func _refresh_ui() -> void:
	if GameState.last_failed:
		title_label.text = "Run Failed"
		if not GameState.tutorial_complete and GameState.tutorial_step >= GameState.TutorialStep.RUN2:
			status_label.text = "Hit an obstacle? You keep half your seeds and coins."
		else:
			status_label.text = "You kept half of your seeds and coins."
	else:
		title_label.text = "Run Complete!"
		status_label.text = "Great run!"

	loot_label.text = GameState.format_loot_label()
	double_button.visible = GameState.show_rewarded_loot_buttons()
	revive_button.visible = (
		GameState.show_rewarded_loot_buttons()
		and GameState.last_failed
		and not GameState.revive_used_this_run
		and not GameState.loot_doubled
	)
	double_button.disabled = GameState.loot_doubled or not GameState.has_pending_loot()


func _on_double_pressed() -> void:
	if GameState.double_loot_placeholder():
		_refresh_ui()
		status_label.text = "Rewarded ad placeholder — coins and seeds doubled!"


func _on_revive_pressed() -> void:
	if GameState.request_revive():
		return
	status_label.text = "Revive not available."


func _on_retry_pressed() -> void:
	GameState.begin_fresh_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	GameState.go_to_camp()
