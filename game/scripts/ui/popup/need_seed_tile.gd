class_name NeedSeedTile
extends Control

## A3 · pločica u „You need more seeds!" (design_handoff_popups): 264 × 244, bijela, rub 3 ink 18 %,
## radius 32; crtež sjemena iz igre i 4 tačke napretka (44 × 22, mint = imaš) umjesto teksta „n/4".

const SET_SIZE := 4
const ART_BOX := 168.0
const ART_CY := 92.0
const DOTS_Y := 190.0
const DOT_GAP := 10.0

var type_id: String = ""
var have: int = 0


func setup(p_type: String, p_have: int) -> NeedSeedTile:
	type_id = p_type
	have = p_have
	name = "NeedSeedTile_%s" % p_type
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(UiPopups.NEED_TILE)
	queue_redraw()
	return self


func get_type_id() -> String:
	return type_id


func get_count_label_text() -> String:
	return "%d/%d" % [mini(have, SET_SIZE), SET_SIZE]


func _draw() -> void:
	draw_style_box(UiPopups.need_tile(), Rect2(Vector2.ZERO, size))
	UiPopups.draw_flower(self, Vector2(size.x * 0.5, ART_CY), type_id, 1, ART_BOX)
	var dot := Vector2(UiPopups.NEED_DOT)
	var w := dot.x * SET_SIZE + DOT_GAP * (SET_SIZE - 1)
	var x := (size.x - w) * 0.5
	for i in SET_SIZE:
		draw_style_box(UiPopups.need_dot(i < have), Rect2(Vector2(x, DOTS_Y), dot))
		x += dot.x + DOT_GAP
