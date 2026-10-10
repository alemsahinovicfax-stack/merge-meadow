extends Node2D

## Lane runner. Mechanics (lanes, swipe, spawn, magnet, 50/100 loot) stay as in §2.
## Visuals: design_handoff_run direction A. Obstacle collision stays 64×64.
## HUD: design_handoff_run_hud_v2 — jedan red (Level · coin · seed · pauza), traka napretka
## lijevo i nagradni grm na šavu staza.

const BASE_SCROLL_SPEED := 400.0
const SPAWN_INTERVAL := 1.2
const SPAWN_CHANCE := 0.7
const OBSTACLE_CHANCE := 0.25
const PICKUP_SEED_CHANCE := 0.30
const RAMP_STEP := 0.05
const RAMP_EVERY := 15.0

const _STATE_RUNNING := 0
const _STATE_ENDED := 1
const _STATE_PAUSED := 2

const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TOKEN_SCRIPT := preload("res://scripts/run/run_token.gd")
const RING_SCRIPT := preload("res://scripts/run/run_ring_fx.gd")

@onready var background: Sprite2D = $Background
@onready var top_hud: Control = $HUD/TopHud
@onready var level_chip: PanelContainer = $HUD/TopHud/LevelChip
@onready var flag_icon: TextureRect = $HUD/TopHud/LevelChip/Row/FlagIcon
@onready var mode_label: Label = $HUD/TopHud/LevelChip/Row/ModeLabel
@onready var pause_button: Control = $HUD/TopHud/PauseButton
@onready var coin_chip: PanelContainer = $HUD/TopHud/CoinChip
@onready var seed_chip: PanelContainer = $HUD/TopHud/SeedChip
@onready var coin_counter_label: Label = $HUD/TopHud/CoinChip/Row/CoinLabel
@onready var seed_counter_label: Label = $HUD/TopHud/SeedChip/Row/SeedLabel
@onready var coin_hud_icon: TextureRect = $HUD/TopHud/CoinChip/Row/CoinIcon
@onready var seed_hud_icon: TextureRect = $HUD/TopHud/SeedChip/Row/SeedIcon
@onready var pickup_feed: Control = $HUD/TopHud/PickupFeed
@onready var fail_flash: ColorRect = $HUD/FailFlash
@onready var fly_layer: Node2D = $HUD/FlyLayer
@onready var world: Node2D = $World
@onready var player: Area2D = $Player

var _coin_scene: PackedScene = preload("res://scenes/run/coin.tscn")
var _seed_scene: PackedScene = preload("res://scenes/run/seed_pickup.tscn")
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

## Pop-upovi runa (design_handoff_popups): R1 oblačić, R3 pauza, R4 banner. Svi žive u
## `_popup_root` (px baze 1080, skaliran na ekran) iznad HUD-a.
var _popup_root: Control
var tutorial_cue: CoachBubble
var pause_overlay: PopupModal
var keep_button: PopupButton
var quit_button: PopupButton
var finish_banner: RunBanner
var _banner_shown_at: float = -1.0

## Run HUD v2: traka napretka (sakrivena u Endlessu) i nagradni grm.
var progress_rail: RunProgressRail
var bush_fx: RunBushFx
var _mode_shown: String = ""
var _bush: RewardBush
var _next_bush_at: float = UiRun.BUSH_FIRST_AFTER
var bushes_spawned: int = 0
var bushes_collected: int = 0


func _ready() -> void:
	player.hit_obstacle.connect(_on_player_hit_obstacle)
	pause_button.clicked.connect(_on_pause_pressed)
	_build_popups()
	keep_button.clicked.connect(_on_keep_running)
	quit_button.clicked.connect(_on_quit_to_camp)
	_build_hud_v2()
	_apply_hud_styles()
	_setup_pickup_hud_icons()
	if pickup_feed and pickup_feed.has_method("bind_targets"):
		pickup_feed.bind_targets(coin_chip, seed_chip, fly_layer)
	_hide_tutorial()
	pause_overlay.close(false)
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
	if ResourceLoader.exists(RunProgressRail.FLAG_TEX):
		_set_icon(flag_icon, load(RunProgressRail.FLAG_TEX) as Texture2D)


