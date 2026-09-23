class_name HomeSeasonCard
extends Panel

## Jedna sezonska kartica na Home (design_handoff_home_v2 · SeasonCard).
## Stage bira sezonu; kartica samo crta fokusirano stanje i javlja tap / swipe / dugmad.

signal tapped(season_id: String)
signal swiped(direction: int)
signal open_field_pressed(season_id: String)
signal unlock_pressed(season_id: String)
signal cta_pressed(season_id: String)
signal page_pressed(direction: int)

const TAP_SLOP := 16.0
const PAGE_DIST := 72.0
const PILL := {1: Color("#A8E6CF"), 2: Color("#B8E0F5"), 3: Color("#FFD56B")}

var season_id: String = ""
var variant: String = UiHome.EXPANDED
var state: String = UiHome.ST_UNLOCKED
var _data: Dictionary = {}
var _unlock_on: bool = false
var _buy_on: bool = false
var _dragging: bool = false
var _press_at: Vector2 = Vector2.ZERO
var _drag: Vector2 = Vector2.ZERO
var _rubber: Tween
var _fill_tween: Tween
var _burst_played: bool = false

var _body: VBoxContainer
var _art: Panel
var _badge: PanelContainer
var _badge_label: Label
var _lock: Panel
var _lock_icon: TextureRect
var _burst: HomeUnlockBurst
var _prev: Control
var _next: Control
var _meta: Label
var _count: Label
var _name: Label
var _tagline: Label
var _roster: GridContainer
var _open: PanelContainer
var _poster: VBoxContainer
var _coin_num: Label
var _flower_num: Label
var _coin_fill: ColorRect
var _flower_fill: ColorRect
var _gate_name: Label
var _unlock: PanelContainer
var _unlock_title: Label
var _unlock_sub: Label
var _premium: HBoxContainer
var _price_label: Label
var _buy: PanelContainer
var _buy_title: Label
var _buy_sub: Label
var _info: PanelContainer
var _info_title: Label
var _info_sub: Label


func _init() -> void:
	name = "SeasonCard"
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	_build()


func _ready() -> void:
	if not is_in_group("block_hub_swipe"):
		add_to_group("block_hub_swipe")
	resized.connect(_fit_body)
	_art.resized.connect(_layout_art)
	_fit_body()


func configure(data: Dictionary) -> void:
	_data = data
	season_id = str(data.get("season_id", ""))
	state = str(data.get("state", UiHome.ST_UNLOCKED))
	variant = _variant_for(state)
	if state != UiHome.ST_UNLOCKING:
		_burst_played = false
	if is_node_ready():
		_apply()


func rubber(direction: int) -> void:
	if _rubber:
		_rubber.kill()
	if not is_inside_tree():
		position.x = 0.0
		return
	_rubber = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_rubber.tween_property(self, "position:x", -float(direction) * UiHome.RUBBER_PX, 0.12)
	_rubber.tween_property(self, "position:x", 0.0, 0.16)


func is_gesturing() -> bool:
	return _dragging or (_rubber != null and _rubber.is_valid() and _rubber.is_running())


func play_unlock_burst() -> void:
	_start_unlock_motion()


func is_active() -> bool:
	return state == UiHome.ST_ACTIVE or bool(_data.get("active", false))


func has_roster() -> bool:
	return _roster.visible


func roster_count() -> int:
	var n := 0
	for child in _roster.get_children():
		if child is Control and (child as Control).visible:
			n += 1
	return n


func has_open_button() -> bool:
	return _open.visible


func has_playing_badge() -> bool:
	return _badge.visible and _badge_label.text.find("PLAYING") >= 0


func get_badge_text() -> String:
	return _badge_label.text if _badge.visible else ""


func has_lock() -> bool:
	return _lock.visible


func get_unlock_title() -> String:
	return _unlock_title.text if _unlock.visible else ""


func get_unlock_sub() -> String:
	return _unlock_sub.text if _unlock.visible else ""


