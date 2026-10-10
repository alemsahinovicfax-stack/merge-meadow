class_name CampTradeBar
extends Control

## Trade bar (design_handoff_camp_v2 · TradeBar): odabrani tip i Trade dugme
## 300 x 120 s jednom rijecju (tap = 1, drzanje = 10/s), strip za rezervisano
## cvijece i "+N" pop. Bez podnaslova i bez "1 coin each" — cijena stoji na kartici.
## Drzanje se vidi: fill je prodani dio gomile, a svaki tik posalje novcic prema
## coin chipu u headeru. Stanje racuna kontroler.

const FEEDBACK_PX := 72
const FEEDBACK_COIN_PX := 65.0

@onready var panel: PanelContainer = $TradePanel
@onready var warning: PanelContainer = %ReservedWarning
@onready var warn_icon: TextureRect = %WarnIcon
@onready var warn_label: Label = %WarnLabel
@onready var art: CampArtFrame = %TradeArt
@onready var selected_label: Label = %SelectedLabel
@onready var button: CampButton = %ExchangeButton
@onready var feedback: PanelContainer = %TradeFeedback
@onready var feedback_label: Label = %FeedbackLabel
@onready var feedback_coin: TextureRect = %FeedbackCoin

var _state: String = UiCamp.TRADE_DISABLED
var _info: Dictionary = {}
var _gain: int = 0
var _hold_ticks: int = 0
var _switch_tween: Tween
var _fly_coins: Array[Control] = []
var _bump: Panel = null
var _bump_tween: Tween
var _feedback_tween: Tween
var _strip_tween: Tween
var _merge_row: HBoxContainer
var _merge_disc: PanelContainer
var _merge_icon: TextureRect
var _merge_label: Label
var _merge_text: String = ""
var _height_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiCamp.trade_bar_style())
	art.configure_frame(UiCamp.TRADE_ART, 22, 3, 0.0, 15, 2, UiCamp.TRADE_ART_SEED)
	for label in [selected_label, warn_label]:
		(label as Label).clip_text = true
		(label as Label).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		(label as Label).custom_minimum_size.x = 1.0
	warning.mouse_filter = Control.MOUSE_FILTER_IGNORE
	warn_icon.custom_minimum_size = Vector2(UiCamp.WARN_ICON, UiCamp.WARN_ICON)
	UiCamp.style_label(warn_label, UiCamp.FONT_WARN, UiCamp.INK)
	feedback.visible = false
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# C1 · leteća poruka sistema (design_handoff_popups): coin 65 + „+N" 72/900 zlatno s ink obrubom,
	# bez pilule; na otpuštanje odleti do coin chipa.
	feedback.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	feedback.custom_minimum_size.y = UiCamp.FEEDBACK_H
	feedback_label.add_theme_font_override("font", UiPopups.font(900, FEEDBACK_PX))
	feedback_label.add_theme_font_size_override("font_size", FEEDBACK_PX)
	feedback_label.add_theme_color_override("font_color", UiPopups.COIN_GOLD)
	feedback_label.add_theme_color_override("font_outline_color", UiPopups.OUTLINE)
	feedback_label.add_theme_constant_override("outline_size", UiPopups.POP_STROKE)
	feedback_coin.texture = UiAssets.get_chrome_icon("icon_coin")
	feedback_coin.custom_minimum_size = Vector2(FEEDBACK_COIN_PX, FEEDBACK_COIN_PX)
	feedback_coin.get_parent().move_child(feedback_coin, 0)
	button.custom_minimum_size = UiCamp.TRADE_BTN
	button.set_fonts(UiCamp.FONT_BTN)
	button.set_press_scale(0.97)
	button.clip_contents = true
	_build_merge_line()
	apply_state(UiCamp.TRADE_DISABLED, {})


func get_state() -> String:
	return _state


func get_warning_text() -> String:
	return warn_label.text if warning.visible else ""


func get_button_text() -> String:
	return button.get_title()


func get_selected_text() -> String:
	return selected_label.text


func get_merge_line() -> String:
	return _merge_text if _merge_row != null and _merge_row.visible else ""


