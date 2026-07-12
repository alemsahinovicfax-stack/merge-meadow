class_name CompanionConfig
extends RefCounted

## Launch companions — cosmetic only (v1).

const ID_PIP := "pip"
const ID_MOCHI := "mochi"

## Kamp level = Sprinkler Lv + Loot Boost Lv (0–8). Mochi at 2+.
const MOCHI_UNLOCK_CAMP_LEVEL := 2

const DISPLAY_NAMES: Dictionary = {
	ID_PIP: "Pip",
	ID_MOCHI: "Mochi",
}

const RUN_DISPLAY_HEIGHT := 112.0
const SOURCE_FRAME_SIZE := 256.0


static func display_name(companion_id: String) -> String:
	return str(DISPLAY_NAMES.get(companion_id, companion_id.capitalize()))


static func run_scale() -> float:
	return RUN_DISPLAY_HEIGHT / SOURCE_FRAME_SIZE


static func ui_scale_for_side(side: float) -> float:
	if side < 1.0:
		return 1.0
	return side / SOURCE_FRAME_SIZE
