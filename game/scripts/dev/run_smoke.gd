extends SceneTree

## Bug-015 — run scene loads with TopHud strip (counters not bottom-anchored).


var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_test")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/run/run_scene.tscn")
	if err != OK:
		push_error("run_smoke: load failed %d" % err)
		_quit(1)
		return
	for _i in 16:
		await process_frame
	var run := current_scene
	if run == null or not str(run.scene_file_path).ends_with("run_scene.tscn"):
		push_error("run_smoke: wrong scene")
		_quit(1)
		return
	if not run.has_method("start_run"):
		push_error("run_smoke: run controller missing start_run")
		_quit(1)
		return
	var top_hud := run.get_node_or_null("HUD/TopHud") as Control
	if top_hud == null:
		push_error("run_smoke: TopHud missing")
		_quit(1)
		return
	# Run HUD v2: brojači su u gornjem redu (y 60), ne pri dnu.
	var coin_chip := run.get_node_or_null("HUD/TopHud/CoinChip") as Control
	if coin_chip == null:
		push_error("run_smoke: CoinChip missing")
		_quit(1)
		return
	if is_equal_approx(coin_chip.anchor_top, 1.0) or coin_chip.position.y > 400.0:
		push_error("run_smoke: CoinChip is not in the top row")
		_quit(1)
		return
	var coin := run.get_node_or_null("HUD/TopHud/CoinChip/Row/CoinLabel") as Label
	var seed := run.get_node_or_null("HUD/TopHud/SeedChip/Row/SeedLabel") as Label
	if coin == null or seed == null:
		push_error("run_smoke: counter labels missing")
		_quit(1)
		return
	print("run_smoke OK")
	_quit(0)
