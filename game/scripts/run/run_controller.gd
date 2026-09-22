extends Node2D

## Lane runner. Mechanics (lanes, swipe, spawn, magnet, 50/100 loot) stay as in §2.
## Visuals: design_handoff_run direction A. Obstacle collision stays 64×64.

const BASE_SCROLL_SPEED := 400.0
const SPAWN_INTERVAL := 1.2
const SPAWN_CHANCE := 0.7
const OBSTACLE_CHANCE := 0.25
const PICKUP_SEED_CHANCE := 0.30
const DIAMOND_SEED_RATIO := 300
const RAMP_STEP := 0.05
const RAMP_EVERY := 15.0

const _STATE_RUNNING := 0
const _STATE_ENDED := 1
const _STATE_PAUSED := 2

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")
const TOKEN_SCRIPT := preload("res://scripts/run/run_token.gd")
const RING_SCRIPT := preload("res://scripts/run/run_ring_fx.gd")

@onready var background: Sprite2D = $Background
@onready var top_hud: Control = $HUD/TopHud
@onready var timer_chip: Panel = $HUD/TopHud/TimerChip
@onready var timer_ring: Control = $HUD/TopHud/TimerChip/Row/Ring
@onready var mode_label: Label = $HUD/TopHud/TimerChip/Row/TextCol/ModeLabel
@onready var seconds_label: Label = $HUD/TopHud/TimerChip/Row/TextCol/SecondsLabel
@onready var pause_button: Control = $HUD/TopHud/PauseButton
@onready var companion_chip: Panel = $HUD/TopHud/CompanionChip
@onready var pip_name_label: Label = $HUD/TopHud/CompanionChip/Row/PipName
@onready var pip_portrait: Control = $HUD/TopHud/CompanionChip/Row/PipPortrait
@onready var coin_chip: Panel = $HUD/TopHud/PickupBar/CoinChip
@onready var seed_chip: Panel = $HUD/TopHud/PickupBar/SeedChip
@onready var diamond_chip: Panel = $HUD/TopHud/PickupBar/DiamondChip
@onready var coin_counter_label: Label = $HUD/TopHud/PickupBar/CoinChip/Row/CoinLabel
@onready var seed_counter_label: Label = $HUD/TopHud/PickupBar/SeedChip/Row/SeedLabel
@onready var diamond_counter_label: Label = $HUD/TopHud/PickupBar/DiamondChip/Row/DiamondLabel
@onready var coin_hud_icon: TextureRect = $HUD/TopHud/PickupBar/CoinChip/Row/CoinIcon
@onready var seed_hud_icon: TextureRect = $HUD/TopHud/PickupBar/SeedChip/Row/SeedIcon
@onready var diamond_hud_icon: TextureRect = $HUD/TopHud/PickupBar/DiamondChip/Row/DiamondIcon
@onready var basket_badge: Panel = $HUD/TopHud/BasketBadge
@onready var basket_icon: TextureRect = $HUD/TopHud/BasketBadge/Row/BasketIcon
@onready var loadout_label: Label = $HUD/TopHud/BasketBadge/Row/LoadoutLabel
@onready var pickup_feed: Control = $HUD/TopHud/PickupFeed
@onready var tutorial_cue: Panel = $HUD/TopHud/TutorialCue
@onready var tutorial_banner: Label = $HUD/TopHud/TutorialCue/TutorialBanner
@onready var pause_overlay: Control = $HUD/PauseOverlay
@onready var pause_panel: Panel = $HUD/PauseOverlay/Panel
@onready var keep_button: Control = $HUD/PauseOverlay/Panel/VBox/KeepButton
@onready var quit_button: Control = $HUD/PauseOverlay/Panel/VBox/QuitButton
@onready var fail_flash: ColorRect = $HUD/FailFlash
@onready var finish_banner: Panel = $HUD/FinishBanner
@onready var fly_layer: Node2D = $HUD/FlyLayer
@onready var world: Node2D = $World
@onready var player: Area2D = $Player

var _coin_scene: PackedScene = preload("res://scenes/run/coin.tscn")
var _seed_scene: PackedScene = preload("res://scenes/run/seed_pickup.tscn")
var _diamond_scene: PackedScene = preload("res://scenes/run/diamond_pickup.tscn")
var _obstacle_scene: PackedScene = preload("res://scenes/run/obstacle.tscn")

var _state: int = _STATE_RUNNING
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
var _next_obstacle_stump: bool = false


