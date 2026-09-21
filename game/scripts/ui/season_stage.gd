extends Control

## Home Season Stage — smjer 1a Season Trail (design_handoff_home).
## Jedna vertikalna kolona: besplatni put redom, red "Premium seasons", premium
## kartice ispod. Tacno jedna kartica je otvorena (harmonika); tap mijenja fokus
## (tween visine 0,22 s). Nema horizontalnih gesti, pa stage NE blokira hub swipe.
## Polje sezone (SeasonField) zivi u istoj sceni i otvara se tapom na aktivnu karticu.

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")

@onready var trail: ScrollContainer = %SeasonTrail
@onready var trail_list: VBoxContainer = %TrailList
@onready var season_field: Control = %SeasonField

var _cards: Dictionary = {}          # season_id -> HomeSeasonCard
var _premium_header: HomePremiumHeader
var _premium_open: bool = false
var _premium_user_set: bool = false
var _unlocking_id: String = ""
var _fresh_id: String = ""
var _buying_id: String = ""
var _known_playable: Dictionary = {}
var _known_ready: bool = false
var _scroll_tween: Tween
var _unlock_timer: SceneTreeTimer
var _laid_out_h: float = -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_premium_header = HomePremiumHeader.new()
	_premium_header.toggled.connect(_on_premium_toggled)
	trail_list.add_child(_premium_header)
	trail.gui_input.connect(_on_trail_gui_input)
	trail.resized.connect(_on_trail_resized)
	IAPManager.purchase_completed.connect(_on_purchase_done)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	var seasons_btn: Control = get_node_or_null("%SeasonsButton") as Control
	if seasons_btn:
		seasons_btn.visible = false
		seasons_btn.set("label_text", "")
	refresh()


func refresh() -> void:
	_detect_fresh()
	_refresh_trail(false)
	_sync_season_field()
	_notify_play_chip()


# --- javni API (main_menu, Camp, smoke) ---

## Otvara polje sezone; bez id-a otvara fokusiranu sezonu (ako je igriva), inace aktivnu.
func open_season_field(season_id: String = "") -> bool:
	var id := season_id
	if id.is_empty():
		id = GameState.home_hero_center_id()
		if not GameState.is_season_playable(id):
			id = GameState.active_season_id
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


func get_premium_header() -> HomePremiumHeader:
	return _premium_header


func is_premium_open() -> bool:
	return _premium_open


## Kartica koja je trenutno otvorena (expanded / poster / premium), ili "".
func focused_card_id() -> String:
	for id: String in _cards:
		var card := _cards[id] as HomeSeasonCard
		if card.visible and card.variant != UiHome.COLLAPSED and card.variant != UiHome.NEXTLOCK:
			return id
	return ""


func tap_card(season_id: String) -> void:
	_on_card_tapped(season_id)


func toggle_premium() -> void:
	_on_premium_toggled()


# --- gradnja kolone ---

func _refresh_trail(animated: bool) -> void:
	var anim := animated and is_visible_in_tree()
	var focus_paid := GameState.home_band == "paid"
	var focus_id := GameState.home_hero_center_id()
	var next_id := GameState.next_locked_free_id()
	var active_id := GameState.active_season_id
	var free_defs := SeasonCatalog.free_defs_sorted()
	var paid_defs := SeasonCatalog.paid_defs()
	if focus_paid:
		_premium_open = true
	elif not _premium_user_set:
		_premium_open = next_id.is_empty()

	var order: Array[Control] = []
	var focused: HomeSeasonCard = null
	for i in free_defs.size():
		var def: SeasonDef = free_defs[i]
		var data := _free_card_data(def, i, focus_paid, focus_id, next_id, active_id)
		var card := _card_for(def.id)
		card.configure(data)
		card.visible = true
		order.append(card)
		if data["variant"] != UiHome.COLLAPSED and data["variant"] != UiHome.NEXTLOCK:
			focused = card
	var paid_ids: Array[String] = []
	for def in paid_defs:
		paid_ids.append(def.id)
	_premium_header.configure(paid_ids, _premium_open)
	_premium_header.visible = not paid_defs.is_empty()
	order.append(_premium_header)
	for def in paid_defs:
		var card := _card_for(def.id)
		card.visible = _premium_open
		if not _premium_open:
			continue
		var data := _paid_card_data(def, focus_paid, focus_id, active_id)
		card.configure(data)
		order.append(card)
		if data["variant"] == UiHome.PREMIUM:
			focused = card
	for i in order.size():
		trail_list.move_child(order[i], i)
	_apply_heights(order, focused, anim)
	if anim and focused != null:
		_scroll_to(focused)