## Traka napretka ide iza čipova u TopHud (pomjera se sa safe area); burst grma u FlyLayer.
func _build_hud_v2() -> void:
	progress_rail = RunProgressRail.new()
	top_hud.add_child(progress_rail)
	top_hud.move_child(progress_rail, 0)
	bush_fx = RunBushFx.new()
	fly_layer.add_child(bush_fx)


func _set_icon(rect: TextureRect, tex: Texture2D) -> void:
	if rect == null:
		return
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func start_run() -> void:
	_pip_play("run_start")
	elapsed = 0.0
	coin_count = 0
	seeds_by_type = {}
	_guaranteed_seed_done = false
	_coins_callout_done = false
	_coins_callout_hide_at = -1.0
	_tutorial_obstacle_done = false
	_next_obstacle_stump = false
	_next_bush_at = UiRun.BUSH_FIRST_AFTER
	_reset_common()


func _resume_run() -> void:
	GameState.resume_pending = false
	elapsed = GameState.carry_elapsed
	coin_count = GameState.carry_coins
	seeds_by_type = GameState.carry_seed_bag.duplicate()
	_guaranteed_seed_done = true
	_coins_callout_done = true
	_tutorial_obstacle_done = true
	_next_bush_at = elapsed + UiRun.BUSH_FIRST_AFTER
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
	_bush = null
	player.reset_lane()
	player.set_magnet_radius(GameState.get_magnet_radius())
	player.set_input_enabled(true)
	if progress_rail:
		progress_rail.reset()
	if bush_fx:
		bush_fx.prepare(GameState.active_season_id)
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
	_update_bush_spawn()

	_shift_world(delta, scroll_speed)
	# Brojevi u headeru se mijenjaju samo na pickupu; po frejmu ide samo traka.
	_update_rail()


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
		# Fer grm: prepreka čeka dok grm ne ode ±300 px od linije spawna.
		if not _tutorial_obstacle_done and elapsed >= 25.0 and not _bush_blocks_lane(1, -80.0):
			_spawn_obstacle_at_lane(1)
			_tutorial_obstacle_done = true


## R1 · oblačić s repom gore prema brojaču coina (ne pokriva staze ispred Pipa).
func _show_tutorial(text: String) -> void:
	tutorial_cue.setup([{"text": text, "icon": UiAssets.get_chrome_icon("icon_coin"), "disc": UiPopups.ACTIVE_RIM}], "up", true)
	var s := _ui_scale()
	var chip := Rect2(coin_chip.get_global_rect().position / s, coin_chip.get_global_rect().size / s)
	var tip := Vector2(chip.get_center().x, chip.end.y + 8.0)
	tutorial_cue.point_at(tip, 0.8, Rect2(24, 0, 1032, 1920))
	tutorial_cue.pop_in()


func _hide_tutorial() -> void:
	if tutorial_cue:
		tutorial_cue.visible = false


func get_tutorial_text() -> String:
	return tutorial_cue.text() if tutorial_cue and tutorial_cue.visible else ""


func is_paused() -> bool:
	return _state == _STATE_PAUSED


func _end_run(failed: bool) -> void:
	if _state == _STATE_ENDED:
		return
	_state = _STATE_ENDED
	player.set_input_enabled(false)
	pause_overlay.close(false)
	_hide_tutorial()
	GameState.finish_run(seeds_by_type.duplicate(), coin_count, failed, elapsed)
	_play_end_and_leave(failed)


func _play_end_and_leave(failed: bool) -> void:
	if failed:
		await _play_fail_beat()
	else:
		await _play_finish_beat()
	if not is_instance_valid(self):
		return
	# R4: banner drži ~1 s, pa se snimi zadnji kadar (R5 se crta preko njega).
	var left := finish_banner.hold_sec() - (_now() - _banner_shown_at)
	if _banner_shown_at >= 0.0 and left > 0.0:
		await get_tree().create_timer(left).timeout
	if not is_instance_valid(self):
		return
	finish_banner.visible = false
	fail_flash.visible = false
	await _capture_snapshot()
	if is_instance_valid(self):
		GameState.go_to_scene(GameState.SCENE_LOOT)


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


