extends Control

## Home Season Stage — smjer 1a Season Stage (design_handoff_home_v2).
## Jedna kartica + dock od 8 tokena. Fokus nije aktivna sezona.
## Play (u HomeColumnu) i dalje pali run aktivne sezone. Swipe po kartici
## lista sezone i ne prolazi u hub; swipe po docku i Play redu ide u hub.

@onready var season_select: Control = %SeasonSelect
@onready var season_field: Control = %SeasonField

var _clip: Control
var _card: HomeSeasonCard
var _browser: PanelContainer
var _free_count: Label
var _free_row: HBoxContainer
var _paid_row: HBoxContainer
var _tokens: Dictionary = {}
var _toast: PanelContainer
var _toast_label: Label
var _toast_token: int = 0
var _unlocking_id: String = ""
var _buying_id: String = ""
var _known_playable: Dictionary = {}
var _known_ready: bool = false
var _suppress_camp: bool = false
var _sliding: bool = false
var _unlock_timer: SceneTreeTimer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_select()
	_card.tapped.connect(_on_card_tapped)
	_card.swiped.connect(_on_swiped)
	_card.open_field_pressed.connect(_on_open_field_pressed)
	_card.unlock_pressed.connect(_on_unlock_pressed)
	_card.cta_pressed.connect(_on_cta_pressed)
	_card.page_pressed.connect(_on_swiped)
	resized.connect(_layout)
	IAPManager.purchase_completed.connect(_on_purchase_done)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
		seasons_btn.set("label_text", "")
	_layout()
	refresh()


func refresh() -> void:
	_detect_fresh()
	_ensure_tokens()
	_apply_tokens()
	_apply_card()
	_sync_season_field()
	_notify_play_chip()
	_layout()


# --- javni API (main_menu, Camp, smoke) ---

func open_season_field(season_id: String = "") -> bool:
	var id := season_id
	if id.is_empty():
		id = GameState.home_hero_center_id()
	if not GameState.is_season_playable(id):
		return false
	if not _focus_season(id):
		return false
	if not GameState.open_home_season_field():
		return false
	_sync_season_field()
	_notify_play_chip()
	return true


func close_season_field() -> void:
	GameState.close_home_season_field()
	_sync_season_field()
	refresh()


func get_card(season_id: String) -> HomeSeasonCard:
	if _card == null or _card.season_id != season_id:
		return null
	return _card


func get_token(season_id: String) -> HomeSeasonToken:
	return _tokens.get(season_id) as HomeSeasonToken


func focused_card_id() -> String:
	if _card == null or not season_select.visible:
		return ""
	return _card.season_id


func tap_card(season_id: String) -> void:
	if GameState.home_season_field_open or not _unlocking_id.is_empty():
		return
	if season_id == _shown_id() and GameState.is_season_playable(season_id):
		open_season_field(season_id)
		return
	_jump_to(season_id, false)


func tap_token(season_id: String) -> void:
	if not _unlocking_id.is_empty():
		return
	_jump_to(season_id, false)


func get_toast_text() -> String:
	if _toast == null or not _toast.visible:
		return ""
	return _toast_label.text


func get_free_path_text() -> String:
	return _free_count.text if _free_count else ""


func is_unlocking() -> bool:
	return not _unlocking_id.is_empty()


# --- izgled ---

