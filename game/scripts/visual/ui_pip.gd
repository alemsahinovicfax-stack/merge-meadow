extends Node2D
class_name UiPip
## Pip cutout rig (design_handoff_pip). Jedan čvor za svaku površinu: polje, kartica,
## Arena, run (odozgo), HUD, Shop, Ormar. Podaci: rig / animations / skins.json.
## Atlas se rasterizuje jednom po skinu; po frejmu samo transformacije čvorova.
## Premium skin (Sir Pip, design_handoff_muncher_premium_pip): skins.json `replace` mijenja
## dijelove po pogledu (finalne boje, bez recolora), rig čvorovi sa "skin" se grade samo za
## taj skin, `gz` je njihov z u Godotu, treći player "Skin" vrti ogrtač, `reactions` mijenja
## merge_t3 / finish, `idle_detail` pušta overlay svakih 6–10 s dok Pip miruje.

signal pip_event(event_name: String, arg: Variant)

const DATA_DIR := "res://data/pip/"
const RASTER := 2.0
const ATLAS_W := 1024
const HUD_CROP := Rect2(40, 40, 176, 176)
## Dijelovi idu od z −4 (sjena) do 11. Domaćin koji sam crta pozadinu (pregled u Shopu /
## Ormaru) diže Pipa za ovoliko, inače sjena i ogrtač Sir Pipa (z −1) padnu pod pozadinu.
const HOST_LIFT := 4
const FRAME := {
	"front": 256.0, "three_q": 256.0, "side": 256.0, "back": 256.0, "top": 150.0,
}

@export var view: String = "front"
@export var skin: String = "classic"
@export var box_px: float = 190.0
@export var still: bool = false
@export var crop_head: bool = false
@export var follow_equipped: bool = true

static var _rig: Dictionary = {}
static var _anims: Dictionary = {}
static var _skins: Dictionary = {}
static var _behaviors: Dictionary = {}
static var _atlas: Dictionary = {}
## key → {"task", "raster"} (najviše jedan) i red čekanja za request_atlas.
static var _jobs: Dictionary = {}
static var _job_queue: Array[String] = []
## Biblioteka po "pogled|reduce_motion", puni se po animaciji (_ensure_anim).
static var _libs: Dictionary = {}
static var _by_view: Dictionary = {}
static var _paths: Dictionary = {}
## id animacije → true ako ključa čvor koji vrti sloj skina (ogrtač); takav base klip ima prednost.
static var _keys_skin_nodes: Dictionary = {}

var nodes: Dictionary = {}
var sprites: Dictionary = {}
var body: AnimationPlayer
var overlay: AnimationPlayer
## Treći player (samo skin sa skin_layer): petlja ogrtača, procesira se prije Body.
var skin_layer: AnimationPlayer
var loop_id: String = ""
var _base_id: String = ""
var _idle_timer: Timer
var look_target: Variant = null
var _look := Vector3.ZERO
var _face_left: bool = false
var _after_pose: String = ""
var _built: bool = false
var _lib_view: String = ""
var _lib_rm: bool = false
## Skin s vlastitim čvorovima (Sir Pip) ima svoju biblioteku: AnimationMixer provjerava putanje
## SVIH animacija u biblioteci, pa bi klipovi s k_cape u zajedničkoj biblioteci bacali
## upozorenja na Classic / Blossom / Sky.
var _lib_skin: String = ""


static func reduce_motion() -> bool:
	var gs := _game_state()
	if gs != null and "reduce_motion" in gs:
		return bool(gs.reduce_motion)
	return false


static func _game_state() -> Node:
	var loop := Engine.get_main_loop() as SceneTree
	if loop == null or loop.root == null:
		return null
	return loop.root.get_node_or_null("GameState")