func _capture_snapshot() -> void:
	GameState.set("last_run_snapshot", null)
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	if not is_instance_valid(self):
		return
	var img := get_viewport().get_texture().get_image()
	if img != null and not img.is_empty():
		GameState.set("last_run_snapshot", ImageTexture.create_from_image(img))


func _play_fail_beat() -> void:
	_pip_play("fail")
	var tw := create_tween()
	tw.tween_interval(UiRun.FAIL_FREEZE)
	tw.tween_callback(func() -> void:
		_spill_tokens()
		_shake()
		_show_banner(false)
	)
	tw.tween_interval(UiRun.FAIL_SHAKE - UiRun.FAIL_FLASH)
	tw.tween_callback(func() -> void:
		fail_flash.visible = true
	)
	await get_tree().create_timer(UiRun.FAIL_TOTAL).timeout
	_pip_play("fail_dizzy")
	fail_flash.visible = false
	position.x = 0.0


func _play_finish_beat() -> void:
	_pip_play("finish")
	# Traka: na 100 % zastavica se podigne i dobije mint prsten, pa „Time!".
	if progress_rail and progress_rail.visible:
		progress_rail.finish()
	_show_banner(true)
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
	ring.ring_color = Color(UiRun.RAIL_FILL.r, UiRun.RAIL_FILL.g, UiRun.RAIL_FILL.b, 0.9)
	ring.ring_width = 8.0
	ring.scale = Vector2(16, 16)
	var from := level_chip.get_global_rect().get_center()
	if progress_rail and progress_rail.visible:
		from = progress_rail.flag_center()
	ring.position = from
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
	_fill_pause()
	pause_overlay.open(true)


func _on_keep_running() -> void:
	if _state != _STATE_PAUSED:
		return
	pause_overlay.close(true)
	_state = _STATE_RUNNING
	player.set_input_enabled(true)


func _on_quit_to_camp() -> void:
	if _state == _STATE_ENDED:
		return
	pause_overlay.close(false)
	_end_run(true)


## Android back na pauzi = Keep running (README § Sistem · Zatvaranje).
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and _state == _STATE_PAUSED:
		_on_keep_running()


# --- pop-upovi ---

func _build_popups() -> void:
	_popup_root = Control.new()
	_popup_root.name = "PopupRoot"
	_popup_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(_popup_root)
	$HUD.move_child(_popup_root, fail_flash.get_index() + 1)
	tutorial_cue = CoachBubble.new()
	tutorial_cue.name = "TutorialCue"
	tutorial_cue.visible = false
	_popup_root.add_child(tutorial_cue)
	finish_banner = RunBanner.new()
	finish_banner.name = "FinishBanner"
	finish_banner.visible = false
	_popup_root.add_child(finish_banner)
	pause_overlay = PopupModal.new()
	pause_overlay.name = "PauseOverlay"
	pause_overlay.setup(UiPopups.S_PAUSED, "decision", true)
	_popup_root.add_child(pause_overlay)
	keep_button = PopupButton.new()
	keep_button.name = "KeepButton"
	keep_button.configure("primary", UiPopups.S_KEEP_RUNNING)
	keep_button.glyph = "play"
	quit_button = PopupButton.new()
	quit_button.name = "QuitButton"
	quit_button.configure("secondary", UiPopups.S_QUIT_TO_CAMP, false, UiPopups.icon("icon_half"))
	_layout_popup_root()


func _layout_popup_root() -> void:
	if _popup_root == null:
		return
	var s := _ui_scale()
	var base := _viewport_size() / s
	_popup_root.position = Vector2.ZERO
	_popup_root.scale = Vector2(s, s)
	_popup_root.size = base
	pause_overlay.position = Vector2.ZERO
	pause_overlay.size = base
	pause_overlay.area = Rect2(Vector2.ZERO, base)
	finish_banner.position = Vector2(0.0, UiPopups.BANNER_Y * base.y / 1920.0)
	finish_banner.size = Vector2(base.x, 300.0)


