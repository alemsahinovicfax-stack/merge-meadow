extends Control

const MetaHubPagesScript := preload("res://scripts/meta/meta_hub_pages.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")
const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")

## Settings ekran je D0-P — do tada kratka poruka ispod headera (kao ranije na Home).
const SETTINGS_TOAST_TEXT := UiPopups.S_SETTINGS_SOON
const SETTINGS_TOAST_HOLD := 1.6  # s
const SETTINGS_TOAST_GAP := 24.0  # px ispod headera
const COIN_POP_POS := Vector2(150, 132)  # design_handoff_shop · CoinSpendPop

@onready var swipe_pager: SwipePager = $RootVBox/SwipePager
@onready var top_bar: MarginContainer = $RootVBox/TopBar
@onready var top_bar_panel: PanelContainer = $RootVBox/TopBar/Panel
@onready var coin_chip: PanelContainer = $RootVBox/TopBar/Panel/HBox/CoinChip
@onready var seed_chip: PanelContainer = $RootVBox/TopBar/Panel/HBox/SeedChip
@onready var flower_chip: PanelContainer = $RootVBox/TopBar/Panel/HBox/FlowerChip
@onready var coins_label: Label = $RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinsLabel
@onready var seeds_label: Label = $RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedsLabel
@onready var flowers_label: Label = $RootVBox/TopBar/Panel/HBox/FlowerChip/HBox/FlowersLabel
@onready var coin_icon: TextureRect = $RootVBox/TopBar/Panel/HBox/CoinChip/HBox/CoinIcon
@onready var seed_icon: TextureRect = $RootVBox/TopBar/Panel/HBox/SeedChip/HBox/SeedIcon
@onready var flower_icon: TextureRect = $RootVBox/TopBar/Panel/HBox/FlowerChip/HBox/FlowerIcon
@onready var settings_button: HubIconButton = $RootVBox/TopBar/Panel/HBox/SettingsButton
@onready var nav_panel: PanelContainer = $RootVBox/PageIndicator/NavPanel
@onready var page_tabs: HBoxContainer = $RootVBox/PageIndicator/NavPanel/Content/TabsRow
@onready var active_indicator: Panel = $RootVBox/PageIndicator/NavPanel/Content/ActiveIndicator
@onready var nav_lock_pill: PanelContainer = $RootVBox/PageIndicator/NavPanel/Content/NavLockPill
@onready var nav_lock_icon: TextureRect = $RootVBox/PageIndicator/NavPanel/Content/NavLockPill/HBox/LockIcon
@onready var nav_lock_label: Label = $RootVBox/PageIndicator/NavPanel/Content/NavLockPill/HBox/LockLabel

var _tabs: Array[HubTab] = []
var _pages_loaded: Array[bool] = []
## Stranice koje se učitavaju u pozadinskom threadu (perf 2026-10-09): lijeno učitavanje susjeda
## padalo je usred swipea (Shop hladno ~0,8 s, toplo ~48 ms), a sve odjednom na otvaranju huba
## produžava start za 1–2 s. Zato: početna + susjedi odmah, ostale preko load_threaded_request,
## a instancira se po jedna, kad je gotova i kad pager stoji.
var _bg_pages: Array[int] = []
var _arena_page: Control = null
var _tabs_enabled: bool = true
var _nav_locked: bool = false
var _current_page: int = MetaHubPagesScript.MAIN
var _safe_insets: Vector4 = Vector4.ZERO
var _settings_toast: PopupToast = null


func _ready() -> void:
	add_to_group("meta_hub")
	if OS.is_debug_build() and not GameState.skip_debug_season_unlock:
		GameState.debug_playtest_two_free()
	GameState.meta_hub_active = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_setup_chrome()
	refresh_top_bar()


func _process(_delta: float) -> void:
	_sync_active_indicator()
	_poll_background_pages()


