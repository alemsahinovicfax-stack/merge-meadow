class_name SettingsScreen
extends Control

## Settings — design_handoff_settings_fixes · D (Settings.dc.html, godot/settings_tree.txt).
## Pun ekran iznad huba: klizi odozdo 0,24 s (Reduce motion: samo alfa 0,12 s), X stoji tačno
## na mjestu zupčanika, Back zatvara (sa Credits vraća na Settings). Svaka promjena se
## primjenjuje odmah (UiSettings.apply) i sprema u user://settings.cfg — slider kad se pusti,
## toggle odmah. Slider i toggle se pomjeraju samo transformom; ništa se ne crta po frejmu.
## Developer sekcija postoji samo u debug buildu. Gradnja ekrana je ~40 ms, pa se gradi samo
## prvi put: zatvaranje ga sakrije, sljedeće otvaranje samo osvježi vrijednosti (reopen).

signal closed

const SCENE := "res://scenes/ui/settings_screen.tscn"
const GROUP := "settings_screen"
## Iznad svega u hubu: Arena ima slojeve do z ~100 (letenje coina, kristal, sjemenka u ruci,
## muncher 45 + rig), pa su sa z 50 izlazili preko Settingsa (2026-10-16).
const Z := 200
const ICON_DIR := "res://assets/ui/chrome/"
const RIM := 4

## Mjesto zupčanika u hubu (lokalno u ovom ekranu) — X ide tačno tu.
var close_rect := Rect2(UiSettings.CLOSE_POS, UiSettings.CLOSE)
var values: Dictionary = {}

var _scroll: ScrollContainer
var _credits: ScrollContainer
var _bar_title: Label
var _close: HubIconButton
var _toast: PopupToast
var _sliders: Dictionary = {}
var _toggles: Dictionary = {}
var _restore_state: int = UiSettings.Restore.IDLE
var _restore_button: PanelContainer
var _restore_label: Label
var _restore_sub: Label
var _restore_snapshot: Array = []
var _dots := 0
var _dots_timer: Timer
var _restore_timer: SceneTreeTimer
var _ads_sub: Label
var _ads_chip: PanelContainer
var _ads_label: Label
var _closing := false
var _tween: Tween
## Hub ga gradi unaprijed, korak po frejm, kad završi svoje stranice (prebuild_over).
var prebuild := false
var _steps: Array[Callable] = []
var _list_node: VBoxContainer


## Stvara ekran iznad `host` (hub). `gear` = globalni rect zupčanika.
static func open_over(host: Control, gear: Rect2) -> SettingsScreen:
	var screen := (load(SCENE) as PackedScene).instantiate() as SettingsScreen
	screen.close_rect = Rect2(gear.position - host.global_position, gear.size)
	host.add_child(screen)
	return screen


## Gradi skriven ekran u pozadini (jedan dio po frejmu) — prvo otvaranje bez zastoja.
static func prebuild_over(host: Control, gear: Rect2) -> SettingsScreen:
	var screen := (load(SCENE) as PackedScene).instantiate() as SettingsScreen
	screen.close_rect = Rect2(gear.position - host.global_position, gear.size)
	screen.prebuild = true
	host.add_child(screen)
	return screen


static func is_open(tree: SceneTree) -> bool:
	return tree != null and not tree.get_nodes_in_group(GROUP).is_empty()


## X tačno na zupčaniku — računa se pri svakom otvaranju (hub se u međuvremenu može pomjeriti).
func place_close(host: Control, gear: Rect2) -> void:
	close_rect = Rect2(gear.position - host.global_position, gear.size)
	if _close != null:
		_close.position = close_rect.position
		_close.size = close_rect.size


func is_showing() -> bool:
	return visible and not _closing


## Ponovo otvori već izgrađen ekran: vrijednosti iz settings.cfg, vrh liste, Settings (ne Credits).
func reopen() -> void:
	_finish_build()
	values = UiSettings.load_settings()
	for key in _sliders:
		_sync_slider(key)
	for key in _toggles:
		_sync_toggle(key, false)
	_sync_ads()
	if _restore_state != UiSettings.Restore.BUSY:
		_set_restore(UiSettings.Restore.IDLE, false)
	_show_credits(false)
	_scroll.scroll_vertical = 0
	_closing = false
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_to_group(GROUP)
	_animate_in()


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = Z
	values = UiSettings.load_settings()
	_steps = [_build_base, _build_sound, _build_gameplay, _build_purchases, _build_privacy,
		_build_tail, _build_credits_page, _build_bar]
	if prebuild:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		_closing = true
		get_tree().process_frame.connect(_build_next)
		return
	add_to_group(GROUP)
	_finish_build()
	_animate_in()


