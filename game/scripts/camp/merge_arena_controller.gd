extends Control

const ArenaSeedChip := preload("res://scripts/camp/arena_seed_chip.gd")
const ArenaSeedBag := preload("res://scripts/camp/arena_seed_bag.gd")
const ArenaVacuumFly := preload("res://scripts/camp/arena_vacuum_fly.gd")
const ArenaPest := preload("res://scripts/camp/arena_pest.gd")
const UI_PALETTE := preload("res://scripts/visual/ui_palette.gd")

## Spacing follows chip size; keepouts are center-based, so each adds the
## chip radius to the edge clearance it had at the original 48px radius.
const CHIP_MIN_DIST := ArenaSeedChip.CHIP_RADIUS * 2.0 + 6.0 * ArenaSeedChip.DISPLAY_SCALE
const CHIP_SEPARATION := CHIP_MIN_DIST
## Rub polja za centre sjemenki (83 px na 1080 — rešetka iz design_handoff_merge_arena).
const FIELD_MARGIN := ArenaSeedChip.CHIP_RADIUS + 16.0
const ARENA_COMBO_WINDOW_SEC := UiArenaV2.COMBO_WINDOW
const COMBO_HUD_MIN := 2
const COMBO_COIN_THRESHOLD := 5
const ARENA_AUTO_REFILL_AT := 12
const ARENA_TINT_T3_CAP := 4
const ARENA_PIP_REACT_SCALE := 1.18
const ARENA_PIP_REACT_SEC := 0.28
const COMBO_RIPPLE_POOL := 3
const COMBO_COIN_SIZE := 56.0
const COMBO_COIN_SEC := 0.5
const COMBO_CHIP_RING_GROW := 6.0
const COMBO_CHIP_RING_SEC := 0.3
const CLEAR_CHIP_SCALE := 1.12
const CLEAR_VFX_SEC := 0.4
const CLEAR_FLASH_COLOR := Color(1.0, 0.96, 0.82, 1.0)
const VACUUM_FLY_SEC := 0.38
const VACUUM_FLY_STAGGER_SEC := 0.05
const VACUUM_FLY_END_SCALE := 0.34
const VACUUM_BAG_PUNCH_SCALE := 1.14
const VACUUM_BAG_PUNCH_UP_SEC := 0.08
const VACUUM_BAG_PUNCH_DOWN_SEC := 0.12
# Tabela animacija (design_handoff_merge_arena).
const POUR_STAGGER_SEC := 0.04
const T3_RING_SIZE := 260.0
const T3_RING_WIDTH := 12
const T3_RING_START := 0.4
const T3_RING_END := 1.9
const T3_RING_SEC := 0.22
const T3_FLY_SEC := 0.52
const T3_FLY_END_SCALE := 0.45

## Jedini tekst koji je ostao u areni — prolazna poruka u oblacicu iznad vrece.
const CUE_PEST_AWAKE := "Muncher's awake — a T3 freezes it 2s."

@onready var meadow_bg: ArenaMeadowBg = $Bg
@onready var playfield: Control = $RootVBox/Playfield
@onready var arena_pip: Control = $RootVBox/Playfield/ArenaPip
## A3 · „You need more seeds!" (design_handoff_popups): modal s mrežom pločica (HFlowContainer —
## svi tipovi iz korpe vidljivi), linija „Every type needs 4" i jedno dugme Back to Camp.
var need_more_overlay: PopupModal
var need_more_tiles: HFlowContainer
var back_to_camp_button: PopupButton

var _chips: Array[ArenaSeedChip] = []
var _chip_data: Dictionary = {}
var _seed_bag: ArenaSeedBag
var _magnet_lock_drag: ArenaSeedChip = null
var _magnet_lock_partner: ArenaSeedChip = null
var _pest: ArenaPest
var _swipe_locked: bool = false
var _page_active: bool = true
var _combo_count: int = 0
var _combo_window_left: float = 0.0
var _combo_coin_granted_this_streak: bool = false
var _auto_pouring: bool = false
var _session_t3_count: int = 0
var _pip_react_tween: Tween = null
var _clear_vfx_done_this_pour: bool = false
var _clear_vfx_tween: Tween = null
var _clear_flash: ColorRect = null
var _vacuum_flies: Array[Control] = []
var _vacuum_fly_tweens: Array[Tween] = []
var _vacuum_fly_stagger: int = 0
var _bag_punch_tween: Tween = null
var _cue: ArenaCue = null
var _rng := RandomNumberGenerator.new()
## Sesija traje dok ima sjemenki na polju; kraj je prazno polje (spojeno ili pojedeno).
var _session_open: bool = false
var _combo_bonus: int = 0
var _fx_nodes: Array[Node] = []
var _combo_mark: ArenaComboMark = null
var _combo_mark_tween: Tween = null
var _combo_ripples: Array[Panel] = []
var _combo_ripple_next: int = 0
var _combo_ripple_tweens: Array[Tween] = []
var _hint_mark: MergeHintMark = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.randomize()
	_cue = ArenaCue.new(self)
	_build_need_more_overlay()
	playfield.resized.connect(_layout_playfield_chrome)
	call_deferred("_deferred_boot")


func _exit_tree() -> void:
	_kill_vacuum_flies()
	_set_hub_nav_locked(false)


func _deferred_boot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.apply_debug_leftover_test_bag()
	GameState.flush_bloom_inbox_to_album()
	var legacy := $RootVBox.get_node_or_null("InboxPanel")
	if legacy:
		legacy.visible = false
	_setup_bag()
	_setup_pest()
	_setup_combo_fx()
	need_more_overlay.close(false)
	_layout_playfield_chrome()
	_apply_season_field()
	_apply_meadow_tint()
	_update_tutorial_cue()
	_refresh_bag()


func _setup_bag() -> void:
	if _seed_bag != null:
		return
	_seed_bag = ArenaSeedBag.new()
	_seed_bag.name = "SeedBag"
	playfield.add_child(_seed_bag)
	_seed_bag.bag_clicked.connect(_on_bag_clicked)
	_layout_bag()


func _layout_bag() -> void:
	if _seed_bag == null or playfield == null:
		return
	var field := playfield.size
	if field.x < 10.0 or field.y < 10.0:
		return
	var x := (field.x - UiArenaV2.BASKET_HIT.x) * 0.5
	var y := field.y - UiArenaV2.BASKET_BOTTOM_GAP - UiArenaV2.BASKET_HIT.y
	_seed_bag.set_layout_position(Vector2(x, y))


func _layout_playfield_chrome() -> void:
	_layout_bag()
	_layout_arena_pip()
	_layout_pest_nest()
	if _cue and playfield:
		_cue.layout(playfield.size)


func _layout_arena_pip() -> void:
	if arena_pip == null or playfield == null:
		return
	var pip_size := Vector2(UiArena.PIP_SIZE, UiArena.PIP_SIZE)
	arena_pip.custom_minimum_size = pip_size
	arena_pip.size = pip_size
	arena_pip.position = Vector2(UiArena.PIP_INSET.x, playfield.size.y - UiArena.PIP_INSET.y - pip_size.y)
	arena_pip.pivot_offset = pip_size * 0.5
	arena_pip.z_index = 4
	arena_pip.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _add_session_t3() -> void:
	_session_t3_count += 1
	_apply_meadow_tint(true)
	_react_arena_pip(ARENA_PIP_REACT_SCALE, ARENA_PIP_REACT_SEC, "merge_t3")


