extends SceneTree

## Bug-015 — run scene loads with TopHud strip (counters not bottom-anchored).


func _initialize() -> void:
	call_deferred("_test")


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		push_error("run_smoke: load failed %d" % err)
		quit(1)
		return
	for _i in 16:
		await process_frame
	var run := current_scene
	if run == null or not str(run.scene_file_path).ends_with("run_scene.tscn"):
		push_error("run_smoke: wrong scene")
		quit(1)
		return
	if not run.has_method("start_run"):
		push_error("run_smoke: run controller missing start_run")
		quit(1)
		return
	var top_hud := run.get_node_or_null("HUD/TopHud") as Control
	if top_hud == null:
		push_error("run_smoke: TopHud missing")
		quit(1)
		return
	var pickup_bar := run.get_node_or_null("HUD/TopHud/TopHudVBox/TopRow/PickupBar") as Control
	if pickup_bar == null:
		push_error("run_smoke: PickupBar not under TopRow")
		quit(1)
		return
	if is_equal_approx(pickup_bar.anchor_top, 1.0):
		push_error("run_smoke: PickupBar still bottom-anchored")
		quit(1)
		return
	var coin := run.get_node_or_null(
		"HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/CoinRow/CoinLabel"
	) as Label
	var seed := run.get_node_or_null(
		"HUD/TopHud/TopHudVBox/TopRow/PickupBar/PickupCounters/SeedRow/SeedLabel"
	) as Label
	if coin == null or seed == null:
		push_error("run_smoke: counter labels missing")
		quit(1)
		return
	print("run_smoke OK")
	quit(0)
