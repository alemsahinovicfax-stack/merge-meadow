class_name ShopCosmeticPreview
extends Control

## Pregled kozmetike u Shopu (design_handoff_shop · components.CosmeticPreview).
## Dvije polovine "Now | With it"; kad je predmet opremljen, ostaje jedna.
## Staza i Pip se crtaju istim bojama kao run (UiRun x meadow modulate x sezona),
## Album je krem stranica s 4 reda i zlatnim ramom kad je skin journal_gold.

const TITLE_PATH := "res://assets/ui/title_bloom_album.png"

var item_id: String = ""
var single: bool = false

var _now_chip: PanelContainer
var _with_chip: PanelContainer
var _now_label: Label
var _with_label: Label
var _title_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	custom_minimum_size = UiShop.PREVIEW_SIZE
	_build_chips()
	_sync_chips()


func configure(cosmetic_id: String, single_view: bool) -> void:
	item_id = cosmetic_id
	single = single_view
	_sync_chips()
	queue_redraw()


func get_half_count() -> int:
	return 1 if single else 2


func _build_chips() -> void:
	_now_chip = _make_chip()
	_now_label = _now_chip.get_child(0) as Label
	_now_label.text = "Now"
	add_child(_now_chip)
	_with_chip = _make_chip()
	_with_label = _with_chip.get_child(0) as Label
	_with_label.text = "With it"
	add_child(_with_chip)


func _make_chip() -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.custom_minimum_size.y = UiShop.LABEL_CHIP_H
	chip.add_theme_stylebox_override("panel", UiShop.label_chip_style())
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiShop.style(label, UiShop.FONT_BODY, UiShop.CREAM, UiShop.BOLD)
	chip.add_child(label)
	return chip


func _sync_chips() -> void:
	if _now_chip == null or _with_chip == null:
		return
	_now_chip.visible = not single
	_with_chip.visible = not single
	_place_chips()


func _place_chips() -> void:
	if _now_chip == null or _with_chip == null or single:
		return
	var half_w := _half_width()
	for pair in [[_now_chip, 0.0], [_with_chip, half_w + float(UiShop.PREVIEW_HALF_GAP)]]:
		var chip: PanelContainer = pair[0]
		chip.reset_size()
		chip.position = Vector2(
			float(pair[1]) + 10.0, size.y - chip.size.y - 10.0
		)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_place_chips()
		queue_redraw()


func _half_width() -> float:
	if single:
		return size.x
	return (size.x - float(UiShop.PREVIEW_HALF_GAP)) * 0.5


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var slot := CosmeticCatalog.get_slot(item_id)
	var equipped := GameState.get_equipped_cosmetic(slot)
	var half_w := _half_width()
	if single:
		_draw_half(Rect2(Vector2.ZERO, Vector2(half_w, size.y)), slot, item_id)
		return
	_draw_half(Rect2(Vector2.ZERO, Vector2(half_w, size.y)), slot, equipped)
	_draw_half(
		Rect2(Vector2(half_w + float(UiShop.PREVIEW_HALF_GAP), 0.0), Vector2(half_w, size.y)),
		slot,
		item_id
	)


func _draw_half(rect: Rect2, slot: String, shown_id: String) -> void:
	if slot == CosmeticCatalog.SLOT_JOURNAL_FRAME:
		_draw_album(rect, shown_id == "journal_gold")
		return
	var meadow_id := shown_id if slot == CosmeticCatalog.SLOT_MEADOW_BG \
		else GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_MEADOW_BG)
	var pip_id := shown_id if slot == CosmeticCatalog.SLOT_PIP_SKIN \
		else GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_PIP_SKIN)
	_draw_lane(rect, meadow_id)
	_draw_pip(rect, pip_id)


