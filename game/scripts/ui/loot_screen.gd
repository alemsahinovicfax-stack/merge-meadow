extends Control

## R5 · Kraj runa (design_handoff_popups): isti modal za pad i kraj, preko zamrznutog zadnjeg kadra
## runa (GameState.last_run_snapshot) pod scrimom. Plijen kao RewardChipovi (coin + crtež svakog
## sjemena + broj); kod pada svaki broj precrtan i prepolovljen + pečat „Kept half". Reklame (Double,
## Revive) su lavanda AdButtoni h 120 u svom redu iznad Retry / To Camp (132) — status reklame se vidi
## na dugmetu („Double •••", „Doubled ✓", „No ad now"), nema reda teksta. Zatvara se samo dugmetom.
## Endless (design_handoff_leveli_endless · B6): ploča „Endless" (lavanda, prstenovi) ili zlatna
## „New best!" (trofej) + pečat; veliko vrijeme 180/900, pilula „Pace N", red „Best 5:28" /
## „Was 4:25"; plijen CIJELI s mint pečatom „All yours". Retry je primarno, Revive nastavlja Endless.

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
	Sfx.music_level("home")
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

## Pad koji siječe plijen (level). Endless kraj nije „fail" za izgled — plijen je cijeli.
func is_failed() -> bool:
	return GameState.last_failed and not GameState.last_run_endless


func is_endless() -> bool:
	return GameState.last_run_endless


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
	if is_endless():
		return UiLevels.S_NEW_BEST if GameState.last_endless_new_best else UiLevels.S_ENDLESS
	return UiPopups.S_RUN_FAILED if is_failed() else UiPopups.S_RUN_COMPLETE


## Endless: preživljeno vrijeme, stepenica i red rekorda (testovi i snimke).
func get_endless_score() -> Dictionary:
	if not is_endless():
		return {}
	var sec := GameState.last_endless_sec
	return {
		"time": UiLevels.clock(sec),
		"pace": UiLevels.S_PACE % RunLevelLibrary.endless_tier(sec),
		"best": _endless_best_line(),
		"stamp": GameState.last_endless_new_best,
	}


func _endless_best_line() -> String:
	if GameState.last_endless_new_best:
		var prev := GameState.last_endless_prev_best
		return UiLevels.S_WAS % UiLevels.clock(prev) if prev > 0.0 else ""
	var best := GameState.endless_best_sec(GameState.active_season_id)
	return UiLevels.S_BEST % UiLevels.clock(best) if best > 0.0 else ""


func get_chip_count() -> int:
	return tray.chips.size() if tray else 0


## Zlatni pečat: Loot Boost (ako je nivo > 0) i koliko je sjemenki bilo dvostruko (Twin Seeds).
## Brojevi u chipovima su već s boostom — pečat kaže zašto su veći od brojača u runu.
func get_boost_stamp() -> String:
	var parts: PackedStringArray = []
	var mult := GameState.last_loot_multiplier
	if mult > 1.0 + 1e-6:
		parts.append(UiPopups.S_LOOT_BOOST % String.num(mult, 2))
	var twins := GameState.last_run_twins
	if twins == 1:
		parts.append(UiPopups.S_TWIN_ONE)
	elif twins > 1:
		parts.append(UiPopups.S_TWINS % twins)
	return " · ".join(parts)


func get_chips() -> Array[RewardChip]:
	return tray.chips if tray else ([] as Array[RewardChip])


func get_all_text() -> String:
	var parts: PackedStringArray = [get_title(), tray.stamp_text if tray else "", tray.shown_boost_text() if tray else ""]
	for b in [double_button, revive_button, retry_button, camp_button]:
		if b.is_inside_tree() and b.visible:
			parts.append(b.label)
	return " | ".join(parts)


# --- gradnja ---

func _build() -> void:
	var endless := is_endless()
	if endless:
		var best := GameState.last_endless_new_best
		modal.set_plate_icon(UiLevels.tex("endless/trophy.svg" if best else "endless/rings.svg"), Vector2(60, 60) if best else Vector2(64, 36))
		modal.set_title(get_title(), "reward" if best else "endless")
	else:
		modal.set_plate_icon(null, Vector2.ZERO)
		modal.set_title(get_title(), "fail" if is_failed() else "success")
	_detach([double_button, revive_button, retry_button, camp_button])
	modal.clear_content()
	if endless:
		var score := _EndlessScore.new()
		score.name = "EndlessScore"
		score.setup(get_endless_score(), RunLevelLibrary.endless_tier(GameState.last_endless_sec))
		modal.content.add_child(score)
	var stamp := UiLevels.S_ALL_YOURS if endless else (UiPopups.S_KEPT_HALF if is_failed() else "")
	tray = RewardTray.new().setup(880.0, _make_chips(), stamp, get_boost_stamp())
	tray.stamp_full = endless
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
	# Endless: Retry je primarno (nova trka za rekord), To Camp sekundarno.
	var endless := is_endless()
	retry_button.configure("disabled" if nav_locked else ("primary" if endless else "secondary"), UiPopups.S_RETRY)
	camp_button.configure("disabled" if nav_locked else ("secondary" if endless else "primary"), UiPopups.S_TO_CAMP, false, UiAssets.get_chrome_icon("tab_camp"))


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
			Sfx.play("loot_double")
			Sfx.haptic(30)
		else:
			double_state = "none"
		_build()
		_pulse_chips()
	elif placement == CONFIG.PLACEMENT_REVIVE:
		Sfx.play("revive")
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
	# Broji Retry i pita pacer (blago ograničenje) — većinom false, pa run kreće odmah.
	if AdManager.take_interstitial_turn(CONFIG.PLACEMENT_LOOT_RETRY):
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


