extends SceneTree

## Bug-023/024 — Home basket card picker sets loadout; not under Panel/VBox.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/main_menu.tscn")
	if err != OK:
		push_error("home_basket_picker_smoke: main_menu load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var home := current_scene as Control
	var gs := _gs()
	if home == null or gs == null:
		push_error("home_basket_picker_smoke: home/GameState missing")
		quit(1)
		return
	gs.set("tutorial_complete", true)
	gs.set("seed_unlock_index", 1)
	gs.set("loadout_type_id", "")
	if home.has_method("_refresh_basket_card"):
		home.call("_refresh_basket_card")
	elif home.has_method("_refresh_basket_button"):
		home.call("_refresh_basket_button")
	if not home.has_method("_on_basket_type_picked"):
		push_error("home_basket_picker_smoke: missing _on_basket_type_picked")
		quit(1)
		return
	home.call("_on_basket_type_picked", "clover")
	await process_frame
	if str(gs.get("loadout_type_id")) != "clover":
		push_error(
			"home_basket_picker_smoke: expected loadout clover got %s"
			% str(gs.get("loadout_type_id"))
		)
		quit(1)
		return
	home.call("_on_basket_type_picked", "daisy")
	await process_frame
	if str(gs.get("loadout_type_id")) != "daisy":
		push_error(
			"home_basket_picker_smoke: expected loadout daisy got %s"
			% str(gs.get("loadout_type_id"))
		)
		quit(1)
		return
	home.call("_on_basket_clear_picked")
	await process_frame
	if str(gs.get("loadout_type_id")) != "":
		push_error("home_basket_picker_smoke: clear should empty loadout")
		quit(1)
		return
	var basket_card := home.get_node_or_null("%BasketCard")
	if basket_card == null:
		push_error("home_basket_picker_smoke: BasketCard missing")
		quit(1)
		return
	if home.get_node_or_null("Panel/VBox/BasketButton") != null:
		push_error("home_basket_picker_smoke: BasketButton still under Panel/VBox")
		quit(1)
		return
	if home.get_node_or_null("%BasketVisual") == null:
		push_error("home_basket_picker_smoke: BasketVisual missing")
		quit(1)
		return
	var stack := home.get_node_or_null("%HomeTopStack")
	if stack == null or basket_card.get_parent() != stack:
		push_error("home_basket_picker_smoke: BasketCard not under HomeTopStack")
		quit(1)
		return
	if home.get_node_or_null("%BasketPickerOverlay") == null:
		push_error("home_basket_picker_smoke: BasketPickerOverlay missing")
		quit(1)
		return
	# Camp chip tap must not set loadout (trade-only).
	err = change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("home_basket_picker_smoke: camp load failed %d" % err)
		quit(1)
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
		push_error("home_basket_picker_smoke: camp chip must not set loadout")
		quit(1)
		return
	print("home_basket_picker_smoke OK")
	quit(0)
