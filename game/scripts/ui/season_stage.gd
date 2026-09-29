extends Control

## Home v3 (design_handoff_home_v3, runda 2): biranje sezone u dva taba i prelaz
## kartica → livada. SeasonStage je cijela stranica 1080 x 1633.
##
## Biranje: tabovi Free / Premium, jedna kartica (minijatura livade), strelice,
## swipe po kartici (60 px), tacke (samo indikator) i Play u tri koraka.
## Prelaz: JEDAN tween napretka `u` 0 → 1 (560 ms), zatvaranje isti tween unazad
## (440 ms). Geometrija ide na ease_t(u) — kartica, ime, Pip i Play se krecu
## zajedno — a blijedjenja na sirovom u (§ Prelaz u README-u paketa).
## Ime, Pip i Play su po JEDAN objekat od kartice do polja; livada ne crta svoje
## trake dok je u < 1 (kartica JESTE livada), pa predaja nema sav.

signal play_run_requested

const BLOCK_HUB_SWIPE_GROUP := "block_hub_swipe"
const TAB_FREE := "free"
const TAB_PREMIUM := "premium"

@onready var page_bg: ColorRect = %PageBg
@onready var season_tabs: HomeV3Tabs = %SeasonTabs
@onready var season_card: HomeV3Card = %SeasonCard
@onready var field_clip: Control = %FieldClip
@onready var season_field: Control = %SeasonField
@onready var card_nav: Control = %CardNav
@onready var prev_arrow: HomeV3Arrow = %PrevSeason
@onready var next_arrow: HomeV3Arrow = %NextSeason
@onready var season_dots: HomeV3Marks = %SeasonDots
@onready var travel_layer: Control = %TravelLayer
@onready var card_edge: HomeV3Marks = %CardEdge
@onready var season_name: HomeV3Marks = %SeasonName
@onready var travel_pip: HomeV3Marks = %TravelPip
@onready var play_button: HomeV3PlayButton = %PlayButton
@onready var stage_toast: HomeV3Marks = %StageToast

var _tab: String = TAB_FREE
var _idx: int = 0
var _u: float = 0.0
var _moving: bool = false
var _opening: bool = false
var _swap: float = 1.0
var _dir: int = 0
var _drag_x: float = 0.0
var _pip_from: Vector2 = Vector2(UiHomeField.PIP_DEFAULT_BASE)
var _field_tween: Tween
var _swap_tween: Tween
var _snap_tween: Tween
var _toast_tween: Tween
var _buying_id: String = ""
var _known_playable: Dictionary = {}
var _known_ready: bool = false
var _chrome: Dictionary = {}
var _chrome_home: Dictionary = {}

var _seen_focus: String = ""
var _drag_on: bool = false
var _drag_moved: bool = false
var _drag_start := Vector2.ZERO
var _drag_part: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in [season_tabs, season_card, prev_arrow, next_arrow, play_button]:
		if not c.is_in_group(BLOCK_HUB_SWIPE_GROUP):
			c.add_to_group(BLOCK_HUB_SWIPE_GROUP)
	season_card.mouse_filter = Control.MOUSE_FILTER_STOP
	season_card.gui_input.connect(_on_card_gui)
	season_tabs.tab_pressed.connect(_on_tab_pressed)
	prev_arrow.left = true
	next_arrow.left = false
	prev_arrow.pressed.connect(func() -> void: _page_by(-1))
	next_arrow.pressed.connect(func() -> void: _page_by(1))
	play_button.pressed.connect(_on_play_pressed)
	IAPManager.purchase_completed.connect(_on_purchase_done)
	IAPManager.purchase_failed.connect(_on_purchase_failed)
	_view_season(_home_focus_id())
	_seen_focus = _home_focus_id()
	refresh()


## MainMenu predaje chrome polja (FieldOverlay) — prelaz ga klipuje i blijedi.
## keys: overlay (clip), inner, top (grupa gore), seasons, endless, hint.
func bind_field_chrome(nodes: Dictionary) -> void:
	_chrome = nodes
	_chrome_home.clear()
	for key in ["seasons", "endless"]:
		var c := _chrome.get(key) as Control
		if c:
			_chrome_home[key] = c.position
	_apply()


