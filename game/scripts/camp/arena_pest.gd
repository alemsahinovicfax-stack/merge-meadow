extends Control
class_name ArenaPest

## MA-01b — Muncher pest: spava, jede T1/T2, freeze na T3.
## Vizual (design_handoff_muncher_premium_pip · A): Nibbs, seed-mole — MuncherRig (cutout,
## 3 pogleda, klipovi stanja) + krtičnjak (zadnji dio ispod, prednja usna preko njega samo dok
## spava / budi se u njemu) + baner „Muncher's awake!" pri prvom buđenju u sesiji. Pravila
## (brzina, cilj, jedenje, led 2 s) su ista; kod samo bira klip. Ništa se ne crta po frejmu.

enum State {
	SLEEPING_NEST,
	WAKE_DELAY,
	HUNTING,
	EATING,
	SLEEPING_SPOT,
	FROZEN,
}

## Vizuelni radius (clamp u polje): r 58 × 52 iz paketa. Jedenje ide po
## GameState.ARENA_PEST_EAT_RADIUS od centra (= usta).
const PEST_RADIUS := 58.0
const FREEZE_OUT_SEC := 0.25
## Polje: pest ispod oblačića tutoriala (z 56); dijelovi riga su −4 … 9 relativno.
const PEST_Z := 45
const NEST_BACK_Z := -5
const NEST_FRONT_OVER_Z := 10
const BANNER_Z := 10
## Smjer lova (paket): |dx| ≥ 0,8·|dy| → bočno, inače naprijed / nazad; najmanje 0,2 s po pogledu.
const SIDE_RATIO := 0.8
const VIEW_MIN_SEC := 0.2
## Baner: vrh na 13 % polja (207 od 1589) = 112 ispod centra gnijezda; uleti 0,32 s, stoji 1,6 s.
const BANNER_BELOW_NEST := 112.0
const BANNER_HOLD := 1.6
const BANNER_SLIDE := 0.32
const BANNER_TEXT := "Muncher's awake!"
const BANNER_PX := 44
const BANNER_TEXT_MAX_W := 330.0

var _state: State = State.SLEEPING_NEST
var _pest_center: Vector2 = Vector2.ZERO
var _nest_center: Vector2 = Vector2.ZERO
var _target_chip: ArenaSeedChip = null
var _eat_timer: float = 0.0
var _freeze_timer: float = 0.0
var _wake_timer: float = 0.0
var _target_reeval: float = 0.0
var _dir: Vector2 = Vector2(cos(deg_to_rad(200.0)), sin(deg_to_rad(200.0)))

## Prvo buđenje u sesiji: baner + m_awake (1,4 s) prije lova.
var _first_wake: bool = true
var _awake_pending: bool = false
var _thawing: bool = false
var _escaped: bool = false
var _target_held: bool = false
## Drugi zalogaj (0,25 s) u jedenju od 0,5 s — zvuk griza ide dvaput.
var _second_bite: bool = false

var _rig: MuncherRig = null
var _nest_back: Node2D = null
var _nest_front: Node2D = null
var _banner: _Banner = null
var _banner_tween: Tween = null
var _shown_state: int = -1
var _force_clip: bool = false
var _hunt_view: String = ""
var _hunt_flip: bool = false
var _view_t: float = 0.0

var _get_edible_chips: Callable
var _get_keepout_rect: Callable
var _get_playfield_bounds: Callable
var _on_eat_chip: Callable


func setup(
	get_edible_chips: Callable,
	get_keepout_rect: Callable,
	get_playfield_bounds: Callable,
	on_eat_chip: Callable
) -> void:
	_get_edible_chips = get_edible_chips
	_get_keepout_rect = get_keepout_rect
	_get_playfield_bounds = get_playfield_bounds
	_on_eat_chip = on_eat_chip
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = PEST_Z
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = true
	# Atlas (46 SVG) u pozadini dok se Arena gradi; rig se složi čim je spreman.
	MuncherRig.request_atlas()
	_ensure_visual()


