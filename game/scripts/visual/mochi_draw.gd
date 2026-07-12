class_name MochiDraw
extends RefCounted

## Procedural Mochi (cat) — pastel flat cartoon placeholder.

const BODY := Color(0.92, 0.9, 0.94, 1.0)
const EAR := Color(0.88, 0.84, 0.9, 1.0)
const EAR_INNER := Color(1.0, 0.78, 0.82, 1.0)
const OUTLINE := Color(0.45, 0.42, 0.52, 0.85)
const EYE := Color(0.22, 0.2, 0.28, 1.0)
const NOSE := Color(0.95, 0.55, 0.62, 1.0)
const CHEEK := Color(1.0, 0.72, 0.78, 0.45)


static func draw_mochi(canvas: CanvasItem, center: Vector2, scale: float = 1.0) -> void:
	var s := scale
	var body_r := 21.0 * s
	var body_center := center + Vector2(0.0, 5.0 * s)

	# Uši (trokutasti feel — dva kruga)
	canvas.draw_circle(center + Vector2(-13.0 * s, -17.0 * s), 9.0 * s, EAR)
	canvas.draw_circle(center + Vector2(13.0 * s, -17.0 * s), 9.0 * s, EAR)
	canvas.draw_circle(center + Vector2(-13.0 * s, -17.0 * s), 4.5 * s, EAR_INNER)
	canvas.draw_circle(center + Vector2(13.0 * s, -17.0 * s), 4.5 * s, EAR_INNER)

	canvas.draw_circle(body_center, body_r, BODY)
	canvas.draw_arc(body_center, body_r, 0.0, TAU, 32, OUTLINE, 2.0 * s)

	# Obrazi
	canvas.draw_circle(center + Vector2(-12.0 * s, 4.0 * s), 4.0 * s, CHEEK)
	canvas.draw_circle(center + Vector2(12.0 * s, 4.0 * s), 4.0 * s, CHEEK)

	# Oči
	canvas.draw_circle(center + Vector2(-7.0 * s, -1.0 * s), 3.2 * s, EYE)
	canvas.draw_circle(center + Vector2(7.0 * s, -1.0 * s), 3.2 * s, EYE)

	# Nos + usta
	canvas.draw_circle(center + Vector2(0.0, 5.0 * s), 3.0 * s, NOSE)
	canvas.draw_line(
		center + Vector2(0.0, 8.0 * s),
		center + Vector2(-4.0 * s, 11.0 * s),
		OUTLINE,
		1.5 * s
	)
	canvas.draw_line(
		center + Vector2(0.0, 8.0 * s),
		center + Vector2(4.0 * s, 11.0 * s),
		OUTLINE,
		1.5 * s
	)
