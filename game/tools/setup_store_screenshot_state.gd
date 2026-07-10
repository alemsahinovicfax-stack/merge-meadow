extends SceneTree

## Seeds player_save.json for store screenshots — camp flowers, coins, mid campaign.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var gs: Node = get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("GameState autoload missing")
		quit()
		return
	gs.call("mark_tutorial_complete")
	gs.set("wallet_coins", 42)
	gs.set("seed_bag", {"clover": 15, "daisy": 6, "buttercup": 4})
	gs.set("magnet_level", 2)
	gs.set("sprinkler_donations", 0)
	gs.set("run_level", 12)
	gs.set("endless_runs_completed", 3)
	gs.set("endless_difficulty", 1)
	gs.set("ads_removed", false)
	gs.set("starter_pack_owned", false)
	gs.set("loadout_type_id", "clover")
	gs.set("discovered_blooms", {"clover": true, "daisy": true, "buttercup": true})
	var beds: Array = gs.get("garden_beds")
	if beds.size() >= 6:
		beds[0] = {"type_id": "clover", "tier": 2}
		beds[1] = {"type_id": "clover", "tier": 1}
		beds[2] = {"type_id": "daisy", "tier": 2}
		beds[3] = {"type_id": "daisy", "tier": 1}
		beds[4] = {"type_id": "buttercup", "tier": 2}
		beds[5] = null
	gs.set("garden_beds", beds)
	gs.call("save_player_save")
	print("Store screenshot save ready: ", OS.get_user_data_dir())
	quit()
