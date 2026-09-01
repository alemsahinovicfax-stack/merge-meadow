extends SceneTree

## HOME-12 MEADOW-A/B + HOME-13 A–E + HOME-14 LIFE-A/B/C/D — SeasonField; Play 3-koraka; equal PlayRow; chrome-safe flowers; Pip FSM.


const SAVE_PATH := "user://player_save.json"
const MetaHubPages := preload("res://scripts/meta/meta_hub_pages.gd")
const BLOOM_PASTEL := Color(0.90, 0.95, 0.86, 1.0)
const HOME_DARK := Color(0.14, 0.2, 0.16, 1.0)


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("season_meadow_smoke: %s" % msg)
	quit(1)


func _count_named(n: Node, node_name: String) -> int:
	var count := 0
	for child in n.get_children():
		if str(child.name) == node_name:
			count += 1
	return count


func _field_flowers(field: Node) -> Array:
	var out: Array = []
	if field == null:
		return out
	for child in field.get_children():
		if child.is_in_group("meadow_flower"):
			out.append(child)
	return out


func _flower_types(flowers: Array) -> Dictionary:
	var types: Dictionary = {}
	for flower in flowers:
		types[str(flower.get("type_id"))] = true
	return types


func _has_arena_chip(n: Node) -> bool:
	for child in n.get_children():
		var script: Script = child.get_script()
		if script != null and str(script.resource_path).ends_with("arena_seed_chip.gd"):
			return true
		if _has_arena_chip(child):
			return true
	return false


func _picker_labels(home: Node) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if home != null and home.has_method("_rebuild_picker_list"):
		home.call("_rebuild_picker_list")
	var list: Node = home.get_node_or_null("%PickerList") if home else null
	if list == null:
		return out
	for child in list.get_children():
		out.append(str(child.get("label_text")))
	return out


func _assert_pip_alive(field: Node, pip: Control, label: String) -> String:
	if pip == null:
		return "%s MeadowPip missing" % label
	if not pip.visible:
		return "%s MeadowPip should be visible" % label
	if pip.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return "%s MeadowPip must IGNORE" % label
	var alive := false
	if field.has_method("is_pip_alive"):
		alive = bool(field.call("is_pip_alive"))
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		alive = true
	if not alive:
		return "%s MeadowPip should be alive or wandering" % label
	return ""


func _assert_play_row_equal(home: Node) -> String:
	var basket_n: Control = home.get_node_or_null("%BasketCard") as Control
	var play_n: Control = home.get_node_or_null("%PlayButton") as Control
	var endless_n: Control = home.get_node_or_null("%EndlessPlayButton") as Control
	if basket_n == null or play_n == null or endless_n == null:
		return "PlayRow children missing"
	var ms: Vector2 = play_n.custom_minimum_size
	if basket_n.custom_minimum_size != ms or endless_n.custom_minimum_size != ms:
		return "PlayRow min sizes differ play=%s basket=%s endless=%s" % [
			str(ms), str(basket_n.custom_minimum_size), str(endless_n.custom_minimum_size)
		]
	if not is_equal_approx(basket_n.size.y, play_n.size.y) or not is_equal_approx(endless_n.size.y, play_n.size.y):
		return "PlayRow heights differ play=%.0f basket=%.0f endless=%.0f" % [
			play_n.size.y, basket_n.size.y, endless_n.size.y
		]
	return ""