func _free_card_data(
	def: SeasonDef, index: int, focus_paid: bool, focus_id: String, next_id: String, active_id: String
) -> Dictionary:
	var id := def.id
	var variant := UiHome.COLLAPSED
	var state := UiHome.ST_LOCKED
	if GameState.is_season_playable(id):
		state = UiHome.ST_ACTIVE if id == active_id else UiHome.ST_UNLOCKED
		if not focus_paid and id == focus_id:
			variant = UiHome.EXPANDED
	elif id == next_id:
		state = UiHome.ST_READY if GameState.can_unlock_free(id) else UiHome.ST_NEXT
		if not focus_paid and id == focus_id:
			variant = UiHome.POSTER
		elif not focus_paid:
			variant = UiHome.NEXTLOCK
	if id == _unlocking_id:
		state = UiHome.ST_UNLOCKING
		variant = UiHome.POSTER
	var data := _base_data(def)
	data["variant"] = variant
	data["state"] = state
	data["active"] = state == UiHome.ST_ACTIVE
	var prev := GameState.previous_free_id_for(id)
	var prev_def: SeasonDef = GameState.get_season_def(prev) if not prev.is_empty() else null
	data["prev_name"] = prev_def.display_name if prev_def else ""
	var gate_type := GameState.star3_type_id_for_season(prev) if not prev.is_empty() else ""
	data["gate_type_id"] = gate_type
	data["gate_name"] = GameState.get_seed_display_name(gate_type) if not gate_type.is_empty() else ""
	data["coins_need"] = def.coins_cost
	data["flowers_need"] = def.t3_flowers_required
	if state == UiHome.ST_UNLOCKING:
		data["coins"] = def.coins_cost
		data["flowers"] = def.t3_flowers_required
	else:
		data["coins"] = int(GameState.wallet_coins)
		data["flowers"] = GameState.star3_flower_count_for_unlock(id)
	return data


func _paid_card_data(def: SeasonDef, focus_paid: bool, focus_id: String, active_id: String) -> Dictionary:
	var id := def.id
	var state := UiHome.ST_PREMIUM
	if GameState.is_test_locked_season(id):
		state = UiHome.ST_SOON
	elif GameState.is_season_playable(id):
		state = UiHome.ST_OWNED
	elif id == _buying_id and IAPManager.is_busy():
		state = UiHome.ST_BUSY
	var data := _base_data(def)
	data["variant"] = UiHome.PREMIUM if focus_paid and id == focus_id else UiHome.COLLAPSED
	data["state"] = state
	data["active"] = state == UiHome.ST_OWNED and id == active_id
	data["price"] = IAPManager.get_price_label(def.iap_product_id) if not def.iap_product_id.is_empty() else ""
	return data


func _base_data(def: SeasonDef) -> Dictionary:
	var roster: Array = []
	for entry in def.roster:
		roster.append({"id": str(entry.get("id", "")), "rarity": int(entry.get("rarity", 1))})
	return {
		"season_id": def.id,
		"name": def.display_name,
		"tagline": def.tagline,
		"roster": roster,
		# "New" dolazi tek poslije prstena (Home Unlock.dc.html, kadar 3).
		"fresh": def.id == _fresh_id and def.id != _unlocking_id,
	}


