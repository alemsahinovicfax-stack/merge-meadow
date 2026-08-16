extends Node

## Autoload — mijenja scenu iz UI-a (preživi i kad se trenutni ekran gasi).

const INPUT_BLOCK_MS := 400

var _input_block_until_msec: int = 0


func is_input_blocked() -> bool:
	return Time.get_ticks_msec() < _input_block_until_msec


func change_to(path: String) -> void:
	_input_block_until_msec = Time.get_ticks_msec() + INPUT_BLOCK_MS
	call_deferred("_change_to", path)


func _change_to(path: String) -> void:
	var tree := get_tree()
	if tree == null:
		push_error("SceneRouter: no SceneTree")
		return
	if not ResourceLoader.exists(path):
		push_error("SceneRouter failed: missing scene %s" % path)
		return
	var err := tree.change_scene_to_file(path)
	if err != OK:
		push_error("SceneRouter failed: %s (err %d)" % [path, err])
