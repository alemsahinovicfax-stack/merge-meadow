extends Control

## R2 · Leteće poruke u runu (design_handoff_popups): „+1" leti do brojača (sjeme u disku ili coin),
## a za sjemenke iskoči poruka „[sjeme] +1 Ime" ispod SeedChipa (Run HUD v2: centar x 806, y 214 →
## lokalno 344, korak 80, najviše 2, 1,4 s).

const TOAST_LIFE := 1.4
const MAX_TOASTS := 2
const STEP := 80.0
const CENTER_X := 344.0
const NAME_PX := 56.0
const FLY_PX := 48.0
const RING_SCRIPT := preload("res://scripts/run/run_ring_fx.gd")

var _toasts: Array[Control] = []
var _coin_target: Control
var _seed_target: Control
var _fly_parent: Node


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bind_targets(coin: Control, seed: Control, fly_parent: Node) -> void:
	_coin_target = coin
	_seed_target = seed
	_fly_parent = fly_parent


func push_coin(from: Vector2 = Vector2.ZERO) -> void:
	_fly(from, _coin_target, UiAssets.get_chrome_icon("icon_coin"), "")


func push_seed(type_id: String, from: Vector2 = Vector2.ZERO, amount: int = 1) -> void:
	var flower_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
	var pop := "+%d" % maxi(1, amount)
	_fly(from, _seed_target, null, type_id, pop)
	_push_toast(type_id, flower_name, pop)


## Grm (Run HUD v2): nagrada sama leti do čipa (RunBushFx), ovdje ide samo poruka s imenom.
func push_seed_toast(type_id: String, amount: int = 1) -> void:
	var flower_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
	_push_toast(type_id, flower_name, "+%d" % maxi(1, amount))


func get_toast_texts() -> PackedStringArray:
	var out: PackedStringArray = []
	for t in _toasts:
		if is_instance_valid(t):
			out.append((t as FloatPop).seed_name)
	return out


func _fly(from: Vector2, target: Control, icon: Texture2D, type_id: String, pop_text: String = "+1") -> void:
	if _fly_parent == null or target == null or from == Vector2.ZERO:
		return
	var pop := FloatPop.new().setup(pop_text, false, icon, FLY_PX)
	if not type_id.is_empty():
		pop.with_seed(type_id)
	pop.modulate.a = 0.9
	_fly_parent.add_child(pop)
	pop.position = from - pop.size * 0.5
	var dest := target.get_global_rect().get_center() - pop.size * 0.5
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(pop, "position", dest, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(pop, "scale", Vector2.ONE * 0.7, 0.32)
	tw.tween_property(pop, "modulate:a", 0.35, 0.32)
	tw.chain().tween_callback(pop.queue_free)
	_burst(from)
	FloatPop.bump_control(target)


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


func _push_toast(type_id: String, flower_name: String, pop_text: String = "+1") -> void:
	while _toasts.size() >= MAX_TOASTS:
		var old: Control = _toasts.pop_front()
		if is_instance_valid(old):
			old.queue_free()
	var pop := FloatPop.new().setup(pop_text, false, null, NAME_PX)
	pop.with_seed(type_id, flower_name)
	add_child(pop)
	_toasts.append(pop)
	_layout_toasts()
	pop.scale = Vector2.ONE * 0.6
	var tw := pop.create_tween()
	tw.tween_property(pop, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(TOAST_LIFE)
	tw.tween_property(pop, "modulate:a", 0.0, 0.12)
	tw.tween_callback(_drop_toast.bind(pop))


func _drop_toast(pop: Control) -> void:
	_toasts.erase(pop)
	if is_instance_valid(pop):
		pop.queue_free()
	_layout_toasts()


func _layout_toasts() -> void:
	var y := 0.0
	var right := size.x if size.x > 8.0 else 440.0
	for t in _toasts:
		if not is_instance_valid(t):
			continue
		var x := minf(CENTER_X - t.size.x * 0.5, right - t.size.x)
		t.position = Vector2(x, y)
		t.pivot_offset = t.size * 0.5
		y += STEP
