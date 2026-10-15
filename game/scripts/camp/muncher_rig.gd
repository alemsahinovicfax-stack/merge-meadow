extends Node2D
class_name MuncherRig

## Nibbs, seed-mole (design_handoff_muncher_premium_pip · A) — cutout rig munchera u Areni.
## Tri pogleda (front ↓, back ↑, side →; ← = scale.x −1 na pogledu), vidljiv je samo jedan.
## Root riga = ArenaPest._pest_center = centar jedenja = usta. Podaci: data/muncher/rig.json i
## animations.json (isti format kao Pip: delte od odmora, ključ [t, vrijednost…, prelaz]).
## Atlas (46 SVG, @1,5×) se rasterizuje jednom u WorkerThreadPool; po frejmu samo transformi.
## Body = klip stanja; Overlay = „sjemenka pobjegla" (m_escaped_*) preko lova.

const DATA_DIR := "res://data/muncher/"
const RASTER := 1.5
const ATLAS_W := 1024
const VIEWS: Array[String] = ["front", "side", "back"]
## Rig z (−50 … 40) → Godot z −4 … 9: pest je na z 45 polja, a oblačić tutoriala na 56.
const Z_MAP := {-50: -4, -8: -3, -2: -2, -1: -1, 30: 7, 35: 8, 40: 9}

static var _rig: Dictionary = {}
static var _anims: Dictionary = {}
static var _atlas: Dictionary = {}
static var _job: Dictionary = {}
static var _libs: Dictionary = {}

var view: String = "front"
var flip: bool = false
var body: AnimationPlayer
var overlay: AnimationPlayer
var clip: String = ""
var _views: Dictionary = {}
var _nodes: Dictionary = {}
var _sprites: Dictionary = {}
var _subs: Dictionary = {}
var _built: bool = false


static func data() -> void:
	if not _rig.is_empty():
		return
	var rig_raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_DIR + "rig.json"))
	_rig = rig_raw if rig_raw is Dictionary else {}
	var anim_raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_DIR + "animations.json"))
	if anim_raw is Dictionary:
		for a in (anim_raw as Dictionary).get("list", []):
			if a is Dictionary:
				_anims[str(a["id"])] = a
	if _rig.is_empty() or _anims.is_empty():
		push_error("MuncherRig: missing data in %s" % DATA_DIR)


static func rig_data() -> Dictionary:
	data()
	return _rig


static func has_anim(id: String) -> bool:
	data()
	return _anims.has(id)


static func anim_length(id: String) -> float:
	data()
	return float(_anims.get(id, {}).get("length", 0.0))


## Atlas u pozadini (kao UiPip.request_atlas): Arena ga traži čim se napravi.
static func request_atlas() -> void:
	data()
	if not _atlas.is_empty() or not _job.is_empty():
		return
	var job := {}
	job["task"] = WorkerThreadPool.add_task(func() -> void: job["raster"] = _raster())
	_job = job
	var loop := Engine.get_main_loop() as SceneTree
	if loop != null and loop.root != null and not loop.root.tree_exiting.is_connected(_drain_job):
		loop.root.tree_exiting.connect(_drain_job)


static func atlas_ready() -> bool:
	if not _atlas.is_empty():
		return true
	if _job.is_empty():
		request_atlas()
		return false
	if not WorkerThreadPool.is_task_completed(int(_job["task"])):
		return false
	_finish_job()
	return true


## Sinhrono (testovi / kad Arena treba odmah).
static func atlas() -> Dictionary:
	data()
	if _atlas.is_empty():
		if _job.is_empty():
			_atlas = _atlas_from(_raster())
		else:
			_finish_job()
	return _atlas


static func _drain_job() -> void:
	if not _job.is_empty():
		WorkerThreadPool.wait_for_task_completion(int(_job["task"]))
		_job = {}


static func _finish_job() -> void:
	WorkerThreadPool.wait_for_task_completion(int(_job["task"]))
	_atlas = _atlas_from(_job["raster"])
	_job = {}