func _queue_background_pages() -> void:
	for i in MetaHubPagesScript.PAGE_COUNT:
		if _pages_loaded[i] or _bg_pages.has(i):
			continue
		var path: String = MetaHubPagesScript.PAGE_SCENES[i]
		if ResourceLoader.exists(path) and ResourceLoader.load_threaded_request(path) == OK:
			_bg_pages.append(i)


## Jedna gotova stranica po frejmu, samo dok pager stoji (ne usred swipea).
func _poll_background_pages() -> void:
	if _bg_pages.is_empty() or swipe_pager == null or swipe_pager.is_moving():
		return
	for i in _bg_pages:
		var path: String = MetaHubPagesScript.PAGE_SCENES[i]
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		if status == ResourceLoader.THREAD_LOAD_LOADED and not _pages_loaded[i]:
			_load_page(i)
			_apply_page_activity(_current_page)
		else:
			_bg_pages.erase(i)
		return


func _setup_chrome() -> void:
	_safe_insets = SAFE_AREA.get_insets(get_viewport())
	top_bar_panel.add_theme_stylebox_override("panel", _header_style())
	_setup_chip(coin_chip, coin_icon, coins_label)
	_setup_chip(seed_chip, seed_icon, seeds_label)
	_setup_chip(flower_chip, flower_icon, flowers_label)
	_setup_resource_icons()
	settings_button.set_icon(UI_ASSETS.get_chrome_icon("icon_settings_light"))
	settings_button.clicked.connect(_on_settings_pressed)
	_setup_nav_lock_pill()
	_apply_nav_lock_visuals()


func _setup_chip(chip: PanelContainer, icon: TextureRect, label: Label) -> void:
	chip.add_theme_stylebox_override("panel", UiChrome.chip_style())
	chip.custom_minimum_size.y = UiChrome.CHIP_H
	icon.custom_minimum_size = Vector2(UiChrome.CHIP_ICON_SIZE, UiChrome.CHIP_ICON_SIZE)
	TEXT_LAYOUT.header_chip_count(label)


## Ikone valuta iz CD-a (v2: u boji, nikad tintane); pickup sprite je fallback ako
## import fali (greske-katalog #6).
func _setup_resource_icons() -> void:
	coin_icon.texture = _chrome_icon_or("icon_coin", PICKUP_ASSETS.get_coin_texture())
	seed_icon.texture = _chrome_icon_or("icon_seed", PICKUP_ASSETS.get_seed_texture())
	flower_icon.texture = UI_ASSETS.get_chrome_icon("icon_flower")


func _chrome_icon_or(icon_name: String, fallback: Texture2D) -> Texture2D:
	var tex := UI_ASSETS.get_chrome_icon(icon_name)
	return tex if tex != null else fallback


## X3 · „Round in progress" (design_handoff_popups): ink pilula s kremastim rubom (tokeni toasta),
## isto mjesto i mjere kao chrome v2; tekst više nije velikim slovima.
func _setup_nav_lock_pill() -> void:
	var sb := UiPopups.nav_lock_pill()
	sb.content_margin_left = 22.0
	sb.content_margin_right = 26.0
	nav_lock_pill.add_theme_stylebox_override("panel", sb)
	nav_lock_icon.custom_minimum_size = Vector2(UiChrome.LOCK_ICON_SIZE, UiChrome.LOCK_ICON_SIZE)
	nav_lock_icon.texture = UI_ASSETS.get_chrome_icon("icon_lock")
	nav_lock_label.text = UiPopups.S_ROUND_IN_PROGRESS
	nav_lock_label.add_theme_font_size_override("font_size", UiChrome.LOCK_FONT_SIZE)
	nav_lock_label.add_theme_font_override("font", UiPopups.font(900, UiChrome.LOCK_FONT_SIZE))
	nav_lock_label.add_theme_color_override("font_color", UiPopups.WARM_WHITE)


