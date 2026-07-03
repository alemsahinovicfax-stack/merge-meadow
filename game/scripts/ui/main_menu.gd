extends Control

@onready var tutorial_hint: Label = $Panel/VBox/TutorialHint
@onready var play_button: Button = $Panel/VBox/PlayButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	tutorial_hint.visible = not GameState.tutorial_seen


func _on_play_pressed() -> void:
	if not GameState.tutorial_seen:
		GameState.mark_tutorial_seen()
	GameState.go_to_scene(GameState.SCENE_RUN)