func refresh() -> void:
	_clamp_focus()
	_follow_focus()
	_detect_fresh()
	if GameState.home_season_field_open and not _moving and _u < 1.0:
		# Polje je vec otvoreno (povratak iz runa): bez prelaza, odmah livada.
		_view_season(GameState.home_season_field_id)
		_sync_field_content()
		_set_u(1.0)
		_release_pip()
	elif not GameState.home_season_field_open and not _moving and _u > 0.0:
		# Polje zatvoreno izvana (Camp, Shop): bez prelaza, odmah kartica.
		_snap_closed()
	_refresh_view()


# --- javni API (MainMenu, smoke testovi) ---

func is_field_transitioning() -> bool:
	return _moving


func is_busy() -> bool:
	return _moving or _swap < 1.0 or _drag_on or (_snap_tween != null and _snap_tween.is_running())


func is_sliding() -> bool:
	return _swap < 1.0


func transition_u() -> float:
	return _u


func viewed_id() -> String:
	var ids := tab_ids(_tab)
	return ids[clampi(_idx, 0, ids.size() - 1)] if not ids.is_empty() else ""


func focused_card_id() -> String:
	return viewed_id()


func current_tab() -> String:
	return _tab


func tab_ids(tab: String) -> Array[String]:
	var out: Array[String] = []
	var defs := SeasonCatalog.free_defs_sorted() if tab == TAB_FREE else SeasonCatalog.paid_defs()
	for def in defs:
		out.append(def.id)
	return out


func page_ids() -> Array[String]:
	return tab_ids(_tab)


func card_status(season_id: String = "") -> String:
	return str(_card_data(season_id if not season_id.is_empty() else viewed_id()).get("status", ""))


func get_card_content() -> HomeV3CardContent:
	return season_card.content if season_card else null


func get_toast_text() -> String:
	return stage_toast.text if stage_toast and stage_toast.visible else ""


## Tri koraka Playa: tudja kartica → "back"; sezona u kojoj se igra → "field";
## polje otvoreno → "run".
func play_action() -> String:
	if GameState.home_season_field_open:
		return "run"
	return "field" if viewed_id() == GameState.active_season_id else "back"


func show_season(season_id: String, animated: bool = true) -> void:
	var tab := TAB_PREMIUM if _is_paid(season_id) else TAB_FREE
	var idx := tab_ids(tab).find(season_id)
	if idx < 0:
		return
	if animated and is_inside_tree():
		_swap_to(tab, idx)
	else:
		_tab = tab
		_idx = idx
		_refresh_view()


## Isto kao tap na karticu (smoke testovi): tudja sezona → prikazi je;
## prikazana otkljucana → otvori polje.
func tap_card(season_id: String) -> void:
	if GameState.home_season_field_open or is_busy():
		return
	if season_id != viewed_id():
		show_season(season_id, false)
		return
	_activate_part(HomeV3CardContent.PART_CARD)


func press_part(part: String) -> void:
	if GameState.home_season_field_open or is_busy():
		return
	_activate_part(part)


func focus_playing_season() -> void:
	var active := GameState.active_season_id
	if active.is_empty() or active == viewed_id():
		return
	show_season(active)


func open_season_field(season_id: String = "", animated: bool = true) -> bool:
	if _moving:
		return false
	# Bez id-a: sezona u fokusu (GameState) — prati karticu kad je fokus dozvoljen.
	var id := season_id if not season_id.is_empty() else _home_focus_id()
	if id.is_empty() or not GameState.is_season_playable(id):
		return false
	if not _focus_season(id):
		return false
	if not GameState.open_home_season_field():
		return false
	_seen_focus = _home_focus_id()
	_kill_swap()
	_view_season(id)
	_swap = 1.0
	_drag_x = 0.0
	_pip_from = Vector2(UiHomeField.PIP_DEFAULT_BASE)
	_sync_field_content()
	_refresh_view()
	if not animated or not is_inside_tree():
		_set_u(1.0)
		_release_pip()
		return true
	_run_field_tween(0.0, 1.0, UiHomeV3.OPEN_SEC, true)
	return true