## Traka se produžava u safe area (notch gore, gesture bar dolje) — bez tamne "rupe".
func _header_style() -> StyleBoxFlat:
	var style := UiChrome.chrome_style(true)
	style.content_margin_top = _safe_insets.x
	style.content_margin_left = UiChrome.HEADER_PAD_LEFT + _safe_insets.w
	style.content_margin_right = _safe_insets.y
	return style


func _footer_style(locked: bool) -> StyleBoxFlat:
	var style := UiChrome.chrome_style(false, locked)
	style.content_margin_left = _safe_insets.w
	style.content_margin_right = _safe_insets.y
	style.content_margin_bottom = _safe_insets.z
	return style


func _finish_boot(start: int) -> void:
	var host: Control = swipe_pager.get_pages_host() as Control
	if host:
		_ensure_page_slots(host)
	_load_page(start)
	_load_neighbors(start)
	# Frejm kasnije: početna stranica je već nacrtala svoje cvijeće (sinhrono). Cvijeće ostalih
	# sezona ide u red threadova PRIJE Shopa i Arene — red je FIFO, a kartica koja traži teksturu
	# iz reda čeka sve ispred nje (Arena ~650 ms u probi 2026-10-10).
	get_tree().process_frame.connect(func() -> void:
		FlowerAssets.prefetch_rosters()
		_queue_background_pages()
	, CONNECT_ONE_SHOT)
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
	for tab in _tabs:
		tab.disabled = not enabled


func set_nav_locked(locked: bool) -> void:
	if _nav_locked == locked:
		return
	_nav_locked = locked
	set_swipe_enabled(not locked)
	set_tabs_enabled(not locked)
	_apply_nav_lock_visuals()


func is_nav_locked() -> bool:
	return _nav_locked


func current_page_index() -> int:
	return _current_page


func _on_page_changed(index: int) -> void:
	if _current_page == MetaHubPagesScript.COLLECTION and index != MetaHubPagesScript.COLLECTION:
		_notify_journal_left()
	_current_page = index
	_load_neighbors(index)
	_update_tab_highlight(index)
	refresh_top_bar()
	_refresh_embedded_page(index)
	# Journal briše "novo" tek u refresh_for_meta_hub, pa badge ide poslije.
	_refresh_tab_badges()
	_notify_arena_page_active(index == MetaHubPagesScript.ARENA)


func _load_neighbors(index: int) -> void:
	_load_page(index)
	if index > 0:
		_load_page(index - 1)
	if index < MetaHubPagesScript.PAGE_COUNT - 1:
		_load_page(index + 1)
	_apply_page_activity(index)


## Stranice van ekrana ne vrte _process ni tweenove (Home ambijent, njihanje cvijeća, Pip,
## Journal…): učitane ostaju žive, a inače ih je plaćala i stranica na kojoj igrač jeste
## (perf 2026-10-09: Arena je štekala dok je Home iza nje animirao). Arena ima svoj
## set_arena_page_active (sesija, nav lock), pa je ovdje preskočena.
func _apply_page_activity(index: int) -> void:
	var host: Control = swipe_pager.get_pages_host() as Control if swipe_pager else null
	if host == null:
		return
	for i in MetaHubPagesScript.PAGE_COUNT:
		if i == MetaHubPagesScript.ARENA:
			continue
		var page := host.get_node_or_null("Page_%d" % i)
		if page != null:
			page.process_mode = Node.PROCESS_MODE_INHERIT if i == index else Node.PROCESS_MODE_DISABLED


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
	var packed: PackedScene = null
	if _bg_pages.has(index):
		# Već se učitava u pozadini — preuzmi (čeka samo ono što još nije gotovo).
		_bg_pages.erase(index)
		packed = ResourceLoader.load_threaded_get(scene_path) as PackedScene
	if packed == null:
		packed = load(scene_path)
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
			pass  # Shop (2026-09-23) nema svoj TopBar ni ResourceBar — valute su u hubu
		MetaHubPagesScript.CAMP:
			_hide_node(page, "%HomeButton")
			_hide_node(page, "%SettingsButton")
			_hide_node(page, "%ResourceBar")
		MetaHubPagesScript.ARENA:
			_hide_node(page, "RootVBox/TopBar/BackButton")
		MetaHubPagesScript.COLLECTION:
			_hide_node(page, "%BackButton")


