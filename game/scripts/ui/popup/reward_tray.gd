class_name RewardTray
extends Control

## Pop-up sistem · RewardTray: RIM ploča (radius 36, rub 3 ink 18 %) s RewardChipovima koji se
## prelamaju i centriraju (gap 16 / 16). Opcioni pečat (HalfStamp: roze pilula h 64, ikona ½ 44 +
## tekst 38/900) sjedi na gornjem lijevom rubu, pola iznad ploče.

## Bočni razmak (dizajn: 3 chipa „18 → 9" staju u jedan red od 824).
const PAD_X := 28.0

var chips: Array[RewardChip] = []
var stamp_text: String = ""

var _width: float = 880.0


func setup(width: float, p_chips: Array, p_stamp: String = "") -> RewardTray:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_width = width
	stamp_text = p_stamp
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
	return float(UiPopups.TRAY_PAD_STAMP if not stamp_text.is_empty() else UiPopups.TRAY_PAD)


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
	if stamp_text.is_empty():
		return
	var tw := UiPopups.text_w(900, 38, stamp_text)
	var r := Rect2(31.0, -UiPopups.STAMP_H * 0.45, 13.0 + 44.0 + 10.0 + tw + 22.0, UiPopups.STAMP_H)
	draw_style_box(UiPopups.half_stamp(), r)
	UiPopups.draw_icon(self, UiPopups.icon("icon_half"), Vector2(r.position.x + 13.0 + 22.0, r.get_center().y), 44.0)
	UiPopups.draw_text(self, 900, 38, stamp_text, Vector2(r.position.x + 13.0 + 44.0 + 10.0, r.get_center().y - 19.0), UiPopups.OUTLINE)


## Nagrada iskoči chip po chip (nije loop).
func reveal() -> void:
	UiPopups.tween_reward_reveal(chips)
