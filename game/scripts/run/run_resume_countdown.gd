class_name RunResumeCountdown
extends Control

## Odbrojavanje poslije pauze (FIX-TEL-2 2026-11-12): „Keep running" zatvori meni, na sredini
## ekrana ide 3 → 2 → 1, tek onda staza krene. Igrač stigne vratiti prst i pogled na stazu.
## Krem disk s ink rubom i tvrdom sjenom (porodica pop-upova), broj 900. Svaki broj uskoči
## (1,25 → 1) i izblijedi pred sljedeći; uz Reduce motion samo se smijeni.
## Vrijeme vodi run_controller (`advance`), pa pauza usred odbrojavanja staje i ono.

signal finished

const STEPS := 3
const STEP_SEC := 0.7
const DISC := 300.0
const FONT_PX := 190.0
const POP_SCALE := 1.25
const POP_SEC := 0.16
const FADE_FROM := 0.78

var _left: float = 0.0
var _shown: int = 0
var _u: float = 0.0


func _init() -> void:
	name = "ResumeCountdown"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func is_running() -> bool:
	return _left > 0.0


## Broj koji je trenutno na ekranu (0 = ništa).
func shown_number() -> int:
	return _shown if is_running() else 0


func total_sec() -> float:
	return float(STEPS) * STEP_SEC


func start() -> void:
	_left = total_sec()
	_shown = 0
	visible = true
	_sync()


func cancel() -> void:
	_left = 0.0
	_shown = 0
	visible = false


## Pomjeri sat; vraća true u frejmu u kojem je odbrojavanje završilo.
func advance(delta: float) -> bool:
	if _left <= 0.0:
		return false
	_left -= delta
	if _left <= 0.0:
		cancel()
		finished.emit()
		return true
	_sync()
	return false


func _sync() -> void:
	var n := clampi(int(ceil(_left / STEP_SEC)), 1, STEPS)
	if n != _shown:
		_shown = n
		Sfx.play("reward_tick")
	_u = 1.0 - (_left - float(n - 1) * STEP_SEC) / STEP_SEC
	queue_redraw()


func _draw() -> void:
	if _shown <= 0:
		return
	var rm := UiPip.reduce_motion()
	var k := 1.0
	var a := 1.0
	if not rm:
		var pop := clampf(_u * STEP_SEC / POP_SEC, 0.0, 1.0)
		k = lerpf(POP_SCALE, 1.0, UiLevels.out3(pop))
		a = 1.0 - clampf((_u - FADE_FROM) / (1.0 - FADE_FROM), 0.0, 1.0)
	# Bez draw_set_transform: draw_text sam postavlja transform (pa bi broj završio u uglu).
	var c := size * 0.5
	var d := DISC * k
	var r := Rect2(c - Vector2(d, d) * 0.5, Vector2(d, d))
	var mod := Color(1, 1, 1, a)
	var shadow := UiPopups._box(Color(UiPopups.RUN_DROP, UiPopups.RUN_DROP.a * a), int(d * 0.5))
	draw_style_box(shadow, Rect2(r.position + Vector2(0, 12), r.size))
	var plate := UiPopups._box(UiPopups.ACTIVE_RIM * mod, int(d * 0.5), 6, UiPopups.OUTLINE * mod)
	draw_style_box(plate, r)
	UiPopups.draw_text_centered(self, 900, FONT_PX * k, str(_shown), r, UiPopups.OUTLINE * mod)
