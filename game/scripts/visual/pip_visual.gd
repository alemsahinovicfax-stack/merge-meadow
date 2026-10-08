extends Node2D

## Run companion — Pip je UiPip (pogled odozgo, galop). Magnet prsten ostaje
## u djetetu `_magnet`, nacrtan jednom; „disanje" je skala tog čvora (sezone faza 2).
## Mochi i dalje pada na proceduralni crtež.

const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
const _LEVEL0_RADIUS := 40.5

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false
var _magnet: _Magnet = null
var actor: UiPip
var _last_lane: int = 1


## Ispuna i prsten magneta u lokalnom prostoru Pipa; puls = skala čvora.
class _Magnet:
	extends Node2D

	var owner_visual: Node

	func _draw() -> void:
		owner_visual._draw_magnet(self)


func _ready() -> void:
	z_index = 10
	_magnet = _Magnet.new()
	_magnet.name = "MagnetRing"
	_magnet.owner_visual = self
	add_child(_magnet)
	_apply_companion_visual()
	var player := get_parent()
	if player != null and player.has_signal("lane_changed"):
		if not player.lane_changed.is_connected(_on_lane_changed):
			player.lane_changed.connect(_on_lane_changed)
	set_process(true)
	queue_redraw()


func refresh_companion_visual() -> void:
	_apply_companion_visual()
	queue_redraw()


func _apply_companion_visual() -> void:
	var companion_id := GameState.get_active_companion_id()
	if companion_id == CompanionConfig.ID_PIP:
		_use_draw_fallback = false
		if actor == null:
			actor = UiPip.new()
			actor.name = "Actor"
			actor.view = "top"
			actor.box_px = 150.0
			actor.follow_equipped = true
			add_child(actor)
		actor.visible = true
		actor.set_view("top")
		actor.set_loop("run_gallop")
	else:
		if actor != null:
			actor.visible = false
		_use_draw_fallback = true


func set_magnet_radius(radius: float) -> void:
	_magnet_radius = radius
	if _magnet != null:
		_magnet.scale = Vector2.ONE
		_magnet.queue_redraw()
	queue_redraw()


func play_event(id: String) -> void:
	if actor != null and actor.visible:
		actor.play(id)


func set_scroll_speed(px_s: float) -> void:
	if actor != null:
		actor.set_scroll_speed(px_s)


func _on_lane_changed(new_lane: int) -> void:
	if actor != null and actor.visible:
		actor.play("lane_right" if new_lane > _last_lane else "lane_left")
	_last_lane = new_lane


func _process(_delta: float) -> void:
	var run := get_parent().get_parent() if get_parent() != null else null
	if run != null and "scroll_speed" in run and actor != null:
		actor.set_scroll_speed(float(run.scroll_speed))
	if _magnet != null:
		_magnet.scale = Vector2.ONE * _magnet_pulse()


func _draw() -> void:
	_draw_ground_shadow()
	if _use_draw_fallback:
		COMPANION_ASSETS.draw_run(self, GameState.get_active_companion_id(), CompanionConfig.run_scale())


func _draw_magnet(canvas: CanvasItem) -> void:
	_draw_magnet_fill(canvas)
	_draw_magnet_ring(canvas)


func _draw_ground_shadow() -> void:
	if actor != null and actor.visible:
		return
	var pts := PackedVector2Array()
	var center := Vector2(0, 40)
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(a) * 36.0, sin(a) * 12.0))
	draw_colored_polygon(pts, Color(0.071, 0.110, 0.086, 0.28))


func _magnet_pulse() -> float:
	if _magnet_radius <= _LEVEL0_RADIUS:
		return 1.0
	var t := Time.get_ticks_msec() / 1000.0
	return 1.0 + 0.045 * sin(TAU * t / 1.8)


func _draw_magnet_fill(canvas: CanvasItem) -> void:
	if _magnet_radius <= _LEVEL0_RADIUS:
		return
	canvas.draw_circle(Vector2.ZERO, _magnet_radius, Color(1.0, 0.973, 0.941, 0.07))


func _draw_magnet_ring(canvas: CanvasItem) -> void:
	if _magnet_radius <= 0.0:
		return
	if _magnet_radius <= _LEVEL0_RADIUS:
		canvas.draw_arc(
			Vector2.ZERO, _magnet_radius, 0.0, TAU, 48,
			Color(1.0, 0.973, 0.941, 0.20), 4.0, true
		)
		return
	var radius := _magnet_radius
	var color := Color(1.0, 0.973, 0.941, 0.42)
	var dashes := 14
	var span := TAU / float(dashes)
	for i in dashes:
		var a0 := float(i) * span
		var a1 := a0 + span * 0.55
		canvas.draw_arc(Vector2.ZERO, radius, a0, a1, 8, color, 7.0, true)
