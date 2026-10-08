class_name UiPip
extends Node2D
## Pip cutout rig (design_handoff_pip). One scene for every surface: field, season card, Arena,
## run (top view), run HUD, Shop, Wardrobe. Built from data at runtime:
##   rig.json        — views → nodes (parent, rest pos/rot/scale, z, sprite / swap frames / overlay)
##   animations.json — tracks per node (deltas from rest), Godot key transitions, events, reduce_motion
##   skins.json      — 7 tokens per skin (classic hex → skin hex recolor) + overlays
## Performance (§6): parts are rasterised ONCE per (skin, raster) into a single atlas ≤ 1024×1024;
## per frame only Node2D transforms / modulate / visible / AtlasTexture swaps change. No _draw().
## Two AnimationPlayers on disjoint channels: Body (base, at most one loop) + Overlay (one-shots on
## pip.rotation / pip.scale / pip.position / head.rotation / swaps / fx). Look-at is additive in _process.

signal pip_event(name: String, arg: Variant)

const DATA_DIR := "res://data/pip/"
const ASSET_DIR := "res://assets/pip/"
const RASTER := 2.0                  ## atlas: 1024 × 802 px worst skin at 2× (pip_export.json)
const ATLAS_W := 1024
const FRAME := {"front": 256.0, "three_q": 256.0, "side": 256.0, "back": 256.0, "top": 150.0}

@export var view: String = "front"
@export var skin: String = "classic"
@export var box_px: float = 190.0      ## 230 card · 190 field · 150 Arena · 150 run · 88 HUD (crop)
@export var still: bool = false         ## Shop list: pose only, no loop

static var _rig: Dictionary = {}
static var _anims: Dictionary = {}
static var _skins: Dictionary = {}
static var _atlas: Dictionary = {}      ## skin → {texture, regions{file: Rect2}}
static var _libs: Dictionary = {}       ## "view|rm" → AnimationLibrary

var nodes: Dictionary = {}               ## id → Node2D
var sprites: Dictionary = {}             ## id → Sprite2D
var body: AnimationPlayer
var overlay: AnimationPlayer
var loop_id: String = ""
var look_target: Variant = null
var _look := Vector3.ZERO                ## (head rot deg, eye dx, eye dy)

static func reduce_motion() -> bool:
	return bool(GameState.get("reduce_motion")) if GameState else false

static func _load(name: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(DATA_DIR + name))

static func data() -> void:
	if _rig.is_empty():
		_rig = _load("rig.json")
		_anims = {}
		for a in (_load("animations.json") as Dictionary)["list"]:
			_anims[a["id"]] = a
		for s in (_load("skins.json") as Dictionary)["skins"]:
			_skins[s["key"]] = s

func _ready() -> void:
	data()
	build()
	if GameState and not GameState.cosmetics_changed.is_connected(_on_cosmetics):
		GameState.cosmetics_changed.connect(_on_cosmetics)

func _on_cosmetics(_slots: Array) -> void:
	set_skin(equipped_skin_key())

static func equipped_skin_key() -> String:
	var id := PipAssets.equipped_skin()
	for k in _skins:
		if str(_skins[k]["cosmetic_id"]) == id:
			return k
	return "classic"

# ── atlas (one per skin) ──────────────────────────────────────────────────────
static func atlas_for(key: String) -> Dictionary:
	if _atlas.has(key):
		return _atlas[key]
	var sk: Dictionary = _skins.get(key, _skins["classic"])
	var recolor: Dictionary = sk["recolor"]
	var files: Array[String] = []
	for v in _rig["views"]:
		for n in _rig["views"][v]["nodes"]:
			if n.has("sprite") and n["sprite"] is Dictionary:
				if n.has("overlay") and not _has_overlay(sk, str(n["overlay"])):
					continue
				files.append(str(n["sprite"]["file"]))
			if n.has("frames"):
				for f in n["frames"]:
					files.append(str(n["frames"][f]["file"]))
	for f in _rig["fx_frames"]:
		files.append(str(_rig["fx_frames"][f]["file"]))
	var uniq := {}
	for f in files:
		uniq[f] = true
	var imgs := {}
	for f in uniq:
		var img := Image.new()
		var svg := PipAssets.recolor_svg(FileAccess.get_file_as_string(f), recolor)
		if img.load_svg_from_string(svg, RASTER) == OK:
			imgs[f] = img
	# shelf pack, tallest first
	var order: Array = imgs.keys()
	order.sort_custom(func(a, b): return imgs[a].get_height() > imgs[b].get_height())
	var x := 0
	var y := 0
	var row := 0
	var regions := {}
	for f in order:
		var im: Image = imgs[f]
		if x + im.get_width() + 2 > ATLAS_W:
			x = 0; y += row; row = 0
		regions[f] = Rect2(x, y, im.get_width(), im.get_height())
		x += im.get_width() + 2
		row = maxi(row, im.get_height() + 2)
	var atlas := Image.create(ATLAS_W, nearest_po2(y + row), false, Image.FORMAT_RGBA8)
	for f in regions:
		atlas.blit_rect(imgs[f], Rect2i(Vector2i.ZERO, imgs[f].get_size()), Vector2i(regions[f].position))
	var tex := ImageTexture.create_from_image(atlas)
	var out := {"texture": tex, "regions": regions, "subs": {}}
	_atlas[key] = out
	return out

