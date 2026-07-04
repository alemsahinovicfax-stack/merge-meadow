extends Control

@onready var tutorial_hint: Label = $Panel/VBox/TutorialHint
@onready var play_button: UiClickButton = $Panel/VBox/PlayButton
@onready var camp_button: UiClickButton = $Panel/VBox/CampButton


func _ready() -> void:
	play_button.clicked.connect(_on_play_pressed)
	camp_button.clicked.connect(_on_camp_pressed)
	_refresh_menu()


func _refresh_menu() -> void:
	var hub := GameState.tutorial_complete
	tutorial_hint.visible = not hub
	camp_button.visible = hub


func _on_play_pressed() -> void:
	GameState.begin_fresh_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	GameState.apply_debug_resources()
	SceneRouter.change_to(GameState.SCENE_CAMP)
