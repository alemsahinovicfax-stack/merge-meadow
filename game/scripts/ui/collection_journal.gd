extends Control

## Journal / Bloom Album — smjer 1a (design_handoff_journal).
## PageHead 175 + lista. NEW ostaje vidljiv cijelu posjetu iako se tab badge
## briše na otvaranje. Sezonska poglavlja i auto-scroll na prvi NEW.
## Redoslijed (2026-10-06): aktivna sezona, pa djelimično otključane, pa potpune, pa bez
## ijednog cvijeta (UiJournal.order_seasons). Lista se puni po 3 sezone: prve tri, a kad igrač
## skrola do kraja učitanog, sljedeće tri — i tako dok ne ponestane sezona.
## FIX-TEL 2026-11 (štekanje pri svakom ulasku na telefonu):
##  · redovi se grade i dok stranica NIJE na ekranu (prewarm iz huba, tik na process_frame —
##    process_mode stranice je tada DISABLED), pa ulazak zatekne gotovu listu;
##  · izlazak više ne skraćuje listu, a novi napredak (kept 3 → 4, nova sezona na vrhu) ne ruši
##    sezone: grupa se prepozna po sezoni i samo premjesti / osvježi; gradi se samo ono što fali.

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")

const SEASONS_PER_CHUNK := 3
## Rad po frejmu (µs): učitavanje tekstura + gradnja redova; uvijek bar jedan red.
## 3 ms (perf 2026-10-09; bilo 6): novi redovi se još i raspoređuju i prvi put crtaju u istom
## frejmu, pa je 6 ms budžeta uz to prelazilo 16,7 ms dok igrač skrola.
const FRAME_BUDGET_USEC := 3000
## Gradnja u pozadini (igrač je na drugoj stranici): jedan red svaki N-ti frejm, da stranica
## koju gleda (Arena, Home) ne plati Journal.
const BACKGROUND_EVERY_N_FRAMES := 3
## Dok igrač gleda Journal: najviše jedan red, svaki N-ti frejm (FIX-TEL-2 2026-11-12). Red se
## gradi, raspoređuje i prvi put crta u istom frejmu — na telefonu je više njih u nizu trzalo.
## Sezona zato odmah zauzme punu visinu, a mjesta redova drži „kostur" s natpisom Loading….
const ACTIVE_EVERY_N_FRAMES := 2
const ROW_FADE_SEC := 0.16
## Sljedeće tri sezone kreću kad je do kraja učitanog ostalo manje od ovoga (px).
const LOAD_AHEAD_PX := 400.0

@onready var root_vbox: VBoxContainer = %RootVBox
@onready var page_head: VBoxContainer = %PageHead
@onready var title_row: HBoxContainer = %TitleRow
@onready var title_accent: Panel = %TitleAccent
@onready var title_label: Label = %BloomAlbumTitle
@onready var golden_plaque: PanelContainer = %GoldenPlaque
@onready var plaque_label: Label = %PlaqueLabel
@onready var divider_gap: Control = %DividerGap
@onready var list_scroll: ScrollContainer = %ListScroll
@onready var list: VBoxContainer = %List
@onready var back_button: UiClickButton = %BackButton
@onready var golden_edge: Panel = %GoldenFrameEdge
@onready var golden_band: Panel = %GoldenFrameGold
## Prozor liste (design_handoff_settings_fixes · A): GL Compat ne reže crtanje, pa sve van
## prozora pokrivaju četiri neprozirna poklopca iznad liste, pa obrub prozora (z 3 / 4).
@onready var cap_top: ColorRect = %CapTop
@onready var cap_bottom: ColorRect = %CapBottom
@onready var cap_left: ColorRect = %CapLeft
@onready var cap_right: ColorRect = %CapRight
@onready var window_rim: Panel = %WindowRim
@onready var grabber: Panel = %Grabber

## Sezone u redoslijedu prikaza: [{sid, entries, kept, total, unlocked}].
var _order: Array[Dictionary] = []
## Sezone koje su na listi (ili u gradnji), istim redom:
## [{sid, group, gap, rows, sig, entries, count_label, count_text, dead}].
var _groups: Array[Dictionary] = []
## Redovi koji čekaju gradnju: [{g (grupa), row (indeks u g.entries)}].
var _work: Array[Dictionary] = []
var _building: bool = false
var _tick_connected: bool = false
var _bg_frame: int = 0
var _bottom: Control = null
var _top: Control = null
var _new_snapshot: Dictionary = {}
var _scroll_season: int = -1
var _scroll_row: int = -1
var _pending_scroll: bool = false
## Igrač je na stranici: tek tada skrol do kraja učitava sljedeće tri (posle izlaska
## skraćivanje liste pomjeri skrol, a to ne smije odmah vratiti obrisane sezone).
var _active: bool = false
var _golden: bool = false


