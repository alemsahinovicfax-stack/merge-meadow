class_name ItemPreview
extends Control

## Ormar · ItemPreview (design_handoff_wardrobe/design/ItemPreview.dc.html).
## Ista komponenta za karticu (210 x 150) i pozornicu (1032 x 300). Vrsta pregleda
## dolazi iz slot.preview u cosmetics.json:
##   companion — trake livade aktivne sezone + pravi pip_idle.svg s recolorom
##               (pozornica dodaje 2 cvijeta iz rostera sezone);
##   meadow    — tlo i staza runa iz kita sezone × look.tint (kao lane_background), Pip u skinu;
##   album     — stranica Bloom Albuma kao u Shopu (okvir / papir / naslov);
##   swatch    — rezerva za slot bez vlastite vrste: naljepnica s 1–2 boje.
## Okvir (rub + zaobljeni uglovi) se crta ovdje: uglovi se prekriju bojom roditelja
## (`corner_bg`), pa nema clip maske ni shadera.

const SIZE_THUMB := "thumb"
const SIZE_STAGE := "stage"
const TITLE_PATH := "res://assets/ui/title_bloom_album.png"
const LOCK_PATH := "res://assets/ui/chrome/icon_lock.svg"
const ALBUM_ROWS: Array[Color] = [Color("b8d4f0"), Color("e0c4ff"), Color("ffe8b8"), Color("e4e4e0")]
const CREATURE_SHADOW := Color(0.102, 0.102, 0.078, 0.16)
const RUN_SHADOW := Color(0.071, 0.110, 0.086, 0.28)
const CREAM := Color("fff8f0")

var kind: String = "companion"
var subject: String = "pip"
var look: Dictionary = {}
## recolor mapa Pipa koja se nosi uz ovaj pregled (meadow: Pip u izabranom skinu).
var pip_recolor: Dictionary = {}
var season_id: String = ""
var preview_size: String = SIZE_THUMB
var veil: bool = false

var frame_border: float = 3.0
var frame_radius: float = 18.0
var frame_color: Color = UiWardrobe.WELL_EDGE
var corner_bg: Color = Color.WHITE

var _hop_k: float = 0.0
var _hop_tween: Tween
## true = Ormar pozornica (stage_idle loop); false = Shop / sličica (poza).
var live_pose: bool = false
var actor: UiPip
var _skin_key: String = "classic"

static var _title_tex: Texture2D
static var _lock_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	clip_children = Control.CLIP_CHILDREN_AND_DRAW


func configure(p_kind: String, p_look: Dictionary, p_pip: Dictionary, p_season: String, p_subject: String = "pip") -> void:
	kind = p_kind if UiWardrobe.PREVIEW_KINDS.has(p_kind) else "swatch"
	look = p_look
	pip_recolor = p_pip
	season_id = p_season
	subject = p_subject if not p_subject.is_empty() else "pip"
	_sync_actor()
	queue_redraw()


func set_frame(border: float, radius: float, color: Color, parent_bg: Color) -> void:
	frame_border = border
	frame_radius = radius
	frame_color = color
	corner_bg = parent_bg
	queue_redraw()


## Pozornica: izabrani lik skoči (1 → 1,12 → 1, y −11 % visine), 280 ms.
func hop() -> void:
	_sync_actor()
	if actor != null and actor.visible:
		actor.play("stage_hop")
		actor.loop_id = "stage_idle"
		return
	if _hop_tween != null and _hop_tween.is_valid():
		_hop_tween.kill()
	_hop_tween = create_tween()
	_hop_tween.tween_method(_set_hop, 0.0, 1.0, UiWardrobe.T_STAGE_HOP)
	_hop_tween.tween_callback(_set_hop.bind(0.0))


func is_hopping() -> bool:
	return _hop_tween != null and _hop_tween.is_running()


func _set_hop(k: float) -> void:
	_hop_k = k
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_actor()
		queue_redraw()


func _skin_for_preview() -> String:
	if kind == "companion":
		return UiPip.skin_key_from_recolor(look.get("recolor", {}))
	return UiPip.skin_key_from_recolor(pip_recolor)


