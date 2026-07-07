extends Control

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var tutorial_hint: Label = $Panel/VBox/TutorialHint
@onready var settings_button: UiClickButton = $SettingsButton
@onready var play_button: UiClickButton = $Panel/VBox/PlayButton
@onready var endless_section: VBoxContainer = $Panel/VBox/EndlessSection
@onready var easy_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/EasyButton
@onready var normal_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/NormalButton
@onready var hard_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/HardButton
@onready var endless_play_button: UiClickButton = $Panel/VBox/EndlessSection/EndlessPlayButton
@onready var camp_button: UiClickButton = $Panel/VBox/CampButton
@onready var shop_button: UiClickButton = $Panel/VBox/ShopButton


func _ready() -> void:
	play_button.clicked.connect(_on_play_pressed)
	easy_button.clicked.connect(_on_easy_pressed)
	normal_button.clicked.connect(_on_normal_pressed)
	hard_button.clicked.connect(_on_hard_pressed)
	endless_play_button.clicked.connect(_on_endless_play_pressed)
	camp_button.clicked.connect(_on_camp_pressed)
	shop_button.clicked.connect(_on_shop_pressed)
	_setup_safe_area()
	_refresh_menu()


func _setup_safe_area() -> void:
	if settings_button:
		SAFE_AREA.apply_top_margin(settings_button, 8.0)
		SAFE_AREA.apply_horizontal_margins(settings_button)


func _refresh_menu() -> void:
	var hub := GameState.tutorial_complete
	tutorial_hint.visible = not hub
	camp_button.visible = hub
	shop_button.visible = hub
	endless_section.visible = hub
	play_button.label_text = "Play"
	_refresh_difficulty_selection()


func _refresh_difficulty_selection() -> void:
	var selected := GameState.endless_difficulty
	easy_button.button_variant = "primary" if selected == GameState.EndlessDifficulty.EASY else "subtle"
	normal_button.button_variant = "primary" if selected == GameState.EndlessDifficulty.NORMAL else "subtle"
	hard_button.button_variant = "primary" if selected == GameState.EndlessDifficulty.HARD else "subtle"


func _select_difficulty(difficulty: int) -> void:
	GameState.endless_difficulty = difficulty
	GameState.save_player_save()
	_refresh_difficulty_selection()


func _on_easy_pressed() -> void:
	_select_difficulty(GameState.EndlessDifficulty.EASY)


func _on_normal_pressed() -> void:
	_select_difficulty(GameState.EndlessDifficulty.NORMAL)


func _on_hard_pressed() -> void:
	_select_difficulty(GameState.EndlessDifficulty.HARD)


func _on_shop_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_SHOP)


func _on_play_pressed() -> void:
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_endless_play_pressed() -> void:
	GameState.begin_endless_run(GameState.endless_difficulty)
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_CAMP)
