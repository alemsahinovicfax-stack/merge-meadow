extends SceneTree

## Bug-018 — tap bag chip sets basket; hub mode hides FooterBar.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("camp_basket_select_smoke: camp load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := _gs()
	if camp == null or gs == null:
		push_error("camp_basket_select_smoke: camp/GameState missing")
		quit(1)
		return
	gs.set("tutorial_complete", true)
	gs.set("seed_unlock_index", 1)
	gs.set("seed_bag", {"clover": 3, "daisy": 1})
	gs.set("loadout_type_id", "")
	if camp.has_method("_refresh_garden_card"):
		camp.call("_refresh_garden_card")
	if camp.has_method("_refresh_loadout"):
		camp.call("_refresh_loadout")
	for _j in 4:
		await process_frame
	if camp.has_method("_on_seed_chip_pressed"):
		camp.call("_on_seed_chip_pressed", "clover")
	await process_frame
	if str(gs.get("loadout_type_id")) != "clover":
		push_error(
			"camp_basket_select_smoke: expected loadout clover got %s"
			% str(gs.get("loadout_type_id"))
		)
		quit(1)
		return
	if str(camp.get("_selected_trade_type")) != "clover":
		push_error("camp_basket_select_smoke: trade select should be clover (>=3)")
		quit(1)
		return
	camp.call("_on_seed_chip_pressed", "daisy")
	await process_frame
	if str(gs.get("loadout_type_id")) != "daisy":
		push_error(
			"camp_basket_select_smoke: expected loadout daisy got %s"
			% str(gs.get("loadout_type_id"))
		)
		quit(1)
		return
	var footer := camp.get_node_or_null("%FooterBar") as Control
	if footer == null:
		push_error("camp_basket_select_smoke: FooterBar missing")
		quit(1)
		return
	if camp.has_method("set_meta_hub_mode"):
		camp.call("set_meta_hub_mode", true)
	await process_frame
	if footer.visible:
		push_error("camp_basket_select_smoke: FooterBar should be hidden in hub mode")
		quit(1)
		return
	camp.call("set_meta_hub_mode", false)
	await process_frame
	if not footer.visible:
		push_error("camp_basket_select_smoke: FooterBar should show standalone")
		quit(1)
		return
	print("camp_basket_select_smoke OK")
	quit(0)
