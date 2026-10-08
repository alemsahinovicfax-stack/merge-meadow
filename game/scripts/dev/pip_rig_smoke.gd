extends SceneTree

## design_handoff_pip — rig, atlas, 77 animacija, 3 skina, 5 pogleda (headless).
## SceneTree -s: bez golih GameState identifikatora u ovoj skripti.

var _fails: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	_fails += 1
	push_error("pip_rig_smoke: %s" % msg)


func _run() -> void:
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
	if UiPip._anims.size() != 77:
		_fail("expected 77 animations, got %d" % UiPip._anims.size())
	if UiPip._skins.size() != 3:
		_fail("expected 3 skins, got %d" % UiPip._skins.size())
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
	for key in ["classic", "blossom", "sky"]:
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
	if _fails == 0:
		print("pip_rig_smoke OK")
	else:
		push_error("pip_rig_smoke: %d fail(s)" % _fails)
	quit(_fails)