func _build_next() -> void:
	if not _steps.is_empty():
		_steps.pop_front().call()
	if _steps.is_empty() and get_tree().process_frame.is_connected(_build_next):
		get_tree().process_frame.disconnect(_build_next)


func _finish_build() -> void:
	while not _steps.is_empty():
		_steps.pop_front().call()
	if is_inside_tree() and get_tree().process_frame.is_connected(_build_next):
		get_tree().process_frame.disconnect(_build_next)


# --- gradnja -----------------------------------------------------------------

func _build_base() -> void:
	var bg := ColorRect.new()
	bg.name = "Bg"
	bg.color = UiSettings.PAGE_BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_scroll = _scroll_body("ScrollBody")
	_list_node = _list(_scroll)


func _build_tail() -> void:
	if OS.is_debug_build():
		_build_dev(_list_node)
	var version := _label(UiSettings.version_text(), 800, UiSettings.VERSION_FONT, UiSettings.SUB_INK)
	version.name = "Version"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list_node.add_child(version)


func _build_credits_page() -> void:
	_credits = _scroll_body("CreditsPage")
	_credits.visible = false
	_build_credits(_list(_credits))


func _scroll_body(node_name: String) -> ScrollContainer:
	var s := ScrollContainer.new()
	s.name = node_name
	s.set_anchors_preset(Control.PRESET_FULL_RECT)
	s.offset_top = float(UiSettings.BAR_H + UiSettings.BAR_RULE_H)
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	add_child(s)
	return s


func _list(scroll: ScrollContainer) -> VBoxContainer:
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", int(UiSettings.PAD.x))
	pad.add_theme_constant_override("margin_right", int(UiSettings.PAD.x))
	pad.add_theme_constant_override("margin_top", int(UiSettings.PAD.y))
	pad.add_theme_constant_override("margin_bottom", UiSettings.LIST_BOTTOM)
	scroll.add_child(pad)
	var list := VBoxContainer.new()
	list.name = "List"
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_theme_constant_override("separation", UiSettings.SECTION_GAP)
	pad.add_child(list)
	return list


## TopBar je neproziran poklopac iznad liste (GL Compat ne reže skrol).
func _build_bar() -> void:
	var bar := Panel.new()
	bar.name = "TopBar"
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.position = Vector2.ZERO
	bar.size = Vector2(1080, UiSettings.BAR_H)
	bar.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.BAR_BG, 0))
	add_child(bar)
	var rule := ColorRect.new()
	rule.name = "Rule"
	rule.color = UiSettings.BAR_RULE
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.position = Vector2(0, UiSettings.BAR_H)
	rule.size = Vector2(1080, UiSettings.BAR_RULE_H)
	add_child(rule)
	_bar_title = _label(UiSettings.S.title, 900, UiSettings.TITLE_FONT, UiSettings.PAGE_BG)
	_bar_title.name = "Title"
	_bar_title.position = Vector2(48, 0)
	_bar_title.size = Vector2(800, UiSettings.BAR_H)
	_bar_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bar.add_child(_bar_title)
	_close = HubIconButton.new()
	_close.name = "CloseButton"
	bar.add_child(_close)
	_close.position = close_rect.position
	_close.size = close_rect.size
	_close.set_icon(_icon("icon_close_light"))
	_close.tap_sfx = ""
	_close.clicked.connect(_on_close_pressed)
	_toast = PopupToast.new()
	_toast.name = "Toast"
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_toast)
	_toast.position = Vector2(0, 1720)
	_toast.setup(0.0, 1.6, 540.0)


func _section(title: String, dev: bool = false) -> VBoxContainer:
	var sec := VBoxContainer.new()
	sec.name = "Section_%s" % title.replace(" ", "").replace("&", "")
	sec.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sec.add_theme_constant_override("separation", UiSettings.SECTION_TITLE_GAP)
	var head := HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override("separation", 16)
	sec.add_child(head)
	head.add_child(_label(title, 900, UiSettings.SECTION_TITLE_FONT, UiSettings.INK))
	if dev:
		var tag := _chip(UiSettings.S.dev_tag, UiSettings.INK, UiSettings.PAGE_BG, 36)
		tag.name = "DevTag"
		tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		head.add_child(tag)
	var card := PanelContainer.new()
	card.name = "Card"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", UiSettings.section_card(dev))
	sec.add_child(card)
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", int(UiSettings.CARD_PAD.x))
	pad.add_theme_constant_override("margin_right", int(UiSettings.CARD_PAD.x))
	pad.add_theme_constant_override("margin_top", int(UiSettings.CARD_PAD.y) + (12 if dev else 0))
	pad.add_theme_constant_override("margin_bottom", int(UiSettings.CARD_PAD.y) + (12 if dev else 0))
	card.add_child(pad)
	var rows := VBoxContainer.new()
	rows.name = "Rows"
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 0)
	pad.add_child(rows)
	return rows