static func _load_json(file_name: String) -> Variant:
	var path := DATA_DIR + file_name
	if not FileAccess.file_exists(path):
		push_error("UiPip: missing %s" % path)
		return {}
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func data() -> void:
	if not _rig.is_empty():
		return
	var rig_raw: Variant = _load_json("rig.json")
	_rig = rig_raw if rig_raw is Dictionary else {}
	_anims = {}
	var anim_raw: Variant = _load_json("animations.json")
	if anim_raw is Dictionary:
		for a in (anim_raw as Dictionary).get("list", []):
			if a is Dictionary:
				_anims[str(a["id"])] = a
	var skin_raw: Variant = _load_json("skins.json")
	if skin_raw is Dictionary:
		for s in (skin_raw as Dictionary).get("skins", []):
			if s is Dictionary:
				_skins[str(s["key"])] = s
	var beh_raw: Variant = _load_json("behaviors.json")
	_behaviors = beh_raw if beh_raw is Dictionary else {}


static func behaviors() -> Dictionary:
	data()
	return _behaviors


static func skin_key_from_cosmetic(cosmetic_id: String) -> String:
	data()
	if cosmetic_id.is_empty():
		return "classic"
	for k in _skins:
		if str(_skins[k].get("cosmetic_id", "")) == cosmetic_id:
			return str(k)
	return "classic"


static func skin_key_from_recolor(recolor: Dictionary) -> String:
	data()
	if recolor.is_empty():
		return "classic"
	## cosmetics.json drži kraću mapu (3 boje Blossom, 2 Sky). skins.json ima svih 7.
	## Traži se da svaki hex iz kataloga postoji u skinu; pobjeđuje najduži pogodak.
	var best := "classic"
	var best_hits := 0
	for k in _skins:
		var rec: Variant = _skins[k].get("recolor", {})
		if not (rec is Dictionary) or (rec as Dictionary).is_empty():
			continue
		var skin_map: Dictionary = rec
		var hits := 0
		var ok := true
		for hex in recolor:
			var want := str(recolor[hex]).to_upper()
			var got := str(skin_map.get(hex, ""))
			if got.is_empty():
				got = str(skin_map.get(str(hex).to_upper(), skin_map.get(str(hex).to_lower(), "")))
			if got.is_empty() or got.to_upper() != want:
				ok = false
				break
			hits += 1
		if ok and hits > best_hits:
			best = str(k)
			best_hits = hits
	return best


static func equipped_skin_key() -> String:
	data()
	return skin_key_from_cosmetic(PipAssets.equipped_skin())


static func pose_for_skin(key: String) -> String:
	data()
	var sk: Dictionary = _skins.get(key, _skins.get("classic", {}))
	return str(sk.get("showcase_anim", "pose_classic"))


static func signature_for_skin(key: String) -> String:
	data()
	var sk: Dictionary = _skins.get(key, _skins.get("classic", {}))
	return str(sk.get("signature_anim", "sig_classic"))


## Skin iz looka kozmetike: {"skin": key} (premium) ili {"recolor": {...}}; gola recolor
## mapa (stari pozivi) i dalje radi.
static func skin_key_from_look(look: Dictionary) -> String:
	data()
	if look.has("skin") and _skins.has(str(look["skin"])):
		return str(look["skin"])
	if look.has("recolor") and look["recolor"] is Dictionary:
		return skin_key_from_recolor(look["recolor"])
	return skin_key_from_recolor(look)


static func skin_def(key: String) -> Dictionary:
	data()
	return _skins.get(key, _skins.get("classic", {}))


## Čvor riga sa "skin" (dodatak premium skina) postoji samo u tom skinu.
static func _node_in_skin(n: Dictionary, key: String) -> bool:
	return not n.has("skin") or str(n["skin"]) == key


static func prewarm() -> void:
	data()
	for k in _skins:
		atlas_for(str(k))


func _ready() -> void:
	data()
	if follow_equipped:
		skin = equipped_skin_key()
	build()
	var gs := _game_state()
	if gs != null and gs.has_signal("cosmetics_changed"):
		if not gs.cosmetics_changed.is_connected(_on_cosmetics):
			gs.cosmetics_changed.connect(_on_cosmetics)


