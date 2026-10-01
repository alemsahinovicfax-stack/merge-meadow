class_name ItemCard
extends WardrobePressable

## Ormar · ItemCard (design_handoff_wardrobe/design/ItemCard.dc.html) — JEDNA kartica
## za sve slotove i za Default. 240 x 272, padding 12, ItemPreview 210 x 150,
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


func _ready() -> void:
	custom_minimum_size = Vector2(UiWardrobe.CARD)
	size = custom_minimum_size
	press_scale = 0.97
	_build()
	_sync()


func is_default() -> bool:
	return item_id.is_empty()


## slot: zapis slota iz kataloga; item: zapis stavke ({} = Default).
func setup(slot: Dictionary, item: Dictionary, p_state: String, p_new: bool, pip_recolor: Dictionary, season: String) -> void:
	slot_id = str(slot.get("id", ""))
	item_id = str(item.get("id", ""))
	state = p_state
	is_new = p_new and state != UiWardrobe.CARD_NONE
	title = str(item.get("title", "")) if not item.is_empty() else str(slot.get("default_title", "Default"))
	name = ("DefaultCard" if item.is_empty() else "ItemCard_%s" % item_id)
	enabled = state != UiWardrobe.CARD_NONE
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
	_badge.queue_redraw()
	_new_tag.queue_redraw()
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


func _draw_new_tag() -> void:
	var r := Rect2(Vector2.ZERO, _new_tag.size)
	_new_tag.draw_style_box(UiWardrobe.new_tag(), r)
	var w := UiHomeV3.text_w(900, UiWardrobe.MIN_TEXT, UiWardrobe.NEW_TEXT)
	UiHomeV3.draw_text(
		_new_tag, 900, UiWardrobe.MIN_TEXT, UiWardrobe.NEW_TEXT,
		Vector2((r.size.x - w) * 0.5, (r.size.y - float(UiWardrobe.MIN_TEXT)) * 0.5), UiWardrobe.INK
	)
