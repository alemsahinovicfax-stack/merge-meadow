class_name UiCoinPrice
extends RefCounted

## Jedno dugme cijene za Shop, Home i Camp (design_handoff_ads_only · godot/coin_price.json).
## Tri veličine, širina fiksna u svim stanjima (potvrda +0 px). Broj uvijek kroz
## UiChrome.format_count („10,000"). Stanja:
##   buy · short · confirm · buying · owned · play · eur (samo kad su kupovine pravim novcem uključene)
## Ravne boje, rub 4 ink, jedna tvrda sjena 0 8 0; short / buying / owned su spušteni 8 px bez sjene.
## Jedina prozirnost: prsten kupovine (1 krug, 0,42 s) blijedi 1 → 0.

const S := "S"
const M := "M"
const L := "L"

## w, h, font, icon, gap — S: Camp i Shop sezona · M: Shop Looks i Boosters · L: Home kartica teme.
const SIZES := {
	"S": {"w": 300.0, "h": 120.0, "font": 44.0, "icon": 48.0, "gap": 12.0},
	"M": {"w": 320.0, "h": 120.0, "font": 52.0, "icon": 56.0, "gap": 12.0},
	"L": {"w": 360.0, "h": 132.0, "font": 56.0, "icon": 64.0, "gap": 14.0},
}

const BUY := "buy"
const SHORT := "short"
const CONFIRM := "confirm"
const BUYING := "buying"
const OWNED := "owned"
const PLAY := "play"
const EUR := "eur"

const INK := Color("#2D3436")
const INK_SUB := Color("#555C5E")
const GOLD := Color("#FFD56B")
const SHORT_BG := Color("#F1EAE0")
const MINT := Color("#A8E6CF")
const PEACH := Color("#FFB88C")
const MONEY := Color("#D4A5FF")
const RING := Color("#FFF5D1")
const SHADOW := Color(0.102, 0.102, 0.078, 0.28)

const BORDER := 4.0
const SHADOW_Y := 8.0
const DOWN_Y := 8.0
## „Yours" / „Wearing" najviše 48 px, „Play" najviše 52 px (S: oba 44).
const OWNED_FONT_MAX := 48.0
const PLAY_FONT_MAX := 52.0
const BAR_H := 8.0
const BAR_BOTTOM := 12.0
const RING_BORDER := 12.0
const RING_FROM := 0.3
const RING_TO := 1.6

const T_POP := 0.22
const T_RING := 0.42
## Kupovina: pop + prsten paralelno, pa kupljeno.
const T_BUYING := 0.6
const T_SHAKE := 0.32


static func spec(size_key: String) -> Dictionary:
	return SIZES.get(size_key, SIZES[M]) as Dictionary


static func button_size(size_key: String) -> Vector2:
	var d := spec(size_key)
	return Vector2(float(d["w"]), float(d["h"]))


## Prostor koji dugme zauzima (lice + sjena / spuštanje 8 px).
static func footprint(size_key: String) -> Vector2:
	return button_size(size_key) + Vector2(0.0, SHADOW_Y)


## Cijena u coinima kao u headeru: 10000 → „10,000".
static func price_text(coins: int) -> String:
	return UiChrome.format_count(coins)


static func fill(state: String) -> Color:
	match state:
		BUY:
			return GOLD
		SHORT:
			return SHORT_BG
		CONFIRM:
			return INK
		BUYING, OWNED:
			return MINT
		PLAY:
			return PEACH
		EUR:
			return MONEY
	return GOLD


static func ink(state: String) -> Color:
	match state:
		CONFIRM:
			return GOLD
		SHORT:
			return INK_SUB
	return INK


## Stanje bez sjene leži 8 px niže (kao pritisnuto).
static func is_flat(state: String) -> bool:
	return state in [SHORT, BUYING, OWNED]