func reset_to_nest() -> void:
	_release_target()
	_state = State.SLEEPING_NEST
	_eat_timer = 0.0
	_freeze_timer = 0.0
	_wake_timer = 0.0
	_target_reeval = 0.0
	_first_wake = true
	_awake_pending = false
	_thawing = false
	_escaped = false
	_pest_center = _nest_center
	_force_clip = true
	hide_awake_banner()
	_sync_visual(0.0)


func set_nest_position(center: Vector2) -> void:
	_nest_center = center
	if _state == State.SLEEPING_NEST:
		_pest_center = center
	_place_nest()
	_sync_visual(0.0)


func on_seeds_poured(has_chips_on_field: bool) -> void:
	if not has_chips_on_field:
		return
	if _state == State.SLEEPING_NEST or _state == State.SLEEPING_SPOT:
		_state = State.WAKE_DELAY
		_wake_timer = GameState.ARENA_PEST_WAKE_DELAY
		if _first_wake:
			_first_wake = false
			_awake_pending = true
			_show_awake_banner()
		_sync_visual(0.0)


func on_field_chip_count_changed(count: int) -> void:
	if count <= 0 and _state in [State.HUNTING, State.EATING, State.WAKE_DELAY]:
		_go_sleep_at_current_spot()


func on_t3_created() -> void:
	_release_target()
	_state = State.FROZEN
	_freeze_timer = GameState.ARENA_PEST_T3_FREEZE
	_eat_timer = 0.0
	_thawing = false
	_force_clip = true
	_sync_visual(0.0)


func is_active() -> bool:
	return _state != State.SLEEPING_NEST and _state != State.SLEEPING_SPOT


func tick(delta: float) -> void:
	match _state:
		State.SLEEPING_NEST, State.SLEEPING_SPOT:
			pass
		State.WAKE_DELAY:
			_wake_timer -= delta
			if _wake_timer <= 0.0:
				if _awake_pending:
					# „Muncher's awake!": protezanje 1,4 s, pa lov (samo prvi put u sesiji).
					_awake_pending = false
					_wake_timer = maxf(0.01, MuncherRig.anim_length("m_awake"))
					if _rig != null:
						_rig.play("m_awake")
					Sfx.play("muncher_awake")
				else:
					_state = State.HUNTING
					_pick_target(true)
		State.FROZEN:
			_freeze_timer -= delta
			# Led ukupno 2 s: zadnjih 0,25 s je pucanje (m_thaw), pravila se ne mijenjaju.
			if not _thawing and _freeze_timer <= FREEZE_OUT_SEC:
				_thawing = true
				if _rig != null:
					_rig.play("m_thaw")
				Sfx.play("muncher_thaw")
			if _freeze_timer <= 0.0:
				_thawing = false
				var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
				if chips.is_empty():
					_go_sleep_at_current_spot()
				else:
					_state = State.HUNTING
					_pick_target(true)
		State.HUNTING:
			_tick_hunting(delta)
		State.EATING:
			_eat_timer -= delta
			if not _second_bite and _eat_timer <= GameState.ARENA_PEST_EAT_DURATION * 0.5:
				_second_bite = true
				Sfx.play("muncher_chomp")
			if _eat_timer <= 0.0:
				_finish_eating()
	_sync_visual(delta)


