extends Control

const MetaHubPagesScript := preload("res://scripts/meta/meta_hub_pages.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")

@onready var swipe_pager: Control = $RootVBox/SwipePager
@onready var top_bar: MarginContainer = $RootVBox/TopBar
@onready var coins_label: Label = $RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinsLabel
@onready var seeds_label: Label = $RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedsLabel
@onready var coin_icon: TextureRect = $RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinIcon
@onready var seed_icon: TextureRect = $RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedIcon
@onready var page_tabs: HBoxContainer = $RootVBox/PageIndicator/NavPanel/Margin/VBox/TabsRow
@onready var settings_button: UiClickButton = $RootVBox/TopBar/Panel/HBox/SettingsButton
@onready var nav_panel: PanelContainer = $RootVBox/PageIndicator/NavPanel

var _tab_buttons: Array[UiClickButton] = []
var _pages_loaded: Array[bool] = []
var _arena_page: Control = null
var _tabs_enabled: bool = true
var _nav_locked: bool = false
var _current_page: int = MetaHubPagesScript.MAIN


func _ready() -> void:
	add_to_group("meta_hub")
	GameState.meta_hub_active = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if settings_button:
		settings_button.clicked.connect(_on_settings_pressed)
	swipe_pager.page_changed.connect(_on_page_changed)
	_pages_loaded.resize(MetaHubPagesScript.PAGE_COUNT)
	for i in MetaHubPagesScript.PAGE_COUNT:
		_pages_loaded[i] = false
	_build_tabs()
	var start := GameState.meta_hub_pending_page
	if start < 0:
		start = MetaHubPagesScript.MAIN
	start = clampi(start, 0, MetaHubPagesScript.PAGE_COUNT - 1)
	GameState.meta_hub_pending_page = MetaHubPagesScript.MAIN
	swipe_pager.start_page = start
	swipe_pager.current_page = start
	call_deferred("_finish_boot", start)
	_setup_nav_bar()
	refresh_top_bar()


func _setup_nav_bar() -> void:
	if top_bar:
		SAFE_AREA.apply_top_margin(top_bar, 8.0)
		SAFE_AREA.apply_horizontal_margins(top_bar)
	if nav_panel:
		SAFE_AREA.apply_bottom_margin(nav_panel, 6.0)
	_setup_resource_icons()
	if coins_label:
		TEXT_LAYOUT.header_chip_count(coins_label)
	if seeds_label:
		TEXT_LAYOUT.header_chip_count(seeds_label)


func _setup_resource_icons() -> void:
	var coin_tex := PICKUP_ASSETS.get_coin_texture()
	if coin_icon and coin_tex:
		coin_icon.texture = coin_tex
	var seed_tex := PICKUP_ASSETS.get_seed_texture()
	if seed_icon and seed_tex:
		seed_icon.texture = seed_tex


func _finish_boot(start: int) -> void:
	var host: Control = swipe_pager.get_pages_host() as Control
	if host:
		_ensure_page_slots(host)
	_load_page(start)
	_load_neighbors(start)
	swipe_pager.go_to_page(start, false)
	_on_page_changed(start)
	_show_swipe_hint_if_needed()


func _ensure_page_slots(host: Control) -> void:
	while host.get_child_count() < MetaHubPagesScript.PAGE_COUNT:
		var slot_index := host.get_child_count()
		var slot := Control.new()
		slot.name = "PageSlot_%d" % slot_index
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(slot)


func go_to_page(index: int, animated: bool = true) -> void:
	index = clampi(index, 0, MetaHubPagesScript.PAGE_COUNT - 1)
	if _nav_locked and index != _current_page:
		return
	var host: Control = swipe_pager.get_pages_host() as Control
	if host:
		_ensure_page_slots(host)
	_load_page(index)
	_load_neighbors(index)
	swipe_pager.go_to_page(index, animated)


func set_swipe_enabled(enabled: bool) -> void:
	if swipe_pager:
		swipe_pager.set_swipe_enabled(enabled)


func set_tabs_enabled(enabled: bool) -> void:
	_tabs_enabled = enabled
	for tab in _tab_buttons:
		tab.disabled = not enabled


func set_nav_locked(locked: bool) -> void:
	if _nav_locked == locked:
		return
	_nav_locked = locked
	set_swipe_enabled(not locked)
	set_tabs_enabled(not locked)


func is_nav_locked() -> bool:
	return _nav_locked


func _on_page_changed(index: int) -> void:
	_current_page = index
	_load_neighbors(index)
	_update_tab_highlight(index)
	refresh_top_bar()
	_refresh_embedded_page(index)
	_notify_arena_page_active(index == MetaHubPagesScript.ARENA)


func _load_neighbors(index: int) -> void:
	_load_page(index)
	if index > 0:
		_load_page(index - 1)
	if index < MetaHubPagesScript.PAGE_COUNT - 1:
		_load_page(index + 1)