func _build_select() -> void:
	_clip = Control.new()
	_clip.name = "CardClip"
	_clip.clip_contents = true
	_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	season_select.add_child(_clip)
	_card = HomeSeasonCard.new()
	_clip.add_child(_card)
	_browser = PanelContainer.new()
	_browser.name = "SeasonBrowser"
	_browser.mouse_filter = Control.MOUSE_FILTER_IGNORE
	season_select.add_child(_browser)
	var browser_col := VBoxContainer.new()
	browser_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	browser_col.add_theme_constant_override("separation", 10)
	_browser.add_child(browser_col)
	var labels := HBoxContainer.new()
	labels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	labels.custom_minimum_size.y = 48
	browser_col.add_child(labels)
	var free_box := HBoxContainer.new()
	free_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	free_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	free_box.add_theme_constant_override("separation", 14)
	labels.add_child(free_box)
	var free_word := Label.new()
	free_word.mouse_filter = Control.MOUSE_FILTER_IGNORE
	free_word.text = "Free path"
	free_word.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiHome.style(free_word, 38, Color("#FFF8F0"), UiHome.W_BOLD)
	free_box.add_child(free_word)
	_free_count = Label.new()
	_free_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_free_count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiHome.style(_free_count, 44, Color("#FFD56B"), UiHome.W_BLACK)
	free_box.add_child(_free_count)
	var prem := Label.new()
	prem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prem.text = "Premium"
	prem.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UiHome.style(prem, 38, Color("#D4A5FF"), UiHome.W_BOLD)
	labels.add_child(prem)
	var tokens := HBoxContainer.new()
	tokens.name = "ProgressIndicator"
	tokens.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tokens.add_theme_constant_override("separation", 20)
	browser_col.add_child(tokens)
	_free_row = HBoxContainer.new()
	_free_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_free_row.add_theme_constant_override("separation", 10)
	tokens.add_child(_free_row)
	_paid_row = HBoxContainer.new()
	_paid_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_paid_row.add_theme_constant_override("separation", 10)
	tokens.add_child(_paid_row)
	_toast = PanelContainer.new()
	_toast.name = "Toast"
	_toast.visible = false
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.z_index = 5
	_toast.custom_minimum_size.y = 92
	add_child(_toast)
	_toast_label = Label.new()
	_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_toast.add_child(_toast_label)


func _layout() -> void:
	if _clip == null or not is_node_ready():
		return
	var width := size.x
	var height := season_select.size.y
	if width < 8.0 or height < 8.0:
		return
	var browser_h := 222.0
	_browser.position = Vector2(0, height - browser_h)
	_browser.size = Vector2(width, browser_h)
	var card_top := 24.0
	var card_h := _browser.position.y - card_top - 24.0
	_clip.position = Vector2(24, card_top)
	_clip.size = Vector2(width - 48.0, card_h + 12.0)
	if not _sliding and not _card.is_gesturing():
		_card.position = Vector2.ZERO
	_card.size = Vector2(_clip.size.x, maxf(card_h, 0.0))
	_place_toast()


func _place_toast() -> void:
	if _toast == null or not _toast.visible:
		return
	var toast_size := _toast.get_combined_minimum_size()
	var w := maxf(toast_size.x, 200.0)
	_toast.size = Vector2(w, 92)
	_toast.position = Vector2((size.x - w) * 0.5, 250)


# --- podaci ---

func _shown_id() -> String:
	return GameState.home_hero_center_id()


func _focusables() -> Array[String]:
	var out: Array[String] = []
	var next_id := GameState.next_locked_free_id()
	for def in SeasonCatalog.free_defs_sorted():
		if GameState.is_season_playable(def.id) or def.id == next_id:
			out.append(def.id)
	for def in SeasonCatalog.paid_defs():
		out.append(def.id)
	return out


func _neighbor(direction: int) -> String:
	var ids := _focusables()
	var index := ids.find(_shown_id())
	if index < 0:
		return ""
	var next_index := index + direction
	if next_index < 0 or next_index >= ids.size():
		return ""
	return ids[next_index]


func _is_focusable(season_id: String) -> bool:
	return _focusables().has(season_id)


func _ensure_tokens() -> void:
	for def in SeasonCatalog.all_defs():
		if _tokens.has(def.id):
			continue
		var token := HomeSeasonToken.new()
		token.name = "Token_%s" % def.id
		token.pressed.connect(_on_token_pressed)
		_tokens[def.id] = token
		if def.is_free():
			_free_row.add_child(token)
		else:
			_paid_row.add_child(token)


func _apply_tokens() -> void:
	var shown := _shown_id()
	var active_id := GameState.active_season_id
	var next_id := GameState.next_locked_free_id()
	var free_defs := SeasonCatalog.free_defs_sorted()
	var done := 0
	for def in free_defs:
		if GameState.is_season_playable(def.id):
			done += 1
	_free_count.text = "%d / %d" % [done, free_defs.size()]
	var browser_style := HomeSeasonStyles.get_style("season_browser_bg")
	browser_style.content_margin_left = 20
	browser_style.content_margin_right = 20
	browser_style.content_margin_top = 14
	browser_style.content_margin_bottom = 8
	browser_style.border_width_top = 3
	browser_style.border_width_bottom = 3
	browser_style.border_color = Color(1, 0.973, 0.941, 0.55)
	_browser.add_theme_stylebox_override("panel", browser_style)
	for def in SeasonCatalog.all_defs():
		var token := _tokens[def.id] as HomeSeasonToken
		token.configure(_token_data(def, shown, active_id, next_id))