func _separator() -> ColorRect:
	var sep := ColorRect.new()
	sep.name = "Separator"
	sep.color = UiSettings.SEP
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sep.custom_minimum_size = Vector2(0, UiSettings.SEP_H)
	return sep


func _label(text: String, weight: int, px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiStage.style(l, weight, px, color)
	return l


func _chip(text: String, ink: Color, bg: Color, px: int = 36) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.custom_minimum_size = Vector2(0, UiSettings.CHIP_H)
	var s := UiSettings.box(bg, UiSettings.CHIP_H / 2, 3).duplicate() as StyleBoxFlat
	s.content_margin_left = 24
	s.content_margin_right = 24
	chip.add_theme_stylebox_override("panel", s)
	var l := _label(text, 900, px, ink)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_child(l)
	return chip


func _icon(icon_name: String) -> Texture2D:
	var path := ICON_DIR + icon_name + ".svg"
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


# --- Sound ---------------------------------------------------------------------

func _build_sound() -> void:
	var list := _list_node
	var rows := _section(UiSettings.S.sound)
	list.add_child(rows.get_parent().get_parent().get_parent())
	rows.add_child(_slider_row("music", UiSettings.S.music))
	rows.add_child(_separator())
	rows.add_child(_slider_row("sfx", UiSettings.S.sfx))
	rows.add_child(_separator())
	rows.add_child(_toggle_row("vibration", UiSettings.S.vibration, ""))


func _slider_row(key: String, title: String) -> Control:
	var row := VBoxContainer.new()
	row.name = "SliderRow_%s" % key
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 0)
	var top := Control.new()
	top.custom_minimum_size = Vector2(0, UiSettings.ROW_PAD_Y)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(top)
	row.add_child(_label(title, 900, UiSettings.LABEL_FONT, UiSettings.INK))
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 24)
	row.add_child(line)
	var mute := _Tap.new()
	mute.name = "MuteButton"
	mute.tap_sfx = ""
	mute.custom_minimum_size = UiSettings.MUTE
	line.add_child(mute)
	var mute_panel := Panel.new()
	mute_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mute_panel.size = UiSettings.MUTE
	mute.add_child(mute_panel)
	var mute_icon := TextureRect.new()
	mute_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mute_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mute_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mute_icon.position = (UiSettings.MUTE - Vector2(56, 56)) * 0.5
	mute_icon.size = Vector2(56, 56)
	mute.add_child(mute_icon)
	mute.tapped.connect(_on_mute.bind(key))
	var slider := _Slider.new()
	slider.name = "Slider"
	slider.custom_minimum_size = Vector2(UiSettings.SLIDER_W, UiSettings.SLIDER_HIT_H)
	line.add_child(slider)
	var track := Panel.new()
	track.name = "Track"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.position = Vector2(0, UiSettings.TRACK_Y)
	track.size = Vector2(UiSettings.SLIDER_W, UiSettings.TRACK_H)
	track.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.PAGE_BG, UiSettings.TRACK_R, RIM))
	slider.add_child(track)
	var fill := Panel.new()
	fill.name = "Fill"
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.position = Vector2(RIM, RIM)
	fill.size = Vector2(UiSettings.SLIDER_W - RIM * 2, UiSettings.TRACK_H - RIM * 2)
	track.add_child(fill)
	var thumb := Panel.new()
	thumb.name = "Thumb"
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.position = Vector2(0, UiSettings.THUMB_Y)
	thumb.size = Vector2(UiSettings.THUMB_D, UiSettings.THUMB_D)
	slider.add_child(thumb)
	slider.changed.connect(_on_slider.bind(key))
	slider.released.connect(_on_slider_released.bind(key))
	var value := _label("", 900, UiSettings.VALUE_FONT, UiSettings.INK)
	value.name = "Value"
	value.custom_minimum_size = Vector2(UiSettings.VALUE_W, UiSettings.SLIDER_HIT_H)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(value)
	var bottom := Control.new()
	bottom.custom_minimum_size = Vector2(0, UiSettings.ROW_PAD_Y)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(bottom)
	_sliders[key] = {"fill": fill, "thumb": thumb, "value": value, "mute": mute_panel, "icon": mute_icon}
	_sync_slider(key)
	return row


