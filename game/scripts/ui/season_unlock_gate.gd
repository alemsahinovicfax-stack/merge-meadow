extends PanelContainer

## HOME-08 — coins + Seeds progress + Unlock inside the next-lock free card.

signal unlock_clicked

const CONTRAST := preload("res://scripts/ui/season_card_contrast.gd")

@onready var coins_label: Label = $UnlockGateVBox/UnlockGateCoins
@onready var t3_label: Label = $UnlockGateVBox/UnlockGateT3
@onready var coins_bar: ProgressBar = $UnlockGateVBox/UnlockGateCoinsBar
@onready var t3_bar: ProgressBar = $UnlockGateVBox/UnlockGateT3Bar
@onready var unlock_button: UiClickButton = $UnlockGateVBox/UnlockGateButton

var _season_id: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_apply_frame("")
	if coins_label:
		coins_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if t3_label:
		t3_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if coins_bar:
		coins_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if t3_bar:
		t3_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	var coins := GameState.wallet_coins
	var t3 := GameState.t3_flower_count()
	var coin_need := maxi(1, def.coins_cost)
	var t3_need := maxi(1, def.t3_flowers_required)
	if coins_label:
		coins_label.text = "Coins  %d / %d" % [coins, def.coins_cost]
	if t3_label:
		t3_label.text = "Seeds  %d / %d" % [t3, def.t3_flowers_required]
	if coins_bar:
		coins_bar.max_value = coin_need
		coins_bar.value = mini(coins, def.coins_cost)
	if t3_bar:
		t3_bar.max_value = t3_need
		t3_bar.value = mini(t3, def.t3_flowers_required)
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
	var ink := CONTRAST.text_color(season_id)
	if coins_label:
		coins_label.add_theme_color_override("font_color", ink)
	if t3_label:
		t3_label.add_theme_color_override("font_color", ink)
