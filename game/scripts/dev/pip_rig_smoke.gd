extends SceneTree

## design_handoff_pip — rig, atlas, 84 animacije (82 + pickup_seed_rare, pickup_twin iz design_handoff_run_pickups), 4 skina, 5 pogleda (headless).
## Sir Pip (design_handoff_muncher_premium_pip): dodaci samo u knight, zamjena dijelova,
## Godot z ogrtača, reakcije merge_t3 / finish, sloj Skin i idle detalj.
## SceneTree -s: bez golih GameState identifikatora u ovoj skripti.

var _fails: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_fails += 1
	push_error("pip_rig_smoke: %s" % msg)


func sky_shop_map() -> Dictionary:
	return {"#A8E6CF": "#C2E2FA", "#D4F5E4": "#EAF5FE"}


func _check_knight(host: Node2D) -> void:
	var want := {"front": 4, "three_q": 4, "side": 3, "back": 2, "top": 3}
	var atlas: Dictionary = UiPip.atlas_for("knight")
	for view in want:
		var k := UiPip.new()
		k.view = view
		k.follow_equipped = false
		k.skin = "knight"
		host.add_child(k)
		var added := 0
		for id in k.nodes:
			if str(id).begins_with("k_"):
				added += 1
		if added != int(want[view]):
			_fail("knight %s: %d added nodes, expected %d" % [view, added, want[view]])
		if not k.nodes.has("k_cape") or not k.nodes.has("k_helm"):
			_fail("knight %s missing cape / helmet" % view)
		var body := k.sprites.get("tuft") as Sprite2D
		var want_file: String = UiPip.skin_def("knight")["replace"][view]["tuft"]["file"]
		if body == null or (body.texture as AtlasTexture).region != atlas["regions"].get(want_file, Rect2()):
			_fail("knight %s plume should come from %s" % [view, want_file])
		if k.skin_layer == null:
			_fail("knight %s has no Skin player" % view)
		elif k.skin_layer.get_index() > k.body.get_index():
			_fail("knight %s Skin player must process before Body" % view)
		if view == "front":
			var cape := k.nodes["k_cape"] as Node2D
			var tail := k.nodes["tail"] as Node2D
			if cape.z_index != -1 or tail.z_index != -1 or cape.get_index() > tail.get_index():
				_fail("knight front cape must sit above the shadow and under the tail (z %d / %d)" % [cape.z_index, tail.z_index])
			if k._react("merge_t3") != "t3_knight" or k._react("finish") != "goal_knight":
				_fail("knight reactions missing")
			if k._idle_timer == null:
				_fail("knight has no idle detail timer")
			k.set_loop("idle")
			if not k.skin_layer.is_playing() or str(k.skin_layer.current_animation) != "k_cape_idle":
				_fail("cape loop should play while idle")
			k.play("merge_t3")
			if not k.is_playing("t3_knight") or k.skin_layer.is_playing():
				_fail("merge_t3 should play t3_knight and hand the cape to it")
		k.queue_free()
	var classic := UiPip.new()
	classic.view = "front"
	classic.follow_equipped = false
	classic.skin = "classic"
	host.add_child(classic)
	for id in classic.nodes:
		if str(id).begins_with("k_"):
			_fail("classic must not build knight node %s" % id)
	if classic.skin_layer != null or classic._react("merge_t3") != "merge_t3":
		_fail("classic must not get the knight layer or reactions")
	classic.queue_free()