func is_unlock_enabled() -> bool:
	return _unlock.visible and _unlock_on


func get_cta_title() -> String:
	if _buy.is_visible_in_tree():
		return _buy_title.text
	if _info.is_visible_in_tree():
		return _info_title.text
	return ""


func is_cta_enabled() -> bool:
	return _buy.is_visible_in_tree() and _buy_on


func get_price_text() -> String:
	return _price_label.text if _premium.visible else ""


func get_fill_color() -> Color:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	return style.bg_color if style else Color.WHITE


func get_border_width() -> int:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	return style.border_width_left if style else 0


func _variant_for(st: String) -> String:
	if st in [UiHome.ST_NEXT, UiHome.ST_READY, UiHome.ST_UNLOCKING, UiHome.ST_LOCKED]:
		return UiHome.POSTER
	if st in [UiHome.ST_PREMIUM, UiHome.ST_BUSY, UiHome.ST_SOON]:
		return UiHome.PREMIUM
	return UiHome.EXPANDED


func _apply() -> void:
	var mood := SeasonCardContrast.mood_color(season_id)
	var sc_state := _color_state(state)
	var fill := SeasonColors.card_fill(mood, sc_state)
	var active := state == UiHome.ST_ACTIVE
	var style_name := "season_card_active" if active else "season_card_preview"
	var style := HomeSeasonStyles.get_style(style_name)
	style.bg_color = fill
	add_theme_stylebox_override("panel", style)
	var ink := SeasonColors.ink(fill)
	var sub := SeasonColors.sub_ink(fill)
	var art_style := HomeSeasonStyles.get_style("season_art_slot")
	art_style.bg_color = SeasonColors.art_slot(fill)
	_art.add_theme_stylebox_override("panel", art_style)

	_apply_badge(ink)
	_apply_title(ink, sub)
	_apply_roster(mood)
	_apply_actions(mood, ink)
	_layout_art()
	_fit_body()
	if state == UiHome.ST_UNLOCKING:
		_start_unlock_motion()
	else:
		_burst.visible = false
		_lock.scale = Vector2.ONE
		if _fill_tween:
			_fill_tween.kill()
			_fill_tween = null


func _color_state(st: String) -> SeasonColors.State:
	match st:
		UiHome.ST_ACTIVE, UiHome.ST_UNLOCKED:
			return SeasonColors.State.ACTIVE
		UiHome.ST_READY:
			return SeasonColors.State.READY
		UiHome.ST_UNLOCKING:
			return SeasonColors.State.UNLOCKING
		UiHome.ST_LOCKED:
			return SeasonColors.State.FAR
		UiHome.ST_PREMIUM:
			return SeasonColors.State.PREMIUM
		UiHome.ST_BUSY:
			return SeasonColors.State.PURCHASING
		UiHome.ST_SOON:
			return SeasonColors.State.SOON
		_:
			return SeasonColors.State.GATHER


func _apply_badge(_ink: Color) -> void:
	var text := "▶  PLAYING"
	var style_name := "badge_playing"
	var color := UiHome.INK
	match state:
		UiHome.ST_NEXT, UiHome.ST_READY, UiHome.ST_UNLOCKING, UiHome.ST_LOCKED:
			text = "PREVIEW · LOCKED"
			style_name = "badge_preview"
			color = Color("#FFF8F0")
		UiHome.ST_PREMIUM, UiHome.ST_BUSY:
			text = "PREVIEW · PREMIUM"
			style_name = "badge_premium"
			color = Color("#D4A5FF")
		UiHome.ST_SOON:
			text = "COMING SOON"
			style_name = "badge_preview"
			color = Color("#FFF8F0")
		UiHome.ST_UNLOCKED:
			text = "PREVIEW"
			style_name = "badge_preview"
			color = Color("#FFF8F0")
	var badge_style := HomeSeasonStyles.get_style(style_name)
	badge_style.content_margin_left = 26
	badge_style.content_margin_right = 26
	_badge.add_theme_stylebox_override("panel", badge_style)
	_badge_label.text = text
	UiHome.style(_badge_label, 38, color, UiHome.W_BLACK)
	_badge.visible = true