static func _atlas_from(raster: Dictionary) -> Dictionary:
	return {"texture": ImageTexture.create_from_image(raster["image"]), "regions": raster["regions"]}


## Samo Image / string operacije — sigurno van glavnog threada.
static func _raster() -> Dictionary:
	var files: Dictionary = {}
	for v in _rig.get("views", {}):
		for n in _rig["views"][v]["nodes"]:
			if n.get("sprite") is Dictionary:
				files[str(n["sprite"]["file"])] = true
			for f in n.get("frames", {}):
				files[str(n["frames"][f]["file"])] = true
	for f in _rig.get("fx_frames", {}):
		files[str(_rig["fx_frames"][f]["file"])] = true
	for n in _rig.get("nest", {}).get("nodes", []):
		files[str(n["sprite"]["file"])] = true
	if _rig.get("banner") is Dictionary:
		files[str(_rig["banner"]["file"])] = true
	var imgs: Dictionary = {}
	for f in files:
		var svg := FileAccess.get_file_as_string(str(f))
		var img := Image.new()
		if not svg.is_empty() and img.load_svg_from_string(svg, RASTER) == OK and not img.is_empty():
			imgs[f] = img
	var order: Array = imgs.keys()
	order.sort_custom(func(a, b): return imgs[a].get_height() > imgs[b].get_height())
	var x := 0
	var y := 0
	var row := 0
	var regions: Dictionary = {}
	for f in order:
		var im: Image = imgs[f]
		if x + im.get_width() + 2 > ATLAS_W:
			x = 0
			y += row
			row = 0
		regions[f] = Rect2(x, y, im.get_width(), im.get_height())
		x += im.get_width() + 2
		row = maxi(row, im.get_height() + 2)
	# GLES3 drži NPOT teksture: visina bez zaokruživanja na 2^n (1024 × ~850 umjesto 1024²).
	var atlas_img := Image.create(ATLAS_W, maxi(4, (y + row + 3) / 4 * 4), false, Image.FORMAT_RGBA8)
	atlas_img.fill(Color(0, 0, 0, 0))
	for f in regions:
		atlas_img.blit_rect(imgs[f], Rect2i(Vector2i.ZERO, imgs[f].get_size()), Vector2i(regions[f].position))
	return {"image": atlas_img, "regions": regions}


## Sprite iz atlasa (offset u game px, tekstura @1,5× pa skala 1/1,5).
static func make_sprite(sprite: Dictionary) -> Sprite2D:
	var s := Sprite2D.new()
	s.centered = false
	_apply_sprite(s, sprite)
	s.scale = Vector2.ONE / RASTER
	return s


static func _apply_sprite(s: Sprite2D, sprite: Dictionary) -> void:
	var a := atlas()
	var t := AtlasTexture.new()
	t.atlas = a["texture"]
	t.region = a["regions"].get(str(sprite["file"]), Rect2())
	s.texture = t
	var off: Array = sprite["offset"]
	s.offset = Vector2(float(off[0]), float(off[1])) * RASTER


static func _z(rig_z: int) -> int:
	return int(Z_MAP.get(rig_z, clampi(rig_z, -1, 6)))


func _ready() -> void:
	build()


func is_built() -> bool:
	return _built


