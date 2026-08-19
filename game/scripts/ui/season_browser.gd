extends Control

## Season catalog — free linear + paid IAP (SEZ-E).

signal unlock_requested(season_id: String)
signal season_selected(season_id: String)
signal closed

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

@onready var dim: Control = $Dim
@onready var close_button: UiClickButton = %BrowserCloseButton
@onready var free_row: HBoxContainer = %FreeRow
@onready var paid_row: HBoxContainer = %PaidRow


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_as_top_level(true)
	add_to_group(BLOCK_HUB_SWIPE_GROUP)
	_fit_viewport()
	var vp := get_viewport()
	if vp:
		vp.size_changed.connect(_fit_viewport)
	if dim:
		dim.gui_input.connect(_on_dim_gui_input)
	if close_button:
		close_button.clicked.connect(close)
	if not IAPManager.purchase_completed.is_connected(_on_purchase_completed):
		IAPManager.purchase_completed.connect(_on_purchase_completed)
		IAPManager.purchase_failed.connect(_on_purchase_failed)


func open_browser() -> void:
	_rebuild()
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func _fit_viewport() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var vr := vp.get_visible_rect()
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	global_position = vr.position
	set_deferred("size", vr.size)


func _rebuild() -> void:
	_clear_row(free_row)
	_clear_row(paid_row)
	for def in SeasonCatalog.free_defs_sorted():
		var playable := GameState.is_season_playable(def.id)
		var card := _make_free_card(def.display_name, playable)
		var sid := def.id
		if playable:
			card.clicked.connect(func() -> void: _on_free_unlocked_pressed(sid))
		else:
			card.clicked.connect(func() -> void: unlock_requested.emit(sid))
		free_row.add_child(card)
	for def in SeasonCatalog.paid_defs():
		var sku := def.iap_product_id
		var owned := IAPManager.owns_product(sku)
		var card := _make_paid_card(def.display_name, sku, owned)
		var sid := def.id
		if owned:
			card.clicked.connect(func() -> void: _on_paid_owned_pressed(sid))
		else:
			card.clicked.connect(func() -> void: _on_paid_buy_pressed(sku))
		paid_row.add_child(card)


func _make_free_card(title: String, unlocked: bool) -> UiClickButton:
	var btn := UiClickButton.new()
	btn.custom_minimum_size = Vector2(168, 120)
	btn.font_size = 20
	btn.label_autowrap = true
	if unlocked:
		btn.label_text = title
		btn.button_variant = "primary"
	else:
		btn.label_text = "🔒\n%s" % title
		btn.button_variant = "subtle"
	return btn


func _make_paid_card(title: String, sku: String, owned: bool) -> UiClickButton:
	var btn := UiClickButton.new()
	btn.custom_minimum_size = Vector2(168, 120)
	btn.font_size = 20
	btn.label_autowrap = true
	if owned:
		btn.label_text = "%s\nSelect" % title
		btn.button_variant = "primary"
	else:
		btn.label_text = "%s\n%s" % [title, IAPManager.get_price_label(sku)]
		btn.button_variant = "accent"
	btn.disabled = IAPManager.is_busy()
	return btn


func _on_free_unlocked_pressed(season_id: String) -> void:
	if GameState.set_active_season(season_id):
		season_selected.emit(season_id)
		close()


func _on_paid_owned_pressed(season_id: String) -> void:
	if GameState.set_active_season(season_id):
		season_selected.emit(season_id)
		close()


func _on_paid_buy_pressed(sku: String) -> void:
	IAPManager.purchase(sku)


func _on_purchase_completed(sku: String) -> void:
	if not CONFIG.is_season_sku(sku):
		if visible:
			_rebuild()
		return
	if visible:
		close()


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if visible:
		_rebuild()


func _clear_row(row: HBoxContainer) -> void:
	if row == null:
		return
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()


func _on_dim_gui_input(event: InputEvent) -> void:
	if _is_tap(event):
		close()


func _is_tap(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false
