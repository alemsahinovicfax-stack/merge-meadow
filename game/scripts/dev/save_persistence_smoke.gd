extends SceneTree

## F1 — Save round-trip: wallet + bag perzistencija.


const SAVE_PATH := "user://player_save.json"


func _gs() -> Node:
	return get_root().get_node("GameState")


func _initialize() -> void:
	call_deferred("_step")


func _step() -> void:
	await process_frame
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := _gs()
	gs.set("wallet_coins", 42)
	gs.set("seed_bag", {"clover": 3, "daisy": 1})
	gs.set("magnet_level", 2)
	gs.call("save_player_save")
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("save_persistence_smoke: save file missing")
		quit(1)
		return
	gs.set("wallet_coins", 0)
	gs.set("seed_bag", {})
	gs.set("magnet_level", 0)
	gs.call("load_player_save")
	if int(gs.get("wallet_coins")) != 42:
		push_error("save_persistence_smoke: wallet=%s expected 42" % str(gs.get("wallet_coins")))
		quit(1)
		return
	var bag: Dictionary = gs.get("seed_bag")
	if int(bag.get("clover", 0)) != 3:
		push_error("save_persistence_smoke: bag clover wrong")
		quit(1)
		return
	if int(gs.get("magnet_level")) != 2:
		push_error("save_persistence_smoke: magnet wrong")
		quit(1)
		return
	print("save_persistence_smoke OK")
	quit(0)
