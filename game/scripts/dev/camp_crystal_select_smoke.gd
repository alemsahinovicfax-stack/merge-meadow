extends SceneTree

## Bug-012 — select crystal type then exchange 1 → coins; select persists while count >= 1.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/camp/camp_scene.tscn")
	if err != OK:
		push_error("camp_crystal_select_smoke: camp load failed %d" % err)
		quit(1)
		return
	for _i in 12:
		await process_frame
	var camp := current_scene as Control
	var gs := _gs()
	if camp == null or gs == null:
		push_error("camp_crystal_select_smoke: camp/GameState missing")
		quit(1)
		return
	if camp.get_node_or_null("RootVBox/MainScroll/ContentMargin/Content/GardenCard/GardenVBox/CrystalRow") != null:
		push_error("camp_crystal_select_smoke: CrystalRow still inside GardenCard")
		quit(1)
		return
	var crystal_card := camp.get_node_or_null("RootVBox/MainScroll/ContentMargin/Content/CrystalCard")
	if crystal_card == null:
		push_error("camp_crystal_select_smoke: CrystalCard missing")
		quit(1)
		return
	gs.set("garden_crystal_stash", {"clover": 2, "daisy": 1})
	gs.set("wallet_coins", 10)
	if camp.has_method("_refresh_crystal_card"):
		camp.call("_refresh_crystal_card")
	elif camp.has_method("_refresh_ui"):
		camp.call("_refresh_ui")
	for _j in 4:
		await process_frame
	var grid := camp.get_node_or_null("%CrystalGrid") as GridContainer
	if grid == null or grid.get_child_count() < 2:
		push_error("camp_crystal_select_smoke: CrystalGrid missing chips")
		quit(1)
		return
	var exchange := camp.get_node_or_null("%CrystalExchangeButton")
	if exchange == null:
		push_error("camp_crystal_select_smoke: CrystalExchangeButton missing")
		quit(1)
		return
	if not bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should start disabled")
		quit(1)
		return
	if camp.has_method("_on_crystal_chip_pressed"):
		camp.call("_on_crystal_chip_pressed", "clover")
	await process_frame
	var selected := str(camp.get("_selected_crystal_type"))
	if selected != "clover":
		push_error("camp_crystal_select_smoke: expected clover selected got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should be enabled")
		quit(1)
		return
	if camp.has_method("_on_crystal_exchange_pressed"):
		camp.call("_on_crystal_exchange_pressed")
	for _k in 4:
		await process_frame
	var stash: Dictionary = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 1:
		push_error("camp_crystal_select_smoke: clover expected 1 got %s" % str(stash.get("clover")))
		quit(1)
		return
	var reward := int(gs.get("CRYSTAL_EXCHANGE_COINS"))
	if int(gs.get("wallet_coins")) != 10 + reward:
		push_error(
			"camp_crystal_select_smoke: coins expected %d got %s"
			% [10 + reward, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_crystal_type"))
	if selected != "clover":
		push_error("camp_crystal_select_smoke: select should persist after exchange #1 got %s" % selected)
		quit(1)
		return
	if bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should stay enabled after #1")
		quit(1)
		return
	camp.call("_on_crystal_exchange_pressed")
	for _m in 4:
		await process_frame
	stash = gs.get("garden_crystal_stash")
	if int(stash.get("clover", 0)) != 0:
		push_error("camp_crystal_select_smoke: clover expected 0 after #2 got %s" % str(stash.get("clover")))
		quit(1)
		return
	if int(gs.get("wallet_coins")) != 10 + reward * 2:
		push_error(
			"camp_crystal_select_smoke: coins expected %d got %s"
			% [10 + reward * 2, str(gs.get("wallet_coins"))]
		)
		quit(1)
		return
	selected = str(camp.get("_selected_crystal_type"))
	if not selected.is_empty():
		push_error("camp_crystal_select_smoke: select should clear when clover gone got %s" % selected)
		quit(1)
		return
	if not bool(exchange.get("disabled")):
		push_error("camp_crystal_select_smoke: Exchange should be disabled when select cleared")
		quit(1)
		return
	print("camp_crystal_select_smoke OK")
	quit(0)