func _on_cosmetics(_slots: Array) -> void:
	if follow_equipped:
		set_skin(equipped_skin_key())


static func atlas_for(key: String) -> Dictionary:
	data()
	if _atlas.has(key):
		return _atlas[key]
	if _jobs.has(key):
		_finish_job(key)
		return _atlas[key]
	_job_queue.erase(key)
	_atlas[key] = _atlas_from(_raster(key))
	return _atlas[key]


## Atlas bez čekanja na glavnom threadu (perf 2026-10-10): Shop u hubu je rasterizovao 3 skina
## u jednom frejmu (~400 ms). SVG → Image ide u WorkerThreadPool, jedan posao u isto vrijeme
## (ThorVG + slab telefon); tekstura se pravi na glavnom threadu u atlas_ready / atlas_for.
static func request_atlas(key: String) -> void:
	data()
	if _atlas.has(key) or _jobs.has(key) or _job_queue.has(key):
		return
	_job_queue.append(key)
	_pump_jobs()


## true kad je atlas spreman (završen posao se ovdje preuzme); inače pokreće sljedeći u redu.
static func atlas_ready(key: String) -> bool:
	if _atlas.has(key):
		return true
	if _jobs.has(key) and WorkerThreadPool.is_task_completed(int(_jobs[key]["task"])):
		_finish_job(key)
		return true
	_pump_jobs()
	return false


static func _pump_jobs() -> void:
	for k in _jobs:
		if not WorkerThreadPool.is_task_completed(int(_jobs[k]["task"])):
			return
		_finish_job(k)
		break
	if not _jobs.is_empty() or _job_queue.is_empty():
		return
	var key: String = _job_queue.pop_front()
	var job := {}
	job["task"] = WorkerThreadPool.add_task(func() -> void: job["raster"] = _raster(key))
	_jobs[key] = job
	# GDScript u threadu dok se skripte gase pri izlasku = pad (exit 139): sačekaj posao.
	var loop := Engine.get_main_loop() as SceneTree
	if loop != null and loop.root != null and not loop.root.tree_exiting.is_connected(_drain_jobs):
		loop.root.tree_exiting.connect(_drain_jobs)


static func _drain_jobs() -> void:
	_job_queue.clear()
	for k in _jobs.keys():
		WorkerThreadPool.wait_for_task_completion(int(_jobs[k]["task"]))
	_jobs.clear()


static func _finish_job(key: String) -> void:
	var job: Dictionary = _jobs[key]
	WorkerThreadPool.wait_for_task_completion(int(job["task"]))
	_jobs.erase(key)
	_atlas[key] = _atlas_from(job["raster"])


static func _atlas_from(raster: Dictionary) -> Dictionary:
	var atlas: Image = raster["image"]
	return {"texture": ImageTexture.create_from_image(atlas), "regions": raster["regions"], "subs": {}}


## Samo Image / string operacije — sigurno van glavnog threada.
static func _raster(key: String) -> Dictionary:
	var sk: Dictionary = _skins.get(key, _skins.get("classic", {}))
	var recolor: Dictionary = sk.get("recolor", {})
	var replace: Dictionary = sk.get("replace", {})
	# I dijelovi premium skina nose classic boje krzna (#A8E6CF…) za uši / šape — recolor
	# ide na sve; boje oklopa nisu classic tokeni pa ostaju.
	var files: Dictionary = {}
	for v in _rig.get("views", {}):
		var rep: Dictionary = replace.get(v, {})
		for n in _rig["views"][v]["nodes"]:
			if not _node_in_skin(n, key):
				continue
			# Overlay drugog skina (grančica Blossoma, oblaci Skya) se nikad ne crta u ovom.
			if n.has("overlay") and not _has_overlay(sk, str(n["overlay"])):
				continue
			if rep.has(str(n["id"])):
				files[str(rep[str(n["id"])]["file"])] = true
				continue
			if n.has("sprite") and n["sprite"] is Dictionary:
				files[str(n["sprite"]["file"])] = true
			if n.has("frames"):
				for f in n["frames"]:
					files[str(n["frames"][f]["file"])] = true
	for f in _rig.get("fx_frames", {}):
		var fx: Dictionary = _rig["fx_frames"][f]
		if _node_in_skin(fx, key):
			files[str(fx["file"])] = true
	var imgs: Dictionary = {}
	for f in files:
		var svg := FileAccess.get_file_as_string(str(f))
		if svg.is_empty():
			continue
		var img := Image.new()
		if img.load_svg_from_string(PipAssets.recolor_svg(svg, recolor), RASTER) == OK and not img.is_empty():
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
	var h := nearest_po2(maxi(1, y + row))
	var atlas := Image.create(ATLAS_W, h, false, Image.FORMAT_RGBA8)
	atlas.fill(Color(0, 0, 0, 0))
	for f in regions:
		atlas.blit_rect(imgs[f], Rect2i(Vector2i.ZERO, imgs[f].get_size()), Vector2i(regions[f].position))
	return {"image": atlas, "regions": regions}


