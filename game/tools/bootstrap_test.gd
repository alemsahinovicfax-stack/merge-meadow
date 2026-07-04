extends Node


func _ready() -> void:
	var root := get_tree().root
	print("root children:")
	for child in root.get_children():
		print(" - ", child.name, " (", child.get_class(), ")")
	print("has GameState node=", root.has_node("GameState"))
	print("Engine singleton GameState=", typeof(GameState) if "GameState" in root else "n/a")
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	await get_tree().process_frame
	await get_tree().process_frame
	var menu := get_tree().current_scene
	print("current=", menu.name if menu else "null")
	if menu:
		var btn := menu.get_node_or_null("Panel/VBox/PlayButton") as Button
		if btn:
			print("connections=", btn.pressed.get_connections().size())
			btn.pressed.emit()
			await get_tree().process_frame
			await get_tree().process_frame
			print("after emit=", get_tree().current_scene.scene_file_path)
	get_tree().quit()