func _build_merge_line() -> void:
	var box := panel.get_node_or_null("TradeVBox") as VBoxContainer
	if box == null:
		return
	box.add_theme_constant_override("separation", UiCamp.MERGE_LINE_GAP)
	_merge_row = HBoxContainer.new()
	_merge_row.name = "MergeableWarning"
	_merge_row.visible = false
	_merge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_merge_row.custom_minimum_size.y = UiCamp.MERGE_LINE_H
	_merge_row.add_theme_constant_override("separation", 14)
	box.add_child(_merge_row)
	_merge_disc = PanelContainer.new()
	_merge_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_merge_disc.custom_minimum_size = UiCamp.MERGE_MARK
	_merge_disc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_merge_row.add_child(_merge_disc)
	_merge_icon = TextureRect.new()
	_merge_icon.custom_minimum_size = Vector2(UiCamp.MERGE_LINE_ICON, UiCamp.MERGE_LINE_ICON)
	_merge_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_merge_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_merge_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_merge_icon.texture = UiAssets.get_camp_icon("icon_mergeable")
	_merge_disc.add_child(_merge_icon)
	_merge_label = Label.new()
	_merge_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_merge_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_merge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_merge_label.clip_text = true
	_merge_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_merge_row.add_child(_merge_label)
	UiCamp.style_label(_merge_label, 36, UiCamp.INK)


## Visina bara: pojava / nestanak linije (152 ↔ 212) ide glatko (T_MERGE_LINE 0,16 s);
## ostale promjene (strip rezervisanog) ostaju trenutne kao u v2.
func _set_bar_height(h: int) -> void:
	var target := float(h)
	if is_equal_approx(custom_minimum_size.y, target):
		return
	if _height_tween != null and _height_tween.is_valid():
		_height_tween.kill()
	var line_step := absf(custom_minimum_size.y - target) == float(UiCamp.MERGE_LINE_GAP + UiCamp.MERGE_LINE_H)
	if not is_inside_tree() or not line_step or GameState.reduce_motion:
		custom_minimum_size.y = target
		return
	_height_tween = create_tween()
	_height_tween.tween_property(self, "custom_minimum_size:y", target, UiCamp.T_MERGE_LINE) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _apply_merge_line(text: String) -> void:
	if _merge_row == null:
		return
	var show := not text.is_empty()
	_merge_row.visible = show
	if not show:
		_merge_text = ""
		return
	var count := int(_info.get("count", 0))
	_merge_disc.add_theme_stylebox_override("panel", UiCamp.merge_mark_style(count == UiCamp.MERGE_MIN))
	if text == _merge_text:
		return
	_merge_text = text
	_merge_label.text = text
	_merge_label.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_merge_label, "modulate:a", 1.0, 0.08)


## `info`: kind, type_id, label, rarity, price, need, season_name, left.
func apply_state(state: String, info: Dictionary) -> void:
	var prev := _state
	_state = state
	_info = info
	var seed := str(info.get("kind", "seed")) == "seed"
	var disabled := state == UiCamp.TRADE_DISABLED
	var merge_text := UiCamp.merge_line_text(int(info.get("count", 0))) if seed and not disabled else ""
	_set_bar_height(UiCamp.trade_height_v3(state, not merge_text.is_empty()))

	if disabled:
		# Bez imena i bez "Nothing selected" — prazan okvir sam kaze da nema sta prodati.
		selected_label.text = ""
		art.set_art(seed, "", 1)
		art.modulate.a = 0.9
	else:
		selected_label.text = str(info.get("label", ""))
		art.configure_frame(
			UiCamp.TRADE_ART, 24, 3, 0.0, 17, 2,
			UiCamp.TRADE_ART_SEED if seed else UiCamp.TRADE_ART_FLOWER
		)
		art.set_art(seed, str(info.get("type_id", "")), 1 if seed else 3)
		art.modulate.a = 1.0
	UiCamp.style_label(selected_label, UiCamp.FONT_TRADE_LABEL, UiCamp.INK)

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
	button.set_text(UiCamp.trade_button_text(state))
	button.set_ink(UiCamp.trade_button_ink(state))
	var icon_name := UiCamp.trade_button_icon(state)
	button.set_icon(_button_icon(icon_name), UiCamp.TRADE_BTN_ICON)
	button.disabled = disabled
	if stop and prev != UiCamp.TRADE_HOLD_STOP:
		button.set_hold_fill(button.get_hold_fill(), UiCamp.HOLD_FREEZE)
	elif state == UiCamp.TRADE_HOLD:
		button.set_hold_fill(button.get_hold_fill(), UiPalette.PEACH)
	elif prev == UiCamp.TRADE_HOLD:
		button.reset_hold_fill(UiCamp.T_HOLD_RESET)
	_apply_merge_line(merge_text)


## Jedan tik drzanja: fill je prodani dio gomile, a novcic odleti prema headeru.
func on_hold_tick(sold: int, sellable_left: int) -> void:
	_hold_ticks += 1
	button.set_hold_fill(UiCamp.hold_fill_ratio(sold, sellable_left), UiPalette.PEACH)
	_fly_coin()


