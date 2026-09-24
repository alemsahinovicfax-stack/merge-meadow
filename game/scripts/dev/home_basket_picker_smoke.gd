extends SceneTree

## Bug-023/024 + HOME-13 CHROME-C + HOME-15 DOCK-A — picker T3 / ★3 / footer.

const SeedUnlockConfig := preload("res://scripts/progression/seed_unlock_config.gd")


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _fail(msg: String) -> void:
	push_error("home_basket_picker_smoke: %s" % msg)
	quit(1)


func _picker_labels(home: Node) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if home.has_method("_rebuild_picker_list"):
		home.call("_rebuild_picker_list")
	var list: Node = home.get_node_or_null("%PickerList")
	if list == null:
		return out
	for child in list.get_children():
		out.append(str(child.get("label_text")))
	return out


func _find_named(n: Node, node_name: String) -> Node:
	if n.name == node_name:
		return n
	for child in n.get_children():
		var found := _find_named(child, node_name)
		if found:
			return found
	return null


func _find_picker_icon(n: Node) -> Control:
	var script: Script = n.get_script()
	if script != null and str(script.resource_path).ends_with("home_basket_picker_icon.gd"):
		return n as Control
	for child in n.get_children():
		var found := _find_picker_icon(child)
		if found:
			return found
	return null


func _assert_picker_rows(home: Node) -> String:
	var list: Node = home.get_node_or_null("%PickerList")
	if list == null:
		return "PickerList missing"
	if list.get_child_count() <= 0:
		return "PickerList should have flower rows"
	for child in list.get_children():
		var label_text := str(child.get("label_text"))
		if label_text.is_empty() or label_text == "<null>":
			return "flower row missing label_text"
		if label_text.findn("Clear") >= 0:
			return "Clear must not be a PickerList child"
		var icon := _find_picker_icon(child)
		if icon == null:
			return "flower row missing T3 PlantIcon"
		var label := _find_named(child, "Label") as Control
		if label == null:
			return "flower row missing Label"
		if icon.global_position.y >= label.global_position.y:
			return "T3 icon must sit above the name label"
	return ""


func _assert_picker_footer(home: Node) -> String:
	var list: Node = home.get_node_or_null("%PickerList")
	var footer := home.get_node_or_null("%PickerFooter") as Control
	var clear_btn := home.get_node_or_null("%PickerClearButton") as Control
	var close_btn := home.get_node_or_null("%PickerCloseButton") as Control
	if footer == null:
		return "PickerFooter missing"
	if clear_btn == null or close_btn == null:
		return "PickerClearButton or PickerCloseButton missing"
	if clear_btn.get_parent() != footer or close_btn.get_parent() != footer:
		return "Clear and Close must be siblings under PickerFooter"
	if list:
		for child in list.get_children():
			if child == clear_btn:
				return "Clear must not be a PickerList child"
			if str(child.get("label_text")).findn("Clear") >= 0:
				return "Clear must not be a PickerList child"
	if close_btn.global_position.y <= clear_btn.global_position.y:
		return "Close must sit below Clear in footer"
	return ""


func _has_scroll_clip_ancestor(n: Node) -> bool:
	var walk := n.get_parent()
	while walk:
		if walk is ScrollContainer:
			return true
		walk = walk.get_parent()
	return false


func _assert_picker_no_scroll(home: Node) -> String:
	var list: Node = home.get_node_or_null("%PickerList")
	if list == null:
		return "PickerList missing"
	if _has_scroll_clip_ancestor(list):
		return "PickerList must not sit under a ScrollContainer"
	return ""


func _assert_picker_rows_in_panel(home: Node) -> String:
	var panel := home.get_node_or_null("%PickerPanel") as Control
	var list: Node = home.get_node_or_null("%PickerList")
	if panel == null:
		return "PickerPanel missing"
	if list == null:
		return "PickerList missing"
	var outer := panel.get_global_rect().grow(1.0)
	for child in list.get_children():
		var row := child as Control
		if row == null:
			continue
		if not outer.encloses(row.get_global_rect()):
			return "flower row not inside PickerPanel: %s" % str(row.get("label_text"))
		var icon := _find_picker_icon(row)
		if icon != null and not outer.encloses(icon.get_global_rect()):
			return "T3 icon not inside PickerPanel: %s" % str(row.get("label_text"))
	var footer := home.get_node_or_null("%PickerFooter") as Control
	if footer != null and not outer.encloses(footer.get_global_rect()):
		return "PickerFooter not inside PickerPanel"
	return ""


