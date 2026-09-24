class_name SeasonPackCard
extends PanelContainer

## Premium sezona u Shopu (design_handoff_shop · components.SeasonPackCard).
## Kartica je u mood boji sezone, pokazuje roster od 6 cvjetova i tagline.
## Tap na karticu ne radi nista — akcija je samo dugme (Get / Play it on Home).
## Kupljena sezona vodi na Home; Ember Fen je "coming soon", bez cijene.

signal buy_pressed(sku: String)
signal open_home_pressed(season_id: String)

var sku: String = ""
var season_id: String = ""

var _state: String = UiShop.SEASON_BUY
var _eyebrow: Label
var _tag: PanelContainer
var _tag_label: Label
var _name: Label
var _tagline: Label
var _roster: GridContainer
var _fine: Label
var _status: ShopPurchaseStatus
var _price: ShopPriceTag
var _buy: CampButton
var _home: CampButton
var _soon_info: CampButton
var _built: bool = false


func apply(pack_sku: String, busy_sku: String = "") -> void:
	sku = pack_sku
	season_id = MonetizationConfig.season_id_for_sku(pack_sku)
	_ensure_built()
	var def: SeasonDef = SeasonCatalog.get_def(season_id)
	if def == null:
		return
	_state = UiShop.season_mode(def, busy_sku)
	_refresh(def)


func get_state() -> String:
	return _state


func get_name_text() -> String:
	return _name.text if _name else ""


func get_action_text() -> String:
	for btn in [_buy, _home, _soon_info]:
		if btn != null and btn.visible:
			return btn.get_title()
	return ""


func get_price_text() -> String:
	return _price.get_price_text() if _price and _price.visible else ""


func get_tag_text() -> String:
	return _tag_label.text if _tag and _tag.visible else ""


func get_status() -> ShopPurchaseStatus:
	return _status


func roster_slot_count() -> int:
	return _roster.get_child_count() if _roster else 0


func _ready() -> void:
	_ensure_built()
	if not sku.is_empty():
		apply(sku)


func _ensure_built() -> void:
	if _built:
		return
	_built = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 20)
	add_child(col)

	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_theme_constant_override("separation", 24)
	col.add_child(top)

	var text_col := VBoxContainer.new()
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.add_theme_constant_override("separation", 12)
	top.add_child(text_col)

	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.custom_minimum_size.y = UiShop.SEASON_TAG_H
	head.add_theme_constant_override("separation", 12)
	text_col.add_child(head)
	_eyebrow = Label.new()
	_eyebrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_eyebrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(_eyebrow)
	_tag = PanelContainer.new()
	_tag.name = "SeasonTag"
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag.visible = false
	_tag.custom_minimum_size.y = UiShop.SEASON_TAG_H
	_tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_tag)
	_tag_label = Label.new()
	_tag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tag_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tag.add_child(_tag_label)

	_name = Label.new()
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_col.add_child(_name)
	_tagline = Label.new()
	_tagline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_col.add_child(_tagline)

	_roster = GridContainer.new()
	_roster.name = "SeasonRoster"
	_roster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_roster.columns = 3
	_roster.custom_minimum_size.x = UiShop.SEASON_ROSTER_W
	_roster.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_roster.add_theme_constant_override("h_separation", UiShop.ROSTER_GAP)
	_roster.add_theme_constant_override("v_separation", UiShop.ROSTER_GAP)
	top.add_child(_roster)

	_fine = Label.new()
	_fine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fine.text = "6 flowers for your Album · same runs, same rewards"
	_fine.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_fine)

	_status = ShopPurchaseStatus.new()
	_status.name = "PurchaseStatus"
	col.add_child(_status)

	var action := HBoxContainer.new()
	action.name = "ActionRow"
	action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action.custom_minimum_size.y = UiShop.MONEY_ROW_H
	action.add_theme_constant_override("separation", 16)
	col.add_child(action)

	_price = ShopPriceTag.new()
	action.add_child(_price)

	_buy = _make_action(action)
	_buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buy.clicked.connect(func() -> void: buy_pressed.emit(sku))
	_home = _make_action(action)
	_home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_home.clicked.connect(func() -> void: open_home_pressed.emit(season_id))
	_soon_info = _make_action(action)
	_soon_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_soon_info.disabled = true
	_status.cleared.connect(func() -> void: apply(sku))


