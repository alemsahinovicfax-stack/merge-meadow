extends Control

## Home Season Stage — pass 2 / 1a (design_handoff_home_v2 · SeasonStage.dc.html).
## Kartica 1032 x 1100 na (24, 24) stranice, dock 1080 x 222 na (0, 1148),
## toast na 250. Swipe na kartici mijenja fokus i nikad ne ide hubu (na krajevima
## rubber-band 40 px); fokus != aktivna sezona. Polje sezone (HOME-19) je u istoj
## sceni: kad je otvoreno, SelectLayer je sakriven.

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const TOAST_OK_EDGE := Color("#2D3436")

@onready var select_layer: Control = %SelectLayer
@onready var card_clip: Control = %CardClip
@onready var card_host: Control = %CardHost
@onready var season_browser: SeasonBrowser = %SeasonBrowser
@onready var season_field: Control = %SeasonField
@onready var stage_toast: PanelContainer = %StageToast
@onready var stage_toast_label: Label = %StageToastLabel

var _cards: Dictionary = {}
var _page_ids: Array[String] = []
var _shown_id: String = ""
var _unlocking_id: String = ""
var _buying_id: String = ""
var _known_playable: Dictionary = {}
var _known_ready: bool = false
var _field_was_open: bool = false
var _field_tween: Tween
var _slide_tween: Tween
var _toast_tween: Tween
var _unlock_timer: SceneTreeTimer
var _drag_on: bool = false
var _drag_moved: bool = false
var _drag_start := Vector2.ZERO
var _drag_dx: float = 0.0
var _drag_part: String = ""
var _drag_last_x: float = 0.0
var _drag_last_t: float = 0.0
var _drag_vel: float = 0.0


func is_field_transitioning() -> bool:
	return _field_tween != null and _field_tween.is_running()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if card_clip:
		card_clip.gui_input.connect(_on_card_clip_gui)
		card_clip.mouse_filter = Control.MOUSE_FILTER_STOP
		if not card_clip.is_in_group(BLOCK_HUB_SWIPE_GROUP):
			card_clip.add_to_group(BLOCK_HUB_SWIPE_GROUP)
	if season_browser:
		season_browser.token_pressed.connect(_on_token_pressed)
	IAPManager.purchase_completed.connect(_on_purchase_done)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
		seasons_btn.set("label_text", "")
	_setup_toast()
	refresh()


func refresh() -> void:
	_detect_fresh()
	_refresh_select(false)
	_sync_season_field()
	_notify_play_chip()


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
	return _cards.get(season_id) as HomeSeasonCard


func focused_card_id() -> String:
	if not _shown_id.is_empty():
		return _shown_id
	return GameState.home_hero_center_id()


func page_ids() -> Array[String]:
	return _page_ids.duplicate()


## Isto kao tap na token ili na karticu: drugi fokus -> klizi do nje; fokusirana
## otkljucana -> otvara polje; daleki lock -> shake + toast.
func tap_card(season_id: String) -> void:
	if GameState.home_season_field_open or is_unlocking():
		return
	if season_id != _shown_id:
		_on_token_pressed(season_id)
		return
	_on_card_tapped(season_id)


func is_unlocking() -> bool:
	return not _unlocking_id.is_empty()


func is_sliding() -> bool:
	return _slide_tween != null and _slide_tween.is_valid() and _slide_tween.is_running()


func get_free_path_text() -> String:
	return season_browser.get_free_path_text() if season_browser else ""


func get_toast_text() -> String:
	return stage_toast_label.text if stage_toast and stage_toast.visible else ""


# --- fokus ---

## Fokus: otkljucane free, sljedeci free lock i sva 4 premium paketa.
func _focusable_ids() -> Array[String]:
	var out: Array[String] = []
	var next_id := _next_lock_id()
	for def in SeasonCatalog.free_defs_sorted():
		if def.id == next_id or (GameState.is_season_playable(def.id) and def.id != _unlocking_id):
			out.append(def.id)
	for def in SeasonCatalog.paid_defs():
		out.append(def.id)
	return out


## Dok traje trenutak otkljucavanja, ta sezona je jos "sljedeci lock".
func _next_lock_id() -> String:
	return _unlocking_id if not _unlocking_id.is_empty() else GameState.next_locked_free_id()