## Crta dugme u `origin` (gornji lijevi ugao zone; zona = footprint). `press` 0..1 spušta lice
## do 4 px; `bar_k` 1 → 0 je traka potvrde (samo confirm); `ring_k` 0..1 prsten kupovine
## (< 0 = nema). `label` je cijena („10,000"), „Yours" / „Wearing" ili € string.
static func draw(
	ci: CanvasItem, origin: Vector2, size_key: String, state: String, label: String,
	press: float = 0.0, bar_k: float = 0.0, ring_k: float = -1.0
) -> void:
	var d := spec(size_key)
	var sz := button_size(size_key)
	var radius := roundi(sz.y * 0.5)
	var flat := is_flat(state)
	var face := Rect2(origin + Vector2(0.0, DOWN_Y if flat else press * 4.0), sz)
	if not flat:
		ci.draw_style_box(UiStage.box(SHADOW, radius), Rect2(origin + Vector2(0.0, SHADOW_Y), sz))
	var edge := Color(INK, 0.35) if state == SHORT else INK
	ci.draw_style_box(UiStage.box(fill(state), radius, roundi(BORDER), edge), face)
	var col := ink(state)
	var font := float(d["font"])
	var icon := float(d["icon"])
	var gap := float(d["gap"])
	var cy := face.get_center().y
	match state:
		BUY, SHORT, CONFIRM:
			var tw := UiHomeV3.text_w(900, font, label, 0.0, true)
			var x := face.get_center().x - (icon + gap + tw) * 0.5
			var tex := UiAssets.get_chrome_icon("check_confirm" if state == CONFIRM else "icon_coin")
			_icon(ci, tex, Vector2(x, cy - icon * 0.5), icon)
			UiHomeV3.draw_text(ci, 900, font, label, Vector2(x + icon + gap, cy - font * 0.5), col, 0.0, true)
			if state == CONFIRM and bar_k > 0.0:
				var bar_w := (sz.x - sz.y) * clampf(bar_k, 0.0, 1.0)
				var bar := Rect2(face.position.x + sz.y * 0.5, face.end.y - BAR_BOTTOM - BAR_H, bar_w, BAR_H)
				ci.draw_style_box(UiStage.box(GOLD, roundi(BAR_H * 0.5)), bar)
		BUYING, OWNED:
			var px := minf(font, OWNED_FONT_MAX)
			var ic := icon * 0.8
			var tw := UiHomeV3.text_w(900, px, label)
			var x := face.get_center().x - (ic + gap + tw) * 0.5
			_icon(ci, UiAssets.get_chrome_icon("check_ink"), Vector2(x, cy - ic * 0.5), ic)
			UiHomeV3.draw_text(ci, 900, px, label, Vector2(x + ic + gap, cy - px * 0.5), col)
		PLAY:
			var px := minf(font, PLAY_FONT_MAX)
			var tri := px * 0.75
			var tw := UiHomeV3.text_w(900, px, UiShopV2.S_PLAY)
			var x := face.get_center().x - (tri + gap + tw) * 0.5
			ci.draw_colored_polygon(PackedVector2Array([
				Vector2(x, cy - tri * 0.58), Vector2(x + tri, cy), Vector2(x, cy + tri * 0.58)
			]), col)
			UiHomeV3.draw_text(ci, 900, px, UiShopV2.S_PLAY, Vector2(x + tri + gap, cy - px * 0.5), col)
		_:
			var tw := UiHomeV3.text_w(900, font, label, 0.0, true)
			UiHomeV3.draw_text(ci, 900, font, label, Vector2(face.get_center().x - tw * 0.5, cy - font * 0.5), col, 0.0, true)
	if ring_k >= 0.0 and ring_k < 1.0:
		var r := sz.y * lerpf(RING_FROM, RING_TO, ring_k)
		ci.draw_arc(face.get_center(), maxf(1.0, r - RING_BORDER * 0.5), 0.0, TAU, 48, Color(RING, 1.0 - ring_k), RING_BORDER, true)


static func _icon(ci: CanvasItem, tex: Texture2D, pos: Vector2, side: float) -> void:
	if tex == null:
		ci.draw_circle(pos + Vector2(side, side) * 0.5, side * 0.5, GOLD)
		return
	ci.draw_texture_rect(tex, Rect2(pos, Vector2(side, side)), false)