func _load_page(index: int) -> void:
	if index < 0 or index >= MetaHubPagesScript.PAGE_COUNT:
		return
	if _pages_loaded[index]:
		return
	var host: Control = swipe_pager.get_pages_host() as Control
	if host == null:
		return
	_ensure_page_slots(host)
	var scene_path: String = MetaHubPagesScript.PAGE_SCENES[index]
	if not ResourceLoader.exists(scene_path):
		push_error("MetaHub: missing page scene %s" % scene_path)
		return
	var slot := host.get_node_or_null("PageSlot_%d" % index)
	if slot:
		host.remove_child(slot)
		slot.queue_free()
	var packed: PackedScene = load(scene_path)
	var page := packed.instantiate() as Control
	page.name = "Page_%d" % index
	page.set_meta("meta_hub_embedded", true)
	page.set_anchors_preset(Control.PRESET_TOP_LEFT)
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(page)
	host.move_child(page, index)
	if swipe_pager.has_method("notify_pages_changed"):
		swipe_pager.notify_pages_changed()
	_pages_loaded[index] = true
	if index == MetaHubPagesScript.ARENA:
		_arena_page = page
		if page.has_method("set_arena_page_active"):
			page.call("set_arena_page_active", _current_page == MetaHubPagesScript.ARENA)
	_configure_embedded_page(page, index)


func _configure_embedded_page(page: Control, index: int) -> void:
	GameState.set_meta_hub_embedded(page, true)
	if page.has_method("set_meta_hub_mode"):
		page.set_meta_hub_mode(true)
	match index:
		MetaHubPagesScript.SHOP:
			_hide_node(page, "RootVBox/TopBar")
			_hide_node(page, "RootVBox/ResourceBar")
		MetaHubPagesScript.CAMP:
			_hide_node(page, "%HomeButton")
			_hide_node(page, "%SettingsButton")
			_hide_node(page, "%ResourceBar")
		MetaHubPagesScript.ARENA:
			_hide_node(page, "RootVBox/TopBar/BackButton")
		MetaHubPagesScript.COLLECTION:
			_hide_node(page, "RootVBox/TopBar/BackButton")


func _hide_node(root: Node, path: String) -> void:
	var node := root.get_node_or_null(path)
	if node:
		node.visible = false


func _refresh_embedded_page(index: int) -> void:
	var host: Control = swipe_pager.get_pages_host() as Control
	if host == null:
		return
	var page := host.get_node_or_null("Page_%d" % index) as Control
	if page == null:
		return
	if page.has_method("refresh_for_meta_hub"):
		page.refresh_for_meta_hub()
	elif page.has_method("_refresh_ui"):
		page.call("_refresh_ui")
	elif page.has_method("_refresh_menu"):
		page.call("_refresh_menu")


func _build_tabs() -> void:
	if page_tabs == null:
		return
	for child in page_tabs.get_children():
		child.queue_free()
	_tab_buttons.clear()
	for i in MetaHubPagesScript.PAGE_COUNT:
		var tab := UiClickButton.new()
		tab.label_text = MetaHubPagesScript.PAGE_LABELS[i]
		tab.font_size = 17
		tab.button_variant = "subtle"
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.clicked.connect(_on_tab_pressed.bind(i))
		page_tabs.add_child(tab)
		_tab_buttons.append(tab)


func _on_tab_pressed(index: int) -> void:
	if not _tabs_enabled:
		return
	go_to_page(index)


func _notify_arena_page_active(active: bool) -> void:
	if _arena_page == null:
		var host: Control = swipe_pager.get_pages_host() as Control if swipe_pager else null
		if host:
			_arena_page = host.get_node_or_null("Page_%d" % MetaHubPagesScript.ARENA) as Control
	if _arena_page and _arena_page.has_method("set_arena_page_active"):
		_arena_page.call("set_arena_page_active", active)


func _exit_tree() -> void:
	set_nav_locked(false)
	GameState.meta_hub_active = false


func _update_tab_highlight(index: int) -> void:
	for i in _tab_buttons.size():
		var tab := _tab_buttons[i]
		tab.button_variant = "primary" if i == index else "subtle"


func refresh_top_bar() -> void:
	if coins_label:
		coins_label.text = str(GameState.wallet_coins)
		TEXT_LAYOUT.ink(coins_label)
	if seeds_label:
		seeds_label.text = str(GameState.sum_seed_bag_only())
		TEXT_LAYOUT.ink(seeds_label)


func _show_swipe_hint_if_needed() -> void:
	# Bug-019: caption removed; tab labels already name each page.
	pass


func _on_settings_pressed() -> void:
	# Placeholder — Settings screen in D0-P (no caption toast).
	pass