func _ready() -> void:
	if not GameState.cosmetics_changed.is_connected(_on_cosmetics_changed):
		GameState.cosmetics_changed.connect(_on_cosmetics_changed)
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Bg.color = UiJournal.PAGE_BG
	back_button.clicked.connect(_on_back_pressed)
	list_scroll.get_v_scroll_bar().value_changed.connect(_on_scrolled)
	list_scroll.get_v_scroll_bar().value_changed.connect(func(_v: float) -> void: _update_grabber())
	list.resized.connect(_update_grabber)
	grabber.add_theme_stylebox_override("panel", UiJournal.grabber_style())
	_style_head()
	if GameState.is_meta_hub_embedded(self):
		_apply_frame()
		return
	_begin_visit()


## Sezone koje se još učitavaju (imaju kostur „Loading…") — testovi.
func loading_season_count() -> int:
	var n := 0
	for g in _groups:
		var skel: Variant = g.get("skel")
		if skel != null and is_instance_valid(skel):
			n += 1
	return n


## Učitane sezone i redoslijed (testovi).
func loaded_season_count() -> int:
	return _groups.size()


func total_season_count() -> int:
	return _order.size()


func is_building() -> bool:
	return _building


func season_order() -> Array[String]:
	var out: Array[String] = []
	for s in _order:
		out.append(str(s["sid"]))
	return out


func _exit_tree() -> void:
	_set_building(false)


## Gradnja ide na SceneTree.process_frame, ne u _process: stranica van ekrana ima
## process_mode DISABLED (hub), a lista se mora graditi baš tada.
func _set_building(on: bool) -> void:
	_building = on
	var tree := get_tree() if is_inside_tree() else null
	if tree == null:
		_tick_connected = false
		return
	if on and not _tick_connected:
		tree.process_frame.connect(_build_tick)
		_tick_connected = true
	elif not on and _tick_connected:
		if tree.process_frame.is_connected(_build_tick):
			tree.process_frame.disconnect(_build_tick)
		_tick_connected = false


func _build_tick() -> void:
	if not _building or list == null:
		_set_building(false)
		return
	_bg_frame += 1
	if _bg_frame % (ACTIVE_EVERY_N_FRAMES if _active else BACKGROUND_EVERY_N_FRAMES) != 0:
		return
	var built := 0
	while not _work.is_empty() and built == 0:
		var item: Dictionary = _work.pop_front()
		var g: Dictionary = item["g"]
		if bool(g.get("dead", false)):
			continue
		var entries: Array = g["entries"]
		var ri := int(item["row"])
		if ri >= entries.size():
			continue
		var entry: Dictionary = entries[ri]
		# Tekstura prije reda: crtež cvijeta se učita ovdje, u budžetu, a ne u _draw.
		var filled := UiJournal.filled_tiers(str(entry.get("state", "locked")))
		for tier in range(1, filled + 1):
			FlowerAssets.get_texture(str(entry.get("type_id", "")), tier)
		var row := JournalRow.new()
		_size_row(row)
		var group := g["group"] as Node
		group.add_child(row)
		row.apply(entry)
		(g["rows"] as Array).append(row)
		# Kostur ostaje zadnji i kraći za jedan red: visina sezone se ne mijenja.
		var skel := g.get("skel") as JournalSkeleton
		if skel != null and is_instance_valid(skel):
			var left := entries.size() - (g["rows"] as Array).size()
			if left <= 0:
				group.remove_child(skel)
				skel.queue_free()
				g["skel"] = null
			else:
				group.move_child(skel, -1)
				skel.set_left(left)
		if _active and not GameState.reduce_motion:
			row.modulate.a = 0.0
			row.create_tween().tween_property(row, "modulate:a", 1.0, ROW_FADE_SEC)
		built += 1
	if not _work.is_empty():
		return
	_set_building(false)
	if _pending_scroll:
		_pending_scroll = false
		# Skrol tek kad lista ima punu visinu, inace se zaustavi na tadasnjem maksimumu.
		call_deferred("_scroll_to_new")
	call_deferred("_maybe_load_more")


