class_name ArenaChipDraw
extends RefCounted

## Crtez sjemenke u Areni — dijele ga ArenaSeedChip i ArenaVacuumFly.
## Smjer B (design_handoff_merge_arena): cream rim + tamni well; T1 krug, T2 zaobljen kvadrat
## s unutrasnjim prstenom; ★3 gold rim + isprekidan prsten. Bez teksta na sjemenci.

const PLANT_DRAW := preload("res://scripts/visual/camp_plant_draw.gd")
const FLOWER_ASSETS := preload("res://scripts/visual/flower_assets.gd")

## Proceduralni cvijet (tipovi bez SVG-a): skala blizu one prije redizajna
## (T1 ~1,72, T2 ~1,23) da sadnice ne izgledaju naduvano u vecem okviru.
const PROC_EXTENT := {1: 45.0, 2: 68.0, 3: 60.0}
## Vizuelni centar proceduralne biljke je ~6 px iznad ishodista.
const PROC_CENTER_Y := -6.0
const MYTHIC_DASH := 10.0
const MYTHIC_GAP := 8.0
const CHOMP_SIZE := 54.0

enum Ring { NONE, PULSE, PARTNER, MERGE }


static func draw_chip(
	canvas: CanvasItem,
	center: Vector2,
	type_id: String,
	tier: int,
	mythic: bool,
	ring: int = Ring.NONE,
	ring_alpha: float = 1.0,
	dragging: bool = false,
	chomp: bool = false
) -> void:
	if tier >= 3:
		draw_flower(canvas, center, type_id, 3, UiArena.FLOWER_SIZE_T3)
		return
	var side := ArenaSeedChip.CHIP_RADIUS * 2.0
	var rect := Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side))
	var corner := UiArena.chip_corner_radius(tier)
	var drop := UiArena.CHIP_SHADOW_OFFSET_DRAG if dragging else UiArena.CHIP_SHADOW_OFFSET
	canvas.draw_style_box(
		UiArena.chip_shadow_style(tier, dragging), Rect2(rect.position + Vector2(0.0, drop), rect.size)
	)
	_draw_ring(canvas, rect, tier, corner, ring, ring_alpha)
	canvas.draw_style_box(UiArena.chip_rim_style(tier, mythic), rect)
	canvas.draw_style_box(UiArena.chip_well_style(tier), rect.grow(-UiArena.chip_well_inset(tier)))
	if tier == 2:
		canvas.draw_style_box(UiArena.chip_hairline_style(mythic), rect.grow(-UiArena.T2_HAIRLINE_INSET))
	var box := UiArena.FLOWER_SIZE_T2 if tier == 2 else UiArena.FLOWER_SIZE_T1
	draw_flower(canvas, center, type_id, tier, box)
	if mythic:
		var nub_radius := corner + 7.0 if tier == 2 else side * 0.5 + 7.0
		draw_dashed_round_rect(
			canvas, rect.grow(7.0), nub_radius, 4.0, Color(UiArena.GOLD_EDGE, 0.9), MYTHIC_DASH, MYTHIC_GAP
		)
	if chomp:
		_draw_chomp(canvas, rect)


## Cvijet u kvadratnom okviru `box`: SVG (FlowerAssets) ili proceduralni fallback.
static func draw_flower(canvas: CanvasItem, center: Vector2, type_id: String, tier: int, box: float) -> void:
	var tex := FLOWER_ASSETS.get_texture(type_id, tier)
	if tex != null:
		canvas.draw_texture_rect(tex, Rect2(center - Vector2(box, box) * 0.5, Vector2(box, box)), false)
		return
	var s := box / float(PROC_EXTENT.get(tier, 60.0))
	canvas.draw_set_transform(center - Vector2(0.0, PROC_CENTER_Y * s), 0.0, Vector2(s, s))
	PLANT_DRAW.draw_plant(canvas, Vector2.ZERO, type_id, tier)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func draw_dashed_round_rect(
	canvas: CanvasItem, rect: Rect2, radius: float, width: float, color: Color, dash: float, gap: float
) -> void:
	var pts := _round_rect_points(rect, radius)
	var on := true
	var left := dash
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var seg := a.distance_to(b)
		var t := 0.0
		while seg - t > 0.001:
			var take := minf(left, seg - t)
			if on:
				canvas.draw_line(a.lerp(b, t / seg), a.lerp(b, (t + take) / seg), color, width, true)
			t += take
			left -= take
			if left <= 0.001:
				on = not on
				left = dash if on else gap


static func _draw_ring(
	canvas: CanvasItem, rect: Rect2, tier: int, corner: float, ring: int, alpha: float
) -> void:
	match ring:
		Ring.PULSE:
			var grow := 7.0
			canvas.draw_style_box(
				UiArena.ring_style(corner + grow, 6.0, Color(UiArena.PULSE_GOLD, 0.8 * alpha)), rect.grow(grow)
			)
		Ring.PARTNER:
			var grow := 10.0
			canvas.draw_style_box(
				UiArena.ring_style(corner + grow, 7.0, Color(UiArena.COIN_GOLD, alpha)), rect.grow(grow)
			)
		Ring.MERGE:
			canvas.draw_style_box(
				UiArena.ring_style(999.0, 10.0, Color(UiArena.FLASH, 0.55 * alpha)), rect.grow(26.0)
			)


## Zagriz — roze klin na desnom gornjem rubu dok ga Muncher jede.
static func _draw_chomp(canvas: CanvasItem, rect: Rect2) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = UiArena.MOUTH
	s.border_color = UiArena.MOUTH_EDGE
	s.set_border_width_all(3)
	var r := int(CHOMP_SIZE * 0.5)
	s.corner_radius_top_left = r
	s.corner_radius_bottom_left = r
	s.corner_radius_bottom_right = r
	s.corner_radius_top_right = 0
	s.corner_detail = 12
	var pos := Vector2(rect.end.x + 4.0 - CHOMP_SIZE, rect.position.y + 30.0)
	canvas.draw_style_box(s, Rect2(pos, Vector2(CHOMP_SIZE, CHOMP_SIZE)))


static func _round_rect_points(rect: Rect2, r: float, steps: int = 10) -> PackedVector2Array:
	r = minf(r, minf(rect.size.x, rect.size.y) * 0.5)
	var corners: Array[Vector2] = [
		rect.position + Vector2(rect.size.x - r, r),
		rect.position + Vector2(rect.size.x - r, rect.size.y - r),
		rect.position + Vector2(r, rect.size.y - r),
		rect.position + Vector2(r, r),
	]
	var pts := PackedVector2Array()
	for k in 4:
		var a0 := -PI * 0.5 + float(k) * PI * 0.5
		for i in steps + 1:
			var a := a0 + PI * 0.5 * float(i) / float(steps)
			pts.append(corners[k] + Vector2(cos(a), sin(a)) * r)
	pts.append(pts[0])
	return pts
