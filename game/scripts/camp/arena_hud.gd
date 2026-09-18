class_name ArenaHud
extends RefCounted

## Merge Arena HUD (smjer B, design_handoff_merge_arena): DailyTask pill, StashCounter,
## HintLine (fiksnih 128 px, max 2 reda), ComboMeter (pluta gore desno u Playfieldu) i
## TutorialCue iznad vrece. Layout ne skace kad se tekst ili combo promijene.

const DAILY_FONT_SIZE := 40
const STASH_FONT_SIZE := 48
const COMBO_FONT_SIZE := 46
const BONUS_FONT_SIZE := 40
const CUE_FONT_SIZE := 40
const CUE_MAX_W := 760.0
const CUE_BOTTOM := 330.0
const COMBO_IN_SEC := 0.2
const COMBO_OUT_SEC := 0.18
const STASH_PUNCH_SCALE := 1.16
const STASH_PUNCH_SEC := 0.18
const STRIKE_H := 3.0
const HINT_SIDE_MARGIN := 40.0

var daily_task: PanelContainer
var daily_icon: TextureRect
var daily_label: Label
var stash_counter: PanelContainer
var stash_icon: TextureRect
var stash_label: Label
var hint_pill: PanelContainer
var info_label: Label
var combo_meter: VBoxContainer
var combo_pill: PanelContainer
var combo_label: Label
var combo_bonus: PanelContainer
var bonus_label: Label
var tutorial_cue: VBoxContainer
var cue_label: Label
var cue_arrow: Control

var _owner: Control
var _strike: ColorRect
var _combo_tween: Tween = null
var _stash_tween: Tween = null
var _combo_shown: bool = false


func _init(owner: Control) -> void:
	_owner = owner
	var row := "RootVBox/ArenaHud/Row/"
	daily_task = owner.get_node(row + "DailyTask")
	daily_icon = owner.get_node(row + "DailyTask/HBox/DailyIcon")
	daily_label = owner.get_node(row + "DailyTask/HBox/DailyLabel")
	stash_counter = owner.get_node(row + "StashCounter")
	stash_icon = owner.get_node(row + "StashCounter/HBox/StashIcon")
	stash_label = owner.get_node(row + "StashCounter/HBox/StashLabel")
	hint_pill = owner.get_node("RootVBox/HintLine/HintPill")
	info_label = owner.get_node("RootVBox/HintLine/HintPill/InfoLabel")
	var field := "RootVBox/Playfield/"
	combo_meter = owner.get_node(field + "ComboMeter")
	combo_pill = owner.get_node(field + "ComboMeter/ComboPill")
	combo_label = owner.get_node(field + "ComboMeter/ComboPill/ComboLabel")
	combo_bonus = owner.get_node(field + "ComboMeter/ComboBonus")
	bonus_label = owner.get_node(field + "ComboMeter/ComboBonus/HBox/BonusLabel")
	tutorial_cue = owner.get_node(field + "TutorialCue")
	cue_label = owner.get_node(field + "TutorialCue/CuePanel/CueLabel")
	cue_arrow = owner.get_node(field + "TutorialCue/CueArrow")
	_style()


func set_hint(text: String) -> void:
	info_label.text = text
	var font := info_label.get_theme_font("font")
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, UiArena.HINT_FONT_SIZE).x
	var view_w := _owner.size.x if _owner.size.x > 1.0 else 1080.0
	var max_w := minf(float(UiArena.HINT_MAX_W), view_w - HINT_SIDE_MARGIN * 2.0) - UiArena.HINT_PAD_X * 2.0
	if width <= max_w:
		info_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		info_label.custom_minimum_size.x = ceilf(width)
	else:
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_label.custom_minimum_size.x = max_w


func get_hint() -> String:
	return info_label.text


func refresh_daily(text: String, done: bool) -> void:
	daily_label.text = text
	daily_task.add_theme_stylebox_override("panel", UiArena.hud_pill_style(done))
	daily_icon.texture = UiAssets.get_arena_icon("icon_check" if done else "icon_target")
	_strike.visible = done


func set_stash(value: int) -> void:
	stash_label.text = UiChrome.format_count(value)


func punch_stash() -> void:
	stash_counter.pivot_offset = stash_counter.size * 0.5
	if _stash_tween != null and _stash_tween.is_valid():
		_stash_tween.kill()
	stash_counter.scale = Vector2.ONE
	_stash_tween = _owner.create_tween()
	_stash_tween.tween_property(
		stash_counter, "scale", Vector2.ONE * STASH_PUNCH_SCALE, STASH_PUNCH_SEC * 0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_stash_tween.tween_property(stash_counter, "scale", Vector2.ONE, STASH_PUNCH_SEC * 0.6).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)


func get_stash_icon_center_global() -> Vector2:
	return stash_icon.get_global_rect().get_center()


