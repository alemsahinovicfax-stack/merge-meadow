## Characterizes GameState's current tutorial-step behavior (extracted into
## Tutorial at plan-arhitektura-refaktor.md Stage 4.2). Flow: RUN1 -> CAMP1
## (after first run) -> RUN2 (notify_camp_play) -> CAMP_MERGE (after 2nd run)
## -> FREE (first T2 merge, via mark_tutorial_complete/notify_merge_completed).
extends "res://test/unit/game_state_test_base.gd"

var _complete_before: bool
var _step_before: int
var _arena_pest_before: bool


func before_each() -> void:
	super.before_each()
	_complete_before = _gs.tutorial_complete
	_step_before = _gs.tutorial_step
	_arena_pest_before = _gs.tutorial.arena_pest_shown


func after_each() -> void:
	_gs.tutorial_complete = _complete_before
	_gs.tutorial_step = _step_before
	_gs.tutorial.arena_pest_shown = _arena_pest_before
	super.after_each()


func test_is_tutorial_run1_true_at_start() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	assert_true(_gs.is_tutorial_run1())
	assert_false(_gs.is_tutorial_run2())


func test_advance_after_run_moves_run1_to_camp1() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.advance_after_run()
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.CAMP1)


func test_should_prompt_merge_tutorial_only_at_camp1() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.CAMP1
	assert_true(_gs.should_prompt_merge_tutorial())
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	assert_false(_gs.should_prompt_merge_tutorial())


func test_advance_after_run_moves_run2_to_camp_merge() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN2
	_gs.tutorial.advance_after_run()
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.CAMP_MERGE)


func test_advance_after_run_is_noop_once_complete() -> void:
	_gs.tutorial_complete = true
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.advance_after_run()
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.RUN1, "completed tutorial must not keep advancing")


func test_mark_tutorial_complete_sets_free_step() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.CAMP_MERGE
	_gs.mark_tutorial_complete()
	assert_true(_gs.tutorial_complete)
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.FREE)


func test_notify_merge_completed_finishes_tutorial_early() -> void:
	# Real behavior: a T2+ merge always ends the tutorial, even outside CAMP_MERGE
	# (the debug leftover bag can trigger a merge before the scripted step).
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.notify_merge_completed()
	assert_true(_gs.tutorial_complete)


func test_should_show_arena_pest_tutorial_once() -> void:
	_gs.tutorial.arena_pest_shown = false
	assert_true(_gs.should_show_arena_pest_tutorial())
	_gs.mark_arena_pest_tutorial_shown()
	assert_false(_gs.should_show_arena_pest_tutorial())