static func _has_overlay(sk: Dictionary, id: String) -> bool:
	for o in sk["overlays"]:
		if str(o["id"]) == id:
			return true
	return false

static func sub(key: String, sprite: Dictionary) -> AtlasTexture:
	var a := atlas_for(key)
	var f := str(sprite["file"])
	if a["subs"].has(f):
		return a["subs"][f]
	var t := AtlasTexture.new()
	t.atlas = a["texture"]
	t.region = a["regions"].get(f, Rect2())
	a["subs"][f] = t
	return t

# ── tree ──────────────────────────────────────────────────────────────────────
func build() -> void:
	for c in get_children():
		c.queue_free()
	nodes.clear(); sprites.clear()
	var v: Dictionary = _rig["views"][view]
	var k := box_px / float(FRAME[view])
	scale = Vector2(k, k)
	var sk: Dictionary = _skins.get(skin, _skins["classic"])
	for n in v["nodes"]:
		if n.has("overlay") and not _has_overlay(sk, str(n["overlay"])):
			continue
		var nd := Node2D.new()
		nd.name = str(n["id"])
		nd.position = Vector2(n["pos"][0], n["pos"][1])
		nd.rotation_degrees = float(n["rot_deg"])
		nd.scale = Vector2(n["scale"][0], n["scale"][1])
		nd.z_index = int(n["z"])
		nd.z_as_relative = true
		nd.visible = bool(n.get("visible", true))
		nd.set_meta("rest", [nd.position, nd.rotation_degrees, nd.scale])
		var parent: Node = self if n["parent"] == null else nodes[str(n["parent"])]
		parent.add_child(nd)
		nodes[nd.name] = nd
		var spr_data: Variant = null
		if n.has("frames"):
			spr_data = n["frames"][str(n["default_frame"])]
		elif n.get("sprite") is Dictionary:
			spr_data = n["sprite"]
		if spr_data != null or str(n.get("sprite", "")) == "fx":
			var s := Sprite2D.new()
			s.centered = false
			if spr_data != null:
				s.texture = sub(skin, spr_data)
				s.offset = Vector2(spr_data["offset"][0], spr_data["offset"][1]) * RASTER
			s.scale = Vector2.ONE / RASTER
			nd.add_child(s)
			sprites[nd.name] = s
	body = AnimationPlayer.new(); body.name = "Body"; add_child(body)
	overlay = AnimationPlayer.new(); overlay.name = "Overlay"; add_child(overlay)
	var lib := library(view, reduce_motion())
	body.add_animation_library("", lib)
	overlay.add_animation_library("", lib)
	body.animation_finished.connect(_on_body_done)
	set_process(false)

func set_skin(key: String) -> void:
	if key == skin:
		return
	skin = key
	var cur := body.current_animation
	build()
	if not cur.is_empty():
		play(cur)

## Swap frame (eye / brow / mouth / fx): called from discrete method tracks.
func set_frame(id: String, frame: String) -> void:
	if not sprites.has(id):
		return
	var src: Dictionary = {}
	for n in _rig["views"][view]["nodes"]:
		if str(n["id"]) == id:
			src = n["frames"][frame] if n.has("frames") else _rig["fx_frames"].get(frame, {})
			break
	if src.is_empty():
		return
	var s: Sprite2D = sprites[id]
	s.texture = sub(skin, src)
	s.offset = Vector2(src["offset"][0], src["offset"][1]) * RASTER

func emit_event(name: String, arg: Variant) -> void:
	pip_event.emit(name, arg)

# ── animation library from animations.json (deltas → absolute per view) ───────
func library(v: String, rm: bool) -> AnimationLibrary:
	var key := v + "|" + str(rm)
	if _libs.has(key):
		return _libs[key]
	var lib := AnimationLibrary.new()
	for id in _anims:
		lib.add_animation(id, _to_animation(_anims[id], rm))
	_libs[key] = lib
	return lib