func _is_far(season_id: String) -> bool:
	return not _page_ids.has(season_id)


func _focus_season(season_id: String) -> bool:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return false
	if def.is_paid():
		if not GameState.set_paid_strip_focus(season_id):
			return false
		GameState.set_home_band("paid")
	else:
		if not GameState.set_free_strip_focus(season_id):
			return false
		GameState.set_home_band("free")
	return true


func _current_focus() -> String:
	var id := GameState.home_hero_center_id()
	if _page_ids.has(id):
		return id
	var active := GameState.active_season_id
	var fallback := active if _page_ids.has(active) else (_page_ids[0] if not _page_ids.is_empty() else "")
	if not fallback.is_empty():
		_focus_season(fallback)
	return fallback


# --- kartice + dock ---

func _refresh_select(animated: bool) -> void:
	_page_ids = _focusable_ids()
	var focus_id := _current_focus()
	if not is_sliding():
		_shown_id = focus_id
	for def in SeasonCatalog.all_defs():
		_card_for(def.id).configure(_card_data(def))
	if not is_sliding() and not _drag_on:
		_place_cards()
	_configure_dock(animated)


func _card_data(def: SeasonDef) -> Dictionary:
	var id := def.id
	var playable := GameState.is_season_playable(id)
	var active_id := GameState.active_season_id
	var state := HomeSeasonCard.ST_FAR
	if def.is_free():
		if id == _unlocking_id:
			state = HomeSeasonCard.ST_UNLOCKING
		elif playable:
			state = HomeSeasonCard.ST_ACTIVE if id == active_id else HomeSeasonCard.ST_OPEN
		elif id == _next_lock_id():
			state = HomeSeasonCard.ST_READY if GameState.can_unlock_free(id) else HomeSeasonCard.ST_GATHER
	else:
		if GameState.is_test_locked_season(id):
			state = HomeSeasonCard.ST_SOON
		elif playable:
			state = HomeSeasonCard.ST_ACTIVE if id == active_id else HomeSeasonCard.ST_OPEN
		elif id == _buying_id:
			state = HomeSeasonCard.ST_PURCHASING
		else:
			state = HomeSeasonCard.ST_PREMIUM
	var roster: Array = []
	for entry in def.roster:
		roster.append({
			"id": str(entry.get("id", "")),
			"name": str(entry.get("display_name", entry.get("id", ""))),
			"rarity": int(entry.get("rarity", 1)),
		})
	var prev := GameState.previous_free_id_for(id)
	var prev_def: SeasonDef = GameState.get_season_def(prev) if not prev.is_empty() else null
	var gate_type := GameState.star3_type_id_for_season(prev) if not prev.is_empty() else ""
	var idx := _page_ids.find(id)
	var unlocking := state == HomeSeasonCard.ST_UNLOCKING
	return {
		"season_id": id,
		"state": state,
		"name": def.display_name,
		"tagline": def.tagline,
		"kind": "paid" if def.is_paid() else "free",
		"order": def.order,
		"free_total": SeasonCatalog.free_defs_sorted().size(),
		"roster": roster,
		"coins": def.coins_cost if unlocking else int(GameState.wallet_coins),
		"coins_need": def.coins_cost,
		"flowers": def.t3_flowers_required if unlocking else GameState.star3_flower_count_for_unlock(id),
		"flowers_need": def.t3_flowers_required,
		"gate_type_id": gate_type,
		"gate_name": GameState.get_seed_display_name(gate_type) if not gate_type.is_empty() else "",
		"gate_mood": SeasonColors.mood_of(prev) if not prev.is_empty() else SeasonColors.mood_of(id),
		"prev_name": prev_def.display_name if prev_def else "",
		"price": IAPManager.get_price_label(def.iap_product_id) if not def.iap_product_id.is_empty() else "",
		"prev_on": idx > 0,
		"next_on": idx >= 0 and idx < _page_ids.size() - 1,
	}


func _card_for(season_id: String) -> HomeSeasonCard:
	var card := _cards.get(season_id) as HomeSeasonCard
	if card != null:
		return card
	card = HomeSeasonCard.new()
	card.name = "Card_%s" % season_id
	card.visible = false
	card.tapped.connect(_on_card_tapped)
	card.open_field_pressed.connect(_on_open_field_pressed)
	card.unlock_pressed.connect(_on_unlock_pressed)
	card.cta_pressed.connect(_on_cta_pressed)
	card.page_pressed.connect(_page_by)
	card_host.add_child(card)
	_cards[season_id] = card
	return card


