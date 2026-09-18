class_name CampTradeBar
extends Control

## Trade bar (design_handoff_camp · TradeBar): odabrani tip i cijena po komadu,
## Trade dugme (tap = 1, drzanje = 10/s), strip za rezervisano cvijece i "+N"
## pop koji na otpustanje leti do coin chipa u headeru. Stanje racuna kontroler.

const FILL_TICKS := 10

@onready var panel: PanelContainer = $TradePanel
@onready var warning: PanelContainer = %ReservedWarning
@onready var warn_icon: TextureRect = %WarnIcon
@onready var warn_label: Label = %WarnLabel
@onready var art: CampArtFrame = %TradeArt
@onready var selected_label: Label = %SelectedLabel
@onready var selected_value: PanelContainer = %SelectedValue
@onready var selected_value_label: Label = %SelectedValueLabel
@onready var button: CampButton = %ExchangeButton
@onready var feedback: PanelContainer = %TradeFeedback
@onready var feedback_label: Label = %FeedbackLabel
@onready var feedback_coin: TextureRect = %FeedbackCoin

var _state: String = UiCamp.TRADE_DISABLED
var _info: Dictionary = {}
var _gain: int = 0
var _hold_ticks: int = 0
var _switch_active: bool = false
var _switch_tween: Tween
var _feedback_tween: Tween
var _strip_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiCamp.trade_bar_style())
	art.configure_frame(UiCamp.TRADE_ART, 22, 3, 9.0, 15, 2, UiCamp.TRADE_ART_SEED)
	for label in [selected_label, selected_value_label, warn_label]:
		(label as Label).clip_text = true
		(label as Label).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		(label as Label).custom_minimum_size.x = 1.0
	selected_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected_value.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	warning.mouse_filter = Control.MOUSE_FILTER_IGNORE
	warn_icon.custom_minimum_size = Vector2(UiCamp.WARN_ICON, UiCamp.WARN_ICON)
	UiCamp.style_label(warn_label, UiCamp.FONT_WARN, UiCamp.INK)
	feedback.visible = false
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback.add_theme_stylebox_override("panel", UiCamp.feedback_style())
	feedback.custom_minimum_size.y = UiCamp.FEEDBACK_H
	UiCamp.style_label(feedback_label, UiCamp.FONT_FEEDBACK, UiCamp.INK)
	feedback_coin.texture = UiAssets.get_chrome_icon("icon_coin")
	feedback_coin.custom_minimum_size = Vector2(UiCamp.FEEDBACK_COIN, UiCamp.FEEDBACK_COIN)
	button.custom_minimum_size = UiCamp.TRADE_BTN
	button.set_press_scale(0.97)
	apply_state(UiCamp.TRADE_DISABLED, {})


func get_state() -> String:
	return _state


func get_warning_text() -> String:
	return warn_label.text if warning.visible else ""


func get_value_text() -> String:
	return selected_value_label.text


## `info`: kind, type_id, label, rarity, price, need, season_name, left.
func apply_state(state: String, info: Dictionary) -> void:
	var prev := _state
	_state = state
	_info = info
	var seed := str(info.get("kind", "seed")) == "seed"
	var disabled := state == UiCamp.TRADE_DISABLED
	custom_minimum_size.y = UiCamp.trade_height(state)

	if disabled:
		selected_label.text = "Nothing selected"
		art.set_art(seed, "", 1)
		art.modulate.a = 0.4
	else:
		selected_label.text = str(info.get("label", ""))
		art.configure_frame(
			UiCamp.TRADE_ART, 22, 3, 9.0, 15, 2,
			UiCamp.TRADE_ART_SEED if seed else UiCamp.TRADE_ART_FLOWER
		)
		art.set_art(seed, str(info.get("type_id", "")), 1 if seed else 3)
		art.modulate.a = 1.0
	UiCamp.style_label(
		selected_label, UiCamp.FONT_TRADE_LABEL, UiCamp.TRADE_DISABLED_INK if disabled else UiCamp.INK
	)
	_refresh_value()

	var stop := state == UiCamp.TRADE_HOLD_STOP
	var strip := stop or state == UiCamp.TRADE_WARN
	warning.visible = strip
	if strip:
		warning.add_theme_stylebox_override("panel", UiCamp.warn_strip_style(stop))
		warn_icon.texture = UiAssets.get_camp_icon("icon_hold_stop" if stop else "icon_reserved")
		warn_label.text = UiCamp.warn_strip_text(
			stop, str(info.get("season_name", "")), int(info.get("need", 0)), int(info.get("left", 0))
		)
		if prev != state:
			_play_strip_in()

	var style := UiCamp.trade_button_style(state)
	button.set_styles(style, style)
	var text := UiCamp.trade_button_text(state)
	button.set_text(text[0], text[1])
	button.set_ink(UiCamp.trade_button_ink(state))
	button.disabled = disabled
	if stop and prev != UiCamp.TRADE_HOLD_STOP:
		button.set_hold_fill(button.get_hold_fill(), UiCamp.HOLD_FREEZE)
	elif state == UiCamp.TRADE_HOLD:
		button.set_hold_fill(button.get_hold_fill(), UiPalette.PEACH)
	elif prev == UiCamp.TRADE_HOLD:
		button.reset_hold_fill(UiCamp.T_HOLD_RESET)


