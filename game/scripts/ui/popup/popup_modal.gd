class_name PopupModal
extends Control

## Pop-up sistem · Modal (design_handoff_popups § Sistem): scrim + krem panel 984 (radius 48, rub 4,
## tvrda sjena 14) centriran u `area`, padding 92 / 48 / 48 / 48, gap 36. ModalPlate h 112 s naslovom
## 56/900 sjedi na gornjem rubu (pola iznad), boja kaže ton: reward zlatna · success mint · fail roze ·
## decision RIM. Ulaz 0,9 → 1 + alpha (220 ms back-out), scrim fade 220 ms.
## `dismiss_on_scrim` = tap van zatvara (poklon); pauza, kraj runa i „need seeds" samo dugmetom.

signal scrim_tapped
signal closed

const PLATE_LIFT := 52.0

var title: String = ""
var tone: String = "decision"
var on_run: bool = false
var dismiss_on_scrim: bool = false
## Prostor za scrim i centriranje (hub: stranica, run: cijeli ekran). Prazno = cijeli roditelj.
var area: Rect2 = Rect2()

var scrim: ColorRect
## Držač panela i pločice — skalira se u ulazu/izlazu.
var box: Control
var panel: PanelContainer
var content: VBoxContainer
var plate: Control

var _tween: Tween


func _init() -> void:
	name = "PopupModal"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim = ColorRect.new()
	scrim.name = "PopupScrim"
	scrim.color = UiPopups.SCRIM
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.gui_input.connect(_on_scrim_input)
	add_child(scrim)
	box = Control.new()
	box.name = "ModalBox"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	panel = PanelContainer.new()
	panel.name = "ModalPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	box.add_child(panel)
	content = VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", UiPopups.MODAL_GAP)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)
	plate = Control.new()
	plate.name = "ModalPlate"
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.draw.connect(_draw_plate)
	box.add_child(plate)
	panel.minimum_size_changed.connect(_layout)
	visible = false


func setup(p_title: String, p_tone: String, p_on_run: bool = false) -> PopupModal:
	title = p_title
	tone = p_tone
	on_run = p_on_run
	var sb := UiPopups.modal_panel(on_run)
	sb.content_margin_top = UiPopups.MODAL_PAD.x
	sb.content_margin_right = UiPopups.MODAL_PAD.y
	sb.content_margin_bottom = UiPopups.MODAL_PAD.z
	sb.content_margin_left = UiPopups.MODAL_PAD.w
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size.x = UiPopups.MODAL_W
	plate.queue_redraw()
	return self


func set_title(p_title: String, p_tone: String = "") -> void:
	title = p_title
	if not p_tone.is_empty():
		tone = p_tone
	plate.queue_redraw()
	_layout()


func clear_content() -> void:
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()


func is_open() -> bool:
	return visible


func open(animated: bool = true) -> void:
	visible = true
	_layout()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not animated or not is_inside_tree():
		scrim.modulate.a = 1.0
		box.scale = Vector2.ONE
		box.modulate.a = 1.0
		return
	scrim.modulate.a = 0.0
	box.pivot_offset = box.size * 0.5
	box.scale = Vector2.ONE * 0.9
	box.modulate.a = 0.0
	_tween = create_tween().set_parallel()
	_tween.tween_property(scrim, "modulate:a", 1.0, UiPopups.ANIM.modal_in)
	_tween.tween_property(box, "scale", Vector2.ONE, UiPopups.ANIM.modal_in).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(box, "modulate:a", 1.0, UiPopups.ANIM.modal_in)


func close(animated: bool = true) -> void:
	if not visible:
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not animated or not is_inside_tree():
		visible = false
		closed.emit()
		return
	box.pivot_offset = box.size * 0.5
	_tween = create_tween().set_parallel()
	_tween.tween_property(box, "scale", Vector2.ONE * 0.96, UiPopups.ANIM.modal_out).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(box, "modulate:a", 0.0, UiPopups.ANIM.modal_out)
	_tween.tween_property(scrim, "modulate:a", 0.0, UiPopups.ANIM.modal_out)
	_tween.chain().tween_callback(func() -> void:
		visible = false
		closed.emit()
	)


func panel_rect() -> Rect2:
	return Rect2(box.position, panel.size)


func _area() -> Rect2:
	if area.size.x > 1.0:
		return area
	return Rect2(Vector2.ZERO, size)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout()


func _layout() -> void:
	var a := _area()
	scrim.position = a.position
	scrim.size = a.size
	var ps := panel.get_combined_minimum_size()
	ps.x = maxf(ps.x, UiPopups.MODAL_W)
	panel.size = ps
	panel.position = Vector2.ZERO
	box.size = ps
	box.position = Vector2(
		roundf(a.position.x + (a.size.x - ps.x) * 0.5),
		roundf(a.position.y + (a.size.y - ps.y) * 0.5 + PLATE_LIFT * 0.5)
	)
	var pw := _plate_w()
	plate.position = Vector2((ps.x - pw) * 0.5, -PLATE_LIFT)
	plate.size = Vector2(pw, UiPopups.PLATE_H)
	plate.queue_redraw()


func _plate_w() -> float:
	return UiPopups.text_w(900, UiPopups.PLATE_TITLE, title) + UiPopups.PLATE_PAD_X * 2.0


func _draw_plate() -> void:
	if title.is_empty():
		return
	var r := Rect2(Vector2.ZERO, plate.size)
	plate.draw_style_box(UiPopups.modal_plate(tone), r)
	UiPopups.draw_text_centered(plate, 900, UiPopups.PLATE_TITLE, title, r, UiPopups.OUTLINE)


func _on_scrim_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if not tapped:
		return
	scrim.accept_event()
	scrim_tapped.emit()
	if dismiss_on_scrim:
		close()


## Red dugmadi (gap 24); svako dugme se širi podjednako.
static func button_row(buttons: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for b in buttons:
		var c := b as Control
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(c)
	return row


## Vodoravno centrirani držač za Control fiksne širine (tray, red pločica).
static func centered(child: Control) -> CenterContainer:
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cc.add_child(child)
	return cc
