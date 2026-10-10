extends Control

## Companion portrait — HUD krop glave (≤ 100), Arena (150), Camp. Run HUD v2 više nema portret.
## Pip = UiPip cutout rig; Mochi ostaje crtež.

@export var companion_id: String = ""
@export var follow_active_companion: bool = true
@export var pip_loop: String = ""
@export var crop_head: bool = false

var actor: UiPip


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_size()
	_sync_actor()
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)


func _on_cosmetics_changed(_slots: Array) -> void:
	_sync_actor()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_actor()


func refresh_portrait() -> void:
	_sync_actor()


func play_pip(id: String) -> void:
	if actor != null and actor.visible:
		actor.play(id)


func _ensure_size() -> void:
	if size.x < 1.0 or size.y < 1.0:
		size = custom_minimum_size


func _resolve_companion_id() -> String:
	if follow_active_companion:
		return GameState.get_active_companion_id()
	if not companion_id.is_empty():
		return companion_id
	return CompanionConfig.ID_PIP


func _sync_actor() -> void:
	_ensure_size()
	var id := _resolve_companion_id()
	if id != CompanionConfig.ID_PIP:
		if actor != null:
			actor.visible = false
		queue_redraw()
		return
	if actor == null:
		actor = UiPip.new()
		actor.name = "Actor"
		actor.follow_equipped = true
		add_child(actor)
	actor.visible = true
	var side := minf(size.x, size.y)
	var hud := crop_head or side <= 100.0
	# Reže se samo HUD portret (crop glave). Arena Pip stoji u kutiji 150, a uši riga
	# izlaze iznad nje — rezanje im je odsijecalo vrhove (playtest 2026-10-08).
	clip_contents = hud
	clip_children = Control.CLIP_CHILDREN_AND_DRAW if hud else Control.CLIP_CHILDREN_DISABLED
	actor.crop_head = hud
	actor.view = "front"
	actor.box_px = side
	actor.place_feet_in(self)
	var loop := pip_loop
	if loop.is_empty():
		loop = "hud_idle" if hud else "arena_idle"
	if actor.loop_id != loop:
		actor.set_loop(loop)
	queue_redraw()


func _draw() -> void:
	_ensure_size()
	var id := _resolve_companion_id()
	if id == CompanionConfig.ID_PIP:
		return
	var side := minf(size.x, size.y)
	if side < 1.0:
		return
	CompanionAssets.draw_portrait(self, id, size * 0.5, side)
