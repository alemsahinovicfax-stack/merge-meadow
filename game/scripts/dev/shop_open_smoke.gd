extends SceneTree

## Smoke: load shop once (autoloads via project.godot). HOME-05 C: 2-col pack grid, 4 packs, no Select theme.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/ui/shop_screen.tscn")
	if err != OK:
		push_error("shop_open_smoke: shop failed %d" % err)
		quit(1)
		return
	for _i in 16:
		await process_frame
	var shop := current_scene
	if shop == null:
		push_error("shop_open_smoke: current_scene missing")
		quit(1)
		return
	var grid := shop.get_node_or_null("%SeasonPacksGrid")
	if grid == null:
		grid = shop.find_child("SeasonPacksGrid", true, false)
	if grid == null or not (grid is GridContainer):
		push_error("shop_open_smoke: SeasonPacksGrid missing or not GridContainer")
		quit(1)
		return
	if (grid as GridContainer).columns != 2:
		push_error("shop_open_smoke: grid columns != 2")
		quit(1)
		return
	if grid.get_child_count() != 4:
		push_error("shop_open_smoke: expected 4 pack cards, got %d" % grid.get_child_count())
		quit(1)
		return
	for child in grid.get_children():
		var pack_label := str(child.get("label_text"))
		if pack_label.contains("Select theme") or pack_label.contains("Selected"):
			push_error("shop_open_smoke: pack card still has Select copy")
			quit(1)
			return
	print("shop_open_smoke OK")
	quit(0)
