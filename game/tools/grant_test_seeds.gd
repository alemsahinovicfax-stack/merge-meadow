extends SceneTree

## Playtest: freeze leftover bag (100 T1, 5 types). Ignores soft cap.
## godot --headless --path game --script res://tools/grant_test_seeds.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var gs: Node = get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("GameState autoload missing")
		quit(1)
		return
	gs.set("_debug_leftover_bag_applied", false)
	var applied: bool = bool(gs.call("apply_debug_leftover_test_bag"))
	if not applied:
		push_error("apply_debug_leftover_test_bag did not overwrite")
		quit(1)
		return
	print("Granted 100 seeds: clover 19, daisy 22, buttercup 13, tulip 28, sunflower 18")
	print("Save: %s/player_save.json" % OS.get_user_data_dir())
	quit(0)
