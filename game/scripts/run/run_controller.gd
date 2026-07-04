extends Node2D

const BASE_SCROLL_SPEED := 400.0
const SPAWN_INTERVAL := 1.2
const SPAWN_CHANCE := 0.7
const OBSTACLE_CHANCE := 0.25
const PICKUP_SEED_CHANCE := 0.30
const RAMP_STEP := 0.05
const RAMP_EVERY := 15.0

@onready var loadout_label: Label = $HUD/PipBadge/LoadoutLabel

@onready var world: Node2D = $World
@onready var player: Area2D = $Player
@onready var lane_guides: Node2D = $LaneGuides
@onready var coin_counter_label: Label = $HUD/PickupCounters/CoinLabel
@onready var seed_counter_label: Label = $HUD/PickupCounters/SeedLabel
@onready var timer_label: Label = $HUD/TimerLabel
@onready var tutorial_banner: Label = $HUD/TutorialBanner

var _coin_scene: PackedScene = preload("res://scenes/run/coin.tscn")
var _seed_scene: PackedScene = preload("res://scenes/run/seed_pickup.tscn")
var _obstacle_scene: PackedScene = preload("res://scenes/run/obstacle.tscn")

var _state: int = 0  # 0=running
var _world_ready: bool = false
var lane_x_positions: Array[float] = []
var scroll_speed: float = BASE_SCROLL_SPEED
var elapsed: float = 0.0
var coin_count: int = 0
var seeds_by_type: Dictionary = {}
var spawn_timer: float = 0.0
var _guaranteed_seed_done: bool = false
var _coins_callout_done: bool = false
var _coins_callout_hide_at: float = -1.0
var _tutorial_obstacle_done: bool = false


func _ready() -> void:
	player.hit_obstacle.connect(_on_player_hit_obstacle)
	tutorial_banner.visible = false
	await _wait_for_viewport()
	_setup_world()
	if GameState.resume_pending:
		_resume_run()
	else:
		GameState.begin_fresh_run()
		start_run()


func _wait_for_viewport() -> void:
	while get_viewport_rect().size.y < 100.0:
		await get_tree().process_frame


func _setup_world() -> void:
	_calculate_lanes()
	_draw_lane_guides()
	player.position.y = _viewport_size().y * 0.82
	_world_ready = true


func start_run() -> void:
	elapsed = 0.0
	coin_count = 0
	seeds_by_type = {}
	_guaranteed_seed_done = false
	_coins_callout_done = false
	_coins_callout_hide_at = -1.0
	_tutorial_obstacle_done = false
	_reset_common()


func _resume_run() -> void:
	GameState.resume_pending = false
	elapsed = GameState.carry_elapsed
	coin_count = GameState.carry_coins
	seeds_by_type = GameState.carry_seed_bag.duplicate()
	_guaranteed_seed_done = true
	_coins_callout_done = true
	_tutorial_obstacle_done = true
	_reset_common()


func _reset_common() -> void:
	if not _world_ready:
		await _wait_for_viewport()
		if not _world_ready:
			_setup_world()
	_state = 0
	scroll_speed = BASE_SCROLL_SPEED
	spawn_timer = 0.0
	_clear_world_entities()
	player.reset_lane()
	player.set_magnet_radius(GameState.get_magnet_radius())
	player.set_input_enabled(true)
	_update_hud()


func _process(delta: float) -> void:
	if _state != 0 or not _world_ready:
		return

	elapsed += delta
	var run_duration := GameState.get_run_duration()
	if elapsed >= run_duration:
		_end_run(false)
		return

	_update_tutorial_run_events()

	var ramp_level := int(elapsed / RAMP_EVERY)
	scroll_speed = BASE_SCROLL_SPEED * pow(1.0 + RAMP_STEP, ramp_level)

	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		_try_spawn()

	_move_entities(delta)
	_update_hud()


func _update_tutorial_run_events() -> void:
	if GameState.is_tutorial_run1():
		if not _coins_callout_done and elapsed >= 20.0:
			tutorial_banner.text = "Coins for the shop!"
			tutorial_banner.visible = true
			_coins_callout_done = true
			_coins_callout_hide_at = elapsed + 3.0
		elif _coins_callout_hide_at > 0.0 and elapsed >= _coins_callout_hide_at:
			tutorial_banner.visible = false
			_coins_callout_hide_at = -1.0
		if not _guaranteed_seed_done and elapsed >= 30.0:
			_spawn_guaranteed_seed(GameState.SEED_TYPE_CLOVER, 1)
			_guaranteed_seed_done = true
	elif GameState.is_tutorial_run2():
		if not _tutorial_obstacle_done and elapsed >= 25.0:
			_spawn_obstacle_at_lane(1)
			_tutorial_obstacle_done = true


