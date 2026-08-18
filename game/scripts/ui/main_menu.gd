extends Control

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")

enum ChestUiState { LOCKED, READY, OPENING, CLAIMED }

@onready var tutorial_hint: Label = $Panel/VBox/TutorialHint
@onready var settings_button: UiClickButton = $SettingsButton
@onready var home_top_stack: VBoxContainer = %HomeTopStack
@onready var basket_card: PanelContainer = %BasketCard
@onready var basket_visual: Control = %BasketVisual
@onready var basket_title: Label = %BasketTitle
@onready var basket_caption: Label = %BasketCaption
@onready var play_button: UiClickButton = $Panel/VBox/PlayButton
@onready var endless_section: VBoxContainer = $Panel/VBox/EndlessSection
@onready var easy_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/EasyButton
@onready var normal_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/NormalButton
@onready var hard_button: UiClickButton = $Panel/VBox/EndlessSection/DifficultyRow/HardButton
@onready var endless_play_button: UiClickButton = $Panel/VBox/EndlessSection/EndlessPlayButton
@onready var daily_chest_card: PanelContainer = %DailyChestCard
@onready var daily_title: Label = %DailyTitle
@onready var daily_caption: Label = %DailyCaption
@onready var chest_visual: Control = %ChestVisual
@onready var reward_overlay: Control = %RewardOverlay
@onready var reward_title: Label = %RewardTitle
@onready var reward_body: Label = %RewardBody
@onready var reward_ok_button: UiClickButton = %RewardOkButton
@onready var basket_picker_overlay: Control = %BasketPickerOverlay
@onready var picker_list: VBoxContainer = %PickerList
@onready var picker_close_button: UiClickButton = %PickerCloseButton

var _chest_ui_state: ChestUiState = ChestUiState.LOCKED
var _chest_pulsing: bool = false
var _chest_pulse_t: float = 0.0
var _style_daily_ready: StyleBox = null
var _style_daily_claimed: StyleBox = null
var _basket_locked: bool = false


func _ready() -> void:
	play_button.clicked.connect(_on_play_pressed)
	easy_button.clicked.connect(_on_easy_pressed)
	normal_button.clicked.connect(_on_normal_pressed)
	hard_button.clicked.connect(_on_hard_pressed)
	endless_play_button.clicked.connect(_on_endless_play_pressed)
	if picker_close_button:
		picker_close_button.clicked.connect(_close_basket_picker)
	if basket_picker_overlay:
		var dim := basket_picker_overlay.get_node_or_null("Dim") as Control
		if dim:
			dim.gui_input.connect(_on_picker_dim_gui_input)
	if settings_button:
		settings_button.clicked.connect(_on_settings_pressed)
	if reward_ok_button:
		reward_ok_button.clicked.connect(_on_reward_ok_pressed)
	if daily_chest_card:
		daily_chest_card.gui_input.connect(_on_daily_chest_gui_input)
		daily_chest_card.resized.connect(_on_daily_chest_resized)
		_on_daily_chest_resized()
	if basket_card:
		basket_card.gui_input.connect(_on_basket_card_gui_input)
	_cache_daily_styles()
	_setup_typography()
	_setup_safe_area()
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _setup_typography() -> void:
	if daily_title:
		TEXT_LAYOUT.card_title_scroll(daily_title)
	if daily_caption:
		TEXT_LAYOUT.caption_label_scroll(daily_caption)
	if basket_title:
		TEXT_LAYOUT.card_title_scroll(basket_title)
	if basket_caption:
		TEXT_LAYOUT.caption_label_scroll(basket_caption)
	if reward_title:
		TEXT_LAYOUT.card_title_scroll(reward_title)
	if reward_body:
		TEXT_LAYOUT.body_label_scroll(reward_body)


func _setup_safe_area() -> void:
	if settings_button:
		SAFE_AREA.apply_top_margin(settings_button, 8.0)
		SAFE_AREA.apply_horizontal_margins(settings_button)
	if home_top_stack:
		SAFE_AREA.apply_top_margin(home_top_stack, 8.0)
		SAFE_AREA.apply_horizontal_margins(home_top_stack)