func _apply_title(ink: Color, sub: Color) -> void:
	var def_free := str(_data.get("kind", "free")) == "free"
	if def_free:
		_meta.text = "FREE · %d OF %d" % [int(_data.get("free_index", 1)), int(_data.get("free_count", 4))]
	else:
		_meta.text = "PREMIUM PACK"
	var total := (_data.get("roster", []) as Array).size()
	var shown := roster_count()
	if shown <= 0:
		shown = 3 if total > 3 and not _six() else total
	_count.text = "%d flowers" % total if _six() or shown >= total else "%d flowers · %d shown" % [total, shown]
	UiHome.style(_meta, 38, sub, UiHome.W_BLACK)
	UiHome.style(_count, 38, sub, UiHome.W_BLACK)
	_name.text = str(_data.get("name", season_id))
	UiHome.style(_name, 80, ink, UiHome.W_BLACK)
	_tagline.text = str(_data.get("tagline", ""))
	UiHome.style(_tagline, 38, sub, UiHome.W_REGULAR)


func _six() -> bool:
	return state in [UiHome.ST_PREMIUM, UiHome.ST_BUSY, UiHome.ST_SOON]


func _apply_roster(mood: Color) -> void:
	var roster: Array = _data.get("roster", [])
	var idxs: Array[int] = []
	if _six():
		for i in roster.size():
			idxs.append(i)
	elif roster.size() >= 6:
		idxs = [0, 3, 5]
	else:
		for i in roster.size():
			idxs.append(i)
	for child in _roster.get_children():
		_roster.remove_child(child)
		child.free()
	var tile_h := 214.0 if _six() else 236.0
	var well := 100.0 if _six() else 118.0
	for i in idxs:
		if i < 0 or i >= roster.size():
			continue
		var entry: Dictionary = roster[i]
		_roster.add_child(_make_tile(entry, mood, tile_h, well, state == UiHome.ST_SOON))
	_roster.visible = not idxs.is_empty()
	_count.text = (
		"%d flowers" % roster.size()
		if _six() or idxs.size() >= roster.size()
		else "%d flowers · %d shown" % [roster.size(), idxs.size()]
	)


func _make_tile(entry: Dictionary, mood: Color, tile_h: float, well: float, soon: bool) -> Control:
	var tile := Panel.new()
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.custom_minimum_size = Vector2(0, tile_h)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := HomeSeasonStyles.get_style("roster_tile")
	tile.add_theme_stylebox_override("panel", box)
	if soon:
		tile.modulate.a = 0.8
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_END
	col.add_theme_constant_override("separation", 8)
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 14
	col.offset_top = 8
	col.offset_right = -14
	col.offset_bottom = -12
	tile.add_child(col)
	var art := RosterFlower.new()
	art.custom_minimum_size = Vector2(well, well)
	art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	art.setup(str(entry.get("id", "")), mood, soon)
	col.add_child(art)
	var name := Label.new()
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name.text = str(entry.get("name", ""))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.custom_minimum_size.y = 80
	UiHome.style(name, 38, UiHome.INK, UiHome.W_BOLD)
	col.add_child(name)
	var rarity := int(entry.get("rarity", 1))
	var pill := PanelContainer.new()
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.position = Vector2(0, 10)
	var pill_box := StyleBoxFlat.new()
	pill_box.bg_color = PILL.get(rarity, PILL[1])
	pill_box.set_corner_radius_all(16)
	pill_box.content_margin_left = 12
	pill_box.content_margin_right = 12
	pill.add_theme_stylebox_override("panel", pill_box)
	var pill_label := Label.new()
	pill_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill_label.text = "★%d" % rarity
	UiHome.style(pill_label, 40, UiHome.INK, UiHome.W_BLACK)
	pill.add_child(pill_label)
	tile.add_child(pill)
	tile.resized.connect(func() -> void:
		pill.position = Vector2(tile.size.x - pill.size.x - 10.0, 10.0)
	)
	return tile


