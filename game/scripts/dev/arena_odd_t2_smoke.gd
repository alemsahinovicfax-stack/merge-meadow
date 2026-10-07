extends SceneTree

## FLOW-A — leftover T2 on Done becomes 2× T1 in the bag.


var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	call_deferred("_run")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _gs() -> Node:
	return get_root().get_node_or_null("GameState")


func _run() -> void:
	var gs := _gs()
	if gs == null:
		push_error("arena_odd_t2_smoke: GameState missing")
		_quit(1)
		return
	gs.set("seed_bag", {"clover": 2})
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
	if after != before + 2:
		push_error(
			"arena_odd_t2_smoke: expected clover bag %d got %d (summary=%s)"
			% [before + 2, after, str(summary)]
		)
		_quit(1)
		return
	if int(summary.get("recycled", 0)) != 1:
		push_error("arena_odd_t2_smoke: expected recycled=1 got %s" % str(summary))
		_quit(1)
		return
	if int(summary.get("kept", 0)) != 0 or int(summary.get("donated", 0)) != 0:
		push_error("arena_odd_t2_smoke: arena Done must not keep/donate")
		_quit(1)
		return
	if not chips.is_empty():
		push_error("arena_odd_t2_smoke: chip_data should be cleared")
		_quit(1)
		return
	print("arena_odd_t2_smoke OK")
	_quit(0)
