extends SceneTree

## Integracija — loot → meta hub camp page (ažurirano za meta hub model).


func _initialize() -> void:
	call_deferred("_test")


func _test() -> void:
	await process_frame
	GameState.finish_run({"clover": 3}, 5, false, 18.0)
	GameState.go_to_camp_hub()
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await process_frame
	await process_frame
	await process_frame
	var log := FileAccess.open("res://tools/camp_flow_log.txt", FileAccess.WRITE)
	log.store_line("scene=" + str(current_scene.scene_file_path if current_scene else "null"))
	log.store_line("wallet=" + str(GameState.wallet_coins))
	log.store_line("bag=" + str(GameState.seed_bag))
	log.close()
	quit(0)