func _hide_node(root: Node, path: String) -> void:
	var node := root.get_node_or_null(path)
	if node:
		node.visible = false


func _notify_journal_left() -> void:
	var host: Control = swipe_pager.get_pages_host() as Control if swipe_pager else null
	if host == null:
		return
	var page := host.get_node_or_null("Page_%d" % MetaHubPagesScript.COLLECTION)
	if page != null and page.has_method("on_meta_page_left"):
		page.call("on_meta_page_left")


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
	_tabs.clear()
	for i in MetaHubPagesScript.PAGE_COUNT:
		var label_text: String = MetaHubPagesScript.PAGE_LABELS[i]
		var icon_name: String = MetaHubPagesScript.PAGE_ICONS[i]
		var tab := HubTab.new()
		tab.name = "Tab_%s" % label_text
		tab.setup(
			label_text,
			UI_ASSETS.get_chrome_icon(icon_name),
			UI_ASSETS.get_chrome_icon(icon_name + "_light")
		)
		tab.clicked.connect(_on_tab_pressed.bind(i))
		page_tabs.add_child(tab)
		_tabs.append(tab)


func _on_tab_pressed(index: int) -> void:
	if not _tabs_enabled:
		return
	go_to_page(index)


func _on_settings_pressed() -> void:
	_show_settings_toast()


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
	for i in _tabs.size():
		_tabs[i].set_active(i == index)
	_apply_tab_dim()


## Zaključano (Arena sesija): gold rub, NavLockPill, neaktivni tabovi 60 %; aktivan ostaje pun peach.
func _apply_nav_lock_visuals() -> void:
	nav_panel.add_theme_stylebox_override("panel", _footer_style(_nav_locked))
	active_indicator.add_theme_stylebox_override("panel", UiChrome.indicator_style(_nav_locked))
	nav_lock_pill.visible = _nav_locked
	if _nav_locked:
		_layout_nav_lock_pill()
	_apply_tab_dim()


func _apply_tab_dim() -> void:
	for i in _tabs.size():
		var dim := _nav_locked and i != _current_page
		_tabs[i].modulate.a = UiChrome.LOCKED_TAB_ALPHA if dim else 1.0


func _layout_nav_lock_pill() -> void:
	var content := nav_lock_pill.get_parent() as Control
	if content == null:
		return
	var pill_size := nav_lock_pill.get_combined_minimum_size()
	nav_lock_pill.size = pill_size
	nav_lock_pill.position = Vector2(
		floorf((content.size.x - pill_size.x) * 0.5),
		-float(UiChrome.LOCK_PILL_RISE + UiChrome.CHROME_EDGE_W)
	)


## Indikator prati živu poziciju pagera — i povlačenje prstom i snap tween.
func _sync_active_indicator() -> void:
	if active_indicator == null or page_tabs == null:
		return
	var slot_w := page_tabs.size.x / float(MetaHubPagesScript.PAGE_COUNT)
	if slot_w < 1.0:
		return
	var scroll_page := clampf(
		swipe_pager.get_scroll_page(), 0.0, float(MetaHubPagesScript.PAGE_COUNT - 1)
	)
	var pos := Vector2(
		page_tabs.position.x + scroll_page * slot_w + (slot_w - UiChrome.INDICATOR_W) * 0.5,
		UiChrome.INDICATOR_TOP
	)
	if active_indicator.position.is_equal_approx(pos):
		return
	active_indicator.position = pos
	active_indicator.size = Vector2(UiChrome.INDICATOR_W, UiChrome.INDICATOR_H)