func build() -> void:
	data()
	if _built:
		return
	for v in VIEWS:
		var holder := Node2D.new()
		holder.name = v
		holder.visible = v == view
		add_child(holder)
		_views[v] = holder
		for n in _rig["views"][v]["nodes"]:
			var nd := Node2D.new()
			nd.name = str(n["id"])
			nd.position = Vector2(float(n["pos"][0]), float(n["pos"][1]))
			nd.rotation_degrees = float(n["rot_deg"])
			nd.scale = Vector2(float(n["scale"][0]), float(n["scale"][1]))
			nd.z_index = _z(int(n["z"]))
			nd.visible = bool(n.get("visible", true))
			nd.set_meta("rest", [nd.position, nd.rotation_degrees, nd.scale, nd.visible])
			var parent_id: Variant = n.get("parent", null)
			var parent: Node = holder if parent_id == null else _nodes[v + "/" + str(parent_id)]
			parent.add_child(nd)
			_nodes[v + "/" + nd.name] = nd
			var spr: Variant = null
			if n.has("frames"):
				spr = n["frames"][str(n["default_frame"])]
				nd.set_meta("frame0", str(n["default_frame"]))
			elif n.get("sprite") is Dictionary:
				spr = n["sprite"]
			if spr != null or str(n.get("sprite", "")) == "fx":
				var s: Sprite2D = make_sprite(spr) if spr != null else Sprite2D.new()
				if spr == null:
					s.centered = false
					s.scale = Vector2.ONE / RASTER
				nd.add_child(s)
				_sprites[v + "/" + nd.name] = s
	body = AnimationPlayer.new()
	body.name = "Body"
	add_child(body)
	overlay = AnimationPlayer.new()
	overlay.name = "Overlay"
	add_child(overlay)
	var lib := _library(UiPip.reduce_motion())
	body.add_animation_library("", lib)
	overlay.add_animation_library("", lib)
	_built = true


## Pogled + smjer (side: ← = zrcaljenje). Skriveni pogledi miruju.
func set_view(v: String, p_flip: bool = false) -> void:
	if not _views.has(v):
		return
	view = v
	flip = p_flip and v == "side"
	for k in _views:
		var holder := _views[k] as Node2D
		holder.visible = k == view
		holder.scale = Vector2(-1.0 if (k == "side" and flip) else 1.0, 1.0)


## Klip stanja: pogled se uzme iz klipa; čvorovi tog pogleda se vrate u odmor (kao u
## pregledaču, gdje se poza svaki frejm gradi od odmora + klipa).
func play(id: String, p_flip: bool = false) -> void:
	if not _built or not _anims.has(id):
		return
	var a: Dictionary = _anims[id]
	var v := str(a.get("view", "front"))
	if UiPip.reduce_motion() and str(a.get("reduce_motion", {}).get("type", "")) == "skip":
		return
	set_view(v, p_flip)
	overlay.stop()
	_reset_view(v)
	_ensure_anim(id)
	clip = id
	body.play(id)
	if UiPip.reduce_motion() and str(a.get("reduce_motion", {}).get("type", "")) == "end":
		body.seek(float(a["length"]), true)


## Jednokratni klip preko lova (sjemenka pobjegla); lov ispod ne staje.
func play_overlay(id: String) -> void:
	if not _built or not _anims.has(id):
		return
	_ensure_anim(id)
	overlay.stop()
	overlay.play(id)


func stop_overlay() -> void:
	if overlay != null and overlay.is_playing():
		overlay.stop()
		_reset_view(view)
		if body != null and not str(body.current_animation).is_empty():
			body.seek(body.current_animation_position, true)


func is_overlay_playing() -> bool:
	return overlay != null and overlay.is_playing()


func _reset_view(v: String) -> void:
	for key in _nodes:
		if not str(key).begins_with(v + "/"):
			continue
		var nd := _nodes[key] as Node2D
		var rest: Array = nd.get_meta("rest")
		nd.position = rest[0]
		nd.rotation_degrees = rest[1]
		nd.scale = rest[2]
		nd.visible = rest[3]
		nd.modulate.a = 1.0
		if nd.has_meta("frame0"):
			set_frame(v, nd.name, str(nd.get_meta("frame0")))


func node(v: String, id: String) -> Node2D:
	return _nodes.get(v + "/" + id) as Node2D


func set_frame(v: String, id: String, frame: String) -> void:
	var s := _sprites.get(v + "/" + id) as Sprite2D
	if s == null:
		return
	var src: Dictionary = {}
	for n in _rig["views"][v]["nodes"]:
		if str(n["id"]) == id:
			if n.has("frames") and n["frames"].has(frame):
				src = n["frames"][frame]
			break
	if src.is_empty():
		src = _rig.get("fx_frames", {}).get(frame, {})
	if src.is_empty():
		return
	var key := v + "/" + id + "/" + frame
	if _subs.has(key):
		s.texture = _subs[key][0]
		s.offset = _subs[key][1]
		return
	_apply_sprite(s, src)
	_subs[key] = [s.texture, s.offset]