func _sync_actor() -> void:
	var want := subject == "pip" and (kind == "companion" or kind == "meadow")
	if not want:
		if actor != null:
			actor.visible = false
		return
	if actor == null:
		actor = UiPip.new()
		actor.name = "Actor"
		actor.view = "three_q"
		actor.follow_equipped = false
		add_child(actor)
	actor.visible = true
	_skin_key = _skin_for_preview()
	actor.set_skin(_skin_key)
	var inner := Rect2(Vector2(frame_border, frame_border), size - Vector2(frame_border, frame_border) * 2.0)
	var stage := preview_size == SIZE_STAGE
	var h := inner.size.y
	var side := roundf(h * (0.80 if stage else 0.84)) if kind == "companion" else roundf(h * (0.56 if stage else 0.62))
	var feet := h - roundf(h * (0.05 if kind == "companion" else 0.06))
	actor.box_px = side
	actor.position = inner.position + Vector2(inner.size.x * 0.5, feet)
	if live_pose:
		actor.still = false
		actor.set_loop("stage_idle")
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		actor.pose(UiPip.pose_for_skin(_skin_key))
		mouse_filter = Control.MOUSE_FILTER_PASS if stage else Control.MOUSE_FILTER_IGNORE


func _gui_input(event: InputEvent) -> void:
	if live_pose or actor == null or not actor.visible:
		return
	var mouse := event as InputEventMouseButton
	if mouse == null or not mouse.pressed or mouse.button_index != MOUSE_BUTTON_LEFT:
		return
	actor.play_then_pose(UiPip.signature_for_skin(_skin_key), UiPip.pose_for_skin(_skin_key))
	accept_event()


func _season() -> String:
	if not season_id.is_empty():
		return season_id
	var sid := GameState.home_season_field_id
	return sid if not sid.is_empty() else GameState.active_season_id


func _draw() -> void:
	if size.x < 4.0 or size.y < 4.0:
		return
	var b := frame_border
	var inner := Rect2(Vector2(b, b), size - Vector2(b, b) * 2.0)
	draw_rect(Rect2(Vector2.ZERO, size), frame_color)
	match kind:
		"companion":
			_draw_companion(inner)
		"meadow":
			_draw_meadow(inner)
		"album":
			_draw_album(inner)
		_:
			_draw_swatch(inner)
	if veil:
		_draw_veil(inner)
	_draw_frame()


# ── companion ─────────────────────────────────────────────────────────────────
func _draw_companion(r: Rect2) -> void:
	var w := r.size.x
	var h := r.size.y
	var stage := preview_size == SIZE_STAGE
	var g := UiHomeField.meadow_ground(_season())
	draw_rect(r, g)
	draw_rect(Rect2(r.position, Vector2(w, roundf(h * 0.32))), UiHomeField.meadow_sky(g))
	var y2 := roundf(h * 0.68)
	draw_rect(Rect2(r.position + Vector2(0.0, y2), Vector2(w, h - y2)), UiHomeField.meadow_near(g))
	if stage:
		var roster := _roster()
		var fs := roundf(h * 0.42)
		if roster.size() > 0:
			UiHomeV3.draw_flower(self, r.position + Vector2(w * 0.13, h * 0.74 - fs * 0.5), roster[0], fs)
		if roster.size() > 4:
			var f2 := fs * 0.9
			UiHomeV3.draw_flower(self, r.position + Vector2(w * 0.87 - fs * 0.45 + f2 * 0.5, h * 0.70 - fs * 0.9 + f2 * 0.5), roster[4], f2)
	var side := roundf(h * (0.80 if stage else 0.84))
	_draw_creature(r, subject, look.get("recolor", {}), side, h - roundf(h * 0.05), CREATURE_SHADOW)


func _roster() -> Array[String]:
	var out: Array[String] = []
	var def: SeasonDef = GameState.get_season_def(_season())
	if def != null:
		out = def.seed_type_ids
	return out