func get_session_t3_count() -> int:
	return _session_t3_count


## Livada je mjesto aktivne sezone (UiArenaV2.FIELDS) — mijenja se samo kad nema sesije.
func _apply_season_field() -> void:
	if meadow_bg != null and not _session_open:
		meadow_bg.set_season(GameState.active_season_id)


func _apply_meadow_tint(animated: bool = false) -> void:
	if meadow_bg == null:
		return
	meadow_bg.set_t3_level(float(mini(_session_t3_count, ARENA_TINT_T3_CAP)), animated)


func _react_arena_pip(
	react_scale: float = ARENA_PIP_REACT_SCALE, react_sec: float = ARENA_PIP_REACT_SEC,
	anim: String = ""
) -> void:
	if arena_pip == null:
		return
	if arena_pip.has_method("play_pip"):
		var id := anim
		if id.is_empty():
			id = "combo_big" if react_scale >= 1.24 else "combo_hop"
		arena_pip.call("play_pip", id)
		return
	if _pip_react_tween != null:
		_pip_react_tween.kill()
		_pip_react_tween = null
	arena_pip.pivot_offset = arena_pip.size * 0.5
	arena_pip.scale = Vector2.ONE
	_pip_react_tween = create_tween()
	_pip_react_tween.tween_property(
		arena_pip, "scale", Vector2(react_scale, react_scale), react_sec * 0.45
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pip_react_tween.tween_property(arena_pip, "scale", Vector2.ONE, react_sec * 0.55).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)


func _reset_session_feel() -> void:
	_session_t3_count = 0
	_apply_meadow_tint()
	if _pip_react_tween != null:
		_pip_react_tween.kill()
		_pip_react_tween = null
	if arena_pip:
		arena_pip.scale = Vector2.ONE
	_clear_vfx_done_this_pour = false
	if _clear_vfx_tween != null:
		_clear_vfx_tween.kill()
		_clear_vfx_tween = null
	if _clear_flash:
		_clear_flash.visible = false
		_clear_flash.modulate.a = 0.0


func is_clear_of_pairs() -> bool:
	var counts: Dictionary = {}
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		var key := "%s:%d" % [chip.type_id, chip.tier]
		counts[key] = int(counts.get(key, 0)) + 1
	for n in counts.values():
		if int(n) >= 2:
			return false
	return true


func did_play_clear_vfx_this_pour() -> bool:
	return _clear_vfx_done_this_pour


func _maybe_play_clear_vfx() -> void:
	if _clear_vfx_done_this_pour:
		return
	if _chips.is_empty():
		return
	if not is_clear_of_pairs():
		return
	_clear_vfx_done_this_pour = true
	_play_clear_field_vfx()


func _ensure_clear_flash() -> void:
	if _clear_flash != null or playfield == null:
		return
	_clear_flash = ColorRect.new()
	_clear_flash.name = "ClearFlash"
	_clear_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_clear_flash.z_index = 8
	_clear_flash.color = CLEAR_FLASH_COLOR
	_clear_flash.modulate.a = 0.0
	_clear_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_clear_flash.visible = false
	playfield.add_child(_clear_flash)


func _play_clear_field_vfx() -> void:
	_ensure_clear_flash()
	if _clear_vfx_tween != null:
		_clear_vfx_tween.kill()
		_clear_vfx_tween = null
	if _clear_flash:
		_clear_flash.visible = true
		_clear_flash.modulate.a = 0.4
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		chip.pivot_offset = chip.size * 0.5
		chip.scale = Vector2.ONE
		var chip_tw := create_tween()
		chip_tw.tween_property(chip, "scale", Vector2(CLEAR_CHIP_SCALE, CLEAR_CHIP_SCALE), CLEAR_VFX_SEC * 0.45)
		chip_tw.tween_property(chip, "scale", Vector2.ONE, CLEAR_VFX_SEC * 0.55)
	if _clear_flash == null:
		return
	_clear_vfx_tween = create_tween()
	_clear_vfx_tween.tween_property(_clear_flash, "modulate:a", 0.0, CLEAR_VFX_SEC)
	_clear_vfx_tween.tween_callback(func() -> void:
		if _clear_flash:
			_clear_flash.visible = false
	)


func _setup_pest() -> void:
	if _pest != null:
		return
	_pest = ArenaPest.new()
	_pest.name = "MuncherPest"
	playfield.add_child(_pest)
	_pest.setup(
		_get_edible_chips_for_pest,
		_get_bag_keepout_rect,
		_pest_bounds,
		_pest_eat_chip
	)
	call_deferred("_layout_pest_nest")


func _layout_pest_nest() -> void:
	if _pest == null or playfield == null:
		return
	_pest.set_nest_position(Vector2(playfield.size.x * 0.5, UiArena.NEST_Y))
	_pest.reset_to_nest()


func _get_edible_chips_for_pest() -> Array:
	var out: Array = []
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		if chip.is_dragging():
			continue
		if chip.tier <= 2:
			out.append(chip)
	return out


func _pest_eat_chip(chip: ArenaSeedChip) -> void:
	if not _chips.has(chip):
		return
	_remove_chip(chip)
	_resolve_t3_starved_types()
	_resolve_stranded_t2()
	_update_tutorial_cue()
	_refresh_bag()
	_try_auto_refill()
	_resolve_t3_starved_types()
	_maybe_play_clear_vfx()
	call_deferred("_end_session_if_settled")


func _notify_meta_swipe_lock(locked: bool) -> void:
	_set_hub_nav_locked(locked)


func _set_hub_nav_locked(locked: bool) -> void:
	if not GameState.meta_hub_active:
		_swipe_locked = false
		return
	if _swipe_locked == locked:
		return
	_swipe_locked = locked
	for hub in get_tree().get_nodes_in_group("meta_hub"):
		if hub.has_method("set_nav_locked"):
			hub.set_nav_locked(locked)
		elif hub.has_method("set_swipe_enabled"):
			hub.set_swipe_enabled(not locked)


func _is_session_active() -> bool:
	if _chips.size() > 0:
		return true
	if _pest != null and _pest.is_active():
		return true
	return false


func _sync_hub_nav_lock() -> void:
	_set_hub_nav_locked(_is_session_active())


func set_arena_page_active(active: bool) -> void:
	_page_active = active
	process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	if active:
		if playfield:
			_layout_playfield_chrome()
		_apply_season_field()
		_refresh_bag()
		_sync_hub_nav_lock()
	else:
		_hide_need_more_overlay()
		_clear_merge_hint()
		if _pest and not _session_open:
			_pest.reset_to_nest()
		# Stay locked only while session lives; tabs should already block leave.
		_sync_hub_nav_lock()


func set_meta_hub_mode(_enabled: bool) -> void:
	# Arena vise nema Back ni naslov — izlaz je Done, a hub tab nosi ime stranice.
	pass


func refresh_for_meta_hub() -> void:
	_refresh_bag()
	_update_tutorial_cue()
	_sync_hub_nav_lock()


