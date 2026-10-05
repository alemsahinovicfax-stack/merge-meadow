class_name MergeHintMark
extends Control

## Merge Hint u Areni (design_handoff_shop_v2 § Merge Hint u Areni): četiri kutne zagrade
## oko najbliže iste sjemenke dok igrač drži sjemenku. Ink traka 18 + svijetla 10 (pravilo
## dvostrukog ruba Arene v2) — oblik, ne prsten, pa se ne miješa s pulsom ni magnetom.
## Ulaz 1,35 → 1 + alpha (0,18 s back-out), prelaz 0,14 s, izlaz 0,12 s. Bez loopa.

const SIDE := UiShopV2.HINT_FRAME + UiShopV2.HINT_INK_W

var _target: Node = null
var _tween: Tween = null
var _moving: bool = false
## Zagrade su na ekranu ili ulaze (false čim krene izlaz) — ne čita se iz `visible`,
## jer izlaz traje 0,12 s i `hide` dolazi tek na kraju.
var _shown: bool = false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(SIDE, SIDE)
	pivot_offset = size * 0.5
	visible = false
	modulate.a = 0.0


func _draw() -> void:
	UiShopV2.draw_merge_hint(self, size * 0.5)


func get_target() -> Node:
	return _target if is_instance_valid(_target) else null


func is_shown() -> bool:
	return _shown


## Nova meta (ili null = sakrij). Isti cilj → samo prati poziciju.
## Poređenje ide preko get_target(): oslobođena meta (spojena sjemenka) je u Godotu 4.7
## `== null`, pa bi `null == _target` bilo true i zagrade bi ostale visjeti.
func set_target(target: Node) -> void:
	if target != null and not is_instance_valid(target):
		target = null
	var current := get_target()
	if target != null and target == current:
		follow()
		return
	if target == null and not _shown:
		_target = null
		return
	var had := current != null and _shown
	_target = target
	_kill_tween()
	if target == null:
		_shown = false
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(self, "modulate:a", 0.0, UiShopV2.T_HINT_OUT)
		_tween.tween_property(self, "scale", Vector2.ONE * 1.2, UiShopV2.T_HINT_OUT)
		_tween.chain().tween_callback(hide)
		return
	_shown = true
	var goal := _goal()
	if had:
		_moving = true
		_tween = create_tween()
		_tween.tween_property(self, "position", goal, UiShopV2.T_HINT_MOVE).set_trans(Tween.TRANS_CUBIC).set_ease(
			Tween.EASE_OUT
		)
		_tween.tween_callback(func() -> void: _moving = false)
		return
	position = goal
	visible = true
	scale = Vector2.ONE * 1.35
	modulate.a = 0.0
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", Vector2.ONE, UiShopV2.T_HINT_IN).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_OUT
	)
	_tween.tween_property(self, "modulate:a", 1.0, UiShopV2.T_HINT_IN)


## Odmah, bez izlaza (kraj sesije, stranica se gasi).
func clear_now() -> void:
	_kill_tween()
	_target = null
	_shown = false
	modulate.a = 0.0
	hide()


## Prati metu kad se ona pomjeri (magnet, razmicanje), osim dok traje prelaz.
func follow() -> void:
	if not is_instance_valid(_target) or _moving:
		return
	position = _goal()


func _goal() -> Vector2:
	var center: Vector2 = _target.call("get_center")
	return center - size * 0.5


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_moving = false