## Rig z slaže dijelove unutar lika (±50). Godot ga zbraja na z hosta (polje 20),
## pa FX na 40 izađe iznad korpe i Ormara (z 45) — „zzz" preko inventara.
## Redoslijed ostaje, raspon stane ispod sheeta: emote 11 → efektivno 31.
static func _part_z(rig_z: int) -> int:
	if rig_z >= 42:
		return 11
	if rig_z >= 40:
		return 10
	if rig_z >= 20:
		return 9
	if rig_z <= -50:
		return -4
	if rig_z <= -40:
		return -3
	if rig_z <= -20:
		return -2
	return rig_z


static func _has_overlay(sk: Dictionary, overlay_id: String) -> bool:
	for o in sk.get("overlays", []):
		if str(o.get("id", "")) == overlay_id:
			return true
	return false


static func sub(key: String, sprite: Dictionary) -> AtlasTexture:
	var a := atlas_for(key)
	var f := str(sprite.get("file", ""))
	if a["subs"].has(f):
		return a["subs"][f]
	var t := AtlasTexture.new()
	t.atlas = a["texture"]
	t.region = a["regions"].get(f, Rect2())
	a["subs"][f] = t
	return t


func build() -> void:
	data()
	while get_child_count() > 0:
		var c := get_child(0)
		remove_child(c)
		c.free()
	nodes.clear()
	sprites.clear()
	body = null
	overlay = null
	skin_layer = null
	_idle_timer = null
	var views: Dictionary = _rig.get("views", {})
	if not views.has(view):
		push_error("UiPip: unknown view %s" % view)
		return
	var v: Dictionary = views[view]
	_apply_scale()
	var sk: Dictionary = _skins.get(skin, _skins.get("classic", {}))
	var rep: Dictionary = sk.get("replace", {}).get(view, {})
	var gz: Dictionary = sk.get("gz", {}).get(view, {})
	for n in v.get("nodes", []):
		if not _node_in_skin(n, skin):
			continue
		var nd := Node2D.new()
		nd.name = str(n["id"])
		nd.position = Vector2(float(n["pos"][0]), float(n["pos"][1]))
		nd.rotation_degrees = float(n["rot_deg"])
		nd.scale = Vector2(float(n["scale"][0]), float(n["scale"][1]))
		# Paket ima i z 0,5 / 2,5 i ogrtač ispod sjene (−6): skin daje cijeli z za Godot.
		nd.z_index = int(gz[nd.name]) if gz.has(nd.name) else _part_z(int(floorf(float(n["z"]))))
		nd.z_as_relative = true
		nd.visible = bool(n.get("visible", true))
		nd.set_meta("rest", [nd.position, nd.rotation_degrees, nd.scale])
		nd.set_meta("rig_z", float(n["z"]))
		var parent_id: Variant = n.get("parent", null)
		var parent: Node = self if parent_id == null else nodes[str(parent_id)]
		parent.add_child(nd)
		if n.has("skin"):
			_insert_by_rig_z(parent, nd)
		nodes[nd.name] = nd
		var is_overlay: bool = bool(n.has("overlay"))
		var show_overlay: bool = (not is_overlay) or _has_overlay(sk, str(n["overlay"]))
		var spr_data: Variant = null
		if n.has("frames"):
			spr_data = n["frames"][str(n["default_frame"])]
		elif rep.has(nd.name):
			spr_data = rep[nd.name]
		elif n.get("sprite") is Dictionary:
			spr_data = n["sprite"]
		var is_fx := str(n.get("sprite", "")) == "fx"
		if (spr_data != null and show_overlay) or is_fx:
			var s := Sprite2D.new()
			s.centered = false
			if spr_data != null and show_overlay:
				s.texture = sub(skin, spr_data)
				var off: Array = spr_data["offset"]
				s.offset = Vector2(float(off[0]), float(off[1])) * RASTER
			s.scale = Vector2.ONE / RASTER
			nd.add_child(s)
			sprites[nd.name] = s
		if is_overlay and not show_overlay:
			nd.visible = false
	_lib_view = view
	_lib_rm = reduce_motion()
	_lib_skin = skin if _skin_has_nodes(skin) else ""
	var lib := library(_lib_view, _lib_rm, _lib_skin)
	# Sloj skina prije Body: kad base klip sam ključa ogrtač, njegova vrijednost pobjeđuje.
	if not _skin_loop_id(sk).is_empty():
		skin_layer = AnimationPlayer.new()
		skin_layer.name = "Skin"
		add_child(skin_layer)
		skin_layer.add_animation_library("", lib)
	body = AnimationPlayer.new()
	body.name = "Body"
	add_child(body)
	overlay = AnimationPlayer.new()
	overlay.name = "Overlay"
	add_child(overlay)
	body.add_animation_library("", lib)
	overlay.add_animation_library("", lib)
	if not body.animation_finished.is_connected(_on_body_done):
		body.animation_finished.connect(_on_body_done)
	if sk.get("idle_detail") is Dictionary:
		_idle_timer = Timer.new()
		_idle_timer.name = "IdleDetail"
		_idle_timer.one_shot = true
		add_child(_idle_timer)
		_idle_timer.timeout.connect(_on_idle_detail)
		_idle_timer.start(float(sk["idle_detail"].get("first_s", 2.5)))
	set_process(false)
	_built = true
	_sync_skin_layer()


