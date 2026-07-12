class_name UiReadability
extends RefCounted

## Blago povećanje fonta (+2 px) — bez tree walkera i bez lomljenja layouta.

const FONT_BUMP := 2


static func font(base: int) -> int:
	if base <= 0:
		base = 16
	return base + FONT_BUMP
