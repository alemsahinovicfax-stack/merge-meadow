extends SceneTree

## Dev playtest: postavi run_level u user://player_save.json
## Pokretanje: godot --headless --path game --script res://tools/set_run_level.gd -- 69

const TARGET_LEVEL := 69


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var level := _parse_level_arg()
	var gs: Node = get_root().get_node_or_null("GameState")
	if gs == null:
		push_error("GameState autoload missing")
		quit(1)
		return

	gs.set("tutorial_complete", true)
	gs.set("tutorial_step", 4) # TutorialStep.FREE
	gs.set("run_level", clampi(level, 1, 100))
	gs.call("save_player_save")

	print("Set run_level=%d (tutorial_complete=true)" % int(gs.get("run_level")))
	print("  Endless: main menu → Easy / Normal / Hard")
	print("Save: %s/player_save.json" % OS.get_user_data_dir())
	_print_level_preview(level)
	_print_endless_preview()
	quit()


func _print_endless_preview() -> void:
	var lib: Node = get_root().get_node_or_null("RunLevelLibrary")
	if lib == null:
		return
	for diff in range(3):
		var cfg = lib.call("get_endless_config_for_difficulty", diff)
		var labels := ["Easy", "Normal", "Hard"]
		print(
			"  Endless %s (Lv %d base): %ds, obstacles=%.0f%%, spawn=%.0f%% (×0.9)"
			% [labels[diff], cfg.id, cfg.duration_sec, cfg.obstacle_chance * 100.0, cfg.spawn_chance * 100.0]
		)


func _parse_level_arg() -> int:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		return TARGET_LEVEL
	return int(args[0])


func _print_level_preview(from_level: int) -> void:
	var lib: Node = get_root().get_node_or_null("RunLevelLibrary")
	if lib == null:
		return
	for id in range(from_level, mini(from_level + 4, 101)):
		var cfg = lib.call("get_level", id)
		print(
			"  Lv %d: %ds, obstacles=%.0f%%, spawn=%.0f%%, interval=%.2fs"
			% [
				id,
				cfg.duration_sec,
				cfg.obstacle_chance * 100.0,
				cfg.spawn_chance * 100.0,
				cfg.spawn_interval,
			]
		)
