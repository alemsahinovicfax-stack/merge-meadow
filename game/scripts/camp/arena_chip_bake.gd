class_name ArenaChipBake
extends Node

## Osnova sjemenke u Areni (SeedBase, sjena, rim, well, T2 hairline, mythic crtice) je 4–6
## StyleBoxFlat s AA rubom: ~0,6 ms CPU po crtanju (perf 2026-10-09 — posle mergea se prekrta
## ~25 sjemenki ≈ 16 ms i frejm ispadne). Ovaj čvor svaku varijantu (tier × mythic × drag, 8 ih je)
## iscrta jednom u SubViewport i sačuva kao ImageTexture; ArenaChipDraw onda crta jednu teksturu.
## Keš je statičan (cijela sesija igre). Dok bake ne završi, crta se stari put (isti izgled).

const PAD := 12.0                                   # SeedBase 4 · mythic crtice grow 7 + pola širine 4
const DROP := UiArena.CHIP_SHADOW_OFFSET_DRAG      # najdublja sjena (drag) ide ispod recta
const VARIANTS := 8

static var _cache: Dictionary = {}
static var _baking: bool = false


static func key(tier: int, mythic: bool, dragging: bool) -> String:
	return "%d_%s_%s" % [tier, mythic, dragging]


static func get_base(tier: int, mythic: bool, dragging: bool) -> Texture2D:
	return _cache.get(key(tier, mythic, dragging)) as Texture2D


## Gornji lijevi ugao teksture = rect sjemenke − origin().
static func origin() -> Vector2:
	return Vector2(PAD, PAD)


static func is_ready() -> bool:
	return _cache.size() >= VARIANTS


## Pokreće bake ispod `host` (Arena), ako već nije gotov ili u toku.
static func ensure(host: Node) -> void:
	if is_ready() or _baking or host == null:
		return
	var baker := ArenaChipBake.new()
	baker.name = "ChipBake"
	# Arena stranica van ekrana ima PROCESS_MODE_DISABLED — bake ide i tada.
	baker.process_mode = Node.PROCESS_MODE_ALWAYS
	host.add_child(baker)
	baker.bake()


## Jedna varijanta po frejmu (8 frejmova, svaki ~1 readback) — pri otvaranju Arene, ne u igri.
func bake() -> void:
	_baking = true
	var side := ArenaSeedChip.CHIP_RADIUS * 2.0
	var vp := SubViewport.new()
	vp.name = "BakeViewport"
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.size = Vector2i(ceili(side + PAD * 2.0), ceili(side + PAD * 2.0 + DROP))
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var painter := _Painter.new()
	painter.size = Vector2(vp.size)
	vp.add_child(painter)
	add_child(vp)
	for tier in [1, 2]:
		for mythic in [false, true]:
			for dragging in [false, true]:
				painter.variant = [tier, mythic, dragging]
				painter.queue_redraw()
				vp.render_target_update_mode = SubViewport.UPDATE_ONCE
				await RenderingServer.frame_post_draw
				if not is_inside_tree():
					_baking = false
					return
				var img := vp.get_texture().get_image()
				if img != null and not img.is_empty():
					_cache[key(tier, mythic, dragging)] = ImageTexture.create_from_image(img)
	_baking = false
	queue_free()


class _Painter:
	extends Control

	var variant: Array = [1, false, false]

	func _draw() -> void:
		var side := ArenaSeedChip.CHIP_RADIUS * 2.0
		var rect := Rect2(ArenaChipBake.origin(), Vector2(side, side))
		ArenaChipDraw.draw_base(self, rect, int(variant[0]), bool(variant[1]), bool(variant[2]))