func close_season_field(animated: bool = true) -> void:
	if _moving:
		return
	if not GameState.home_season_field_open:
		if _u > 0.0:
			_snap_closed()
		return
	_pip_from = _hold_pip()
	_view_season(GameState.active_season_id)
	_swap = 1.0
	_dir = 0
	_drag_x = 0.0
	_refresh_view()
	if not animated or not is_inside_tree():
		_finish_close()
		return
	_run_field_tween(1.0, 0.0, UiHomeV3.CLOSE_SEC, false)


# --- stanje biranja ---

## Fokus promijenjen van Homea (Camp „Unlock", Shop): kartica ga prati.
func _follow_focus() -> void:
	var focus := _home_focus_id()
	if focus == _seen_focus:
		return
	_seen_focus = focus
	if not _moving and not GameState.home_season_field_open:
		_view_season(focus)


## Sacuvani fokus koji vise nije dozvoljen (daleka free sezona) vraca se na
## sezonu u kojoj se igra.
func _clamp_focus() -> void:
	var def: SeasonDef = GameState.get_season_def(GameState.home_hero_center_id())
	if def != null and def.is_free() and not GameState.set_free_strip_focus(def.id):
		_focus_season(GameState.active_season_id)


func _home_focus_id() -> String:
	var id := GameState.home_hero_center_id()
	if id.is_empty():
		id = GameState.active_season_id
	return id


func _view_season(season_id: String) -> void:
	var tab := TAB_PREMIUM if _is_paid(season_id) else TAB_FREE
	var idx := tab_ids(tab).find(season_id)
	if idx < 0:
		tab = TAB_FREE
		idx = maxi(0, tab_ids(TAB_FREE).find(GameState.active_season_id))
	_tab = tab
	_idx = idx


func _is_paid(season_id: String) -> bool:
	var def: SeasonDef = GameState.get_season_def(season_id)
	return def != null and def.is_paid()


## Pamti fokus u GameState kad je to dozvoljeno (daleka free sezona nije).
func _persist_focus() -> void:
	var id := viewed_id()
	var def: SeasonDef = GameState.get_season_def(id)
	if def == null:
		return
	if def.is_paid():
		if GameState.set_paid_strip_focus(id):
			GameState.set_home_band("paid")
	elif GameState.set_free_strip_focus(id):
		GameState.set_home_band("free")
	_seen_focus = _home_focus_id()


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


func _card_data(season_id: String) -> Dictionary:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return {}
	var playable := GameState.is_season_playable(season_id)
	var active := season_id == GameState.active_season_id
	var status := HomeV3CardContent.ST_LOCKED
	if def.is_free():
		if playable:
			status = HomeV3CardContent.ST_ACTIVE if active else HomeV3CardContent.ST_OPEN
		elif season_id == GameState.next_locked_free_id() and GameState.can_unlock_free(season_id):
			status = HomeV3CardContent.ST_UNLOCK
	else:
		if GameState.is_test_locked_season(season_id):
			status = HomeV3CardContent.ST_SOON
		elif playable:
			status = HomeV3CardContent.ST_ACTIVE if active else HomeV3CardContent.ST_OWNED
		else:
			status = HomeV3CardContent.ST_BUY
	var prev := GameState.previous_free_id_for(season_id) if def.is_free() else ""
	return {
		"season_id": season_id,
		"name": def.display_name,
		"status": status,
		"premium": def.is_paid(),
		"roster": _roster(def, playable),
		"coins": int(GameState.wallet_coins),
		"coins_need": def.coins_cost,
		"stars": GameState.star3_flower_count_for_unlock(season_id) if not prev.is_empty() else 0,
		"stars_need": def.t3_flowers_required,
		"prev_type": GameState.star3_type_id_for_season(prev) if not prev.is_empty() else "",
		"price": IAPManager.get_price_label(def.iap_product_id) if not def.iap_product_id.is_empty() else "",
		"buying": season_id == _buying_id,
	}


