extends SceneTree

## Dev: granice crteža Pipa po skinu i pogledu, u px oko ishodišta lika (box_px = 100).
## Koristi se za koliziju u runu (koliko glava viri ispred tijela) i za sličice u ormaru
## (koliko uši / kapa vire iznad okvira). Headless:
##   godot --headless --path game -s scripts/dev/pip_bounds_probe.gd


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	UiPip.data()
	var keys: Array = ["classic"]
	for it in CosmeticCatalog.items_in_slot(CosmeticCatalog.SLOT_PIP_SKIN):
		var k := UiPip.skin_key_from_look(it.get("look", {}))
		if not keys.has(k):
			keys.append(k)
	for view in ["top", "three_q"]:
		for key in keys:
			while not UiPip.atlas_ready(key):
				UiPip.request_atlas(key)
				await process_frame
			var a := UiPip.new()
			a.view = view
			a.skin = key
			a.box_px = 100.0
			a.follow_equipped = false
			get_root().add_child(a)
			await process_frame
			if view == "three_q":
				a.pose(UiPip.pose_for_skin(key))
			await process_frame
			var all := Rect2()
			var first := true
			var lines: PackedStringArray = []
			for id in a.sprites:
				var s := a.sprites[id] as Sprite2D
				if s == null or s.texture == null or not s.is_visible_in_tree():
					continue
				var r := s.get_global_transform() * s.get_rect()
				r = a.get_global_transform().affine_inverse() * r
				# Rect je u prostoru čvora `a` prije njegove skale → pomnoži skalom na px.
				r = Rect2(r.position * a.scale, r.size * a.scale)
				lines.append("    %-14s x %6.1f..%6.1f  y %6.1f..%6.1f" % [id, r.position.x, r.end.x, r.position.y, r.end.y])
				all = r if first else all.merge(r)
				first = false
			print("BOUNDS %s %s  x %.1f..%.1f  y %.1f..%.1f (box 100)" % [view, key, all.position.x, all.end.x, all.position.y, all.end.y])
			if OS.get_environment("MM_PARTS") == "1":
				for l in lines:
					print(l)
			a.queue_free()
	print("pip_bounds_probe OK")
	quit(0)
