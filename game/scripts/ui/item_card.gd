class_name ItemCard
extends WardrobePressable

## Ormar · ItemCard (design_handoff_wardrobe/design/ItemCard.dc.html) — JEDNA kartica
## za sve slotove i za Default (u Pip slotu je to Classic Pip s oznakom „Free", settings_fixes). 240 x 272, padding 12, ItemPreview 210 x 150,
## ime 38/40 (2 reda, balance). Stanja: worn (ACTIVE_RIM + rub 4 + ✓ 60),
## owned (bijela, rub 3 ROW_EDGE), none (DISABLED + veo s katancem, ne prima tap —
## samo za stavke drugog izvora: season / event).

var slot_id: String = ""
var item_id: String = ""    # "" = Default
var state: String = UiWardrobe.CARD_OWNED
var is_new: bool = false
var title: String = ""

var preview: ItemPreview
var _badge: Control
var _new_tag: Control
var _free_tag: Control

## Iznad Pip riga u pregledu (HOST_LIFT 4 + dijelovi do 11).
const TAG_Z := 16


func _ready() -> void:
	# Izbor pušta „wear" u WardrobeSheet.pick (nekupljen Sir Pip vodi u Shop uz swipe zvuk).
	tap_sfx = ""
	custom_minimum_size = Vector2(UiWardrobe.CARD)
	size = custom_minimum_size
	press_scale = 0.97
	_build()
	_sync()


func is_default() -> bool:
	return item_id.is_empty()


## Classic Pip: zadana kartica Pip slota je pravi skin s oznakom „Free".
func is_free_skin() -> bool:
	return is_default() and slot_id == CosmeticCatalog.SLOT_PIP_SKIN


## Premium skin za pravi novac (Sir Pip): oznaka „Premium"; nekupljen je pod velom, a tap
## vodi u Shop na njegovu karticu.
func is_premium() -> bool:
	return not is_default() and CosmeticCatalog.is_iap_item(item_id)


## slot: zapis slota iz kataloga; item: zapis stavke ({} = Default).
func setup(slot: Dictionary, item: Dictionary, p_state: String, p_new: bool, pip_recolor: Dictionary, season: String) -> void:
	slot_id = str(slot.get("id", ""))
	item_id = str(item.get("id", ""))
	state = p_state
	is_new = p_new and state != UiWardrobe.CARD_NONE
	title = str(item.get("title", "")) if not item.is_empty() else str(slot.get("default_title", "Default"))
	name = ("DefaultCard" if item.is_empty() else "ItemCard_%s" % item_id)
	enabled = state != UiWardrobe.CARD_NONE or is_premium()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	if preview == null:
		_build()
	var args: Dictionary = slot.get("preview_args", {})
	preview.configure(
		str(slot.get("preview", "swatch")), item.get("look", {}), pip_recolor, season,
		str(args.get("subject", "pip"))
	)
	_sync()


func set_state(p_state: String) -> void:
	state = p_state
	_sync()


func _border() -> float:
	return 4.0 if state == UiWardrobe.CARD_WORN else 3.0


func _fill() -> Color:
	match state:
		UiWardrobe.CARD_WORN:
			return UiWardrobe.ACTIVE_RIM
		UiWardrobe.CARD_NONE:
			return UiWardrobe.DISABLED
		_:
			return UiWardrobe.ROW_FILL


func _build() -> void:
	if preview != null:
		return
	preview = ItemPreview.new()
	preview.name = "ItemPreview"
	preview.preview_size = ItemPreview.SIZE_THUMB
	preview.size = Vector2(UiWardrobe.CARD_PREVIEW)
	add_child(preview)
	_badge = Control.new()
	_badge.name = "EquippedBadge"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.size = Vector2(UiWardrobe.BADGE, UiWardrobe.BADGE)
	_badge.draw.connect(_draw_badge)
	add_child(_badge)
	_new_tag = Control.new()
	_new_tag.name = "NewTag"
	_new_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_new_tag.draw.connect(_draw_new_tag)
	add_child(_new_tag)
	_free_tag = Control.new()
	_free_tag.name = "FreeTag"
	_free_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_free_tag.draw.connect(_draw_free_tag)
	add_child(_free_tag)
	# Dijelovi Pip riga imaju z do 11 (UiPip._part_z): oznake i kvačica moraju biti iznad.
	for tag in [_badge, _new_tag, _free_tag]:
		tag.z_index = TAG_Z