## Svih sest cvjetova sezone (runda 3). Red 1 = trojka iz runde 2: prvi ★1
## lijevo, ★3 u sredini (veliki disk, potpisni cvijet), prvi ★2 desno. Red 2 =
## ostala tri redom iz rostera. Cvijet koji fali (samo na igrivoj sezoni) = jos
## nikad ubran.
func _roster(def: SeasonDef, playable: bool) -> Array:
	var pick: Array = [{}, {}, {}]
	var slot_of := {1: 0, 3: 1, 2: 2}
	var rest: Array = []
	for entry in def.roster:
		var id := str(entry.get("id", ""))
		var row := {
			"id": id,
			"name": str(entry.get("display_name", id)),
			"missing": playable and not _has_flower(id),
		}
		var slot: int = slot_of[clampi(int(entry.get("rarity", 1)), 1, 3)]
		if (pick[slot] as Dictionary).is_empty():
			pick[slot] = row
		else:
			rest.append(row)
	# Sezona bez nekog stepena rijetkosti: prazno mjesto u prvom redu popuni
	# sljedeci cvijet, da potpisni ostane u sredini.
	for i in pick.size():
		if (pick[i] as Dictionary).is_empty() and not rest.is_empty():
			pick[i] = rest.pop_front()
	var out: Array = []
	for p in pick:
		if not (p as Dictionary).is_empty():
			out.append(p)
	out.append_array(rest)
	return out


func _has_flower(type_id: String) -> bool:
	if bool(GameState.discovered_blooms.get(type_id, false)):
		return true
	if int(GameState.collection_kept_tiers.get(type_id, 0)) > 0:
		return true
	return int(GameState.garden_crystal_stash.get(type_id, 0)) > 0


func _refresh_view() -> void:
	var id := viewed_id()
	var data := _card_data(id)
	season_card.content.configure(data)
	season_card.set_ground(UiHomeV3.ground(id))
	season_tabs.premium = _tab == TAB_PREMIUM
	var active := GameState.active_season_id
	var active_tab := TAB_PREMIUM if _is_paid(active) else TAB_FREE
	var active_idx := tab_ids(active_tab).find(active)
	var dots: Array = []
	var ids := tab_ids(_tab)
	for i in ids.size():
		var here := active_tab == _tab and i == active_idx
		var cur := i == _idx
		var fill := UiHomeV3.PEACH if here else (UiHomeV3.INK if cur else UiHomeV3.DOT_IDLE)
		dots.append({"w": UiHomeV3.DOT_W_CURRENT if cur else UiHomeV3.DOT_W, "fill": fill, "ring": here})
	season_dots.dots = dots
	season_dots.queue_redraw()
	_apply()


# --- crtanje stanja (biranje + prelaz) ---

func _set_u(u: float) -> void:
	_u = clampf(u, 0.0, 1.0)
	_apply()