func _card_for(season_id: String) -> HomeSeasonCard:
	var card := _cards.get(season_id) as HomeSeasonCard
	if card != null:
		return card
	card = HomeSeasonCard.new()
	card.name = "Card_%s" % season_id
	card.tapped.connect(_on_card_tapped)
	card.open_field_pressed.connect(_on_open_field_pressed)
	card.unlock_pressed.connect(_on_unlock_pressed)
	card.cta_pressed.connect(_on_cta_pressed)
	card.fresh_done.connect(_on_fresh_done)
	trail_list.add_child(card)
	_cards[season_id] = card
	return card


## Visina po varijanti (ili vise, ako sadrzaj trazi — npr. "Need …" u dva reda);
## otvorena kartica uzme ostatak kolone, kao g.h u HomeScreen.dc.html, i smije
## se smanjiti do svog minimuma (roster na manjem okviru) da kolona stane bez skrola.
func _apply_heights(order: Array[Control], focused: HomeSeasonCard, animated: bool) -> void:
	var sep := trail_list.get_theme_constant("separation")
	var heights: Dictionary = {}
	var used := 0.0
	var shown := 0
	for node in order:
		if not node.visible:
			continue
		shown += 1
		var h := node.custom_minimum_size.y
		if node is HomeSeasonCard:
			var card := node as HomeSeasonCard
			h = float(UiHome.CARD_H[card.variant])
			if card != focused:
				h = maxf(h, card.get_minimum_size().y)
			heights[card] = h
		used += h
	used += float(sep * maxi(shown - 1, 0))
	if focused != null and heights.has(focused):
		var fit := float(heights[focused]) + trail.size.y - used
		# Smanjuje se samo kad kolona time stvarno stane; ako ionako skrola
		# (npr. otvorena premium lista), kartica zadrzava punu visinu.
		if fit >= focused.floor_height():
			heights[focused] = fit
	for card: HomeSeasonCard in heights:
		card.set_target_height(float(heights[card]), animated)


func _scroll_to(card: Control) -> void:
	await get_tree().process_frame
	if not is_instance_valid(card) or not card.is_inside_tree():
		return
	var top := card.position.y
	var bottom := top + card.custom_minimum_size.y
	var view := trail.size.y
	var target := float(trail.scroll_vertical)
	if top < target:
		target = top
	elif bottom > target + view:
		target = minf(top, bottom - view)
	if is_equal_approx(target, float(trail.scroll_vertical)):
		return
	if _scroll_tween:
		_scroll_tween.kill()
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(trail, "scroll_vertical", int(target), UiHome.T_SCROLL) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# --- tapovi ---

func _on_card_tapped(season_id: String) -> void:
	if GameState.home_season_field_open or not _unlocking_id.is_empty():
		return
	var def: SeasonDef = GameState.get_season_def(season_id)
	var card := get_card(season_id)
	if def == null or card == null:
		return
	var playable := GameState.is_season_playable(season_id)
	if def.is_free():
		if playable and season_id == GameState.active_season_id:
			open_season_field(season_id)
			return
		if playable:
			GameState.set_active_season(season_id)
			GameState.set_home_band("free")
			_after_focus_change()
			return
		if season_id == GameState.next_locked_free_id():
			GameState.set_free_strip_focus(season_id)
			GameState.set_home_band("free")
			_after_focus_change()
			return
		card.bounce()
		return
	if card.variant == UiHome.PREMIUM:
		if playable and season_id == GameState.active_season_id:
			open_season_field(season_id)
		return
	GameState.set_paid_strip_focus(season_id)
	GameState.set_home_band("paid")
	if playable:
		GameState.set_active_season(season_id)
	_after_focus_change()


func _after_focus_change() -> void:
	_refresh_trail(true)
	_notify_play_chip()


func _on_open_field_pressed(season_id: String) -> void:
	open_season_field(season_id)


