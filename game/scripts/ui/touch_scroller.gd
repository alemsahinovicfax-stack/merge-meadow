class_name TouchScroller
extends Node

## Skrol prstom preko CIJELE liste (FIX-TEL 2026-11) — dijete ScrollContainera.
## Godotov ScrollContainer skrola na dodir samo kad dodir stigne do njega; kartice i dugmad
## ga pojedu, pa je Shop skrolao samo između kartica. Ovaj čvor gleda dodir u _input (isti
## obrazac kao SwipePager), prije GUI-ja:
##   pritisak u listi → prati; pomak > TAP_SLOP i pretežno vertikalan → skrol (lista prati prst,
##   dugmad pod prstom dobiju cancel_press, ostatak geste GUI ne vidi); puštanje → inercija.
## Tap (bez pomaka) prolazi netaknut do dugmeta. Radi i mišem na kompjuteru, pa se testira
## headless (touch_scroll_smoke). Pretežno horizontalan pomak ostaje SwipePageru.

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")
## Vertikala mora biti bar ovoliko puta veća od horizontale (inače je to swipe huba).
const AXIS_DOMINANCE := 1.2
const FLING_MIN := 240.0        # px/s ispod kojeg nema inercije
const FLING_MAX := 6000.0
const FLING_FRICTION := 4.5     # 1/s — brzina pada eksponencijalno

var _scroll: ScrollContainer
var _active: bool = false
var _scrolling: bool = false
var _from_touch: bool = false
var _start: Vector2 = Vector2.ZERO
var _start_scroll: float = 0.0
var _last_y: float = 0.0
var _last_t: float = 0.0
var _vel: float = 0.0
var _fling: float = 0.0
var _fling_pos: float = 0.0


static func attach(scroll: ScrollContainer) -> TouchScroller:
	var existing := scroll.get_node_or_null("TouchScroller") as TouchScroller
	if existing != null:
		return existing
	var ts := TouchScroller.new()
	ts.name = "TouchScroller"
	scroll.add_child(ts, false, Node.INTERNAL_MODE_BACK)
	return ts


func _ready() -> void:
	_scroll = get_parent() as ScrollContainer
	set_process(false)


func is_scrolling() -> bool:
	return _scrolling


func _usable() -> bool:
	return _scroll != null and _scroll.is_visible_in_tree() \
		and _scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED \
		and not SceneRouter.is_input_blocked()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.index != 0:
			return
		if touch.pressed:
			_begin(touch.position, true)
		else:
			_end()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == 0 and _active and _from_touch:
			_move(drag.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		# Telefon šalje i emulirani miš uz svaki dodir — gesta ide samo kroz touch.
		if mouse.device == InputEvent.DEVICE_ID_EMULATION or mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_begin(mouse.position, false)
		else:
			_end()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if motion.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if _active and not _from_touch and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_move(motion.position)


func _begin(pos: Vector2, from_touch: bool) -> void:
	_active = false
	_scrolling = false
	if not _usable() or not _scroll.get_global_rect().has_point(pos):
		return
	# Dodir zaustavlja inerciju prošle geste.
	_fling = 0.0
	set_process(false)
	_active = true
	_from_touch = from_touch
	_start = pos
	_start_scroll = float(_scroll.scroll_vertical)
	_last_y = pos.y
	_last_t = Time.get_ticks_msec() / 1000.0
	_vel = 0.0


func _move(pos: Vector2) -> void:
	if not _scrolling:
		var d := pos - _start
		if absf(d.y) <= DRAG_SCROLL.TAP_SLOP:
			if absf(d.x) > DRAG_SCROLL.TAP_SLOP * 2.0:
				_active = false  # horizontalna gesta — swipe huba
			return
		if absf(d.y) < absf(d.x) * AXIS_DOMINANCE:
			_active = false
			return
		_scrolling = true
		# Dugme pod prstom ne smije kliknuti na kraju povlačenja.
		_scroll.propagate_call("cancel_press", [], false)
	var now := Time.get_ticks_msec() / 1000.0
	var dt := now - _last_t
	if dt > 0.0005:
		_vel = lerpf(_vel, (pos.y - _last_y) / dt, 0.6)
		_last_y = pos.y
		_last_t = now
	_scroll.scroll_vertical = int(roundf(_start_scroll - (pos.y - _start.y)))
	get_viewport().set_input_as_handled()


func _end() -> void:
	if not _active:
		return
	_active = false
	if not _scrolling:
		return
	_scrolling = false
	# Puštanje NE gutamo: GUI i ScrollContainer moraju vidjeti kraj dodira. Dugme pod prstom
	# je već dobilo cancel_press, pa na puštanje ne klikne.
	# Prst je stajao prije puštanja → bez inercije.
	if Time.get_ticks_msec() / 1000.0 - _last_t > 0.08:
		return
	if absf(_vel) >= FLING_MIN:
		_fling = clampf(-_vel, -FLING_MAX, FLING_MAX)
		_fling_pos = float(_scroll.scroll_vertical)
		set_process(true)


func _process(delta: float) -> void:
	if absf(_fling) < 30.0 or _scroll == null:
		_fling = 0.0
		set_process(false)
		return
	# Neko drugi je pomjerio listu (skok na slot, promjena taba) — inercija staje.
	if absi(_scroll.scroll_vertical - int(roundf(_fling_pos))) > 1:
		_fling = 0.0
		set_process(false)
		return
	_fling_pos += _fling * delta
	_fling *= exp(-FLING_FRICTION * delta)
	var before := _scroll.scroll_vertical
	_scroll.scroll_vertical = int(roundf(_fling_pos))
	# Kraj liste: ScrollContainer je stegnuo vrijednost.
	if _scroll.scroll_vertical == before and absf(_fling_pos - float(before)) > 2.0:
		_fling = 0.0