## `at` = mjesto spajanja u koordinatama Playfielda (INF = bez efekta na polju, npr. smoke).
## `t3` = T3 merge: T3 burst zamjenjuje combo talas (jedan prsten, ne dva).
func register_arena_combo_merge(at: Vector2 = Vector2.INF, t3: bool = false) -> void:
	if _combo_window_left > 0.0:
		_combo_count += 1
	else:
		_combo_count = 1
	_combo_window_left = ARENA_COMBO_WINDOW_SEC
	var coin_now := false
	if _combo_count == COMBO_COIN_THRESHOLD and not _combo_coin_granted_this_streak:
		_combo_bonus = GameState.try_grant_arena_combo_coins()
		_combo_coin_granted_this_streak = true
		if _combo_bonus > 0 and GameState.meta_hub_active and is_inside_tree():
			get_tree().call_group("meta_hub", "refresh_top_bar")
			coin_now = true
	if _combo_count >= COMBO_COIN_THRESHOLD:
		GameState.note_arena_daily_event("combo_5")
	_play_combo_feedback(at, t3)
	if coin_now and not _fly_combo_coin(at, _combo_bonus):
		get_tree().call_group("meta_hub", "show_coin_earn_pop", _combo_bonus)


## Combo zivi na polju (design_handoff_arena_v2 § Combo): „×N" na mjestu spajanja, talas ispod
## sjemenki, svjetlo sezone preko livade, od 4 naklon elemenata, Pip skok (na 5 veci).
func _play_combo_feedback(at: Vector2, t3: bool) -> void:
	var step := UiArenaV2.combo_step(_combo_count)
	if step.is_empty():
		return
	if meadow_bg != null:
		meadow_bg.set_combo_light(float(step["light"]))
	var pip: Array = UiArenaV2.COMBO_PIP[str(step["pip"])]
	_react_arena_pip(float(pip[0]), float(pip[1]))
	if at == Vector2.INF or playfield == null or not is_inside_tree():
		return
	_show_combo_mark(at, bool(step["gold"]), int(step["mark"]))
	if not t3:
		_play_combo_ripple(at, float(step["ring"]))
	if bool(step["bow"]) and meadow_bg != null:
		var bg_at := at + playfield.global_position - meadow_bg.global_position
		meadow_bg.play_bow(bg_at, float(step["ring"]))


## „×N" i prstenovi se prave pri pokretanju Arene (ne u frejmu prvog comboa), a slova svih
## combo velicina se iscrtaju jednom nevidljivo — prvi puls ne steka.
func _setup_combo_fx() -> void:
	if _combo_mark == null:
		_combo_mark = ArenaComboMark.new()
		_combo_mark.name = "ComboMark"
		_combo_mark.z_index = 60
		playfield.add_child(_combo_mark)
		_combo_mark.prewarm()
	if _combo_ripples.is_empty():
		var width := float(UiArenaV2.COMBO_RIPPLE["width"])
		for i in COMBO_RIPPLE_POOL:
			var ring := Panel.new()
			ring.name = "ComboRipple%d" % i
			ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ring.visible = false
			ring.add_theme_stylebox_override("panel", UiArena.ring_style(999.0, width, UiPalette.WARM_WHITE))
			playfield.add_child(ring)
			playfield.move_child(ring, 0)
			_combo_ripples.append(ring)


func _show_combo_mark(at: Vector2, gold: bool, font_size: int) -> void:
	var cfg := UiArenaV2.COMBO_MARK
	_setup_combo_fx()
	if _combo_mark_tween != null and _combo_mark_tween.is_valid():
		_combo_mark_tween.kill()
	_combo_mark.show_mark("×%d" % _combo_count, font_size, UiArenaV2.col(str(cfg["gold" if gold else "fill"])))
	var from_y := at.y + float(cfg["rise_from"]) - _combo_mark.size.y * 0.5
	var to_y := at.y + float(cfg["rise_to"]) - _combo_mark.size.y * 0.5
	_combo_mark.position = Vector2(at.x - _combo_mark.size.x * 0.5, from_y)
	_combo_mark.scale = Vector2.ZERO
	_combo_mark.modulate.a = 1.0
	_combo_mark.visible = true
	var pop := float(cfg["pop_in"])
	var hold := float(cfg["hold"])
	var fade := float(cfg["fade"])
	_combo_mark_tween = _combo_mark.create_tween().set_parallel(true)
	_combo_mark_tween.tween_property(_combo_mark, "scale", Vector2.ONE, pop).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	_combo_mark_tween.tween_property(_combo_mark, "position:y", to_y, pop + hold + fade).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	_combo_mark_tween.tween_property(_combo_mark, "modulate:a", 0.0, fade).set_delay(pop + hold)


func get_combo_mark() -> ArenaComboMark:
	return _combo_mark


## Prsten (10 px) od mjesta spajanja, r 90 → R, alpha 0,55 → 0, 0,5 s — crta se ispod sjemenki.
func _play_combo_ripple(at: Vector2, radius: float) -> void:
	var cfg := UiArenaV2.COMBO_RIPPLE
	_setup_combo_fx()
	var slot := _combo_ripple_next % _combo_ripples.size()
	var ring := _combo_ripples[slot]
	_combo_ripple_next += 1
	# Brz combo moze vratiti isti prsten dok mu stari tween jos traje — ugasi ga prvo.
	if slot < _combo_ripple_tweens.size() and _combo_ripple_tweens[slot] != null \
			and _combo_ripple_tweens[slot].is_valid():
		_combo_ripple_tweens[slot].kill()
	if meadow_bg != null:
		var ring_color := UiArenaV2.col(str(UiArenaV2.field(meadow_bg.get_season_id())["combo"]["ring"]))
		(ring.get_theme_stylebox("panel") as StyleBoxFlat).border_color = ring_color
	ring.size = Vector2(radius, radius) * 2.0
	ring.pivot_offset = ring.size * 0.5
	ring.position = at - ring.size * 0.5
	ring.scale = Vector2.ONE * (float(cfg["from_r"]) / radius)
	ring.modulate.a = float(cfg["alpha"])
	ring.visible = true
	var tw := ring.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "scale", Vector2.ONE, float(cfg["sec"]))
	tw.tween_property(ring, "modulate:a", 0.0, float(cfg["sec"]))
	tw.chain().tween_callback(ring.hide)
	while _combo_ripple_tweens.size() <= slot:
		_combo_ripple_tweens.append(null)
	_combo_ripple_tweens[slot] = tw


## Na combo 5 novcic 56 px leti od spajanja do coin chipa (0,5 s), pa postojeci „+N" pop.
## Vraca false ako nema huba / mjesta (pozivalac tad odmah zove pop).
func _fly_combo_coin(at: Vector2, amount: int) -> bool:
	if at == Vector2.INF or playfield == null or not is_inside_tree():
		return false
	var hub := get_tree().get_first_node_in_group("meta_hub")
	if hub == null:
		return false
	var chip := hub.get("coin_chip") as Control
	if chip == null or not is_instance_valid(chip):
		return false
	var coin := TextureRect.new()
	coin.name = "ComboCoin"
	coin.texture = UiAssets.get_chrome_icon("icon_coin")
	coin.custom_minimum_size = Vector2(COMBO_COIN_SIZE, COMBO_COIN_SIZE)
	coin.size = coin.custom_minimum_size
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin.top_level = true
	coin.z_index = 100
	add_child(coin)
	_fx_nodes.append(coin)
	coin.global_position = playfield.global_position + at - coin.size * 0.5
	var to := chip.global_position + chip.size * 0.5 - coin.size * 0.5
	var tw := coin.create_tween()
	tw.tween_property(coin, "global_position", to, COMBO_COIN_SEC).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_IN
	)
	tw.tween_callback(_on_combo_coin_arrived.bind(coin, chip, amount))
	return true