func _place_cards() -> void:
	for id in _cards:
		var card := _cards[id] as HomeSeasonCard
		var on_stage: bool = id == _shown_id and not GameState.home_season_field_open
		card.visible = on_stage
		card.position = Vector2.ZERO


func _configure_dock(animated: bool) -> void:
	if season_browser == null:
		return
	var free_ids: Array[String] = []
	var paid_ids: Array[String] = []
	var status: Dictionary = {}
	var next_id := _next_lock_id()
	for def in SeasonCatalog.free_defs_sorted():
		free_ids.append(def.id)
		if def.id == next_id:
			status[def.id] = HomeDockToken.S_NEXT
		elif GameState.is_season_playable(def.id):
			status[def.id] = HomeDockToken.S_OPEN
		else:
			status[def.id] = HomeDockToken.S_FAR
	for def in SeasonCatalog.paid_defs():
		paid_ids.append(def.id)
		if GameState.is_test_locked_season(def.id):
			status[def.id] = HomeDockToken.S_SOON
		elif GameState.is_season_playable(def.id):
			status[def.id] = HomeDockToken.S_OPEN
		else:
			status[def.id] = HomeDockToken.S_PAID
	season_browser.configure(
		free_ids, paid_ids, _shown_id, GameState.active_season_id, status, _gate_progress(next_id), animated
	)


## (min(coins, 500) / 500 + min(★3, 20) / 20) / 2 — bar na next-lock tokenu.
func _gate_progress(season_id: String) -> float:
	if season_id.is_empty():
		return 0.0
	if season_id == _unlocking_id:
		return 1.0
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return 0.0
	var c := minf(float(GameState.wallet_coins), float(def.coins_cost)) / maxf(float(def.coins_cost), 1.0)
	var f := minf(float(GameState.star3_flower_count_for_unlock(season_id)), float(def.t3_flowers_required)) / maxf(float(def.t3_flowers_required), 1.0)
	return (c + f) * 0.5


# --- paging ---

func _page_by(delta: int) -> void:
	var i := _page_ids.find(_shown_id)
	if i < 0:
		return
	var j := i + delta
	if j < 0 or j >= _page_ids.size():
		_snap_back()
		return
	_slide_to(_page_ids[j], 1 if delta > 0 else -1)


## Klizanje 1080 px, 280 ms cubic out. dir +1 = sljedeca (dolazi zdesna).
func _slide_to(target_id: String, dir: int) -> void:
	if target_id == _shown_id or not _focus_season(target_id):
		_snap_back()
		return
	var old := get_card(_shown_id)
	var new := get_card(target_id)
	var start_x := old.position.x if old else 0.0
	_kill_slide()
	for id in _cards:
		var other := _cards[id] as HomeSeasonCard
		if other != old and other != new:
			other.visible = false
	_shown_id = target_id
	_refresh_select(true)
	var w := UiStage.STAGE.x
	new.position = Vector2(start_x + float(dir) * w, 0.0)
	new.visible = true
	_notify_play_chip()
	if not is_inside_tree():
		_place_cards()
		return
	_slide_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if old:
		old.visible = true
		old.position.x = start_x
		_slide_tween.tween_property(old, "position:x", -float(dir) * w, UiStage.T_PAGE)
	_slide_tween.tween_property(new, "position:x", 0.0, UiStage.T_PAGE)
	_slide_tween.chain().tween_callback(func() -> void:
		_slide_tween = null
		_place_cards()
	)


func _snap_back() -> void:
	var card := get_card(_shown_id)
	if card == null:
		return
	var neighbors: Array[HomeSeasonCard] = []
	for id in _cards:
		var other := _cards[id] as HomeSeasonCard
		if other != card and other.visible:
			neighbors.append(other)
	if not is_inside_tree():
		_place_cards()
		return
	_kill_slide()
	_slide_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(card, "position:x", 0.0, UiStage.T_PAGE)
	for other in neighbors:
		var away := UiStage.STAGE.x * (1.0 if other.position.x > 0.0 else -1.0)
		_slide_tween.tween_property(other, "position:x", away, UiStage.T_PAGE)
	_slide_tween.chain().tween_callback(func() -> void:
		_slide_tween = null
		_place_cards()
	)


