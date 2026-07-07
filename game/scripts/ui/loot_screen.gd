extends Control

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

const COLOR_FAIL_TITLE := Color(1.0, 0.42, 0.38)
const COLOR_WIN_TITLE := Color(0.55, 0.98, 0.62)
const COLOR_FAIL_STATUS := Color(1.0, 0.78, 0.68)
const COLOR_WIN_STATUS := Color(0.82, 0.94, 0.86)
const COLOR_FAIL_ACCENT := Color(0.85, 0.22, 0.18, 0.95)
const COLOR_WIN_ACCENT := Color(0.22, 0.72, 0.38, 0.95)

@onready var outcome_accent: ColorRect = $Panel/VBox/OutcomeAccent
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
	AdManager.rewarded_completed.connect(_on_rewarded_completed)
	AdManager.rewarded_failed.connect(_on_rewarded_failed)
	_refresh_ui()


func _refresh_ui() -> void:
	var failed := GameState.last_failed
	if failed:
		title_label.text = "Run Failed"
		title_label.add_theme_color_override("font_color", COLOR_FAIL_TITLE)
		status_label.add_theme_color_override("font_color", COLOR_FAIL_STATUS)
		outcome_accent.color = COLOR_FAIL_ACCENT
		loot_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.55, 1))
		if not GameState.tutorial_complete and GameState.tutorial_step >= GameState.TutorialStep.RUN2:
			status_label.text = "Hit an obstacle? " + GameState.format_loot_outcome_detail()
		else:
			status_label.text = GameState.format_loot_outcome_detail()
	else:
		title_label.text = "Run Complete!"
		title_label.add_theme_color_override("font_color", COLOR_WIN_TITLE)
		status_label.add_theme_color_override("font_color", COLOR_WIN_STATUS)
		outcome_accent.color = COLOR_WIN_ACCENT
		loot_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 1))
		status_label.text = GameState.format_loot_outcome_detail()

	loot_label.text = GameState.format_loot_label()
	double_button.visible = GameState.show_rewarded_loot_buttons()
	revive_button.visible = (
		GameState.show_rewarded_loot_buttons()
		and GameState.last_failed
		and not GameState.revive_used_this_run
		and not GameState.loot_doubled
	)
	double_button.disabled = GameState.loot_doubled or not GameState.has_pending_loot() or not AdManager.can_request_rewarded()
	revive_button.disabled = not AdManager.can_request_rewarded()


func _on_double_pressed() -> void:
	if GameState.loot_doubled or not GameState.has_pending_loot():
		return
	status_label.text = _ad_status_text("Loading rewarded ad…")
	double_button.disabled = true
	revive_button.disabled = true
	AdManager.request_rewarded(CONFIG.PLACEMENT_DOUBLE_LOOT)


func _on_revive_pressed() -> void:
	if not revive_button.visible:
		return
	status_label.text = _ad_status_text("Loading rewarded ad…")
	double_button.disabled = true
	revive_button.disabled = true
	AdManager.request_rewarded(CONFIG.PLACEMENT_REVIVE)


func _on_rewarded_completed(placement: String) -> void:
	if placement == CONFIG.PLACEMENT_DOUBLE_LOOT:
		if GameState.double_loot_placeholder():
			status_label.text = _ad_status_text("Loot doubled!")
		else:
			status_label.text = "Could not double loot."
	elif placement == CONFIG.PLACEMENT_REVIVE:
		if GameState.request_revive():
			return
		status_label.text = "Revive not available."
	_refresh_ui()


func _on_rewarded_failed(_placement: String, _reason: String) -> void:
	status_label.text = "Ad not available — try again later."
	_refresh_ui()


func _ad_status_text(message: String) -> String:
	if AdManager.is_stub_mode():
		return "%s (test stub ~1s)" % message
	return message


func _on_retry_pressed() -> void:
	GameState.begin_fresh_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_camp_pressed() -> void:
	GameState.go_to_camp()