## R3 · „If you quit": isti kept/was kao finish_run na padu — prvo × loot multiplier, pa ceil 50 %.
func _fill_pause() -> void:
	for b in [keep_button, quit_button]:
		if b.get_parent() != null:
			b.get_parent().remove_child(b)
	pause_overlay.clear_content()
	var chips: Array = []
	var mult := GameState.get_loot_multiplier()
	if coin_count > 0:
		var scaled_coins := int(round(float(coin_count) * mult))
		var kept_coins := int(ceil(float(scaled_coins) * 0.5))
		chips.append(RewardChip.new().setup("coin", "", kept_coins, scaled_coins, false, false))
	for type_id in seeds_by_type:
		var n := int(seeds_by_type[type_id])
		if n > 0:
			var scaled_n := int(round(float(n) * mult))
			var kept_n := int(ceil(float(scaled_n) * 0.5))
			chips.append(RewardChip.new().setup("seed", str(type_id), kept_n, scaled_n, false, false))
	var tray := RewardTray.new().setup(880.0, chips, UiPopups.S_IF_YOU_QUIT)
	tray.name = "RewardTray"
	pause_overlay.content.add_child(PopupModal.centered(tray))
	var col := VBoxContainer.new()
	col.name = "ModalButtons"
	col.add_theme_constant_override("separation", 24)
	col.add_child(keep_button)
	col.add_child(quit_button)
	pause_overlay.content.add_child(col)


func _show_banner(time_up: bool) -> void:
	finish_banner.setup(time_up)
	finish_banner.visible = true
	finish_banner.pop_in()
	_banner_shown_at = _now()


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

	# Fer grm: nema prepreke u susjednim stazama ±300 px od grma — umjesto nje ide pickup.
	if GameState.obstacles_enabled_for_run() and randf() < _obstacle_chance \
			and not _bush_blocks_lane(lane, spawn_pos.y):
		var obstacle := _obstacle_scene.instantiate()
		obstacle.position = spawn_pos
		_decorate_obstacle(obstacle)
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


func _decorate_obstacle(obstacle: Node) -> void:
	var kind := "stump" if _next_obstacle_stump else "stone"
	_next_obstacle_stump = not _next_obstacle_stump
	if obstacle.has_method("set_kind"):
		obstacle.set_kind(kind)
	if obstacle.has_method("apply_season_tint"):
		obstacle.call("apply_season_tint")


func _effective_seed_spawn_chance() -> float:
	var chance := _pickup_seed_chance
	if GameState.is_loadout_in_active_season_pool():
		chance += GameState.LOADOUT_SPAWN_BONUS
	return minf(chance, 0.85)


func _pick_seed_type_id() -> String:
	return GameState.pick_random_run_seed_type()


## Pip portret u headeru je izbačen (Run HUD v2) — animacija ide samo Pipu na stazi.
func _pip_play(run_id: String) -> void:
	var pv := player.get_node_or_null("PipVisual") if player != null else null
	if pv != null and pv.has_method("play_event"):
		pv.call("play_event", run_id)


func _on_coin_collected(at: Vector2) -> void:
	coin_count += 1
	_pip_play("pickup_coin")
	_update_hud()
	if pickup_feed and pickup_feed.has_method("push_coin"):
		pickup_feed.push_coin(at)


func _on_seed_collected(type_id: String, at: Vector2) -> void:
	var amount := 2 if randf() < UiCamp.twin_chance(GameState.get_twin_seeds_level()) else 1
	seeds_by_type[type_id] = int(seeds_by_type.get(type_id, 0)) + amount
	# +2 ide u loot prije množitelja. Lanac otključavanja i dalje broji jedan pickup.
	GameState.record_seed_pickup_lifetime(type_id, 1)
	_pip_play("pickup_seed")
	_update_hud()
	if pickup_feed and pickup_feed.has_method("push_seed"):
		pickup_feed.push_seed(type_id, at, amount)


# --- nagradni grm (design_handoff_run_hud_v2 · run_hud_export.json → bush) ---