func _sync_slider(key: String) -> void:
	var s: Dictionary = _sliders[key]
	var v := int(values[key])
	var muted := bool(values[key + "_mute"])
	var fill := s["fill"] as Panel
	fill.pivot_offset = Vector2.ZERO
	fill.scale.x = UiSettings.fill_scale(v)
	fill.visible = v > 0
	fill.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.OFF if muted else UiSettings.ON, UiSettings.TRACK_R - RIM))
	var thumb := s["thumb"] as Panel
	thumb.position.x = UiSettings.thumb_x(v)
	thumb.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.THUMB_MUTED if muted else UiSettings.THUMB, UiSettings.THUMB_D / 2, RIM, UiSettings.INK, 4))
	(s["value"] as Label).text = UiSettings.S.off if muted else str(v)
	(s["mute"] as Panel).add_theme_stylebox_override("panel", UiSettings.box(UiSettings.OFF if muted else UiSettings.CARD, UiSettings.MUTE_R, RIM))
	(s["icon"] as TextureRect).texture = _icon("icon_sound_off" if muted else "icon_sound")


func _on_slider(v: int, key: String) -> void:
	var was := int(values[key])
	values[key] = v
	values[key + "_mute"] = false
	UiSettings.apply(values)
	_sync_slider(key)
	# Kvačica na svakih 5 (cooldown u katalogu) — ton prati vrijednost.
	if floori(v / 5.0) != floori(was / 5.0):
		Sfx.play("ui_slider", -1, 0.8 + 0.5 * float(v) / 100.0)


## Pušten Sound effects slider: probni coin na novoj glasnoći.
func _on_slider_released(key: String) -> void:
	_save()
	if key == "sfx":
		Sfx.play("coin")


## Mute čuva vrijednost; unmute vraća nju (0 → 80, ne tišina).
func _on_mute(key: String) -> void:
	var muted := not bool(values[key + "_mute"])
	values[key + "_mute"] = muted
	if not muted and int(values[key]) <= 0:
		values[key] = 80
	UiSettings.apply(values)
	_sync_slider(key)
	Sfx.play("ui_toggle_off" if muted else "ui_toggle_on")
	_save()


# --- Toggle --------------------------------------------------------------------

func _toggle_row(key: String, title: String, sub: String) -> Control:
	var row := _Tap.new()
	row.name = "ToggleRow_%s" % key
	row.tap_sfx = ""
	row.press_scale = 1.0
	row.custom_minimum_size = Vector2(0, UiSettings.ROW_MIN_H + (UiSettings.ROW_PAD_Y * 2 if not sub.is_empty() else 0))
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.set_anchors_preset(Control.PRESET_FULL_RECT)
	line.add_theme_constant_override("separation", 24)
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(line)
	var texts := VBoxContainer.new()
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.add_theme_constant_override("separation", 4)
	line.add_child(texts)
	texts.add_child(_label(title, 900, UiSettings.LABEL_FONT, UiSettings.INK))
	if not sub.is_empty():
		var sl := _label(sub, 700, UiSettings.SUB_FONT, UiSettings.SUB_INK)
		sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texts.add_child(sl)
	var track := Panel.new()
	track.name = "Toggle"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.custom_minimum_size = UiSettings.TOGGLE
	track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(track)
	var knob := Panel.new()
	knob.name = "Knob"
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	knob.size = Vector2(UiSettings.KNOB_D, UiSettings.KNOB_D)
	knob.position = Vector2(UiSettings.knob_x(bool(values[key])), (UiSettings.TOGGLE.y - UiSettings.KNOB_D) * 0.5)
	knob.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.THUMB, UiSettings.KNOB_D / 2, RIM))
	track.add_child(knob)
	row.tapped.connect(_on_toggle.bind(key))
	_toggles[key] = {"track": track, "knob": knob}
	_sync_toggle(key, false)
	return row


func _sync_toggle(key: String, animated: bool) -> void:
	var t: Dictionary = _toggles[key]
	var on := bool(values[key])
	(t["track"] as Panel).add_theme_stylebox_override("panel", UiSettings.box(UiSettings.ON if on else UiSettings.OFF, int(UiSettings.TOGGLE.y / 2), RIM))
	var knob := t["knob"] as Panel
	var x := UiSettings.knob_x(on)
	if animated and not GameState.reduce_motion and is_inside_tree():
		create_tween().tween_property(knob, "position:x", x, UiSettings.TOGGLE_SEC) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		knob.position.x = x


