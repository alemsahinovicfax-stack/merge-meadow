extends SceneTree

## Bug-023/024 + HOME-13 CHROME-C — Home basket in PlayRow; season picker; camp chip is trade-only.


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


func _run() -> void:
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		_fail("main_menu load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var home := current_scene as Control
	var gs := _gs()
	if home == null or gs == null:
		_fail("home/GameState missing")
		return
	gs.set("tutorial_complete", true)
	gs.set("seed_unlock_index", 1)
	gs.set("loadout_type_id", "")
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
	if basket_card.get_parent() == stack:
		_fail("BasketCard must not stay under HomeTopStack")
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
	if play_row == null or basket_card.get_parent() != play_row:
		_fail("BasketCard parent should be PlayRow")
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
	if not basket_card.visible:
		_fail("Bloom field: BasketCard should be visible")
		return
	if basket_card.get_parent() != play_row:
		_fail("Bloom field: BasketCard should stay under PlayRow")
		return
	if not home.has_method("_on_basket_type_picked"):
		_fail("missing _on_basket_type_picked")
		return
	home.call("_on_basket_type_picked", "clover")
	await process_frame
	if str(gs.get("loadout_type_id")) != "clover":
		_fail("expected loadout clover got %s" % str(gs.get("loadout_type_id")))
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
