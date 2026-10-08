extends PanelContainer

## Hero kartica sljedece besplatne sezone (design_handoff_camp_v2 · SeasonLinkCard).
## Tap bilo gdje na kartici vodi na Home bez trosenja — bez "Details" pilule i bez
## "Next free season" natpisa. Unlock (300 x 120, jedna rijec) stoji desno od imena,
## trosi odmah (500 coina + 20 ★3), pokaze burst, pa skace na Home s fokusom.
## Season Kit (design_handoff_seasons faza 2): sezona s receptom "camp" crta svoje mjesto
## (SeasonBackdrop 1026 x 312 unutar ruba 3 #2D3436, ništa izvan) umjesto tinta, tekst
## #3D3D33, jedna tvrda sjena 0 8 0; uglovi = maska u boji stranice Campa.

@onready var title_label: Label = %SeasonLinkTitle
@onready var coin_icon: TextureRect = %SeasonLinkCoinIcon
@onready var coins_label: Label = %SeasonLinkCoins
@onready var coins_bar: ProgressBar = %SeasonLinkCoinsBar
@onready var split_line: Panel = %SeasonSplitLine
@onready var flower_art: CampArtFrame = %SeasonLinkFlower
@onready var flower_name: Label = %SeasonLinkFlowerName
@onready var t3_label: Label = %SeasonLinkT3
@onready var t3_bar: ProgressBar = %SeasonLinkT3Bar
@onready var unlock_button: CampButton = %SeasonLinkUnlock

var _season_id: String = ""
var _state: String = UiCamp.SEASON_SHORT
var _pressing_card: bool = false
var _unlocking: bool = false
var _burst: float = -1.0
var _scene: Dictionary = {}
var _ink: Color = UiCamp.DARK_INK


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	clip_contents = true
	custom_minimum_size.y = UiCamp.SEASON_H
	_ignore_tree(get_node("SeasonLinkVBox") as Control)
	unlock_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unlock_button.custom_minimum_size = UiCamp.UNLOCK_BTN
	unlock_button.clicked.connect(_on_unlock_clicked)
	coin_icon.texture = UiAssets.get_chrome_icon("icon_coin")
	coin_icon.custom_minimum_size = Vector2(UiCamp.SEASON_ICON, UiCamp.SEASON_ICON)
	flower_art.configure_frame(
		UiCamp.SEASON_ART_FRAME, UiCamp.SEASON_ART_RADIUS, UiCamp.SEASON_ART_BORDER,
		0.0, 0, 0, UiCamp.SEASON_ART
	)
	flower_name.autowrap_mode = TextServer.AUTOWRAP_OFF
	flower_name.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	flower_name.clip_text = false
	split_line.add_theme_stylebox_override("panel", UiCamp.split_line_style())
	split_line.custom_minimum_size = Vector2(UiCamp.SEASON_SPLIT_W, UiCamp.SEASON_SPLIT_H)
	for bar in [coins_bar, t3_bar]:
		(bar as ProgressBar).show_percentage = false
		(bar as ProgressBar).custom_minimum_size.y = UiCamp.SEASON_BAR_H
		(bar as ProgressBar).add_theme_stylebox_override("background", UiCamp.progress_track_style())
	coins_bar.add_theme_stylebox_override("fill", UiCamp.progress_fill_style(true))
	t3_bar.add_theme_stylebox_override("fill", UiCamp.progress_fill_style(false))
	UiCamp.style_label(title_label, UiCamp.FONT_SEASON_NAME, UiCamp.DARK_INK)
	UiCamp.style_label(coins_label, UiCamp.FONT_SEASON_VALUE, UiCamp.DARK_INK)
	UiCamp.style_label(t3_label, UiCamp.FONT_SEASON_VALUE, UiCamp.DARK_INK)
	title_label.custom_minimum_size.x = 1.0
	unlock_button.set_fonts(UiCamp.FONT_UNLOCK)


func get_state() -> String:
	return _state


## Kartica crta recept "camp" sezone (Season Kit).
func has_kit() -> bool:
	return not _scene.is_empty()


