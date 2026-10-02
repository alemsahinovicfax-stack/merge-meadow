class_name ShopTabBar
extends Control

## Shop v2 · ShopTabBar (1080 x 172): tenda s mint/krem prugama (18 × 60, zaobljeno dno r 30,
## ink rub 4, tvrda sjena 6) drži 4 taba 249 x 120. Neaktivni su bijeli s rubom 3; aktivan je
## peach klizač (rub 4, sjena 6) koji klizne 0,2 s cubic-out.

signal tab_selected(tab_id: String)

const STRIPES := 18
const AWNING_SHADOW := Color(0.102, 0.102, 0.078, 0.16)

var active: String = "seasons"
var _thumb_x: float = 0.0
var _thumb_tween: Tween
var _tabs: Array[ShopTabButton] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(1080, UiShopV2.TABBAR_H)
	size = custom_minimum_size
	for i in UiShopV2.TABS.size():
		var t := ShopTabButton.new()
		t.name = "ShopTab_%s" % UiShopV2.TABS[i]
		t.tab_id = UiShopV2.TABS[i]
		t.label = UiShopV2.TAB_LABELS[i]
		t.position = Vector2(UiShopV2.TAB_X0 + i * UiShopV2.TAB_STEP, UiShopV2.TAB_Y)
		t.size = Vector2(UiShopV2.TAB_W, UiShopV2.TAB_H)
		add_child(t)
		t.clicked.connect(_on_tab.bind(UiShopV2.TABS[i]))
		_tabs.append(t)
	_thumb_x = _x_for(active)


func get_tabs() -> Array[ShopTabButton]:
	return _tabs


func set_active(tab_id: String, animated: bool = true) -> void:
	active = tab_id
	if _thumb_tween != null and _thumb_tween.is_valid():
		_thumb_tween.kill()
	var goal := _x_for(tab_id)
	if not animated or not is_inside_tree():
		_set_thumb(goal)
		return
	_thumb_tween = create_tween()
	_thumb_tween.tween_method(_set_thumb, _thumb_x, goal, UiShopV2.T_TAB).set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)


func _on_tab(tab_id: String) -> void:
	tab_selected.emit(tab_id)


func _x_for(tab_id: String) -> float:
	return float(UiShopV2.TAB_X0 + maxi(0, UiShopV2.TABS.find(tab_id)) * UiShopV2.TAB_STEP)


func _set_thumb(x: float) -> void:
	_thumb_x = x
	queue_redraw()


func _draw() -> void:
	var h := float(UiShopV2.AWNING_H)
	for pass_i in 3:
		for i in STRIPES:
			var x := float(i * UiShopV2.AWNING_STRIPE_W)
			match pass_i:
				0:
					_stripe(Rect2(x - 4.0, 6.0, 68.0, h + 4.0), 34.0, AWNING_SHADOW)
				1:
					_stripe(Rect2(x - 4.0, 0.0, 68.0, h + 4.0), 34.0, UiShopV2.INK)
				2:
					_stripe(
						Rect2(x, 0.0, float(UiShopV2.AWNING_STRIPE_W), h), 30.0,
						UiShopV2.AWNING_B if i % 2 else UiShopV2.AWNING_A
					)
	for i in UiShopV2.TABS.size():
		var r := Rect2(Vector2(UiShopV2.TAB_X0 + i * UiShopV2.TAB_STEP, UiShopV2.TAB_Y), Vector2(UiShopV2.TAB_W, UiShopV2.TAB_H))
		draw_style_box(UiShopV2.tab_style(false), r)
	var thumb := Rect2(Vector2(_thumb_x, UiShopV2.TAB_Y), Vector2(UiShopV2.TAB_W, UiShopV2.TAB_H))
	draw_style_box(UiShopV2.box(Color(UiShopV2.SHADOW_CARD, 0.24), UiShopV2.RADIUS_BUTTON), Rect2(thumb.position + Vector2(0, 6), thumb.size))
	draw_style_box(UiShopV2.box(UiShopV2.TAB_ACTIVE, UiShopV2.RADIUS_BUTTON, 4), thumb)


## Pruga s ravnim vrhom i polukružnim dnom (CSS border-radius 0 0 r r).
func _stripe(r: Rect2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array([r.position, Vector2(r.end.x, r.position.y)])
	var cy := r.end.y - rad
	for k in 13:
		var a := PI * float(k) / 12.0
		pts.append(Vector2(r.position.x + r.size.x * 0.5 + cos(a) * r.size.x * 0.5, cy + sin(a) * rad))
	draw_colored_polygon(pts, col)


## Tab: samo labela i dodir — pozadinu i klizač crta ShopTabBar.
class ShopTabButton:
	extends HubPressable

	var tab_id: String = ""
	var label: String = ""

	func _draw() -> void:
		var w := UiHomeV3.text_w(900, 44, label)
		UiHomeV3.draw_text(self, 900, 44, label, Vector2((size.x - w) * 0.5, (size.y - 44.0) * 0.5), UiShopV2.INK)

	## Pritisak: scale 0,97 (CSS style-active) oko centra.
	func _apply_state() -> void:
		pivot_offset = size * 0.5
		scale = Vector2.ONE * (0.97 if is_pressing() else 1.0)
