## Tutorial domain, extracted from GameState (plan-arhitektura-refaktor.md
## Stage 4.2). Owned by GameState as `tutorial`.
##
## `complete`/`step` are exposed on GameState via property getters/setters
## (see game_state.gd) rather than plain facade methods, because production
## code (main_menu.gd, loot_screen.gd) and several GameState functions read
## GameState.tutorial_complete/tutorial_step as raw properties, not through a
## function call — a property shim keeps all of that working unchanged while
## this class owns the actual storage. TutorialStep itself stays declared on
## GameState (shared vocabulary both sides reference), not duplicated here.
class_name Tutorial
extends RefCounted

var complete: bool = false
var step: int
var arena_pest_shown: bool = false

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner
	step = _owner.TutorialStep.RUN1


func apply_from_save(data: Dictionary) -> void:
	complete = bool(data.get("tutorial_complete", false))
	step = int(data.get("tutorial_step", _owner.TutorialStep.RUN1))
	if complete:
		step = _owner.TutorialStep.FREE
	arena_pest_shown = bool(data.get("arena_pest_tutorial_shown", false))


func to_save_dict() -> Dictionary:
	return {
		"tutorial_complete": complete,
		"tutorial_step": step,
		"arena_pest_tutorial_shown": arena_pest_shown,
	}


## Legacy pre-save-file flags (user://tutorial_flags.json) — only consulted on
## a fresh boot with no player save yet (see GameState._ready()).
func migrate_legacy_flags() -> void:
	if not FileAccess.file_exists(_owner.TUTORIAL_FLAGS_PATH):
		return
	var file := FileAccess.open(_owner.TUTORIAL_FLAGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		complete = bool(parsed.get("tutorial_complete", false))
		if complete:
			step = _owner.TutorialStep.FREE


func mark_complete() -> void:
	if complete:
		return
	complete = true
	step = _owner.TutorialStep.FREE
	_owner.save_player_save()


func is_run1() -> bool:
	return not complete and step == _owner.TutorialStep.RUN1


func is_run2() -> bool:
	return not complete and step == _owner.TutorialStep.RUN2


func should_prompt_merge() -> bool:
	return not complete and step == _owner.TutorialStep.CAMP1


func advance_after_run() -> void:
	if complete:
		return
	if step == _owner.TutorialStep.RUN1:
		step = _owner.TutorialStep.CAMP1
	elif step == _owner.TutorialStep.RUN2:
		step = _owner.TutorialStep.CAMP_MERGE
	_owner.save_player_save()


func notify_merge_completed() -> void:
	if complete:
		return
	# First T2 merge ends the tutorial (not just at CAMP_MERGE — the debug
	# leftover bag can trigger a merge earlier).
	mark_complete()


func mark_arena_pest_shown() -> void:
	if arena_pest_shown:
		return
	arena_pest_shown = true
	_owner.save_player_save()


func should_show_arena_pest() -> bool:
	return not arena_pest_shown