func _token_data(def: SeasonDef, shown: String, active_id: String, next_id: String) -> Dictionary:
	var mood := SeasonCardContrast.mood_color(def.id)
	var kind := "number"
	var fill := mood
	var show_bar := false
	var bar_ratio := 0.0
	if def.is_free():
		if GameState.is_season_playable(def.id):
			kind = "number"
			fill = mood
		elif def.id == next_id:
			kind = "lock"
			fill = SeasonColors.card_fill(mood, SeasonColors.State.GATHER)
			show_bar = true
			bar_ratio = _gate_ratio(def)
		else:
			kind = "lock"
			fill = SeasonColors.far_token(mood)
	elif GameState.is_test_locked_season(def.id):
		kind = "soon"
		fill = SeasonColors.card_fill(mood, SeasonColors.State.SOON)
	elif GameState.is_season_playable(def.id):
		kind = "check"
		fill = mood
	else:
		kind = "gem"
		fill = mood
	return {
		"season_id": def.id,
		"fill": fill,
		"kind": kind,
		"number": def.order,
		"active": def.id == active_id and GameState.is_season_playable(def.id),
		"focused": def.id == shown,
		"show_bar": show_bar,
		"bar_ratio": bar_ratio,
	}


func _gate_ratio(def: SeasonDef) -> float:
	var coins_need := maxi(def.coins_cost, 1)
	var flowers_need := maxi(def.t3_flowers_required, 1)
	var coins := clampf(float(GameState.wallet_coins) / float(coins_need), 0.0, 1.0)
	var flowers := clampf(float(GameState.star3_flower_count_for_unlock(def.id)) / float(flowers_need), 0.0, 1.0)
	return (coins + flowers) * 0.5


func _apply_card() -> void:
	var id := _shown_id()
	var def: SeasonDef = GameState.get_season_def(id)
	if def == null:
		return
	_card.configure(_card_data(def))


func _card_data(def: SeasonDef) -> Dictionary:
	var roster: Array = []
	for entry in def.roster:
		roster.append({
			"id": str(entry.get("id", "")),
			"name": str(entry.get("display_name", "")),
			"rarity": int(entry.get("rarity", 1)),
		})
	var state := _state_for(def)
	var prev := ""
	var gate_name := ""
	var gate_type := ""
	if def.is_free():
		prev = GameState.previous_free_id_for(def.id)
	var prev_def: SeasonDef = GameState.get_season_def(prev) if not prev.is_empty() else null
	if prev_def == null and not def.is_free():
		prev_def = null
	if not prev.is_empty():
		gate_type = GameState.star3_type_id_for_season(prev)
		gate_name = GameState.get_seed_display_name(gate_type) if not gate_type.is_empty() else ""
	var coins := int(GameState.wallet_coins)
	var flowers := GameState.star3_flower_count_for_unlock(def.id) if def.is_free() else 0
	if state == UiHome.ST_UNLOCKING:
		coins = def.coins_cost
		flowers = def.t3_flowers_required
	return {
		"season_id": def.id,
		"name": def.display_name,
		"tagline": def.tagline,
		"kind": "free" if def.is_free() else "paid",
		"free_index": def.order,
		"free_count": SeasonCatalog.free_defs_sorted().size(),
		"roster": roster,
		"state": state,
		"active": state == UiHome.ST_ACTIVE,
		"prev_name": prev_def.display_name if prev_def else "",
		"gate_name": gate_name,
		"gate_type_id": gate_type,
		"coins": coins,
		"coins_need": def.coins_cost,
		"flowers": flowers,
		"flowers_need": def.t3_flowers_required,
		"price": IAPManager.get_price_label(def.iap_product_id) if not def.iap_product_id.is_empty() else "",
		"prev_on": not _neighbor(-1).is_empty(),
		"next_on": not _neighbor(1).is_empty(),
	}