func _to_animation(a: Dictionary, rm: bool) -> Animation:
	var an := Animation.new()
	an.length = maxf(0.01, float(a["length"]))
	an.loop_mode = Animation.LOOP_LINEAR if bool(a["loop"]) else Animation.LOOP_NONE
	var r: Dictionary = a["reduce_motion"]
	var mode := str(r.get("type", "damp")) if rm else ""
	var k := float(r.get("k", 0.3))
	var keep: Array = r.get("keep", [])
	for tr in a["tracks"]:
		var id := str(tr["node"])
		if not nodes.has(id):
			continue
		var prop := str(tr["prop"])
		var is_fx := id.begins_with("fx_") or id.begins_with("prop") or id == "emote"
		if rm and is_fx and not bool(r.get("fx", false)):
			continue
		if mode == "expr" and prop != "frame":
			continue
		var kk := 1.0 if keep.has(id) or mode != "damp" else k
		var rest: Array = nodes[id].get_meta("rest")
		if prop == "frame":
			var t := an.add_track(Animation.TYPE_METHOD)
			an.track_set_path(t, NodePath("."))
			for key in tr["keys"]:
				an.track_insert_key(t, float(key[0]), {"method": "set_frame", "args": [id, str(key[1])]})
			continue
		var t2 := an.add_track(Animation.TYPE_VALUE)
		an.track_set_path(t2, NodePath(str(get_path_to(nodes[id])) + ":" + prop))
		var discrete := prop == "visible"
		an.value_track_set_update_mode(t2, Animation.UPDATE_DISCRETE if discrete else Animation.UPDATE_CONTINUOUS)
		for key in tr["keys"]:
			var tt := float(key[0])
			var val: Variant
			var trans := 1.0
			match prop:
				"position":
					val = rest[0] + Vector2(key[1], key[2]) * kk
					trans = float(key[3]) if key.size() > 3 else -2.0
				"scale":
					val = rest[2] * (Vector2.ONE + (Vector2(key[1], key[2]) - Vector2.ONE) * kk)
					trans = float(key[3]) if key.size() > 3 else -2.0
				"rotation_degrees":
					val = rest[1] + float(key[1]) * kk
					trans = float(key[2]) if key.size() > 2 else -2.0
				"modulate:a":
					val = float(key[1])
					trans = float(key[2]) if key.size() > 2 else -2.0
				"visible":
					val = float(key[1]) > 0.5
			an.track_insert_key(t2, tt, val, trans)
	if mode != "expr":
		for ev in a["events"]:
			var te := an.add_track(Animation.TYPE_METHOD)
			an.track_set_path(te, NodePath("."))
			an.track_insert_key(te, float(ev["t"]), {"method": "emit_event", "args": [ev["name"], ev["arg"]]})
	return an

# ── API ───────────────────────────────────────────────────────────────────────
func play(id: String) -> void:
	if not _anims.has(id):
		return
	var a: Dictionary = _anims[id]
	var rm := reduce_motion()
	if rm and str(a["reduce_motion"].get("type", "")) == "skip":
		return
	if str(a["layer"]) == "overlay":
		overlay.stop(); overlay.play(id)
	else:
		if bool(a["loop"]):
			loop_id = id
		body.play(id)
		if rm and str(a["reduce_motion"].get("type", "")) == "end":
			body.seek(float(a["length"]), true)
	if still:
		body.pause()

func set_loop(id: String) -> void:
	loop_id = id
	play(id)

func pose(id: String) -> void:  ## Shop / thumbnails: last frame, no ticking
	body.play(id); body.seek(float(_anims[id]["length"]), true); body.pause()

func _on_body_done(id: StringName) -> void:
	if bool(_anims[str(id)].get("hold_last", false)):
		return
	if not loop_id.is_empty() and not still:
		body.play(loop_id)

## Run: AnimationPlayer speed follows the world (stride 96 px per 0.24 s at 400 px/s).
func set_scroll_speed(px_s: float) -> void:
	body.speed_scale = px_s / 400.0

## Arena: Pip follows the dragged seed (head ±7°, eyes ±3.5 / ±3 px). null = release.
func look_at_point(p: Variant) -> void:
	look_target = p
	set_process(true)

func _process(delta: float) -> void:
	var want := Vector3.ZERO
	if look_target is Vector2 and nodes.has("head"):
		var d: Vector2 = nodes["head"].to_local(look_target)
		want = Vector3(clampf(d.x * 0.05, -7, 7), clampf(d.x * 0.03, -3.5, 3.5), clampf(d.y * 0.03, -3, 3))
	_look = _look.lerp(want, minf(1.0, delta * 9.0))
	nodes["head"].rotation_degrees = nodes["head"].get_meta("rest")[1] + _look.x
	for e in ["eye_L", "eye_R"]:
		if nodes.has(e):
			nodes[e].position = nodes[e].get_meta("rest")[0] + Vector2(_look.y, _look.z)
	if look_target == null and _look.length() < 0.01:
		set_process(false)