## Lik (Pip SVG s recolorom ili Mochi) sa stopalima na `feet` i sjenkom.
func _draw_creature(r: Rect2, who: String, recolor: Dictionary, side: float, feet: float, shadow: Color) -> void:
	var ratio := 0.95 if who == "mochi" else 0.926
	var cx := r.position.x + r.size.x * 0.5
	var fy := r.position.y + feet
	if who == "pip" and actor != null and actor.visible:
		return
	var sh := Rect2(cx - side * 0.315, fy - side * 0.075, side * 0.63, side * 0.137)
	draw_style_box(UiStage.box(shadow, roundi(sh.size.y * 0.5)), sh)
	var arc := sin(PI * _hop_k)
	var sc := 1.0 + (UiWardrobe.STAGE_HOP_SCALE - 1.0) * arc
	var lift := -arc * side * 0.11
	var pivot := Vector2(cx, fy - side * ratio + side * ratio)
	var top_left := Vector2(cx - side * 0.5, fy - side * ratio)
	draw_set_transform(pivot + Vector2(0.0, lift), 0.0, Vector2(sc, sc))
	var local := Rect2(top_left - pivot, Vector2(side, side))
	if who == "mochi":
		MochiDraw.draw_mochi(self, local.get_center(), side / 56.0)
	else:
		var tex := PipAssets.texture_for_recolor(recolor)
		if tex != null:
			draw_texture_rect(tex, local, false)
		else:
			PipDraw.draw_pip(self, local.get_center(), side / 56.0)
	draw_set_transform_matrix(Transform2D.IDENTITY)


# ── meadow ────────────────────────────────────────────────────────────────────
func _draw_meadow(r: Rect2) -> void:
	var w := r.size.x
	var h := r.size.y
	var o := r.position
	var stage := preview_size == SIZE_STAGE
	var c := run_colors(look.get("tint", []), _season())
	draw_rect(r, c["ground"])
	draw_circle(o + Vector2(w * 0.10 + h * 0.31, h * 0.05 + h * 0.31), h * 0.31, c["blob"])
	draw_circle(o + Vector2(w * 0.78 + h * 0.35, h * 0.42 + h * 0.35), h * 0.35, c["blob"])
	var lanes: Array = [0.25, 0.5, 0.75] if stage else [0.5]
	var lw := roundf(w * 200.0 / 1080.0) if stage else roundf(w * 0.46)
	var ew := 4.0 if stage else 3.0
	var per := roundf(h * 0.31)
	var sh := roundf(h * 0.105)
	for f in lanes:
		var x := roundf(w * float(f) - lw * 0.5)
		draw_rect(Rect2(o + Vector2(x, 0.0), Vector2(lw, h)), c["lane"])
		draw_rect(Rect2(o + Vector2(x, 0.0), Vector2(ew, h)), c["edge"])
		draw_rect(Rect2(o + Vector2(x + lw - ew, 0.0), Vector2(ew, h)), c["edge"])
		var y := roundf(h * 0.05)
		while y < h:
			draw_rect(Rect2(o + Vector2(x + ew, y), Vector2(lw - ew * 2.0, minf(sh, h - y))), c["mow"])
			y += per
	if stage:
		for sx in [405.0, 675.0]:
			_dashed_v(o + Vector2(w * sx / 1080.0, 0.0), h, c["seam"])
	var z := 1.2 if stage else 0.8
	if stage:
		_tuft(o + Vector2(w * 0.045, h * 0.22), z, c["tuft"])
		_petal(o + Vector2(w * 0.08, h * 0.78), z, c["petal"])
		_tuft(o + Vector2(w * 0.955, h * 0.66), z, c["tuft"])
		_petal(o + Vector2(w * 0.93, h * 0.3), z, c["petal"])
		_tuft(o + Vector2(w * 0.62, h * 0.86), z, c["tuft"])
	else:
		_tuft(o + Vector2(w * 0.1, h * 0.3), z, c["tuft"])
		_petal(o + Vector2(w * 0.12, h * 0.8), z, c["petal"])
		_tuft(o + Vector2(w * 0.9, h * 0.72), z, c["tuft"])
		_petal(o + Vector2(w * 0.88, h * 0.22), z, c["petal"])
	var side := roundf(h * (0.56 if stage else 0.62))
	_draw_creature(r, "pip", pip_recolor, side, h - roundf(h * 0.06), RUN_SHADOW)


