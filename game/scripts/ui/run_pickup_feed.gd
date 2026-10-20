extends Control

## R2 · Poruka „[sjeme] +1 Ime" ispod SeedChipa (Run HUD v2: centar x 806, y 214 → lokalno 344,
## korak 80, najviše 2, 1,4 s). Let „+1" do brojača i dodir sa Pipom radi PickupFx
## (design_handoff_run_pickups); poruka iskoči kad pilula stigne do čipa.

const TOAST_LIFE := 1.4
const MAX_TOASTS := 2
const STEP := 80.0
const CENTER_X := 344.0
const NAME_PX := 56.0

var _toasts: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Pickup (PickupFx, kad pilula stigne) i grm (RunBushFx): samo poruka s imenom.
func push_seed_toast(type_id: String, amount: int = 1) -> void:
	var flower_name: String = GameState.SEED_DISPLAY_NAMES.get(type_id, type_id.capitalize())
	_push_toast(type_id, flower_name, "+%d" % maxi(1, amount))


func get_toast_texts() -> PackedStringArray:
	var out: PackedStringArray = []
	for t in _toasts:
		if is_instance_valid(t):
			out.append((t as FloatPop).seed_name)
	return out


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