func _apply() -> void:
	if season_card == null:
		return
	var u := _u
	var e := UiHomeV3.ease_t(u)
	var page := size if size.x >= 8.0 else UiHomeV3.PAGE
	var rect := UiHomeV3.card_rect_at(e, page)
	var idle := u <= 0.0
	var in_field := u >= 1.0
	var sw := UiHomeV3.ease_t(_swap)
	var ox := float(_dir) * UiHomeV3.SWAP_OFFSET * (1.0 - sw) + _drag_x if idle else 0.0
	var swap_a := 0.4 + 0.6 * sw if idle else 1.0
	var rad := lerpf(UiHomeV3.CARD_RADIUS, 0.0, e)
	var id := viewed_id()
	var ground := UiHomeV3.ground(id)

	if page_bg:
		page_bg.color = UiHomeV3.page_bg(ground)

	# Kartica = livada dok traje prelaz.
	season_card.visible = not in_field
	season_card.position = rect.position + Vector2(ox, 0.0)
	season_card.size = rect.size
	season_card.set_shape(rad, lerpf(UiHomeV3.CARD_SHADOW_Y, 0.0, e))
	season_card.modulate.a = swap_a
	season_card.layout_content()
	var content_a := 1.0 - UiHomeV3.win(u, UiHomeV3.CONTENT_OUT.x, UiHomeV3.CONTENT_OUT.y)
	season_card.content.modulate.a = content_a
	season_card.content.visible = content_a > 0.0

	card_edge.visible = not in_field
	card_edge.rect = Rect2(rect.position + Vector2(ox, 0.0), rect.size)
	card_edge.border = lerpf(UiHomeV3.CARD_BORDER, 0.0, e)
	card_edge.radius = rad
	card_edge.modulate.a = swap_a
	card_edge.queue_redraw()

	# Tabovi, strelice i tacke: alpha 1 → 0 (u .02–.30), tabovi i gore 24 px.
	var sel := UiHomeV3.win(u, UiHomeV3.SELECT_OUT.x, UiHomeV3.SELECT_OUT.y)
	season_tabs.modulate.a = 1.0 - sel
	season_tabs.position.y = UiHomeV3.TABS_RECT.position.y - UiHomeV3.SELECT_LIFT * sel
	season_tabs.visible = sel < 1.0
	card_nav.modulate.a = 1.0 - sel
	card_nav.visible = sel < 1.0
	var ids := tab_ids(_tab)
	prev_arrow.visible = _idx > 0
	next_arrow.visible = _idx < ids.size() - 1

	# Ime: JEDAN objekat, 80 px na kartici → 56 px SeasonLabel.
	var active_name := _season_name(GameState.active_season_id)
	season_name.text = _season_name(id) if idle else active_name
	season_name.top = lerpf(UiHomeV3.NAME_CARD_TOP, UiHomeV3.NAME_FIELD_TOP, e)
	season_name.px = lerpf(UiHomeV3.NAME_CARD_SIZE, UiHomeV3.NAME_FIELD_SIZE, e)
	season_name.tracking = lerpf(UiHomeV3.NAME_CARD_LS, UiHomeV3.NAME_FIELD_LS, e)
	season_name.offset_x = ox
	season_name.modulate.a = swap_a
	season_name.queue_redraw()

	# Pip: JEDAN objekat; na polju ga (u = 1) preuzima livada na istom mjestu.
	var status := str(season_card.content.data.get("status", ""))
	var held := bool(season_field.call("is_pip_held")) if season_field.has_method("is_pip_held") else false
	var show_pip := (idle and status == HomeV3CardContent.ST_ACTIVE) or (u > 0.0 and (not in_field or held))
	travel_pip.visible = show_pip
	if show_pip:
		var from := Rect2(UiHomeV3.PIP_CARD_POS + Vector2(ox, 0.0), Vector2.ONE * UiHomeV3.PIP_CARD_SIZE)
		var to := Rect2(UiHomeV3.pip_field_pos(_pip_from), Vector2.ONE * UiHomeV3.PIP_FIELD_SIZE)
		travel_pip.rect = Rect2(from.position.lerp(to.position, e), from.size.lerp(to.size, e))
		travel_pip.shadow = UiHomeV3.pip_shadow_at(e)
		travel_pip.modulate.a = swap_a
		travel_pip.queue_redraw()

	# Play: JEDAN objekat — na u = 1 je FieldPlayButton.
	play_button.set_progress(e)
	var back := idle and id != GameState.active_season_id
	var act := GameState.active_season_id
	play_button.set_mode(
		HomeV3PlayButton.MODE_BACK if back else HomeV3PlayButton.MODE_PLAY,
		UiHomeV3.ground(act), _signature_type(act)
	)
	play_button.enabled = not _moving

	# Polje: sadrzaj u FieldClip-u = rect kartice (bez duhova ivica).
	field_clip.visible = u > 0.0
	field_clip.position = rect.position
	field_clip.size = rect.size
	season_field.position = -rect.position
	season_field.size = page
	if season_field.has_method("apply_reveal"):
		season_field.call("apply_reveal", u)
	_apply_chrome(u, rect, page)