## Hub: stranica je učitana ali nije na ekranu — pripremi listu unaprijed (bez „viđeno",
## bez zvuka i skrola). Ulazak poslije toga samo osvježi redove.
func prewarm() -> void:
	if _active or not is_inside_tree():
		return
	_order = UiJournal.order_seasons(GameState.get_collection_journal_entries(), GameState.active_season_id)
	_sync_groups(maxi(mini(SEASONS_PER_CHUNK, _order.size()), mini(_groups.size(), _order.size())))


func _style_head() -> void:
	title_accent.add_theme_stylebox_override("panel", UiJournal.flat(UiJournal.COIN_GOLD, 5))
	UiStage.style(title_label, 900, UiJournal.TITLE_FONT, UiJournal.INK)
	UiStage.style(plaque_label, 900, UiJournal.PLAQUE_FONT, UiJournal.INK)
	golden_plaque.add_theme_stylebox_override("panel", UiJournal.golden_plaque_style())
	golden_plaque.custom_minimum_size.y = UiJournal.PLAQUE_H


func _begin_visit() -> void:
	_active = true
	var raw := GameState.get_collection_journal_entries()
	GameState.mark_collection_journal_viewed()
	_order = UiJournal.order_seasons(raw, GameState.active_season_id)
	_new_snapshot.clear()
	_scroll_season = -1
	_scroll_row = -1
	for si in _order.size():
		var entries: Array = _order[si]["entries"]
		for ri in entries.size():
			var entry: Dictionary = entries[ri]
			if not bool(entry.get("is_new", false)):
				continue
			_new_snapshot[str(entry.get("type_id", ""))] = int(entry.get("new_tier", 0))
			if _scroll_season < 0:
				_scroll_season = si
				_scroll_row = ri
	_apply_frame()
	# Prve tri sezone; ako je prvi NEW dalje, onoliko trojki koliko treba da se vidi.
	var want := mini(SEASONS_PER_CHUNK, _order.size())
	if _scroll_season >= 0:
		want = mini(_order.size(), (_scroll_season / SEASONS_PER_CHUNK + 1) * SEASONS_PER_CHUNK)
	# Već učitane sezone ostaju (izlazak ih više ne briše).
	want = maxi(want, mini(_groups.size(), _order.size()))
	_sync_groups(want)
	if _scroll_season >= 0:
		# Novo cvijeće u Albumu: šljokice pri ulasku (jednom po posjeti).
		Sfx.play("discover")
		_pending_scroll = _building
		if not _building:
			call_deferred("_scroll_to_new")
	else:
		list_scroll.scroll_vertical = 0
	if is_inside_tree():
		get_tree().call_group("meta_hub", "refresh_top_bar")


func refresh_for_meta_hub() -> void:
	_begin_visit()


## Odlazak: NEW se gasi na izgrađenim redovima. Lista OSTAJE (ranije se kratila na tri sezone,
## pa je svaki sljedeći ulazak opet gradio — štekanje); nedovršena gradnja ide dalje u pozadini.
func on_meta_page_left() -> void:
	_active = false
	_new_snapshot.clear()
	_scroll_season = -1
	_pending_scroll = false
	for s in _order:
		for entry in s["entries"]:
			entry["is_new"] = false
			entry["new_tier"] = 0
	for g in _groups:
		var entries: Array = g["entries"]
		var rows: Array = g["rows"]
		for i in rows.size():
			if i < entries.size():
				(rows[i] as CollectionJournalRow).apply(entries[i])


## Potpis sezone: ono što određuje KOJI su redovi i zaglavlje (bez brojača „kept" — on se
## mijenja svakim novim cvijetom i samo se prepiše u labeli, ne ruši sezonu).
func _season_signature(s: Dictionary) -> String:
	var sid := str(s["sid"])
	var parts := PackedStringArray([sid, str(s["total"]), str(GameState.is_season_playable(sid))])
	for entry in s["entries"]:
		parts.append(str(entry.get("type_id", "")))
	return "|".join(parts)


func _count_text(s: Dictionary) -> String:
	return "%d / %d kept" % [int(s.get("kept", 0)), int(s.get("total", 0))]