## B6 · rezultat Endlessa iznad plijena: vrijeme 180/900 (tabular), red [Pace N] [🏆 Best 5:28];
## na rekordu zlatni pečat „New best!" (220, 12°) gore desno, ulazi 0,22 s back-out.
class _EndlessScore extends Control:
	const TIME_FONT := 180
	const PILL_H := 72.0
	const PILL_FONT := 40
	const GAP := 18.0
	const STAMP := 220.0

	var score: Dictionary = {}
	var tier: int = 0
	var _stamp: Control

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func setup(p_score: Dictionary, p_tier: int) -> void:
		score = p_score
		tier = p_tier
		custom_minimum_size = Vector2(UiPopups.MODAL_W - 96.0, TIME_FONT * 0.9 + GAP + PILL_H)
		if bool(score.get("stamp", false)):
			_stamp = _Stamp.new()
			_stamp.size = Vector2(STAMP, STAMP)
			_stamp.pivot_offset = _stamp.size * 0.5
			_stamp.rotation_degrees = 12.0
			add_child(_stamp)
			_stamp.scale = Vector2.ONE * 0.6
			_stamp.modulate.a = 0.0
			var t := _stamp.create_tween().set_parallel()
			t.tween_property(_stamp, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			t.tween_property(_stamp, "modulate:a", 1.0, 0.22)
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED and _stamp:
			_stamp.position = Vector2(size.x + 6.0 - STAMP, -40.0)

	func _pace_w() -> float:
		return 16.0 + 36.0 + 10.0 + UiPopups.text_w(900, PILL_FONT, str(score.get("pace", ""))) + 26.0

	func _best_w() -> float:
		var b := str(score.get("best", ""))
		return 0.0 if b.is_empty() else 16.0 + 40.0 + 10.0 + UiPopups.text_w(900, PILL_FONT, b) + 26.0

	func _draw() -> void:
		var t := str(score.get("time", ""))
		var tw := UiHomeV3.text_w(900, TIME_FONT, t, 0.0, true)
		UiHomeV3.draw_text(self, 900, TIME_FONT, t, Vector2((size.x - tw) * 0.5, -TIME_FONT * 0.05), UiLevels.INK, 0.0, true)
		var y := TIME_FONT * 0.9 + GAP
		var pw := _pace_w()
		var bw := _best_w()
		var row := pw + (16.0 + bw if bw > 0.0 else 0.0)
		var x := (size.x - row) * 0.5
		var pr := Rect2(x, y, pw, PILL_H)
		draw_style_box(UiPopups._box(UiLevels.band_fill(UiLevels.pace_band(tier)), int(PILL_H * 0.5), 4), pr)
		var icon := UiLevels.tex("fx/pace_up.svg")
		if icon:
			draw_texture_rect(icon, Rect2(pr.position.x + 16.0, pr.get_center().y - 18.0, 36.0, 36.0), false)
		UiPopups.draw_text(self, 900, PILL_FONT, str(score.get("pace", "")), Vector2(pr.position.x + 62.0, pr.get_center().y - PILL_FONT * 0.5), UiLevels.INK)
		if bw <= 0.0:
			return
		var br := Rect2(pr.end.x + 16.0, y, bw, PILL_H)
		draw_style_box(UiPopups._box(UiLevels.RIM, int(PILL_H * 0.5), 3, UiLevels.INK_18), br)
		var trophy := UiLevels.tex("endless/trophy.svg")
		if trophy:
			draw_texture_rect(trophy, Rect2(br.position.x + 16.0, br.get_center().y - 20.0, 40.0, 40.0), false)
		UiPopups.draw_text(self, 900, PILL_FONT, str(score.get("best", "")), Vector2(br.position.x + 66.0, br.get_center().y - PILL_FONT * 0.5), UiLevels.SOFT)


	class _Stamp extends Control:
		func _init() -> void:
			mouse_filter = Control.MOUSE_FILTER_IGNORE

		func _draw() -> void:
			var tex := UiLevels.tex("endless/stamp_best.svg")
			if tex:
				draw_texture_rect(tex, Rect2(Vector2.ZERO, size), false)
			var r := Rect2(Vector2.ZERO, size)
			var lines := ["New", "best!"]
			var h := 40.0 * 0.95
			for i in lines.size():
				var w := UiPopups.text_w(900, 40, str(lines[i]))
				UiPopups.draw_text(self, 900, 40, str(lines[i]), Vector2(r.get_center().x - w * 0.5, r.get_center().y - h + float(i) * h), UiLevels.INK)