func _tick_hunting(delta: float) -> void:
	# Meta je nestala usred lova (spojena / u korpu): „hmph" preko lova, novi cilj odmah.
	# Oslobođen objekt se u Godotu 4 poredi kao null, pa se pamti da je meta postojala.
	if _target_held and (not is_instance_valid(_target_chip) or _target_chip.is_queued_for_deletion()):
		_target_chip = null
		_escaped = true
	_target_held = false
	_target_reeval -= delta
	if _target_reeval <= 0.0:
		_target_reeval = GameState.ARENA_PEST_TARGET_REEVAL
		_pick_target(false)
	if _target_chip == null or not is_instance_valid(_target_chip):
		_pick_target(true)
		if _target_chip == null:
			_go_sleep_at_current_spot()
			return
	_target_held = true
	var chip_center := _target_chip.get_center()
	var dir := chip_center - _pest_center
	var dist := dir.length()
	if dist <= GameState.ARENA_PEST_EAT_RADIUS:
		_target_held = false
		_begin_eating()
		return
	if dist > 1.0:
		dir = dir / dist
	var speed := GameState.ARENA_PEST_SPEED * delta
	var next := _pest_center + dir * speed
	next = _clamp_to_bounds(next)
	next = _avoid_keepout(next)
	if next.distance_squared_to(_pest_center) > 0.0001:
		_dir = (next - _pest_center).normalized()
	_pest_center = next


func _begin_eating() -> void:
	_state = State.EATING
	_eat_timer = GameState.ARENA_PEST_EAT_DURATION
	_second_bite = false
	Sfx.play("muncher_chomp")
	if _target_chip != null and is_instance_valid(_target_chip):
		_target_chip.set_being_eaten(true)


func _finish_eating() -> void:
	if _target_chip != null and is_instance_valid(_target_chip):
		if _on_eat_chip.is_valid():
			_on_eat_chip.call(_target_chip)
	_target_chip = null
	var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
	if chips.is_empty():
		_go_sleep_at_current_spot()
	else:
		_state = State.HUNTING
		_pick_target(true)
		# Novi lov poslije obroka: klip lova iznova (isti state, novi plijen).
		_force_clip = true


func _go_sleep_at_current_spot() -> void:
	_release_target()
	_state = State.SLEEPING_SPOT
	_eat_timer = 0.0
	_awake_pending = false


## Plijen koji je prezivio (freeze, reset) vraca se u normalu.
func _release_target() -> void:
	if _target_chip != null and is_instance_valid(_target_chip) and _target_chip.is_being_eaten():
		_target_chip.set_being_eaten(false)
	_target_chip = null
	_target_held = false


func _pick_target(force: bool) -> void:
	if not force and _target_chip != null and is_instance_valid(_target_chip):
		return
	var chips: Array = _get_edible_chips.call() if _get_edible_chips.is_valid() else []
	if chips.is_empty():
		_target_chip = null
		return
	var best: ArenaSeedChip = null
	var best_score := INF
	for raw in chips:
		var chip := raw as ArenaSeedChip
		if chip == null or not is_instance_valid(chip):
			continue
		var dist := _pest_center.distance_to(chip.get_center())
		var tier_bias := 0.0 if chip.tier >= 2 else 12.0
		var score := dist + tier_bias
		if score < best_score:
			best_score = score
			best = chip
	_target_chip = best


func _clamp_to_bounds(center: Vector2) -> Vector2:
	if not _get_playfield_bounds.is_valid():
		return center
	var bounds: Rect2 = _get_playfield_bounds.call()
	var r := PEST_RADIUS
	return Vector2(
		clampf(center.x, bounds.position.x + r, bounds.position.x + bounds.size.x - r),
		clampf(center.y, bounds.position.y + r, bounds.position.y + bounds.size.y - r)
	)


func _avoid_keepout(center: Vector2) -> Vector2:
	if not _get_keepout_rect.is_valid():
		return center
	var zone: Rect2 = _get_keepout_rect.call()
	if zone.size.x < 1.0 or not zone.has_point(center):
		return center
	var zone_center := zone.get_center()
	var dir := center - zone_center
	if dir.length_squared() < 1.0:
		dir = Vector2(0.0, -1.0)
	else:
		dir = dir.normalized()
	var push := maxf(zone.size.x, zone.size.y) * 0.45 + PEST_RADIUS
	return _clamp_to_bounds(zone_center + dir * push)


