extends Node

## Autoload — sigurno izvršavanje UI klikova (debounce, validacija scene).

const DEBOUNCE_MS := 350

var _last_action_msec: Dictionary = {}


func validate_scene_path(path: String) -> bool:
	return not path.is_empty() and ResourceLoader.exists(path)


func probe_packed_scene(path: String) -> bool:
	if not validate_scene_path(path):
		return false
	var packed := load(path) as PackedScene
	return packed != null


func safe_change_scene(path: String, source: String = "") -> void:
	if SceneRouter.is_input_blocked():
		return
	if not validate_scene_path(path):
		push_error("UiClickGuard: missing scene %s (%s)" % [path, source])
		return
	if not probe_packed_scene(path):
		push_error("UiClickGuard: cannot load scene %s (%s)" % [path, source])
		return
	SceneRouter.change_to(path)


func safe_invoke(action_id: String, handler: Callable) -> void:
	var key := action_id if not action_id.is_empty() else "anonymous"
	var now := Time.get_ticks_msec()
	var last := int(_last_action_msec.get(key, 0))
	if now - last < DEBOUNCE_MS:
		return
	_last_action_msec[key] = now
	if not handler.is_valid():
		push_error("UiClickGuard: invalid handler for %s" % key)
		return
	call_deferred("_run_handler", key, handler)


func wire_button(button: Node, action_id: String, handler: Callable) -> void:
	if button == null or not button.has_signal("clicked"):
		return
	button.set("click_action_id", action_id)
	button.set("guarded_click", true)
	if button.has_meta("_click_guard_wired"):
		return
	button.set_meta("_click_guard_wired", true)
	button.clicked.connect(func() -> void:
		safe_invoke(action_id, handler)
	)


func validate_button_exports(button: Node) -> PackedStringArray:
	var issues: PackedStringArray = []
	if button == null:
		return issues
	var nav_scene: String = button.get("navigation_scene") if "navigation_scene" in button else ""
	var action_id: String = button.get("click_action_id") if "click_action_id" in button else ""
	var guarded: bool = button.get("guarded_click") if "guarded_click" in button else false
	if not nav_scene.is_empty() and not validate_scene_path(nav_scene):
		issues.append("navigation_scene missing: %s" % nav_scene)
	if guarded and action_id.is_empty() and nav_scene.is_empty():
		issues.append("set click_action_id or navigation_scene for guarded button")
	return issues


func _run_handler(_action_id: String, handler: Callable) -> void:
	if not handler.is_valid():
		return
	if not is_inside_tree() or get_tree() == null:
		return
	handler.call()
