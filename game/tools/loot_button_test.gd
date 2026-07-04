extends Node

const LOG := "C:/Users/Alem/Desktop/Mobilna igra/game/loot_debug.txt"


func _ready() -> void:
	await get_tree().process_frame
	GameState.finish_run({"clover": 2}, 5, false, 18.0)
	var loot: Control = (load(GameState.SCENE_LOOT) as PackedScene).instantiate()
	add_child(loot)
	await get_tree().process_frame
	var retry: UiClickButton = loot.get_node("Panel/VBox/RetryButton") as UiClickButton
	var status: Label = loot.get_node("Panel/VBox/StatusLabel") as Label
	var log := FileAccess.open(LOG, FileAccess.WRITE)
	log.store_line("clicked_conn=%d" % retry.clicked.get_connections().size())
	# Simuliraj pravi miš klik (kao desktop)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = retry.global_position + retry.size * 0.5
	retry._gui_input(click)
	await get_tree().process_frame
	log.store_line("after_mouse_click status=%s" % status.text)
	retry.clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	log.store_line("after_emit scene=%s" % get_tree().current_scene.name)
	log.close()
	get_tree().quit()