func _on_combo_coin_arrived(coin: Node, chip: Control, amount: int) -> void:
	_free_fx(coin)
	if not is_inside_tree():
		return
	get_tree().call_group("meta_hub", "show_coin_earn_pop", amount)
	if chip == null or not is_instance_valid(chip):
		return
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.top_level = true
	ring.z_index = 100
	ring.add_theme_stylebox_override("panel", UiArena.ring_style(999.0, 4.0, UiArena.COIN_GOLD))
	add_child(ring)
	_fx_nodes.append(ring)
	ring.size = chip.size + Vector2.ONE * COMBO_CHIP_RING_GROW * 2.0
	ring.global_position = chip.global_position - Vector2.ONE * COMBO_CHIP_RING_GROW
	var tw := ring.create_tween()
	tw.tween_property(ring, "modulate:a", 0.0, COMBO_CHIP_RING_SEC)
	tw.tween_callback(_free_fx.bind(ring))


func get_combo_count() -> int:
	return _combo_count


## Smoke/hub: sesija traje dok ima sjemenki na polju — dotle je swipe zakljucan.
func is_session_open() -> bool:
	return _session_open


func _clear_combo() -> void:
	var had_combo := _combo_count >= COMBO_HUD_MIN
	_combo_count = 0
	_combo_window_left = 0.0
	_combo_coin_granted_this_streak = false
	_combo_bonus = 0
	if had_combo and meadow_bg != null:
		meadow_bg.clear_combo_light()


func _on_chip_drag_started(chip: ArenaSeedChip) -> void:
	_set_pair_pulses(chip)
	_update_merge_hint()


## Merge Hint (kupljen jednom, Shop v2): dok igrač drži sjemenku, najbliža ista sjemenka
## dobije MergeHintMark; histereza 24 px u UiShopV2.merge_hint_target.
func _update_merge_hint() -> void:
	var held := _get_dragging_chip()
	if held == null or not GameState.merge_hint_owned:
		if _hint_mark != null:
			_hint_mark.set_target(null)
		return
	if _hint_mark == null:
		_hint_mark = MergeHintMark.new()
		_hint_mark.name = "MergeHintMark"
		_hint_mark.z_index = 5
		playfield.add_child(_hint_mark)
	_hint_mark.set_target(UiShopV2.merge_hint_target(held, _chips, _hint_mark.get_target()))


func get_merge_hint_target() -> Node:
	return _hint_mark.get_target() if _hint_mark != null and _hint_mark.is_shown() else null


func is_merge_hint_visible() -> bool:
	return _hint_mark != null and _hint_mark.visible


## Kraj sesije / stranica se gasi (_process staje): zagrade ne smiju ostati na polju.
func _clear_merge_hint() -> void:
	if _hint_mark != null:
		_hint_mark.clear_now()


func _set_pair_pulses(held: ArenaSeedChip) -> void:
	if not is_instance_valid(held):
		_clear_pair_pulses()
		return
	for other in _chips:
		if not is_instance_valid(other) or other == held:
			continue
		other.pulse_highlight = other.type_id == held.type_id and other.tier == held.tier


func _clear_pair_pulses() -> void:
	for chip in _chips:
		if is_instance_valid(chip):
			chip.pulse_highlight = false


func _process(delta: float) -> void:
	_apply_magnet_pull()
	if _hint_mark != null or GameState.merge_hint_owned:
		_update_merge_hint()
	if _pest:
		_pest.tick(delta)
	if _combo_window_left > 0.0:
		_combo_window_left -= delta
		if _combo_window_left <= 0.0:
			_clear_combo()
	_sync_hub_nav_lock()


func _apply_magnet_pull() -> void:
	var active := _get_dragging_chip()
	if active == null:
		_clear_magnet_lock()
		return
	if _magnet_lock_drag != active:
		_clear_magnet_lock()
		_magnet_lock_drag = active
	var partner := _get_magnet_lock_partner(active)
	_mark_magnet_partner(partner)
	if partner == null:
		return
	var dist := active.get_center().distance_to(partner.get_center())
	if dist >= GameState.ARENA_MAGNET_RADIUS or dist < ArenaSeedChip.CHIP_RADIUS * 0.35:
		return
	var pull_strength := (GameState.ARENA_MAGNET_RADIUS - dist) / GameState.ARENA_MAGNET_RADIUS
	var dir := (active.get_center() - partner.get_center()).normalized()
	var next_center := partner.get_center() + dir * pull_strength * 6.5 * ArenaSeedChip.DISPLAY_SCALE
	if _get_bag_keepout_rect().has_point(next_center):
		return
	partner.set_center(next_center)
	_sync_chip_pos(partner)


func _clear_magnet_lock() -> void:
	_mark_magnet_partner(null)
	_magnet_lock_drag = null
	_magnet_lock_partner = null


func _mark_magnet_partner(partner: ArenaSeedChip) -> void:
	for chip in _chips:
		if is_instance_valid(chip):
			chip.magnet_partner = chip == partner


func _get_magnet_lock_partner(active: ArenaSeedChip) -> ArenaSeedChip:
	if _is_valid_magnet_partner(active, _magnet_lock_partner):
		return _magnet_lock_partner
	var found := _find_closest_magnet_partner(active)
	if found != null:
		_magnet_lock_partner = found
	return found


func _is_valid_magnet_partner(active: ArenaSeedChip, partner: ArenaSeedChip) -> bool:
	if partner == null or not is_instance_valid(partner):
		return false
	if partner == active or not _chips.has(partner):
		return false
	if partner.is_dragging() or not _can_merge_chips(active, partner):
		return false
	if _get_bag_keepout_rect().has_point(partner.get_center()):
		return false
	if _get_bag_keepout_rect().has_point(active.get_center()):
		return false
	return active.get_center().distance_to(partner.get_center()) <= GameState.ARENA_MAGNET_RADIUS


func _find_closest_magnet_partner(active: ArenaSeedChip) -> ArenaSeedChip:
	var best: ArenaSeedChip = null
	var best_dist := GameState.ARENA_MAGNET_RADIUS
	for other in _chips:
		if other == active or other.is_dragging():
			continue
		if not _can_merge_chips(active, other):
			continue
		if _get_bag_keepout_rect().has_point(other.get_center()):
			continue
		var dist := active.get_center().distance_to(other.get_center())
		if dist < best_dist:
			best_dist = dist
			best = other
	return best


func _get_dragging_chip() -> ArenaSeedChip:
	for chip in _chips:
		if chip.is_dragging():
			return chip
	return null


