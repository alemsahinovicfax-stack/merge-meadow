extends Control

## R5 · Kraj runa (design_handoff_popups): isti modal za pad i kraj, preko zamrznutog zadnjeg kadra
## runa (GameState.last_run_snapshot) pod scrimom. Plijen kao RewardChipovi (coin + crtež svakog
## sjemena + broj); kod pada svaki broj precrtan i prepolovljen + pečat „Kept half". Reklame (Double,
## Revive) su lavanda AdButtoni h 120 u svom redu iznad Retry / To Camp (132) — status reklame se vidi
## na dugmetu („Double •••", „Doubled ✓", „No ad now"), nema reda teksta. Zatvara se samo dugmetom.

const CONFIG := preload("res://scripts/monetization/monetization_config.gd")

## Stanje reklame na dugmetu: ready | loading | done | none
var double_state: String = "ready"
var revive_state: String = "ready"
var retry_loading: bool = false
var nav_locked: bool = false

var modal: PopupModal
var tray: RewardTray
var double_button: PopupButton
var revive_button: PopupButton
var retry_button: PopupButton
var camp_button: PopupButton

var _ad_row: HBoxContainer
var _placement_busy: String = ""

@onready var snapshot: TextureRect = $Snapshot


func _ready() -> void:
	var tex: Texture2D = GameState.get("last_run_snapshot")
	snapshot.texture = tex
	snapshot.visible = tex != null
	modal = PopupModal.new()
	modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(modal)
	modal.setup("", "fail", true)
	double_button = PopupButton.new()
	double_button.name = "DoubleButton"
	revive_button = PopupButton.new()
	revive_button.name = "ReviveButton"
	retry_button = PopupButton.new()
	retry_button.name = "RetryButton"
	camp_button = PopupButton.new()
	camp_button.name = "CampButton"
	double_button.clicked.connect(_on_double_pressed)
	revive_button.clicked.connect(_on_revive_pressed)
	retry_button.clicked.connect(_on_retry_pressed)
	camp_button.clicked.connect(_on_camp_pressed)
	AdManager.rewarded_completed.connect(_on_rewarded_completed)
	AdManager.rewarded_failed.connect(_on_rewarded_failed)
	if not AdManager.can_request_rewarded():
		double_state = "none"
		revive_state = "none"
	_build()
	modal.open(true)
	tray.reveal()


func _exit_tree() -> void:
	if AdManager.rewarded_completed.is_connected(_on_rewarded_completed):
		AdManager.rewarded_completed.disconnect(_on_rewarded_completed)
	if AdManager.rewarded_failed.is_connected(_on_rewarded_failed):
		AdManager.rewarded_failed.disconnect(_on_rewarded_failed)


# --- stanje ---

func is_failed() -> bool:
	return GameState.last_failed


func shows_ads() -> bool:
	return GameState.show_rewarded_loot_buttons()


func shows_double() -> bool:
	return shows_ads() and (GameState.has_pending_loot() or GameState.loot_doubled)


func shows_revive() -> bool:
	return (
		shows_ads()
		and GameState.last_failed
		and not GameState.revive_used_this_run
		and not GameState.loot_doubled
	)


func get_title() -> String:
	return UiPopups.S_RUN_FAILED if is_failed() else UiPopups.S_RUN_COMPLETE


func get_chip_count() -> int:
	return tray.chips.size() if tray else 0


func get_chips() -> Array[RewardChip]:
	return tray.chips if tray else ([] as Array[RewardChip])


func get_all_text() -> String:
	var parts: PackedStringArray = [get_title(), tray.stamp_text if tray else ""]
	for b in [double_button, revive_button, retry_button, camp_button]:
		if b.is_inside_tree() and b.visible:
			parts.append(b.label)
	return " | ".join(parts)


# --- gradnja ---

func _build() -> void:
	modal.set_title(get_title(), "fail" if is_failed() else "success")
	_detach([double_button, revive_button, retry_button, camp_button])
	modal.clear_content()
	tray = RewardTray.new().setup(880.0, _make_chips(), UiPopups.S_KEPT_HALF if is_failed() else "")
	tray.name = "RewardTray"
	modal.content.add_child(PopupModal.centered(tray))
	var buttons := VBoxContainer.new()
	buttons.name = "ModalButtons"
	buttons.add_theme_constant_override("separation", 24)
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ads: Array = []
	if shows_double():
		ads.append(double_button)
	if shows_revive():
		ads.append(revive_button)
	if not ads.is_empty():
		_ad_row = PopupModal.button_row(ads)
		_ad_row.name = "AdRow"
		buttons.add_child(_ad_row)
	var main := PopupModal.button_row([retry_button, camp_button])
	main.name = "MainRow"
	buttons.add_child(main)
	modal.content.add_child(buttons)
	_apply_buttons()