func _assert_flowers(field: Node, pool: Array, label: String) -> String:
	var flowers: Array = _field_flowers(field)
	if flowers.size() < 12 or flowers.size() > 14:
		return "%s flower count %d expected 12-14" % [label, flowers.size()]
	var pool_set: Dictionary = {}
	for type_id in pool:
		pool_set[str(type_id)] = true
	for flower in flowers:
		if (flower as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
			return "%s flower must IGNORE" % label
		var type_id := str(flower.get("type_id"))
		if not pool_set.has(type_id):
			return "%s flower type %s not in pool" % [label, type_id]
	if _has_arena_chip(field):
		return "%s must not instance ArenaSeedChip" % label
	return ""


func _assert_flowers_clear_chrome(home: Node, field: Node, label: String) -> String:
	if home == null or field == null:
		return "%s chrome check missing nodes" % label
	var chrome: Array[Control] = []
	var daily: Control = home.get_node_or_null("%DailyChestCard") as Control
	var chip: Control = home.get_node_or_null("%SeasonNameChip") as Control
	var play_row: Control = home.get_node_or_null("%PlayRow") as Control
	var settings: Control = home.get_node_or_null("%SettingsButton") as Control
	if settings == null:
		settings = home.get_node_or_null("SettingsButton") as Control
	for node in [daily, settings, chip, play_row]:
		var control: Control = node as Control
		if control == null or not control.visible:
			continue
		chrome.append(control)
	if chrome.is_empty():
		return "%s expected Daily/Settings/chip/PlayRow for chrome check" % label
	var margin := 12.0
	for flower in _field_flowers(field):
		var fr: Rect2 = (flower as Control).get_global_rect()
		for blocker in chrome:
			var cr: Rect2 = blocker.get_global_rect().grow(margin)
			if fr.intersects(cr):
				return "%s flower intersects %s" % [label, blocker.name]
	return ""


func _run() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)

	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	for _i in 16:
		await process_frame

	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub: Node = hubs[0]
	if hub.has_method("go_to_page"):
		hub.call("go_to_page", MetaHubPages.MAIN, false)
	for _j in 12:
		await process_frame

	var swipe := hub.get_node_or_null("RootVBox/SwipePager")
	if swipe == null:
		_fail("SwipePager missing")
		return
	var host: Node = swipe.call("get_pages_host") if swipe.has_method("get_pages_host") else null
	var home: Node = host.get_node_or_null("Page_%d" % MetaHubPages.MAIN) if host else null
	if home == null:
		_fail("Home page missing")
		return
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return

	var band: Control = stage.get_node_or_null("%BandColumn") as Control
	var field: Control = stage.get_node_or_null("%SeasonField") as Control
	var seasons: Node = stage.get_node_or_null("%SeasonsButton")
	if band == null or field == null:
		_fail("BandColumn or SeasonField missing")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("default field should be closed")
		return
	if not band.visible:
		_fail("default BandColumn should be visible")
		return
	if field.visible:
		_fail("default SeasonField should be hidden")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("expected exactly 1 SeasonField child, got %d" % _count_named(stage, "SeasonField"))
		return
	if seasons == null:
		_fail("SeasonsButton missing")
		return
	if not bool(gs.call("can_open_home_season_field")):
		_fail("Bloom center should can_open")
		return
	if str(home.call("home_play_action")) != "open_field":
		_fail("carousel Bloom: home_play_action should be open_field")
		return
	var basket: Control = home.get_node_or_null("%BasketCard") as Control
	var play_row: Node = home.get_node_or_null("%PlayRow")
	if basket == null:
		_fail("BasketCard missing")
		return
	if basket.visible:
		_fail("carousel BasketCard should be hidden")
		return
	if play_row == null or basket.get_parent() != play_row:
		_fail("BasketCard parent should be PlayRow")
		return
	var stack := home.get_node_or_null("%HomeTopStack")
	if stack != null and basket.get_parent() == stack:
		_fail("carousel BasketCard must not sit under HomeTopStack")
		return
	var endless_btn: Control = home.get_node_or_null("%EndlessPlayButton") as Control
	if endless_btn == null:
		_fail("EndlessPlayButton missing")
		return
	if endless_btn.visible:
		_fail("carousel EndlessPlayButton should be hidden")
		return
	if play_row != null and endless_btn.get_parent() != play_row:
		_fail("EndlessPlayButton parent should be PlayRow")
		return
	var play_btn_carousel: Control = home.get_node_or_null("%PlayButton") as Control
	if play_btn_carousel == null:
		_fail("PlayButton missing")
		return
	if not is_equal_approx(play_btn_carousel.custom_minimum_size.y, 96.0):
		_fail("carousel Play min height expected 96 got %s" % str(play_btn_carousel.custom_minimum_size))
		return
	if basket.custom_minimum_size != play_btn_carousel.custom_minimum_size:
		_fail("carousel Basket min size should match Play")
		return
	if endless_btn.custom_minimum_size != play_btn_carousel.custom_minimum_size:
		_fail("carousel Endless min size should match Play")
		return
	var name_chip: Control = home.get_node_or_null("%SeasonNameChip") as Control
	if name_chip and name_chip.visible:
		_fail("carousel SeasonNameChip should be hidden")
		return

	home.call("_on_play_pressed")
	await process_frame
	await process_frame
	if not bool(gs.get("home_season_field_open")):
		_fail("Play on Bloom should open field")
		return
	if str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("field_id expected country_bloom got %s" % str(gs.get("home_season_field_id")))
		return
	if str(home.call("home_play_action")) != "run":
		_fail("Bloom open: home_play_action should be run")
		return
	if band.visible:
		_fail("BandColumn should hide when field open")
		return
	if not field.visible:
		_fail("SeasonField should show when open")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("still exactly 1 SeasonField after open")
		return
	if seasons == null:
		_fail("SeasonsButton missing after open")
		return
	if (seasons as Control).visible:
		_fail("Bloom open: SeasonsButton should be hidden")
		return
	if str(seasons.get("label_text")).findn("Seasons") >= 0:
		_fail("SeasonsButton label should be empty")
		return
	if name_chip == null:
		_fail("SeasonNameChip missing")
		return
	if not name_chip.visible:
		_fail("Bloom open: SeasonNameChip should be visible")
		return
	var bloom_chip := str(name_chip.get("label_text"))
	if bloom_chip.find("Country Bloom") < 0:
		_fail("Bloom chip expected Country Bloom got '%s'" % bloom_chip)
		return
	var bloom_def: SeasonDef = gs.call("get_season_def", "country_bloom")
	var bloom_pool: Array = bloom_def.seed_type_ids if bloom_def else []
	var bloom_flower_err := _assert_flowers(field, bloom_pool, "Bloom")
	if not bloom_flower_err.is_empty():
		_fail(bloom_flower_err)
		return
	var bloom_chrome_err := _assert_flowers_clear_chrome(home, field, "Bloom")
	if not bloom_chrome_err.is_empty():
		_fail(bloom_chrome_err)
		return
	var bloom_types := _flower_types(_field_flowers(field))
	var pip: Control = stage.get_node_or_null("%MeadowPip") as Control
	if pip == null:
		_fail("MeadowPip missing")
		return
	if _count_named(field, "MeadowPip") != 1:
		_fail("expected exactly 1 MeadowPip, got %d" % _count_named(field, "MeadowPip"))
		return
	var bloom_pip_err := _assert_pip_alive(field, pip, "Bloom open")
	if not bloom_pip_err.is_empty():
		_fail(bloom_pip_err)
		return
	var bloom_pip_id := pip.get_instance_id()
	var backdrop: ColorRect = home.get_node_or_null("%FieldBackdrop") as ColorRect
	var home_bg: ColorRect = home.get_node_or_null("Background") as ColorRect
	var daily: Control = home.get_node_or_null("%DailyChestCard") as Control
	var play_btn: Control = home.get_node_or_null("%PlayButton") as Control
	if backdrop == null:
		_fail("FieldBackdrop missing")
		return
	if not backdrop.visible:
		_fail("Bloom open: FieldBackdrop should be visible")
		return
	if not backdrop.color.is_equal_approx(BLOOM_PASTEL):
		_fail("Bloom FieldBackdrop should be pastel")
		return
	if backdrop.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		_fail("FieldBackdrop must IGNORE")
		return
	if backdrop.size.y <= (stage as Control).size.y:
		_fail("FieldBackdrop should extend beyond SeasonStage")
		return
	if daily and not backdrop.get_global_rect().has_point(daily.global_position + daily.size * 0.5):
		_fail("FieldBackdrop should cover Daily")
		return
	if play_btn and not backdrop.get_global_rect().has_point(play_btn.global_position + play_btn.size * 0.5):
		_fail("FieldBackdrop should cover Play")
		return
	if home_bg == null or not home_bg.color.is_equal_approx(HOME_DARK):
		_fail("Home Background should stay dark green")
		return
	if not basket.visible:
		_fail("Bloom open: BasketCard should be visible")
		return
	if play_btn and basket.global_position.x >= play_btn.global_position.x:
		_fail("Bloom open: BasketCard should sit left of Play")
		return
	if not endless_btn.visible:
		_fail("Bloom open: EndlessPlayButton should be visible")
		return
	if play_btn and endless_btn.global_position.x <= play_btn.global_position.x:
		_fail("Bloom open: EndlessPlayButton should sit right of Play")
		return
	var bloom_row_err := _assert_play_row_equal(home)
	if not bloom_row_err.is_empty():
		_fail("Bloom open: %s" % bloom_row_err)
		return
	if str(gs.get("active_season_id")) != "country_bloom":
		_fail("Bloom open: active_season_id expected country_bloom")
		return
	var bloom_spawn: Array = gs.call("get_active_season_spawn_types")
	if bloom_spawn.has("frost_snowdrop"):
		_fail("Bloom spawn types must not include frost_snowdrop")
		return
	for type_id in bloom_spawn:
		if not bloom_pool.has(type_id):
			_fail("Bloom spawn type %s not in Bloom seed_type_ids" % str(type_id))
			return
	var bloom_picker: Array = gs.call("get_unlocked_loadout_types_for_season", "country_bloom")
	if bloom_picker.has("frost_snowdrop"):
		_fail("Bloom picker types must not include frost_snowdrop")
		return
	for label in _picker_labels(home):
		if str(label).findn("frost") >= 0 or str(label).findn("snowdrop") >= 0:
			_fail("Bloom picker row must not list frost-only seed: %s" % label)
			return

	if name_chip.has_signal("clicked"):
		name_chip.emit_signal("clicked")
	elif stage.has_method("close_season_field"):
		stage.call("close_season_field")
	await process_frame
	if not _field_flowers(field).is_empty():
		_fail("close should clear meadow flowers")
		return
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		_fail("close should stop Pip wander")
		return
	if field.has_method("is_pip_alive") and bool(field.call("is_pip_alive")):
		_fail("close should stop Pip FSM")
		return
	if pip.visible and field.visible:
		_fail("close should hide MeadowPip")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("close should clear flag")
		return
	if not band.visible:
		_fail("BandColumn should show after close")
		return
	if field.visible:
		_fail("SeasonField should hide after close")
		return
	if backdrop.visible:
		_fail("close should hide FieldBackdrop")
		return
	if home_bg == null or not home_bg.color.is_equal_approx(HOME_DARK):
		_fail("close: Home Background should stay dark green")
		return
	if basket.visible:
		_fail("close should hide BasketCard")
		return
	if endless_btn.visible:
		_fail("close should hide EndlessPlayButton")
		return
	if name_chip.visible:
		_fail("close should hide SeasonNameChip")
		return
	gs.set("loadout_type_id", "clover")

	var unlocked: Array = gs.get("unlocked_seasons")
	if not unlocked.has("frost_orchard"):
		unlocked.append("frost_orchard")
	gs.set("strip_focus_id", "frost_orchard")
	gs.set("home_band", "free")
	if not bool(gs.call("can_open_home_season_field")):
		_fail("playable Frost should can_open")
		return
	if not bool(stage.call("open_season_field")):
		_fail("open Frost field failed")
		return
	await process_frame
	await process_frame
	if str(gs.get("home_season_field_id")) != "frost_orchard":
		_fail("field_id expected frost_orchard got %s" % str(gs.get("home_season_field_id")))
		return
	var ground: ColorRect = stage.get_node_or_null("%FieldGround") as ColorRect
	if ground == null:
		_fail("FieldGround missing")
		return
	if ground.color.is_equal_approx(BLOOM_PASTEL) or ground.color.is_equal_approx(Color.WHITE):
		_fail("Frost FieldGround tint should differ from Bloom")
		return
	if not backdrop.visible:
		_fail("Frost open: FieldBackdrop should be visible")
		return
	if backdrop.color.is_equal_approx(BLOOM_PASTEL) or backdrop.color.is_equal_approx(Color.WHITE):
		_fail("Frost FieldBackdrop tint should differ from Bloom")
		return
	var frost_def: SeasonDef = gs.call("get_season_def", "frost_orchard")
	var frost_pool: Array = frost_def.seed_type_ids if frost_def else []
	var frost_flower_err := _assert_flowers(field, frost_pool, "Frost")
	if not frost_flower_err.is_empty():
		_fail(frost_flower_err)
		return
	var frost_chrome_err := _assert_flowers_clear_chrome(home, field, "Frost")
	if not frost_chrome_err.is_empty():
		_fail(frost_chrome_err)
		return
	var frost_types := _flower_types(_field_flowers(field))
	if frost_types == bloom_types:
		_fail("Frost flower types should differ from Bloom")
		return
	if _count_named(stage, "SeasonField") != 1:
		_fail("still exactly 1 SeasonField after Frost open")
		return
	var frost_pip: Control = stage.get_node_or_null("%MeadowPip") as Control
	if frost_pip == null or frost_pip.get_instance_id() != bloom_pip_id:
		_fail("Frost should reuse the same MeadowPip node")
		return
	if _count_named(field, "MeadowPip") != 1:
		_fail("Frost: expected 1 MeadowPip")
		return
	var frost_pip_err := _assert_pip_alive(field, frost_pip, "Frost open")
	if not frost_pip_err.is_empty():
		_fail(frost_pip_err)
		return
	if str(gs.get("loadout_type_id")) != "":
		_fail("Frost open should clear clover loadout")
		return
	if not basket.visible:
		_fail("Frost open: BasketCard should be visible")
		return
	if not endless_btn.visible:
		_fail("Frost open: EndlessPlayButton should be visible")
		return
	var frost_row_err := _assert_play_row_equal(home)
	if not frost_row_err.is_empty():
		_fail("Frost open: %s" % frost_row_err)
		return
	if str(gs.get("active_season_id")) != "frost_orchard":
		_fail("Frost open: active_season_id expected frost_orchard")
		return
	var frost_spawn: Array = gs.call("get_active_season_spawn_types")
	if not frost_spawn.has("frost_snowdrop"):
		_fail("Frost spawn types should include frost_snowdrop")
		return
	if frost_spawn.has("clover"):
		_fail("Frost spawn types must not include clover")
		return
	for type_id in frost_spawn:
		if not frost_pool.has(type_id):
			_fail("Frost spawn type %s not in Frost seed_type_ids" % str(type_id))
			return
	var frost_picker: Array = gs.call("get_unlocked_loadout_types_for_season", "frost_orchard")
	if not frost_picker.has("frost_snowdrop"):
		_fail("Frost picker types should include frost_snowdrop")
		return
	if frost_picker.has("clover"):
		_fail("Frost picker types must not include clover")
		return
	for type_id in frost_picker:
		if not frost_pool.has(type_id):
			_fail("Frost picker type %s not in Frost seed_type_ids" % str(type_id))
			return
	var frost_labels := _picker_labels(home)
	var frost_joined := " ".join(frost_labels)
	if frost_joined.findn("snowdrop") < 0:
		_fail("Frost picker should list Frost Snowdrop")
		return
	if frost_joined.findn("clover") >= 0:
		_fail("Frost picker must not list clover")
		return
	if name_chip == null or not name_chip.visible:
		_fail("Frost open: SeasonNameChip should be visible")
		return
	var frost_chip := str(name_chip.get("label_text"))
	if frost_chip.find("Frost Orchard") < 0:
		_fail("Frost chip expected Frost Orchard got '%s'" % frost_chip)
		return
	if frost_chip == bloom_chip:
		_fail("Frost chip text should differ from Bloom")
		return

	stage.call("close_season_field")
	await process_frame
	if field.has_method("is_pip_wandering") and bool(field.call("is_pip_wandering")):
		_fail("Frost close should stop Pip wander")
		return
	if field.has_method("is_pip_alive") and bool(field.call("is_pip_alive")):
		_fail("Frost close should stop Pip FSM")
		return
	if frost_pip.visible and field.visible:
		_fail("Frost close should hide MeadowPip")
		return
	if basket.visible:
		_fail("Frost close should hide BasketCard")
		return
	if endless_btn.visible:
		_fail("Frost close should hide EndlessPlayButton")
		return
	if name_chip.visible:
		_fail("Frost close should hide SeasonNameChip")
		return
	gs.call("reset_seasons_to_s1")
	gs.set("strip_focus_id", "lantern_meadow")
	if stage.has_method("refresh"):
		stage.call("refresh")
	await process_frame
	await process_frame
	if bool(gs.call("can_open_home_season_field")):
		_fail("locked lantern should not can_open")
		return
	if bool(gs.call("open_home_season_field")):
		_fail("open locked lantern should return false")
		return
	if bool(gs.get("home_season_field_open")):
		_fail("locked open must not set flag")
		return
	if str(home.call("home_play_action")) != "snap":
		_fail("lantern hero: home_play_action should be snap")
		return
	home.call("_on_play_pressed")
	await process_frame
	await process_frame
	if bool(gs.get("home_season_field_open")):
		_fail("lantern Play should not open field")
		return
	if str(gs.call("home_hero_center_id")) != str(gs.get("active_season_id")):
		_fail("lantern Play should snap hero to active_season_id")
		return
	if str(gs.call("home_hero_center_id")) != "country_bloom":
		_fail("lantern Play should snap to Bloom")
		return
	if current_scene and str(current_scene.scene_file_path).find("run_scene") >= 0:
		_fail("lantern Play should not enter run")
		return
	if stage.has_method("swap_home_band"):
		stage.call("swap_home_band", "paid", "coral_tide")
		await process_frame
		await process_frame
	if str(gs.get("home_band")) != "paid":
		_fail("LIFE-A setup: expected paid band for coral")
		return
	if bool(gs.call("is_season_playable", "coral_tide")):
		_fail("coral_tide should be unowned")
		return
	if str(home.call("home_play_action")) != "snap":
		_fail("unowned paid: home_play_action should be snap")
		return
	home.call("_on_play_pressed")
	await process_frame
	await process_frame
	if bool(gs.get("home_season_field_open")):
		_fail("unowned paid Play should not open field")
		return
	if str(gs.get("home_band")) != "free":
		_fail("unowned paid Play should snap home_band to free")
		return
	if str(gs.call("home_hero_center_id")) != "country_bloom":
		_fail("unowned paid Play should snap to Bloom")
		return
	if current_scene and str(current_scene.scene_file_path).find("run_scene") >= 0:
		_fail("unowned paid Play should not enter run")
		return

	print("season_meadow_smoke OK")
	quit(0)
