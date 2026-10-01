class_name PipAssets
extends RefCounted

## Shared Pip sprite — C2 art pass (Figma Make export).
## Ormar (design_handoff_wardrobe): skin = isti pip_idle.svg s zamijenjenim bojama
## (look.recolor iz cosmetics.json) → Image.load_svg_from_string → ImageTexture.
## Keš po (skin, scale); svaki novi skin = 2–3 hexa u JSON-u, 0 KB arta.
## Rezerva kad SVG izvor nije dostupan: pečeni res://assets/ui/wardrobe/pip_<id>.svg.

const SPRITE_PATH := "res://assets/sprites/pip_idle.svg"
const SPRITE_FALLBACK := "res://assets/sprites/pip_idle.png"
const BAKED_SKIN_DIR := "res://assets/ui/wardrobe/"
const RUN_DISPLAY_HEIGHT := 112.0
const SOURCE_FRAME_SIZE := 256.0
## Rasterizuje se 2× izvora (512 px) — oštro i na pozornici Ormara i na polju.
const SKIN_RASTER_SCALE := 2.0

## Sentinel: "skin koji je trenutno opremljen".
const EQUIPPED := "@equipped"

static var _texture: Texture2D
static var _svg_source: String = ""
static var _svg_tried: bool = false
static var _skin_cache: Dictionary = {}


## skin_id: EQUIPPED (default) = opremljeni skin; "" = klasični Pip; id = taj skin.
static func get_texture(skin_id: String = EQUIPPED) -> Texture2D:
	var skin := equipped_skin() if skin_id == EQUIPPED else skin_id
	if not skin.is_empty():
		var tex := get_skin_texture(skin)
		if tex != null:
			return tex
	return _base_texture()


static func equipped_skin() -> String:
	var gs := _game_state()
	if gs == null:
		return ""
	return str(gs.call("get_equipped_cosmetic", CosmeticCatalog.SLOT_PIP_SKIN))


static func _game_state() -> Node:
	var loop := Engine.get_main_loop() as SceneTree
	if loop == null or loop.root == null:
		return null
	return loop.root.get_node_or_null("GameState")


static func _base_texture() -> Texture2D:
	if _texture != null:
		return _texture
	for path in [SPRITE_PATH, SPRITE_FALLBACK]:
		if ResourceLoader.exists(path):
			_texture = load(path) as Texture2D
			if _texture != null:
				return _texture
	push_warning("PipAssets: sprite not loaded — using PipDraw fallback")
	return null


## Tekstura skina po look.recolor; null kad skin nema recolor ni pečeni fajl.
static func get_skin_texture(skin_id: String, raster_scale: float = SKIN_RASTER_SCALE) -> Texture2D:
	var key := "%s@%s" % [skin_id, str(raster_scale)]
	if _skin_cache.has(key):
		return _skin_cache[key] as Texture2D
	var tex: Texture2D = null
	var recolor := CosmeticCatalog.get_recolor(skin_id)
	if not recolor.is_empty():
		tex = texture_for_recolor(recolor, raster_scale)
	if tex == null:
		var baked := BAKED_SKIN_DIR + skin_id + ".svg"
		if ResourceLoader.exists(baked):
			tex = load(baked) as Texture2D
	if tex != null:
		_skin_cache[key] = tex
	return tex


## Pip s proizvoljnom mapom boja (pregled Ormara, demo stavke) — keš po mapi.
static func texture_for_recolor(recolor: Dictionary, raster_scale: float = SKIN_RASTER_SCALE) -> Texture2D:
	if recolor.is_empty():
		return _base_texture()
	var key := "map:%s@%s" % [JSON.stringify(recolor, "", true), str(raster_scale)]
	if _skin_cache.has(key):
		return _skin_cache[key] as Texture2D
	var src := svg_source()
	if src.is_empty():
		return null
	var tex := texture_from_svg(recolor_svg(src, recolor), raster_scale)
	if tex != null:
		_skin_cache[key] = tex
	return tex


## Tekst izvornog pip_idle.svg (export: include_filter u export_presets.cfg).
static func svg_source() -> String:
	if _svg_tried:
		return _svg_source
	_svg_tried = true
	if FileAccess.file_exists(SPRITE_PATH):
		_svg_source = FileAccess.get_file_as_string(SPRITE_PATH)
	return _svg_source


## Zamjena boja (case-insensitive hex) — obrub, oči i crtež ostaju netaknuti.
static func recolor_svg(svg: String, recolor: Dictionary) -> String:
	var out := svg
	for from_hex in recolor:
		var to_hex := str(recolor[from_hex])
		var f := str(from_hex)
		out = out.replace(f.to_upper(), to_hex).replace(f.to_lower(), to_hex)
	return out


static func texture_from_svg(svg: String, raster_scale: float) -> Texture2D:
	var img := Image.new()
	if img.load_svg_from_string(svg, raster_scale) != OK or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)


static func clear_skin_cache() -> void:
	_skin_cache.clear()


static func has_sprite() -> bool:
	return get_texture() != null


static func run_scale() -> float:
	return RUN_DISPLAY_HEIGHT / SOURCE_FRAME_SIZE


static func ui_scale_for_side(side: float) -> float:
	if side < 1.0:
		return 1.0
	return side / SOURCE_FRAME_SIZE