func _state_for(def: SeasonDef) -> String:
	var id := def.id
	if id == _unlocking_id:
		return UiHome.ST_UNLOCKING
	if def.is_free():
		if GameState.is_season_playable(id):
			return UiHome.ST_ACTIVE if id == GameState.active_season_id else UiHome.ST_UNLOCKED
		if id == GameState.next_locked_free_id():
			return UiHome.ST_READY if GameState.can_unlock_free(id) else UiHome.ST_NEXT
		return UiHome.ST_LOCKED
	if GameState.is_test_locked_season(id):
		return UiHome.ST_SOON
	if GameState.is_season_playable(id):
		return UiHome.ST_ACTIVE if id == GameState.active_season_id else UiHome.ST_UNLOCKED
	if id == _buying_id and IAPManager.is_busy():
		return UiHome.ST_BUSY
	return UiHome.ST_PREMIUM


# --- fokus i geste ---

func _jump_to(season_id: String, animate: bool) -> void:
	if not _is_focusable(season_id):
		_reject_far(season_id)
		return
	if season_id == _shown_id():
		return
	if animate:
		_slide_to(1 if _focusables().find(season_id) > _focusables().find(_shown_id()) else -1, season_id)
		return
	_set_focus(season_id)
	_apply_card()
	_apply_tokens()
	_notify_play_chip()


func _on_token_pressed(season_id: String) -> void:
	tap_token(season_id)


func _on_card_tapped(season_id: String) -> void:
	tap_card(season_id)


func _on_open_field_pressed(season_id: String) -> void:
	open_season_field(season_id)


func _on_swiped(direction: int) -> void:
	if GameState.home_season_field_open or not _unlocking_id.is_empty():
		return
	var nxt := _neighbor(direction)
	if nxt.is_empty():
		_sliding = true
		_card.rubber(direction)
		if is_inside_tree():
			get_tree().create_timer(0.3).timeout.connect(func() -> void: _sliding = false, CONNECT_ONE_SHOT)
		return
	_slide_to(direction, nxt)


func _slide_to(direction: int, season_id: String) -> void:
	if _sliding or not is_inside_tree():
		_set_focus(season_id)
		_apply_card()
		_apply_tokens()
		return
	_sliding = true
	var width := _clip.size.x
	var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_card, "position:x", -float(direction) * width, UiHome.T_PAGE)
	tw.tween_callback(func() -> void:
		_set_focus(season_id)
		_card.position.x = float(direction) * width
		_apply_card()
		_apply_tokens()
		var back := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		back.tween_property(_card, "position:x", 0.0, UiHome.T_PAGE)
		back.tween_callback(func() -> void: _sliding = false)
	)


func _set_focus(season_id: String) -> bool:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return false
	if def.is_paid():
		if not GameState.set_paid_strip_focus(season_id):
			return false
		GameState.set_home_band("paid")
		return true
	if not GameState.set_free_strip_focus(season_id):
		return false
	GameState.set_home_band("free")
	return true


func _focus_season(season_id: String) -> bool:
	return _set_focus(season_id)


func _reject_far(season_id: String) -> void:
	var token := get_token(season_id)
	if token:
		token.shake()
	var prev := GameState.previous_free_id_for(season_id)
	var prev_def: SeasonDef = GameState.get_season_def(prev) if not prev.is_empty() else null
	var who := prev_def.display_name if prev_def else "the previous season"
	_show_toast("Unlock %s first" % who, false)


func _show_toast(text: String, success: bool) -> void:
	var style := HomeSeasonStyles.get_style("toast_success" if success else "toast_blocked")
	style.content_margin_left = 40
	style.content_margin_right = 40
	_toast.add_theme_stylebox_override("panel", style)
	_toast_label.text = text
	UiHome.style(_toast_label, 40, UiHome.INK if success else Color("#FFF8F0"), UiHome.W_BLACK)
	_toast.visible = true
	_place_toast()
	_toast_token += 1
	var token := _toast_token
	if not is_inside_tree():
		return
	get_tree().create_timer(UiHome.T_TOAST if success else 1.8).timeout.connect(func() -> void:
		if token == _toast_token:
			_toast.visible = false
	, CONNECT_ONE_SHOT)


# --- unlock ---

