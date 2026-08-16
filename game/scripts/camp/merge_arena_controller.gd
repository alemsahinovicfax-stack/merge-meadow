extends Control

const ArenaSeedChip := preload("res://scripts/camp/arena_seed_chip.gd")
const ArenaSeedBag := preload("res://scripts/camp/arena_seed_bag.gd")
const ArenaPest := preload("res://scripts/camp/arena_pest.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

const CHIP_MIN_DIST := 102.0
const CHIP_SEPARATION := 102.0
const BAG_BOTTOM_PAD := 14.0
const BAG_LIFT := 100.0
const BAG_KEEPOUT_SIDE := 56.0
const BAG_KEEPOUT_TOP := 140.0
const BAG_KEEPOUT_BOTTOM := 36.0

@onready var playfield: Control = $RootVBox/Playfield
@onready var info_label: Label = $RootVBox/InfoLabel
@onready var done_button: UiClickButton = $FooterBar/DoneButton
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton

var _chips: Array[ArenaSeedChip] = []
var _chip_data: Dictionary = {}
var _seed_bag: ArenaSeedBag
var _magnet_lock_drag: ArenaSeedChip = null
var _magnet_lock_partner: ArenaSeedChip = null
var _bloom_panel: PanelContainer
var _bloom_target: ArenaSeedChip = null
var _pest: ArenaPest
var _swipe_locked: bool = false
var _page_active: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	done_button.clicked.connect(_on_done_pressed)
	back_button.clicked.connect(_on_back_pressed)
	SAFE_AREA.apply_top_margin($RootVBox/TopBar, 8.0)
	playfield.resized.connect(_layout_bag)
	call_deferred("_deferred_boot")


func _exit_tree() -> void:
	_set_hub_nav_locked(false)


func _deferred_boot() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	GameState.ensure_dev_unlocked_seeds(10)
	GameState.flush_bloom_inbox_to_album()
	var legacy := $RootVBox.get_node_or_null("InboxPanel")
	if legacy:
		legacy.visible = false
	_setup_bag()
	_setup_bloom_panel()
	_setup_pest()
	_apply_merge_hint_if_ready()
	_apply_pest_tutorial_if_ready()
	_update_hint()
	_refresh_bag()


func _apply_merge_hint_if_ready() -> void:
	if not GameState.merge_hint_booster_active:
		return
	info_label.text = GameState.get_merge_hint_message(_chip_data)
	GameState.consume_merge_hint_booster()


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
	var bag_size := _seed_bag.size
	if bag_size.x < 1.0:
		bag_size = ArenaSeedBag.BAG_SIZE
	var x := (field.x - bag_size.x) * 0.5
	var y := field.y - bag_size.y - BAG_BOTTOM_PAD - BAG_LIFT
	_seed_bag.set_layout_position(Vector2(x, y))


func _apply_pest_tutorial_if_ready() -> void:
	if not GameState.should_show_arena_pest_tutorial():
		return
	info_label.text = "Pour seeds — watch the muncher! Merge to T3 to freeze it."


func _setup_pest() -> void:
	if _pest != null:
		return
	_pest = ArenaPest.new()
	_pest.name = "MuncherPest"
	playfield.add_child(_pest)
	_pest.setup(
		_get_edible_chips_for_pest,
		_get_bag_keepout_rect,
		_playfield_bounds,
		_pest_eat_chip
	)
	call_deferred("_layout_pest_nest")


func _layout_pest_nest() -> void:
	if _pest == null or playfield == null:
		return
	var bounds := _playfield_bounds()
	_pest.set_nest_position(Vector2(bounds.position.x + bounds.size.x * 0.5, bounds.position.y + 28.0))
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
	_hide_bloom_panel()
	_remove_chip(chip)
	_update_hint()
	_refresh_bag()


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
			_layout_bag()
			_layout_pest_nest()
		_refresh_bag()
		_sync_hub_nav_lock()
	else:
		# Stay locked only while session lives; tabs should already block leave.
		_sync_hub_nav_lock()


func set_meta_hub_mode(_enabled: bool) -> void:
	if back_button:
		back_button.visible = not _enabled


func refresh_for_meta_hub() -> void:
	_refresh_bag()
	_update_hint()
	_sync_hub_nav_lock()


func _process(delta: float) -> void:
	_apply_magnet_pull()
	if _pest:
		_pest.tick(delta)
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
	if partner == null:
		return
	var dist := active.get_center().distance_to(partner.get_center())
	if dist >= GameState.ARENA_MAGNET_RADIUS or dist < ArenaSeedChip.CHIP_RADIUS * 0.35:
		return
	var pull_strength := (GameState.ARENA_MAGNET_RADIUS - dist) / GameState.ARENA_MAGNET_RADIUS
	var dir := (active.get_center() - partner.get_center()).normalized()
	var next_center := partner.get_center() + dir * pull_strength * 6.5
	if _get_bag_keepout_rect().has_point(next_center):
		return
	partner.set_center(next_center)
	_sync_chip_pos(partner)


func _clear_magnet_lock() -> void:
	_magnet_lock_drag = null
	_magnet_lock_partner = null


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


func _on_bag_clicked() -> void:
	var slots := _arena_slots_available()
	if slots <= 0:
		info_label.text = "Arena full (%d/%d) — merge some seeds first!" % [
			_chips.size(),
			GameState.ARENA_MAX_CHIPS,
		]
		_refresh_bag()
		return
	var bag_count := GameState.sum_seed_bag_only()
	if bag_count <= 0:
		info_label.text = "Bag is empty."
		_refresh_bag()
		return
	var to_pour := mini(slots, bag_count)
	var pulled := GameState.pull_seeds_to_arena(to_pour)
	if pulled.is_empty():
		info_label.text = "Nothing to pour."
		_refresh_bag()
		return
	_spawn_poured_chips(pulled)
	_repel_chips_from_bag()
	if _pest:
		_pest.on_seeds_poured(not _chips.is_empty())
	if GameState.should_show_arena_pest_tutorial():
		info_label.text = "Muncher woke up — merge fast! T3 merge freezes it 2s."
		GameState.mark_arena_pest_tutorial_shown()
	else:
		info_label.text = "Poured %d seeds — drag matching ones together!" % pulled.size()
	_update_hint()
	_refresh_bag()


func _arena_slots_available() -> int:
	return maxi(0, GameState.ARENA_MAX_CHIPS - _chips.size())


func _get_bag_keepout_rect() -> Rect2:
	if _seed_bag == null:
		return Rect2()
	var pad := Vector2(BAG_KEEPOUT_SIDE, BAG_KEEPOUT_TOP)
	return Rect2(
		_seed_bag.position - pad,
		_seed_bag.size + Vector2(BAG_KEEPOUT_SIDE * 2.0, BAG_KEEPOUT_TOP + BAG_KEEPOUT_BOTTOM)
	)


func _repel_chips_from_bag() -> void:
	var zone := _get_bag_keepout_rect()
	if zone.size.x < 1.0:
		return
	for chip in _chips:
		if not is_instance_valid(chip):
			continue
		var center := chip.get_center()
		if not zone.has_point(center):
			continue
		var zone_center := zone.get_center()
		var dir := center - zone_center
		if dir.length_squared() < 1.0:
			dir = Vector2(0.0, -1.0)
		else:
			dir = dir.normalized()
		var push := maxf(zone.size.x, zone.size.y) * 0.42 + ArenaSeedChip.CHIP_RADIUS * 1.35
		chip.set_center(zone_center + dir * push)
		_sync_chip_pos(chip)


func _spawn_poured_chips(entries: Array) -> void:
	var existing: Array[Vector2] = []
	for chip in _chips:
		existing.append(chip.get_center())
	var bounds := _playfield_bounds()
	for entry in entries:
		var chip_id := int(entry.get("chip_id", 0))
		var type_id := str(entry.get("type_id", ""))
		var tier := int(entry.get("tier", 1))
		var pos := _random_chip_position(existing, _pour_spawn_bounds(bounds))
		existing.append(pos)
		var chip := ArenaSeedChip.new()
		chip.setup(chip_id, type_id, pos, tier)
		chip.drag_released.connect(_on_chip_released)
		chip.bloom_tapped.connect(_on_bloom_tapped)
		playfield.add_child(chip)
		_chips.append(chip)
		_chip_data[chip_id] = {"chip_id": chip_id, "type_id": type_id, "tier": tier, "pos": pos}


func _playfield_bounds() -> Rect2:
	var field := playfield.size
	if field.x < 10.0:
		field = Vector2(1000.0, 900.0)
	var margin := ArenaSeedChip.CHIP_RADIUS + 16.0
	var bag_reserve := ArenaSeedBag.BAG_SIZE.y + BAG_BOTTOM_PAD + BAG_LIFT + 24.0
	return Rect2(
		margin,
		margin,
		field.x - margin * 2.0,
		field.y - bag_reserve - margin
	)


func _pour_spawn_bounds(full_bounds: Rect2) -> Rect2:
	var zone := _get_bag_keepout_rect()
	if zone.size.x < 1.0:
		return full_bounds
	var ceiling := zone.position.y - ArenaSeedChip.CHIP_RADIUS - 12.0
	var min_y := full_bounds.position.y
	var max_h := ceiling - min_y
	if max_h < full_bounds.size.y * 0.35:
		max_h = full_bounds.size.y * 0.72
	return Rect2(full_bounds.position.x, min_y, full_bounds.size.x, maxf(max_h, 80.0))


func _random_chip_position(existing: Array[Vector2], bounds: Rect2) -> Vector2:
	for _attempt in 32:
		var p := Vector2(
			randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
			randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		)
		var ok := true
		for other in existing:
			if p.distance_to(other) < CHIP_MIN_DIST:
				ok = false
				break
		if ok:
			return p
	return Vector2(
		randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
		randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
	)


func _sync_chip_pos(chip: ArenaSeedChip) -> void:
	var bounds := _playfield_bounds()
	var center := chip.get_center()
	center.x = clampf(center.x, bounds.position.x, bounds.position.x + bounds.size.x)
	center.y = clampf(center.y, bounds.position.y, bounds.position.y + bounds.size.y)
	var zone := _get_bag_keepout_rect()
	if zone.size.x > 1.0 and zone.has_point(center):
		var zone_center := zone.get_center()
		var dir := center - zone_center
		if dir.length_squared() < 1.0:
			dir = Vector2(0.0, -1.0)
		else:
			dir = dir.normalized()
		var push := maxf(zone.size.x, zone.size.y) * 0.42 + ArenaSeedChip.CHIP_RADIUS * 1.35
		center = zone_center + dir * push
		center.x = clampf(center.x, bounds.position.x, bounds.position.x + bounds.size.x)
		center.y = clampf(center.y, bounds.position.y, bounds.position.y + bounds.size.y)
	chip.set_center(center)
	if _chip_data.has(chip.chip_id):
		_chip_data[chip.chip_id]["pos"] = center


func _can_merge_chips(a: ArenaSeedChip, b: ArenaSeedChip) -> bool:
	return a.type_id == b.type_id and a.tier == b.tier


func _resolve_overlaps(moved: ArenaSeedChip) -> void:
	if not is_instance_valid(moved):
		return
	for _pass in 14:
		var moved_center := moved.get_center()
		var fixed_any := false
		for other in _chips:
			if other == moved or not is_instance_valid(other):
				continue
			var other_center := other.get_center()
			var dist := moved_center.distance_to(other_center)
			if dist >= CHIP_SEPARATION - 0.5:
				continue
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
	_repel_chips_from_bag()


func _on_chip_released(chip: ArenaSeedChip) -> void:
	_clear_magnet_lock()
	_sync_chip_pos(chip)
	var partner := _find_snap_partner(chip)
	if partner != null:
		var result := GameState.try_merge_arena_chips(chip.chip_id, partner.chip_id, _chip_data)
		if bool(result.get("ok", false)):
			_hide_bloom_panel()
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
			var name: String = GameState.SEED_DISPLAY_NAMES.get(chip.type_id, chip.type_id)
			if new_tier >= GameState.MAX_MERGE_TIER:
				if _pest:
					_pest.on_t3_created()
				GameState.stash_garden_crystal(chip.type_id)
				info_label.text = "%s crystal → garden stash! Muncher frozen 2s." % name
				_remove_chip(chip)
				_update_hint()
				_refresh_bag()
				return
			else:
				info_label.text = "Merged to T%d — keep merging!" % new_tier
			_resolve_overlaps(chip)
			_update_hint()
			_refresh_bag()
			return
		info_label.text = str(result.get("msg", "No merge."))
	_resolve_overlaps(chip)
	_repel_chips_from_bag()
	_refresh_bag()


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


func _setup_bloom_panel() -> void:
	if _bloom_panel != null:
		return
	_bloom_panel = PanelContainer.new()
	_bloom_panel.name = "BloomActionPanel"
	_bloom_panel.visible = false
	_bloom_panel.z_index = 60
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.9, 0.96)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	_bloom_panel.add_theme_stylebox_override("panel", style)
	playfield.add_child(_bloom_panel)
	var col := VBoxContainer.new()
	col.name = "VBox"
	col.add_theme_constant_override("separation", 6)
	_bloom_panel.add_child(col)
	var title := Label.new()
	title.name = "Title"
	col.add_child(title)
	var row := HBoxContainer.new()
	row.name = "ActionRow"
	row.add_theme_constant_override("separation", 8)
	col.add_child(row)
	var donate := UiClickButton.new()
	donate.name = "DonateBtn"
	donate.label_text = "Donate"
	donate.font_size = 16
	donate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	donate.clicked.connect(_on_bloom_donate)
	row.add_child(donate)
	var keep := UiClickButton.new()
	keep.name = "KeepBtn"
	keep.label_text = "Album"
	keep.font_size = 16
	keep.button_variant = "accent"
	keep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keep.clicked.connect(_on_bloom_keep)
	row.add_child(keep)
	var basket := UiClickButton.new()
	basket.name = "BasketBtn"
	basket.label_text = "Basket"
	basket.font_size = 16
	basket.button_variant = "subtle"
	basket.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	basket.clicked.connect(_on_bloom_basket)
	row.add_child(basket)


