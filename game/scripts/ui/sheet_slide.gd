class_name SheetSlide
extends Node

## Ulazak sheeta odozdo bez trzaja (FIX-TEL-2 2026-11-12 — Ormar, Boosts i Basket na telefonu).
## Obični Tween je kretao u istom frejmu u kojem se sadržaj sheeta gradi i prvi put crta: taj
## frejm traje 40–80 ms, pa tween „preskoči" prvu četvrtinu puta i sheet se pojavi u trzaju.
## Ovdje:
##  · prva WARM_FRAMES frejma sheet stoji ispod ekrana (gradnja i prvo crtanje prođu neviđeno);
##  · korak po frejmu je najviše MAX_STEP s — spor frejm uspori animaciju, ne preskoči je.
## Kriva i trajanje su isti kao prije (cubic-out, UiPopups.ANIM.sheet_in).

signal finished

const WARM_FRAMES := 2
const MAX_STEP := 1.0 / 30.0

var _sheet: Control
var _fade: CanvasItem
var _from: float = 0.0
var _to: float = 0.0
var _dur: float = 0.32
var _fade_dur: float = 0.2
var _t: float = 0.0
var _warm: int = WARM_FRAMES


## `fade` (scrim / dim) ide 0 → 1 kroz `fade_dur`. Sheet se odmah stavlja na `from_y`.
static func run(sheet: Control, from_y: float, to_y: float, dur: float, fade: CanvasItem = null, fade_dur: float = 0.2) -> SheetSlide:
	stop_on(sheet)
	var s := SheetSlide.new()
	s.name = "SheetSlide"
	s._sheet = sheet
	s._fade = fade
	s._from = from_y
	s._to = to_y
	s._dur = maxf(dur, 0.01)
	s._fade_dur = maxf(fade_dur, 0.01)
	sheet.position.y = from_y
	if fade != null:
		fade.modulate.a = 0.0
	sheet.add_child(s)
	return s


## Prekini ulazak koji još traje (sheet ostaje gdje je).
static func stop_on(sheet: Control) -> void:
	for c in sheet.get_children():
		if c is SheetSlide:
			sheet.remove_child(c)
			c.queue_free()


static func is_running_on(sheet: Control) -> bool:
	for c in sheet.get_children():
		if c is SheetSlide and not c.is_queued_for_deletion():
			return true
	return false


func _process(delta: float) -> void:
	if not is_instance_valid(_sheet):
		queue_free()
		return
	if _warm > 0:
		_warm -= 1
		return
	_t += minf(delta, MAX_STEP)
	var u := clampf(_t / _dur, 0.0, 1.0)
	var e := 1.0 - pow(1.0 - u, 3.0)
	_sheet.position.y = lerpf(_from, _to, e)
	if _fade != null and is_instance_valid(_fade):
		_fade.modulate.a = clampf(_t / _fade_dur, 0.0, 1.0)
	if u >= 1.0:
		if _fade != null and is_instance_valid(_fade):
			_fade.modulate.a = 1.0
		finished.emit()
		queue_free()