func _on_toggle(key: String) -> void:
	values[key] = not bool(values[key])
	UiSettings.apply(values)
	_sync_toggle(key, true)
	Sfx.play("ui_toggle_on" if bool(values[key]) else "ui_toggle_off")
	if key == "vibration" and bool(values[key]):
		UiSettings.vibrate(30)
	_save()


# --- Gameplay ------------------------------------------------------------------

func _build_gameplay() -> void:
	var list := _list_node
	var rows := _section(UiSettings.S.gameplay)
	list.add_child(rows.get_parent().get_parent().get_parent())
	rows.add_child(_toggle_row("reduce_motion", UiSettings.S.reduce_motion, UiSettings.S.reduce_motion_sub))


# --- Purchases -----------------------------------------------------------------

func _build_purchases() -> void:
	var list := _list_node
	var rows := _section(UiSettings.S.purchases)
	list.add_child(rows.get_parent().get_parent().get_parent())
	var restore := VBoxContainer.new()
	restore.name = "RestoreRow"
	restore.mouse_filter = Control.MOUSE_FILTER_IGNORE
	restore.add_theme_constant_override("separation", 8)
	rows.add_child(restore)
	var pad_top := Control.new()
	pad_top.custom_minimum_size = Vector2(0, UiSettings.ROW_PAD_Y + 8)
	pad_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	restore.add_child(pad_top)
	var btn := _Tap.new()
	btn.name = "RestoreButton"
	btn.custom_minimum_size = Vector2(0, UiSettings.BUTTON_H)
	restore.add_child(btn)
	_restore_button = PanelContainer.new()
	_restore_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_restore_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_child(_restore_button)
	_restore_label = _label("", 900, UiSettings.LABEL_FONT, UiSettings.INK)
	_restore_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_restore_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_restore_button.add_child(_restore_label)
	btn.tapped.connect(_on_restore)
	_restore_sub = _label("", 700, UiSettings.SUB_FONT, UiSettings.SUB_INK)
	_restore_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_restore_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	restore.add_child(_restore_sub)
	var pad_bottom := Control.new()
	pad_bottom.custom_minimum_size = Vector2(0, UiSettings.ROW_PAD_Y)
	pad_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	restore.add_child(pad_bottom)
	_dots_timer = Timer.new()
	_dots_timer.wait_time = 0.35
	_dots_timer.timeout.connect(_tick_dots)
	add_child(_dots_timer)
	_set_restore(UiSettings.Restore.IDLE, false)
	rows.add_child(_separator())
	var ads := HBoxContainer.new()
	ads.name = "AdsRow"
	ads.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ads.custom_minimum_size = Vector2(0, UiSettings.LINK_ROW_H)
	ads.add_theme_constant_override("separation", 24)
	rows.add_child(ads)
	var texts := VBoxContainer.new()
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	ads.add_child(texts)
	texts.add_child(_label(UiSettings.S.remove_ads, 900, UiSettings.LABEL_FONT, UiSettings.INK))
	_ads_sub = _label("", 700, UiSettings.SUB_FONT, UiSettings.SUB_INK)
	texts.add_child(_ads_sub)
	_ads_chip = _chip("", UiSettings.INK, UiSettings.CARD)
	_ads_chip.name = "AdsStatus"
	_ads_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ads.add_child(_ads_chip)
	_ads_label = _ads_chip.get_child(0) as Label
	_sync_ads()


## Remove Ads je samo status — Settings ne prodaje (Pillar 2).
func _sync_ads() -> void:
	var off := bool(GameState.ads_removed)
	_ads_sub.text = UiSettings.S.ads_bought if off else UiSettings.S.ads_not
	_ads_label.text = UiSettings.S.ads_off if off else UiSettings.S.ads_on
	var s := UiSettings.box(UiSettings.ON if off else UiSettings.CARD, UiSettings.CHIP_H / 2, 3).duplicate() as StyleBoxFlat
	s.content_margin_left = 24
	s.content_margin_right = 24
	_ads_chip.add_theme_stylebox_override("panel", s)