func _on_bloom_tapped(chip: ArenaSeedChip) -> void:
	if chip.tier < 2:
		return
	_show_bloom_panel(chip)


func _show_bloom_panel(chip: ArenaSeedChip) -> void:
	if _bloom_panel == null:
		return
	_bloom_target = chip
	var name: String = GameState.SEED_DISPLAY_NAMES.get(chip.type_id, chip.type_id)
	var title: Label = _bloom_panel.get_node("VBox/Title") as Label
	if title:
		title.text = "%s T%d" % [name, chip.tier]
	var donate: UiClickButton = _bloom_panel.get_node("VBox/ActionRow/DonateBtn") as UiClickButton
	if donate:
		if chip.tier == 2:
			donate.disabled = (
				GameState.magnet_level >= GameState.MAGNET_MAX_LEVEL
				or GameState.sprinkler_donations >= GameState.MAGNET_COST_T2
			)
		else:
			donate.disabled = (
				GameState.multiplier_level >= GameState.MULTIPLIER_MAX_LEVEL
				or GameState.multiplier_donations >= GameState.MULTIPLIER_COST_T3
			)
	var keep: UiClickButton = _bloom_panel.get_node("VBox/ActionRow/KeepBtn") as UiClickButton
	if keep:
		var can_upgrade := GameState.can_keep_bloom_upgrade(chip.type_id, chip.tier)
		keep.disabled = not can_upgrade
		if can_upgrade:
			var prev := int(GameState.collection_kept_tiers.get(chip.type_id, 0))
			if prev <= 0:
				keep.label_text = "Album"
			else:
				keep.label_text = "Album T%d→T%d" % [prev, chip.tier]
		else:
			var kept := int(GameState.collection_kept_tiers.get(chip.type_id, 0))
			if kept >= chip.tier:
				keep.label_text = "In Album"
			else:
				keep.label_text = "Keep"
	var center := chip.get_center()
	_bloom_panel.position = center + Vector2(-120.0, -ArenaSeedChip.CHIP_RADIUS - 90.0)
	_bloom_panel.visible = true