## FieldOverlay (MainMenu): isti clip kao kartica; gornja grupa i Seasons /
## Endless ulaze u .60–.92 (alpha, y −16 / x ±254, ease out).
func _apply_chrome(u: float, rect: Rect2, page: Vector2) -> void:
	if _chrome.is_empty():
		return
	var overlay := _chrome.get("overlay") as Control
	var inner := _chrome.get("inner") as Control
	if overlay:
		overlay.position = rect.position
		overlay.size = rect.size
		overlay.clip_contents = u < 1.0
	if inner:
		inner.position = -rect.position
		inner.size = page
	var c := UiHomeV3.win(u, UiHomeV3.FIELD_CHROME_IN.x, UiHomeV3.FIELD_CHROME_IN.y)
	var ce := UiHomeV3.ease_out(c)
	var top := _chrome.get("top") as Control
	if top:
		top.modulate.a = c
		top.position.y = -UiHomeV3.FIELD_CHROME_Y * (1.0 - ce)
	var hint := _chrome.get("hint") as Control
	if hint:
		hint.modulate.a = c
	for key in ["seasons", "endless"]:
		var n := _chrome.get(key) as Control
		if n == null or not _chrome_home.has(key):
			continue
		var sgn := 1.0 if key == "seasons" else -1.0
		n.modulate.a = c
		n.position = (_chrome_home[key] as Vector2) + Vector2(sgn * UiHomeV3.FIELD_SIDE_SLIDE * (1.0 - ce), 0.0)


func _season_name(season_id: String) -> String:
	var def: SeasonDef = GameState.get_season_def(season_id)
	return def.display_name if def else season_id


## Potpisni cvijet sezone (★3) — disk na „Back" dugmetu.
func _signature_type(season_id: String) -> String:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return ""
	for entry in def.roster:
		if int(entry.get("rarity", 1)) >= 3:
			return str(entry.get("id", ""))
	return ""


# --- prelaz ---

func _run_field_tween(from_u: float, to_u: float, sec: float, opening: bool) -> void:
	_kill_field_tween()
	_moving = true
	_opening = opening
	_set_u(from_u)
	_field_tween = create_tween()
	_field_tween.tween_method(_set_u, from_u, to_u, sec).set_trans(Tween.TRANS_LINEAR)
	_field_tween.finished.connect(_on_field_tween_finished, CONNECT_ONE_SHOT)
	_notify_host("on_field_transition_started", opening)


func _on_field_tween_finished() -> void:
	_field_tween = null
	_moving = false
	if _opening:
		_set_u(1.0)
		_release_pip()
		_notify_host("on_field_transition_finished", true)
	else:
		_finish_close()


func _finish_close() -> void:
	_moving = false
	GameState.close_home_season_field()
	if season_field.has_method("dismiss_flowers"):
		season_field.call("dismiss_flowers")
	_pip_from = Vector2(UiHomeField.PIP_DEFAULT_BASE)
	_set_u(0.0)
	_refresh_view()
	_notify_host("sync_field_backdrop")
	_notify_host("on_field_transition_finished", false)


func _snap_closed() -> void:
	_kill_field_tween()
	_moving = false
	_hold_pip()
	if season_field.has_method("dismiss_flowers"):
		season_field.call("dismiss_flowers")
	_pip_from = Vector2(UiHomeField.PIP_DEFAULT_BASE)
	_view_season(_home_focus_id())
	_set_u(0.0)
	_refresh_view()
	_notify_host("sync_field_backdrop")
	_notify_host("on_field_transition_finished", false)


func _kill_field_tween() -> void:
	if _field_tween:
		_field_tween.kill()
		_field_tween = null


func _sync_field_content() -> void:
	if season_field.has_method("hold_pip"):
		season_field.call("hold_pip")
	if season_field.has_method("apply_season"):
		season_field.call("apply_season", GameState.home_season_field_id)
	_notify_host("sync_field_backdrop")


## Pip s kartice predaje se livadi na kucnim stopalima; hodanje krece tek sada.
func _release_pip() -> void:
	if season_field.has_method("release_pip"):
		season_field.call("release_pip")
	_apply()


## Stopala Pipa na livadi (gdje je trenutno odsetao) i Pip livade se sakrije.
func _hold_pip() -> Vector2:
	var feet := Vector2(UiHomeField.PIP_DEFAULT_BASE)
	if season_field.has_method("pip_feet"):
		feet = season_field.call("pip_feet") as Vector2
	if season_field.has_method("hold_pip"):
		season_field.call("hold_pip")
	return feet


