extends Control

## HOME-14 LIFE-D — Pip na SeasonField. FSM i dalje živi na SeasonField;
## ovdje je host za UiPip (design_handoff_pip): hop u profilu, idle / sniff / sleep.

const PIP_SIDE := 190.0

var actor: UiPip
var _pose: String = "walk"
var _walking: bool = false
var _last_x: float = 0.0
var _apply_playing: bool = false
var _spawning: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(PIP_SIDE, PIP_SIDE)
	size = custom_minimum_size
	z_index = 20
	_ensure_actor()
	set_process(true)


func _ensure_actor() -> void:
	if actor != null or _spawning:
		return
	_spawning = true
	var key := UiPip.equipped_skin_key()
	while not UiPip.atlas_ready(key):
		UiPip.request_atlas(key)
		await get_tree().process_frame
		if not is_inside_tree():
			_spawning = false
			return
	actor = UiPip.new()
	actor.name = "Actor"
	actor.view = "front"
	actor.box_px = PIP_SIDE
	actor.follow_equipped = true
	actor.skin = key
	add_child(actor)
	actor.place_feet_in(self)
	actor.set_loop("idle")
	if actor.body != null and not actor.body.animation_finished.is_connected(_on_actor_done):
		actor.body.animation_finished.connect(_on_actor_done)
	_spawning = false
	set_pose(_pose, _walking)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and actor != null:
		actor.place_feet_in(self)


func set_pose(pose: String, walking: bool = false, tilt_dir: float = 1.0) -> void:
	_pose = pose
	_walking = walking and pose == "walk"
	_ensure_actor()
	if actor == null:
		return
	if _walking:
		actor.set_view("side")
		actor.set_facing(tilt_dir < 0.0)
		actor.set_loop("hop")
	elif pose == "sniff":
		actor.set_view("front")
		actor.set_facing(false)
		actor.play("sniff")
		actor.loop_id = "idle"
	elif pose == "sleep":
		actor.set_view("front")
		actor.set_facing(false)
		actor.play("fall_asleep")
		actor.loop_id = "sleep"
	else:
		actor.set_view("front")
		actor.set_facing(false)
		actor.set_loop("idle")


func get_pose() -> String:
	return _pose


func is_walking() -> bool:
	return _walking


func play_apply() -> void:
	_ensure_actor()
	if actor == null:
		return
	_apply_playing = true
	actor.set_view("front")
	actor.play("apply")
	actor.loop_id = "idle"


func is_apply_playing() -> bool:
	if _apply_playing:
		return true
	return actor != null and actor.is_playing("apply")


func _on_actor_done(id: StringName) -> void:
	if str(id) == "apply":
		_apply_playing = false


func _process(_delta: float) -> void:
	if actor == null or not _walking:
		_last_x = position.x
		return
	var dx := position.x - _last_x
	if absf(dx) > 0.4:
		actor.set_facing(dx < 0.0)
	_last_x = position.x
