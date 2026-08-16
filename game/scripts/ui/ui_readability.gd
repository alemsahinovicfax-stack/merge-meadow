class_name UiReadability
extends RefCounted

## Blago povećanje fonta (+2 px) — bez tree walkera i bez lomljenja layouta.

const TYPO := preload("res://scripts/ui/ui_typography.gd")
const FONT_BUMP := 2


static func font(base: int) -> int:
	if base <= 0:
		base = TYPO.BODY
	return base + FONT_BUMP


static func button_font() -> int:
	return font(TYPO.BUTTON)