func _on_premium_toggled() -> void:
	if not _unlocking_id.is_empty():
		return
	_premium_user_set = true
	_premium_open = not _premium_open
	if not _premium_open and GameState.home_band == "paid":
		GameState.set_home_band("free")
		var active_def: SeasonDef = GameState.get_season_def(GameState.active_season_id)
		if active_def != null and active_def.is_free():
			GameState.set_free_strip_focus(active_def.id)
	_refresh_trail(true)
	if _premium_open:
		_scroll_to(_premium_header)


func _on_trail_gui_input(event: InputEvent) -> void:
	var dy := DRAG_SCROLL.drag_delta(event)
	if is_zero_approx(dy):
		return
	DRAG_SCROLL.apply(trail, dy)
	trail.accept_event()


## Visina kolone odredjuje koliko otvorena kartica raste; sirina ne mijenja nista.
func _on_trail_resized() -> void:
	if not is_node_ready() or is_equal_approx(trail.size.y, _laid_out_h):
		return
	_laid_out_h = trail.size.y
	_refresh_trail(false)


# --- unlock ---

func _on_unlock_pressed(season_id: String) -> void:
	if not _unlocking_id.is_empty():
		return
	if not GameState.unlock_free(season_id):
		_refresh_trail(false)
		return
	_unlocking_id = season_id
	_fresh_id = season_id
	_known_playable[season_id] = true
	_refresh_top_bar()
	_refresh_trail(false)
	var card := get_card(season_id)
	if card:
		card.play_unlock_burst()
	_notify_home_refresh()
	_notify_play_chip()
	if not is_inside_tree():
		_finish_unlock()
		return
	_unlock_timer = get_tree().create_timer(UiHome.T_BURST)
	_unlock_timer.timeout.connect(_finish_unlock, CONNECT_ONE_SHOT)


func _finish_unlock() -> void:
	_unlocking_id = ""
	_refresh_trail(true)
	_notify_play_chip()


func is_unlocking() -> bool:
	return not _unlocking_id.is_empty()


## Nova otkljucana ili kupljena sezona (i dolazak iz Campa) dobija cip "New".
func _detect_fresh() -> void:
	var now: Dictionary = {}
	for def in SeasonCatalog.all_defs():
		if GameState.is_season_playable(def.id):
			now[def.id] = true
	if _known_ready:
		for id: String in now:
			if not _known_playable.has(id):
				_fresh_id = id
	_known_playable = now
	_known_ready = true


func _on_fresh_done(season_id: String) -> void:
	if season_id != _fresh_id:
		return
	_fresh_id = ""
	_refresh_trail(false)


# --- premium kupovina ---

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
	_refresh_trail(false)


func _on_purchase_done(_sku: String) -> void:
	if _buying_id.is_empty():
		return
	var id := _buying_id
	_buying_id = ""
	if GameState.is_season_playable(id):
		GameState.set_paid_strip_focus(id)
		GameState.set_home_band("paid")
	_refresh_top_bar()
	refresh()


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if _buying_id.is_empty():
		return
	_buying_id = ""
	_refresh_trail(false)


# --- polje sezone ---

func _focus_season(season_id: String) -> bool:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null or not GameState.is_season_playable(season_id):
		return false
	if def.is_paid():
		GameState.set_paid_strip_focus(season_id)
		GameState.set_home_band("paid")
	else:
		GameState.set_free_strip_focus(season_id)
		GameState.set_home_band("free")
	return true


func _sync_season_field() -> void:
	var open := GameState.home_season_field_open
	trail.visible = not open
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


# --- obavjestenja roditeljima ---

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


## Unlock mijenja i ProgressIndicator (2 / 4 → 3 / 4) u TopRow-u.
func _notify_home_refresh() -> void:
	if owner and owner.has_method("refresh_progress_indicator"):
		owner.call("refresh_progress_indicator")


func _refresh_top_bar() -> void:
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")
