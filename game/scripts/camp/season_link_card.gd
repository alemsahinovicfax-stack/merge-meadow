extends PanelContainer

## Hero kartica sljedece besplatne sezone (design_handoff_camp_v2 · SeasonLinkCard).
## Tap bilo gdje na kartici vodi na Home bez trosenja — bez "Details" pilule i bez
## "Next free season" natpisa. Unlock (300 x 120, jedna rijec) stoji desno od imena,
## trosi odmah (coini + ★3 iz seasons.json), pokaze burst, pa skace na Home s fokusom.
## Kad su sve besplatne otključane, kartica nastavlja s prvom plaćenom sezonom koju igrač
## nema (2026-10-16, na zahtjev): umjesto coina i ★3 samo cijena (zlatno dugme, kao zlatna
## cijena na Homeu), kupovina kroz IAPManager, pa isti burst i skok na Home (band „paid").
## Plaćena kartica (design_handoff_run_pickups · camp_paid_card.json): recept „camp" i za 4 plaćene
## sezone, boja teksta po receptu (ink), ispod imena oznaka PREMIUM + „6 new flowers" i red od 6
## cvjetova sezone u okvirima po rijetkosti; stanja price → buying (tri tačke) → burst / failed
## (pilula „Purchase cancelled" 1,6 s, pa nazad na cijenu). Sve se crta jednom, bez animacije.
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
## Plaćena sezona (nema više besplatnih): cijena umjesto napretka.
var _paid: bool = false
var _buying: bool = false
var _pressing_card: bool = false
var _unlocking: bool = false
var _burst: float = -1.0
var _scene: Dictionary = {}
var _ink: Color = UiCamp.DARK_INK
var _offer: HBoxContainer
var _paid_count: Label
var _paid_tiles: Array[_FlowerTile] = []
var _dots: _Dots
var _toast_until: int = 0
var _toast_layer: _ToastLayer


## Okvir cvijeta plaćene sezone: okvir po rijetkosti, tamno udubljenje, t3 cvijet 84 px.
## Crta se jednom (set_flower → queue_redraw).
class _FlowerTile:
	extends Control

	var _tex: Texture2D
	var _rarity: int = 1

	func set_flower(type_id: String, rarity: int) -> void:
		_rarity = rarity
		_tex = FlowerAssets.get_texture(type_id, 3) if not type_id.is_empty() else null
		queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_style_box(UiCamp.paid_tile_style(_rarity), r)
		draw_style_box(UiCamp.paid_well_style(), r.grow(-float(UiCamp.PAID_WELL_INSET)))
		if _tex != null:
			CampPlantDraw.draw_cropped_texture(self, size * 0.5, _tex, float(UiCamp.PAID_ART))


