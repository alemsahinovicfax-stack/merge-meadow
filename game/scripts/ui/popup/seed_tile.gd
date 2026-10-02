class_name SeedTile
extends HubPressable

## H4 · pločica u sheetu korpe (design_handoff_popups): 328 × 410, radius 32. Okvir korpe s polja
## (zlatni 194, rub 3, tamni bunar 168) s pravim crtežom 134 (isti T3 kao korpa na polju), ime
## 40/900, zvjezdice 38/900 `#7A4A28`. Zaključana: siva pločica, sivi okvir s katancem 80, sivi tekst.
## Izabrana: RIM pločica, rub 4 ink, mint ✓ 72 na gornjem desnom uglu. Tap = izbor (zaključana ne reaguje).

const PICKER_ICON := preload("res://scripts/ui/home_basket_picker_icon.gd")
const FRAME_Y := 27.0
const WELL := 168.0
const ART := 134.0
const NAME_TOP := 243.0
const NAME_MAX_W := 290.0
const STARS_BOTTOM := 30.0
const CHECK := 72.0

var type_id: String = ""
var display_name: String = ""
var stars: int = 1
var locked: bool = false
var chosen: bool = false
## Isti tekst kao stari red pickera („Ime ★★") — smoke testovi ga čitaju.
var label_text: String = ""

var _icon: Control


func setup(p_type: String, p_name: String, p_stars: int, p_locked: bool, p_chosen: bool) -> SeedTile:
	type_id = p_type
	display_name = p_name
	stars = p_stars
	locked = p_locked
	chosen = p_chosen and not p_locked
	label_text = "%s %s" % [p_name, "★".repeat(p_stars)]
	name = "SeedTile_%s" % p_type
	set_meta("seed_type_id", p_type)
	custom_minimum_size = Vector2(UiPopups.SEED_TILE)
	disabled = locked
	if _icon == null and not locked:
		_icon = PICKER_ICON.new()
		_icon.name = "PlantIcon"
		_icon.set("icon_side", ART)
		_icon.set("type_id", p_type)
		add_child(_icon)
	_layout_icon()
	queue_redraw()
	return self


func is_locked() -> bool:
	return locked


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_icon()


func _layout_icon() -> void:
	if _icon == null:
		return
	var f := float(UiPopups.SEED_FRAME)
	var c := Vector2(size.x * 0.5, FRAME_Y + f * 0.5)
	_icon.position = c - Vector2(ART, ART) * 0.5
	_icon.size = Vector2(ART, ART)


func _apply_state() -> void:
	queue_redraw()


func _draw() -> void:
	var state := "locked" if locked else ("chosen" if chosen else "open")
	var dy := 4.0 if is_pressing() and not locked else 0.0
	draw_style_box(UiPopups.seed_tile(state), Rect2(Vector2(0, dy), size))
	var f := float(UiPopups.SEED_FRAME)
	var fr := Rect2((size.x - f) * 0.5, FRAME_Y + dy, f, f)
	draw_style_box(UiPopups.seed_frame(locked), fr)
	if locked:
		UiPopups.draw_icon(self, UiPopups.icon("icon_lock"), fr.get_center(), 80.0)
	else:
		var w := Rect2(fr.get_center() - Vector2(WELL, WELL) * 0.5, Vector2(WELL, WELL))
		draw_style_box(UiPopups._box(UiPopups.WELL, 24), w)
	var ink := UiPopups.INK_SOFT if locked else UiPopups.OUTLINE
	var lines := UiPopups.wrap_lines(900, 40, display_name, NAME_MAX_W)
	var y := NAME_TOP + dy + (0.0 if lines.size() > 1 else 21.0)
	for line in lines:
		var lw := UiPopups.text_w(900, 40, line)
		UiPopups.draw_text(self, 900, 40, line, Vector2((size.x - lw) * 0.5, y), ink)
		y += 42.0
	var star_text := "★".repeat(stars) + "☆".repeat(maxi(0, 3 - stars))
	var sw := UiPopups.text_w(900, 38, star_text)
	UiPopups.draw_text(self, 900, 38, star_text, Vector2((size.x - sw) * 0.5, size.y - STARS_BOTTOM - 38.0 - 14.0 + dy), UiPopups.INK_SOFT if locked else UiPopups.STAR_INK)
	if chosen:
		var c := Vector2(size.x - 14.0, 26.0 + dy)
		draw_style_box(UiPopups._box(UiPopups.MINT, int(CHECK / 2.0), 4), Rect2(c - Vector2(CHECK, CHECK) * 0.5, Vector2(CHECK, CHECK)))
		UiPopups.draw_check(self, c, 38.0, UiPopups.OUTLINE, 6.0)