func _kill_slide() -> void:
	if _slide_tween:
		_slide_tween.kill()
		_slide_tween = null


# --- input na kartici ---

func _on_card_clip_gui(event: InputEvent) -> void:
	if GameState.home_season_field_open:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		_pointer(mb.position, mb.pressed)
		card_clip.accept_event()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		_pointer(st.position, st.pressed)
		card_clip.accept_event()
	elif event is InputEventScreenDrag:
		_drag((event as InputEventScreenDrag).position)
		card_clip.accept_event()
	elif event is InputEventMouseMotion and _drag_on:
		_drag((event as InputEventMouseMotion).position)
		card_clip.accept_event()


func _pointer(pos: Vector2, pressed: bool) -> void:
	var card := get_card(_shown_id)
	if pressed:
		if _drag_on or is_sliding() or is_unlocking() or card == null:
			return
		_drag_on = true
		_drag_moved = false
		_drag_start = pos
		_drag_dx = 0.0
		_drag_vel = 0.0
		_drag_last_x = pos.x
		_drag_last_t = Time.get_ticks_msec() / 1000.0
		_drag_part = card.hit_part(pos - card.position)
		if _drag_part != HomeSeasonCard.PART_CARD:
			card.set_pressed_part(_drag_part)
		return
	if not _drag_on:
		return
	_drag_on = false
	if card:
		card.set_pressed_part(HomeSeasonCard.PART_NONE)
	if not _drag_moved:
		if card and not _drag_part.is_empty():
			card.press_part(_drag_part)
		return
	var dx := _drag_dx
	if absf(dx) >= UiStage.SWIPE_MIN or absf(_drag_vel) >= UiStage.SWIPE_VELOCITY:
		var toward_next := dx < 0.0
		if absf(dx) < UiStage.SWIPE_MIN:
			toward_next = _drag_vel < 0.0
		var dir := 1 if toward_next else -1
		var j := _page_ids.find(_shown_id) + dir
		if j >= 0 and j < _page_ids.size():
			_slide_to(_page_ids[j], dir)
			return
	_snap_back()


func _drag(pos: Vector2) -> void:
	if not _drag_on:
		return
	var delta := pos - _drag_start
	if not _drag_moved:
		if absf(delta.x) < UiStage.TAP_SLOP and absf(delta.y) < UiStage.TAP_SLOP:
			return
		_drag_moved = true
		var card := get_card(_shown_id)
		if card:
			card.set_pressed_part(HomeSeasonCard.PART_NONE)
	var now := Time.get_ticks_msec() / 1000.0
	var dt := now - _drag_last_t
	if dt >= 0.008:
		_drag_vel = (pos.x - _drag_last_x) / dt
		_drag_last_x = pos.x
		_drag_last_t = now
	_drag_dx = delta.x
	_apply_drag()


## Kartica prati prst; susjedna viri s druge strane. Na krajevima rubber-band 40 px.
func _apply_drag() -> void:
	var card := get_card(_shown_id)
	if card == null:
		return
	var i := _page_ids.find(_shown_id)
	var dir := 1 if _drag_dx < 0.0 else -1
	var j := i + dir
	var w := UiStage.STAGE.x
	for id in _cards:
		var other := _cards[id] as HomeSeasonCard
		if other != card:
			other.visible = false
	if j < 0 or j >= _page_ids.size():
		card.position.x = signf(_drag_dx) * minf(absf(_drag_dx) * 0.35, UiStage.RUBBER)
		return
	card.position.x = _drag_dx
	var neighbor := get_card(_page_ids[j])
	if neighbor:
		neighbor.visible = true
		neighbor.position = Vector2(_drag_dx + float(dir) * w, 0.0)


# --- tap / akcije ---

func _on_token_pressed(season_id: String) -> void:
	if GameState.home_season_field_open or is_unlocking():
		return
	if _is_far(season_id):
		var prev := GameState.previous_free_id_for(season_id)
		var prev_def: SeasonDef = GameState.get_season_def(prev)
		if season_browser:
			season_browser.shake_token(season_id)
		_show_toast("Unlock %s first" % (prev_def.display_name if prev_def else "the previous season"), false)
		return
	if season_id == _shown_id:
		return
	var dir := 1 if _page_ids.find(season_id) > _page_ids.find(_shown_id) else -1
	_slide_to(season_id, dir)


