extends Node2D

enum State { READY, RUNNING, ENDED }

const RUN_DURATION := 75.0
const BASE_SCROLL_SPEED := 400.0
const SPAWN_INTERVAL := 1.2
const SPAWN_CHANCE := 0.7
const OBSTACLE_CHANCE := 0.25
const RAMP_STEP := 0.05
const RAMP_EVERY := 15.0

@onready var world: Node2D = $World
@onready var player: Area2D = $Player
@onready var lane_guides: Node2D = $LaneGuides
@onready var orb_counter_label: Label = $HUD/OrbCounter
@onready var timer_label: Label = $HUD/TimerLabel
@onready var start_overlay: CanvasLayer = $StartOverlay
@onready var start_button: Button = $StartOverlay/Panel/VBox/StartButton
@onready var loot_overlay: CanvasLayer = $LootOverlay
@onready var loot_label: Label = $LootOverlay/Panel/VBox/LootLabel
@onready var retry_button: Button = $LootOverlay/Panel/VBox/RetryButton

var _orb_scene: PackedScene = preload("res://scenes/run/orb.tscn")
var _obstacle_scene: PackedScene = preload("res://scenes/run/obstacle.tscn")

var _state: State = State.READY
var lane_x_positions: Array[float] = []
var scroll_speed: float = BASE_SCROLL_SPEED
var elapsed: float = 0.0
var orb_count: int = 0
var spawn_timer: float = 0.0


func _ready() -> void:
	_calculate_lanes()
	_draw_lane_guides()
	player.position.y = _viewport_size().y * 0.82
	player.hit_obstacle.connect(_on_player_hit_obstacle)
	start_button.pressed.connect(start_run)
	retry_button.pressed.connect(start_run)
	_enter_ready()


func _process(delta: float) -> void:
	if _state != State.RUNNING:
		return

	elapsed += delta
	if elapsed >= RUN_DURATION:
		_end_run(false)
		return

	var ramp_level := int(elapsed / RAMP_EVERY)
	scroll_speed = BASE_SCROLL_SPEED * pow(1.0 + RAMP_STEP, ramp_level)

	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		_try_spawn()

	_move_entities(delta)
	_update_hud()


func start_run() -> void:
	_state = State.RUNNING
	elapsed = 0.0
	orb_count = 0
	scroll_speed = BASE_SCROLL_SPEED
	spawn_timer = 0.0
	start_overlay.visible = false
	loot_overlay.visible = false
	_clear_world_entities()
	player.reset_lane()
	player.set_input_enabled(true)
	_update_hud()


func _enter_ready() -> void:
	_state = State.READY
	elapsed = 0.0
	orb_count = 0
	start_overlay.visible = true
	loot_overlay.visible = false
	player.set_input_enabled(false)
	_clear_world_entities()
	player.reset_lane()
	_update_hud()


func _end_run(failed: bool) -> void:
	_state = State.ENDED
	player.set_input_enabled(false)

	var loot := orb_count
	if failed:
		loot = orb_count / 2
		loot_label.text = "Fail!\n+%d Orbs (50%%)" % loot
	else:
		loot_label.text = "Run complete!\n+%d Orbs" % loot

	loot_overlay.visible = true


func _viewport_size() -> Vector2:
	return get_viewport_rect().size


func _calculate_lanes() -> void:
	var width := _viewport_size().x
	lane_x_positions = [width * 0.25, width * 0.5, width * 0.75]
	player.setup_lanes(lane_x_positions)


func _draw_lane_guides() -> void:
	for x in lane_x_positions:
		var line := ColorRect.new()
		line.color = Color(1.0, 1.0, 1.0, 0.08)
		line.size = Vector2(4.0, _viewport_size().y)
		line.position = Vector2(x - 2.0, 0.0)
		lane_guides.add_child(line)


func _clear_world_entities() -> void:
	for child in world.get_children():
		child.queue_free()


func _move_entities(delta: float) -> void:
	var remove_y := _viewport_size().y + 100.0
	for child in world.get_children():
		child.position.y += scroll_speed * delta
		if child.position.y > remove_y:
			child.queue_free()


func _try_spawn() -> void:
	if randf() > SPAWN_CHANCE:
		return

	var lane := randi() % 3
	var spawn_pos := Vector2(lane_x_positions[lane], -80.0)

	if randf() < OBSTACLE_CHANCE:
		var obstacle := _obstacle_scene.instantiate()
		obstacle.position = spawn_pos
		world.add_child(obstacle)
	else:
		var orb := _orb_scene.instantiate()
		orb.position = spawn_pos
		orb.collected.connect(_on_orb_collected)
		world.add_child(orb)


func _on_orb_collected() -> void:
	orb_count += 1
	_update_hud()


func _on_player_hit_obstacle() -> void:
	if _state == State.RUNNING:
		_end_run(true)


func _update_hud() -> void:
	orb_counter_label.text = "Orbs: %d" % orb_count
	var remaining := maxf(0.0, RUN_DURATION - elapsed)
	timer_label.text = "%ds" % int(ceil(remaining))