func _ready() -> void:
	player.hit_obstacle.connect(_on_player_hit_obstacle)
	pause_button.clicked.connect(_on_pause_pressed)
	keep_button.clicked.connect(_on_keep_running)
	quit_button.clicked.connect(_on_quit_to_camp)
	_apply_hud_styles()
	_setup_pickup_hud_icons()
	if pickup_feed and pickup_feed.has_method("bind_targets"):
		pickup_feed.bind_targets(coin_chip, seed_chip, diamond_chip, fly_layer)
	_hide_tutorial()
	pause_overlay.visible = false
	fail_flash.visible = false
	finish_banner.visible = false
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
	_layout_hud()
	_setup_safe_area()
	player.position.y = _viewport_size().y * UiRun.PLAYER_Y_RATIO
	_world_ready = true


func _setup_safe_area() -> void:
	if top_hud == null:
		return
	var inset := SAFE_AREA.get_insets(get_viewport()).x
	var extra := maxf(0.0, inset - float(UiRun.SAFE_TOP))
	top_hud.offset_top = extra
	top_hud.offset_bottom = extra


func _setup_pickup_hud_icons() -> void:
	_set_icon(coin_hud_icon, UiAssets.get_chrome_icon("icon_coin"))
	_set_icon(seed_hud_icon, UiAssets.get_chrome_icon("icon_seed"))
	_set_icon(diamond_hud_icon, UiAssets.get_chrome_icon("icon_diamond"))
	_set_icon(basket_icon, UiAssets.get_run_icon("icon_basket"))


func _set_icon(rect: TextureRect, tex: Texture2D) -> void:
	if rect == null:
		return
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func start_run() -> void:
	elapsed = 0.0
	coin_count = 0
	seeds_by_type = {}
	_guaranteed_seed_done = false
	_coins_callout_done = false
	_coins_callout_hide_at = -1.0
	_tutorial_obstacle_done = false
	_next_obstacle_stump = false
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
	_state = _STATE_RUNNING
	pause_overlay.visible = false
	fail_flash.visible = false
	finish_banner.visible = false
	position.x = 0.0
	_apply_run_level_config()
	spawn_timer = 0.0
	_clear_world_entities()
	player.reset_lane()
	player.set_magnet_radius(GameState.get_magnet_radius())
	player.set_input_enabled(true)
	_update_hud()


func _process(delta: float) -> void:
	if _state != _STATE_RUNNING or not _world_ready:
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

	_shift_world(delta, scroll_speed)
	_update_hud()


func _update_tutorial_run_events() -> void:
	if GameState.is_tutorial_run1():
		if not _coins_callout_done and elapsed >= 20.0:
			_show_tutorial("Coins for the shop!")
			_coins_callout_done = true
			_coins_callout_hide_at = elapsed + 3.0
		elif _coins_callout_hide_at > 0.0 and elapsed >= _coins_callout_hide_at:
			_hide_tutorial()
			_coins_callout_hide_at = -1.0
		if not _guaranteed_seed_done and elapsed >= 30.0:
			_spawn_guaranteed_seed(GameState.SEED_TYPE_CLOVER, 1)
			_guaranteed_seed_done = true
	elif GameState.is_tutorial_run2():
		if not _tutorial_obstacle_done and elapsed >= 25.0:
			_spawn_obstacle_at_lane(1)
			_tutorial_obstacle_done = true


func _show_tutorial(text: String) -> void:
	tutorial_banner.text = text
	tutorial_banner.visible = true
	tutorial_cue.visible = true


func _hide_tutorial() -> void:
	tutorial_banner.visible = false
	tutorial_cue.visible = false


func _end_run(failed: bool) -> void:
	if _state == _STATE_ENDED:
		return
	_state = _STATE_ENDED
	player.set_input_enabled(false)
	pause_overlay.visible = false
	_hide_tutorial()
	GameState.finish_run(seeds_by_type.duplicate(), coin_count, failed, elapsed)
	_play_end_and_leave(failed)


func _play_end_and_leave(failed: bool) -> void:
	if failed:
		await _play_fail_beat()
	else:
		await _play_finish_beat()
	if is_instance_valid(self):
		GameState.go_to_scene(GameState.SCENE_LOOT)