## Dodatak skina ide prije braće s istim Godot z i većim z iz paketa (Godot pri istom z
## crta po redu u stablu; paket ima i z 0,5 između dva cijela).
static func _insert_by_rig_z(parent: Node, nd: Node2D) -> void:
	var z := float(nd.get_meta("rig_z"))
	for c in parent.get_children():
		var sib := c as Node2D
		if sib == null or sib == nd or not sib.has_meta("rig_z"):
			continue
		if sib.z_index == nd.z_index and float(sib.get_meta("rig_z")) > z:
			parent.move_child(nd, sib.get_index())
			return


func _skin_loop_id(sk: Dictionary) -> String:
	var loops: Variant = sk.get("skin_layer", {}).get("loops", {})
	if not (loops is Dictionary):
		return ""
	return str((loops as Dictionary).get(view, (loops as Dictionary).get("default", "")))


## true ako animacija ključa neki čvor koji ključa i petlja sloja skina (npr. k_cape).
func _anim_keys_skin(id: String) -> bool:
	if id.is_empty() or not _anims.has(id):
		return false
	var loop := _skin_loop_id(skin_def(skin))
	if loop.is_empty() or not _anims.has(loop):
		return false
	var cache_key := id + "|" + loop
	if _keys_skin_nodes.has(cache_key):
		return _keys_skin_nodes[cache_key]
	var skin_nodes := {}
	for tr in _anims[loop].get("tracks", []):
		skin_nodes[str(tr["node"])] = true
	var hit := false
	for tr in _anims[id].get("tracks", []):
		if skin_nodes.has(str(tr["node"])):
			hit = true
			break
	_keys_skin_nodes[cache_key] = hit
	return hit


