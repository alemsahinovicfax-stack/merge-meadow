extends Node2D

## Run companion — Pip je UiPip (pogled odozgo, galop). Magnet krug je u djetetu `_magnet`,
## nacrtan jednom (design_handoff_run_pickups: krem tačkice s ink rubom, alfa MAGNET_ALPHA, jedna
## mreža = 1 draw poziv); vrti se 18°/s i trzne 4 % kad uhvati pickup — samo rotacija i skala čvora.
## Mochi i dalje pada na proceduralni crtež.

const COMPANION_ASSETS := preload("res://scripts/visual/companion_assets.gd")
## Alfa tačkica magnet kruga: paket 0,6 → 0,32 (2026-10-21 — veći domet = veći krug, previše se
## vidio dok Pip trči).
const MAGNET_ALPHA := 0.32

var _magnet_radius: float = 0.0
var _use_draw_fallback: bool = false
var _magnet: _Magnet = null
var actor: UiPip
var _last_lane: int = 1
var _pip_spawning: bool = false
var _pickup_fx: Node = null
var _ring_rot_deg_s: float = 18.0
var _ring_pull: float = 1.04


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
		if actor == null and not _pip_spawning:
			_pip_spawning = true
			var key := UiPip.equipped_skin_key()
			while not UiPip.atlas_ready(key):
				UiPip.request_atlas(key)
				await get_tree().process_frame
				if not is_inside_tree():
					_pip_spawning = false
					return
			actor = UiPip.new()
			actor.name = "Actor"
			actor.view = "top"
			actor.skin = key
			actor.box_px = 150.0
			actor.follow_equipped = true
			add_child(actor)
			_pip_spawning = false
		if actor == null:
			return
		actor.visible = true
		actor.set_view("top")
		actor.set_loop("run_gallop")
	else:
		if actor != null:
			actor.visible = false
		_use_draw_fallback = true


## PickupFx daje trzaj kruga (prvih 0,1 s leta pickupa).
func bind_pickup_fx(fx: Node) -> void:
	_pickup_fx = fx
	var ring: Dictionary = PickupArt.data().get("magnet", {}).get("ring", {})
	_ring_rot_deg_s = float(ring.get("rot_deg_s", 18))
	_ring_pull = float(ring.get("pull_pulse", {}).get("s", 1.04))


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
		_magnet.rotation_degrees = fmod(_magnet.rotation_degrees + _ring_rot_deg_s * _delta, 360.0)
		var pull := float(_pickup_fx.call("get_pull")) if _pickup_fx != null else 0.0
		_magnet.scale = Vector2.ONE * lerpf(1.0, _ring_pull, pull)


func _draw() -> void:
	_draw_ground_shadow()
	if _use_draw_fallback:
		COMPANION_ASSETS.draw_run(self, GameState.get_active_companion_id(), CompanionConfig.run_scale())


func _draw_magnet(canvas: CanvasItem) -> void:
	_draw_magnet_dots(canvas)


func _draw_ground_shadow() -> void:
	if actor != null and actor.visible:
		return
	var pts := PackedVector2Array()
	var center := Vector2(0, 40)
	for i in 16:
		var a := TAU * float(i) / 16.0
		pts.append(center + Vector2(cos(a) * 36.0, sin(a) * 12.0))
	draw_colored_polygon(pts, Color(0.071, 0.110, 0.086, 0.28))


## magnet_ring_l*.svg: tačkice r 4,5 (krem #FFF8F0, ink rub 2 #2D3436); razmak ~30 px po obodu
## (L0 12 … L4 55 tačkica). Prsten i jezgro se ne preklapaju, pa alfa važi za grupu kao u SVG-u.
## Alfa: MAGNET_ALPHA. Jedna mreža trouglova = 1 draw poziv.
func _draw_magnet_dots(canvas: CanvasItem) -> void:
	if _magnet_radius <= 0.0:
		return
	const SEG := 10
	const R_IN := 3.5
	const R_OUT := 5.5
	var ink := Color(0.176, 0.204, 0.212, MAGNET_ALPHA)
	var cream := Color(1.0, 0.973, 0.941, MAGNET_ALPHA)
	var n := maxi(12, roundi(TAU * _magnet_radius / 30.0))
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for i in n:
		var c := Vector2.from_angle(TAU * float(i) / float(n)) * _magnet_radius
		var base := points.size()
		points.append(c)
		colors.append(cream)
		for k in SEG:
			var d := Vector2.from_angle(TAU * float(k) / float(SEG))
			points.append(c + d * R_IN)
			colors.append(cream)
			points.append(c + d * R_OUT)
			colors.append(ink)
		for k in SEG:
			var a := base + 1 + k * 2
			var b := base + 1 + ((k + 1) % SEG) * 2
			indices.append_array([base, a, b])
			indices.append_array([a, a + 1, b, a + 1, b + 1, b])
	RenderingServer.canvas_item_add_triangle_array(canvas.get_canvas_item(), indices, points, colors)
