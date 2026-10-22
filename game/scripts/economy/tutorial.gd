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
##
## Tok od 2026-10-22 (playtest „novi igrač"): tutorijal su DVA vođena runa — RUN1 (coini, zagarantovano
## sjeme) i RUN2 (prva prepreka) — pa je gotov (Level Path, Level 1, korpa). Ranije ga je završavao tek
## prvi merge u Areni, a Arena traži 50 sjemenki za spajanje (UiCamp.GATE_MIN): poslije runa od 45 s
## igrač ih ima ~10, pa je tutorijal trajao zauvijek („Practice" na svakom runu, bez levela). CAMP1 je
## čekao Play baš u Campu — Play na Homeu je ostavljao igrača bez prepreka. CAMP1 / CAMP_MERGE ostaju
## u enumu samo zbog starih saveova (load ih pomjeri naprijed).
## Savjet za prvi merge u Areni (should_prompt_merge) dolazi tek kad su vrata Arene otvorena.
class_name Tutorial
extends RefCounted

var complete: bool = false
var step: int
var arena_pest_shown: bool = false
## Prvi spoj u Areni urađen (savjet „spoji" se više ne pokazuje).
var merged: bool = false

## Untyped on purpose — see cosmetics.gd for why.
var _owner: Variant


func _init(owner: Variant) -> void:
	_owner = owner
	step = _owner.TutorialStep.RUN1


func apply_from_save(data: Dictionary) -> void:
	complete = bool(data.get("tutorial_complete", false))
	step = int(data.get("tutorial_step", _owner.TutorialStep.RUN1))
	# Stari tok: CAMP1 (čeka Play u Campu) → RUN2; CAMP_MERGE (čeka merge u Areni) → gotovo.
	if not complete and step == _owner.TutorialStep.CAMP1:
		step = _owner.TutorialStep.RUN2
	elif not complete and step >= _owner.TutorialStep.CAMP_MERGE:
		complete = true
	if complete:
		step = _owner.TutorialStep.FREE
	arena_pest_shown = bool(data.get("arena_pest_tutorial_shown", false))
	# Stari završeni tutorijal je tražio merge — bez ključa znači da je spajao.
	merged = bool(data.get("first_arena_merge_done", bool(data.get("tutorial_complete", false))))


func to_save_dict() -> Dictionary:
	return {
		"tutorial_complete": complete,
		"tutorial_step": step,
		"arena_pest_tutorial_shown": arena_pest_shown,
		"first_arena_merge_done": merged,
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


## Savjet za prvi spoj (Arena, Camp): tek kad igrač ima dovoljno sjemena (vrata Arene otvorena).
func should_prompt_merge() -> bool:
	return not merged and _owner.arena_gate_open()


## RUN1 → RUN2 → gotovo (FREE). Poziva se iz finish_run i kod pada (prepreka u RUN2 se računa).
func advance_after_run() -> void:
	if complete:
		return
	if step == _owner.TutorialStep.RUN1:
		step = _owner.TutorialStep.RUN2
	else:
		mark_complete()
		return
	_owner.save_player_save()


## Prvi spoj u Areni: savjet se gasi; ako je neko spojio prije kraja tutorijala (debug vreća),
## tutorijal se tada i završi kao ranije.
func notify_merge_completed() -> void:
	if not merged:
		merged = true
		_owner.save_player_save()
	if complete:
		return
	mark_complete()


func mark_arena_pest_shown() -> void:
	if arena_pest_shown:
		return
	arena_pest_shown = true
	_owner.save_player_save()


func should_show_arena_pest() -> bool:
	return not arena_pest_shown