func get_ink() -> Color:
	return _ink


func refresh() -> void:
	if _unlocking:
		return
	var id := GameState.next_locked_free_id()
	_season_id = id
	var def: SeasonDef = GameState.get_season_def(id) if not id.is_empty() else null
	if def == null or not def.is_free():
		visible = false
		return
	visible = true
	var coins := GameState.wallet_coins
	var flowers := GameState.star3_flower_count_for_unlock(id)
	_state = UiCamp.SEASON_READY if GameState.can_unlock_free(id) else UiCamp.SEASON_SHORT
	_show(def, coins, flowers)


func _show(def: SeasonDef, coins: int, flowers: int) -> void:
	var coins_need := def.coins_cost
	var flowers_need := def.t3_flowers_required
	var recipe := UiSeasons.recipe(def.id, "camp")
	_scene = {} if recipe.is_empty() else SeasonBackdrop.scene(
		"camp:" + def.id, recipe, float(recipe.get("w", UiSeasons.CAMP_CARD.x)), []
	)
	_ink = UiSeasons.CAMP_TEXT if has_kit() else UiCamp.DARK_INK
	for lab in [title_label, coins_label, t3_label]:
		(lab as Label).add_theme_color_override("font_color", _ink)
	add_theme_stylebox_override("panel", UiCamp.season_card_kit_style() if has_kit() else UiCamp.season_card_style(def.id))
	queue_redraw()
	title_label.text = def.display_name
	coins_label.text = "%d / %d" % [mini(coins, coins_need), coins_need]
	t3_label.text = "%d / %d" % [mini(flowers, flowers_need), flowers_need]
	coins_bar.max_value = maxi(coins_need, 1)
	coins_bar.value = mini(coins, coins_need)
	t3_bar.max_value = maxi(flowers_need, 1)
	t3_bar.value = mini(flowers, flowers_need)
	var prev := GameState.previous_free_id_for(def.id)
	var flower_type := GameState.star3_type_id_for_season(prev) if not prev.is_empty() else ""
	flower_art.set_art(false, flower_type, 3)
	_fit_flower_name(GameState.get_seed_display_name(flower_type) if not flower_type.is_empty() else "")
	var style := UiCamp.unlock_button_style(_state)
	unlock_button.set_styles(style, style)
	unlock_button.set_text(UiCamp.unlock_button_text(_state))
	unlock_button.set_ink(UiCamp.unlock_button_ink(_state))
	# Lokot kad jos fali — razlika "nedostaje / spremno" ne ovisi samo o boji.
	unlock_button.set_icon(
		UiAssets.get_chrome_icon("icon_lock") if _state == UiCamp.SEASON_SHORT else null,
		UiCamp.UNLOCK_LOCK_ICON
	)
	var ready := _state == UiCamp.SEASON_READY
	unlock_button.disabled = not ready
	unlock_button.mouse_filter = Control.MOUSE_FILTER_STOP if ready else Control.MOUSE_FILTER_IGNORE


## 42, pa 38, pa 34. Ime se nikad ne reže.
func _fit_flower_name(text: String) -> void:
	flower_name.text = text
	for px in [UiCamp.FONT_SEASON_FLOWER, 38, 34]:
		UiCamp.style_label(flower_name, px, _ink)
		var width := UiCamp.tight_font(px).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		if width <= float(UiCamp.SEASON_NAME_W) or px == 34:
			return


func navigate_to_lock() -> void:
	_go_home(GameState.next_locked_free_id())


func _gui_input(event: InputEvent) -> void:
	if _unlocking:
		accept_event()
		return
	var down := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		down = mb.pressed
	elif event is InputEventScreenTouch:
		down = (event as InputEventScreenTouch).pressed
	else:
		return
	accept_event()
	if down:
		_pressing_card = true
	elif _pressing_card:
		_pressing_card = false
		navigate_to_lock()