func _apply_actions(mood: Color, _ink: Color) -> void:
	var playable := state == UiHome.ST_ACTIVE or state == UiHome.ST_UNLOCKED
	_open.visible = playable
	if _open.visible:
		var open_style := HomeSeasonStyles.get_style("open_meadow_button")
		open_style.content_margin_left = 36
		open_style.content_margin_right = 36
		_open.add_theme_stylebox_override("panel", open_style)
	var gate := state in [UiHome.ST_NEXT, UiHome.ST_READY, UiHome.ST_UNLOCKING, UiHome.ST_LOCKED]
	_poster.visible = gate
	if gate:
		_apply_poster()
	var premium := state == UiHome.ST_PREMIUM or state == UiHome.ST_BUSY
	_premium.visible = premium
	if premium:
		_apply_premium()
	else:
		_buy_on = false
	_info.visible = state == UiHome.ST_SOON
	if _info.visible:
		_info.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style("unlock_button_disabled"))
		_info_title.text = "Coming soon"
		_info_sub.text = "no price yet · preview the flowers"
		UiHome.style(_info_title, 46, UiHome.INK, UiHome.W_BLACK)
		UiHome.style(_info_sub, 38, Color("#3D3D33"), UiHome.W_BOLD)
	_lock.visible = state in [UiHome.ST_NEXT, UiHome.ST_READY, UiHome.ST_LOCKED]
	_set_lock_icon(state == UiHome.ST_UNLOCKING)
	var prev_on := bool(_data.get("prev_on", false))
	var next_on := bool(_data.get("next_on", false))
	_prev.modulate.a = 1.0 if prev_on else 0.3
	_next.modulate.a = 1.0 if next_on else 0.3
	_prev.visible = true
	_next.visible = true


func _apply_poster() -> void:
	var coins := int(_data.get("coins", 0))
	var coins_need := maxi(int(_data.get("coins_need", 1)), 1)
	var flowers := int(_data.get("flowers", 0))
	var flowers_need := maxi(int(_data.get("flowers_need", 1)), 1)
	var coin_ok := coins >= coins_need
	var flower_ok := flowers >= flowers_need
	_coin_num.text = "%d / %d" % [mini(coins, coins_need), coins_need]
	_flower_num.text = "%d / %d" % [mini(flowers, flowers_need), flowers_need]
	UiHome.style(_coin_num, 46, Color("#FFD56B") if coin_ok else Color("#FFF8F0"), UiHome.W_BLACK)
	UiHome.style(_flower_num, 46, Color("#FFD56B") if flower_ok else Color("#FFF8F0"), UiHome.W_BLACK)
	_gate_name.text = "%s ★3" % str(_data.get("gate_name", "Flower"))
	UiHome.style(_gate_name, 38, Color("#FFF8F0"), UiHome.W_BOLD)
	if state != UiHome.ST_UNLOCKING:
		_coin_fill.anchor_right = clampf(float(coins) / float(coins_need), 0.0, 1.0)
		_flower_fill.anchor_right = clampf(float(flowers) / float(flowers_need), 0.0, 1.0)
	var display := str(_data.get("name", season_id))
	var prev := str(_data.get("prev_name", "Country Bloom"))
	var gate := str(_data.get("gate_name", "flowers"))
	_unlock_on = state == UiHome.ST_READY
	var title := "Unlock %s" % display
	var sub := "spends %d coins + %d %s" % [coins_need, flowers_need, gate]
	var style_name := "unlock_button_ready"
	if state == UiHome.ST_NEXT or state == UiHome.ST_LOCKED:
		var parts: PackedStringArray = PackedStringArray()
		if not coin_ok:
			parts.append("%d coins" % (coins_need - coins))
		if not flower_ok:
			parts.append("%d flowers" % (flowers_need - flowers))
		if parts.is_empty():
			parts.append("a moment")
		title = "Needs " + " + ".join(parts)
		sub = "run in %s to collect" % prev if state == UiHome.ST_NEXT else "free seasons open in order"
		if state == UiHome.ST_LOCKED:
			title = "Unlock %s first" % prev
		style_name = "unlock_button_disabled"
	elif state == UiHome.ST_UNLOCKING:
		title = "Unlocking…"
		sub = "coins and flowers spent"
		style_name = "unlock_button_ready"
	_unlock.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style(style_name))
	_unlock_title.text = title
	_unlock_sub.text = sub
	UiHome.style(_unlock_title, 46, UiHome.INK, UiHome.W_BLACK)
	UiHome.style(_unlock_sub, 38, UiHome.INK, UiHome.W_BOLD)


