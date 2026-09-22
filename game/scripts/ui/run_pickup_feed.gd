extends Control

## Leteći +1 prema brojaču. Toast s imenom tipa samo za sjemenke (1,4 s, max 2).

const TOAST_LIFE := 1.4
const MAX_TOASTS := 2
const RING_SCRIPT := preload("res://scripts/run/run_ring_fx.gd")

var _toasts: Array[Control] = []
var _coin_target: Control
var _seed_target: Control
var _diamond_target: Control
var _fly_parent: Node


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind_targets(coin: Control, seed: Control, diamond: Control, fly_parent: Node) -> void:
	_coin_target = coin
	_seed_target = seed
	_diamond_target = diamond
	_fly_parent = fly_parent


func push_coin(from: Vector2 = Vector2.ZERO) -> void:
	_fly("+1", from, _coin_target, UiRun.COIN_FILL)


func push_seed(type_id: String, from: Vector2 = Vector2.ZERO) -> void:
	var flower_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
	_fly("+1", from, _seed_target, UiRun.CHIP_BG)
	_push_toast(flower_name)


func push_diamond(from: Vector2 = Vector2.ZERO) -> void:
	_fly("+1", from, _diamond_target, UiRun.DIAMOND_FILL)


func _fly(text: String, from: Vector2, target: Control, color: Color) -> void:
	if _fly_parent == null or target == null or from == Vector2.ZERO:
		return
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", UiRun.FONT_NAME)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.07, 0.11, 0.09, 0.85))
	label.add_theme_constant_override("outline_size", 6)
	label.position = from - Vector2(28, 28)
	_fly_parent.add_child(label)
	var dest := target.get_global_rect().get_center() - Vector2(28, 28)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "global_position", dest, 0.32) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(label, "modulate:a", 0.0, 0.32)
	tw.chain().tween_callback(label.queue_free)
	_burst(from)
	_punch(target)


func _burst(at: Vector2) -> void:
	if _fly_parent == null:
		return
	var ring := Node2D.new()
	ring.set_script(RING_SCRIPT)
	ring.position = at
	ring.ring_color = Color(UiRun.CHIP_BG.r, UiRun.CHIP_BG.g, UiRun.CHIP_BG.b, 0.9)
	ring.ring_width = 4.0
	ring.scale = Vector2(18, 18)
	_fly_parent.add_child(ring)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2(64, 64), 0.22)
	tw.tween_property(ring, "modulate:a", 0.0, 0.22)
	tw.chain().tween_callback(ring.queue_free)


func _punch(node: Control) -> void:
	if node == null:
		return
	node.pivot_offset = node.size * 0.5
	var tw := create_tween()
	tw.tween_property(node, "scale", Vector2(1.08, 1.08), 0.08)
	tw.tween_property(node, "scale", Vector2.ONE, 0.12)


func _push_toast(flower_name: String) -> void:
	while _toasts.size() >= MAX_TOASTS:
		var old: Control = _toasts.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _toast_style())
	panel.custom_minimum_size = Vector2(size.x if size.x > 8.0 else 420.0, 62)
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = flower_name
	label.add_theme_font_size_override("font_size", UiRun.FONT_TOAST)
	label.add_theme_color_override("font_color", UiRun.CHIP_BG)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	add_child(panel)
	_toasts.append(panel)
	_layout_toasts()
	var tw := create_tween()
	tw.tween_interval(TOAST_LIFE)
	tw.tween_property(panel, "modulate:a", 0.0, 0.12)
	tw.tween_callback(_drop_toast.bind(panel))


func _drop_toast(panel: Control) -> void:
	_toasts.erase(panel)
	if is_instance_valid(panel):
		panel.queue_free()
	_layout_toasts()


func _layout_toasts() -> void:
	var y := 0.0
	for toast in _toasts:
		if not is_instance_valid(toast):
			continue
		toast.position = Vector2(0.0, y)
		y += 70.0


func _toast_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = UiRun.TOAST_BG
	s.set_corner_radius_all(18)
	s.content_margin_left = 18.0
	s.content_margin_right = 18.0
	s.content_margin_top = 8.0
	s.content_margin_bottom = 8.0
	return s