## Sloj iznad cijele kartice (zadnje dijete): „Purchase cancelled" desno 22, gore 150 od ruba
## kartice, h 64, 900 34 — preko reda cvjetova. Crta se samo dok traje (1,6 s).
class _ToastLayer:
	extends Control

	var card: Control

	func _draw() -> void:
		if card == null or not bool(card.call("is_cancel_toast_visible")):
			return
		const PX := 34
		var font := UiCamp.tight_font(PX)
		var text := UiCamp.S_PURCHASE_CANCELLED
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x + 54.0
		var r := Rect2(Vector2(card.size.x - 22.0 - w, 150.0) - position, Vector2(w, 64.0))
		draw_style_box(UiCamp.paid_toast_style(), r)
		var asc := font.get_ascent(PX)
		var baseline := r.position.y + (64.0 - (asc + font.get_descent(PX))) * 0.5 + asc
		draw_string(font, Vector2(r.position.x + 27.0, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, PX, UiCamp.INK)


## „Čeka trgovinu": tri tačke 18 px, alfa 1 / 0,6 / 0,3, razmak 12.
class _Dots:
	extends Control

	func _draw() -> void:
		var alphas := [1.0, 0.6, 0.3]
		for i in 3:
			draw_circle(Vector2(9.0 + float(i) * 30.0, size.y * 0.5), 9.0, Color(UiCamp.INK, float(alphas[i])))


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
	_build_paid_offer()
	IAPManager.purchase_completed.connect(_on_purchase_completed)
	IAPManager.purchase_failed.connect(_on_purchase_failed)


func get_state() -> String:
	return _state


## Kartica nudi plaćenu sezonu (sve besplatne otključane).
func is_paid() -> bool:
	return _paid


func get_season_id() -> String:
	return _season_id


## Kartica crta recept "camp" sezone (Season Kit).
func has_kit() -> bool:
	return not _scene.is_empty()


func get_ink() -> Color:
	return _ink


func refresh() -> void:
	if _unlocking:
		return
	var id := GameState.next_locked_free_id()
	_paid = id.is_empty()
	if _paid:
		# Bez kupovina (MonetizationConfig.IAP_ENABLED = false) nema ponude plaćene sezone.
		id = GameState.next_unowned_paid_id() if MonetizationConfig.iap_enabled() else ""
	if id != _season_id:
		_set_toast(false)
	_season_id = id
	var def: SeasonDef = GameState.get_season_def(id) if not id.is_empty() else null
	if def == null or (not _paid and not def.is_free()):
		visible = false
		return
	visible = true
	if _paid:
		_state = UiCamp.SEASON_READY
		_show_paid(def)
		return
	_set_free_layout(true)
	var coins := GameState.wallet_coins
	var flowers := GameState.star3_flower_count_for_unlock(id)
	_state = UiCamp.SEASON_READY if GameState.can_unlock_free(id) else UiCamp.SEASON_SHORT
	_show(def, coins, flowers)


func _show(def: SeasonDef, coins: int, flowers: int) -> void:
	var coins_need := def.coins_cost
	var flowers_need := def.t3_flowers_required
	_apply_card_look(def)
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


## Recept „camp" sezone (Season Kit) ili tint, i boja teksta po njemu.
func _apply_card_look(def: SeasonDef) -> void:
	var recipe := UiSeasons.recipe(def.id, "camp")
	_scene = {} if recipe.is_empty() else SeasonBackdrop.scene(
		"camp:" + def.id, recipe, float(recipe.get("w", UiSeasons.CAMP_CARD.x)), []
	)
	_ink = UiCamp.DARK_INK
	if has_kit():
		_ink = Color(str(recipe["ink"])) if recipe.has("ink") else UiSeasons.CAMP_TEXT
	for lab in [title_label, coins_label, t3_label, _paid_count]:
		(lab as Label).add_theme_color_override("font_color", _ink)
	add_theme_stylebox_override("panel", UiCamp.season_card_kit_style() if has_kit() else UiCamp.season_card_style(def.id))
	queue_redraw()


## Besplatna sezona: kolona coina, linija i traka ★3. Plaćena: samo cvijet sezone i tekst.
func _set_free_layout(free: bool) -> void:
	var coin_col := coins_label.get_parent().get_parent() as Control
	if coin_col != null:
		coin_col.visible = free
	split_line.visible = free
	t3_bar.visible = free
	var progress := coin_col.get_parent() as Control if coin_col != null else null
	if progress != null:
		progress.visible = free
	if _offer != null:
		_offer.visible = not free
	if free:
		_set_dots(false)


## Red ispod imena plaćene kartice: [PREMIUM / „6 new flowers"] (312) | 6 okvira cvjetova.
func _build_paid_offer() -> void:
	var vbox := get_node("SeasonLinkVBox") as VBoxContainer
	_offer = HBoxContainer.new()
	_offer.name = "SeasonOffer"
	_offer.visible = false
	_offer.custom_minimum_size.y = UiCamp.PAID_OFFER_H
	_offer.add_theme_constant_override("separation", UiCamp.PAID_GAP)
	_offer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(_offer)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = UiCamp.PAID_LEFT_W
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", 12)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_offer.add_child(left)
	var tag := PanelContainer.new()
	tag.name = "PremiumTag"
	tag.custom_minimum_size.y = UiCamp.PAID_TAG_H
	tag.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	tag.add_theme_stylebox_override("panel", UiCamp.premium_tag_style())
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(tag)
	var tag_label := Label.new()
	tag_label.text = UiCamp.S_PREMIUM_TAG
	tag_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiStage.style(tag_label, 900, UiCamp.PAID_TAG_FONT, UiCamp.INK, 1.0, 0.06)
	tag.add_child(tag_label)
	_paid_count = Label.new()
	_paid_count.name = "PaidCount"
	UiCamp.style_label(_paid_count, UiCamp.PAID_COUNT_FONT, _ink)
	left.add_child(_paid_count)
	var row := HBoxContainer.new()
	row.name = "FlowerRow"
	row.add_theme_constant_override("separation", UiCamp.PAID_TILE_GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_offer.add_child(row)
	for i in 6:
		var tile := _FlowerTile.new()
		tile.custom_minimum_size = Vector2(UiCamp.PAID_TILE, UiCamp.PAID_TILE)
		tile.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tile)
		_paid_tiles.append(tile)
	_dots = _Dots.new()
	_dots.name = "BuyingDots"
	_dots.custom_minimum_size = Vector2(78, 18)
	_dots.visible = false
	_dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unlock_button.get_text_column().add_child(_dots)
	_toast_layer = _ToastLayer.new()
	_toast_layer.name = "CancelToast"
	_toast_layer.card = self
	_toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast_layer)


## Cvijeće plaćene sezone: ★1 × 3, ★2 × 2, ★3 (redoslijed kita unutar rijetkosti).
func _paid_roster(def: SeasonDef) -> Array:
	var out: Array = []
	for r in [1, 2, 3]:
		for id in def.seed_type_ids:
			if GameState.get_seed_rarity(str(id)) == r:
				out.append([str(id), r])
	return out


func _set_dots(on: bool) -> void:
	if _dots == null:
		return
	_dots.visible = on
	unlock_button.get_title_label().visible = not on


## price | buying (čeka trgovinu) | burst (kupljeno, prsten pa Home).
func get_paid_button_state() -> String:
	if _unlocking:
		return "burst"
	if _buying:
		return "buying"
	return "price"