func _apply_premium() -> void:
	var price := str(_data.get("price", ""))
	_price_label.text = price
	UiHome.style(_price_label, 56, Color("#1A1A14"), UiHome.W_BLACK)
	var buying := state == UiHome.ST_BUSY
	_buy_on = not buying
	_buy.add_theme_stylebox_override(
		"panel",
		HomeSeasonStyles.get_style("unlock_button_disabled" if buying else "buy_button")
	)
	_buy_title.text = "Waiting for store…" if buying else "Get %s" % str(_data.get("name", season_id))
	_buy_sub.text = "you can keep playing" if buying else "yours to keep"
	UiHome.style(_buy_title, 46, UiHome.INK, UiHome.W_BLACK)
	UiHome.style(_buy_sub, 38, UiHome.INK, UiHome.W_BOLD)


func _set_lock_icon(coin: bool) -> void:
	_lock.visible = _lock.visible or coin
	if coin:
		_lock.visible = true
	var circle := _lock.get_theme_stylebox("panel") as StyleBoxFlat
	if circle == null:
		circle = StyleBoxFlat.new()
		circle.set_corner_radius_all(75)
		circle.set_border_width_all(4)
		circle.border_color = UiHome.INK
	circle.bg_color = Color("#FFD56B") if coin else Color("#FFF8F0")
	_lock.add_theme_stylebox_override("panel", circle)
	_lock_icon.texture = UiAssets.get_chrome_icon("icon_coin" if coin else "icon_lock")


