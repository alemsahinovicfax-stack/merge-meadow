extends SceneTree

## design_handoff_hub_chrome_v2: ikone valuta i tabova su u boji i FIKSNE — kod smije
## mijenjati samo modulate.a. Ovaj smoke cuva tri stvari: svih 13 SVG-ova se ucitava
## na 128 x 128, nijedna ikona u hubu nije RGB-tintana, i mjesta koja su prije koristila
## icon_crystal / icon_seed_light sada gadjaju nove fajlove.

const UI_ASSETS := preload("res://scripts/visual/ui_assets.gd")
const ICONS: Array[String] = [
	"icon_coin", "icon_seed", "icon_flower",
	"icon_settings", "icon_settings_light", "icon_lock",
	"tab_shop", "tab_shop_light", "tab_journal", "tab_journal_light",
	"tab_home", "tab_home_light", "tab_camp", "tab_camp_light",
	"tab_arena", "tab_arena_light",
]
const GONE: Array[String] = ["icon_seed_light"]

var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_files()
	await _check_hub_icons()
	if _failed:
		quit(1)
		return
	print("hub_chrome_icons_smoke OK")
	quit(0)


func _check_files() -> void:
	for name in ICONS:
		var path := "res://assets/ui/chrome/%s.svg" % name
		if not ResourceLoader.exists(path):
			_fail("missing %s" % path)
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			_fail("not importable: %s" % path)
			continue
		if tex.get_width() != 128 or tex.get_height() != 128:
			_fail("%s should be 128 x 128, got %s" % [name, str(tex.get_size())])
	for name in GONE:
		if ResourceLoader.exists("res://assets/ui/chrome/%s.svg" % name):
			_fail("%s should be deleted (v2 uses the coloured icon)" % name)


## Nijedan TextureRect u hubu ne smije nositi RGB tintu preko ikone u boji.
func _check_hub_icons() -> void:
	var err := change_scene_to_file("res://scenes/meta/meta_hub.tscn")
	if err != OK:
		_fail("hub load failed %d" % err)
		return
	for _i in 12:
		await process_frame
	var hubs := get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		_fail("no meta_hub")
		return
	var hub := hubs[0] as Control
	# Samo chrome (header + footer) — stranice imaju svoje Kenney ikone koje se smiju tintati.
	var rects: Array[TextureRect] = []
	for path in ["RootVBox/TopBar", "RootVBox/PageIndicator"]:
		var root := hub.get_node_or_null(path) as Control
		if root == null:
			_fail("missing %s" % path)
			continue
		rects.append_array(_all_texture_rects(root))
	if rects.size() < 9:
		_fail("expected 3 chip icons + settings + 5 tab icons, found %d" % rects.size())
	for rect in rects:
		if rect.texture == null:
			continue
		var m := rect.modulate
		if not (is_equal_approx(m.r, 1.0) and is_equal_approx(m.g, 1.0) and is_equal_approx(m.b, 1.0)):
			_fail("%s is RGB-tinted (%s)" % [rect.name, str(m)])


func _all_texture_rects(node: Node) -> Array[TextureRect]:
	var out: Array[TextureRect] = []
	if node is TextureRect:
		out.append(node as TextureRect)
	for child in node.get_children():
		out.append_array(_all_texture_rects(child))
	return out


func _fail(msg: String) -> void:
	_failed = true
	push_error("hub_chrome_icons_smoke: " + msg)