func _set_restore(state: int, pop: bool) -> void:
	_restore_state = state
	_restore_button.add_theme_stylebox_override("panel", UiSettings.restore_style(state))
	var texts := UiSettings.restore_text(state)
	_restore_label.text = texts[0]
	_restore_sub.text = texts[1]
	if state == UiSettings.Restore.BUSY:
		_dots = 0
		_tick_dots()
		_dots_timer.start()
	else:
		_dots_timer.stop()
	if pop and not GameState.reduce_motion and is_inside_tree():
		var btn := _restore_button.get_parent() as Control
		btn.pivot_offset = btn.size * 0.5
		var tw := create_tween()
		tw.tween_property(btn, "scale", Vector2.ONE * UiSettings.RESULT_POP, UiSettings.RESULT_SEC * 0.5)
		tw.tween_property(btn, "scale", Vector2.ONE, UiSettings.RESULT_SEC * 0.5)


## Jedini loop na ekranu: tri tačke dok prodavnica odgovara.
func _tick_dots() -> void:
	_dots = (_dots + 1) % 4
	_restore_label.text = UiSettings.S.restoring + " " + "•".repeat(maxi(1, _dots))


func _owned_snapshot() -> Array:
	return [bool(GameState.ads_removed), bool(GameState.starter_pack_owned), bool(GameState.merge_hint_owned),
		(GameState.owned_paid_seasons as Array).size()]


func _on_restore() -> void:
	if _restore_state == UiSettings.Restore.BUSY:
		return
	_restore_snapshot = _owned_snapshot()
	_set_restore(UiSettings.Restore.BUSY, false)
	if not IAPManager.restore_completed.is_connected(_on_restore_done):
		IAPManager.restore_completed.connect(_on_restore_done, CONNECT_ONE_SHOT)
	_restore_timer = get_tree().create_timer(UiSettings.RESTORE_TIMEOUT)
	_restore_timer.timeout.connect(_on_restore_timeout)
	IAPManager.restore_purchases()


func _on_restore_done() -> void:
	if _restore_state != UiSettings.Restore.BUSY:
		return
	var changed := _owned_snapshot() != _restore_snapshot
	_set_restore(UiSettings.Restore.DONE if changed else UiSettings.Restore.NONE, true)
	Sfx.play("purchase_ok" if changed else "ui_toast")
	_sync_ads()
	get_tree().call_group("meta_hub", "refresh_top_bar")


func _on_restore_timeout() -> void:
	if _restore_state != UiSettings.Restore.BUSY:
		return
	if IAPManager.restore_completed.is_connected(_on_restore_done):
		IAPManager.restore_completed.disconnect(_on_restore_done)
	_set_restore(UiSettings.Restore.FAIL, true)
	Sfx.play("purchase_fail")


# --- Privacy & help ------------------------------------------------------------

func _build_privacy() -> void:
	var list := _list_node
	var rows := _section(UiSettings.S.privacy)
	list.add_child(rows.get_parent().get_parent().get_parent())
	rows.add_child(_link_row("PrivacyChoices", UiSettings.S.privacy_choices, UiSettings.S.privacy_choices_sub, "icon_chevron", _on_privacy_choices))
	rows.add_child(_separator())
	rows.add_child(_link_row("PrivacyPolicy", UiSettings.S.privacy_policy, "", "icon_external", func() -> void: OS.shell_open(UiSettings.PRIVACY_URL)))
	rows.add_child(_separator())
	rows.add_child(_link_row("ContactSupport", UiSettings.S.support, UiSettings.S.support_sub, "icon_external", func() -> void: OS.shell_open(UiSettings.SUPPORT_MAIL)))
	rows.add_child(_separator())
	rows.add_child(_link_row("Credits", UiSettings.S.credits, "", "icon_chevron", _show_credits.bind(true)))


func _link_row(node_name: String, title: String, sub: String, icon: String, action: Callable) -> Control:
	var row := _Tap.new()
	row.name = "LinkRow_%s" % node_name
	row.press_scale = 1.0
	row.custom_minimum_size = Vector2(0, UiSettings.LINK_ROW_H)
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.set_anchors_preset(Control.PRESET_FULL_RECT)
	line.add_theme_constant_override("separation", 24)
	row.add_child(line)
	var texts := VBoxContainer.new()
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.add_theme_constant_override("separation", 2)
	line.add_child(texts)
	texts.add_child(_label(title, 900, UiSettings.LABEL_FONT, UiSettings.INK))
	if not sub.is_empty():
		texts.add_child(_label(sub, 700, UiSettings.SUB_FONT, UiSettings.SUB_INK))
	var box := Control.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size = Vector2(120, 120)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(box)
	var tr := TextureRect.new()
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.texture = _icon(icon)
	tr.position = Vector2(32, 32)
	tr.size = Vector2(56, 56)
	box.add_child(tr)
	row.tapped.connect(action)
	return row


