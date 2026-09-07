extends PanelContainer

## Next locked free season — card tap navigates Home; Unlock spends after delay.

const CONTRAST := preload("res://scripts/ui/season_card_contrast.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")

const CARD_CORNER := 16
const CARD_MARGIN_X := 14.0
const CARD_MARGIN_Y := 12.0
const CARD_ALPHA := 0.98
const UNLOCK_DELAY_SEC := 0.4
const TITLE_FONT := 36

@onready var title_label: Label = $SeasonLinkVBox/SeasonLinkTitle
@onready var progress: Node = $SeasonLinkVBox/SeasonLinkInset/SeasonLinkInner/SeasonUnlockProgress
@onready var spacer: Control = $SeasonLinkVBox/SeasonLinkInset/SeasonLinkInner/SeasonLinkSpacer
@onready var unlock_button: UiClickButton = $SeasonLinkVBox/SeasonLinkInset/SeasonLinkInner/SeasonLinkUnlock

var _season_id: String = ""
var _pressing_card: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_stretch_ratio = 1.0
	_ignore_chrome()
	if title_label:
		title_label.add_theme_font_size_override("font_size", TITLE_FONT)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if unlock_button:
		unlock_button.clicked.connect(_on_unlock_clicked)


func refresh() -> void:
	var id := GameState.next_locked_free_id()
	_season_id = id
	if id.is_empty():
		visible = false
		return
	var def: SeasonDef = GameState.get_season_def(id)
	if def == null or not def.is_free():
		visible = false
		return
	visible = true
	if title_label:
		title_label.text = def.display_name
		title_label.add_theme_font_size_override("font_size", TITLE_FONT)
	if progress and progress.has_method("refresh"):
		progress.call("refresh", id)
	var can := GameState.can_unlock_free(id)
	if unlock_button:
		unlock_button.disabled = not can
		unlock_button.button_variant = "gold" if can else "subtle"
		unlock_button.mouse_filter = (
			Control.MOUSE_FILTER_STOP if can else Control.MOUSE_FILTER_IGNORE
		)
	_apply_tint(id)


func navigate_to_lock() -> void:
	_go_home(false)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if mb.pressed:
			_pressing_card = true
			accept_event()
		elif _pressing_card:
			_pressing_card = false
			accept_event()
			_go_home(false)
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_pressing_card = true
			accept_event()
		elif _pressing_card:
			_pressing_card = false
			accept_event()
			_go_home(false)


func _close_home_field() -> void:
	GameState.close_home_season_field()
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	for hub in tree.get_nodes_in_group("meta_hub"):
		var swipe: Node = hub.get_node_or_null("RootVBox/SwipePager")
		if swipe == null or not swipe.has_method("get_pages_host"):
			continue
		var host: Node = swipe.call("get_pages_host")
		if host == null:
			continue
		var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN)
		if home == null:
			continue
		var stage: Node = home.get_node_or_null("%SeasonStage")
		if stage != null and stage.has_method("close_season_field"):
			stage.call("close_season_field")


func _refresh_home_after_unlock() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	for hub in tree.get_nodes_in_group("meta_hub"):
		if hub.has_method("refresh_top_bar"):
			hub.call("refresh_top_bar")
		var swipe: Node = hub.get_node_or_null("RootVBox/SwipePager")
		if swipe == null or not swipe.has_method("get_pages_host"):
			continue
		var host: Node = swipe.call("get_pages_host")
		if host == null:
			continue
		var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN)
		if home != null and home.has_method("refresh_for_meta_hub"):
			home.call("refresh_for_meta_hub")


func _ignore_chrome() -> void:
	var vbox := get_node_or_null("SeasonLinkVBox") as Control
	if vbox:
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inset := get_node_or_null("SeasonLinkVBox/SeasonLinkInset") as Control
	if inset:
		inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var inner := get_node_or_null("SeasonLinkVBox/SeasonLinkInset/SeasonLinkInner") as Control
	if inner:
		inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if progress is Control:
		_ignore_tree(progress as Control)
	if title_label:
		title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if spacer:
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ignore_tree(n: Control) -> void:
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in n.get_children():
		if child is Control:
			_ignore_tree(child as Control)


func _apply_tint(season_id: String) -> void:
	var mood: Color = CONTRAST.mood_color(season_id)
	var bg: Color
	if CONTRAST.uses_dark_frame(season_id):
		bg = mood.darkened(0.18)
	else:
		bg = mood.lightened(0.20)
	bg.a = CARD_ALPHA
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(CARD_CORNER)
	box.content_margin_left = CARD_MARGIN_X
	box.content_margin_right = CARD_MARGIN_X
	box.content_margin_top = CARD_MARGIN_Y
	box.content_margin_bottom = CARD_MARGIN_Y
	box.set_border_width_all(2)
	box.border_color = CONTRAST.border_color(season_id)
	add_theme_stylebox_override("panel", box)
	var title_ink: Color = CONTRAST.title_color(season_id)
	if title_label:
		title_label.add_theme_color_override("font_color", title_ink)


func _go_home(spend_after_delay: bool) -> void:
	var id := GameState.next_locked_free_id()
	if id.is_empty():
		return
	GameState.set_free_strip_focus(id)
	GameState.set_home_band("free")
	_close_home_field()
	GameState.go_to_meta_page(MetaHubPages.MAIN)
	if not spend_after_delay:
		return
	await get_tree().create_timer(UNLOCK_DELAY_SEC).timeout
	if not is_inside_tree():
		return
	if not GameState.can_unlock_free(id):
		return
	if not GameState.unlock_free(id):
		return
	_refresh_home_after_unlock()


func _on_unlock_clicked() -> void:
	var id := GameState.next_locked_free_id()
	if id.is_empty():
		return
	_go_home(GameState.can_unlock_free(id))