## Boje pregleda staze = run sezone (kit: ground / lane) × tint kozmetike — isto što
## lane_background crta u runu (Season Kit faza 2: bez tinta sezone). + blob / seam.
static func run_colors(tint: Variant, season: String) -> Dictionary:
	var t := Color.WHITE
	if tint is Array and (tint as Array).size() >= 3:
		var a: Array = tint
		t = Color(float(a[0]), float(a[1]), float(a[2]), 1.0)
	var m: Color = t
	m.a = 1.0
	var run := UiSeasons.run_def(season)
	var ground := UiSeasons.col(str(run["ground"])) if run.has("ground") else UiRun.GROUND
	var lane := UiSeasons.col(str(run["lane"])) if run.has("lane") else UiRun.LANE
	return {
		"ground": _mul(ground, m),
		"lane": _mul(lane, m),
		"edge": _mul(lane.lerp(CREAM, 0.20), m),
		"mow": _mul(lane.lerp(CREAM, 0.055), m),
		"tuft": _mul(UiRun.TUFT, m),
		"petal": _mul(UiRun.PETAL, m),
		"blob": _mul(ground.lerp(CREAM, 0.05), m),
		"seam": _mul(ground.lerp(CREAM, 0.16), m),
	}


static func _mul(c: Color, m: Color) -> Color:
	return Color(clampf(c.r * m.r, 0.0, 1.0), clampf(c.g * m.g, 0.0, 1.0), clampf(c.b * m.b, 0.0, 1.0), 1.0)


func _tuft(p: Vector2, z: float, col: Color) -> void:
	draw_circle(p + Vector2(-8.0 * z + 7.0 * z, 4.0 * z), 7.0 * z, col)
	draw_circle(p + Vector2(8.0 * z, 4.0 * z), 7.0 * z, col)
	draw_circle(p + Vector2(0.0, -8.0 * z), 8.0 * z, col)


func _petal(p: Vector2, z: float, col: Color) -> void:
	draw_circle(p, 6.0 * z, col)
	draw_circle(p + Vector2(0.0, -8.0 * z), 4.5 * z, col)


func _dashed_v(top: Vector2, h: float, col: Color) -> void:
	var y := 0.0
	while y < h:
		draw_rect(Rect2(top + Vector2(0.0, y), Vector2(3.0, minf(9.0, h - y))), col)
		y += 15.0


# ── album ─────────────────────────────────────────────────────────────────────
func _draw_album(r: Rect2) -> void:
	var w := r.size.x
	var h := r.size.y
	var stage := preview_size == SIZE_STAGE
	draw_rect(r, UiWardrobe.ALBUM_BG)
	var pw := 560.0 if stage else w - 24.0
	var ph := h - (40.0 if stage else 24.0)
	var page := Rect2(r.position + Vector2((w - pw) * 0.5, (h - ph) * 0.5), Vector2(pw, ph))
	var s := 1.2 if stage else 0.62
	var fr: Dictionary = look.get("frame", {})
	var bw := maxf(4.0, roundf(float(fr.get("width", 0)) * s)) if not fr.is_empty() else 0.0
	var paper := Color(str(look.get("paper", "#FFF8F0")))
	var sb := UiStage.box(paper, roundi(14.0 * s), int(bw), Color(str(fr.get("color", "#E8C44A"))))
	draw_style_box(sb, page)
	var pad := roundf(14.0 * s) + bw
	var th := roundf(34.0 * s)
	var tw := th * 13.0
	var cw := pw - pad * 2.0
	if _title_tex == null and ResourceLoader.exists(TITLE_PATH):
		_title_tex = load(TITLE_PATH) as Texture2D
	if _title_tex != null:
		var tm: Variant = look.get("title_modulate", null)
		var mod := Color.WHITE
		if tm is Array and (tm as Array).size() >= 3:
			mod = Color(float(tm[0]), float(tm[1]), float(tm[2]), 1.0)
		var tw2 := minf(tw, cw)
		var th2 := minf(th, cw / 13.0)
		draw_texture_rect(_title_tex, Rect2(page.position + Vector2(pad + (cw - tw2) * 0.5, pad), Vector2(tw2, th2)), false, mod)
	var gap := roundf(10.0 * s)
	var rh := roundf((ph - pad * 2.0 - th - 4.0 * 10.0 * s) / 4.0)
	for i in ALBUM_ROWS.size():
		var row := Rect2(page.position + Vector2(pad, pad + th + gap + float(i) * (rh + gap)), Vector2(cw, rh))
		draw_style_box(UiStage.box(ALBUM_ROWS[i], roundi(10.0 * s)), row)


