extends PanelContainer

## HOME-08 / HOME-17 — unlock poster + Unlock inside the next-lock free card.

signal unlock_clicked

const CONTRAST := preload("res://scripts/ui/season_card_contrast.gd")

@onready var progress: Node = $UnlockGateVBox/UnlockProgress
@onready var unlock_button: UiClickButton = $UnlockGateVBox/UnlockGateButton

var _season_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_apply_frame("")
	if unlock_button:
		unlock_button.mouse_filter = Control.MOUSE_FILTER_STOP
		unlock_button.clicked.connect(_on_unlock_clicked)


func refresh_gate(hero_id: String, free_is_hero: bool) -> void:
	_season_id = hero_id
	var show := (
		free_is_hero
		and not hero_id.is_empty()
		and hero_id == GameState.next_locked_free_id()
		and GameState.is_free_selectable(hero_id)
		and not GameState.is_season_playable(hero_id)
	)
	visible = show
	if not show:
		return
	var def: SeasonDef = GameState.get_season_def(hero_id)
	if def == null:
		visible = false
		return
	if progress and progress.has_method("refresh"):
		progress.call("refresh", hero_id)
	var can := GameState.can_unlock_free(hero_id)
	if unlock_button:
		unlock_button.disabled = not can
		unlock_button.button_variant = "gold" if can else "subtle"
		unlock_button.mouse_filter = (
			Control.MOUSE_FILTER_STOP if can else Control.MOUSE_FILTER_IGNORE
		)
	_apply_frame(hero_id)


func _on_unlock_clicked() -> void:
	if _season_id.is_empty():
		return
	if not GameState.unlock_free(_season_id):
		refresh_gate(_season_id, GameState.home_band != "paid")
		return
	unlock_clicked.emit()
	for hub in get_tree().get_nodes_in_group("meta_hub"):
		if hub.has_method("refresh_top_bar"):
			hub.call("refresh_top_bar")


func _apply_frame(season_id: String) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0)
	box.set_border_width_all(0)
	box.set_content_margin_all(8)
	add_theme_stylebox_override("panel", box)
	if progress and progress.has_method("_apply_ink"):
		progress.call("_apply_ink", CONTRAST.text_color(season_id))