func _on_card_tapped(season_id: String) -> void:
	if season_id != _shown_id or GameState.home_season_field_open:
		return
	if GameState.is_season_playable(season_id) and season_id != _unlocking_id:
		open_season_field(season_id)


func _on_open_field_pressed(season_id: String) -> void:
	if season_id == _unlocking_id:
		return
	open_season_field(season_id)


func _on_unlock_pressed(season_id: String) -> void:
	if is_unlocking():
		return
	if not GameState.unlock_free(season_id):
		_refresh_select(false)
		return
	_unlocking_id = season_id
	_known_playable[season_id] = true
	_refresh_top_bar()
	_refresh_select(false)
	var card := get_card(season_id)
	if card:
		card.play_unlock()
	_notify_play_chip()
	if not is_inside_tree():
		_finish_unlock()
		return
	_unlock_timer = get_tree().create_timer(UiStage.T_UNLOCK)
	_unlock_timer.timeout.connect(_finish_unlock, CONNECT_ONE_SHOT)


func _finish_unlock() -> void:
	var id := _unlocking_id
	_unlocking_id = ""
	_refresh_select(true)
	_notify_play_chip()
	var def: SeasonDef = GameState.get_season_def(id)
	if def:
		_show_toast("%s unlocked · now playing" % def.display_name, true)


func _on_cta_pressed(season_id: String) -> void:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return
	if GameState.is_season_playable(season_id):
		open_season_field(season_id)
		return
	if GameState.is_test_locked_season(season_id) or def.iap_product_id.is_empty() or IAPManager.is_busy():
		return
	_buying_id = season_id
	_refresh_select(false)
	IAPManager.purchase(def.iap_product_id)


func _on_purchase_done(_sku: String) -> void:
	if _buying_id.is_empty():
		return
	var id := _buying_id
	_buying_id = ""
	if GameState.is_season_playable(id):
		_known_playable[id] = true
		_focus_season(id)
		var def: SeasonDef = GameState.get_season_def(id)
		if def:
			_show_toast("%s is yours · now playing" % def.display_name, true)
	_refresh_top_bar()
	refresh()


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if _buying_id.is_empty():
		return
	_buying_id = ""
	_refresh_select(false)


## Sezona koja je postala igriva van Homea (Camp unlock, Shop): fokus na nju +
## toast, bez ponovnog trenutka otkljucavanja.
func _detect_fresh() -> void:
	var now: Dictionary = {}
	for def in SeasonCatalog.all_defs():
		if GameState.is_season_playable(def.id):
			now[def.id] = true
	var fresh := ""
	if _known_ready:
		for id: String in now:
			if not _known_playable.has(id):
				fresh = id
	_known_playable = now
	_known_ready = true
	if fresh.is_empty():
		return
	_focus_season(fresh)
	var def: SeasonDef = GameState.get_season_def(fresh)
	if def == null:
		return
	if def.is_free():
		_show_toast("Unlocked in Camp · now playing", true)
	else:
		_show_toast("%s is yours · now playing" % def.display_name, true)


# --- toast (toast_success | toast_blocked) ---

func _setup_toast() -> void:
	if stage_toast == null:
		return
	stage_toast.visible = false
	stage_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_toast.z_index = 30
	UiStage.style(stage_toast_label, 900, 40, UiStage.INK)
	stage_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_toast_label.autowrap_mode = TextServer.AUTOWRAP_OFF