## Ključ stanja za testove i Pipove reakcije.
func get_pose_key() -> String:
	match _state:
		State.SLEEPING_NEST, State.SLEEPING_SPOT:
			return "sleep"
		State.WAKE_DELAY:
			return "wake"
		State.EATING:
			return "eat"
		State.FROZEN:
			return "frozen"
	return "hunt"


## U gnijezdu (spava ili se tek budi na njemu) — prednja usna krtičnjaka ga pokriva.
func _in_nest() -> bool:
	var at_nest := _pest_center.distance_to(_nest_center) < 1.0
	return _state == State.SLEEPING_NEST or (_state == State.WAKE_DELAY and at_nest)


# ── vizual (MuncherRig) ───────────────────────────────────────────────────────

## Rig i krtičnjak se slože kad je atlas gotov (Arena se gradi u pozadini na startu huba).
func _ensure_visual() -> bool:
	if _rig != null:
		return true
	if not MuncherRig.atlas_ready():
		return false
	var nest: Dictionary = MuncherRig.rig_data().get("nest", {})
	for n in nest.get("nodes", []):
		var holder := Node2D.new()
		holder.name = "NestBack" if str(n["id"]) == "nest_back" else "NestFront"
		holder.add_child(MuncherRig.make_sprite(n["sprite"]))
		add_child(holder)
		if str(n["id"]) == "nest_back":
			_nest_back = holder
		else:
			_nest_front = holder
	_rig = MuncherRig.new()
	_rig.name = "Muncher"
	add_child(_rig)
	_rig.body.animation_finished.connect(_on_clip_done)
	_banner = _Banner.new()
	_banner.name = "AwakeBanner"
	_banner.z_index = BANNER_Z
	_banner.visible = false
	add_child(_banner)
	_place_nest()
	_force_clip = true
	return true


func _place_nest() -> void:
	if _nest_back == null:
		return
	_nest_back.position = _nest_center
	_nest_front.position = _nest_center
	_nest_back.z_index = NEST_BACK_Z
	if _banner != null and not _banner.visible:
		_banner.position = _banner_home()


func _sync_visual(delta: float) -> void:
	if not _ensure_visual():
		return
	_rig.position = _pest_center
	if _force_clip or int(_state) != _shown_state:
		_force_clip = false
		_shown_state = int(_state)
		_enter_state_clip()
	if _state == State.HUNTING:
		_update_hunt_view(delta)
		if _escaped:
			_escaped = false
			if _hunt_view == "back":
				_hunt_view = "front"
				_hunt_flip = false
				_rig.play("m_hunt_front")
			var hmph := "m_escaped_side" if _hunt_view == "side" else "m_escaped_front"
			_rig.play_overlay(hmph)
			Sfx.play("muncher_hmph")
			# Pogled stoji dok traje „hmph" (0,8 s): promjena pogleda bi prekinula klip.
			_view_t = MuncherRig.anim_length(hmph)
	_escaped = false
	# Usna krtičnjaka preko munchera samo dok je u rupi; inače je cijeli krtičnjak ispod.
	_nest_front.z_index = NEST_FRONT_OVER_Z if _in_nest() else NEST_BACK_Z


func _enter_state_clip() -> void:
	_rig.stop_overlay()
	match _state:
		State.SLEEPING_NEST:
			_rig.play("m_sleep_nest")
		State.WAKE_DELAY:
			_rig.play("m_wake_nest" if _in_nest() else "m_wake_spot")
			Sfx.play("muncher_wake")
		State.HUNTING:
			_hunt_view = ""
			_view_t = 0.0
			_update_hunt_view(0.0)
		State.EATING:
			if _hunt_view == "side":
				_rig.play("m_eat_side", _hunt_flip)
			else:
				_hunt_view = "front"
				_hunt_flip = false
				_rig.play("m_eat_front")
		State.FROZEN:
			_rig.play("m_freeze")
			Sfx.play("muncher_freeze")
		State.SLEEPING_SPOT:
			_rig.play("m_doze")
			Sfx.play("muncher_yawn")