## Lista = prvih `want` sezona iz _order. Sezona koja je već izgrađena (isti potpis) se
## prepozna po id-u gdje god da je sada u redoslijedu: grupa se premjesti i redovi osvježe.
## Gradi se samo sezona koje nema ili kojoj se promijenio sastav.
func _sync_groups(want: int) -> void:
	if list == null:
		return
	var old: Dictionary = {}
	for g in _groups:
		old[str(g["sid"])] = g
	var next: Array[Dictionary] = []
	for i in mini(want, _order.size()):
		var s: Dictionary = _order[i]
		var sid := str(s["sid"])
		var found: Variant = old.get(sid)
		if found != null and str(found["sig"]) == _season_signature(s):
			var g: Dictionary = found
			old.erase(sid)
			g["entries"] = s["entries"]
			var text := _count_text(s)
			if str(g["count_text"]) != text and is_instance_valid(g["count_label"]):
				(g["count_label"] as Label).text = text
				g["count_text"] = text
			var rows: Array = g["rows"]
			var entries: Array = s["entries"]
			for r in mini(rows.size(), entries.size()):
				(rows[r] as CollectionJournalRow).apply(entries[r])
			next.append(g)
		else:
			next.append(_new_group(s))
	for sid in old:
		_free_group(old[sid])
	_groups = next
	_drop_dead_work()
	_place_groups()
	if _groups.is_empty():
		_clear_list()


func _new_group(s: Dictionary) -> Dictionary:
	var gap := _spacer(UiJournal.SEASON_GAP)
	list.add_child(gap)
	var group := VBoxContainer.new()
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.add_theme_constant_override("separation", UiJournal.SEASON_HEADER_GAP)
	var header := _season_header(str(s["sid"]), s)
	group.add_child(header)
	list.add_child(group)
	var skel := JournalSkeleton.new()
	group.add_child(skel)
	skel.set_left((s["entries"] as Array).size())
	var g := {
		"sid": s["sid"], "group": group, "gap": gap, "rows": [], "sig": _season_signature(s),
		"entries": s["entries"], "count_label": header.get_node_or_null("Count"),
		"count_text": _count_text(s), "dead": false, "skel": skel,
	}
	for ri in (s["entries"] as Array).size():
		_work.append({"g": g, "row": ri})
	_set_building(true)
	return g


func _free_group(g: Dictionary) -> void:
	g["dead"] = true
	for key in ["group", "gap"]:
		var n: Node = g.get(key)
		if n != null and is_instance_valid(n):
			if n.get_parent() != null:
				n.get_parent().remove_child(n)
			n.queue_free()


func _drop_dead_work() -> void:
	var kept: Array[Dictionary] = []
	for item in _work:
		if not bool((item["g"] as Dictionary).get("dead", false)):
			kept.append(item)
	_work = kept
	_set_building(not _work.is_empty())


## Čvorovi liste istim redom kao _groups: vrh, [razmak] sezona, …, dno. Razmak prve je sakriven.
func _place_groups() -> void:
	if list == null or _groups.is_empty():
		return
	if _top == null or not is_instance_valid(_top):
		_top = _spacer(UiJournal.LIST_TOP)
		list.add_child(_top)
	if _bottom == null or not is_instance_valid(_bottom):
		_bottom = _spacer(UiJournal.LIST_BOTTOM)
		list.add_child(_bottom)
	var idx := 0
	list.move_child(_top, idx)
	idx += 1
	for i in _groups.size():
		var g: Dictionary = _groups[i]
		var gap := g["gap"] as Control
		gap.visible = i > 0
		list.move_child(gap, idx)
		idx += 1
		list.move_child(g["group"] as Node, idx)
		idx += 1
	list.move_child(_bottom, list.get_child_count() - 1)


func _add_season(index: int) -> void:
	if list == null or index >= _order.size():
		return
	_groups.append(_new_group(_order[index]))
	_place_groups()


## Ostavi prvih `count` sezona; ostale (i njihov nedovršen rad) se brišu.
func _trim_groups(count: int) -> void:
	while _groups.size() > count:
		_free_group(_groups.pop_back())
	_drop_dead_work()
	if _groups.is_empty():
		_clear_list()


func _on_scrolled(_value: float) -> void:
	_maybe_load_more()


