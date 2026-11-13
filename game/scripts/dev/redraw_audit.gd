extends SceneTree

## Alat (FIX-TEL-3 2026-11-12): koji se čvorovi crtaju U SVAKOM FREJMU? Control koji mijenja
## rotation / scale / pivot sam sebi zove queue_redraw — skup `_draw` tada radi stalno (korpa u
## Areni, katalog #74). Alat prođe stranice huba, na svakoj broji `draw` po čvoru kroz 120
## frejmova i ispiše one koji se crtaju u više od četvrtine frejmova.
##   godot --headless --path game -s res://scripts/dev/redraw_audit.gd
## Arena se mjeri tri puta: prazna, sa sjemenkama na polju i dok igrač vuče sjemenku.

const FRAMES := 120
const PAGES := {0: "Shop", 1: "Journal", 2: "Home", 3: "Camp", 4: "Arena"}

var _counts: Dictionary = {}
var _hooked: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _hook(node: Node) -> void:
	if node is CanvasItem and not _hooked.has(node.get_instance_id()):
		_hooked[node.get_instance_id()] = true
		var id := node.get_instance_id()
		(node as CanvasItem).draw.connect(func() -> void: _counts[id] = int(_counts.get(id, 0)) + 1)
	for c in node.get_children():
		_hook(c)


func _measure(label: String, scope: Node) -> void:
	_hook(scope)
	for _i in 10:
		await process_frame
	_counts.clear()
	for _i in FRAMES:
		await process_frame
	var rows: Array = []
	for id in _counts:
		var n := int(_counts[id])
		if n < FRAMES / 4:
			continue
		var node := instance_from_id(id) as Node
		if node == null or not is_instance_valid(node):
			continue
		var script: Script = node.get_script()
		rows.append([n, str(scope.get_path_to(node)), node.get_class(), script.resource_path.get_file() if script != null else ""])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
	print("== %s: %d nodes redrawn in > 25 %% of %d frames" % [label, rows.size(), FRAMES])
	for r in rows.slice(0, 25):
		print("   %4d  %-70s %s %s" % [r[0], str(r[1]).right(70), r[2], r[3]])


func _run() -> void:
	var gs := get_root().get_node("GameState")
	gs.set("tutorial_complete", true)
	gs.set("reduce_motion", false)
	gs.set("seed_bag", {"clover": 60, "daisy": 60, "buttercup": 60, "tulip": 40})
	change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	await create_timer(4.0).timeout
	var hub: Node = current_scene
	var host: Node = hub.get_node("RootVBox/SwipePager").call("get_pages_host")
	for idx in PAGES:
		hub.call("go_to_page", idx, false)
		await create_timer(2.0).timeout
		var page: Node = host.get_node_or_null("Page_%d" % idx)
		if page == null:
			print("== %s: page not loaded" % PAGES[idx])
			continue
		await _measure(str(PAGES[idx]), page)
		if idx == 2:
			var stage: Node = page.get_node_or_null("%SeasonStage")
			if stage != null and bool(stage.call("open_season_field", str(gs.get("active_season_id")), false)):
				await create_timer(1.0).timeout
				await _measure("Home · field open", page)
				if bool(stage.call("open_level_path", false)):
					await create_timer(1.0).timeout
					await _measure("Home · level path", page)
		if idx == 4:
			page.call("_on_bag_clicked")
			await create_timer(2.5).timeout
			await _measure("Arena · 30 chips resting", page)
			var chips: Array = page.get("_chips")
			if not chips.is_empty():
				chips[0].call("_begin_drag", Vector2(40, 40))
				await _measure("Arena · dragging a chip", page)
				chips[0].call("_end_drag")
	await _measure("Hub chrome (whole hub, Arena page)", hub)
	print("redraw_audit done")
	quit(0)