# ── animacije (iz JSON-a, kad se prvi put puste) ─────────────────────────────

func _library(rm: bool) -> AnimationLibrary:
	var key := "rm" if rm else "full"
	if not _libs.has(key):
		_libs[key] = AnimationLibrary.new()
	return _libs[key]


func _ensure_anim(id: String) -> void:
	var rm := UiPip.reduce_motion()
	var lib := _library(rm)
	if not lib.has_animation(id):
		lib.add_animation(id, _to_animation(_anims[id], rm))


func _path(v: String, id: String) -> String:
	var chain := PackedStringArray()
	var cur := id
	var by_id := {}
	for n in _rig["views"][v]["nodes"]:
		by_id[str(n["id"])] = n
	var guard := 0
	while not cur.is_empty() and guard < 12:
		chain.insert(0, cur)
		var p: Variant = by_id.get(cur, {}).get("parent", null)
		cur = "" if p == null else str(p)
		guard += 1
	return v + "/" + "/".join(chain)


func _to_animation(a: Dictionary, rm: bool) -> Animation:
	var v := str(a.get("view", "front"))
	var an := Animation.new()
	an.length = maxf(0.01, float(a.get("length", 0.01)))
	an.loop_mode = Animation.LOOP_LINEAR if bool(a.get("loop", false)) else Animation.LOOP_NONE
	var r: Dictionary = a.get("reduce_motion", {})
	var mode := str(r.get("type", "damp")) if rm else ""
	var k := float(r.get("k", 0.3))
	for tr in a.get("tracks", []):
		var id := str(tr["node"])
		var nd := node(v, id)
		if nd == null:
			continue
		var prop := str(tr["prop"])
		var is_fx := id.begins_with("fx_") or id == "emote"
		if rm and is_fx and not bool(r.get("fx", false)):
			continue
		if mode == "expr" and prop != "frame":
			continue
		var kk := k if mode == "damp" else 1.0
		var rest: Array = nd.get_meta("rest")
		if prop == "frame":
			var t := an.add_track(Animation.TYPE_METHOD)
			an.track_set_path(t, NodePath("."))
			for key in tr["keys"]:
				an.track_insert_key(t, float(key[0]), {"method": "set_frame", "args": [v, id, str(key[1])]})
			continue
		var t2 := an.add_track(Animation.TYPE_VALUE)
		an.track_set_path(t2, NodePath(_path(v, id) + ":" + prop))
		an.value_track_set_update_mode(t2, Animation.UPDATE_DISCRETE if prop == "visible" else Animation.UPDATE_CONTINUOUS)
		for key in tr["keys"]:
			_insert_key(an, t2, prop, key, rest, kk)
	return an


func _insert_key(an: Animation, t2: int, prop: String, key: Array, rest: Array, kk: float) -> void:
	var tt := float(key[0])
	var val: Variant
	var trans := -2.0
	match prop:
		"position":
			val = rest[0] + Vector2(float(key[1]), float(key[2])) * kk
			trans = float(key[3]) if key.size() > 3 else -2.0
		"scale":
			val = rest[2] * (Vector2.ONE + (Vector2(float(key[1]), float(key[2])) - Vector2.ONE) * kk)
			trans = float(key[3]) if key.size() > 3 else -2.0
		"rotation_degrees":
			val = rest[1] + float(key[1]) * kk
			trans = float(key[2]) if key.size() > 2 else -2.0
		"modulate:a":
			val = float(key[1])
			trans = float(key[2]) if key.size() > 2 else -2.0
		"visible":
			val = float(key[1]) > 0.5
		_:
			return
	an.track_insert_key(t2, tt, val, trans)
