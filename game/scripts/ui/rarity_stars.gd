extends RefCounted

## Filled rarity stars only — no empty silhouettes.

const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")

const FILLED := "★"


static func make_row(rarity: int, font_size: int = 26) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "StarsRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_theme_constant_override("separation", 2)
	apply_row(row, rarity, font_size)
	return row


static func apply_row(row: HBoxContainer, rarity: int, font_size: int = 26) -> void:
	if row == null:
		return
	var filled := clampi(rarity, 0, 3)
	while row.get_child_count() > filled:
		var last := row.get_child(row.get_child_count() - 1)
		row.remove_child(last)
		last.queue_free()
	while row.get_child_count() < filled:
		var lab := Label.new()
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(lab)
	for child in row.get_children():
		if not child is Label:
			continue
		var lab := child as Label
		lab.text = FILLED
		lab.add_theme_font_size_override("font_size", font_size)
		lab.add_theme_color_override("font_color", UI_PALETTE.GOLD)
