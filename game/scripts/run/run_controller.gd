extends Node2D

const BASE_SCROLL_SPEED := 400.0
const SPAWN_INTERVAL := 1.2
const SPAWN_CHANCE := 0.7
const OBSTACLE_CHANCE := 0.25
const PICKUP_SEED_CHANCE := 0.30
const DIAMOND_SEED_RATIO := 300
const RAMP_STEP := 0.05
const RAMP_EVERY := 15.0

const PICKUP_ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var top_hud: MarginContainer = $HUD/TopHud
@onready var loadout_label: Label = $HUD/TopHud/TopHudVBox/TopRow/PipBadge/LoadoutLabel
@onready var pip_name_label: Label = $HUD/TopHud/TopHudVBox/TopRow/PipBadge/PipName
@onready var pip_portrait: Control = $HUD/TopHud/TopHudVBox/TopRow/PipBadge/PipPortrait
@onready var pickup_feed: Label = $HUD/TopHud/TopHudVBox/PickupFeed
@onready var world: Node2D = $World
@onready var player: Area2D = $Player
@onready var coin_counter_label: Label = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/CoinRow/CoinLabel
@onready var seed_counter_label: Label = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/SeedRow/SeedLabel
@onready var diamond_counter_label: Label = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/DiamondRow/DiamondLabel
@onready var coin_hud_icon: TextureRect = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/CoinRow/CoinIcon
@onready var seed_hud_icon: TextureRect = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/SeedRow/SeedIcon
@onready var diamond_hud_icon: TextureRect = $HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/DiamondRow/DiamondIcon
@onready var timer_label: Label = $HUD/TopHud/TopHudVBox/TopRow/TimerLabel
@onready var tutorial_banner: Label = $HUD/TopHud/TopHudVBox/TutorialBanner

var _coin_scene: PackedScene = preload("res://scenes/run/coin.tscn")
var _seed_scene: PackedScene = preload("res://scenes/run/seed_pickup.tscn")
var _diamond_scene: PackedScene = preload("res://scenes/run/diamond_pickup.tscn")
var _obstacle_scene: PackedScene = preload("res://scenes/run/obstacle.tscn")

var _state: int = 0  # 0=running
var _world_ready: bool = false
var lane_x_positions: Array[float] = []
var scroll_speed: float = BASE_SCROLL_SPEED
var elapsed: float = 0.0
var coin_count: int = 0
var seeds_by_type: Dictionary = {}
var spawn_timer: float = 0.0
var _spawn_interval: float = SPAWN_INTERVAL
var _spawn_chance: float = SPAWN_CHANCE
var _obstacle_chance: float = OBSTACLE_CHANCE
var _pickup_seed_chance: float = PICKUP_SEED_CHANCE
var _scroll_speed_base: float = BASE_SCROLL_SPEED
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
	_setup_pickup_hud_icons()
	_setup_safe_area()
	player.position.y = _viewport_size().y * 0.82
	_world_ready = true


func _setup_safe_area() -> void:
	if top_hud:
		SAFE_AREA.apply_top_margin(top_hud, 8.0)


func _setup_pickup_hud_icons() -> void:
	var coin_tex := PICKUP_ASSETS.get_coin_texture()
	var seed_tex := PICKUP_ASSETS.get_seed_texture()
	var diamond_tex := PICKUP_ASSETS.get_diamond_texture()
	if coin_hud_icon and coin_tex:
		coin_hud_icon.texture = coin_tex
	if seed_hud_icon and seed_tex:
		seed_hud_icon.texture = seed_tex
	if diamond_hud_icon and diamond_tex:
		diamond_hud_icon.texture = diamond_tex


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
	_apply_run_level_config()
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
	scroll_speed = _scroll_speed_base * pow(1.0 + RAMP_STEP, ramp_level)

	spawn_timer += delta
	if spawn_timer >= _spawn_interval:
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


func _apply_run_level_config() -> void:
	_scroll_speed_base = BASE_SCROLL_SPEED
	_spawn_interval = SPAWN_INTERVAL
	_spawn_chance = SPAWN_CHANCE
	_obstacle_chance = OBSTACLE_CHANCE
	_pickup_seed_chance = PICKUP_SEED_CHANCE
	if not GameState.uses_run_level_config():
		return
	var cfg = GameState.get_active_run_level_config()
	_scroll_speed_base = BASE_SCROLL_SPEED * cfg.scroll_speed_mult
	_spawn_interval = cfg.spawn_interval
	_spawn_chance = cfg.spawn_chance
	_obstacle_chance = cfg.obstacle_chance
	_pickup_seed_chance = cfg.pickup_seed_chance


func _try_spawn() -> void:
	if randf() > _spawn_chance:
		return

	var lane := randi() % 3
	var spawn_pos := Vector2(lane_x_positions[lane], -80.0)

	if GameState.obstacles_enabled_for_run() and randf() < _obstacle_chance:
		var obstacle := _obstacle_scene.instantiate()
		obstacle.position = spawn_pos
		world.add_child(obstacle)
	elif randf() < _effective_seed_spawn_chance():
		if randf() < 1.0 / float(DIAMOND_SEED_RATIO):
			_spawn_diamond(spawn_pos)
		else:
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


func _spawn_diamond(spawn_pos: Vector2) -> void:
	var diamond := _diamond_scene.instantiate()
	diamond.position = spawn_pos
	diamond.collected.connect(_on_diamond_collected)
	world.add_child(diamond)


func _effective_seed_spawn_chance() -> float:
	var chance := _pickup_seed_chance
	if not GameState.get_loadout_type().is_empty():
		chance += GameState.LOADOUT_SPAWN_BONUS
	return minf(chance, 0.85)


func _pick_seed_type_id() -> String:
	return GameState.pick_random_run_seed_type()


func _on_coin_collected() -> void:
	coin_count += 1
	if pickup_feed and pickup_feed.has_method("push_coin"):
		pickup_feed.push_coin()
	_update_hud()


func _on_seed_collected(type_id: String) -> void:
	seeds_by_type[type_id] = int(seeds_by_type.get(type_id, 0)) + 1
	GameState.record_seed_pickup_lifetime(type_id, 1)
	if pickup_feed and pickup_feed.has_method("push_seed"):
		pickup_feed.push_seed(type_id)
	_update_hud()


func _on_diamond_collected() -> void:
	GameState.add_diamonds(1)
	if pickup_feed:
		pickup_feed.text = "+1 diamond"
	_update_hud()


func _on_player_hit_obstacle() -> void:
	_end_run(true)


func _update_hud() -> void:
	if coin_counter_label == null or seed_counter_label == null:
		return
	coin_counter_label.text = "%d" % coin_count
	seed_counter_label.text = "%d" % _sum_run_seeds()
	if diamond_counter_label:
		diamond_counter_label.text = "%d" % GameState.get_diamonds()
	if pip_name_label:
		pip_name_label.text = GameState.get_companion_display_name()
	if pip_portrait and pip_portrait.has_method("refresh_portrait"):
		pip_portrait.refresh_portrait()
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
	if GameState.is_endless_mode():
		timer_label.text = "Endless · %s · %ds" % [
			GameState.get_endless_difficulty_label(),
			int(ceil(remaining)),
		]
	elif GameState.uses_run_level_config():
		timer_label.text = "Lv %d · %ds" % [GameState.run_level, int(ceil(remaining))]
	else:
		timer_label.text = "%ds" % int(ceil(remaining))


func _sum_run_seeds() -> int:
	var total := 0
	for type_id in seeds_by_type:
		total += int(seeds_by_type[type_id])
	return total