func _play_fail_beat() -> void:
	var pip := player.get_node_or_null("PipVisual") as Node2D
	var tw := create_tween()
	tw.tween_interval(UiRun.FAIL_FREEZE)
	tw.tween_callback(func() -> void:
		if pip:
			pip.rotation_degrees = -13.0
		_spill_tokens()
		_shake()
	)
	tw.tween_interval(UiRun.FAIL_SHAKE - UiRun.FAIL_FLASH)
	tw.tween_callback(func() -> void:
		fail_flash.visible = true
	)
	await get_tree().create_timer(UiRun.FAIL_TOTAL).timeout
	fail_flash.visible = false
	position.x = 0.0


func _play_finish_beat() -> void:
	if timer_ring and timer_ring.has_method("set_progress"):
		timer_ring.set_progress(0.0, UiRun.RING_OK)
	finish_banner.visible = true
	_spawn_finish_burst()
	var start_speed := scroll_speed
	var t := 0.0
	while t < UiRun.FINISH_TOTAL:
		await get_tree().process_frame
		var delta := get_process_delta_time()
		if delta <= 0.0:
			delta = 1.0 / 60.0
		t += delta
		if t <= UiRun.FINISH_STOP:
			var k := 1.0 - clampf(t / UiRun.FINISH_STOP, 0.0, 1.0)
			_shift_world(delta, start_speed * k)


func _spill_tokens() -> void:
	var origin := player.position
	for i in 5:
		var token := Node2D.new()
		token.set_script(TOKEN_SCRIPT)
		token.position = origin
		add_child(token)
		var ang := -PI * 0.9 + float(i) * 0.38
		var dest := origin + Vector2(cos(ang), sin(ang)) * (80.0 + float(i) * 16.0)
		dest.y += 36.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(token, "position", dest, 0.28)
		tw.tween_property(token, "modulate:a", 0.0, 0.28)
		tw.chain().tween_callback(token.queue_free)


func _shake() -> void:
	var tw := create_tween()
	var step := UiRun.FAIL_SHAKE / 6.0
	for i in 6:
		var x := UiRun.FAIL_SHAKE_PX if i % 2 == 0 else -UiRun.FAIL_SHAKE_PX
		tw.tween_property(self, "position:x", x, step)
	tw.tween_property(self, "position:x", 0.0, 0.02)


func _spawn_finish_burst() -> void:
	var ring := Node2D.new()
	ring.set_script(RING_SCRIPT)
	ring.ring_color = Color(UiRun.RING_OK.r, UiRun.RING_OK.g, UiRun.RING_OK.b, 0.9)
	ring.ring_width = 8.0
	ring.scale = Vector2(16, 16)
	ring.position = timer_chip.get_global_rect().get_center()
	fly_layer.add_child(ring)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2(260, 260), UiRun.FINISH_BURST)
	tw.tween_property(ring, "modulate:a", 0.0, UiRun.FINISH_BURST)
	tw.chain().tween_callback(ring.queue_free)


func _on_pause_pressed() -> void:
	if _state != _STATE_RUNNING:
		return
	_state = _STATE_PAUSED
	player.set_input_enabled(false)
	pause_overlay.visible = true


func _on_keep_running() -> void:
	if _state != _STATE_PAUSED:
		return
	pause_overlay.visible = false
	_state = _STATE_RUNNING
	player.set_input_enabled(true)


func _on_quit_to_camp() -> void:
	if _state == _STATE_ENDED:
		return
	pause_overlay.visible = false
	_end_run(true)


func _viewport_size() -> Vector2:
	return get_viewport_rect().size


func _ui_scale() -> float:
	return _viewport_size().x / 1080.0


func _calculate_lanes() -> void:
	var width := _viewport_size().x
	lane_x_positions = [
		UiRun.lane_x(0, width),
		UiRun.lane_x(1, width),
		UiRun.lane_x(2, width),
	]
	player.setup_lanes(lane_x_positions)


func _clear_world_entities() -> void:
	for child in world.get_children():
		child.queue_free()


func _shift_world(delta: float, speed: float) -> void:
	var remove_y := _viewport_size().y + 100.0
	for child in world.get_children():
		child.position.y += speed * delta
		if child.position.y > remove_y:
			child.queue_free()
	if background and background.has_method("add_scroll"):
		background.add_scroll(speed * delta)


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
	_decorate_obstacle(obstacle)
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
		_decorate_obstacle(obstacle)
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


func _decorate_obstacle(obstacle: Node) -> void:
	var kind := "stump" if _next_obstacle_stump else "stone"
	_next_obstacle_stump = not _next_obstacle_stump
	if obstacle.has_method("set_kind"):
		obstacle.set_kind(kind)
	if obstacle.has_method("apply_season_tint"):
		obstacle.call("apply_season_tint")


