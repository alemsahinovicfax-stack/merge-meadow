extends Sprite2D

## Sjemenka u runu — isti jezik kao Arena SeedChip (krem rim + tamni well), 120 px.
## Kolizija ostaje r 26. Rijetkost = broj pipa na rimu.

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
	var radius := float(UiRun.SEED_SIZE) * 0.5
	draw_circle(Vector2.ZERO, radius, UiRun.CHIP_BG)
	draw_arc(Vector2.ZERO, radius - 2.0, 0.0, TAU, 48, UiRun.CHIP_EDGE, 4.0, true)
	var well_r := float(UiRun.SEED_WELL_SIZE) * 0.5
	draw_circle(Vector2.ZERO, well_r, UiRun.SEED_WELL)
	draw_arc(Vector2.ZERO, well_r - 1.0, 0.0, TAU, 36, UiRun.SEED_WELL_EDGE, 2.0, true)
	PLANT_DRAW.draw_fitted_plant(self, Vector2.ZERO, _type_id, 1, float(UiRun.SEED_FLOWER_SIZE))
	var rarity := _rarity()
	var pip_color := UiRun.seed_pip_color(rarity)
	var pip_r := float(UiRun.SEED_PIP_SIZE) * 0.5
	for pos in UiRun.seed_pip_positions(rarity):
		draw_circle(pos, pip_r, pip_color)


func _rarity() -> int:
	var parent_pickup := get_parent()
	if parent_pickup != null and "rarity" in parent_pickup:
		return int(parent_pickup.rarity)
	return 1


func _draw_shadow() -> void:
	var size := UiRun.PICKUP_SHADOW_SIZE
	var center := Vector2(0.0, float(UiRun.PICKUP_SHADOW_OFFSET))
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * size.x * 0.5, sin(a) * size.y * 0.5))
	draw_colored_polygon(pts, UiRun.PICKUP_SHADOW)