func _on_unlock_clicked() -> void:
	if _unlocking:
		return
	var id := GameState.next_locked_free_id()
	if id.is_empty():
		return
	if not GameState.can_unlock_free(id):
		_go_home(id)
		return
	var def: SeasonDef = GameState.get_season_def(id)
	if def == null or not GameState.unlock_free(id):
		refresh()
		return
	_unlocking = true
	_state = UiCamp.SEASON_UNLOCKING
	_show(def, def.coins_cost, def.t3_flowers_required)
	unlock_button.disabled = true
	unlock_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh_top_bar()
	if not is_inside_tree():
		_finish_unlock(id)
		return
	_burst = 0.0
	var tw := create_tween()
	tw.tween_method(_set_burst, 0.0, 1.0, UiCamp.T_UNLOCK_BURST) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(UiCamp.T_UNLOCK_LINGER)
	tw.tween_callback(_finish_unlock.bind(id))


func _set_burst(value: float) -> void:
	_burst = value
	queue_redraw()


func _finish_unlock(season_id: String) -> void:
	_unlocking = false
	_burst = -1.0
	queue_redraw()
	_go_home(season_id)
	_refresh_home_after_unlock()
	refresh()


func _draw() -> void:
	if has_kit():
		_draw_kit()
	if _burst < 0.0:
		return
	var radius := lerpf(0.2, 1.0, _burst) * UiCamp.BURST_SIZE * 0.5
	var color := UiCamp.BURST
	color.a *= 1.0 - _burst
	draw_arc(size * 0.5, radius, 0.0, TAU, 64, color, UiCamp.BURST_BORDER, true)


## Sjena (sjena minus tijelo, ne ide ispod providnog ruba) → recept unutar ruba →
## maske uglova u boji stranice → rub 3. Panel ne crta ništa (season_card_kit_style).
func _draw_kit() -> void:
	var full := Rect2(Vector2.ZERO, size)
	var radius := float(UiPalette.CORNER_RADIUS_CTA)
	var border := 3.0
	var shadow := SeasonBackdrop.round_rect_points(Rect2(Vector2(0.0, UiSeasons.CAMP_SHADOW_Y), size), radius)
	for poly in Geometry2D.clip_polygons(shadow, SeasonBackdrop.round_rect_points(full, radius)):
		if poly.size() >= 3:
			draw_colored_polygon(poly, UiSeasons.CAMP_SHADOW)
	var inner := full.grow(-border)
	SeasonBackdrop.draw(self, _scene, inner)
	SeasonBackdrop.draw_corner_masks(self, inner, radius - border, UiCamp.PAGE_BG)
	var edge := StyleBoxFlat.new()
	edge.draw_center = false
	edge.set_border_width_all(int(border))
	edge.border_color = UiCamp.INK
	edge.set_corner_radius_all(int(radius))
	edge.anti_aliasing = true
	draw_style_box(edge, full)


func _go_home(season_id: String) -> void:
	if season_id.is_empty():
		return
	GameState.set_free_strip_focus(season_id)
	GameState.set_home_band("free")
	_close_home_field()
	GameState.go_to_meta_page(MetaHubPages.MAIN)


func _refresh_top_bar() -> void:
	if not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "refresh_top_bar")


func _home_page() -> Node:
	if not is_inside_tree():
		return null
	for hub in get_tree().get_nodes_in_group("meta_hub"):
		var swipe: Node = hub.get_node_or_null("RootVBox/SwipePager")
		if swipe == null or not swipe.has_method("get_pages_host"):
			continue
		var host: Node = swipe.call("get_pages_host")
		if host != null:
			return host.get_node_or_null("Page_%d" % MetaHubPages.MAIN)
	return null


func _close_home_field() -> void:
	GameState.close_home_season_field()
	var home := _home_page()
	if home == null:
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage != null and stage.has_method("close_season_field"):
		stage.call("close_season_field")


func _refresh_home_after_unlock() -> void:
	_refresh_top_bar()
	var home := _home_page()
	if home != null and home.has_method("refresh_for_meta_hub"):
		home.call("refresh_for_meta_hub")


func _ignore_tree(n: Control) -> void:
	if n == null:
		return
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in n.get_children():
		if child is Control:
			_ignore_tree(child as Control)