func _on_unlock_pressed(season_id: String) -> void:
	if not _unlocking_id.is_empty():
		return
	if not GameState.unlock_free(season_id):
		refresh()
		return
	_unlocking_id = season_id
	_known_playable[season_id] = true
	_refresh_top_bar()
	refresh()
	_notify_play_chip()
	if not is_inside_tree():
		_finish_unlock()
		return
	_unlock_timer = get_tree().create_timer(UiHome.T_UNLOCK)
	_unlock_timer.timeout.connect(_finish_unlock, CONNECT_ONE_SHOT)


func _finish_unlock() -> void:
	var id := _unlocking_id
	_unlocking_id = ""
	refresh()
	_notify_play_chip()
	var def: SeasonDef = GameState.get_season_def(id)
	if def:
		_show_toast("%s unlocked · now playing" % def.display_name, true)


func _detect_fresh() -> void:
	var now: Dictionary = {}
	for def in SeasonCatalog.all_defs():
		if GameState.is_season_playable(def.id):
			now[def.id] = true
	var arrival := ""
	if _known_ready and _unlocking_id.is_empty() and not _suppress_camp:
		for id in now.keys():
			if not _known_playable.has(id):
				var def: SeasonDef = GameState.get_season_def(str(id))
				if def != null and def.is_free() and str(id) == GameState.active_season_id:
					arrival = str(id)
	_known_playable = now
	_known_ready = true
	if not arrival.is_empty():
		var def: SeasonDef = GameState.get_season_def(arrival)
		if def:
			_show_toast("Unlocked in Camp · now playing", true)


# --- premium ---

func _on_cta_pressed(season_id: String) -> void:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return
	if GameState.is_season_playable(season_id):
		open_season_field(season_id)
		return
	if GameState.is_test_locked_season(season_id) or def.iap_product_id.is_empty():
		return
	if IAPManager.is_busy():
		return
	_buying_id = season_id
	IAPManager.purchase(def.iap_product_id)
	_apply_card()


func _on_purchase_done(_sku: String) -> void:
	if _buying_id.is_empty():
		return
	var id := _buying_id
	_buying_id = ""
	_suppress_camp = true
	if GameState.is_season_playable(id):
		_set_focus(id)
	_refresh_top_bar()
	refresh()
	_suppress_camp = false
	var def: SeasonDef = GameState.get_season_def(id)
	if def and GameState.is_season_playable(id):
		_show_toast("%s is yours · now playing" % def.display_name, true)


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if _buying_id.is_empty():
		return
	_buying_id = ""
	_apply_card()


# --- polje sezone ---

func _sync_season_field() -> void:
	var open := GameState.home_season_field_open
	season_select.visible = not open
	if season_field:
		season_field.visible = open
		season_field.mouse_filter = (
			Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
		)
		if open and season_field.has_method("apply_season"):
			season_field.call("apply_season", GameState.home_season_field_id)
		elif not open and season_field.has_method("dismiss_flowers"):
			season_field.call("dismiss_flowers")
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
	_notify_home_field_backdrop()


func _is_hub_on_home() -> bool:
	if not is_inside_tree():
		return true
	var hubs := get_tree().get_nodes_in_group("meta_hub")
	if hubs.is_empty():
		return true
	var hub: Node = hubs[0]
	if hub.has_method("current_page_index"):
		return int(hub.call("current_page_index")) == MetaHubPages.MAIN
	return true


func _try_close_field_on_back() -> bool:
	if not GameState.home_season_field_open:
		return false
	if not is_visible_in_tree():
		return false
	if not _is_hub_on_home():
		return false
	close_season_field()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var back := false
	if event.is_action_pressed("ui_cancel"):
		back = true
	elif event is InputEventKey:
		var key := event as InputEventKey
		back = key.pressed and key.keycode == KEY_ESCAPE
	if not back:
		return
	if _try_close_field_on_back():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_try_close_field_on_back()


func _notify_home_field_backdrop() -> void:
	var n: Node = get_parent()
	while n:
		if n.has_method("sync_field_backdrop"):
			n.call("sync_field_backdrop")
			return
		n = n.get_parent()


func _notify_play_chip() -> void:
	if owner and owner.has_method("refresh_play_chip"):
		owner.call("refresh_play_chip")
	if owner and owner.has_method("refresh_progress_indicator"):
		owner.call("refresh_progress_indicator")


func _refresh_top_bar() -> void:
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")
