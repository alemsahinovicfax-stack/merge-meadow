class_name HomeV3Tabs
extends Control

## SeasonTabs (HomeScreen.dc.html): staza 1032 x 124 (radius 62, rgba .10) s dva
## taba 508 x 108. design_handoff_ads_only (home_season_tabs.json): „Journey" (sjemenka, izabran
## krem) = besplatni put, uvijek prvi; „Themes" (zvjezdica „Special", izabran #C2E2FA) = teme.
## ID-evi free / premium ostaju interni — mijenja se samo prikaz. Oba rub 3 ink i sjenka 0 6 0.
## Nijedan tap na tab ne mijenja aktivnu sezonu.

signal tab_pressed(tab: String)

const FREE := "free"
const PREMIUM := "premium"
const LABEL_FREE := "Journey"
const LABEL_PREMIUM := "Themes"

var premium: bool = false:
	set(v):
		if premium == v:
			return
		premium = v
		queue_redraw()
var _down: String = ""


func _init() -> void:
	name = "SeasonTabs"
	mouse_filter = Control.MOUSE_FILTER_STOP
	position = UiHomeV3.TABS_RECT.position
	size = UiHomeV3.TABS_RECT.size


func tab_rect(tab: String) -> Rect2:
	var p := UiHomeV3.TABS_PAD
	var x := p if tab == FREE else p + UiHomeV3.TAB_SIZE.x
	return Rect2(Vector2(x, p), UiHomeV3.TAB_SIZE)


func tab_at(pos: Vector2) -> String:
	if tab_rect(FREE).has_point(pos):
		return FREE
	if tab_rect(PREMIUM).has_point(pos):
		return PREMIUM
	return ""


func _gui_input(event: InputEvent) -> void:
	var pos := Vector2.ZERO
	var pressed := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		pos = mb.position
		pressed = mb.pressed
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		pos = st.position
		pressed = st.pressed
	else:
		return
	accept_event()
	if pressed:
		_down = tab_at(pos)
		return
	var hit := tab_at(pos)
	var was := _down
	_down = ""
	if not hit.is_empty() and hit == was:
		Sfx.play("ui_tab")
		tab_pressed.emit(hit)


func _draw() -> void:
	draw_style_box(UiStage.box(UiHomeV3.TAB_TRACK, 62), Rect2(Vector2.ZERO, size))
	for tab: String in [FREE, PREMIUM]:
		var r := tab_rect(tab)
		var on := (tab == PREMIUM) == premium
		if on:
			var fill := SpecialTag.FILL if tab == PREMIUM else UiHomeV3.CREAM
			UiHomeV3.draw_panel(self, r, fill, 54.0, 3.0, UiHomeV3.INK, 6.0, UiHomeV3.TAB_SHADOW)
		var label := LABEL_PREMIUM if tab == PREMIUM else LABEL_FREE
		var icon: Texture2D = UiAssets.get_chrome_icon("icon_special" if tab == PREMIUM else "icon_seed")
		var icon_w: float = UiHomeV3.TAB_ICON + 16.0 if icon != null else 0.0
		var tw := UiHomeV3.text_w(900, UiHomeV3.TAB_LABEL, label)
		var x := r.get_center().x - (icon_w + tw) * 0.5
		var cy := r.get_center().y
		if icon:
			draw_texture_rect(icon, Rect2(x, cy - UiHomeV3.TAB_ICON * 0.5, UiHomeV3.TAB_ICON, UiHomeV3.TAB_ICON), false)
		UiHomeV3.draw_text(self, 900, UiHomeV3.TAB_LABEL, label, Vector2(x + icon_w, cy - UiHomeV3.TAB_LABEL * 0.5), UiHomeV3.INK)
