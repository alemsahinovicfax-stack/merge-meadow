extends SceneTree

## Ikone i splash iz Claude Design mastera (hero Pip v3 s kristalnim božurom) — headless:
##   godot --headless --path game --script res://scripts/dev/make_app_icons.gd
## Izvor: marketing/store/design/source/icon/ (512 + adaptivni fg/bg/mono 432, CD round 3).
## Piše u res://assets/branding/ (launcher, adaptivni slojevi, splash) i
## marketing/store/app-icon-512.png (Play store ikona). Poslije: scripts/godot-import.ps1.

const SRC_DIR := "../marketing/store/design/source/icon"
const OUT_DIR := "res://assets/branding"
const STORE_ICON := "../marketing/store/app-icon-512.png"

## Boja Pipove linije (CD ink) — obrub splash značke.
const OUTLINE := Color("#2D3436")


func _initialize() -> void:
	var icon := _load("icon_512.png")
	var fg := _load("icon_adaptive_fg_432.png")
	var bg := _load("icon_adaptive_bg_432.png")
	var mono := _load("icon_mono_432.png")
	if icon == null or fg == null or bg == null or mono == null:
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)

	# Adaptivni slojevi i store ikona idu 1:1 — CD ih je već kadrirao (lice + cvijet u 66 % krugu).
	_save(fg, OUT_DIR + "/icon_adaptive_fg_432.png")
	_save(bg, OUT_DIR + "/icon_adaptive_bg_432.png")
	_save(mono, OUT_DIR + "/icon_mono_432.png")
	_save(icon, OUT_DIR + "/icon_512.png")
	_save(icon, ProjectSettings.globalize_path("res://").path_join(STORE_ICON))

	# Stari launcheri (192): smanjena store ikona sa zaobljenim uglovima.
	var legacy := icon.duplicate() as Image
	legacy.resize(192, 192, Image.INTERPOLATE_LANCZOS)
	_round_corners(legacy, 34)
	_save(legacy, OUT_DIR + "/icon_192.png")

	# Splash: okrugla značka (adaptivna pozadina + Pip) s obrubom boje Pipove linije, providno okolo.
	var badge := bg.duplicate() as Image
	badge.blend_rect(fg, Rect2i(Vector2i.ZERO, fg.get_size()), Vector2i.ZERO)
	badge.resize(480, 480, Image.INTERPOLATE_LANCZOS)
	_circle_mask(badge, 240.0, 12.0)
	var splash := _canvas(560)
	_stamp(splash, badge, Vector2(280, 280))
	_save(splash, OUT_DIR + "/splash_pip.png")

	print("make_app_icons OK")
	quit(0)


func _load(file: String) -> Image:
	var path := ProjectSettings.globalize_path("res://").path_join(SRC_DIR).path_join(file)
	var img := Image.load_from_file(path)
	if img == null:
		push_error("make_app_icons: %s missing" % path)
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


func _canvas(size: int) -> Image:
	var img := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


func _stamp(dst: Image, src: Image, center: Vector2) -> void:
	var at := Vector2i(int(round(center.x - src.get_width() * 0.5)), int(round(center.y - src.get_height() * 0.5)))
	dst.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), at)


## Krug s obrubom (ring_px) u boji Pipove konture; van kruga providno, ivica antialias.
func _circle_mask(img: Image, radius: float, ring_px: float) -> void:
	var c := Vector2(img.get_width(), img.get_height()) * 0.5
	for y in img.get_height():
		for x in img.get_width():
			var d := Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(c)
			var px := img.get_pixel(x, y)
			if d > radius - ring_px:
				px = OUTLINE
			px.a *= clampf(radius - d, 0.0, 1.0)
			img.set_pixel(x, y, px)


func _round_corners(img: Image, radius: int) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var r := float(radius)
	for y in h:
		for x in w:
			var cx := clampf(float(x), r, float(w - 1) - r)
			var cy := clampf(float(y), r, float(h - 1) - r)
			var d := Vector2(float(x) - cx, float(y) - cy).length()
			if d > r:
				var c := img.get_pixel(x, y)
				c.a *= clampf(1.0 - (d - r), 0.0, 1.0)
				img.set_pixel(x, y, c)


func _save(img: Image, path: String) -> void:
	var err := img.save_png(path)
	if err != OK:
		push_error("make_app_icons: save %s failed %d" % [path, err])