## Jedan grm na ekranu; prvi tek posle 6 s, pa svakih 8–12 s; nikad u tutorial runu 1.
func _update_bush_spawn() -> void:
	if GameState.is_tutorial_run1() or elapsed < _next_bush_at:
		return
	if _bush != null and is_instance_valid(_bush):
		return
	var y := -80.0
	var first := randi() % 2
	for k in 2:
		var seam := (first + k) % 2
		if _obstacle_near_seam(seam, y):
			continue
		_spawn_bush(seam, y)
		_next_bush_at = elapsed + randf_range(UiRun.BUSH_GAP_MIN, UiRun.BUSH_GAP_MAX)
		return
	# Oba šava blokirana preprekom — probaj u sljedećem frejmu.


func _spawn_bush(seam: int, y: float) -> RewardBush:
	var reward := UiRun.roll_bush_reward(randf(), randf())
	var bush := RewardBush.new().setup(seam, GameState.active_season_id, reward)
	bush.name = "RewardBush"
	bush.position = Vector2(UiRun.bush_seam_x(seam, _viewport_size().x), y)
	bush.collected.connect(_on_bush_collected)
	world.add_child(bush)
	_bush = bush
	bushes_spawned += 1
	return bush


## Staze uz šav `seam` su `seam` i `seam + 1`.
func _obstacle_near_seam(seam: int, y: float) -> bool:
	for child in world.get_children():
		if not child.is_in_group("obstacle"):
			continue
		var lane := _lane_of(child.position.x)
		if (lane == seam or lane == seam + 1) and absf(child.position.y - y) < UiRun.BUSH_FAIR_PX:
			return true
	return false


func _bush_blocks_lane(lane: int, y: float) -> bool:
	if _bush == null or not is_instance_valid(_bush) or _bush.is_collected():
		return false
	if lane != _bush.seam and lane != _bush.seam + 1:
		return false
	return absf(_bush.position.y - y) < UiRun.BUSH_FAIR_PX


func _lane_of(x: float) -> int:
	var best := 0
	for i in lane_x_positions.size():
		if absf(lane_x_positions[i] - x) < absf(lane_x_positions[best] - x):
			best = i
	return best


## Twin Seeds, korpa i magnet se ne primjenjuju; nagrada ide u isti run bag / coin brojač.
func _on_bush_collected(bush: RewardBush) -> void:
	if _state == _STATE_ENDED:
		return
	bushes_collected += 1
	var at := bush.global_position
	var kind := bush.reward_kind
	var amount := bush.reward_amount
	var target: Control = coin_chip
	if kind == "coin":
		coin_count += amount
		_pip_play("pickup_coin")
	else:
		var type_id := _pick_seed_type_id()
		seeds_by_type[type_id] = int(seeds_by_type.get(type_id, 0)) + amount
		GameState.record_seed_pickup_lifetime(type_id, 1)
		_pip_play("pickup_seed")
		target = seed_chip
		if pickup_feed and pickup_feed.has_method("push_seed_toast"):
			pickup_feed.push_seed_toast(type_id, amount)
	_update_hud()
	if bush_fx:
		bush_fx.play(at, bush.season_id, kind, amount, target)


func _on_player_hit_obstacle() -> void:
	_end_run(true)


func _update_hud() -> void:
	if coin_counter_label == null or seed_counter_label == null:
		return
	coin_counter_label.text = "%d" % coin_count
	seed_counter_label.text = "%d" % _sum_run_seeds()
	var endless := GameState.is_endless_mode()
	var text := UiRun.mode_text(
		endless,
		GameState.get_endless_difficulty_label(),
		GameState.uses_run_level_config(),
		GameState.run_level,
	)
	if text != _mode_shown:
		_apply_mode(text, endless)
	_update_rail()


## LevelChip: „Level N" 48 px / „Endless · X" 42 px bez zastavice / „Practice" sa zastavicom.
## Širina raste s tekstom (min 200, max 464); traka napretka samo kad run ima cilj.
func _apply_mode(text: String, endless: bool) -> void:
	_mode_shown = text
	var px := UiRun.FONT_LEVEL_ENDLESS if endless else UiRun.FONT_LEVEL
	mode_label.add_theme_font_override("font", UiPopups.font(900, px))
	mode_label.add_theme_font_size_override("font_size", px)
	mode_label.text = text
	flag_icon.visible = UiRun.has_goal(endless)
	if progress_rail:
		progress_rail.visible = UiRun.rail_visible(endless)
	_layout_level_chip()