func _sync() -> void:
	if preview == null:
		return
	var b := _border()
	var pad := b + float(UiWardrobe.CARD_PAD)
	preview.position = Vector2(pad, pad)
	preview.size = Vector2(UiWardrobe.CARD_PREVIEW)
	preview.set_frame(3.0, float(UiWardrobe.CARD_PREVIEW_RADIUS), UiWardrobe.WELL_EDGE, _fill())
	preview.veil = state == UiWardrobe.CARD_NONE
	preview.queue_redraw()
	_badge.visible = state == UiWardrobe.CARD_WORN
	_badge.position = Vector2(size.x - b - UiWardrobe.BADGE_INSET - UiWardrobe.BADGE, b + UiWardrobe.BADGE_INSET)
	_new_tag.visible = is_new
	var tag_w := UiHomeV3.text_w(900, UiWardrobe.MIN_TEXT, UiWardrobe.NEW_TEXT) + 28.0 + 6.0
	_new_tag.size = Vector2(ceilf(tag_w), UiWardrobe.NEW_TAG_H)
	_new_tag.position = Vector2(b + UiWardrobe.BADGE_INSET, b + UiWardrobe.BADGE_INSET)
	_free_tag.visible = is_free_skin() or is_premium()
	if is_premium():
		# „Special" S (design_handoff_ads_only · premium_tag.json) na istom mjestu kao „Free".
		_free_tag.size = SpecialTag.tag_size("S")
	else:
		var free_w := UiHomeV3.text_w(900, UiWardrobe.UNDER_TAG_PX, _tag_text()) + UiWardrobe.UNDER_TAG_PAD_X * 2.0
		_free_tag.size = Vector2(ceilf(free_w), UiWardrobe.UNDER_TAG_H)
	var name_top := pad + float(UiWardrobe.CARD_PREVIEW.y) + 12.0
	_free_tag.position = Vector2(pad, name_top + float(UiWardrobe.CARD_NAME_LINE) + UiWardrobe.UNDER_TAG_GAP)
	_badge.queue_redraw()
	_new_tag.queue_redraw()
	_free_tag.queue_redraw()
	queue_redraw()


func _draw() -> void:
	draw_style_box(UiWardrobe.card(state), Rect2(Vector2.ZERO, size))
	var b := _border()
	var x := b + float(UiWardrobe.CARD_PAD)
	var y := x + float(UiWardrobe.CARD_PREVIEW.y) + 12.0
	var max_w := size.x - x * 2.0
	var f := UiStage.font(900, UiWardrobe.CARD_NAME_PX)
	var lines := UiStage.balance_lines(title, f, UiWardrobe.CARD_NAME_PX, max_w)
	var ink := UiWardrobe.card_ink(state)
	var lh := float(UiWardrobe.CARD_NAME_LINE)
	for i in mini(2, lines.size()):
		var top := y + float(i) * lh + (lh - float(UiWardrobe.CARD_NAME_PX)) * 0.5
		UiHomeV3.draw_text(self, 900, UiWardrobe.CARD_NAME_PX, lines[i], Vector2(x, top), ink)


func _draw_badge() -> void:
	var s := Vector2(UiWardrobe.BADGE, UiWardrobe.BADGE)
	_badge.draw_style_box(UiWardrobe.badge(), Rect2(Vector2.ZERO, s))
	# SVG: M7 16.5 l6 6 L25 10 u kutiji 32, potez 5 krem.
	var o := (s - Vector2(32, 32)) * 0.5
	_badge.draw_polyline(
		PackedVector2Array([o + Vector2(7, 16.5), o + Vector2(13, 22.5), o + Vector2(25, 10)]),
		UiWardrobe.STICKER, 5.0, true
	)
	for p in [o + Vector2(7, 16.5), o + Vector2(25, 10)]:
		_badge.draw_circle(p, 2.5, UiWardrobe.STICKER)


func _tag_text() -> String:
	return SpecialTag.LABEL if is_premium() else UiWardrobe.FREE_TEXT


func _draw_free_tag() -> void:
	if is_premium():
		SpecialTag.draw_tag(_free_tag, Vector2.ZERO, "S")
		return
	var r := Rect2(Vector2.ZERO, _free_tag.size)
	_free_tag.draw_style_box(UiWardrobe.free_tag(), r)
	var text := _tag_text()
	var w := UiHomeV3.text_w(900, UiWardrobe.UNDER_TAG_PX, text)
	UiHomeV3.draw_text(
		_free_tag, 900, UiWardrobe.UNDER_TAG_PX, text,
		Vector2((r.size.x - w) * 0.5, (r.size.y - float(UiWardrobe.UNDER_TAG_PX)) * 0.5), UiWardrobe.INK
	)


func _draw_new_tag() -> void:
	var r := Rect2(Vector2.ZERO, _new_tag.size)
	_new_tag.draw_style_box(UiWardrobe.new_tag(), r)
	var w := UiHomeV3.text_w(900, UiWardrobe.MIN_TEXT, UiWardrobe.NEW_TEXT)
	UiHomeV3.draw_text(
		_new_tag, 900, UiWardrobe.MIN_TEXT, UiWardrobe.NEW_TEXT,
		Vector2((r.size.x - w) * 0.5, (r.size.y - float(UiWardrobe.MIN_TEXT)) * 0.5), UiWardrobe.INK
	)
