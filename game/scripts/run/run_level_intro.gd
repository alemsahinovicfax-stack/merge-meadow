class_name RunLevelIntro
extends Control

## A2 · najava levela na startu runa (design_handoff_leveli_endless · run_difficulty.json → intro).
## Krem ploča „Level 14 + pločica pojasa" (h 180) i pilula „Dash · 1:42" (h 88); za 1,12 s uleti u
## LevelChip (x −300, y 24, scale 0,36) i chip se trzne 1,08. Ne blokira swipe. Crta se jednom,
## animira se samo transform / alpha (6 čvorova u budžetu: ploča, tekst, pločica, pilula, disk, tekst).

var level: int = 1
var replay: bool = false
var duration_sec: float = 60.0

var _sub: _Sub
var _chip: Control
var _t: float = -1.0


func _init() -> void:
	name = "LevelIntro"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	size = Vector2(1080.0, UiLevels.INTRO_PLATE_H + UiLevels.INTRO_GAP + UiLevels.INTRO_SUB_H)
	pivot_offset = size * 0.5
	_sub = _Sub.new()
	_sub.intro = self
	add_child(_sub)
	set_process(false)


## `chip` = LevelChip u TopHudu (trzaj na kraju leta).
func play(p_level: int, p_replay: bool, p_duration: float, chip: Control) -> void:
	level = p_level
	replay = p_replay
	duration_sec = p_duration
	_chip = chip
	_sub.position = Vector2(0.0, UiLevels.INTRO_PLATE_H + UiLevels.INTRO_GAP)
	_sub.size = Vector2(size.x, UiLevels.INTRO_SUB_H)
	_sub.pivot_offset = _sub.size * 0.5
	queue_redraw()
	_sub.queue_redraw()
	_t = 0.0
	visible = true
	_apply(0.0)
	set_process(true)


func is_playing() -> bool:
	return _t >= 0.0


func sub_text() -> String:
	var name_txt := UiLevels.S_REPLAY if replay else str(UiLevels.band(UiLevels.band_of(level))["name"])
	return "%s · %s" % [name_txt, _fmt_dur(duration_sec)]


func plate_text() -> String:
	return "Level %d" % level


func stop() -> void:
	_t = -1.0
	visible = false
	set_process(false)
	if is_instance_valid(_chip):
		_chip.scale = Vector2.ONE


func _process(delta: float) -> void:
	# Godot sam uključi _process kad čvor uđe u stablo — miruj dok efekat ne krene.
	if _t < 0.0:
		set_process(false)
		return
	_t += delta
	_apply(_t)
	if _t >= UiLevels.INTRO_CHIP_BUMP.y:
		stop()


func _apply(u: float) -> void:
	var pop := UiLevels.out_back(UiLevels.clamp01(u / UiLevels.INTRO_POP))
	var sub := UiLevels.out3(UiLevels.clamp01((u - UiLevels.INTRO_SUB.x) / (UiLevels.INTRO_SUB.y - UiLevels.INTRO_SUB.x)))
	var fly := UiLevels.io2(UiLevels.clamp01((u - UiLevels.INTRO_FLY.x) / (UiLevels.INTRO_FLY.y - UiLevels.INTRO_FLY.x)))
	var y := UiLevels.INTRO_Y + (UiLevels.INTRO_FLY_TO.y - UiLevels.INTRO_Y) * fly
	position = Vector2(UiLevels.INTRO_FLY_TO.x * fly, y)
	scale = Vector2.ONE * (0.9 + 0.1 * pop) * (1.0 - (1.0 - UiLevels.INTRO_FLY_SCALE) * fly)
	modulate.a = UiLevels.clamp01(u / 0.08) * (1.0 - UiLevels.clamp01((fly - 0.7) / 0.3))
	visible = u < UiLevels.INTRO_TOTAL
	_sub.modulate.a = sub * (1.0 - fly)
	_sub.position.y = UiLevels.INTRO_PLATE_H + UiLevels.INTRO_GAP - 24.0 * (1.0 - sub)
	if is_instance_valid(_chip):
		_chip.pivot_offset = _chip.size * 0.5
		_chip.scale = Vector2.ONE * (1.0 + 0.08 * UiLevels.bell(u, UiLevels.INTRO_CHIP_BUMP.x, UiLevels.INTRO_CHIP_BUMP.y))


func _draw() -> void:
	var txt := plate_text()
	var tag := UiLevels.tag_tex(level)
	var tag_w := UiLevels.INTRO_TAG_H * UiLevels.tag_size(level).x / UiLevels.tag_size(level).y
	var tw := UiPopups.text_w(900, UiLevels.INTRO_FONT, txt)
	var w := UiLevels.INTRO_PLATE_PAD * 2.0 + tw + UiLevels.INTRO_PLATE_GAP + tag_w
	var r := Rect2((size.x - w) * 0.5, 0.0, w, UiLevels.INTRO_PLATE_H)
	var sb := UiPopups._hard_shadow(UiPopups._box(UiLevels.CREAM, int(UiLevels.INTRO_PLATE_H * 0.5), 5), 12, Color(0.039, 0.055, 0.047, 0.55))
	draw_style_box(sb, r)
	var x := r.position.x + UiLevels.INTRO_PLATE_PAD
	UiPopups.draw_text(self, 900, UiLevels.INTRO_FONT, txt, Vector2(x, r.get_center().y - UiLevels.INTRO_FONT * 0.5), UiLevels.INK)
	x += tw + UiLevels.INTRO_PLATE_GAP
	if tag:
		draw_texture_rect(tag, Rect2(x, r.get_center().y - UiLevels.INTRO_TAG_H * 0.5, tag_w, UiLevels.INTRO_TAG_H), false)


static func _fmt_dur(sec: float) -> String:
	var s := roundi(sec)
	return "%d:%02d" % [s / 60, s % 60]


## Pilula ispod ploče: disk boje pojasa sa satom + „Dash · 1:42" (ili „Replay · 2:00").
class _Sub extends Control:
	var intro: RunLevelIntro

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if intro == null:
			return
		var txt := intro.sub_text()
		var h := UiLevels.INTRO_SUB_H
		var disc := UiLevels.INTRO_SUB_DISC
		var w := 18.0 + disc + 14.0 + UiPopups.text_w(900, UiLevels.INTRO_SUB_FONT, txt) + 34.0
		var r := Rect2((size.x - w) * 0.5, 0.0, w, h)
		draw_style_box(UiPopups._box(UiLevels.CREAM, int(h * 0.5), 4), r)
		var dc := Vector2(r.position.x + 18.0 + disc * 0.5, r.get_center().y)
		var fill := UiLevels.band_fill(UiLevels.band_of(intro.level))
		draw_style_box(UiPopups._box(fill, int(disc * 0.5), 3), Rect2(dc - Vector2(disc, disc) * 0.5, Vector2(disc, disc)))
		# Sat: krug 26 (rub 5) + kazaljka 4 × 9.
		draw_arc(dc, 10.5, 0.0, TAU, 28, UiLevels.INK, 5.0, true)
		draw_rect(Rect2(dc + Vector2(-2.0, -11.0), Vector2(4.0, 9.0)), UiLevels.INK)
		UiPopups.draw_text(self, 900, UiLevels.INTRO_SUB_FONT, txt, Vector2(dc.x + disc * 0.5 + 14.0, r.get_center().y - UiLevels.INTRO_SUB_FONT * 0.5), UiLevels.INK)