## Do kraja učitanog je ostalo malo (ili lista ne puni ekran) — učitaj sljedeće tri.
func _maybe_load_more() -> void:
	if not _active or _building or list == null or list_scroll == null or _groups.size() >= _order.size():
		return
	if not list_scroll.is_visible_in_tree():
		return
	# Visina iz minimalne veličine, ne iz `size`: raspored kontejnera kasni frejm, a stara
	# (mala) visina bi odmah učitala sve sezone.
	var bottom := float(list_scroll.scroll_vertical) + list_scroll.size.y
	if bottom < list.get_combined_minimum_size().y - LOAD_AHEAD_PX:
		return
	var want := mini(_order.size(), _groups.size() + SEASONS_PER_CHUNK)
	while _groups.size() < want:
		_add_season(_groups.size())


func _season_header(season_id: String, count: Dictionary) -> HBoxContainer:
	var header := HBoxContainer.new()
	header.name = "SeasonHeader"
	header.custom_minimum_size.y = UiJournal.SEASON_HEADER_H
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 18)
	var def := SeasonCatalog.get_def(season_id)
	var name := Label.new()
	name.text = def.display_name if def else season_id
	UiStage.style(name, 900, UiJournal.SEASON_NAME_FONT, UiJournal.INK)
	header.add_child(name)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 3)
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rule.color = Color(UiJournal.INK, 0.14)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(rule)
	if not GameState.is_season_playable(season_id):
		var lock := TextureRect.new()
		lock.custom_minimum_size = Vector2(UiJournal.SEASON_LOCK_ICON, UiJournal.SEASON_LOCK_ICON)
		lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lock.texture = UiAssets.get_chrome_icon("icon_lock_ink")
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		header.add_child(lock)
	var kept := int(count.get("kept", 0))
	var total := int(count.get("total", 0))
	var num := Label.new()
	num.name = "Count"
	num.text = "%d / %d kept" % [kept, total]
	UiStage.style(num, 800, UiJournal.SEASON_COUNT_FONT, UiJournal.SUB_INK)
	header.add_child(num)
	return header


func _spacer(h: int) -> Control:
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, h)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pad


func _scroll_to_new() -> void:
	if list_scroll == null or _scroll_season < 0:
		return
	var y := UiJournal.row_y(_scroll_season, _scroll_row) - UiJournal.AUTO_SCROLL_LEAD
	list_scroll.scroll_vertical = maxi(0, y)


func _clear_list() -> void:
	for g in _groups:
		g["dead"] = true
	_groups.clear()
	_work.clear()
	_set_building(false)
	_bottom = null
	_top = null
	if list == null:
		return
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()


func _on_cosmetics_changed(slots: Array) -> void:
	if slots.has(CosmeticCatalog.SLOT_JOURNAL_FRAME) and golden_edge != null:
		_apply_frame()


func _apply_frame() -> void:
	# Ormar: okvir dolazi iz look.frame opremljene stavke (cosmetics.json).
	var golden := not CosmeticCatalog.get_album_frame(
		GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_JOURNAL_FRAME)
	).is_empty()
	golden_edge.visible = golden
	golden_band.visible = golden
	if golden:
		golden_edge.add_theme_stylebox_override("panel", UiJournal.golden_frame_style(false, 38))
		golden_band.add_theme_stylebox_override("panel", UiJournal.golden_frame_style(true, 35))
	title_accent.visible = not golden
	title_label.visible = not golden
	golden_plaque.visible = golden
	page_head.custom_minimum_size.y = float(UiJournal.HEAD_H_GOLD if golden else UiJournal.HEAD_H)
	var top_pad := page_head.get_node_or_null("TopPad") as Control
	if top_pad:
		top_pad.custom_minimum_size.y = 40.0 if golden else 30.0
	divider_gap.custom_minimum_size.y = 14.0 if golden else 24.0
	if root_vbox:
		root_vbox.offset_left = 44.0 if golden else float(UiJournal.PAD_X)
		root_vbox.offset_right = -44.0 if golden else -float(UiJournal.PAD_X)
	window_rim.add_theme_stylebox_override("panel", UiJournal.window_rim_style(golden))
	_golden = golden
	_layout_window()