## Bez trake s porukama odbijen tap javlja sama vreca (punch), ne tekst.
func _on_bag_clicked() -> void:
	var slots := _arena_slots_available()
	if slots <= 0:
		_punch_seed_bag()
		_refresh_bag()
		return
	var bag_count := GameState.sum_seed_bag_only()
	if bag_count <= 0:
		_punch_seed_bag()
		_refresh_bag()
		return
	_start_session_if_needed()
	var poured := _pour_available_seeds()
	if poured <= 0:
		if _bag_has_pourable_set():
			_punch_seed_bag()
		else:
			_show_need_more_seeds_overlay()
		_refresh_bag()
		return
	if GameState.should_show_arena_pest_tutorial():
		_cue.show_message(CUE_PEST_AWAKE)
		GameState.mark_arena_pest_tutorial_shown()


## Prvi pour na prazno polje otvara sesiju: hub se zakljuca, lockovi i livada se resetuju.
func _start_session_if_needed() -> void:
	if _session_open or not _chips.is_empty():
		return
	_session_open = true
	GameState.clear_arena_pour_locks()
	_reset_session_feel()
	if _pest:
		_pest.reset_to_nest()


## Sesija se ne prekida rucno — gasi se sama kad polje ostane prazno (sve spojeno ili
## pojedeno). Tek tada `_is_session_active()` pusti swipe po hubu.
func _end_session_if_settled() -> void:
	if not _session_open or _auto_pouring:
		return
	if not _chips.is_empty() or not _vacuum_flies.is_empty():
		return
	_session_open = false
	GameState.commit_arena_chips_to_bag(_chip_data)
	_clear_combo()
	_clear_pair_pulses()
	_clear_merge_hint()
	_update_tutorial_cue()
	_refresh_bag()
	_sync_hub_nav_lock()


func _bag_has_pourable_set() -> bool:
	var bag: Dictionary = GameState.seed_bag
	for type_id in bag:
		if int(bag[type_id]) >= 4 and not GameState.is_arena_pour_locked(str(type_id)):
			return true
	return false


func _show_need_more_seeds_overlay() -> void:
	_rebuild_need_more_list()
	need_more_overlay.open(true)


func _hide_need_more_overlay() -> void:
	if need_more_overlay:
		need_more_overlay.close(false)
	if need_more_tiles == null:
		return
	for child in need_more_tiles.get_children():
		need_more_tiles.remove_child(child)
		child.queue_free()


func _build_need_more_overlay() -> void:
	need_more_overlay = PopupModal.new()
	need_more_overlay.name = "NeedMoreSeedsOverlay"
	need_more_overlay.z_index = 30
	need_more_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(need_more_overlay)
	need_more_overlay.setup(UiPopups.S_NEED_TITLE, "decision")
	var line := Label.new()
	line.name = "ModalLine"
	line.text = UiPopups.S_NEED_LINE
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.add_theme_font_override("font", UiPopups.font(900, 44))
	line.add_theme_font_size_override("font_size", 44)
	line.add_theme_color_override("font_color", UiPopups.OUTLINE)
	need_more_overlay.content.add_child(line)
	need_more_tiles = HFlowContainer.new()
	need_more_tiles.name = "NeedSeedTiles"
	need_more_tiles.alignment = FlowContainer.ALIGNMENT_CENTER
	need_more_tiles.add_theme_constant_override("h_separation", 24)
	need_more_tiles.add_theme_constant_override("v_separation", 24)
	need_more_tiles.mouse_filter = Control.MOUSE_FILTER_IGNORE
	need_more_overlay.content.add_child(need_more_tiles)
	back_to_camp_button = PopupButton.new()
	back_to_camp_button.name = "BackToCampButton"
	back_to_camp_button.configure("primary", UiPopups.S_BACK_TO_CAMP, false, UiAssets.get_chrome_icon("tab_camp"))
	back_to_camp_button.clicked.connect(_on_back_to_camp_pressed)
	need_more_overlay.content.add_child(back_to_camp_button)


func _rebuild_need_more_list() -> void:
	for child in need_more_tiles.get_children():
		need_more_tiles.remove_child(child)
		child.queue_free()
	for entry in GameState.get_seed_bag_entries():
		var tile := NeedSeedTile.new().setup(str(entry.get("type_id", "")), int(entry.get("count", 0)))
		need_more_tiles.add_child(tile)


func get_need_title() -> String:
	return need_more_overlay.title if need_more_overlay else ""


func get_need_tiles() -> Array:
	return need_more_tiles.get_children() if need_more_tiles else []


## Overlay se zatvara samo preko "Back to Camp" (ne tap bilo gdje).
func _on_back_to_camp_pressed() -> void:
	_end_session_to_camp()


func _arena_slots_available() -> int:
	return maxi(0, GameState.ARENA_MAX_CHIPS - _chips.size())


func _field_type_counts() -> Dictionary:
	var counts: Dictionary = {}
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		var type_id := chip.type_id
		counts[type_id] = int(counts.get(type_id, 0)) + 1
	return counts


func _pour_available_seeds() -> int:
	var slots := _arena_slots_available()
	if slots <= 0:
		return 0
	var bag_count := GameState.sum_seed_bag_only()
	if bag_count <= 0:
		return 0
	var to_pour := mini(slots, bag_count)
	var pulled: Array = GameState.pull_seeds_to_arena(to_pour, _field_type_counts())
	if pulled.is_empty():
		return 0
	var spawned := _spawn_poured_chips(pulled)
	_animate_pour(spawned)
	_repel_chips_from_bag()
	if _pest:
		_pest.on_seeds_poured(not _chips.is_empty())
	_resolve_t3_starved_types()
	_resolve_stranded_t2()
	_update_tutorial_cue()
	_refresh_bag()
	return pulled.size()


func _try_auto_refill() -> void:
	if _auto_pouring:
		return
	if _chips.size() <= 0 or _chips.size() > ARENA_AUTO_REFILL_AT:
		return
	if GameState.sum_seed_bag_only() <= 0:
		return
	if _arena_slots_available() <= 0:
		return
	_auto_pouring = true
	var poured := _pour_available_seeds()
	_auto_pouring = false
	if poured <= 0:
		return
	if (
		_chips.size() > 0
		and _chips.size() <= ARENA_AUTO_REFILL_AT
		and GameState.sum_seed_bag_only() > 0
		and _arena_slots_available() > 0
	):
		call_deferred("_try_auto_refill")


func _get_bag_keepout_rect() -> Rect2:
	if _seed_bag == null:
		return Rect2()
	var anchor := _seed_bag.get_base_position() + Vector2(UiArena.BAG_HIT.x * 0.5, UiArena.BAG_HIT.y)
	return Rect2(anchor + UiArena.BAG_KEEPOUT.position, UiArena.BAG_KEEPOUT.size)


func _get_pip_keepout_rect() -> Rect2:
	if arena_pip == null:
		return Rect2()
	return Rect2(arena_pip.position - UiArena.PIP_KEEPOUT_GROW, arena_pip.size + UiArena.PIP_KEEPOUT_GROW * 2.0)


