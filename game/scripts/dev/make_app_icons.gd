extends SceneTree

## Ikone i splash iz Pip HUD portreta (vektor) — headless, bez vanjskih alata:
##   godot --headless --path game --script res://scripts/dev/make_app_icons.gd
## Piše u res://assets/branding/ (launcher, adaptivni slojevi, splash) i
## marketing/store/app-icon-512.png (Play store ikona). Poslije: scripts/godot-import.ps1.

const PIP_SVG := "res://assets/pip/hud/pip_hud_classic.svg"
## Portret je 88 px (viewBox 176) — skala daje veličinu glave u pikselima.
const PIP_BASE_PX := 88.0
const OUT_DIR := "res://assets/branding"
const STORE_ICON := "../marketing/store/app-icon-512.png"

const SKY_TOP := Color("#B8E0F5")
const SKY_LOW := Color("#E2F2FA")
const HILL := Color("#7CC46A")
const HILL_DARK := Color("#5DAE5B")
## Kremasta pozadina UI-ja (ui_home_v3 CREAM) — ista ide u boot_splash/bg_color.
const SPLASH_BG := Color("#FFF8F0")
const OUTLINE := Color("#2E3436")


func _initialize() -> void:
	var svg := FileAccess.get_file_as_string(PIP_SVG)
	if svg.is_empty():
		push_error("make_app_icons: %s missing" % PIP_SVG)
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(OUT_DIR)

	# Portret je kadriran (uši i tijelo odsječeni viewBoxom) — zato uvijek preko cijelog platna,
	# da rezovi padnu na ivicu ikone. Adaptivna maska (~66 % sredine) ionako vidi lice.
	var fg := _canvas(432)
	_stamp(fg, _pip(svg, 432.0), Vector2(216, 216))
	_save(fg, OUT_DIR + "/icon_adaptive_fg_432.png")

	var bg := _meadow(432, 0.62)
	_save(bg, OUT_DIR + "/icon_adaptive_bg_432.png")

	var mono := _canvas(432)
	_stamp(mono, _silhouette(_pip(svg, 432.0)), Vector2(216, 216))
	_save(mono, OUT_DIR + "/icon_mono_432.png")

	# Stari launcheri (192) i Play store (512, Play sam zaobli uglove).
	var legacy := _meadow(192, 0.62)
	_stamp(legacy, _pip(svg, 192.0), Vector2(96, 96))
	_round_corners(legacy, 34)
	_save(legacy, OUT_DIR + "/icon_192.png")

	var store := _meadow(512, 0.62)
	_stamp(store, _pip(svg, 512.0), Vector2(256, 256))
	_save(store, OUT_DIR + "/icon_512.png")
	_save(store, ProjectSettings.globalize_path("res://").path_join(STORE_ICON))

	# Splash: okrugla značka (livada + Pip, obrub boje Pipove linije) na kremastoj pozadini igre.
	var badge := _meadow(480, 0.62)
	_stamp(badge, _pip(svg, 480.0), Vector2(240, 240))
	_circle_mask(badge, 240.0, 12.0)
	var splash := _canvas(560)
	_stamp(splash, badge, Vector2(280, 280))
	_save(splash, OUT_DIR + "/splash_pip.png")

	print("make_app_icons OK")
	quit(0)


func _pip(svg: String, size_px: float) -> Image:
	var img := Image.new()
	var err := img.load_svg_from_string(svg, size_px / PIP_BASE_PX)
	if err != OK:
		push_error("make_app_icons: svg render failed %d" % err)
	img.convert(Image.FORMAT_RGBA8)
	return img


func _canvas(size: int) -> Image:
	var img := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


## Nebo koje svijetli prema horizontu + zaobljeno brdo livade (kao run pozadina).
func _meadow(size: int, horizon: float) -> Image:
	var img := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	var s := float(size)
	for y in size:
		var t := float(y) / s
		var sky := SKY_TOP.lerp(SKY_LOW, clampf(t / horizon, 0.0, 1.0))
		for x in size:
			var u := float(x) / s - 0.5
			# Brdo: parabola, vrh u sredini.
			var hill_y := horizon + 0.18 * u * u * 4.0
			if t >= hill_y:
				var depth := clampf((t - hill_y) / (1.0 - horizon), 0.0, 1.0)
				img.set_pixel(x, y, HILL.lerp(HILL_DARK, depth))
			else:
				img.set_pixel(x, y, sky)
	return img


func _stamp(dst: Image, src: Image, center: Vector2) -> void:
	var at := Vector2i(int(round(center.x - src.get_width() * 0.5)), int(round(center.y - src.get_height() * 0.5)))
	dst.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), at)


func _silhouette(src: Image) -> Image:
	var out := src.duplicate() as Image
	for y in out.get_height():
		for x in out.get_width():
			var a := out.get_pixel(x, y).a
			out.set_pixel(x, y, Color(1, 1, 1, a))
	return out


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