## Petlja ogrtača svira dok Pip nije u mirnoj pozi (Shop lista), nema reduce motion i base
## klip ne ključa ogrtač sam (poza, potpis, T3, cilj) — kao sloj „Skin" u paketu.
func _sync_skin_layer() -> void:
	if skin_layer == null:
		return
	var loop := _skin_loop_id(skin_def(skin))
	if loop.is_empty() or still or reduce_motion() or _anim_keys_skin(_base_id):
		if skin_layer.is_playing():
			skin_layer.pause()
		return
	if str(skin_layer.current_animation) != loop:
		_ensure_anim(loop)
		skin_layer.play(loop)
	elif not skin_layer.is_playing():
		skin_layer.play()


## Idle detalj skina (kaciga sklizne): overlay jednom u 6–10 s dok Pip miruje.
func _on_idle_detail() -> void:
	if _idle_timer == null:
		return
	var idd: Dictionary = skin_def(skin).get("idle_detail", {})
	var gap: Array = idd.get("gap_s", [6, 10])
	_idle_timer.start(randf_range(float(gap[0]), float(gap[1])))
	if still or reduce_motion() or body == null or not is_visible_in_tree():
		return
	if overlay != null and overlay.is_playing():
		return
	if not (idd.get("on", []) as Array).has(str(body.current_animation)):
		return
	play(str(idd.get("anim", "")))


func _apply_scale() -> void:
	var frame_px := float(FRAME.get(view, 256.0))
	var k: float
	if crop_head and view != "top":
		k = box_px / HUD_CROP.size.x
	else:
		k = box_px / frame_px
	scale = Vector2(-k if _face_left else k, k)


func set_box(px: float) -> void:
	box_px = px
	_apply_scale()


func set_facing(left: bool) -> void:
	if _face_left == left:
		return
	_face_left = left
	_apply_scale()


func set_view(v: String) -> void:
	if v == view and _built:
		return
	view = v
	var cur: String = str(body.current_animation) if body != null else ""
	build()
	if not cur.is_empty():
		play(cur)
	elif not loop_id.is_empty():
		play(loop_id)


func set_skin(key: String) -> void:
	if key.is_empty():
		key = "classic"
	if key == skin and _built:
		return
	skin = key
	var cur: String = str(body.current_animation) if body != null else ""
	build()
	if not cur.is_empty():
		play(cur)
	elif not loop_id.is_empty():
		play(loop_id)


func place_feet_in(host: Control) -> void:
	if crop_head:
		var k := box_px / HUD_CROP.size.x
		position = Vector2((128.0 - HUD_CROP.position.x) * k, (240.0 - HUD_CROP.position.y) * k)
	else:
		position = Vector2(host.size.x * 0.5, host.size.y)


func set_frame(id: String, frame: String) -> void:
	if not sprites.has(id):
		return
	var src: Dictionary = {}
	for n in _rig["views"][view]["nodes"]:
		if str(n["id"]) != id:
			continue
		if n.has("frames") and n["frames"].has(frame):
			src = n["frames"][frame]
		else:
			src = _rig.get("fx_frames", {}).get(frame, {})
		break
	if src.is_empty():
		return
	var s: Sprite2D = sprites[id]
	s.texture = sub(skin, src)
	var off: Array = src["offset"]
	s.offset = Vector2(float(off[0]), float(off[1])) * RASTER


func emit_event(event_name: String, arg: Variant) -> void:
	# Zvučni događaji iz animations.json (sfx:land, pop, sneeze, bonk, thump, cough, blow) →
	# pip_* u katalogu; samo Pip koji se vidi i živi (ne poza u Shop listi).
	if event_name.begins_with("sfx:") and not still and is_visible_in_tree():
		Sfx.play("pip_" + event_name.substr(4))
	pip_event.emit(event_name, arg)