## Zone kroz koje sjemenka ne prolazi ni kad se vuce (vreca, Pip).
func _physical_keepouts() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for zone in [_get_bag_keepout_rect(), _get_pip_keepout_rect()]:
		if zone.size.x > 1.0:
			out.append(zone)
	return out


## Spawn izbjegava gnijezdo (overlay, ne prepreka) — combo keepout je otpao s pilulom.
func _spawn_keepouts() -> Array[Rect2]:
	var out := _physical_keepouts()
	var field := playfield.size
	var above := 1000.0
	out.append(Rect2(
		field.x * 0.5 - UiArena.NEST_KEEPOUT_HALF_W, -above,
		UiArena.NEST_KEEPOUT_HALF_W * 2.0, above + UiArena.NEST_KEEPOUT_BOTTOM
	))
	return out


func _pest_bounds() -> Rect2:
	return Rect2(Vector2.ZERO, playfield.size)


## Najbliza ivica zone koja ostaje u polju — manje "skakanja" nego radijalni guranje.
func _push_out_of(zone: Rect2, center: Vector2, bounds: Rect2) -> Vector2:
	var options: Array[Vector2] = [
		Vector2(zone.position.x - 1.0, center.y),
		Vector2(zone.end.x + 1.0, center.y),
		Vector2(center.x, zone.position.y - 1.0),
		Vector2(center.x, zone.end.y + 1.0),
	]
	var best := center
	var best_d := INF
	for p in options:
		if not bounds.grow(0.5).has_point(p):
			continue
		var d := center.distance_squared_to(p)
		if d < best_d:
			best_d = d
			best = p
	return best


func _repel_chips_from_bag() -> void:
	var zones := _physical_keepouts()
	if zones.is_empty():
		return
	var bounds := _playfield_bounds()
	for chip in _chips:
		if not is_instance_valid(chip) or chip.is_dragging():
			continue
		var center := chip.get_center()
		var moved := false
		for zone in zones:
			if zone.has_point(center):
				center = _push_out_of(zone, center, bounds)
				moved = true
		if moved:
			chip.set_center(center)
			_sync_chip_pos(chip)


## Rešetkasti spawn (UiArena.spawn_slots) — slucajni puca iznad ~22 sjemenke na polju.
func _spawn_poured_chips(entries: Array) -> Array[ArenaSeedChip]:
	_clear_vfx_done_this_pour = false
	var existing: Array[Vector2] = []
	for chip in _chips:
		existing.append(chip.get_center())
	var bounds := _playfield_bounds()
	var slots := UiArena.spawn_slots(
		_chips.size() + entries.size(), bounds, _spawn_keepouts(), existing, CHIP_MIN_DIST, _rng
	)
	var spawned: Array[ArenaSeedChip] = []
	for entry in entries:
		var chip_id := int(entry.get("chip_id", 0))
		var type_id := str(entry.get("type_id", ""))
		var tier := int(entry.get("tier", 1))
		var pos: Vector2 = slots.pop_back() if not slots.is_empty() else _random_chip_position(existing, bounds)
		existing.append(pos)
		var chip := ArenaSeedChip.new()
		chip.setup(chip_id, type_id, pos, tier)
		chip.drag_started.connect(_on_chip_drag_started)
		chip.drag_released.connect(_on_chip_released)
		playfield.add_child(chip)
		_chips.append(chip)
		spawned.append(chip)
		_chip_data[chip_id] = {"chip_id": chip_id, "type_id": type_id, "tier": tier, "pos": pos}
	var moved_any := false
	for chip in spawned:
		moved_any = _resolve_overlaps_any(chip) or moved_any
	# Pushes can shove older chips into each other — settle the whole field (najviše 3
	# prolaza; prolaz u kojem se ništa ne pomjeri ne mijenja ništa, pa se tu staje).
	var sweeps := 0
	while moved_any and sweeps < 3:
		moved_any = false
		for chip in _chips:
			moved_any = _resolve_overlaps_any(chip) or moved_any
		sweeps += 1
	return spawned


## Pour: vreca se nagne, sjemenke izlijecu iz vrata s razmakom 0,04 s.
func _animate_pour(spawned: Array[ArenaSeedChip]) -> void:
	if _seed_bag == null:
		return
	_seed_bag.play_pour()
	var mouth := _bag_mouth_local()
	for i in spawned.size():
		if is_instance_valid(spawned[i]):
			spawned[i].play_pour_in(mouth, float(i) * POUR_STAGGER_SEC)


## Granice centara sjemenki; vreca i Pip su keepout zone unutar njih.
func _playfield_bounds() -> Rect2:
	var field := playfield.size
	if field.x < 10.0:
		field = Vector2(1000.0, 900.0)
	return Rect2(FIELD_MARGIN, FIELD_MARGIN, field.x - FIELD_MARGIN * 2.0, field.y - FIELD_MARGIN * 2.0)


func _random_chip_position(existing: Array[Vector2], bounds: Rect2) -> Vector2:
	# On a crowded field, fall back to the roomiest candidate instead of a
	# blind random spot — big chips otherwise land stacked on each other.
	var best := Vector2.ZERO
	var best_gap := -1.0
	for _attempt in 48:
		var p := Vector2(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		)
		var gap := INF
		for other in existing:
			gap = minf(gap, p.distance_to(other))
		if gap >= CHIP_MIN_DIST:
			return p
		if gap > best_gap:
			best_gap = gap
			best = p
	return best


func _sync_chip_pos(chip: ArenaSeedChip) -> void:
	var bounds := _playfield_bounds()
	var center := chip.get_center()
	center.x = clampf(center.x, bounds.position.x, bounds.end.x)
	center.y = clampf(center.y, bounds.position.y, bounds.end.y)
	for zone in _physical_keepouts():
		if zone.has_point(center):
			center = _push_out_of(zone, center, bounds)
	chip.set_center(center)
	if _chip_data.has(chip.chip_id):
		_chip_data[chip.chip_id]["pos"] = center


func _can_merge_chips(a: ArenaSeedChip, b: ArenaSeedChip) -> bool:
	return a.type_id == b.type_id and a.tier == b.tier


func _resolve_overlaps(moved: ArenaSeedChip) -> void:
	_resolve_overlaps_any(moved)
	_repel_chips_from_bag()


## Razmakne `moved` od ostalih; vraća true ako je išta pomjereno (spawn zna kad da stane).
## Bez guranja iz vreće — to radi pozivalac jednom (spawn: _pour_available_seeds).
func _resolve_overlaps_any(moved: ArenaSeedChip) -> bool:
	if not is_instance_valid(moved):
		return false
	var moved_any := false
	var sep_sq := (CHIP_SEPARATION - 0.5) * (CHIP_SEPARATION - 0.5)
	for _pass in 14:
		var moved_center := moved.get_center()
		var fixed_any := false
		for other in _chips:
			if other == moved or not is_instance_valid(other):
				continue
			var other_center := other.get_center()
			# Kvadrat udaljenosti prvo — većina parova je daleko, bez korijena.
			if moved_center.distance_squared_to(other_center) >= sep_sq:
				continue
			var dist := moved_center.distance_to(other_center)
			fixed_any = true
			var overlap := CHIP_SEPARATION - maxf(dist, 0.001)
			var dir: Vector2
			if dist < 6.0:
				dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			else:
				dir = (moved_center - other_center).normalized()
			var mismatch := not _can_merge_chips(moved, other)
			# Soft repulsion — blaže za različit tip/tier.
			var repulse := 0.32 if mismatch else 0.44
			var push := overlap * repulse
			moved.set_center(moved_center + dir * push)
			other.set_center(other_center - dir * push * 0.85)
			_sync_chip_pos(moved)
			_sync_chip_pos(other)
			moved_center = moved.get_center()
		if not fixed_any:
			break
		moved_any = true
	return moved_any