# --- promjena kartice (strelice, swipe, tab, Back) ---

func _page_by(delta: int) -> void:
	if is_busy() or _u > 0.0:
		return
	var j := _idx + delta
	if j < 0 or j >= tab_ids(_tab).size():
		return
	_swap_to(_tab, j)


func _on_tab_pressed(tab: String) -> void:
	if is_busy() or _u > 0.0 or tab == _tab:
		return
	var active := GameState.active_season_id
	var idx := tab_ids(tab).find(active)
	_swap_to(tab, idx if idx >= 0 else 0)


func _swap_to(tab: String, idx: int, dir_override: int = -99) -> void:
	if tab == _tab and idx == _idx:
		return
	var dir := 0 if tab != _tab else signi(idx - _idx)
	if dir_override != -99:
		dir = dir_override
	_kill_swap()
	_tab = tab
	_idx = idx
	_dir = dir
	_drag_x = 0.0
	_persist_focus()
	_refresh_view()
	_notify_host("refresh_play_chip")
	if not is_inside_tree():
		_swap = 1.0
		_apply()
		return
	_swap = 0.0
	_apply()
	_swap_tween = create_tween()
	_swap_tween.tween_method(_set_swap, 0.0, 1.0, UiHomeV3.SWAP_SEC)
	_swap_tween.finished.connect(func() -> void:
		_swap_tween = null
		_swap = 1.0
		_apply()
	, CONNECT_ONE_SHOT)


func _set_swap(v: float) -> void:
	_swap = v
	_apply()


func _kill_swap() -> void:
	if _swap_tween:
		_swap_tween.kill()
		_swap_tween = null
	_swap = 1.0


# --- dodir na kartici (tap + swipe) ---

func _on_card_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		season_card.accept_event()
		_pointer(mb.position, mb.pressed)
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		season_card.accept_event()
		_pointer(st.position, st.pressed)
	elif event is InputEventScreenDrag:
		season_card.accept_event()
		_drag((event as InputEventScreenDrag).position)
	elif event is InputEventMouseMotion and _drag_on:
		season_card.accept_event()
		_drag((event as InputEventMouseMotion).position)


## Pozicije su lokalne kartici (prati prst, pa se racuna od starta).
func _pointer(pos: Vector2, pressed: bool) -> void:
	var content := season_card.content
	if pressed:
		if _drag_on or _moving or _u > 0.0 or _swap < 1.0 or GameState.home_season_field_open:
			return
		if _snap_tween and _snap_tween.is_running():
			return
		_drag_on = true
		_drag_moved = false
		_drag_start = pos + season_card.position
		_drag_part = content.hit_part(pos - content.position)
		if _drag_part != HomeV3CardContent.PART_CARD:
			content.set_pressed_part(_drag_part)
		return
	if not _drag_on:
		return
	_drag_on = false
	content.set_pressed_part(HomeV3CardContent.PART_NONE)
	if not _drag_moved:
		var part := content.hit_part(pos - content.position)
		if part == _drag_part and not part.is_empty():
			_activate_part(part)
		return
	var dx := _drag_x
	if dx <= -UiHomeV3.SWIPE_MIN and _idx < tab_ids(_tab).size() - 1:
		_swap_to(_tab, _idx + 1, 1)
		return
	if dx >= UiHomeV3.SWIPE_MIN and _idx > 0:
		_swap_to(_tab, _idx - 1, -1)
		return
	_snap_back()


func _drag(pos: Vector2) -> void:
	if not _drag_on:
		return
	var page_pos := pos + season_card.position
	var dx := page_pos.x - _drag_start.x
	if not _drag_moved:
		if absf(dx) < UiHomeV3.TAP_SLOP and absf(page_pos.y - _drag_start.y) < UiHomeV3.TAP_SLOP:
			return
		_drag_moved = true
		season_card.content.set_pressed_part(HomeV3CardContent.PART_NONE)
	var at_edge := (dx > 0.0 and _idx == 0) or (dx < 0.0 and _idx == tab_ids(_tab).size() - 1)
	if at_edge:
		_drag_x = signf(dx) * minf(absf(dx) * UiHomeV3.RUBBER_FACTOR, UiHomeV3.RUBBER)
	else:
		_drag_x = dx
	_apply()