static func _skin_has_nodes(key: String) -> bool:
	for v in _rig.get("views", {}):
		for n in _rig["views"][v]["nodes"]:
			if str(n.get("skin", "")) == key:
				return true
	return false


func library(v: String, rm: bool, skin_key: String = "") -> AnimationLibrary:
	var key := "%s|%s|%s" % [v, str(rm), skin_key]
	if _libs.has(key):
		return _libs[key]
	var lib := AnimationLibrary.new()
	_libs[key] = lib
	return lib


## Animacija se pretvara iz JSON-a tek kad se prvi put pusti (perf 2026-10-10): cijela
## biblioteka (75 animacija) je ~45 ms po pogledu, a plaćao ju je prvi Pip u Shopu, Ormaru i runu.
func _ensure_anim(id: String) -> void:
	if body == null or not _anims.has(id):
		return
	var lib := library(_lib_view, _lib_rm, _lib_skin)
	if not lib.has_animation(id):
		lib.add_animation(id, _to_animation(_anims[id], _lib_view, _lib_rm))


func _view_nodes(v: String) -> Dictionary:
	if _by_view.has(v):
		return _by_view[v]
	var out: Dictionary = {}
	for n in _rig["views"][v]["nodes"]:
		out[str(n["id"])] = n
	_by_view[v] = out
	return out


func _node_path(v: String, id: String) -> NodePath:
	var pkey := v + "|" + id
	if _paths.has(pkey):
		return _paths[pkey]
	var by_id := _view_nodes(v)
	var chain: PackedStringArray = PackedStringArray()
	var cur := id
	var guard := 0
	while not cur.is_empty() and guard < 16:
		chain.insert(0, cur)
		var n: Dictionary = by_id.get(cur, {})
		var p: Variant = n.get("parent", null)
		cur = "" if p == null else str(p)
		guard += 1
	_paths[pkey] = NodePath("/".join(chain))
	return _paths[pkey]


func _rest_of(n: Dictionary) -> Array:
	return [
		Vector2(float(n["pos"][0]), float(n["pos"][1])),
		float(n["rot_deg"]),
		Vector2(float(n["scale"][0]), float(n["scale"][1])),
	]


func _to_animation(a: Dictionary, v: String, rm: bool) -> Animation:
	var an := Animation.new()
	an.length = maxf(0.01, float(a.get("length", 0.01)))
	an.loop_mode = Animation.LOOP_LINEAR if bool(a.get("loop", false)) else Animation.LOOP_NONE
	var r: Dictionary = a.get("reduce_motion", {})
	var mode := str(r.get("type", "damp")) if rm else ""
	var k := float(r.get("k", 0.3))
	var keep: Array = r.get("keep", [])
	var by_id := _view_nodes(v)
	for tr in a.get("tracks", []):
		var id := str(tr["node"])
		if not by_id.has(id):
			continue
		var prop := str(tr["prop"])
		var is_fx := id.begins_with("fx_") or id.begins_with("prop") or id == "emote"
		if rm and is_fx and not bool(r.get("fx", false)):
			continue
		if mode == "expr" and prop != "frame":
			continue
		var kk := 1.0 if keep.has(id) or mode != "damp" else k
		var rest: Array = _rest_of(by_id[id])
		if prop == "frame":
			var t := an.add_track(Animation.TYPE_METHOD)
			an.track_set_path(t, NodePath("."))
			for key in tr["keys"]:
				an.track_insert_key(t, float(key[0]), {"method": "set_frame", "args": [id, str(key[1])]})
			continue
		var t2 := an.add_track(Animation.TYPE_VALUE)
		an.track_set_path(t2, NodePath(str(_node_path(v, id)) + ":" + prop))
		var discrete := prop == "visible"
		an.value_track_set_update_mode(
			t2, Animation.UPDATE_DISCRETE if discrete else Animation.UPDATE_CONTINUOUS
		)
		for key in tr["keys"]:
			_insert_key(an, t2, prop, key, rest, kk)
	if mode != "expr":
		for ev in a.get("events", []):
			var te := an.add_track(Animation.TYPE_METHOD)
			an.track_set_path(te, NodePath("."))
			an.track_insert_key(
				te, float(ev["t"]), {"method": "emit_event", "args": [str(ev["name"]), ev.get("arg", "")]}
			)
	return an


