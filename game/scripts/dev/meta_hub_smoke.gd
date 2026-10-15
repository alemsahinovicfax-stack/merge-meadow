extends SceneTree

## Headless smoke — meta hub loads and arena pest script parses.

var _backup: String = ""


func _initialize() -> void:
	_backup = CampSmokeUtil.backup_save()
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		push_error("meta_hub_smoke: scene load failed %d" % err)
		_quit(1)
		return
	call_deferred("_step")


func _quit(code: int) -> void:
	CampSmokeUtil.restore_save(self, _backup)
	quit(code)


func _step() -> void:
	await process_frame
	await process_frame
	await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		push_error("meta_hub_smoke: no meta_hub group node")
		_quit(1)
		return
	var pest_script := load("res://scripts/camp/arena_pest.gd")
	if pest_script == null:
		push_error("meta_hub_smoke: arena_pest.gd missing")
		_quit(1)
		return
	# Stranice van početne se učitavaju u pozadini kroz BackgroundLoad — ono se sačeka pri
	# izlasku; inače izlaz usred učitavanja Shopa ispiše „Parse Error … shop_screen.tscn" (#39).
	var queued: Dictionary = (load("res://scripts/visual/background_load.gd") as GDScript).get("_paths")
	if not queued.has("res://scenes/ui/shop_screen.tscn"):
		push_error("meta_hub_smoke: hub background pages must go through BackgroundLoad (%s)" % str(queued.keys()))
		_quit(1)
		return
	print("meta_hub_smoke OK")
	_quit(0)