func _draw_lane(rect: Rect2, meadow_id: String) -> void:
	var c := UiShop.preview_lane_colors(meadow_id, GameState.active_season_id)
	draw_rect(rect, c["ground"])
	var lane := Rect2(
		rect.position + Vector2((rect.size.x - float(UiShop.LANE_W)) * 0.5, 0.0),
		Vector2(float(UiShop.LANE_W), rect.size.y)
	)
	draw_rect(lane, c["lane"])
	var edge := float(UiShop.LANE_EDGE_W)
	draw_rect(Rect2(lane.position, Vector2(edge, lane.size.y)), c["edge"])
	draw_rect(
		Rect2(Vector2(lane.end.x - edge, lane.position.y), Vector2(edge, lane.size.y)), c["edge"]
	)
	for top in UiShop.MOW_TOPS:
		draw_rect(
			Rect2(
				Vector2(lane.position.x + edge, rect.position.y + float(top)),
				Vector2(lane.size.x - edge * 2.0, float(UiShop.MOW_H))
			),
			c["mow"]
		)
	var left_x := rect.position.x + rect.size.x * 0.16
	var right_x := rect.end.x - rect.size.x * 0.16
	draw_circle(Vector2(left_x, rect.position.y + 60.0), 14.0, c["tuft"])
	draw_circle(Vector2(left_x + 18.0, rect.position.y + 74.0), 14.0, c["tuft"])
	draw_circle(Vector2(right_x, rect.position.y + 190.0), 16.0, c["tuft"])
	draw_circle(Vector2(left_x + 6.0, rect.position.y + 128.0), 6.0, c["petal"])
	draw_circle(Vector2(right_x - 14.0, rect.position.y + 96.0), 5.0, c["petal"])
	draw_circle(Vector2(left_x - 10.0, rect.position.y + 214.0), 5.0, c["petal"])


func _draw_pip(rect: Rect2, pip_id: String) -> void:
	var palette: Dictionary = UiShop.preview_pip_palette(pip_id)
	var shadow_center := Vector2(
		rect.position.x + rect.size.x * 0.5, rect.end.y - 24.0
	)
	draw_set_transform(shadow_center, 0.0, Vector2(1.0, 0.26))
	draw_circle(Vector2.ZERO, 50.0, UiShop.PIP_SHADOW)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if palette.is_empty():
		var tex := PipAssets.get_texture()
		if tex != null:
			var side := float(UiShop.PIP_SPRITE)
			var pos := Vector2(
				rect.position.x + (rect.size.x - side) * 0.5,
				rect.end.y - side - float(UiShop.PIP_SPRITE_BOTTOM)
			)
			draw_texture_rect(tex, Rect2(pos, Vector2(side, side)), false)
			return
	var center := Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.end.y - float(UiShop.PIP_DRAW_BOTTOM) - 66.0
	)
	PipDraw.draw_pip(self, center, UiShop.PIP_DRAW_SCALE, palette)


func _draw_album(rect: Rect2, gold: bool) -> void:
	draw_rect(rect, UiShop.WELL)
	var inset := float(UiShop.ALBUM_INSET)
	var page := Rect2(rect.position + Vector2(inset, inset), rect.size - Vector2(inset, inset) * 2.0)
	draw_rect(page, UiShop.CREAM)
	if _title_tex == null and ResourceLoader.exists(TITLE_PATH):
		_title_tex = load(TITLE_PATH) as Texture2D
	var pad := 14.0
	var title_h := 40.0
	var title_w := minf(page.size.x - pad * 2.0, 520.0)
	var title_pos := Vector2(page.position.x + (page.size.x - title_w) * 0.5, page.position.y + pad)
	if _title_tex != null:
		var modulate_col := Color(0.8, 0.8, 0.8, 1.0) if gold else Color.WHITE
		draw_texture_rect(
			_title_tex, Rect2(title_pos, Vector2(title_w, title_h)), false, modulate_col
		)
	var row_h := float(UiShop.ALBUM_ROW_H_FRAMED if gold else UiShop.ALBUM_ROW_H)
	var gap := 10.0
	var y := title_pos.y + title_h + pad
	var rows := [
		UiPalette.rarity_bg_color(1),
		UiPalette.rarity_bg_color(2),
		UiPalette.rarity_bg_color(3),
		UiPalette.rarity_bg_color(1, true),
	]
	for color in rows:
		var row := Rect2(
			Vector2(page.position.x + pad, y), Vector2(page.size.x - pad * 2.0, row_h)
		)
		if row.end.y > page.end.y - pad:
			break
		draw_rect(row, color)
		y += row_h + gap
	if gold:
		var w := float(UiShop.ALBUM_FRAME_W)
		var frame := page
		draw_rect(Rect2(frame.position, Vector2(frame.size.x, w)), UiShop.ALBUM_FRAME)
		draw_rect(
			Rect2(Vector2(frame.position.x, frame.end.y - w), Vector2(frame.size.x, w)),
			UiShop.ALBUM_FRAME
		)
		draw_rect(Rect2(frame.position, Vector2(w, frame.size.y)), UiShop.ALBUM_FRAME)
		draw_rect(
			Rect2(Vector2(frame.end.x - w, frame.position.y), Vector2(w, frame.size.y)),
			UiShop.ALBUM_FRAME
		)