func _run() -> void:
	# Petlje (ogrtač) ne smiju zavisiti od Reduce motion na ovom računaru (greske-katalog #45).
	get_root().get_node("GameState").set("reduce_motion", false)
	var files := [
		"res://data/pip/rig.json",
		"res://data/pip/animations.json",
		"res://data/pip/skins.json",
		"res://data/pip/behaviors.json",
		"res://assets/pip/parts/body_f.svg",
		"res://assets/pip/overlays/ov_sprig.svg",
		"res://assets/pip/fx/petal.svg",
	]
	for p in files:
		if not FileAccess.file_exists(p):
			_fail("missing %s" % p)
	UiPip.data()
	# 77 − pickup_diamond − hud_wow (dijamanti izbačeni 2026-10-09) + 7 Sir Pip klipova.
	if UiPip._anims.size() != 84:
		_fail("expected 84 animations, got %d" % UiPip._anims.size())
	if UiPip._skins.size() != 4:
		_fail("expected 4 skins, got %d" % UiPip._skins.size())
	if UiPip.skin_key_from_cosmetic("pip_knight") != "knight":
		_fail("pip_knight should map to knight")
	if UiPip.skin_key_from_look({"skin": "knight"}) != "knight" or UiPip.skin_key_from_look({"recolor": sky_shop_map()}) != "sky":
		_fail("skin_key_from_look should read skin and recolor looks")
	if UiPip.skin_key_from_cosmetic("pip_blossom") != "blossom":
		_fail("pip_blossom should map to blossom")
	if UiPip.skin_key_from_cosmetic("") != "classic":
		_fail("empty cosmetic should be classic")
	var blossom_shop := {
		"#A8E6CF": "#FFD3DE", "#D4F5E4": "#FFF0F3", "#FFB88C": "#FF94AE",
	}
	var sky_shop := {"#A8E6CF": "#C2E2FA", "#D4F5E4": "#EAF5FE"}
	if UiPip.skin_key_from_recolor(blossom_shop) != "blossom":
		_fail("shop blossom recolor should map to blossom")
	if UiPip.skin_key_from_recolor(sky_shop) != "sky":
		_fail("shop sky recolor should map to sky")
	if UiPip._part_z(42) >= 20 or UiPip._part_z(40) >= UiPip._part_z(42):
		_fail("fx z must stay under the field sheets and above the body")
	for key in ["classic", "blossom", "sky", "knight"]:
		var atlas: Dictionary = UiPip.atlas_for(key)
		var tex: Texture2D = atlas.get("texture") as Texture2D
		if tex == null or tex.get_width() != 1024:
			_fail("%s atlas missing or not 1024 wide" % key)
		if tex != null and tex.get_height() < 200:
			_fail("%s atlas too short (%d)" % [key, tex.get_height()])
	var host := Node2D.new()
	root.add_child(host)
	for view in ["front", "three_q", "side", "back", "top"]:
		var pip := UiPip.new()
		pip.view = view
		pip.box_px = 150.0 if view == "top" else 190.0
		pip.follow_equipped = false
		pip.skin = "classic"
		host.add_child(pip)
		if pip.nodes.is_empty():
			_fail("%s built 0 nodes" % view)
			continue
		if not pip.nodes.has("root") or not pip.nodes.has("pip"):
			_fail("%s missing root/pip" % view)
		pip.set_loop("idle" if view != "top" else "run_gallop")
		if pip.body == null or pip.body.get_animation_list().is_empty():
			_fail("%s AnimationPlayer empty" % view)
		pip.set_skin("blossom")
		if view == "front":
			var sprig: Node2D = pip.nodes.get("ov_sprig") as Node2D
			if sprig == null or not sprig.visible:
				_fail("blossom front should show the ear sprig")
			var tip: Node2D = pip.nodes.get("ov_ctip_l") as Node2D
			if tip != null and tip.visible:
				_fail("blossom should not show sky ear tips")
		pip.queue_free()
	var blossom := UiPip.new()
	blossom.follow_equipped = false
	blossom.skin = "blossom"
	blossom.view = "front"
	blossom.box_px = 190.0
	host.add_child(blossom)
	blossom.play("apply")
	if not blossom.is_playing("apply"):
		_fail("apply did not start")
	_check_knight(host)
	if _fails == 0:
		print("pip_rig_smoke OK")
	else:
		push_error("pip_rig_smoke: %d fail(s)" % _fails)
	quit(_fails)