func refresh_top_bar() -> void:
	if coins_label:
		coins_label.text = UiChrome.format_count(GameState.wallet_coins)
	if seeds_label:
		seeds_label.text = UiChrome.format_count(GameState.sum_seed_bag_only())
	if flowers_label:
		flowers_label.text = UiChrome.format_count(GameState.get_garden_crystal_total())
	_refresh_tab_badges()


func _refresh_tab_badges() -> void:
	if _tabs.size() <= MetaHubPagesScript.COLLECTION:
		return
	_tabs[MetaHubPagesScript.COLLECTION].set_badge_count(
		GameState.count_collection_journal_news()
	)


## Shop javlja potrosnju coina; pop krece ispod coin chipa (design_handoff_shop).
## Shop v2 · coins.short: tap na dugme bez dovoljno coina — coin chip kratko pulsira
## (scale 1,06, prsten 6 px #FFD56B, 0,3 s), bez rečenice.
func pulse_coin_chip() -> void:
	if coin_chip == null:
		return
	coin_chip.pivot_offset = coin_chip.size * 0.5
	var tw := coin_chip.create_tween()
	tw.tween_property(coin_chip, "scale", Vector2.ONE * 1.06, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(coin_chip, "scale", Vector2.ONE, 0.18)
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.draw_center = false
	sb.set_border_width_all(6)
	sb.border_color = Color("#FFD56B")
	sb.set_corner_radius_all(26)
	ring.add_theme_stylebox_override("panel", sb)
	ring.size = coin_chip.size + Vector2(12, 12)
	ring.position = Vector2(-6, -6)
	coin_chip.add_child(ring)
	var rt := ring.create_tween()
	rt.tween_property(ring, "modulate:a", 0.0, 0.3)
	rt.tween_callback(ring.queue_free)


## X2 · leteća poruka (design_handoff_popups): potrošnja roze „−N" pada ispod coin chipa.
func show_coin_spend_pop(amount: int) -> void:
	if amount <= 0:
		return
	FloatPop.spend_at(self, _coin_pop_origin(), "−%d" % amount, UI_ASSETS.get_chrome_icon("icon_coin"))


## Arena javlja combo nagradu (+2 na combo 5): zlatna „+N" iskoči ispod chipa i uleti u njega.
func show_coin_earn_pop(amount: int) -> void:
	if amount <= 0:
		return
	var target := coin_chip.get_global_rect().get_center() - get_global_rect().position if coin_chip else Vector2(COIN_POP_POS)
	FloatPop.earn(self, _coin_pop_origin() + Vector2(0, 24), "+%d" % amount, UI_ASSETS.get_chrome_icon("icon_coin"), target, coin_chip)


func _coin_pop_origin() -> Vector2:
	if coin_chip == null:
		return Vector2(COIN_POP_POS)
	var r := coin_chip.get_global_rect()
	r.position -= get_global_rect().position
	return Vector2(r.position.x + 100.0, r.end.y + 36.0)


## X1 · toast sistema 24 px ispod headera (traka čvora „SettingsToast").
func _show_settings_toast() -> void:
	if _settings_toast == null:
		_settings_toast = PopupToast.new()
		_settings_toast.name = "SettingsToast"
		_settings_toast.z_index = 60
		add_child(_settings_toast)
	_settings_toast.position = Vector2(0.0, top_bar.position.y + top_bar.size.y + SETTINGS_TOAST_GAP)
	_settings_toast.setup(0.0, SETTINGS_TOAST_HOLD, size.x * 0.5)
	_settings_toast.show_text(SETTINGS_TOAST_TEXT, UI_ASSETS.get_chrome_icon("icon_settings"))


func _show_swipe_hint_if_needed() -> void:
	# Bug-019: caption removed; tab labels already name each page.
	pass
