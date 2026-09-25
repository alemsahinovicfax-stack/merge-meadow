extends SceneTree

## Hub chrome v2 (design_handoff_hub_chrome_v2) — geometrija iz handoffa, ikone bez
## labela, FlowerChip umjesto dijamanta, badge, nav lock, Settings toast.

const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const UI_CHROME := preload("res://scripts/visual/ui_chrome.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const HEADER_ROW := "RootVBox/TopBar/Panel/HBox"
const FOOTER_CONTENT := "RootVBox/PageIndicator/NavPanel/Content"
const CHROME_ICONS: Array[String] = [
	"icon_coin", "icon_seed", "icon_flower", "icon_diamond", "icon_lock",
	"icon_settings", "icon_settings_light",
	"tab_shop", "tab_shop_light", "tab_journal", "tab_journal_light", "tab_home", "tab_home_light",
	"tab_camp", "tab_camp_light", "tab_arena", "tab_arena_light",
]
# Lanac iz handoffa: 20 · 3 x 296 (gap 16) · 16 · Settings 124 = 1080; footer 5 x 216.
const CHIP_W := 296.0
const TAB_SLOT_W := 216.0
const TOLERANCE := 1.5

var _failed: bool = false


func _initialize() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("hub_chrome_smoke: hub load failed %d" % err)
		quit(1)
		return
	call_deferred("_run")


func _run() -> void:
	for _i in 12:
		await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
	else:
		var hub := hubs[0] as Control
		_check_icons()
		_check_header(hub)
		await _check_footer(hub)
		_check_badge(hub)
		_check_nav_lock(hub)
		await _check_settings_toast(hub)
	if _failed:
		quit(1)
		return
	print("hub_chrome_smoke OK")
	quit(0)


func _check_icons() -> void:
	for icon_name in CHROME_ICONS:
		var path := "res://assets/ui/chrome/%s.svg" % icon_name
		if not ResourceLoader.exists(path) or load(path) == null:
			_fail("chrome icon not importable: %s" % path)


func _check_header(hub: Control) -> void:
	var view_w := hub.get_viewport_rect().size.x
	var settings := hub.get_node_or_null(HEADER_ROW + "/SettingsButton") as Control
	if settings == null:
		_fail("SettingsButton missing in header")
		return
	_expect_near("Settings width", settings.size.x, UI_CHROME.SETTINGS_SLOT_W)
	_expect_near("Settings height", settings.size.y, UI_CHROME.SETTINGS_HIT_H)
	_expect_near("Settings right edge", settings.get_global_rect().end.x, view_w)
	for chip_name in ["CoinChip", "SeedChip", "FlowerChip"]:
		var chip := hub.get_node_or_null(HEADER_ROW + "/" + chip_name) as Control
		if chip == null:
			_fail("%s missing" % chip_name)
			continue
		_expect_near("%s width" % chip_name, chip.size.x, CHIP_W)
		_expect_near("%s height" % chip_name, chip.size.y, UI_CHROME.CHIP_H)
	var coins := hub.get_node_or_null(HEADER_ROW + "/CoinChip/HBox/CoinsLabel") as Label
	if coins == null:
		_fail("CoinsLabel missing")
	else:
		if coins.get_theme_font_size("font_size") != UI_CHROME.NUMBER_FONT_SIZE:
			_fail("CoinsLabel font size %d" % coins.get_theme_font_size("font_size"))
		if not coins.get_theme_color("font_color").is_equal_approx(UI_CHROME.NUMBER_INK):
			_fail("CoinsLabel ink should be cream on the dark well")
	var chip_icon := hub.get_node_or_null(HEADER_ROW + "/CoinChip/HBox/CoinIcon") as TextureRect
	if chip_icon == null or chip_icon.texture == null:
		_fail("CoinIcon texture missing")
	else:
		_expect_near("chip icon size", chip_icon.size.x, UI_CHROME.CHIP_ICON_SIZE)
	var flower_label := hub.get_node_or_null(HEADER_ROW + "/FlowerChip/HBox/FlowersLabel") as Label
	# GameState se u --script smokeu cita preko roota (staticka referenca ne kompajlira).
	var gs := get_root().get_node_or_null("GameState")
	var want_flowers := UI_CHROME.format_count(int(gs.call("get_garden_crystal_total")))
	if flower_label == null or flower_label.text != want_flowers:
		_fail("FlowerChip should count flowers (%s)" % want_flowers)
	var top_bar := hub.get_node_or_null("RootVBox/TopBar") as Control
	if top_bar:
		_expect_near(
			"header height (no safe area)",
			top_bar.size.y,
			UI_CHROME.SETTINGS_HIT_H + UI_CHROME.CHROME_EDGE_W
		)


func _check_footer(hub: Control) -> void:
	var page_indicator := hub.get_node_or_null("RootVBox/PageIndicator") as Control
	var pager := hub.get_node_or_null("RootVBox/SwipePager") as Control
	if pager:
		_expect_near("page height", pager.size.y, UI_CHROME.PAGE_H)
	if page_indicator:
		_expect_near("footer height (no safe area)", page_indicator.size.y, UI_CHROME.FOOTER_H)
	var tabs_row := hub.get_node_or_null(FOOTER_CONTENT + "/TabsRow") as Control
	if tabs_row == null or tabs_row.get_child_count() != MetaHubPages.PAGE_COUNT:
		_fail("TabsRow should hold %d tabs" % MetaHubPages.PAGE_COUNT)
		return
	for i in tabs_row.get_child_count():
		var tab := tabs_row.get_child(i) as Control
		_expect_near("tab %d width" % i, tab.size.x, TAB_SLOT_W)
		var tile := tab.get_node_or_null("Tile") as Control
		if tile == null:
			_fail("tab %d Tile missing" % i)
			continue
		_expect_near("tab %d tile width" % i, tile.size.x, UI_CHROME.TAB_TILE_W)
		_expect_near("tab %d tile height" % i, tile.size.y, UI_CHROME.TAB_TILE_H)
		_expect_near("tab %d tile top" % i, tile.position.y, UI_CHROME.TAB_TILE_TOP)
		# v2: nema labele — ime ostaje samo kao accessible name.
		if tab.find_child("Label", true, false) != null:
			_fail("tab %d should not carry a visible label" % i)
		if tab.tooltip_text != MetaHubPages.PAGE_LABELS[i]:
			_fail("tab %d tooltip should read %s" % [i, MetaHubPages.PAGE_LABELS[i]])
		var icon := tab.get_node_or_null("Icon") as TextureRect
		if icon == null or icon.texture == null:
			_fail("tab %d icon missing" % i)
		elif not icon.modulate.is_equal_approx(Color(1, 1, 1, icon.modulate.a)):
			_fail("tab %d icon must not be RGB-tinted" % i)
	var indicator := hub.get_node_or_null(FOOTER_CONTENT + "/ActiveIndicator") as Control
	if indicator == null:
		_fail("ActiveIndicator missing")
		return
	for page in [MetaHubPages.ARENA, MetaHubPages.SHOP, MetaHubPages.MAIN]:
		hub.call("go_to_page", page, false)
		for _k in 4:
			await process_frame
		var want_x := (TAB_SLOT_W - UI_CHROME.INDICATOR_W) * 0.5 + float(page) * TAB_SLOT_W
		_expect_near("indicator x on page %d" % page, indicator.position.x, want_x)
		_expect_near("indicator width", indicator.size.x, UI_CHROME.INDICATOR_W)
		for i in tabs_row.get_child_count():
			var active := bool(tabs_row.get_child(i).call("is_active"))
			if active != (i == page):
				_fail("tab %d active=%s on page %d" % [i, active, page])
			# Aktivan tab nosi vecu ikonu u boji, neaktivan krem liniju.
			var tab_icon := tabs_row.get_child(i).get_node_or_null("Icon") as TextureRect
			var want_side := (
				UI_CHROME.TAB_ICON_SIZE_ACTIVE if active else UI_CHROME.TAB_ICON_SIZE
			)
			if tab_icon:
				_expect_near("tab %d icon side" % i, tab_icon.size.x, float(want_side))


func _check_badge(hub: Control) -> void:
	var tabs_row := hub.get_node_or_null(FOOTER_CONTENT + "/TabsRow")
	var journal := tabs_row.get_child(MetaHubPages.COLLECTION) as Control
	var badge := journal.get_node_or_null("Badge") as Control
	var count_label := journal.get_node_or_null("Badge/Count") as Label
	var tile := journal.get_node_or_null("Tile") as Control
	if badge == null or count_label == null or tile == null:
		_fail("Journal tab badge nodes missing")
		return
	journal.call("set_badge_count", 3)
	if not badge.visible or count_label.text != "3":
		_fail("badge 3 should be visible with '3'")
	_expect_near(
		"badge right edge", badge.get_rect().end.x, tile.get_rect().end.x + UI_CHROME.BADGE_OFFSET.x
	)
	_expect_near("badge top", badge.get_rect().position.y, tile.get_rect().position.y - 8.0)
	journal.call("set_badge_count", 12)
	if count_label.text != "9+":
		_fail("badge 12 should read '9+' got '%s'" % count_label.text)
	journal.call("set_badge_count", 0)
	if badge.visible:
		_fail("badge 0 should hide")
	hub.call("refresh_top_bar")


func _check_nav_lock(hub: Control) -> void:
	var pill := hub.get_node_or_null(FOOTER_CONTENT + "/NavLockPill") as Control
	var tabs_row := hub.get_node_or_null(FOOTER_CONTENT + "/TabsRow")
	var nav_panel := hub.get_node_or_null("RootVBox/PageIndicator/NavPanel") as PanelContainer
	var current := int(hub.call("current_page_index"))
	hub.call("set_nav_locked", true)
	if pill == null or not pill.visible:
		_fail("NavLockPill should be visible when locked")
	elif pill.position.y > -30.0:
		_fail("NavLockPill should rise above the footer edge (y=%.1f)" % pill.position.y)
	for i in tabs_row.get_child_count():
		var tab := tabs_row.get_child(i) as Control
		var want := 1.0 if i == current else UI_CHROME.LOCKED_TAB_ALPHA
		_expect_near("locked tab %d alpha" % i, tab.modulate.a, want)
		if not bool(tab.get("disabled")):
			_fail("tab %d should be disabled while locked" % i)
	var style := nav_panel.get_theme_stylebox("panel") as StyleBoxFlat if nav_panel else null
	if style == null or not is_equal_approx(style.border_color.a, 0.85):
		_fail("locked footer edge should be gold @ 85 %")
	hub.call("set_nav_locked", false)
	if pill and pill.visible:
		_fail("NavLockPill should hide when unlocked")
	for i in tabs_row.get_child_count():
		var tab := tabs_row.get_child(i) as Control
		_expect_near("unlocked tab %d alpha" % i, tab.modulate.a, 1.0)


func _check_settings_toast(hub: Control) -> void:
	var settings := hub.get_node_or_null(HEADER_ROW + "/SettingsButton")
	if settings == null:
		return
	settings.emit_signal("clicked")
	for _i in 3:
		await process_frame
	var toast := hub.get_node_or_null("SettingsToast") as Control
	if toast == null or not toast.visible:
		_fail("Settings tap should show SettingsToast")
		return
	var header_bottom := (hub.get_node("RootVBox/TopBar") as Control).get_global_rect().end.y
	if toast.get_global_rect().position.y < header_bottom:
		_fail("SettingsToast should sit below the header")


func _expect_near(what: String, got: float, want: float) -> void:
	if absf(got - want) > TOLERANCE:
		_fail("%s: got %.1f expected %.1f" % [what, got, want])


func _fail(msg: String) -> void:
	_failed = true
	push_error("hub_chrome_smoke: " + msg)
