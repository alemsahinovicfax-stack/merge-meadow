extends SceneTree

## Bug-016 — odd T2 with album+donate blocked recycles to T1 on commit.


func _initialize() -> void:
	call_deferred("_run")


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var gs := _gs()
	if gs == null:
		push_error("arena_odd_t2_smoke: GameState missing")
		quit(1)
		return
	gs.set("seed_bag", {"clover": 2})
	gs.set("collection_kept_tiers", {"clover": 2})
	gs.set("sprinkler_donations", 2)
	gs.set("magnet_level", 0)
	var before := int(gs.get("seed_bag")["clover"])
	var chips := {
		"chip_odd_t2": {
			"chip_id": "chip_odd_t2",
			"type_id": "clover",
			"tier": 2,
			"pos": Vector2(100, 100),
		}
	}
	var summary: Dictionary = gs.call("commit_arena_chips_to_bag", chips)
	var after := int(gs.get("seed_bag").get("clover", 0))
	if after != before + 1:
		push_error(
			"arena_odd_t2_smoke: expected clover bag %d got %d (summary=%s)"
			% [before + 1, after, str(summary)]
		)
		quit(1)
		return
	if int(summary.get("recycled", 0)) != 1:
		push_error("arena_odd_t2_smoke: expected recycled=1 got %s" % str(summary))
		quit(1)
		return
	if not chips.is_empty():
		push_error("arena_odd_t2_smoke: chip_data should be cleared")
		quit(1)
		return
	print("arena_odd_t2_smoke OK")
	quit(0)