func _spawn_diamond(spawn_pos: Vector2) -> void:
	var diamond := _diamond_scene.instantiate()
	diamond.position = spawn_pos
	diamond.collected.connect(_on_diamond_collected)
	world.add_child(diamond)


func _effective_seed_spawn_chance() -> float:
	var chance := _pickup_seed_chance
	if GameState.is_loadout_in_active_season_pool():
		chance += GameState.LOADOUT_SPAWN_BONUS
	return minf(chance, 0.85)


func _pick_seed_type_id() -> String:
	return GameState.pick_random_run_seed_type()


func _on_coin_collected(at: Vector2) -> void:
	coin_count += 1
	_update_hud()
	if pickup_feed and pickup_feed.has_method("push_coin"):
		pickup_feed.push_coin(at)


func _on_seed_collected(type_id: String, at: Vector2) -> void:
	seeds_by_type[type_id] = int(seeds_by_type.get(type_id, 0)) + 1
	GameState.record_seed_pickup_lifetime(type_id, 1)
	_update_hud()
	if pickup_feed and pickup_feed.has_method("push_seed"):
		pickup_feed.push_seed(type_id, at)


func _on_diamond_collected(at: Vector2) -> void:
	GameState.add_diamonds(1)
	_update_hud()
	if pickup_feed and pickup_feed.has_method("push_diamond"):
		pickup_feed.push_diamond(at)


func _on_player_hit_obstacle() -> void:
	_end_run(true)


func _update_hud() -> void:
	if coin_counter_label == null or seed_counter_label == null:
		return
	coin_counter_label.text = "%d" % coin_count
	seed_counter_label.text = "%d" % _sum_run_seeds()
	var diamonds := GameState.get_diamonds()
	if diamond_counter_label:
		diamond_counter_label.text = "%d" % diamonds
	if diamond_chip:
		diamond_chip.visible = diamonds > 0
	_layout_counters()
	if pip_name_label:
		pip_name_label.text = GameState.get_companion_display_name()
	if pip_portrait and pip_portrait.has_method("refresh_portrait"):
		pip_portrait.refresh_portrait()
	if not GameState.get_loadout_type().is_empty():
		var flower_name: String = GameState.SEED_DISPLAY_NAMES.get(
			GameState.get_loadout_type(),
			GameState.get_loadout_type().capitalize()
		)
		loadout_label.text = flower_name
		basket_badge.visible = true
	else:
		basket_badge.visible = false
	var duration := GameState.get_run_duration()
	var remaining := maxf(0.0, duration - elapsed)
	var lines: Array = UiRun.timer_lines(
		remaining,
		GameState.is_endless_mode(),
		GameState.get_endless_difficulty_label(),
		GameState.uses_run_level_config(),
		GameState.run_level,
	)
	mode_label.text = str(lines[0])
	seconds_label.text = str(lines[1])
	if timer_ring and timer_ring.has_method("set_progress"):
		var pct := 1.0 if duration <= 0.0 else remaining / duration
		timer_ring.set_progress(pct, UiRun.ring_color(remaining, duration))


func _sum_run_seeds() -> int:
	var total := 0
	for type_id in seeds_by_type:
		total += int(seeds_by_type[type_id])
	return total


func _layout_hud() -> void:
	var s := _ui_scale()
	_place_rect(timer_chip, UiRun.TIMER_RECT, s)
	_place_rect(pause_button, UiRun.PAUSE_RECT, s)
	_place_rect(companion_chip, UiRun.COMPANION_RECT, s)
	_place_rect(basket_badge, UiRun.BASKET_RECT, s)
	var toast := Rect2(600, UiRun.TOAST_TOP, 440, 150)
	_place_rect(pickup_feed, toast, s)
	var cue := Rect2(160, UiRun.CUE_TOP, 760, 110)
	_place_rect(tutorial_cue, cue, s)
	_layout_pause_panel(s)
	_layout_finish_banner(s)
	_layout_counters()