func _cache_daily_styles() -> void:
	if daily_chest_card == null:
		return
	var current := daily_chest_card.get_theme_stylebox("panel")
	if current:
		_style_daily_ready = current
		_style_daily_claimed = current.duplicate()
		if _style_daily_claimed is StyleBoxFlat:
			var claimed := _style_daily_claimed as StyleBoxFlat
			claimed.bg_color = Color(0.55, 0.62, 0.56, 0.72)
			claimed.border_color = Color(0.176, 0.204, 0.212, 0.18)
			claimed.set_border_width_all(2)


func _process(delta: float) -> void:
	if not _chest_pulsing or daily_chest_card == null:
		return
	_chest_pulse_t += delta
	var wave := 0.5 + 0.5 * sin(_chest_pulse_t * 2.2)
	daily_chest_card.modulate = Color.WHITE.lerp(Color(1.08, 1.04, 0.92), wave)


func _exit_tree() -> void:
	_stop_chest_pulse()


func _refresh_menu() -> void:
	var hub := GameState.tutorial_complete
	tutorial_hint.visible = not hub
	endless_section.visible = hub
	play_button.label_text = "Play"
	_refresh_difficulty_selection()
	_refresh_basket_card()


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


func _on_play_pressed() -> void:
	GameState.begin_campaign_run()
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_endless_play_pressed() -> void:
	GameState.begin_endless_run(GameState.endless_difficulty)
	SceneRouter.change_to(GameState.SCENE_RUN)


func _on_settings_pressed() -> void:
	if tutorial_hint:
		tutorial_hint.text = "Settings coming soon."
		tutorial_hint.visible = true


func _refresh_chest_card() -> void:
	if daily_chest_card == null:
		return
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if not GameState.tutorial_complete:
		_chest_ui_state = ChestUiState.LOCKED
		daily_chest_card.visible = false
		_stop_chest_pulse()
		return
	daily_chest_card.visible = true
	if GameState.can_claim_daily_chest():
		_chest_ui_state = ChestUiState.READY
		daily_title.text = "Daily gift"
		daily_caption.text = "Tap to open"
		if _style_daily_ready:
			daily_chest_card.add_theme_stylebox_override("panel", _style_daily_ready)
		if chest_visual:
			chest_visual.modulate = Color.WHITE
		_start_chest_pulse()
	else:
		_chest_ui_state = ChestUiState.CLAIMED
		daily_title.text = "Daily gift"
		daily_caption.text = "Back tomorrow"
		if _style_daily_claimed:
			daily_chest_card.add_theme_stylebox_override("panel", _style_daily_claimed)
		if chest_visual:
			chest_visual.modulate = Color(0.75, 0.75, 0.75, 1)
		_stop_chest_pulse()


func _start_chest_pulse() -> void:
	_chest_pulsing = true
	_chest_pulse_t = 0.0


func _stop_chest_pulse() -> void:
	_chest_pulsing = false
	_chest_pulse_t = 0.0
	if daily_chest_card:
		daily_chest_card.modulate = Color.WHITE


func _on_daily_chest_resized() -> void:
	if daily_chest_card:
		daily_chest_card.pivot_offset = daily_chest_card.size * 0.5


func _on_daily_chest_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	daily_chest_card.accept_event()
	_on_daily_chest_pressed()


func _on_daily_chest_pressed() -> void:
	if _chest_ui_state == ChestUiState.OPENING:
		return
	if _chest_ui_state == ChestUiState.LOCKED:
		return
	if _chest_ui_state == ChestUiState.CLAIMED:
		_show_reward_overlay(
			"Come back tomorrow",
			"Daily chest already opened today — come back tomorrow!"
		)
		return
	_chest_ui_state = ChestUiState.OPENING
	_stop_chest_pulse()
	var tw := create_tween()
	tw.tween_property(daily_chest_card, "scale", Vector2(1.05, 1.05), 0.15)
	tw.tween_property(daily_chest_card, "scale", Vector2.ONE, 0.2)
	tw.tween_callback(_finish_chest_claim)


