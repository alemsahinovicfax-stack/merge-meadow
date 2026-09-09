extends SceneTree

## Playtest: seed bag (leftover test fixture) + crystal stash (flowers) for
## whatever season is currently active, so Camp has both rows filled.
## Sets seed_bag/tutorial fields directly rather than via
## apply_debug_leftover_test_bag(), which is gated by the (currently false)
## DEBUG_DEV_RESOURCES const and would be a permanent no-op otherwise.
## godot --headless --path game --script res://scripts/dev/grant_test_seeds_and_flowers.gd

const SEED_BAG := {
	"clover": 19,
	"daisy": 22,
	"buttercup": 13,
	"tulip": 28,
	"sunflower": 18,
}
const TUTORIAL_STEP_FREE := 4


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var gs: Node = get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("GameState autoload missing")
		quit(1)
		return
	gs.set("seed_bag", SEED_BAG.duplicate())
	gs.set("seed_unlock_index", 4)
	gs.set("tutorial_complete", true)
	gs.set("tutorial_step", TUTORIAL_STEP_FREE)
	var discovered: Dictionary = gs.get("discovered_blooms")
	for type_id in SEED_BAG:
		discovered[str(type_id)] = true
	gs.set("discovered_blooms", discovered)
	var season_id: String = str(gs.get("active_season_id"))
	var flower_types: Array = gs.call("star3_type_ids_for_season", season_id)
	if flower_types.is_empty():
		push_error("no star3 flower types for active season '%s'" % season_id)
		quit(1)
		return
	var stash: Dictionary = gs.get("garden_crystal_stash")
	for type_id in flower_types:
		stash[str(type_id)] = 20
	gs.set("garden_crystal_stash", stash)
	gs.call("save_player_save")
	print("Granted seeds: clover 19, daisy 22, buttercup 13, tulip 28, sunflower 18")
	print("Granted flowers (season '%s'): %s x20 each" % [season_id, flower_types])
	print("Save: %s/player_save.json" % OS.get_user_data_dir())
	quit(0)