func _start_unlock_motion() -> void:
	if _burst_played:
		return
	_burst_played = true
	_set_lock_icon(true)
	_lock.scale = Vector2(0.2, 0.2)
	_lock.pivot_offset = _lock.size * 0.5
	var mood := SeasonCardContrast.mood_color(season_id)
	var from := SeasonColors.card_fill(mood, SeasonColors.State.GATHER)
	_set_fill(from)
	_coin_fill.anchor_right = 1.0
	_flower_fill.anchor_right = 1.0
	if not is_inside_tree():
		return
	_burst.play()
	_layout_art()
	if _fill_tween:
		_fill_tween.kill()
	_fill_tween = create_tween().set_parallel(true)
	_fill_tween.tween_method(_set_fill, from, mood, UiHome.T_UNLOCK).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_fill_tween.tween_method(_set_bars, 1.0, 0.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_fill_tween.tween_property(_lock, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _set_fill(color: Color) -> void:
	var style := get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.bg_color = color
	var art := _art.get_theme_stylebox("panel") as StyleBoxFlat
	if art:
		art.bg_color = SeasonColors.art_slot(color)
	queue_redraw()
	_art.queue_redraw()


func _set_bars(ratio: float) -> void:
	var r := clampf(ratio, 0.0, 1.0)
	_coin_fill.anchor_right = r
	_flower_fill.anchor_right = r


func _fit_body() -> void:
	var style := get_theme_stylebox("panel")
	if style == null or _body == null:
		return
	var origin := style.get_offset()
	var right := style.get_margin(SIDE_RIGHT)
	var bottom := style.get_margin(SIDE_BOTTOM)
	_body.position = origin
	_body.size = size - origin - Vector2(right, bottom)


func _layout_art() -> void:
	var s := _art.size
	if s.x < 8.0 or s.y < 8.0:
		return
	_badge.position = Vector2(22, 22)
	_lock.position = (s - _lock.size) * 0.5
	_lock.pivot_offset = _lock.size * 0.5
	_burst.size = Vector2(UiHome.BURST_DIAMETER, UiHome.BURST_DIAMETER)
	_burst.position = (s - _burst.size) * 0.5
	var face := 96.0
	var inset := (132.0 - face) * 0.5
	_prev.position = Vector2(20.0 - inset, s.y - 16.0 - face - inset)
	_next.position = Vector2(s.x - 20.0 - face - inset, s.y - 16.0 - face - inset)


func _build() -> void:
	_body = VBoxContainer.new()
	_body.name = "CardBody"
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_theme_constant_override("separation", 22)
	add_child(_body)
	_art = Panel.new()
	_art.name = "SeasonArt"
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_art.custom_minimum_size.y = 80
	_body.add_child(_art)
	_badge = PanelContainer.new()
	_badge.name = "ActiveBadge"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.custom_minimum_size.y = 72
	_art.add_child(_badge)
	_badge_label = Label.new()
	_badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.add_child(_badge_label)
	_lock = Panel.new()
	_lock.name = "LockIcon"
	_lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock.custom_minimum_size = Vector2(150, 150)
	_lock.size = Vector2(150, 150)
	_art.add_child(_lock)
	_lock_icon = TextureRect.new()
	_lock_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lock_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lock_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lock_icon.offset_left = 35
	_lock_icon.offset_top = 35
	_lock_icon.offset_right = -35
	_lock_icon.offset_bottom = -35
	_lock.add_child(_lock_icon)
	_burst = HomeUnlockBurst.new()
	_burst.name = "UnlockBurst"
	_art.add_child(_burst)
	_prev = _pager("PagerPrev", -1)
	_next = _pager("PagerNext", 1)
	_art.add_child(_prev)
	_art.add_child(_next)

	var title := VBoxContainer.new()
	title.name = "SeasonTitle"
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.custom_minimum_size.y = 170
	title.alignment = BoxContainer.ALIGNMENT_CENTER
	title.add_theme_constant_override("separation", 8)
	_body.add_child(title)
	var meta_row := HBoxContainer.new()
	meta_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_child(meta_row)
	_meta = _label("Meta")
	_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta_row.add_child(_meta)
	_count = _label("RosterCount")
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	meta_row.add_child(_count)
	_name = _label("SeasonName")
	UiHome.ellipsis(_name)
	title.add_child(_name)
	_tagline = _label("Tagline")
	_tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_child(_tagline)

	_roster = GridContainer.new()
	_roster.name = "SeasonRoster"
	_roster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_roster.columns = 3
	_roster.add_theme_constant_override("h_separation", 18)
	_roster.add_theme_constant_override("v_separation", 14)
	_body.add_child(_roster)

	_open = _panel("OpenMeadow", 130)
	_body.add_child(_open)
	var open_row := HBoxContainer.new()
	open_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	open_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_open.add_child(open_row)
	var open_title := _label("Title")
	open_title.text = "Open meadow"
	open_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UiHome.style(open_title, 46, UiHome.INK, UiHome.W_BLACK)
	open_row.add_child(open_title)
	var open_sub := _label("Sub")
	open_sub.text = "field · upgrades ↗"
	open_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	UiHome.style(open_sub, 38, Color("#555C5E"), UiHome.W_BOLD)
	open_row.add_child(open_sub)
	_open.gui_input.connect(_on_open_input)

	_poster = VBoxContainer.new()
	_poster.name = "UnlockPoster"
	_poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_poster.add_theme_constant_override("separation", 12)
	_body.add_child(_poster)
	var coin_row := _progress_row("CoinProgress", "icon_coin")
	_poster.add_child(coin_row)
	_coin_num = coin_row.get_node("Row/Value") as Label
	_coin_fill = coin_row.get_node("Track/Fill") as ColorRect
	var flower_row := _progress_row("FlowerProgress", "")
	_poster.add_child(flower_row)
	_flower_num = flower_row.get_node("Row/Value") as Label
	_flower_fill = flower_row.get_node("Track/Fill") as ColorRect
	_gate_name = flower_row.get_node("Row/Caption") as Label
	_unlock = _panel("UnlockButton", 140)
	_poster.add_child(_unlock)
	var unlock_col := _stack()
	_unlock.add_child(unlock_col)
	_unlock_title = _label("Title")
	_unlock_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unlock_col.add_child(_unlock_title)
	_unlock_sub = _label("Sub")
	_unlock_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unlock_col.add_child(_unlock_sub)
	_unlock.gui_input.connect(_on_unlock_input)

	_premium = HBoxContainer.new()
	_premium.name = "PremiumActions"
	_premium.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_premium.custom_minimum_size.y = 130
	_premium.add_theme_constant_override("separation", 16)
	_body.add_child(_premium)
	var price := _panel("PriceTag", 130)
	price.custom_minimum_size = Vector2(300, 130)
	price.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	price.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style("price_tag"))
	_premium.add_child(price)
	var price_col := _stack()
	price.add_child(price_col)
	_price_label = _label("Price")
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_col.add_child(_price_label)
	var once := _label("Once")
	once.text = "one-time"
	once.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiHome.style(once, 38, Color("#5A4A1E"), UiHome.W_BOLD)
	price_col.add_child(once)
	_buy = _panel("BuyButton", 130)
	_buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_premium.add_child(_buy)
	var buy_col := _stack()
	_buy.add_child(buy_col)
	_buy_title = _label("Title")
	_buy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buy_col.add_child(_buy_title)
	_buy_sub = _label("Sub")
	_buy_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	buy_col.add_child(_buy_sub)
	_buy.gui_input.connect(_on_buy_input)

	_info = _panel("InfoBar", 130)
	_body.add_child(_info)
	var info_col := _stack()
	_info.add_child(info_col)
	_info_title = _label("Title")
	info_col.add_child(_info_title)
	_info_sub = _label("Sub")
	info_col.add_child(_info_sub)


func _pager(node_name: String, direction: int) -> Control:
	var hit := Control.new()
	hit.name = node_name
	hit.mouse_filter = Control.MOUSE_FILTER_STOP
	hit.custom_minimum_size = Vector2(132, 132)
	hit.size = Vector2(132, 132)
	var face := Panel.new()
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.position = Vector2(18, 18)
	face.size = Vector2(96, 96)
	face.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style("pager_arrow"))
	hit.add_child(face)
	var mark := Label.new()
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.set_anchors_preset(Control.PRESET_FULL_RECT)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.text = "‹" if direction < 0 else "›"
	UiHome.style(mark, 64, Color("#FFF8F0"), UiHome.W_BLACK)
	face.add_child(mark)
	hit.gui_input.connect(_on_page_input.bind(direction))
	return hit


