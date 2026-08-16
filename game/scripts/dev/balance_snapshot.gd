extends SceneTree

## F4 — Simulira N runova i ispisuje prosječni loot (headless balans snapshot).


const RUNS := 5


func _gs() -> Node:
	return get_root().get_node("GameState")


func _initialize() -> void:
	call_deferred("_step")


func _step() -> void:
	await process_frame
	var gs := _gs()
	var total_coins := 0
	var total_seeds := 0
	for i in RUNS:
		gs.call("begin_fresh_run")
		var seeds := {"clover": 2 + i, "daisy": 1}
		var coins := 3 + i
		var failed := i % 2 == 1
		gs.call("finish_run", seeds, coins, failed, 45.0)
		total_coins += int(gs.get("last_run_coins"))
		total_seeds += int(gs.call("sum_seed_bag", gs.get("last_seed_bag")))
	print(
		"balance_snapshot: runs=%d avg_coins=%.1f avg_seeds=%.1f magnet_lv=%d"
		% [
			RUNS,
			float(total_coins) / float(RUNS),
			float(total_seeds) / float(RUNS),
			int(gs.get("magnet_level")),
		]
	)
	print("balance_snapshot OK")
	quit(0)
