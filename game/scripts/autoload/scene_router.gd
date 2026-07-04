extends Node

## Autoload — mijenja scenu iz UI-a (preživi i kad se trenutni ekran gasi).


func change_to(path: String) -> void:
	call_deferred("_change_to", path)


func _change_to(path: String) -> void:
	var tree := get_tree()
	if tree == null:
		push_error("SceneRouter: no SceneTree")
		return
	var err := tree.change_scene_to_file(path)
	if err != OK:
		push_error("SceneRouter failed: %s (err %d)" % [path, err])
