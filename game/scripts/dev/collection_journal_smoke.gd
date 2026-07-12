extends SceneTree

func _initialize() -> void:
	call_deferred("_test")


func _test() -> void:
	await process_frame
	var err := change_scene_to_file("res://scenes/ui/collection_journal.tscn")
	print("journal load err=", err)
	for i in 5:
		await process_frame
	var journal := current_scene
	print("journal=", journal.name if journal else "null")
	var gs := get_root().get_node_or_null("GameState")
	if gs:
		print("entries=", gs.call("get_collection_journal_entries").size())
	quit(0)