func _make_action(row: HBoxContainer) -> CampButton:
	var btn := CampButton.new()
	btn.label_text = ""
	btn.custom_minimum_size.y = UiShop.MONEY_ROW_H
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(btn)
	btn.set_fonts(UiShop.FONT_BUTTON, UiShop.FONT_BUTTON_SUB)
	btn.set_press_scale(0.97)
	return btn


func _refresh(def: SeasonDef) -> void:
	var soon := _state == UiShop.SEASON_SOON
	var owned := _state == UiShop.SEASON_OWNED
	var fill := UiShop.season_fill(season_id, soon)
	var ink := UiShop.season_ink(fill)
	var sub_ink := UiShop.season_sub_ink(fill)
	add_theme_stylebox_override("panel", UiShop.season_card_style(season_id, _state))

	_eyebrow.visible = not owned and not soon
	_eyebrow.text = "PREMIUM SEASON"
	UiShop.style(_eyebrow, UiShop.FONT_EYEBROW, sub_ink, UiShop.HEAVY)
	_tag.visible = owned or soon
	if _tag.visible:
		_tag.add_theme_stylebox_override("panel", UiShop.tag_style("soon" if soon else "yours"))
		_tag_label.text = "COMING SOON" if soon else "YOURS"
		UiShop.style(
			_tag_label, UiShop.FONT_EYEBROW, UiShop.CREAM if soon else UiShop.INK, UiShop.HEAVY
		)
	_name.text = def.display_name
	UiShop.style(_name, UiShop.FONT_SEASON_NAME, ink, UiShop.HEAVY)
	_tagline.text = def.tagline
	UiShop.style(_tagline, UiShop.FONT_BODY, sub_ink, UiShop.REGULAR, 1.2)
	UiShop.style(_fine, UiShop.FONT_BODY, sub_ink, UiShop.BOLD)
	_build_roster(def, soon)

	_price.visible = _state == UiShop.SEASON_BUY or _state == UiShop.SEASON_BUSY \
		or _state == UiShop.SEASON_DIM
	if _price.visible:
		_price.configure(IAPManager.get_price_label(sku), "one-time")
	_buy.visible = _price.visible
	_home.visible = owned
	_soon_info.visible = soon

	if _buy.visible:
		var busy_on_mood := true
		UiShopButtons.apply_money(
			_buy, _state, "Get %s" % def.display_name, "yours to keep", busy_on_mood
		)
	if _home.visible:
		_home.set_text("Play it on Home ↗", "owned · plays like a free season")
		var light := UiShop.is_light(fill)
		_home.set_styles(UiShop.open_on_home_style(light))
		_home.set_ink(ink)
		_home.disabled = false
	if _soon_info.visible:
		_soon_info.set_text("Not for sale yet", "no price until it’s ready")
		_soon_info.set_styles(UiShop.soon_info_style())
		_soon_info.set_ink(ink)


func _build_roster(def: SeasonDef, soon: bool) -> void:
	var want: int = maxi(6, def.roster.size())
	while _roster.get_child_count() < want:
		var well := PanelContainer.new()
		well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		well.custom_minimum_size = Vector2(UiShop.ROSTER_WELL, UiShop.ROSTER_WELL)
		var dot := Panel.new()
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dot.custom_minimum_size = Vector2(UiShop.ROSTER_DOT, UiShop.ROSTER_DOT)
		dot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		well.add_child(dot)
		_roster.add_child(well)
	for i in _roster.get_child_count():
		var slot := _roster.get_child(i) as PanelContainer
		slot.visible = i < want
		slot.add_theme_stylebox_override("panel", UiShop.roster_well_style())
		slot.modulate.a = 0.8 if soon else 1.0
		var dot := slot.get_child(0) as Panel
		dot.add_theme_stylebox_override("panel", UiShop.roster_dot_style(season_id, soon))