## Combo od 2 navise; `bonus` > 0 dodaje red "+2" s coin ikonom (dodijeljeno na 5).
func show_combo(count: int, bonus: int) -> void:
	combo_label.text = "Combo %d" % count
	combo_pill.add_theme_stylebox_override("panel", UiArena.combo_style(count))
	combo_bonus.visible = bonus > 0
	bonus_label.text = "+%d" % bonus
	if _combo_shown:
		return
	_combo_shown = true
	_kill_combo_tween()
	combo_meter.visible = true
	combo_meter.pivot_offset = Vector2(combo_meter.size.x, 0.0)
	combo_meter.scale = Vector2.ONE * 0.6
	combo_meter.modulate.a = 0.0
	_combo_tween = _owner.create_tween().set_parallel(true)
	_combo_tween.tween_property(combo_meter, "scale", Vector2.ONE, COMBO_IN_SEC).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	_combo_tween.tween_property(combo_meter, "modulate:a", 1.0, COMBO_IN_SEC * 0.6)


func hide_combo() -> void:
	if not _combo_shown:
		return
	_combo_shown = false
	_kill_combo_tween()
	if not _owner.is_inside_tree():
		combo_meter.visible = false
		return
	_combo_tween = _owner.create_tween()
	_combo_tween.tween_property(combo_meter, "modulate:a", 0.0, COMBO_OUT_SEC).set_trans(Tween.TRANS_CUBIC)
	_combo_tween.tween_callback(combo_meter.hide)


func is_combo_shown() -> bool:
	return _combo_shown


func set_tutorial_visible(on: bool) -> void:
	tutorial_cue.visible = on


func layout_tutorial(field_size: Vector2) -> void:
	if field_size.x < 10.0:
		return
	cue_label.custom_minimum_size.x = minf(CUE_MAX_W - 64.0, field_size.x - 160.0)
	tutorial_cue.reset_size()
	var cue_size := tutorial_cue.get_combined_minimum_size()
	tutorial_cue.size = cue_size
	tutorial_cue.position = Vector2((field_size.x - cue_size.x) * 0.5, field_size.y - CUE_BOTTOM - cue_size.y)


func _style() -> void:
	_label(daily_label, DAILY_FONT_SIZE, UiPalette.OUTLINE)
	_strike = ColorRect.new()
	_strike.name = "Strike"
	_strike.color = UiPalette.OUTLINE
	_strike.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strike.anchor_right = 1.0
	_strike.anchor_top = 0.5
	_strike.anchor_bottom = 0.5
	_strike.offset_top = -STRIKE_H * 0.5
	_strike.offset_bottom = STRIKE_H * 0.5
	_strike.visible = false
	daily_label.add_child(_strike)
	daily_task.add_theme_stylebox_override("panel", UiArena.hud_pill_style(false))
	daily_icon.texture = UiAssets.get_arena_icon("icon_target")
	_label(stash_label, STASH_FONT_SIZE, UiPalette.OUTLINE)
	stash_counter.add_theme_stylebox_override("panel", UiArena.hud_pill_style(false, 20.0, 24.0))
	stash_icon.texture = UiAssets.get_arena_icon("icon_crystal")
	hint_pill.add_theme_stylebox_override("panel", UiArena.hint_pill_style())
	info_label.add_theme_font_size_override("font_size", UiArena.HINT_FONT_SIZE)
	info_label.add_theme_font_override("font", UiChrome.heavy_font(UiChrome.EMBOLDEN_700))
	info_label.add_theme_color_override("font_color", UiPalette.WARM_WHITE)
	_label(combo_label, COMBO_FONT_SIZE, UiPalette.OUTLINE)
	combo_pill.add_theme_stylebox_override("panel", UiArena.combo_style(2))
	_label(bonus_label, BONUS_FONT_SIZE, UiPalette.OUTLINE)
	combo_bonus.add_theme_stylebox_override("panel", UiArena.hud_pill_style(false, 20.0, 20.0))
	var coin := combo_bonus.get_node("HBox/CoinIcon") as TextureRect
	coin.texture = UiAssets.get_chrome_icon("icon_coin")
	_label(cue_label, CUE_FONT_SIZE, UiPalette.OUTLINE)
	(cue_label.get_parent() as PanelContainer).add_theme_stylebox_override("panel", UiArena.cue_style())
	cue_arrow.draw.connect(_draw_cue_arrow)


func _draw_cue_arrow() -> void:
	var w := cue_arrow.size.x
	var h := cue_arrow.size.y
	cue_arrow.draw_colored_polygon(
		PackedVector2Array([Vector2(0.0, 0.0), Vector2(w, 0.0), Vector2(w * 0.5, h)]), UiPalette.WARM_WHITE
	)


func _kill_combo_tween() -> void:
	if _combo_tween != null and _combo_tween.is_valid():
		_combo_tween.kill()


static func _label(label: Label, font_size: int, color: Color) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_font_override("font", UiChrome.heavy_font(UiChrome.EMBOLDEN_800))
	label.add_theme_color_override("font_color", color)