func _detach(nodes: Array) -> void:
	for n in nodes:
		var c := n as Node
		if c.get_parent() != null:
			c.get_parent().remove_child(c)


func _make_chips() -> Array:
	var out: Array = []
	var failed := is_failed()
	var doubled := GameState.loot_doubled
	if GameState.last_run_coins > 0 or (failed and GameState.carry_coins > 0):
		var was := GameState.carry_coins if failed and not doubled else -1
		out.append(RewardChip.new().setup("coin", "", GameState.last_run_coins, was, doubled))
	var raw: Dictionary = GameState.carry_seed_bag
	for type_id in GameState.last_seed_bag:
		var n := int(GameState.last_seed_bag[type_id])
		if n <= 0:
			continue
		var was_n := int(raw.get(type_id, -1)) if failed and not doubled else -1
		var chip := RewardChip.new().setup("seed", str(type_id), n, was_n, doubled)
		chip.name = "Chip_%s" % type_id
		out.append(chip)
	return out


func _apply_buttons() -> void:
	_apply_ad(double_button, UiPopups.S_AD_DOUBLE, double_state, UiPopups.S_AD_DOUBLED)
	var rs := revive_state
	if double_state == "loading" and rs == "ready":
		rs = "dim"
	_apply_ad(revive_button, UiPopups.S_AD_REVIVE, rs, UiPopups.S_AD_REVIVE)
	if retry_loading:
		retry_button.configure("loading", UiPopups.S_RETRY)
		camp_button.configure("disabled", UiPopups.S_TO_CAMP, false, UiAssets.get_chrome_icon("tab_camp"))
		return
	retry_button.configure("disabled" if nav_locked else "secondary", UiPopups.S_RETRY)
	camp_button.configure("disabled" if nav_locked else "primary", UiPopups.S_TO_CAMP, false, UiAssets.get_chrome_icon("tab_camp"))


func _apply_ad(btn: PopupButton, label: String, state: String, done_label: String) -> void:
	match state:
		"loading":
			btn.configure("loading", label, true)
		"done":
			btn.configure("done", done_label, true)
		"none":
			btn.configure("disabled", UiPopups.S_AD_NONE, true)
		"dim":
			btn.configure("disabled", label, true)
		_:
			btn.configure("disabled" if nav_locked or retry_loading else "ad", label, true)


# --- akcije ---

func _on_double_pressed() -> void:
	if double_state != "ready" or GameState.loot_doubled or not GameState.has_pending_loot():
		return
	double_state = "loading"
	_placement_busy = CONFIG.PLACEMENT_DOUBLE_LOOT
	_apply_buttons()
	AdManager.request_rewarded(CONFIG.PLACEMENT_DOUBLE_LOOT)


func _on_revive_pressed() -> void:
	if revive_state != "ready" or not shows_revive():
		return
	revive_state = "loading"
	_placement_busy = CONFIG.PLACEMENT_REVIVE
	_apply_buttons()
	AdManager.request_rewarded(CONFIG.PLACEMENT_REVIVE)


func _on_rewarded_completed(placement: String) -> void:
	_placement_busy = ""
	if placement == CONFIG.PLACEMENT_DOUBLE_LOOT:
		if GameState.double_loot_placeholder():
			double_state = "done"
		else:
			double_state = "none"
		_build()
		_pulse_chips()
	elif placement == CONFIG.PLACEMENT_REVIVE:
		if GameState.request_revive():
			return
		revive_state = "none"
		_apply_buttons()


func _on_rewarded_failed(placement: String, _reason: String) -> void:
	_placement_busy = ""
	if placement == CONFIG.PLACEMENT_REVIVE:
		revive_state = "none"
	else:
		double_state = "none"
	_apply_buttons()


## „Doubled": broj 1 → 1,12 → 1 i ×2 tag (220 ms).
func _pulse_chips() -> void:
	for chip in get_chips():
		chip.pivot_offset = chip.custom_minimum_size * 0.5
		var t := chip.create_tween()
		t.tween_property(chip, "scale", Vector2.ONE * 1.12, 0.11)
		t.tween_property(chip, "scale", Vector2.ONE, 0.11)


func _on_retry_pressed() -> void:
	var start_run := func() -> void:
		GameState.begin_fresh_run()
		SceneRouter.change_to(GameState.SCENE_RUN)
	if AdManager.can_show_interstitial(CONFIG.PLACEMENT_LOOT_RETRY):
		retry_loading = true
		_apply_buttons()
		AdManager.show_interstitial(CONFIG.PLACEMENT_LOOT_RETRY, start_run)
	else:
		start_run.call()


func _on_camp_pressed() -> void:
	_set_nav_locked(true)
	GameState.go_to_camp()


func _set_nav_locked(locked: bool) -> void:
	nav_locked = locked
	_apply_buttons()