func _run() -> void:
	var gs := _gs()
	if gs == null:
		_fail("GameState missing")
		return
	gs.set("skip_debug_season_unlock", true)
	gs.call("reset_seasons_to_s1")
	gs.set("tutorial_complete", true)
	gs.set("seed_unlock_index", 1)
	gs.set("loadout_type_id", "")
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		_fail("main_menu load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var home := current_scene as Control
	if home == null or _gs() == null:
		_fail("home/GameState missing")
		return
	gs = _gs()
	var stage: Node = home.get_node_or_null("%SeasonStage")
	if stage == null:
		_fail("SeasonStage missing")
		return
	if bool(gs.get("home_season_field_open")) and stage.has_method("close_season_field"):
		stage.call("close_season_field")
		await process_frame
	if home.has_method("_refresh_basket_card"):
		home.call("_refresh_basket_card")
	elif home.has_method("_refresh_basket_button"):
		home.call("_refresh_basket_button")
	var basket_card := home.get_node_or_null("%BasketCard") as Control
	if basket_card == null:
		_fail("BasketCard missing")
		return
	if basket_card.visible:
		_fail("carousel BasketCard should be hidden")
		return
	var stack := home.get_node_or_null("%HomeTopStack")
	if stack == null:
		_fail("HomeTopStack missing")
		return
	if basket_card.get_parent() != stack:
		_fail("BasketCard parent should be HomeTopStack")
		return
	if home.get_node_or_null("%DailyChestCard") == null:
		_fail("DailyChestCard missing")
		return
	if home.get_node_or_null("Panel/VBox/BasketButton") != null:
		_fail("BasketButton still under Panel/VBox")
		return
	if home.get_node_or_null("%BasketVisual") == null:
		_fail("BasketVisual missing")
		return
	if home.get_node_or_null("%BasketPickerOverlay") == null:
		_fail("BasketPickerOverlay missing")
		return
	var play_row := home.get_node_or_null("%PlayRow")
	if play_row != null and basket_card.get_parent() == play_row:
		_fail("BasketCard must not sit under PlayRow")
		return
	if home.get_node_or_null("%PlayButton") == null:
		_fail("PlayButton missing")
		return
	if not bool(gs.call("can_open_home_season_field")):
		_fail("Bloom should can_open")
		return
	if not bool(stage.call("open_season_field")):
		_fail("open Bloom field failed")
		return
	await process_frame
	await process_frame
	if str(gs.get("home_season_field_id")) != "country_bloom":
		_fail("field_id expected country_bloom got %s" % str(gs.get("home_season_field_id")))
		return
	if not basket_card.visible:
		_fail("Bloom field: BasketCard should be visible")
		return
	var basket_btn := home.get_node_or_null("%BasketButton") as Control
	if basket_btn == null:
		_fail("Bloom field: BasketButton missing")
		return
	if basket_btn.custom_minimum_size.y < 120.0:
		_fail("Bloom field: BasketButton hit < 120")
		return
	if basket_card.get_parent() != stack:
		_fail("Bloom field: BasketCard should stay under HomeTopStack")
		return
	if play_row != null and basket_card.get_parent() == play_row:
		_fail("Bloom field: BasketCard must not sit under PlayRow")
		return
	if not home.has_method("_on_basket_type_picked"):
		_fail("missing _on_basket_type_picked")
		return
	home.call("_on_basket_type_picked", "clover")
	await process_frame
	if str(gs.get("loadout_type_id")) != "clover":
		_fail("expected loadout clover got %s" % str(gs.get("loadout_type_id")))
		return
	if home.has_method("_refresh_basket_card"):
		home.call("_refresh_basket_card")
	if home.has_method("is_basket_attention_active") and bool(home.call("is_basket_attention_active")):
		_fail("selected basket should not blink")
		return
	home.call("_on_basket_type_picked", "daisy")
	await process_frame
	if str(gs.get("loadout_type_id")) != "daisy":
		_fail("expected loadout daisy got %s" % str(gs.get("loadout_type_id")))
		return
	home.call("_on_basket_clear_picked")
	await process_frame
	if str(gs.get("loadout_type_id")) != "":
		_fail("clear should empty loadout")
		return
	if home.has_method("_refresh_basket_card"):
		home.call("_refresh_basket_card")
	await process_frame
	if home.has_method("is_basket_attention_active") and not bool(home.call("is_basket_attention_active")):
		_fail("empty basket should blink/shake")
		return
	home.call("_on_basket_type_picked", "pumpkin")
	await process_frame
	if str(gs.get("loadout_type_id")) != "":
		_fail("locked pumpkin must not become loadout")
		return
	var bloom_types: Array = gs.call(
		"get_unlocked_loadout_types_for_season", str(gs.get("home_season_field_id"))
	)
	if bloom_types.has("frost_snowdrop"):
		_fail("Bloom picker types must not include frost_snowdrop")
		return
	var labels := _picker_labels(home)
	for label in labels:
		if str(label).findn("frost") >= 0 or str(label).findn("snowdrop") >= 0:
			_fail("Bloom picker row must not list frost-only seed: %s" % label)
			return
	if home.has_method("_open_basket_picker"):
		home.call("_open_basket_picker")
	await process_frame
	await process_frame
	var overlay := home.get_node_or_null("%BasketPickerOverlay") as Control
	if overlay == null or not overlay.visible:
		_fail("open picker should show BasketPickerOverlay")
		return
	var list: Node = home.get_node_or_null("%PickerList")
	if list == null or list.get_child_count() != 6:
		_fail("Bloom picker should list all 6 seeds, got %d" % (list.get_child_count() if list else -1))
		return
	for child in list.get_children():
		var row_label := str(child.get("label_text"))
		if row_label.findn("watermelon") >= 0 or row_label.findn("Patch Watermelon") >= 0:
			_fail("Bloom picker must not list watermelon, got %s" % row_label)
			return
	var pumpkin_row: Control = null
	for child in list.get_children():
		if str(child.get_meta("seed_type_id", "")) == "pumpkin":
			pumpkin_row = child as Control
			break
	if pumpkin_row == null:
		_fail("Bloom picker must include locked pumpkin row")
		return
	if pumpkin_row.modulate.r > 0.6:
		_fail("locked pumpkin row should be gray")
		return
	var row_err := _assert_picker_rows(home)
	if not row_err.is_empty():
		_fail(row_err)
		return
	var footer_err := _assert_picker_footer(home)
	if not footer_err.is_empty():
		_fail(footer_err)
		return
	var scroll_err := _assert_picker_no_scroll(home)
	if not scroll_err.is_empty():
		_fail(scroll_err)
		return
	var in_panel_err := _assert_picker_rows_in_panel(home)
	if not in_panel_err.is_empty():
		_fail(in_panel_err)
		return
	var pumpkin_idx := SeedUnlockConfig.get_index("pumpkin")
	if pumpkin_idx < 0:
		_fail("pumpkin missing from unlock chain")
		return
	gs.set("seed_unlock_index", pumpkin_idx)
	if home.has_method("_rebuild_picker_list"):
		home.call("_rebuild_picker_list")
	await process_frame
	await process_frame
	var bloom_unlocked: Array = gs.call(
		"get_unlocked_loadout_types_for_season", str(gs.get("home_season_field_id"))
	)
	if not bloom_unlocked.has("pumpkin"):
		_fail("unlocked Bloom picker must include pumpkin")
		return
	var pumpkin_labels := _picker_labels(home)
	var pumpkin_listed := false
	for label in pumpkin_labels:
		if str(label).findn("pumpkin") >= 0:
			pumpkin_listed = true
			break
	if not pumpkin_listed:
		_fail("Bloom picker labels should include pumpkin when unlocked")
		return
	home.call("_on_basket_type_picked", "pumpkin")
	await process_frame
	if str(gs.get("loadout_type_id")) != "pumpkin":
		_fail("expected loadout pumpkin got %s" % str(gs.get("loadout_type_id")))
		return
	if home.has_method("_open_basket_picker"):
		home.call("_open_basket_picker")
	await process_frame
	await process_frame
	var full_idx := SeedUnlockConfig.get_index("pumpkin")
	if full_idx < 0:
		_fail("pumpkin missing from unlock chain")
		return
	gs.set("seed_unlock_index", full_idx)
	if home.has_method("_open_basket_picker"):
		home.call("_open_basket_picker")
	await process_frame
	await process_frame
	var full_list: Node = home.get_node_or_null("%PickerList")
	if full_list == null or full_list.get_child_count() != 6:
		_fail(
			"Bloom full unlock expected 6 picker rows got %s"
			% str(full_list.get_child_count() if full_list else 0)
		)
		return
	for full_child in full_list.get_children():
		var full_label := str(full_child.get("label_text"))
		if full_label.findn("watermelon") >= 0 or full_label.findn("Patch Watermelon") >= 0:
			_fail("full Bloom picker must not list watermelon, got %s" % full_label)
			return
	var full_scroll := _assert_picker_no_scroll(home)
	if not full_scroll.is_empty():
		_fail(full_scroll)
		return
	var full_in_panel := _assert_picker_rows_in_panel(home)
	if not full_in_panel.is_empty():
		_fail(full_in_panel)
		return
	var close_btn := home.get_node_or_null("%PickerCloseButton")
	if close_btn and close_btn.has_signal("clicked"):
		close_btn.emit_signal("clicked")
	elif home.has_method("_close_basket_picker"):
		home.call("_close_basket_picker")
	await process_frame
	if overlay.visible:
		_fail("Close should hide BasketPickerOverlay")
		return
	# Camp chip tap must not set loadout (trade-only).
	err = change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		_fail("camp load failed %d" % err)
		return
	for _j in 12:
		await process_frame
	var camp := current_scene as Control
	gs.set("seed_bag", {"clover": 3})
	gs.set("loadout_type_id", "")
	if camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	await process_frame
	var grid := camp.get_node_or_null("%SeedBagGrid") as GridContainer
	if grid and grid.get_child_count() > 0:
		var chip: Node = grid.get_child(0)
		if chip.has_signal("pressed"):
			chip.emit_signal("pressed")
		elif chip.has_method("_on_pressed"):
			chip.call("_on_pressed")
		await process_frame
	if str(gs.get("loadout_type_id")) != "":
		_fail("camp chip must not set loadout")
		return
	print("home_basket_picker_smoke OK")
	quit(0)