## ListScroll = rupa prozora; poklopci i obrub oko nje. Mijenja se samo pri promjeni okvira
## ili veličine stranice — skrol pomjera samo listu i grabber.
func _layout_window() -> void:
	var page_h := size.y if size.y >= 600.0 else float(UiJournal.PAGE_H)
	var win := UiJournal.list_window(_golden, page_h)
	var hole: Rect2 = win["scroll"]
	list_scroll.position = hole.position
	list_scroll.size = hole.size
	var caps: Array = win["caps"]
	var nodes: Array[ColorRect] = [cap_top, cap_bottom, cap_left, cap_right]
	for i in nodes.size():
		var r: Rect2 = caps[i]
		nodes[i].position = r.position
		nodes[i].size = r.size
	var rim: Rect2 = win["rim"]
	window_rim.position = rim.position
	window_rim.size = rim.size
	for g in _groups:
		for row in g["rows"]:
			if is_instance_valid(row):
				_size_row(row)
	_update_grabber()


func _size_row(row: Node) -> void:
	row.set("row_width", list_scroll.size.x - 2.0 * UiJournal.WIN_LIST_PAD_X)
	if _golden:
		row.call("set_slot_size", float(UiJournal.SLOT_COMPACT), float(UiJournal.ART_COMPACT))
	else:
		row.call("set_slot_size", float(UiJournal.SLOT), float(UiJournal.ART))


## Grabber 8 px, 6 px od desne ivice prozora, visina = udio vidljivog dijela; samo position.y.
func _update_grabber() -> void:
	if grabber == null or list_scroll == null:
		return
	var hole := Rect2(list_scroll.position, list_scroll.size)
	var content := maxf(1.0, list.get_combined_minimum_size().y)
	var max_scroll := content - hole.size.y
	grabber.visible = max_scroll > 1.0
	if not grabber.visible:
		return
	var gh := maxf(64.0, roundf(hole.size.y * hole.size.y / content))
	var t := clampf(float(list_scroll.scroll_vertical) / max_scroll, 0.0, 1.0)
	grabber.size = Vector2(UiJournal.WIN_GRABBER_W, gh - 20.0)
	grabber.position = Vector2(
		hole.end.x - UiJournal.WIN_GRABBER_W - UiJournal.WIN_GRABBER_INSET,
		hole.position.y + 10.0 + roundf(t * (hole.size.y - gh))
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_layout_window()


func _on_back_pressed() -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.CAMP)
	else:
		SceneRouter.change_to(GameState.SCENE_CAMP)


func set_meta_hub_mode(enabled: bool) -> void:
	if back_button:
		back_button.visible = not enabled


## Mjesta redova koji se još grade (FIX-TEL-2): blijedi obrisi reda 200 px + tri kruga tiera,
## u prvom natpis „Loading…" s tačkicama. Drži punu visinu sezone od prve sekunde, pa se lista
## ne pomjera dok redovi stižu. Crta se samo kad se promijeni broj redova ili faza tačkica.
class JournalSkeleton extends Control:
	const DOT_SEC := 0.3
	const S_LOADING := "Loading"

	var left: int = 0
	var _phase: int = 0
	var _t: float = 0.0

	func _init() -> void:
		name = "SeasonLoading"
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_horizontal = Control.SIZE_EXPAND_FILL

	func set_left(n: int) -> void:
		left = maxi(0, n)
		custom_minimum_size.y = float(left * UiJournal.ROW_H + maxi(0, left - 1) * UiJournal.ROW_GAP)
		queue_redraw()

	func _process(delta: float) -> void:
		if GameState.reduce_motion:
			return
		_t += delta
		if _t >= DOT_SEC:
			_t = 0.0
			_phase = (_phase + 1) % 4
			queue_redraw()

	func _draw() -> void:
		var ink := UiJournal.INK
		var fill := UiStage.box(Color(ink, 0.04), 26, 3, Color(ink, 0.10))
		var ring := UiStage.box(Color(ink, 0.03), int(UiJournal.SLOT_COMPACT / 2.0), 3, Color(ink, 0.08))
		var slot := float(UiJournal.SLOT_COMPACT)
		for i in left:
			var r := Rect2(0.0, float(i * (UiJournal.ROW_H + UiJournal.ROW_GAP)), size.x, float(UiJournal.ROW_H))
			draw_style_box(fill, r)
			for k in 3:
				var x := r.end.x - 27.0 - slot - float(k) * (slot + 12.0)
				draw_style_box(ring, Rect2(x, r.position.y + (r.size.y - slot) * 0.5, slot, slot))
			if i == 0:
				var text := S_LOADING + ".".repeat(_phase if not GameState.reduce_motion else 3)
				UiHomeV3.draw_text(self, 800, 40, text, Vector2(31.0, r.position.y + (r.size.y - 40.0) * 0.5), Color(ink, 0.55))