func _end_run(failed: bool) -> void:
	if _state == 1:
		return
	_state = 1
	player.set_input_enabled(false)
	tutorial_banner.visible = false
	GameState.finish_run(seeds_by_type.duplicate(), coin_count, failed, elapsed)
	GameState.go_to_scene(GameState.SCENE_LOOT)


func _viewport_size() -> Vector2:
	return get_viewport_rect().size


func _calculate_lanes() -> void:
	var width := _viewport_size().x
	lane_x_positions = [width * 0.25, width * 0.5, width * 0.75]
	player.setup_lanes(lane_x_positions)


func _draw_lane_guides() -> void:
	for child in lane_guides.get_children():
		child.queue_free()
	var height := _viewport_size().y
	for x in lane_x_positions:
		var line := Line2D.new()
		line.width = 4.0
		line.default_color = Color(1.0, 1.0, 1.0, 0.08)
		line.points = PackedVector2Array([Vector2(x, 0.0), Vector2(x, height)])
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


func _spawn_guaranteed_seed(type_id: String, lane: int) -> void:
	var seed := _seed_scene.instantiate()
	seed.position = Vector2(lane_x_positions[lane], -80.0)
	if seed.has_method("setup"):
		seed.setup(type_id, GameState.get_seed_rarity(type_id))
	seed.collected.connect(_on_seed_collected)
	world.add_child(seed)


func _spawn_obstacle_at_lane(lane: int) -> void:
	var obstacle := _obstacle_scene.instantiate()
	obstacle.position = Vector2(lane_x_positions[lane], -80.0)
	world.add_child(obstacle)


func _try_spawn() -> void:
	if randf() > SPAWN_CHANCE:
		return

	var lane := randi() % 3
	var spawn_pos := Vector2(lane_x_positions[lane], -80.0)

	if GameState.obstacles_enabled_for_run() and randf() < OBSTACLE_CHANCE:
		var obstacle := _obstacle_scene.instantiate()
		obstacle.position = spawn_pos
		world.add_child(obstacle)
	elif randf() < _effective_seed_spawn_chance():
		var seed := _seed_scene.instantiate()
		seed.position = spawn_pos
		var type_id := _pick_seed_type_id()
		if seed.has_method("setup"):
			seed.setup(type_id, GameState.get_seed_rarity(type_id))
		seed.collected.connect(_on_seed_collected)
		world.add_child(seed)
	else:
		var coin := _coin_scene.instantiate()
		coin.position = spawn_pos
		coin.collected.connect(_on_coin_collected)
		world.add_child(coin)


func _effective_seed_spawn_chance() -> float:
	var chance := PICKUP_SEED_CHANCE
	if not GameState.get_loadout_type().is_empty():
		chance += GameState.LOADOUT_SPAWN_BONUS
	return minf(chance, 0.85)


func _pick_seed_type_id() -> String:
	var loadout := GameState.get_loadout_type()
	if not loadout.is_empty():
		return loadout
	return GameState.SEED_TYPE_CLOVER


func _on_coin_collected() -> void:
	coin_count += 1
	_update_hud()


func _on_seed_collected(type_id: String) -> void:
	seeds_by_type[type_id] = int(seeds_by_type.get(type_id, 0)) + 1
	_update_hud()


func _on_player_hit_obstacle() -> void:
	_end_run(true)


func _update_hud() -> void:
	coin_counter_label.text = "Coins: %d" % coin_count
	seed_counter_label.text = "Seeds: %d" % GameState.sum_seed_bag(seeds_by_type)
	if not GameState.get_loadout_type().is_empty():
		var name: String = GameState.SEED_DISPLAY_NAMES.get(
			GameState.get_loadout_type(),
			GameState.get_loadout_type().capitalize()
		)
		loadout_label.text = "Basket: %s" % name
		loadout_label.visible = true
	else:
		loadout_label.visible = false
	var remaining := maxf(0.0, GameState.get_run_duration() - elapsed)
	timer_label.text = "%ds" % int(ceil(remaining))
