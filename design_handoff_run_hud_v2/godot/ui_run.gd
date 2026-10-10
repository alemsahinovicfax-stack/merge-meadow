# ui_run.gd — Run HUD v2 (only changes; names kept where they exist)
class_name UiRun
extends RefCounted

# --- TopHud: one row ---
const TOP_HUD_Y := 60
const TOP_HUD_H := 128
const LEVEL_CHIP_RECT := Rect2(40, 60, 200, 128)   # width grows with text, max 464
const LEVEL_CHIP_MAX_W := 464
const LEVEL_CHIP_PAD_X := 32
const LEVEL_FONT_PX := 48
const LEVEL_FONT_PX_ENDLESS := 42
const COIN_CHIP_RECT := Rect2(520, 60, 180, 128)
const SEED_CHIP_RECT := Rect2(716, 60, 180, 128)
const PAUSE_RECT := Rect2(912, 60, 128, 128)
const CHIP_ICON := 52
const CHIP_NUMBER_PX := 56
const CHIP_BG := Color("#FFF8F0")
const CHIP_RIM := Color("#CBC2B6")
const CHIP_RADIUS := 30
const CHIP_SHADOW := Vector2(0, 6)
const CHIP_SHADOW_COLOR := Color(0.07, 0.11, 0.086, 0.42)
const INK := Color("#2D3436")

# Removed in v2: TIMER_RING_*, TIMER_SECONDS_*, COMPANION_CHIP_*, BASKET_BADGE_*, DIAMOND_CHIP_*

# --- ProgressRail (left band x 24–140) ---
const RAIL_RECT := Rect2(24, 200, 116, 1540)
const RAIL_TRACK := Rect2(70, 300, 28, 1400)
const RAIL_FILL := Color("#A8E6CF")
const RAIL_FILL_LOW := Color("#FFB88C")
const RAIL_LOW_REMAINING := 0.17
const RAIL_PIP_SIZE := 92
const RAIL_PIP_CENTER_X := 82.0
const RAIL_Y_START := 1700.0
const RAIL_Y_GOAL := 300.0

# --- RewardBush ---
const BUSH_SIZE := Vector2(120, 140)
const BUSH_SEAMS := [405, 675]
const BUSH_PIVOT := Vector2(60, 124)
const BUSH_IDLE_ROT_DEG := 5.0
const BUSH_IDLE_SCALE_Y := 1.04
const BUSH_IDLE_PERIOD := 0.9
const BUSH_BURST_TIME := 0.25
const BUSH_FLY_TIME := 0.35
const BUSH_FLY_ARC := 140.0
const BUSH_MAX_FLY_SPRITES := 4
const BUSH_LEAVES := 6

# --- DiamondPop ---
const DIAMOND_POP_TIME := 0.5
const DIAMOND_POP_RISE := 60.0


static func timer_lines(is_endless: bool, difficulty: String, uses_level_config: bool, level: int) -> String:
	if is_endless:
		return "Endless · %s" % difficulty
	if not uses_level_config:
		return "Practice"
	return "Level %d" % level


static func rail_visible(is_endless: bool) -> bool:
	return not is_endless


# Call from _process; only moves a node and swaps a color at the threshold — no redraw.
static func rail_pip_y(progress: float) -> float:
	return lerpf(RAIL_Y_START, RAIL_Y_GOAL, clampf(progress, 0.0, 1.0)) - RAIL_PIP_SIZE * 0.5


static func rail_fill_color(progress: float) -> Color:
	return RAIL_FILL_LOW if (1.0 - progress) < RAIL_LOW_REMAINING else RAIL_FILL


static func bush_idle_tween(node: Node2D) -> Tween:
	var t := node.create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "rotation_degrees", BUSH_IDLE_ROT_DEG, BUSH_IDLE_PERIOD * 0.5).from(-BUSH_IDLE_ROT_DEG)
	t.parallel().tween_property(node, "scale:y", BUSH_IDLE_SCALE_Y, BUSH_IDLE_PERIOD * 0.5).from(1.0)
	t.tween_property(node, "rotation_degrees", -BUSH_IDLE_ROT_DEG, BUSH_IDLE_PERIOD * 0.5)
	t.parallel().tween_property(node, "scale:y", 1.0, BUSH_IDLE_PERIOD * 0.5)
	return t
