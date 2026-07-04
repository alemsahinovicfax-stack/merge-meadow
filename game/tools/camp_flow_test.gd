extends SceneTree


func _initialize() -> void:
	var log := FileAccess.open("user://camp_flow_log.txt", FileAccess.WRITE)
	log.store_line("start")
	log.close()
	call_deferred("_test")


func _test() -> void:
	await process_frame
	GameState.finish_run({"clover": 3}, 5, false, 18.0)
	GameState.deposit_loot_to_camp()
	change_scene_to_file(GameState.SCENE_CAMP)
	await process_frame
	await process_frame
	await process_frame

	var camp := current_scene
	var seed_lbl: Label = camp.get_node("GardenLayer/VBox/SeedBagLabel")
	var play: UiClickButton = camp.get_node("GardenLayer/VBox/PlayButton")
	var log := FileAccess.open("res://tools/camp_flow_log.txt", FileAccess.WRITE)
	log.store_line("seed_label=" + seed_lbl.text)
	log.store_line("seed_bag=" + str(GameState.seed_bag))
	log.store_line("play_conns=" + str(play.get_signal_connection_list("clicked").size()))
	play.clicked.emit()
	await process_frame
	await process_frame
	log.store_line("after_play=" + str(current_scene.scene_file_path if current_scene else "null"))
	log.close()
	quit(0)
