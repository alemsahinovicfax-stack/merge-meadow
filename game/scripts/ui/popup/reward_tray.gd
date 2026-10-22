class_name RewardTray
extends Control

## Pop-up sistem · RewardTray: RIM ploča (radius 36, rub 3 ink 18 %) s RewardChipovima koji se
## prelamaju i centriraju (gap 16 / 16). Opcioni pečat (HalfStamp: roze pilula h 64, ikona ½ 44 +
## tekst 38/900) sjedi na gornjem lijevom rubu, pola iznad ploče.

## Bočni razmak (dizajn: 3 chipa „18 → 9" staju u jedan red od 824).
const PAD_X := 28.0

var chips: Array[RewardChip] = []
var stamp_text: String = ""
## Endless (design_handoff_leveli_endless · B6/B7): plijen ostaje cijeli — mint pečat s korpom
## („All yours", „If you quit · all yours") umjesto roze „Kept half" s ½.
var stamp_full: bool = false:
	set(v):
		stamp_full = v
		queue_redraw()
## Zlatni pečat desno (kraj runa: Loot Boost i Twin Seeds) — isti oblik kao HalfStamp, bez ikone.
var boost_text: String = ""
## Ako bi zlatni pečat udario u lijevi, crta se samo prvi dio (do „ · ").
var boost_short: String = ""

var _width: float = 880.0


func setup(width: float, p_chips: Array, p_stamp: String = "", p_boost: String = "") -> RewardTray:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_width = width
	stamp_text = p_stamp
	boost_text = p_boost
	boost_short = p_boost.get_slice(" · ", 0)
	for c in chips:
		if is_instance_valid(c):
			c.queue_free()
	chips.clear()
	for c in p_chips:
		var chip := c as RewardChip
		chips.append(chip)
		add_child(chip)
	_layout()
	return self


func pad_top() -> float:
	var stamped := not stamp_text.is_empty() or not boost_text.is_empty()
	return float(UiPopups.TRAY_PAD_STAMP if stamped else UiPopups.TRAY_PAD)


func _layout() -> void:
	var inner := _width - PAD_X * 2.0
	var rows: Array = []
	var row: Array = []
	var row_w := 0.0
	for chip in chips:
		var w := chip.custom_minimum_size.x
		var add := w if row.is_empty() else row_w + UiPopups.REWARD_CHIP_GAP.x + w
		if not row.is_empty() and add > inner:
			rows.append([row, row_w])
			row = []
			row_w = 0.0
			add = w
		row.append(chip)
		row_w = add
	if not row.is_empty():
		rows.append([row, row_w])
	var y := pad_top()
	for r in rows:
		var x := (_width - float(r[1])) * 0.5
		for chip: RewardChip in r[0]:
			chip.position = Vector2(x, y)
			chip.size = chip.custom_minimum_size
			x += chip.size.x + UiPopups.REWARD_CHIP_GAP.x
		y += UiPopups.CHIP_H + UiPopups.REWARD_CHIP_GAP.y
	var h := y - UiPopups.REWARD_CHIP_GAP.y + UiPopups.TRAY_PAD
	if rows.is_empty():
		h = pad_top() + UiPopups.TRAY_PAD
	custom_minimum_size = Vector2(_width, h)
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	draw_style_box(UiPopups.reward_tray(), Rect2(Vector2.ZERO, size))
	var left_end := 0.0
	if not stamp_text.is_empty():
		var tw := UiPopups.text_w(900, 38, stamp_text)
		var r := Rect2(31.0, -UiPopups.STAMP_H * 0.45, 13.0 + 44.0 + 10.0 + tw + 22.0, UiPopups.STAMP_H)
		draw_style_box(UiPopups._box(UiPopups.MINT, int(UiPopups.STAMP_H / 2.0), 3) if stamp_full else UiPopups.half_stamp(), r)
		UiPopups.draw_icon(self, UiPopups.icon("icon_basket" if stamp_full else "icon_half"), Vector2(r.position.x + 13.0 + 22.0, r.get_center().y), 44.0)
		UiPopups.draw_text(self, 900, 38, stamp_text, Vector2(r.position.x + 13.0 + 44.0 + 10.0, r.get_center().y - 19.0), UiPopups.OUTLINE)
		left_end = r.end.x
	var boost := shown_boost_text()
	if boost.is_empty():
		return
	var bw := UiPopups.text_w(900, 38, boost) + 44.0
	var br := Rect2(size.x - 31.0 - bw, -UiPopups.STAMP_H * 0.45, bw, UiPopups.STAMP_H)
	draw_style_box(UiPopups.boost_stamp(), br)
	UiPopups.draw_text(self, 900, 38, boost, Vector2(br.position.x + 22.0, br.get_center().y - 19.0), UiPopups.OUTLINE)


## Tekst zlatnog pečata kakav se crta (kraći kad bi udario u lijevi „Kept half").
func shown_boost_text() -> String:
	if boost_text.is_empty():
		return ""
	if stamp_text.is_empty():
		return boost_text
	var left_w := 31.0 + 13.0 + 44.0 + 10.0 + UiPopups.text_w(900, 38, stamp_text) + 22.0
	var full_w := UiPopups.text_w(900, 38, boost_text) + 44.0
	if _width - 31.0 - full_w >= left_w + 16.0:
		return boost_text
	return boost_short


## Nagrada iskoči chip po chip (nije loop).
func reveal() -> void:
	UiPopups.tween_reward_reveal(chips)