## Pristanak za reklame (EU): AdManager ga otvara kad plugin to podržava; do tada politika.
func _on_privacy_choices() -> void:
	if AdManager.has_method("show_privacy_options"):
		AdManager.call("show_privacy_options")
	else:
		OS.shell_open(UiSettings.PRIVACY_URL)


func _build_credits(list: VBoxContainer) -> void:
	for c in UiSettings.CREDITS:
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_theme_stylebox_override("panel", UiSettings.section_card(false))
		list.add_child(card)
		var pad := MarginContainer.new()
		pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for side in ["left", "right"]:
			pad.add_theme_constant_override("margin_" + side, int(UiSettings.CARD_PAD.x))
		for side in ["top", "bottom"]:
			pad.add_theme_constant_override("margin_" + side, 28)
		card.add_child(pad)
		var v := VBoxContainer.new()
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_constant_override("separation", 6)
		pad.add_child(v)
		v.add_child(_label(str(c[0]), 900, UiSettings.LABEL_FONT, UiSettings.INK))
		var t := _label(str(c[1]), 700, 38, UiSettings.SUB_INK)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(t)


func _show_credits(on: bool) -> void:
	_credits.visible = on
	_scroll.visible = not on
	_bar_title.text = UiSettings.S.credits if on else UiSettings.S.title
	_credits.scroll_vertical = 0


# --- Developer (samo debug build) ---------------------------------------------

func _build_dev(list: VBoxContainer) -> void:
	var rows := _section(UiSettings.S.dev, true)
	var sec := rows.get_parent().get_parent().get_parent()
	sec.name = "Section_Developer"
	list.add_child(sec)
	var grid := GridContainer.new()
	grid.name = "DevGrid"
	grid.columns = 2
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	rows.add_child(grid)
	grid.add_child(_dev_button("DevUnlock", UiSettings.S.dev_unlock, false, _dev_unlock))
	grid.add_child(_dev_button("DevResetSeasons", UiSettings.S.dev_reset_seasons, true, _dev_reset_seasons))
	grid.add_child(_dev_button("DevCoins", UiSettings.S.dev_coins, false, _dev_coins))
	grid.add_child(_dev_button("DevResetTutorial", UiSettings.S.dev_reset_tutorial, true, _dev_reset_tutorial))
	grid.add_child(_dev_button("DevLevelUp", UiSettings.S.dev_level_up, false, _dev_level_up))
	grid.add_child(_dev_button("DevLevelReset", UiSettings.S.dev_level_reset, true, _dev_level_reset))


func _dev_button(node_name: String, text: String, danger: bool, action: Callable) -> Control:
	var b := _Tap.new()
	b.name = node_name
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, UiSettings.BUTTON_H)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", UiSettings.box(UiSettings.FAIL if danger else UiSettings.CARD, UiSettings.BUTTON_R, RIM, UiSettings.INK, UiSettings.BUTTON_SHADOW_Y))
	b.add_child(panel)
	var l := _label(text, 900, 38, UiSettings.INK)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(l)
	b.tapped.connect(action)
	return b


func _dev_done(text: String) -> void:
	get_tree().call_group("meta_hub", "refresh_top_bar")
	_toast.show_text(text)


func _dev_unlock() -> void:
	GameState.debug_unlock_all_seasons()
	_dev_done("All seasons unlocked")


## Kao novi igrač: samo prva sezona, bez kupljenih, polje zatvoreno — i aktivna je ta sezona
## svuda (Home, Arena, run). Ranije: stara playtest pomoć (debug_playtest_two_free) je
## postavljala aktivnu na Frost mimo set_active, pa su Home i Arena / run pričali različito.
func _dev_reset_seasons() -> void:
	GameState.stash_upgrade_levels(GameState.active_season_id)
	GameState.reset_seasons_to_s1()
	GameState.apply_active_upgrade_levels()
	GameState.save_player_save()
	_dev_done("Seasons reset to the first season")


func _dev_coins() -> void:
	GameState.wallet_coins += 1000
	GameState.save_player_save()
	_dev_done("+1000 coins")


func _dev_reset_tutorial() -> void:
	GameState.tutorial_complete = false
	GameState.tutorial_step = GameState.TutorialStep.RUN1
	GameState.save_player_save()
	_dev_done("Tutorial starts again")


