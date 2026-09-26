extends Sprite2D

## Sjemenka u runu — samo odrezana sadnica, bez okvira. Kolizija ostaje r 26.
## Rijetkost = broj pipa u kruni iznad sadnice.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")

var _type_id: String = "clover"
var _phase: float = 0.0


func _ready() -> void:
	texture = null
	centered = true
	_phase = randf() * TAU
	var parent_pickup := get_parent()
	if parent_pickup != null and "type_id" in parent_pickup:
		_type_id = str(parent_pickup.type_id)
	queue_redraw()


func setup(type_id: String) -> void:
	_type_id = type_id
	texture = null
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta * 2.4
	position.y = sin(_phase) * 5.0


func _draw() -> void:
	_draw_shadow()
	PLANT_DRAW.draw_cropped_plant(self, Vector2.ZERO, _type_id, 1, float(UiRun.SEED_FLOWER_SIZE))
	var rarity := _rarity()
	var pip_color := UiRun.seed_pip_color(rarity)
	var outer := float(UiRun.SEED_PIP_SIZE) * 0.5
	var inner := outer - float(UiRun.SEED_PIP_BORDER)
	for pos in UiRun.seed_pip_positions(rarity):
		draw_circle(pos, outer, UiRun.CHIP_BG)
		draw_circle(pos, inner, pip_color)


func _rarity() -> int:
	var parent_pickup := get_parent()
	if parent_pickup != null and "rarity" in parent_pickup:
		return int(parent_pickup.rarity)
	return 1


func _draw_shadow() -> void:
	var size := UiRun.PICKUP_SHADOW_SIZE
	var center := Vector2(0.0, float(UiRun.SEED_SHADOW_OFFSET))
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, UiRun.PICKUP_SHADOW)
