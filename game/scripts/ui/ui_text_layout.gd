class_name UiTextLayout
extends RefCounted

const TYPO := preload("res://scripts/ui/ui_typography.gd")
const READABILITY := preload("res://scripts/ui/ui_readability.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")


static func ink(label: Label) -> void:
	if label == null:
		return
	label.add_theme_color_override("font_color", UI_PALETTE.UI_TEXT)


static func _apply_scroll_wrap(label: Label, font_px: int) -> void:
	label.add_theme_font_size_override("font_size", font_px)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ink(label)


static func screen_title(label: Label) -> void:
	label.add_theme_font_size_override("font_size", TYPO.SCREEN_TITLE)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


static func section_title(label: Label) -> void:
	label.add_theme_font_size_override("font_size", TYPO.SECTION_TITLE)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ink(label)


static func section_title_scroll(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.SECTION_TITLE)


static func card_title(label: Label) -> void:
	label.add_theme_font_size_override("font_size", TYPO.CARD_TITLE)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ink(label)


static func card_title_scroll(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.CARD_TITLE)


static func body_label(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.BODY)


static func body_label_scroll(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.BODY)


static func caption_label(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.CAPTION)


static func caption_label_scroll(label: Label) -> void:
	_apply_scroll_wrap(label, TYPO.CAPTION)


static func header_label(label: Label, max_lines: int = 2) -> void:
	label.add_theme_font_size_override("font_size", TYPO.SECTION_TITLE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = false
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ink(label)
	if max_lines > 0:
		label.max_lines_visible = max_lines


static func stat_label(label: Label) -> void:
	label.add_theme_font_size_override("font_size", TYPO.STAT_NUMBER)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	# Stats live on dark top bars — keep light ink.
	label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 1.0))


static func header_chip_count(label: Label) -> void:
	## Hub pastel chips — dark ink, no clip/ellipsis so the number stays visible.
	if label == null:
		return
	label.add_theme_font_size_override("font_size", 28)
	label.clip_text = false
	label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label.custom_minimum_size = Vector2(maxi(int(label.custom_minimum_size.x), 40), 0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ink(label)


static func body_label_readable(label: Label) -> void:
	_apply_scroll_wrap(label, READABILITY.font(TYPO.BODY))


static func card_title_scroll_readable(label: Label) -> void:
	_apply_scroll_wrap(label, READABILITY.font(TYPO.CARD_TITLE))


static func caption_label_scroll_readable(label: Label) -> void:
	_apply_scroll_wrap(label, READABILITY.font(TYPO.CAPTION))