## Playtest balansa: aktivna sezona skače +5 levela (1 → 6 → … → 21 = put završen → 1). Nagrade
## na putu ostaju neuzete (Claim), Endless se otvori kad level 15 bude „pređen" (16+).
func _dev_level_up() -> void:
	var id := GameState.active_season_id
	var lv := GameState.season_level(id)
	_dev_set_level(id, 1 if lv >= LevelPathDomain.COMPLETE else mini(lv + 5, LevelPathDomain.COMPLETE))


func _dev_level_reset() -> void:
	_dev_set_level(GameState.active_season_id, 1)


func _dev_set_level(season_id: String, level: int) -> void:
	GameState.level_path_domain.set_level(season_id, level)
	GameState.save_player_save()
	var shown := "Level %d" % level if level <= LevelPathDomain.LEVELS else "Path complete"
	if GameState.is_endless_unlocked(season_id):
		shown += " · Endless open"
	_dev_done(shown)


# --- ulaz / izlaz --------------------------------------------------------------

func _animate_in() -> void:
	Sfx.play("ui_open")
	if GameState.reduce_motion:
		modulate.a = 0.0
		_tween = create_tween()
		_tween.tween_property(self, "modulate:a", 1.0, 0.12)
		return
	modulate.a = 1.0
	position.y = 1920.0
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", 0.0, UiSettings.IN_SEC)


func close() -> void:
	if _closing:
		return
	_closing = true
	_save()
	Sfx.play("ui_close")
	remove_from_group(GROUP)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tween = create_tween()
	if GameState.reduce_motion:
		_tween.tween_property(self, "modulate:a", 0.0, 0.12)
	else:
		_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		_tween.tween_property(self, "position:y", 1920.0, UiSettings.OUT_SEC)
	_tween.tween_callback(func() -> void:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		closed.emit())


func _on_close_pressed() -> void:
	if _credits.visible:
		Sfx.play("ui_back")
		_show_credits(false)
	else:
		close()


func _save() -> void:
	UiSettings.save_settings(values)


func _unhandled_input(event: InputEvent) -> void:
	if _closing or event.is_echo():
		return
	var back := event.is_action_pressed("ui_cancel")
	if not back and event is InputEventKey:
		var k := event as InputEventKey
		back = k.pressed and k.keycode == KEY_ESCAPE
	if back:
		get_viewport().set_input_as_handled()
		_on_close_pressed()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not _closing:
		_on_close_pressed()


# --- male komponente -----------------------------------------------------------

## Dodir: tap (pritisak + puštanje unutra), pritisnuto = skala 0,97 za 0,08 s.
class _Tap:
	extends Control

	signal tapped

	var press_scale := 0.97
	## Zvuk tapa; toggle / mute / X puštaju svoj.
	var tap_sfx := "ui_tap"
	var _down := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		var pressed := false
		var at := Vector2.ZERO
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index != MOUSE_BUTTON_LEFT:
				return
			pressed = mb.pressed
			at = mb.position
		elif event is InputEventScreenTouch:
			var st := event as InputEventScreenTouch
			pressed = st.pressed
			at = st.position
		else:
			return
		accept_event()
		if pressed:
			_down = true
			_press(true)
		elif _down:
			_down = false
			_press(false)
			if Rect2(Vector2.ZERO, size).has_point(at):
				if not tap_sfx.is_empty():
					Sfx.play(tap_sfx)
				tapped.emit()

	func _press(on: bool) -> void:
		if is_equal_approx(press_scale, 1.0):
			return
		pivot_offset = size * 0.5
		create_tween().tween_property(self, "scale", Vector2.ONE * (press_scale if on else 1.0), UiSettings.PRESS_SEC)


## Slider: povlačenje mijenja vrijednost (changed), puštanje sprema (released).
class _Slider:
	extends Control

	signal changed(value: int)
	signal released

	var _drag := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index != MOUSE_BUTTON_LEFT:
				return
			_set_drag(mb.pressed, mb.position.x)
		elif event is InputEventScreenTouch:
			var st := event as InputEventScreenTouch
			_set_drag(st.pressed, st.position.x)
		elif event is InputEventMouseMotion and _drag:
			changed.emit(UiSettings.value_from_x((event as InputEventMouseMotion).position.x))
		elif event is InputEventScreenDrag and _drag:
			changed.emit(UiSettings.value_from_x((event as InputEventScreenDrag).position.x))
		else:
			return
		accept_event()

	func _set_drag(on: bool, x: float) -> void:
		if on:
			_drag = true
			changed.emit(UiSettings.value_from_x(x))
		elif _drag:
			_drag = false
			released.emit()