func get_paid_tiles() -> Array:
	return _paid_tiles


func is_cancel_toast_visible() -> bool:
	return Time.get_ticks_msec() < _toast_until


## Plaćena sezona: ime + zlatno dugme s cijenom; u redu ispod potpisni ★3 cvijet sezone,
## „Premium season" i koliko novih cvjetova donosi. Nema coina ni ★3 — samo cijena.
func _show_paid(def: SeasonDef) -> void:
	_set_free_layout(false)
	_apply_card_look(def)
	title_label.text = def.display_name
	var flower_type := GameState.star3_type_id_for_season(def.id)
	flower_art.set_art(false, flower_type, 3)
	_fit_flower_name(UiCamp.S_PREMIUM_SEASON)
	t3_label.text = UiCamp.S_PREMIUM_FLOWERS % def.seed_type_ids.size()
	_paid_count.text = UiCamp.S_PREMIUM_FLOWERS % def.seed_type_ids.size()
	_paid_count.add_theme_color_override("font_color", _ink)
	var roster := _paid_roster(def)
	for i in _paid_tiles.size():
		var f: Array = roster[i] if i < roster.size() else ["", 1]
		_paid_tiles[i].set_flower(str(f[0]), int(f[1]))
		_paid_tiles[i].visible = i < roster.size()
	var price := IAPManager.get_price_label(def.iap_product_id)
	unlock_button.set_styles(UiCamp.paid_button_style(_buying), UiCamp.paid_button_style(true))
	unlock_button.set_text(price)
	unlock_button.set_ink(UiCamp.INK)
	unlock_button.set_icon(null, UiCamp.UNLOCK_LOCK_ICON)
	_set_dots(_buying)
	unlock_button.disabled = _buying
	unlock_button.mouse_filter = Control.MOUSE_FILTER_IGNORE if _buying else Control.MOUSE_FILTER_STOP


## 42, pa 38, pa 34. Ime se nikad ne reže.
func _fit_flower_name(text: String) -> void:
	flower_name.text = text
	for px in [UiCamp.FONT_SEASON_FLOWER, 38, 34]:
		UiCamp.style_label(flower_name, px, _ink)
		var width := UiCamp.tight_font(px).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		if width <= float(UiCamp.SEASON_NAME_W) or px == 34:
			return


func navigate_to_lock() -> void:
	if _paid:
		_go_home_paid(_season_id)
		return
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
	if _paid:
		_buy_paid()
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
	Sfx.play("unlock")
	Sfx.haptic(40)
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
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def != null and def.is_paid():
		_go_home_paid(season_id)
	else:
		_go_home(season_id)
	_refresh_home_after_unlock()
	refresh()


# --- plaćena sezona --------------------------------------------------------------

func _buy_paid() -> void:
	var def: SeasonDef = GameState.get_season_def(_season_id)
	if def == null or def.iap_product_id.is_empty() or _buying or IAPManager.is_busy():
		return
	if GameState.is_season_playable(def.id):
		refresh()
		return
	_buying = true
	_set_toast(false)
	_show_paid(def)
	IAPManager.purchase(def.iap_product_id)


func _on_purchase_completed(sku: String) -> void:
	if not _buying:
		return
	var def: SeasonDef = GameState.get_season_def(_season_id)
	if def == null or def.iap_product_id != sku:
		return
	_buying = false
	if not GameState.is_season_playable(def.id):
		refresh()
		return
	# Isti trenutak kao besplatna: zvuk, burst, pa Home na kupljenu sezonu.
	_unlocking = true
	_state = UiCamp.SEASON_UNLOCKING
	Sfx.play("unlock")
	Sfx.haptic(40)
	var busy := UiCamp.paid_button_style(true)
	unlock_button.set_styles(busy, busy)
	_set_dots(false)
	unlock_button.set_text(UiCamp.unlock_button_text(_state))
	unlock_button.disabled = true
	unlock_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh_top_bar()
	if not is_inside_tree():
		_finish_unlock(def.id)
		return
	_burst = 0.0
	var tw := create_tween()
	tw.tween_method(_set_burst, 0.0, 1.0, UiCamp.T_UNLOCK_BURST) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(UiCamp.T_UNLOCK_LINGER)
	tw.tween_callback(_finish_unlock.bind(def.id))


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if not _buying:
		return
	_buying = false
	refresh()
	# failed: kratka pilula preko reda cvjetova, pa nazad na cijenu (camp_paid_card.json).
	_set_toast(true)
	if is_inside_tree():
		get_tree().create_timer(UiCamp.PAID_TOAST_LIFE).timeout.connect(_toast_layer.queue_redraw)


func _set_toast(on: bool) -> void:
	_toast_until = Time.get_ticks_msec() + int(UiCamp.PAID_TOAST_LIFE * 1000.0) if on else 0
	if _toast_layer != null:
		_toast_layer.queue_redraw()


func _go_home_paid(season_id: String) -> void:
	if season_id.is_empty():
		return
	GameState.set_paid_strip_focus(season_id)
	GameState.set_home_band("paid")
	_close_home_field()
	GameState.go_to_meta_page(MetaHubPages.MAIN)


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
