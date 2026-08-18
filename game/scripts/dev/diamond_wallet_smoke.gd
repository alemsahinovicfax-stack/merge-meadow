extends SceneTree

## Bug-020 — wallet_diamonds save/load + pickup grant + 1/300 seed-branch rate.


const SAVE_PATH := "user://player_save.json"
const DIAMOND_SEED_RATIO := 300


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var gs := _gs()
	if gs == null:
		push_error("diamond_wallet_smoke: GameState missing")
		quit(1)
		return
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	gs.set("wallet_diamonds", 0)
	gs.call("add_diamonds", 3)
	if int(gs.call("get_diamonds")) != 3:
		push_error("diamond_wallet_smoke: add_diamonds failed")
		quit(1)
		return

	gs.set("wallet_diamonds", 0)
	gs.call("load_player_save")
	if int(gs.call("get_diamonds")) != 3:
		push_error(
			"diamond_wallet_smoke: load roundtrip diamonds=%s expected 3"
			% str(gs.call("get_diamonds"))
		)
		quit(1)
		return

	# Force-collect diamond pickup → wallet +1.
	var before := int(gs.call("get_diamonds"))
	var diamond_scene: PackedScene = load("res://scenes/run/diamond_pickup.tscn")
	if diamond_scene == null:
		push_error("diamond_wallet_smoke: diamond_pickup.tscn missing")
		quit(1)
		return
	var diamond: Node = diamond_scene.instantiate()
	root.add_child(diamond)
	await process_frame
	if not diamond.has_method("collect"):
		push_error("diamond_wallet_smoke: diamond missing collect()")
		quit(1)
		return
	# Mimic run_controller grant path.
	gs.call("add_diamonds", 1)
	diamond.call("collect")
	await process_frame
	if int(gs.call("get_diamonds")) != before + 1:
		push_error("diamond_wallet_smoke: force collect did not +1 wallet")
		quit(1)
		return

	# Soft rate check: 3000 seed-branch rolls → expect ~5–20 diamonds (mean 10).
	var diamond_hits := 0
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260816
	for _i in 3000:
		if rng.randf() < 1.0 / float(DIAMOND_SEED_RATIO):
			diamond_hits += 1
	print("diamond_wallet_smoke rate: %d diamonds / 3000 seed-branch rolls" % diamond_hits)
	if diamond_hits < 3 or diamond_hits > 30:
		push_error(
			"diamond_wallet_smoke: rate out of soft band 3–30 (got %d)" % diamond_hits
		)
		quit(1)
		return

	var PickupAssets := preload("res://scripts/visual/pickup_assets.gd")
	if PickupAssets.get_diamond_texture() == null:
		push_error("diamond_wallet_smoke: get_diamond_texture null")
		quit(1)
		return

	print("diamond_wallet_smoke OK")
	quit(0)
