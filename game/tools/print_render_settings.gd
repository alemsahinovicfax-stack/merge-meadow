extends SceneTree


func _initialize() -> void:
	print(
		"rendering_method=",
		ProjectSettings.get_setting("rendering/renderer/rendering_method")
	)
	print(
		"rendering_method.mobile=",
		ProjectSettings.get_setting("rendering/renderer/rendering_method.mobile")
	)
	print(
		"driver.android=",
		ProjectSettings.get_setting("rendering/rendering_device/driver.android")
	)
	quit()