## Jedan auto-tik drzanja: fill napreduje 1/10 i krug se zatvara svake sekunde.
func on_hold_tick() -> void:
	_hold_ticks += 1
	var step := _hold_ticks % FILL_TICKS
	button.set_hold_fill(1.0 if step == 0 else float(step) / FILL_TICKS, UiPalette.PEACH)


func on_press_ended() -> void:
	_hold_ticks = 0
	if _state != UiCamp.TRADE_HOLD_STOP:
		button.reset_hold_fill(UiCamp.T_HOLD_RESET)


## Auto prelaz: mint plocica "empty — switched here" iza novog imena.
func flash_switch() -> void:
	_switch_active = true
	_refresh_value()
	if not is_inside_tree():
		return
	if _switch_tween:
		_switch_tween.kill()
	selected_value.modulate.a = 0.0
	_switch_tween = create_tween()
	_switch_tween.tween_property(selected_value, "modulate:a", 1.0, UiCamp.T_AUTO_SWITCH) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_switch_tween.tween_interval(UiCamp.T_AUTO_SWITCH_HOLD)
	_switch_tween.tween_property(selected_value, "modulate:a", 0.0, UiCamp.T_AUTO_SWITCH)
	_switch_tween.tween_callback(_end_switch)


func _end_switch() -> void:
	_switch_active = false
	_refresh_value()
	selected_value.modulate.a = 1.0


func _refresh_value() -> void:
	var disabled := _state == UiCamp.TRADE_DISABLED
	var rarity := int(_info.get("rarity", 1))
	var text := ""
	if disabled:
		text = "pick a type to trade"
	elif _switch_active:
		text = "empty — switched here"
	elif _state == UiCamp.TRADE_HOLD_STOP:
		var need := int(_info.get("need", 0))
		text = "%s · %d of %d kept" % [UiCamp.pips(rarity), need, need]
	else:
		text = UiCamp.trade_info_text(rarity, int(_info.get("price", 1)))
	selected_value_label.text = text
	var plate := _switch_active and not disabled
	selected_value.add_theme_stylebox_override(
		"panel", UiCamp.switch_plate_style() if plate else StyleBoxEmpty.new()
	)
	selected_value.size_flags_horizontal = (
		Control.SIZE_SHRINK_BEGIN if plate else Control.SIZE_EXPAND_FILL
	)
	var ink := UiCamp.INK if plate else (UiCamp.TRADE_DISABLED_INK if disabled else UiCamp.SUB_INK)
	UiCamp.style_label(selected_value_label, UiCamp.FONT_TRADE_SUB, ink, UiCamp.SEMI)


func _play_strip_in() -> void:
	if not is_inside_tree():
		return
	if _strip_tween:
		_strip_tween.kill()
	warning.modulate.a = 0.0
	_strip_tween = create_tween()
	_strip_tween.tween_property(warning, "modulate:a", 1.0, UiCamp.T_HOLD_STOP) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## "+N" raste dok traje pritisak (drzanje broji zbirno).
func add_gain(amount: int) -> void:
	if amount <= 0:
		return
	var first := _gain == 0
	_gain += amount
	feedback_label.text = "+%d" % _gain
	feedback.visible = true
	feedback.modulate.a = 1.0
	if first and is_inside_tree():
		if _feedback_tween:
			_feedback_tween.kill()
		feedback.pivot_offset = feedback.size * 0.5
		feedback.scale = Vector2.ONE * 0.7
		_feedback_tween = create_tween()
		_feedback_tween.tween_property(feedback, "scale", Vector2.ONE, UiCamp.T_TAP_POP) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func get_gain() -> int:
	return _gain


## Otpustanje: pop leti do coin chipa u headeru (u hubu), inace samo nestane.
func release_gain() -> void:
	if _gain <= 0:
		return
	var text := feedback_label.text
	_gain = 0
	var from := feedback.global_position
	feedback.visible = false
	if not is_inside_tree():
		return
	var hub := _find_hub()
	var target: Control = null
	if hub != null:
		target = hub.get("coin_chip") as Control
	if hub == null or target == null or not is_instance_valid(target):
		return
	var fly := PanelContainer.new()
	fly.name = "TradeFeedbackFly"
	fly.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fly.add_theme_stylebox_override("panel", UiCamp.feedback_style())
	fly.custom_minimum_size.y = UiCamp.FEEDBACK_H
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	fly.add_child(row)
	var label := Label.new()
	label.text = text
	UiCamp.style_label(label, UiCamp.FONT_FEEDBACK, UiCamp.INK)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	var coin := TextureRect.new()
	coin.texture = feedback_coin.texture
	coin.custom_minimum_size = feedback_coin.custom_minimum_size
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(coin)
	fly.top_level = true
	fly.z_index = 100
	hub.add_child(fly)
	fly.reset_size()
	fly.global_position = from
	fly.pivot_offset = fly.size * 0.5
	var to := target.global_position + target.size * 0.5 - fly.size * 0.5
	var tw := fly.create_tween()
	tw.set_parallel(true)
	tw.tween_property(fly, "global_position", to, UiCamp.T_TAP_FLY) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(fly, "scale", Vector2.ONE * 0.6, UiCamp.T_TAP_FLY)
	tw.tween_property(fly, "modulate:a", 0.0, UiCamp.T_TAP_FADE).set_delay(UiCamp.T_TAP_FLY - UiCamp.T_TAP_FADE)
	tw.chain().tween_callback(fly.queue_free)


func _find_hub() -> Node:
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	return hubs[0] if not hubs.is_empty() else null