func _finish_chest_claim() -> void:
	var msg := GameState.claim_daily_chest()
	_chest_ui_state = ChestUiState.CLAIMED
	_refresh_chest_card()
	_notify_hub_chrome()
	_show_reward_overlay("Daily gift!", msg)


func _notify_hub_chrome() -> void:
	if not GameState.meta_hub_active or not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


func _show_reward_overlay(title: String, body: String) -> void:
	if reward_overlay == null:
		return
	if reward_title:
		reward_title.text = title
	if reward_body:
		reward_body.text = body
	reward_overlay.visible = true


func _hide_reward_overlay() -> void:
	if reward_overlay:
		reward_overlay.visible = false


func _on_reward_ok_pressed() -> void:
	_hide_reward_overlay()


func set_meta_hub_mode(_enabled: bool) -> void:
	# Bug-022: Settings stays on Home (top-right) in hub mode.
	if settings_button:
		settings_button.visible = true


func refresh_for_meta_hub() -> void:
	_refresh_menu()
	_refresh_chest_card()
	_refresh_basket_card()


func _refresh_basket_card() -> void:
	if basket_card == null:
		return
	_basket_locked = not GameState.loadout_enabled()
	if _basket_locked:
		if basket_title:
			basket_title.text = "Basket"
		if basket_caption:
			basket_caption.text = "Unlock after first merge"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
		basket_card.modulate = Color(0.78, 0.78, 0.78, 1)
		return
	basket_card.modulate = Color.WHITE
	var type_id := GameState.get_loadout_type()
	if type_id.is_empty():
		if basket_title:
			basket_title.text = "Basket"
		if basket_caption:
			basket_caption.text = "Tap to choose"
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", "")
	else:
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		var stars := "★".repeat(GameState.get_seed_rarity(type_id))
		if basket_title:
			basket_title.text = name
		if basket_caption:
			basket_caption.text = "%s  (+%.0f%% spawn)" % [stars, GameState.LOADOUT_SPAWN_BONUS * 100.0]
		if basket_visual and basket_visual.has_method("set_loadout_type"):
			basket_visual.call("set_loadout_type", type_id)


func _on_basket_card_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	if basket_card:
		basket_card.accept_event()
	_on_basket_pressed()


func _on_basket_pressed() -> void:
	if _basket_locked or not GameState.loadout_enabled():
		if tutorial_hint:
			tutorial_hint.text = "Merge your first flower to unlock the basket."
			tutorial_hint.visible = true
		return
	_open_basket_picker()


func _on_picker_dim_gui_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if tapped:
		_close_basket_picker()


func _open_basket_picker() -> void:
	if basket_picker_overlay == null or picker_list == null:
		return
	_rebuild_picker_list()
	basket_picker_overlay.visible = true


func _close_basket_picker() -> void:
	if basket_picker_overlay:
		basket_picker_overlay.visible = false


func _rebuild_picker_list() -> void:
	if picker_list == null:
		return
	for child in picker_list.get_children():
		picker_list.remove_child(child)
		child.queue_free()
	var current := GameState.get_loadout_type()
	var clear_btn := UiClickButton.new()
	clear_btn.custom_minimum_size = Vector2(0, 56)
	clear_btn.font_size = 22
	clear_btn.label_text = "Clear basket"
	clear_btn.button_variant = "subtle"
	clear_btn.disabled = current.is_empty()
	clear_btn.clicked.connect(_on_basket_clear_picked)
	picker_list.add_child(clear_btn)
	for type_id in GameState.get_unlocked_loadout_types():
		var name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
		var stars := "★".repeat(GameState.get_seed_rarity(type_id))
		var row := UiClickButton.new()
		row.custom_minimum_size = Vector2(0, 56)
		row.font_size = 22
		row.label_text = "%s %s" % [name, stars]
		row.button_variant = "primary" if type_id == current else "subtle"
		row.clicked.connect(func() -> void: _on_basket_type_picked(type_id))
		picker_list.add_child(row)


func _on_basket_clear_picked() -> void:
	GameState.clear_loadout()
	_refresh_basket_card()
	_close_basket_picker()


func _on_basket_type_picked(type_id: String) -> void:
	if GameState.set_loadout(type_id):
		_refresh_basket_card()
		_close_basket_picker()