func _layout_level_chip() -> void:
	var s := _ui_scale()
	var flag_w := (UiRun.LEVEL_FLAG.x + UiRun.LEVEL_GAP) if flag_icon.visible else 0.0
	var room := float(UiRun.LEVEL_CHIP_MAX_W - 2 * UiRun.LEVEL_CHIP_PAD_X) - flag_w
	# Bez rezanja label nosi punu širinu teksta; tek preko max 464 dobije „…" na fiksnoj širini
	# (Label s overrunom ima min širinu 0, pa ga ne smijemo ostaviti uključenog).
	mode_label.custom_minimum_size.x = 0.0
	mode_label.clip_text = false
	mode_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	if mode_label.get_minimum_size().x > room:
		mode_label.clip_text = true
		mode_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		mode_label.custom_minimum_size.x = room
	var w := clampf(level_chip.get_combined_minimum_size().x / maxf(s, 0.01),
		UiRun.LEVEL_CHIP_RECT.size.x, float(UiRun.LEVEL_CHIP_MAX_W))
	var r := UiRun.LEVEL_CHIP_RECT
	_place_rect(level_chip, Rect2(r.position, Vector2(w, r.size.y)), s)


func _update_rail() -> void:
	if progress_rail == null or not progress_rail.visible:
		return
	var duration := GameState.get_run_duration()
	progress_rail.set_progress(1.0 if duration <= 0.0 else elapsed / duration)


func _sum_run_seeds() -> int:
	var total := 0
	for type_id in seeds_by_type:
		total += int(seeds_by_type[type_id])
	return total


func _layout_hud() -> void:
	var s := _ui_scale()
	_place_rect(coin_chip, UiRun.COIN_CHIP_RECT, s)
	_place_rect(seed_chip, UiRun.SEED_CHIP_RECT, s)
	_place_rect(pause_button, UiRun.PAUSE_RECT, s)
	_place_rect(pickup_feed, UiRun.FEED_RECT, s)
	if progress_rail:
		progress_rail.scale = Vector2(s, s)
		progress_rail.position = UiRun.RAIL_RECT.position * s
	_layout_level_chip()
	_layout_popup_root()


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
	var ink := UiRun.INK
	level_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(), UiRun.LEVEL_CHIP_PAD_X, 0))
	coin_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(), 4, 0))
	seed_chip.add_theme_stylebox_override("panel", _padded(UiRun.chip_style(), 4, 0))
	fail_flash.color = Color(UiRun.FAIL.r, UiRun.FAIL.g, UiRun.FAIL.b, 0.26)
	_style_label(mode_label, UiRun.FONT_LEVEL, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(coin_counter_label, UiRun.FONT_COUNTER, ink, HORIZONTAL_ALIGNMENT_LEFT)
	_style_label(seed_counter_label, UiRun.FONT_COUNTER, ink, HORIZONTAL_ALIGNMENT_LEFT)
	for c in [coin_hud_icon, seed_hud_icon]:
		(c as TextureRect).custom_minimum_size = Vector2(UiRun.CHIP_ICON, UiRun.CHIP_ICON)
	flag_icon.custom_minimum_size = UiRun.LEVEL_FLAG


func _padded(style: StyleBoxFlat, x: float, y: float) -> StyleBoxFlat:
	style.content_margin_left = x
	style.content_margin_right = x
	style.content_margin_top = y
	style.content_margin_bottom = y
	return style


## Brojevi i nivo: Nunito 900, tamni tekst na kremi (12,6 : 1 na svakoj sezoni).
func _style_label(label: Label, size: int, color: Color, align: HorizontalAlignment) -> void:
	if label == null:
		return
	label.add_theme_font_override("font", UiPopups.font(900, size))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 0)
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