func _progress_row(node_name: String, icon_name: String) -> PanelContainer:
	var row := _panel(node_name, 96)
	row.add_theme_stylebox_override("panel", HomeSeasonStyles.get_style("progress_well"))
	var box := HBoxContainer.new()
	box.name = "Row"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 18)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(box)
	if icon_name.is_empty():
		var caption := _label("Caption")
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(caption)
	else:
		var icon_well := Panel.new()
		icon_well.custom_minimum_size = Vector2(64, 64)
		icon_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var circle := StyleBoxFlat.new()
		circle.bg_color = Color("#FFD56B")
		circle.set_corner_radius_all(32)
		icon_well.add_theme_stylebox_override("panel", circle)
		var icon := TextureRect.new()
		icon.texture = UiAssets.get_chrome_icon(icon_name)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 10
		icon.offset_top = 10
		icon.offset_right = -10
		icon.offset_bottom = -10
		icon_well.add_child(icon)
		box.add_child(icon_well)
		var caption := _label("Caption")
		caption.text = "Coins"
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiHome.style(caption, 38, Color("#FFF8F0"), UiHome.W_BOLD)
		box.add_child(caption)
	var value := _label("Value")
	box.add_child(value)
	var track := ColorRect.new()
	track.name = "Track"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.color = Color(1, 0.973, 0.941, 0.16)
	track.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	track.offset_top = -12
	track.offset_bottom = 0
	row.add_child(track)
	var fill := ColorRect.new()
	fill.name = "Fill"
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.color = Color("#FFD56B") if icon_name == "icon_coin" else Color("#FFF8F0")
	fill.anchor_bottom = 1.0
	fill.anchor_right = 0.0
	track.add_child(fill)
	return row


