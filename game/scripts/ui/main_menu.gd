extends Control

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var tutorial_hint: Label = $Panel/VBox/TutorialHint
@onready var settings_button: UiClickButton = $SettingsButton
@onready var play_button: UiClickButton = $Panel/VBox/PlayButton
@onready var camp_button: UiClickButton = $Panel/VBox/CampButton
@onready var shop_button: UiClickButton = $Panel/VBox/ShopButton


func _ready() -> void:
	play_button.clicked.connect(_on_play_pressed)
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


func _on_shop_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_SHOP)


func _on_play_pressed() -> void:
	GameState.begin_fresh_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	SceneRouter.change_to(GameState.SCENE_CAMP)