func _insert_key(an: Animation, t2: int, prop: String, key: Array, rest: Array, kk: float) -> void:
	var tt := float(key[0])
	var val: Variant
	var trans := 1.0
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


## Skin može zamijeniti klip svojim (Sir Pip: merge_t3 → t3_knight, finish → goal_knight).
func _react(id: String) -> String:
	var reactions: Variant = skin_def(skin).get("reactions", {})
	if reactions is Dictionary and (reactions as Dictionary).has(id):
		var alt := str(reactions[id])
		if _anims.has(alt):
			return alt
	return id


func play(id: String) -> void:
	id = _react(id)
	if not _anims.has(id) or body == null:
		return
	var a: Dictionary = _anims[id]
	var rm := reduce_motion()
	if rm and str(a.get("reduce_motion", {}).get("type", "")) == "skip":
		return
	_ensure_anim(id)
	if str(a.get("layer", "base")) == "overlay":
		overlay.stop()
		overlay.play(id)
	else:
		if bool(a.get("loop", false)):
			loop_id = id
		_base_id = id
		body.play(id)
		if rm and str(a.get("reduce_motion", {}).get("type", "")) == "end":
			body.seek(float(a["length"]), true)
	if still:
		body.pause()
	_sync_skin_layer()


func set_loop(id: String) -> void:
	loop_id = id
	play(id)


func pose(id: String) -> void:
	if not _anims.has(id) or body == null:
		return
	still = true
	_ensure_anim(id)
	_base_id = id
	body.play(id)
	body.seek(float(_anims[id]["length"]), true)
	body.pause()
	_sync_skin_layer()


func play_then_pose(id: String, pose_id: String) -> void:
	_after_pose = pose_id
	still = false
	play(id)


func is_playing(id: String = "") -> bool:
	if body == null:
		return false
	if id.is_empty():
		return body.is_playing() or (overlay != null and overlay.is_playing())
	return body.current_animation == id or (overlay != null and overlay.current_animation == id)


func _on_body_done(id: StringName) -> void:
	if not _after_pose.is_empty():
		var p := _after_pose
		_after_pose = ""
		pose(p)
		return
	if bool(_anims.get(str(id), {}).get("hold_last", false)):
		return
	if not loop_id.is_empty() and not still:
		_ensure_anim(loop_id)
		_base_id = loop_id
		body.play(loop_id)
		_sync_skin_layer()


func set_scroll_speed(px_s: float) -> void:
	if body != null:
		body.speed_scale = px_s / 400.0
	if skin_layer != null:
		skin_layer.speed_scale = px_s / 400.0


func look_at_point(p: Variant) -> void:
	look_target = p
	set_process(true)


func _process(delta: float) -> void:
	var want := Vector3.ZERO
	if look_target is Vector2 and nodes.has("head"):
		var d: Vector2 = nodes["head"].to_local(look_target)
		want = Vector3(clampf(d.x * 0.05, -7.0, 7.0), clampf(d.x * 0.03, -3.5, 3.5), clampf(d.y * 0.03, -3.0, 3.0))
	_look = _look.lerp(want, minf(1.0, delta * 9.0))
	if nodes.has("head"):
		nodes["head"].rotation_degrees = float(nodes["head"].get_meta("rest")[1]) + _look.x
	for e in ["eye_L", "eye_R"]:
		if nodes.has(e):
			nodes[e].position = nodes[e].get_meta("rest")[0] + Vector2(_look.y, _look.z)
	if look_target == null and _look.length() < 0.01:
		set_process(false)
