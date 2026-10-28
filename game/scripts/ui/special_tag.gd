class_name SpecialTag
extends Control

## Oznaka „Special" (design_handoff_ads_only · premium_tag.json): zvjezdica + „Special" na
## #C2E2FA, tekst ink (11 : 1), rub 3, bez sjene, pilula. Jedna oznaka i jedna boja za „posebno
## za coine" — Shop Sir Pip (L), Camp kartica teme (M), Ormar (S); Home tab nosi samo zvjezdicu i
## boju. Ljubičasta MONEY nije oznaka (samo lice € dugmeta kad se IAP vrati).

const LABEL := "Special"
const FILL := Color("#C2E2FA")
const BORDER := 3
const SIZES := {
	"L": {"h": 60.0, "font": 34.0, "icon": 36.0, "pad_l": 14.0, "pad_r": 24.0, "gap": 8.0},
	"M": {"h": 52.0, "font": 32.0, "icon": 32.0, "pad_l": 12.0, "pad_r": 20.0, "gap": 8.0},
	"S": {"h": 44.0, "font": 26.0, "icon": 26.0, "pad_l": 10.0, "pad_r": 16.0, "gap": 6.0},
}

var size_key: String = "M":
	set(v):
		size_key = v
		_fit()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_fit()


static func tag_size(key: String) -> Vector2:
	var d: Dictionary = SIZES.get(key, SIZES["M"])
	var w := float(d["pad_l"]) + float(d["icon"]) + float(d["gap"]) \
		+ UiHomeV3.text_w(900, float(d["font"]), LABEL) + float(d["pad_r"])
	return Vector2(ceilf(w), float(d["h"]))


## Crta oznaku u `pos` na bilo kojem CanvasItemu (kartice koje se same crtaju).
static func draw_tag(ci: CanvasItem, pos: Vector2, key: String) -> void:
	var d: Dictionary = SIZES.get(key, SIZES["M"])
	var sz := tag_size(key)
	ci.draw_style_box(UiStage.box(FILL, roundi(sz.y * 0.5), BORDER, UiCoinPrice.INK), Rect2(pos, sz))
	var icon := float(d["icon"])
	var x := pos.x + float(d["pad_l"])
	var tex := UiAssets.get_chrome_icon("icon_special")
	if tex != null:
		ci.draw_texture_rect(tex, Rect2(x, pos.y + (sz.y - icon) * 0.5, icon, icon), false)
	var font := float(d["font"])
	UiHomeV3.draw_text(ci, 900, font, LABEL, Vector2(x + icon + float(d["gap"]), pos.y + (sz.y - font) * 0.5), UiCoinPrice.INK)


func _fit() -> void:
	custom_minimum_size = tag_size(size_key)
	size = custom_minimum_size
	queue_redraw()


func _draw() -> void:
	draw_tag(self, Vector2.ZERO, size_key)