func _hide_bloom_panel() -> void:
	if _bloom_panel:
		_bloom_panel.visible = false
	_bloom_target = null


func _on_bloom_donate() -> void:
	if _bloom_target == null:
		return
	if GameState.donate_bloom(_bloom_target.type_id, _bloom_target.tier):
		info_label.text = "Donated!"
		_consume_bloom_target()
	else:
		info_label.text = "Cannot donate — try Basket or leave for auto-donate on Done."


func _on_bloom_keep() -> void:
	if _bloom_target == null:
		return
	if GameState.keep_bloom(_bloom_target.type_id, _bloom_target.tier):
		info_label.text = "Saved to Album!"
		_consume_bloom_target()
	else:
		info_label.text = "Already in Album at this tier — Donate or Basket."


func _on_bloom_basket() -> void:
	if _bloom_target == null:
		return
	if GameState.basket_bloom_type(_bloom_target.type_id):
		var name: String = GameState.SEED_DISPLAY_NAMES.get(
			GameState.get_loadout_type(),
			GameState.get_loadout_type()
		)
		info_label.text = "Basket set to %s." % name
		_consume_bloom_target()
	else:
		info_label.text = "Cannot use basket for this bloom."


func _consume_bloom_target() -> void:
	if _bloom_target == null:
		return
	var chip := _bloom_target
	_hide_bloom_panel()
	_remove_chip(chip)
	_update_hint()
	_refresh_bag()