func _snap_back() -> void:
	if absf(_drag_x) < 0.5 or not is_inside_tree():
		_drag_x = 0.0
		_apply()
		return
	var from := _drag_x
	if _snap_tween:
		_snap_tween.kill()
	_snap_tween = create_tween()
	_snap_tween.tween_method(func(k: float) -> void:
		_drag_x = from * (1.0 - UiHomeV3.ease_t(k))
		_apply()
	, 0.0, 1.0, UiHomeV3.SNAP_SEC)


func _activate_part(part: String) -> void:
	var id := viewed_id()
	match part:
		HomeV3CardContent.PART_GATE:
			open_season_field(id)
		HomeV3CardContent.PART_UNLOCK:
			_unlock(id)
		HomeV3CardContent.PART_BUY:
			_buy(id)
		HomeV3CardContent.PART_CARD:
			if GameState.is_season_playable(id):
				open_season_field(id)


func _on_play_pressed() -> void:
	if _moving or _swap < 1.0:
		return
	match play_action():
		"run":
			if _u >= 1.0:
				play_run_requested.emit()
		"field":
			open_season_field(GameState.active_season_id)
		_:
			focus_playing_season()


# --- akcije ---

func _unlock(season_id: String) -> void:
	if not GameState.unlock_free(season_id):
		_refresh_view()
		return
	_known_playable[season_id] = true
	_refresh_top_bar()
	_refresh_view()
	# Veo se dize disk po disk — jedini trenutak kad se cvijece sezone pokaze.
	if season_card and season_card.content and str(viewed_id()) == season_id:
		season_card.content.play_reveal()
	_notify_host("refresh_play_chip")
	_show_toast("Unlocked")


func _buy(season_id: String) -> void:
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null or GameState.is_test_locked_season(season_id):
		return
	if GameState.is_season_playable(season_id):
		open_season_field(season_id)
		return
	if def.iap_product_id.is_empty() or IAPManager.is_busy():
		return
	_buying_id = season_id
	_refresh_view()
	IAPManager.purchase(def.iap_product_id)


func _on_purchase_done(_sku: String) -> void:
	if _buying_id.is_empty():
		return
	var id := _buying_id
	_buying_id = ""
	if GameState.is_season_playable(id):
		_known_playable[id] = true
		_view_season(id)
		_show_toast("Yours")
	_refresh_top_bar()
	_refresh_view()


func _on_purchase_failed(_sku: String, _reason: String) -> void:
	if _buying_id.is_empty():
		return
	_buying_id = ""
	_refresh_view()


## Sezona koja je postala igriva van Homea (Camp, Shop): kartica na nju + toast.
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
	if fresh.is_empty() or GameState.home_season_field_open:
		return
	_view_season(fresh)
	_show_toast("Unlocked" if not _is_paid(fresh) else "Yours")


# --- toast ---

func _show_toast(text: String) -> void:
	if stage_toast == null:
		return
	stage_toast.text = text
	stage_toast.visible = true
	stage_toast.modulate.a = 1.0
	stage_toast.queue_redraw()
	if _toast_tween:
		_toast_tween.kill()
	if not is_inside_tree():
		return
	_toast_tween = create_tween()
	_toast_tween.tween_interval(UiHomeV3.TOAST_SEC)
	_toast_tween.tween_callback(func() -> void:
		stage_toast.visible = false
	)


# --- nazad (Android back / Esc) ---

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
	if not GameState.home_season_field_open or _moving:
		return false
	if not is_visible_in_tree() or not _is_hub_on_home():
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
	if back and _try_close_field_on_back():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_try_close_field_on_back()
	elif what == NOTIFICATION_RESIZED:
		_apply()


func _notify_host(method: String, arg: Variant = null) -> void:
	var n: Node = get_parent()
	while n:
		if n.has_method(method):
			if arg == null:
				n.call(method)
			else:
				n.call(method, arg)
			return
		n = n.get_parent()


func _refresh_top_bar() -> void:
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")