func _layout_counters() -> void:
	var s := _ui_scale()
	var right := (1080.0 - float(UiRun.BAR_RIGHT)) * s
	var top := float(UiRun.BAR_TOP) * s
	var gap := float(UiRun.COUNTER_GAP) * s
	var coin_size := UiRun.COUNTER_SIZE * s
	var seed_size := UiRun.COUNTER_SIZE * s
	var dia_size := UiRun.COUNTER_DIAMOND_SIZE * s
	var x := right
	if diamond_chip.visible:
		x -= dia_size.x
		_place_xy(diamond_chip, x, top, dia_size)
		x -= gap
	x -= seed_size.x
	_place_xy(seed_chip, x, top, seed_size)
	x -= gap + coin_size.x
	_place_xy(coin_chip, x, top, coin_size)


func _layout_pause_panel(s: float) -> void:
	var vp := _viewport_size()
	var panel_w := 900.0 * s
	var panel_h := 680.0 * s
	pause_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pause_panel.offset_left = (vp.x - panel_w) * 0.5
	pause_panel.offset_top = vp.y * 0.18
	pause_panel.offset_right = pause_panel.offset_left + panel_w
	pause_panel.offset_bottom = pause_panel.offset_top + panel_h
	keep_button.custom_minimum_size = Vector2(0, 140.0 * s)
	quit_button.custom_minimum_size = Vector2(0, 140.0 * s)


func _layout_finish_banner(s: float) -> void:
	var vp := _viewport_size()
	var w := 760.0 * s
	var h := 220.0 * s
	finish_banner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	finish_banner.offset_left = (vp.x - w) * 0.5
	finish_banner.offset_top = vp.y * 0.36
	finish_banner.offset_right = finish_banner.offset_left + w
	finish_banner.offset_bottom = finish_banner.offset_top + h


func _place_rect(node: Control, rect: Rect2, s: float) -> void:
	_place_xy(node, rect.position.x * s, rect.position.y * s, rect.size * s)


func _place_xy(node: Control, x: float, y: float, size: Vector2) -> void:
	node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	node.offset_left = x
	node.offset_top = y
	node.offset_right = x + size.x
	node.offset_bottom = y + size.y
	node.custom_minimum_size = size
	node.size = size


func _apply_hud_styles() -> void:
	var ink := UI_PALETTE.UI_TEXT
	timer_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(28), 16, 12))
	companion_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(26), 16, 12))
	coin_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(26), 14, 8))
	seed_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(26), 14, 8))
	diamond_chip.add_theme_stylebox_override("panel", _padded(UiRun.diamond_chip_style(), 12, 8))
	basket_badge.add_theme_stylebox_override("panel", _padded(UiRun.basket_style(), 14, 8))
	tutorial_cue.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(22), 18, 12))
	pause_panel.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(28), 36, 28))
	finish_banner.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(28), 28, 20))
	fail_flash.color = Color(UiRun.FAIL.r, UiRun.FAIL.g, UiRun.FAIL.b, 0.26)
	_style_label(mode_label, UiRun.FONT_MODE, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(seconds_label, UiRun.FONT_SECONDS, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(pip_name_label, UiRun.FONT_NAME, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(coin_counter_label, UiRun.FONT_COUNTER, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(seed_counter_label, UiRun.FONT_COUNTER, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(diamond_counter_label, UiRun.FONT_COUNTER, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(loadout_label, UiRun.FONT_BASKET, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(tutorial_banner, UiRun.FONT_TOAST, ink, HORIZONTAL_ALIGNMENT_CENTER)
	var title := pause_panel.get_node_or_null("VBox/Title") as Label
	var body := pause_panel.get_node_or_null("VBox/Body") as Label
	_style_label(title, UiRun.FONT_NAME, ink, HORIZONTAL_ALIGNMENT_CENTER)
	_style_label(body, UiRun.FONT_TOAST, ink, HORIZONTAL_ALIGNMENT_CENTER)
	if body:
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var finish_title := finish_banner.get_node_or_null("VBox/Title") as Label
	var finish_sub := finish_banner.get_node_or_null("VBox/Subtitle") as Label
	_style_label(finish_title, UiRun.FONT_SECONDS, ink, HORIZONTAL_ALIGNMENT_CENTER)
	_style_label(finish_sub, UiRun.FONT_TOAST, ink, HORIZONTAL_ALIGNMENT_CENTER)
	mode_label.clip_text = true
	seconds_label.clip_text = true


func _padded(style: StyleBoxFlat, x: float, y: float) -> StyleBoxFlat:
	style.content_margin_left = x
	style.content_margin_right = x
	style.content_margin_top = y
	style.content_margin_bottom = y
	return style


func _style_label(label: Label, size: int, color: Color, align: HorizontalAlignment) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 0)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