func _on_chip_released(chip: ArenaSeedChip) -> void:
	_clear_magnet_lock()
	_clear_pair_pulses()
	_sync_chip_pos(chip)
	var partner := _find_snap_partner(chip)
	if partner != null:
		var result := GameState.try_merge_arena_chips(chip.chip_id, partner.chip_id, _chip_data)
		if bool(result.get("ok", false)):
			_remove_chip(partner)
			var new_tier := int(result.get("new_tier", 2))
			var merged_center := (chip.get_center() + partner.get_center()) * 0.5
			chip.set_center(merged_center)
			chip.set_tier(new_tier)
			_chip_data[chip.chip_id] = {
				"chip_id": chip.chip_id,
				"type_id": chip.type_id,
				"tier": new_tier,
				"pos": merged_center,
			}
			register_arena_combo_merge(merged_center, new_tier >= GameState.MAX_MERGE_TIER)
			if new_tier == 2:
				GameState.note_arena_daily_event("merge_t2")
			elif new_tier >= GameState.MAX_MERGE_TIER:
				GameState.note_arena_daily_event("make_t3")
			if new_tier >= GameState.MAX_MERGE_TIER:
				_add_session_t3()
				if _pest:
					_pest.on_t3_created()
				GameState.stash_garden_crystal(chip.type_id)
				_play_t3_moment(chip.type_id, merged_center)
				_remove_chip(chip)
				_resolve_t3_starved_types()
				_resolve_stranded_t2()
				_update_tutorial_cue()
				_refresh_bag()
				_try_auto_refill()
				_resolve_t3_starved_types()
				_maybe_play_clear_vfx()
				call_deferred("_end_session_if_settled")
				return
			else:
				chip.play_merge_pop()
			_resolve_overlaps(chip)
			_resolve_t3_starved_types()
			_resolve_stranded_t2()
			_update_tutorial_cue()
			_refresh_bag()
			_try_auto_refill()
			_resolve_t3_starved_types()
			_maybe_play_clear_vfx()
			call_deferred("_end_session_if_settled")
			return
	elif _has_near_miss(chip):
		chip.play_wobble()
	_resolve_overlaps(chip)
	_repel_chips_from_bag()
	_resolve_t3_starved_types()
	_resolve_stranded_t2()
	_refresh_bag()
	call_deferred("_end_session_if_settled")


## Pusten blizu sjemenke s kojom ne moze (drugi tip ili tier) — wobble kao feedback.
func _has_near_miss(chip: ArenaSeedChip) -> bool:
	for other in _chips:
		if other == chip or not is_instance_valid(other):
			continue
		if chip.get_center().distance_to(other.get_center()) < GameState.ARENA_SNAP_DISTANCE:
			return true
	return false


## T3 trenutak (0,74 s): burst prsten, pa kristal odleti u gornji desni ugao polja
## (gdje je stajao stash brojac) i nestane. Tweenovi su vezani za ring/ghost.
func _play_t3_moment(type_id: String, at_local: Vector2) -> void:
	var origin := at_local + playfield.global_position - global_position
	var ring := Panel.new()
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.z_index = 70
	ring.add_theme_stylebox_override("panel", UiArena.ring_style(999.0, T3_RING_WIDTH, UiArena.FLASH))
	ring.size = Vector2(T3_RING_SIZE, T3_RING_SIZE)
	ring.pivot_offset = ring.size * 0.5
	ring.position = origin - ring.size * 0.5
	ring.scale = Vector2.ONE * T3_RING_START
	ring.modulate.a = 0.75
	add_child(ring)
	_fx_nodes.append(ring)
	var ring_tw := ring.create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	ring_tw.tween_property(ring, "scale", Vector2.ONE * T3_RING_END, T3_RING_SEC)
	ring_tw.tween_property(ring, "modulate:a", 0.0, T3_RING_SEC)
	ring_tw.chain().tween_callback(_free_fx.bind(ring))
	var ghost := ArenaVacuumFly.new()
	add_child(ghost)
	ghost.setup(type_id, GameState.MAX_MERGE_TIER, origin)
	ghost.z_index = 71
	_fx_nodes.append(ghost)
	var target := playfield.position + Vector2(
		playfield.size.x - UiArena.CRYSTAL_EXIT_INSET.x, UiArena.CRYSTAL_EXIT_INSET.y
	)
	var fly := ghost.create_tween()
	fly.tween_interval(T3_RING_SEC)
	fly.tween_property(ghost, "position", target - ghost.size * 0.5, T3_FLY_SEC).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	fly.parallel().tween_property(ghost, "scale", Vector2.ONE * T3_FLY_END_SCALE, T3_FLY_SEC).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	fly.parallel().tween_property(ghost, "modulate:a", 0.0, T3_FLY_SEC * 0.5).set_delay(T3_FLY_SEC * 0.5)
	fly.tween_callback(_on_t3_crystal_arrived.bind(ghost))


func _on_t3_crystal_arrived(ghost: Node) -> void:
	_free_fx(ghost)


func _free_fx(node: Node) -> void:
	_fx_nodes.erase(node)
	if is_instance_valid(node):
		node.queue_free()


func _find_snap_partner(chip: ArenaSeedChip) -> ArenaSeedChip:
	var best: ArenaSeedChip = null
	var best_dist := GameState.ARENA_SNAP_DISTANCE
	for other in _chips:
		if other == chip:
			continue
		if other.type_id != chip.type_id or other.tier != chip.tier:
			continue
		var dist := chip.get_center().distance_to(other.get_center())
		if dist < best_dist:
			best_dist = dist
			best = other
	return best


func _remove_chip(chip: ArenaSeedChip) -> void:
	_chips.erase(chip)
	_chip_data.erase(chip.chip_id)
	chip.queue_free()
	if _pest:
		_pest.on_field_chip_count_changed(_chips.size())


func _bag_mouth_local() -> Vector2:
	if playfield == null:
		return Vector2.ZERO
	if _seed_bag == null:
		return Vector2(playfield.size.x * 0.5, playfield.size.y - 24.0)
	return _seed_bag.get_mouth_position()