## Tap (bez drzanja): fill kratko skoci pa se isprazni — prvi nagovjestaj da se drzi.
func on_tap_hint(sold: int, sellable_left: int) -> void:
	if _state == UiCamp.TRADE_HOLD_STOP:
		return
	button.set_hold_fill(UiCamp.hold_fill_ratio(sold, sellable_left), UiPalette.PEACH)
	button.reset_hold_fill(UiCamp.T_TAP_FILL_DRAIN)
	_fly_coin()


func on_press_ended() -> void:
	_hold_ticks = 0
	if _state != UiCamp.TRADE_HOLD_STOP:
		button.reset_hold_fill(UiCamp.T_HOLD_RESET)


## Auto prelaz na sljedeci tip kad se odabrani isprazni: novo ime se pojavi umjesto
## rečenice "empty — switched here".
func flash_switch() -> void:
	if not is_inside_tree():
		return
	if _switch_tween:
		_switch_tween.kill()
	selected_label.modulate.a = 0.0
	_switch_tween = create_tween()
	_switch_tween.tween_property(selected_label, "modulate:a", 1.0, UiCamp.T_AUTO_SWITCH) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Novcic 44 px odleti od dugmeta do coin chipa u headeru (max 3 ziva, bez cestica).
func _fly_coin() -> void:
	if not is_inside_tree() or _fly_coins.size() >= UiCamp.FLY_COIN_MAX:
		return
	var hub := _find_hub()
	if hub == null:
		return
	var chip := hub.get("coin_chip") as Control
	if chip == null or not is_instance_valid(chip):
		return
	var coin := TextureRect.new()
	coin.name = "FlyCoin"
	coin.texture = feedback_coin.texture
	coin.custom_minimum_size = Vector2(UiCamp.FLY_COIN, UiCamp.FLY_COIN)
	coin.size = coin.custom_minimum_size
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.top_level = true
	coin.z_index = 100
	coin.pivot_offset = coin.size * 0.5
	hub.add_child(coin)
	_fly_coins.append(coin)
	coin.global_position = button.global_position + button.size * 0.5 - coin.size * 0.5
	var to := chip.global_position + chip.size * 0.5 - coin.size * 0.5
	var tw := coin.create_tween()
	tw.set_parallel(true)
	tw.tween_property(coin, "global_position", to, UiCamp.T_FLY_COIN) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(coin, "scale", Vector2.ONE * 0.7, UiCamp.T_FLY_COIN)
	tw.chain().tween_callback(_on_fly_coin_arrived.bind(coin, chip))


func _on_fly_coin_arrived(coin: Control, chip: Control) -> void:
	_fly_coins.erase(coin)
	if is_instance_valid(coin):
		coin.queue_free()
	_bump_coin_chip(chip)


## Prsten preko coin chipa kad novcic stigne — put od dugmeta do brojaca se vidi.
func _bump_coin_chip(chip: Control) -> void:
	if chip == null or not is_instance_valid(chip) or not is_inside_tree():
		return
	var hub := _find_hub()
	if hub == null:
		return
	if _bump == null or not is_instance_valid(_bump):
		_bump = Panel.new()
		_bump.name = "CoinChipBump"
		_bump.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bump.add_theme_stylebox_override("panel", UiCamp.coin_bump_style())
		_bump.top_level = true
		_bump.z_index = 99
		hub.add_child(_bump)
	_bump.size = chip.size + Vector2(12, 12)
	_bump.global_position = chip.global_position - Vector2(6, 6)
	_bump.modulate.a = 0.0
	_bump.visible = true
	if _bump_tween and _bump_tween.is_valid():
		_bump_tween.kill()
	_bump_tween = _bump.create_tween()
	_bump_tween.tween_property(_bump, "modulate:a", 1.0, UiCamp.T_COIN_BUMP * 0.4)
	_bump_tween.tween_property(_bump, "modulate:a", 0.0, UiCamp.T_COIN_BUMP * 0.6)


func _button_icon(icon_name: String) -> Texture2D:
	if icon_name.is_empty():
		return null
	if icon_name == "icon_lock":
		return UiAssets.get_chrome_icon("icon_lock")
	return UiAssets.get_camp_icon(icon_name)


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
	var origin := (hub as Control).get_global_rect().position
	var from_c := from + feedback.size * 0.5 - origin
	var to_c := target.get_global_rect().get_center() - origin
	var fly := FloatPop.earn(hub, from_c, text, feedback_coin.texture, to_c, target)
	fly.name = "TradeFeedbackFly"
	fly.z_index = 100


func _find_hub() -> Node:
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	return hubs[0] if not hubs.is_empty() else null