func _refresh_bag() -> void:
	if _seed_bag == null:
		return
	var bag_count := GameState.sum_seed_bag_only()
	var slots := _arena_slots_available()
	var can_pour := bag_count > 0 and slots > 0
	_seed_bag.set_state(bag_count, can_pour, GameState.get_bag_preview_types())
	_layout_bag()
	_repel_chips_from_bag()


func _on_done_pressed() -> void:
	_hide_bloom_panel()
	GameState.commit_arena_chips_to_bag(_chip_data)
	_clear_field_chips()
	if _pest:
		_pest.reset_to_nest()
	_set_hub_nav_locked(false)
	GameState.go_to_camp_hub()


func _on_back_pressed() -> void:
	_hide_bloom_panel()
	GameState.commit_arena_chips_to_bag(_chip_data)
	_clear_field_chips()
	if _pest:
		_pest.reset_to_nest()
	_set_hub_nav_locked(false)
	GameState.go_to_camp_hub()


func _clear_field_chips() -> void:
	for chip in _chips:
		if is_instance_valid(chip):
			chip.queue_free()
	_chips.clear()
	_chip_data.clear()


func _update_hint() -> void:
	if GameState.merge_hint_booster_active:
		info_label.text = GameState.get_merge_hint_message(_chip_data)
		return
	var bag := GameState.sum_seed_bag_only()
	if GameState.should_prompt_merge_tutorial():
		info_label.text = "Tap bag to pour seeds. Drag to merge. Tap blooms to spend."
	elif bag >= 2 and _chips.is_empty():
		info_label.text = "Tap the bag below — seeds jump into the arena!"
	elif bag > 0 and _chips.size() < GameState.ARENA_MAX_CHIPS:
		info_label.text = "Tap bag again to pour more (up to %d on field)." % GameState.ARENA_MAX_CHIPS
	elif not _chips.is_empty():
		info_label.text = "Merge T1→T2→T3. T3 crystals go to garden stash. Tap T2 blooms to spend."
	elif bag <= 0 and _chips.is_empty():
		if _pest and _pest.is_active():
			info_label.text = "Out of seeds — tap Done or pour again when you have more."
		else:
			info_label.text = "No seeds left — tap Done to return to camp."