func _show_toast(text: String, ok: bool) -> void:
	if stage_toast == null or stage_toast_label == null:
		return
	var fill := UiStage.GOLD if ok else UiStage.CHROME
	var edge := TOAST_OK_EDGE if ok else UiStage.BLOCKED
	var ink := UiStage.INK if ok else UiStage.CREAM
	var pad_x := UiStage.TOAST_PAD + 4.0
	var style := UiStage.pad(UiStage.box(fill, int(UiStage.TOAST_H * 0.5), 4, edge), pad_x, 4.0, pad_x, 4.0)
	stage_toast.add_theme_stylebox_override("panel", style)
	stage_toast_label.text = text
	stage_toast_label.add_theme_color_override("font_color", ink)
	var w := UiStage.text_w(UiStage.font(900, 40), 40, text) + pad_x * 2.0
	stage_toast.size = Vector2(w, UiStage.TOAST_H)
	var stage_w := size.x if size.x > 8.0 else UiStage.CARD.size.x
	stage_toast.position = Vector2(
		(stage_w - w) * 0.5, UiStage.TOAST_TOP - UiStage.CARD.position.y
	)
	stage_toast.visible = true
	stage_toast.modulate.a = 0.0
	if _toast_tween:
		_toast_tween.kill()
	if not is_inside_tree():
		stage_toast.modulate.a = 1.0
		return
	_toast_tween = create_tween()
	_toast_tween.tween_property(stage_toast, "modulate:a", 1.0, UiStage.T_TOAST_FADE)
	_toast_tween.tween_interval(UiStage.T_TOAST)
	_toast_tween.tween_property(stage_toast, "modulate:a", 0.0, UiStage.T_TOAST_FADE)
	_toast_tween.tween_callback(func() -> void:
		stage_toast.visible = false
	)


# --- polje sezone (HOME-19) ---

func _sync_season_field() -> void:
	var open := GameState.home_season_field_open
	var just_opened := open and not _field_was_open
	var just_closed := not open and _field_was_open
	_field_was_open = open
	var from_rect := Rect2()
	if just_opened:
		var card := get_card(GameState.home_season_field_id)
		if card and card.visible:
			from_rect = card.get_global_rect()
	if select_layer:
		select_layer.visible = not open
	if open and stage_toast:
		stage_toast.visible = false
	if season_field:
		season_field.visible = open
		season_field.mouse_filter = (
			Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
		)
		season_field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
	_notify_home_field_backdrop()
	if season_field:
		if size.x >= 8.0:
			season_field.size = size
		if open and season_field.has_method("apply_season"):
			season_field.call("apply_season", GameState.home_season_field_id)
		elif not open and season_field.has_method("dismiss_flowers"):
			season_field.call("dismiss_flowers")
	if just_opened:
		_play_field_open_motion(from_rect)
	elif just_closed:
		_kill_field_tween()
		_refresh_select(false)


func _kill_field_tween() -> void:
	if _field_tween:
		_field_tween.kill()
		_field_tween = null


func _play_field_open_motion(from_rect: Rect2 = Rect2()) -> void:
	if season_field == null:
		return
	_kill_field_tween()
	season_field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	season_field.modulate.a = 0.0
	if from_rect.size.x > 8.0:
		_spawn_open_shell(from_rect)
	_field_tween = create_tween()
	_field_tween.tween_property(season_field, "modulate:a", 1.0, UiHomeField.ANIM.field_open) \
		.set_ease(Tween.EASE_OUT)
	_field_tween.finished.connect(_on_field_open_finished, CONNECT_ONE_SHOT)
	if owner and owner.has_method("play_field_chrome_in"):
		owner.call("play_field_chrome_in")


func _spawn_open_shell(from_rect: Rect2) -> void:
	var shell := Panel.new()
	shell.name = "FieldOpenShell"
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.z_index = 4
	var sb := UiHomeField.meadow_frame(GameState.home_season_field_id)
	shell.add_theme_stylebox_override("panel", sb)
	add_child(shell)
	var inv := get_global_transform_with_canvas().affine_inverse()
	shell.position = inv * from_rect.position
	shell.size = from_rect.size
	var dest := Rect2(Vector2.ZERO, size)
	if dest.size.x < 8.0:
		dest.size = Vector2(UiHomeField.MEADOW)
	var t := UiHomeField.tween_open_field(shell, dest, SeasonTheme.home_field_tint(GameState.home_season_field_id))
	t.finished.connect(func() -> void:
		if is_instance_valid(shell):
			shell.queue_free()
	, CONNECT_ONE_SHOT)


func _on_field_open_finished() -> void:
	_field_tween = null
	if season_field == null or not GameState.home_season_field_open:
		return
	season_field.modulate.a = 1.0
	season_field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if season_field.has_method("settle_flowers"):
		season_field.call("settle_flowers")


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


func _refresh_top_bar() -> void:
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")