func _vacuum_fly_chip(chip: ArenaSeedChip) -> void:
	if not is_instance_valid(chip) or playfield == null:
		return
	var seed_type := chip.type_id
	var seed_tier := chip.tier
	var center := chip.get_center()
	_remove_chip(chip)
	var ghost := ArenaVacuumFly.new()
	playfield.add_child(ghost)
	ghost.setup(seed_type, seed_tier, center)
	_vacuum_flies.append(ghost)
	var delay := float(_vacuum_fly_stagger) * VACUUM_FLY_STAGGER_SEC
	_vacuum_fly_stagger += 1
	var end_pos := _bag_mouth_local() - ghost.size * 0.5
	var tw := create_tween()
	_vacuum_fly_tweens.append(tw)
	tw.tween_interval(delay)
	tw.tween_property(ghost, "position", end_pos, VACUUM_FLY_SEC).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(
		ghost, "scale", Vector2(VACUUM_FLY_END_SCALE, VACUUM_FLY_END_SCALE), VACUUM_FLY_SEC
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(_on_vacuum_fly_arrived.bind(ghost, tw))


func _on_vacuum_fly_arrived(ghost: Control, tw: Tween) -> void:
	_vacuum_fly_tweens.erase(tw)
	_vacuum_flies.erase(ghost)
	if is_instance_valid(ghost):
		ghost.queue_free()
	_punch_seed_bag()
	call_deferred("_end_session_if_settled")


func _punch_seed_bag() -> void:
	if _seed_bag == null:
		return
	if _bag_punch_tween != null:
		_bag_punch_tween.kill()
		_bag_punch_tween = null
	_seed_bag.pivot_offset = _seed_bag.size * 0.5
	_seed_bag.scale = Vector2.ONE
	_bag_punch_tween = create_tween()
	_bag_punch_tween.tween_property(
		_seed_bag, "scale", Vector2(VACUUM_BAG_PUNCH_SCALE, VACUUM_BAG_PUNCH_SCALE), VACUUM_BAG_PUNCH_UP_SEC
	)
	_bag_punch_tween.tween_property(_seed_bag, "scale", Vector2.ONE, VACUUM_BAG_PUNCH_DOWN_SEC)


func _kill_vacuum_flies() -> void:
	for tw in _vacuum_fly_tweens:
		if tw != null:
			tw.kill()
	_vacuum_fly_tweens.clear()
	for ghost in _vacuum_flies:
		if is_instance_valid(ghost):
			ghost.queue_free()
	_vacuum_flies.clear()
	_vacuum_fly_stagger = 0
	if _bag_punch_tween != null:
		_bag_punch_tween.kill()
		_bag_punch_tween = null
	if _seed_bag != null:
		_seed_bag.scale = Vector2.ONE
	for node in _fx_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_fx_nodes.clear()


func _type_t1_eq(type_id: String) -> int:
	var field_t1 := 0
	var field_t2 := 0
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		if chip.type_id != type_id:
			continue
		if chip.tier == 1:
			field_t1 += 1
		elif chip.tier == 2:
			field_t2 += 1
	return field_t1 + field_t2 * 2 + _pourable_bag_t1(type_id)


func _pourable_bag_t1(type_id: String) -> int:
	if GameState.is_arena_pour_locked(type_id):
		return 0
	var bag_n := int(GameState.seed_bag.get(type_id, 0))
	if bag_n < 4:
		return 0
	return bag_n


func _resolve_t3_starved_types() -> void:
	_vacuum_fly_stagger = 0
	var type_ids: Dictionary = {}
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		if chip.tier != 1 and chip.tier != 2:
			continue
		type_ids[chip.type_id] = true
	var vacuumed_any := false
	var leftover_became_pourable := false
	for type_id in type_ids:
		var id := str(type_id)
		if _type_t1_eq(id) >= 4:
			continue
		var idle: Array[ArenaSeedChip] = []
		var needed := 0
		for chip in _chips:
			if not is_instance_valid(chip) or not _chips.has(chip):
				continue
			if chip.type_id != id:
				continue
			if chip.is_dragging():
				continue
			if chip.tier == 1:
				idle.append(chip)
				needed += 1
			elif chip.tier == 2:
				idle.append(chip)
				needed += 2
		if idle.is_empty() or needed <= 0:
			continue
		var added := GameState.add_seeds_to_bag_unbounded(id, needed)
		if added < needed:
			continue
		for chip in idle:
			if is_instance_valid(chip) and _chips.has(chip):
				_vacuum_fly_chip(chip)
		if int(GameState.seed_bag.get(id, 0)) >= 4:
			GameState.unlock_arena_pour_type(id)
			leftover_became_pourable = true
		else:
			GameState.lock_arena_pour_type(id)
		vacuumed_any = true
	if vacuumed_any:
		GameState.save_player_save()
		# S32 — empty field after leftover that now makes a T3 set; do not dump other bag types.
		if leftover_became_pourable and _chips.is_empty() and not _auto_pouring:
			_auto_pouring = true
			_pour_available_seeds()
			_auto_pouring = false


func _t2_has_pair_chance(chip: ArenaSeedChip) -> bool:
	var type_id := chip.type_id
	var other_t2 := 0
	var field_t1 := 0
	for other in _chips:
		if not is_instance_valid(other) or other == chip:
			continue
		if other.type_id != type_id:
			continue
		if other.tier == 2:
			other_t2 += 1
		elif other.tier == 1:
			field_t1 += 1
	if other_t2 > 0:
		return true
	if int(GameState.seed_bag.get(type_id, 0)) > 0:
		return true
	return field_t1 >= 2


func _resolve_stranded_t2() -> void:
	_vacuum_fly_stagger = 0
	var snapshot: Array[ArenaSeedChip] = []
	for chip in _chips:
		if is_instance_valid(chip) and chip.tier == 2:
			snapshot.append(chip)
	var recycled_any := false
	for chip in snapshot:
		if not is_instance_valid(chip) or not _chips.has(chip):
			continue
		if chip.tier != 2:
			continue
		if _t2_has_pair_chance(chip):
			continue
		if GameState.seed_bag_remaining_capacity() < 2:
			continue
		var added := GameState.add_seeds_to_bag(chip.type_id, 2)
		if added < 2:
			continue
		_vacuum_fly_chip(chip)
		recycled_any = true
	if recycled_any:
		GameState.save_player_save()
		_try_auto_refill()


func _refresh_bag() -> void:
	if _seed_bag == null:
		return
	var bag_count := GameState.sum_seed_bag_only()
	var slots := _arena_slots_available()
	var can_pour := bag_count > 0 and slots > 0
	_seed_bag.set_state(bag_count, can_pour, GameState.get_bag_preview_types())
	_layout_bag()
	_repel_chips_from_bag()


## Jedini rucni izlaz koji je ostao — "Back to Camp" iz "You need more seeds" overlaya.
func _end_session_to_camp() -> void:
	_session_open = false
	_hide_need_more_overlay()
	_reset_session_feel()
	_clear_combo()
	_clear_pair_pulses()
	_clear_merge_hint()
	GameState.commit_arena_chips_to_bag(_chip_data)
	_clear_field_chips()
	GameState.clear_arena_pour_locks()
	if _pest:
		_pest.reset_to_nest()
	_set_hub_nav_locked(false)
	GameState.go_to_camp_hub()


func _clear_field_chips() -> void:
	_kill_vacuum_flies()
	for chip in _chips:
		if is_instance_valid(chip):
			chip.queue_free()
	_chips.clear()
	_chip_data.clear()


## Oblacic iznad vrece stoji samo dok tutorial traje i polje je prazno.
func _update_tutorial_cue() -> void:
	if _cue == null:
		return
	_cue.set_tutorial_visible(GameState.should_prompt_merge_tutorial() and _chips.is_empty())
