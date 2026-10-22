## Characterizes GameState's tutorial-step behavior (extracted into Tutorial at
## plan-arhitektura-refaktor.md Stage 4.2). Flow od 2026-10-22: RUN1 -> RUN2 (after first run)
## -> FREE (after second run) — dva vođena runa, bez čekanja na merge u Areni (vrata Arene traže
## 50 sjemenki). Stari saveovi na CAMP1 / CAMP_MERGE se pomjere naprijed pri učitavanju; savjet za
## prvi spoj tek kad su vrata Arene otvorena.
extends "res://test/unit/game_state_test_base.gd"

var _complete_before: bool
var _step_before: int
var _arena_pest_before: bool
var _merged_before: bool
var _bag_before: Dictionary


func before_each() -> void:
	super.before_each()
	_complete_before = _gs.tutorial_complete
	_step_before = _gs.tutorial_step
	_arena_pest_before = _gs.tutorial.arena_pest_shown
	_merged_before = _gs.tutorial.merged
	_bag_before = _gs.seed_bag.duplicate()


func after_each() -> void:
	_gs.tutorial_complete = _complete_before
	_gs.tutorial_step = _step_before
	_gs.tutorial.arena_pest_shown = _arena_pest_before
	_gs.tutorial.merged = _merged_before
	_gs.seed_bag = _bag_before
	super.after_each()


func test_is_tutorial_run1_true_at_start() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	assert_true(_gs.is_tutorial_run1())
	assert_false(_gs.is_tutorial_run2())


func test_advance_after_run_moves_run1_to_run2() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.advance_after_run()
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.RUN2)
	assert_true(_gs.is_tutorial_run2(), "second run is the obstacle run, wherever Play is pressed")


func test_second_run_completes_tutorial() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN2
	_gs.tutorial.advance_after_run()
	assert_true(_gs.tutorial_complete)
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.FREE)
	assert_true(_gs.uses_run_level_config(), "next run is Level 1, not Practice")


func test_advance_after_run_is_noop_once_complete() -> void:
	_gs.tutorial_complete = true
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.advance_after_run()
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.RUN1, "completed tutorial must not keep advancing")


func test_old_saves_stuck_waiting_for_merge_move_on() -> void:
	var t := Tutorial.new(_gs)
	t.apply_from_save({"tutorial_complete": false, "tutorial_step": _gs.TutorialStep.CAMP1})
	assert_false(t.complete)
	assert_eq(t.step, _gs.TutorialStep.RUN2)
	t.apply_from_save({"tutorial_complete": false, "tutorial_step": _gs.TutorialStep.CAMP_MERGE})
	assert_true(t.complete)
	assert_eq(t.step, _gs.TutorialStep.FREE)
	assert_false(t.merged, "stuck save never merged")
	t.apply_from_save({"tutorial_complete": true, "tutorial_step": _gs.TutorialStep.FREE})
	assert_true(t.merged, "old completed tutorial required a merge")


func test_merge_prompt_only_when_arena_gate_open() -> void:
	_gs.tutorial.merged = false
	_gs.seed_bag = {"clover": 9}
	assert_false(_gs.arena_gate_open())
	assert_false(_gs.should_prompt_merge_tutorial())
	assert_false(_gs.should_offer_merge_arena(), "To Camp must not lead to closed Arena gates")
	_gs.seed_bag = {"clover": 40, "daisy": 20}
	assert_true(_gs.arena_gate_open())
	assert_true(_gs.should_prompt_merge_tutorial())
	assert_true(_gs.should_offer_merge_arena())
	_gs.tutorial.notify_merge_completed()
	assert_false(_gs.should_prompt_merge_tutorial(), "tip only until the first merge")


func test_mark_tutorial_complete_sets_free_step() -> void:
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN2
	_gs.mark_tutorial_complete()
	assert_true(_gs.tutorial_complete)
	assert_eq(_gs.tutorial_step, _gs.TutorialStep.FREE)


func test_notify_merge_completed_finishes_tutorial_early() -> void:
	# A T2+ merge still ends the tutorial (the debug leftover bag can merge before the 2nd run).
	_gs.tutorial_complete = false
	_gs.tutorial_step = _gs.TutorialStep.RUN1
	_gs.tutorial.notify_merge_completed()
	assert_true(_gs.tutorial_complete)


func test_should_show_arena_pest_tutorial_once() -> void:
	_gs.tutorial.arena_pest_shown = false
	assert_true(_gs.should_show_arena_pest_tutorial())
	_gs.mark_arena_pest_tutorial_shown()
	assert_false(_gs.should_show_arena_pest_tutorial())