## Pogled lova po smjeru prema cilju; isti pogled najmanje 0,2 s (bez treptanja).
func _update_hunt_view(delta: float) -> void:
	_view_t -= delta
	if _target_chip == null or not is_instance_valid(_target_chip):
		if _hunt_view.is_empty():
			_hunt_view = "front"
			_rig.play("m_hunt_front")
		return
	var d := _target_chip.get_center() - _pest_center
	var v := "side" if absf(d.x) >= SIDE_RATIO * absf(d.y) else ("front" if d.y > 0.0 else "back")
	var f := v == "side" and d.x < 0.0
	if _hunt_view.is_empty() or (_view_t <= 0.0 and (v != _hunt_view or f != _hunt_flip)):
		_hunt_view = v
		_hunt_flip = f
		_view_t = VIEW_MIN_SEC
		_rig.play("m_hunt_" + v, f)


func _on_clip_done(id: StringName) -> void:
	match str(id):
		"m_freeze":
			if _state == State.FROZEN and not _thawing:
				_rig.play("m_frozen")
		"m_doze":
			if _state == State.SLEEPING_SPOT:
				_rig.play("m_sleep_spot")


# ── baner „Muncher's awake!" ─────────────────────────────────────────────────

func _banner_home() -> Vector2:
	return _nest_center + Vector2(0.0, BANNER_BELOW_NEST)


func _show_awake_banner() -> void:
	if _banner == null or not is_inside_tree():
		return
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	var home := _banner_home()
	var hidden := home - Vector2(0.0, BANNER_BELOW_NEST + 120.0)
	_banner.position = hidden
	_banner.visible = true
	_banner_tween = create_tween()
	_banner_tween.tween_property(_banner, "position", home, BANNER_SLIDE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_interval(BANNER_HOLD)
	_banner_tween.tween_property(_banner, "position", hidden, BANNER_SLIDE).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_banner_tween.tween_callback(func() -> void: _banner.visible = false)


## Tutorial Arene već piše „Muncher's awake" u oblačiću — tada baner ne treba.
func hide_awake_banner() -> void:
	if _banner_tween != null and _banner_tween.is_valid():
		_banner_tween.kill()
	if _banner != null:
		_banner.visible = false


func is_banner_showing() -> bool:
	return _banner != null and _banner.visible


func get_clip() -> String:
	return _rig.clip if _rig != null else ""


func get_view() -> String:
	return _rig.view if _rig != null else ""


func is_nest_front_over() -> bool:
	return _nest_front != null and _nest_front.z_index == NEST_FRONT_OVER_Z


func get_rig() -> MuncherRig:
	return _rig


## Pločica banera (m_banner.svg) + tekst: crta se jednom, kreće se transformom.
class _Banner:
	extends Node2D

	func _draw() -> void:
		var spec: Dictionary = MuncherRig.rig_data().get("banner", {})
		if not spec.is_empty():
			var a := MuncherRig.atlas()
			var region: Rect2 = a["regions"].get(str(spec["file"]), Rect2())
			var off: Array = spec["offset"]
			draw_texture_rect_region(
				a["texture"], Rect2(Vector2(float(off[0]), float(off[1])), region.size / MuncherRig.RASTER), region
			)
		# Pločica je 372 px (bez repova): 44 px Nunito 900 je preširok, tekst se smanji da stane.
		var px := ArenaPest.BANNER_PX
		var w := UiHomeV3.text_w(900, px, ArenaPest.BANNER_TEXT)
		if w > ArenaPest.BANNER_TEXT_MAX_W:
			px = int(floorf(float(px) * ArenaPest.BANNER_TEXT_MAX_W / w))
			w = UiHomeV3.text_w(900, px, ArenaPest.BANNER_TEXT)
		UiHomeV3.draw_text(self, 900, px, ArenaPest.BANNER_TEXT, Vector2(-w * 0.5, -px * 0.5 - 2.0), Color("#2D3436"))