func _panel(node_name: String, h: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.custom_minimum_size.y = h
	return panel


func _stack() -> VBoxContainer:
	var col := VBoxContainer.new()
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	return col


func _label(node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label


func _pointer(event: InputEvent) -> Dictionary:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return {}
		return {"ok": true, "down": mb.pressed, "pos": mb.position}
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		return {"ok": true, "down": touch.pressed, "pos": touch.position}
	return {}


func _on_open_input(event: InputEvent) -> void:
	var p := _pointer(event)
	if p.is_empty() or bool(p["down"]):
		return
	open_field_pressed.emit(season_id)
	_open.accept_event()


func _on_unlock_input(event: InputEvent) -> void:
	var p := _pointer(event)
	if p.is_empty() or bool(p["down"]):
		return
	if _unlock_on:
		unlock_pressed.emit(season_id)
	_unlock.accept_event()


func _on_buy_input(event: InputEvent) -> void:
	var p := _pointer(event)
	if p.is_empty() or bool(p["down"]):
		return
	if _buy_on:
		cta_pressed.emit(season_id)
	_buy.accept_event()


func _on_page_input(event: InputEvent, direction: int) -> void:
	var p := _pointer(event)
	if p.is_empty() or bool(p["down"]):
		return
	page_pressed.emit(direction)
	accept_event()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _dragging:
		_drag = (event as InputEventMouseMotion).position - _press_at
		position.x = clampf(_drag.x, -UiHome.RUBBER_PX, UiHome.RUBBER_PX)
		accept_event()
		return
	if event is InputEventScreenDrag and _dragging:
		_drag = (event as InputEventScreenDrag).position - _press_at
		position.x = clampf(_drag.x, -UiHome.RUBBER_PX, UiHome.RUBBER_PX)
		accept_event()
		return
	var p := _pointer(event)
	if p.is_empty():
		return
	if bool(p["down"]):
		_dragging = true
		_press_at = p["pos"]
		_drag = Vector2.ZERO
	else:
		var was := _dragging
		_dragging = false
		var dx := _drag.x
		position.x = 0.0
		if was and absf(dx) >= PAGE_DIST and absf(dx) > absf(_drag.y):
			swiped.emit(-1 if dx > 0.0 else 1)
		elif was and absf(dx) < TAP_SLOP and absf(_drag.y) < TAP_SLOP:
			tapped.emit(season_id)
	accept_event()


class RosterFlower extends Control:
	var type_id: String = ""
	var mood: Color = Color.WHITE
	var soon: bool = false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func setup(id: String, mood_color: Color, is_soon: bool) -> void:
		type_id = id
		mood = mood_color
		soon = is_soon
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5
		draw_circle(center, radius, Color("#22342A"))
		if type_id.is_empty():
			draw_circle(center, radius * 0.56, Color("#4A5550") if soon else mood)
			return
		ArenaChipDraw.draw_flower(self, center, type_id, 3, radius * 1.15)