# ── swatch ────────────────────────────────────────────────────────────────────
func _draw_swatch(r: Rect2) -> void:
	var w := r.size.x
	var h := r.size.y
	var stage := preview_size == SIZE_STAGE
	draw_rect(r, UiWardrobe.ALBUM_BG)
	var cols: Array = look.get("colors", ["#FFF8F0"])
	if cols.is_empty():
		cols = ["#FFF8F0"]
	var sw := 420.0 if stage else w - 48.0
	var shh := h - 90.0 if stage else h - 44.0
	var rect := Rect2(r.position + Vector2((w - sw) * 0.5, (h - shh) * 0.5), Vector2(sw, shh))
	var rad := 28 if stage else 16
	draw_style_box(UiStage.box(Color(str(cols[0])), rad, 3, UiWardrobe.INK), rect)
	if cols.size() > 1:
		var low := Rect2(rect.position + Vector2(3.0, shh * 0.62), Vector2(sw - 6.0, shh * 0.38 - 3.0))
		var sb := UiStage.box(Color(str(cols[1])), 0)
		sb.corner_radius_bottom_left = rad - 3
		sb.corner_radius_bottom_right = rad - 3
		draw_style_box(sb, low)


# ── veo (kartica "none") i okvir ──────────────────────────────────────────────
func _draw_veil(r: Rect2) -> void:
	draw_rect(r, UiWardrobe.LOCK_VEIL)
	var box := Rect2(r.get_center() - Vector2(36, 36), Vector2(72, 72))
	draw_style_box(UiStage.box(UiWardrobe.VEIL_LOCK_FILL, 20, 3, UiWardrobe.VEIL_LOCK_EDGE), box)
	if _lock_tex == null and ResourceLoader.exists(LOCK_PATH):
		_lock_tex = load(LOCK_PATH) as Texture2D
	if _lock_tex != null:
		draw_texture_rect(_lock_tex, Rect2(r.get_center() - Vector2(20, 20), Vector2(40, 40)), false)


func _draw_frame() -> void:
	var rad := frame_radius
	if rad > 0.5:
		for corner in 4:
			draw_colored_polygon(_corner_mask(corner, rad), corner_bg)
	if frame_border > 0.0:
		var sb := UiStage.box(Color.TRANSPARENT, roundi(rad), roundi(frame_border), frame_color)
		sb.draw_center = false
		draw_style_box(sb, Rect2(Vector2.ZERO, size))


## Područje između ugla pravougaonika i luka radijusa `rad` (prekriva se bojom roditelja).
func _corner_mask(corner: int, rad: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 10
	var c: Vector2
	var a0: float
	var tip: Vector2
	match corner:
		0:
			c = Vector2(rad, rad); a0 = PI; tip = Vector2.ZERO
		1:
			c = Vector2(size.x - rad, rad); a0 = PI * 1.5; tip = Vector2(size.x, 0.0)
		2:
			c = Vector2(size.x - rad, size.y - rad); a0 = 0.0; tip = size
		_:
			c = Vector2(rad, size.y - rad); a0 = PI * 0.5; tip = Vector2(0.0, size.y)
	pts.append(tip)
	for i in steps + 1:
		var a := a0 + (PI * 0.5) * float(i) / float(steps)
		pts.append(c + Vector2(cos(a), sin(a)) * (rad + 0.5))
	return pts
