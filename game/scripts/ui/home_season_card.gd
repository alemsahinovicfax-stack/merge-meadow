class_name HomeSeasonCard
extends PanelContainer

## Kartica sezone na Home (design_handoff_home · SeasonCard / HomeScreen.dc.html).
## Jedna scena za sve: varijanta je visina + vidljivost djece, stanje je boja i tekst.
## Kartica samo prikazuje podatke; SeasonStage odlucuje sta tap znaci.

signal tapped(season_id: String)
signal open_field_pressed(season_id: String)
signal unlock_pressed(season_id: String)
signal cta_pressed(season_id: String)
signal fresh_done(season_id: String)

const DRAG_SCROLL := preload("res://scripts/ui/drag_scroll.gd")
const PRESS_SCALE := 0.97
const PRESS_SEC := 0.08

var season_id: String = ""
var variant: String = UiHome.COLLAPSED
var state: String = UiHome.ST_UNLOCKED
var _data: Dictionary = {}
var _fresh_shown: bool = false
var _pressing: bool = false
var _drag_dist: float = 0.0
var _press_tween: Tween
var _fresh_tween: Tween
var _busy_tween: Tween
var _bounce_tween: Tween
var _height_tween: Tween

var _burst: HomeUnlockBurst
var _body: VBoxContainer
var _head: HBoxContainer
var _lock_box: PanelContainer
var _head_text: VBoxContainer
var _eyebrow_row: HBoxContainer
var _badge_top: PanelContainer
var _new_badge: PanelContainer
var _eyebrow: Label
var _name: Label
var _status: Label
var _badge_row: PanelContainer
var _status_chip: PanelContainer
var _price_tag: PanelContainer
var _open_button: CampButton
var _tagline: Label
var _roster: PanelContainer
var _roster_row: HBoxContainer
var _roster_frames: Array[CampArtFrame] = []
var _roster_pips: Array[Label] = []
var _roster_slots: Array[VBoxContainer] = []
var _poster: VBoxContainer
var _need: Label
var _coin_row: HBoxContainer
var _coin_icon: TextureRect
var _coin_value: Label
var _coin_bar: HomeBar
var _flower_row: HBoxContainer
var _gate_frame: CampArtFrame
var _flower_value: Label
var _flower_bar: HomeBar
var _gate_caption: Label
var _unlock_button: CampButton
var _cta: CampButton


func _init() -> void:
	name = "SeasonCard"
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()


func _ready() -> void:
	resized.connect(_on_resized)
	_open_button.clicked.connect(func() -> void: open_field_pressed.emit(season_id))
	_unlock_button.clicked.connect(func() -> void: unlock_pressed.emit(season_id))
	_cta.clicked.connect(func() -> void: cta_pressed.emit(season_id))
	_on_resized()
	_apply()


## data: season_id, variant, state, active, fresh, name, tagline, prev_name, roster,
## coins, coins_need, flowers, flowers_need, gate_type_id, gate_name, price.
func configure(data: Dictionary) -> void:
	var was_fresh := bool(_data.get("fresh", false))
	_data = data
	season_id = str(data.get("season_id", ""))
	variant = str(data.get("variant", UiHome.COLLAPSED))
	state = str(data.get("state", UiHome.ST_UNLOCKED))
	if not bool(data.get("fresh", false)) or not was_fresh:
		_fresh_shown = false
	if is_node_ready():
		_apply()


## Visina iz stagea (varijanta + dio praznog prostora ako je ova kartica fokus).
func set_target_height(h: float, animated: bool) -> void:
	_fit_roster(h)
	if _height_tween:
		_height_tween.kill()
		_height_tween = null
	if not animated or not is_inside_tree() or is_equal_approx(custom_minimum_size.y, h):
		custom_minimum_size = Vector2(0.0, h)
		return
	_height_tween = create_tween()
	_height_tween.tween_property(self, "custom_minimum_size:y", h, UiHome.T_CARD) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Najniza visina bez rezanja sadrzaja (roster na najmanjem okviru cvijeta).
func floor_height() -> float:
	var h := get_minimum_size().y
	if _roster.visible and not _roster_frames.is_empty():
		h -= maxf(_roster_frames[0].frame_side - UiHome.ART_MIN, 0.0)
	return h


func play_unlock_burst() -> void:
	_burst.play()


func bounce() -> void:
	if _bounce_tween:
		_bounce_tween.kill()
	modulate.a = 1.0
	if not is_inside_tree():
		return
	_bounce_tween = create_tween().set_trans(Tween.TRANS_SINE)
	_bounce_tween.tween_property(self, "modulate:a", 0.55, UiHome.T_BOUNCE * 0.5).set_ease(Tween.EASE_OUT)
	_bounce_tween.tween_property(self, "modulate:a", 1.0, UiHome.T_BOUNCE * 0.5).set_ease(Tween.EASE_IN)


# --- getteri (smoke) ---

func is_active() -> bool:
	return state == UiHome.ST_ACTIVE or bool(_data.get("active", false))


func get_status_text() -> String:
	return _status.text if _status.visible else ""


func get_chip_text() -> String:
	return (_status_chip.get_child(0) as Label).text if _status_chip.visible else ""


func get_price_text() -> String:
	return (_price_tag.get_child(0) as Label).text if _price_tag.visible else ""


func get_need_text() -> String:
	return _need.text if _poster.visible else ""


func get_unlock_title() -> String:
	return _unlock_button.get_title() if _unlock_button.visible else ""


func get_unlock_sub() -> String:
	return _unlock_button.get_sub() if _unlock_button.visible else ""


func is_unlock_enabled() -> bool:
	return _unlock_button.visible and not _unlock_button.disabled


func get_cta_title() -> String:
	return _cta.get_title() if _cta.visible else ""


func is_cta_enabled() -> bool:
	return _cta.visible and not _cta.disabled


func has_open_button() -> bool:
	return _open_button.visible


func has_playing_badge() -> bool:
	return _badge_top.visible or _badge_row.visible


func has_new_badge() -> bool:
	return _new_badge.visible


func has_lock() -> bool:
	return _lock_box.visible


func has_roster() -> bool:
	return _roster.visible


func roster_art_side() -> float:
	return _roster_frames[0].frame_side if not _roster_frames.is_empty() else 0.0


func get_fill_color() -> Color:
	return (get_theme_stylebox("panel") as StyleBoxFlat).bg_color


func get_border_width() -> int:
	return (get_theme_stylebox("panel") as StyleBoxFlat).border_width_left


# --- gradnja ---

func _build() -> void:
	_burst = HomeUnlockBurst.new()
	_burst.name = "UnlockBurst"
	add_child(_burst)
	_body = VBoxContainer.new()
	_body.name = "CardBody"
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_body)

	_head = _hbox("CardHead", 18)
	_body.add_child(_head)
	_lock_box = PanelContainer.new()
	_lock_box.name = "LockBox"
	_lock_box.custom_minimum_size = Vector2(UiHome.LOCK_BOX, UiHome.LOCK_BOX)
	_lock_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_lock_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock_box.add_theme_stylebox_override("panel", UiHome.lock_box())
	var lock_icon := _icon_rect("LockIcon", UiAssets.get_chrome_icon("icon_lock"), UiHome.LOCK_ICON)
	lock_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	lock_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_lock_box.add_child(lock_icon)
	_head.add_child(_lock_box)

	_head_text = VBoxContainer.new()
	_head_text.name = "HeadText"
	_head_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_head_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_head_text.alignment = BoxContainer.ALIGNMENT_CENTER
	_head.add_child(_head_text)
	_eyebrow_row = _hbox("EyebrowRow", 14)
	_eyebrow_row.custom_minimum_size.y = UiHome.CHIP_H
	_head_text.add_child(_eyebrow_row)
	_badge_top = _chip("ActiveBadge", UiHome.CHIP_H)
	_eyebrow_row.add_child(_badge_top)
	_new_badge = _chip("NewBadge", UiHome.CHIP_H)
	_eyebrow_row.add_child(_new_badge)
	_eyebrow = _label("Eyebrow")
	_eyebrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_eyebrow_row.add_child(_eyebrow)
	_name = _label("SeasonName")
	UiHome.ellipsis(_name)
	_head_text.add_child(_name)
	_status = _label("StatusLine")
	UiHome.ellipsis(_status)
	_head_text.add_child(_status)

	_badge_row = _chip("PlayingBadge", UiHome.BADGE_ROW_H)
	_head.add_child(_badge_row)
	_status_chip = _chip("StatusChip", UiHome.STATUS_CHIP_H)
	_head.add_child(_status_chip)
	_price_tag = _chip("PriceTag", UiHome.PRICE_TAG_H)
	_head.add_child(_price_tag)
	_open_button = _button("OpenFieldButton")
	_open_button.custom_minimum_size = UiHome.OPEN_BTN
	_open_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_open_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_head.add_child(_open_button)

	_tagline = _label("Tagline")
	_tagline.custom_minimum_size.y = UiHome.TAGLINE_H
	UiHome.ellipsis(_tagline)
	_body.add_child(_tagline)

	_roster = PanelContainer.new()
	_roster.name = "SeasonRoster"
	_roster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_roster.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(_roster)
	_roster_row = _hbox("RosterRow", UiHome.ROSTER_GAP)
	_roster.add_child(_roster_row)

	_poster = VBoxContainer.new()
	_poster.name = "UnlockPoster"
	_poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_poster.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(_poster)
	_need = _label("NeedLine")
	_need.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_poster.add_child(_need)
	_coin_row = _hbox("CoinProgress", 16)
	_poster.add_child(_coin_row)
	_coin_icon = _icon_rect("CoinIcon", UiAssets.get_chrome_icon("icon_coin"), 60)
	_coin_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_coin_row.add_child(_coin_icon)
	_coin_value = _label("CoinValue")
	_coin_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_coin_row.add_child(_coin_value)
	_coin_bar = _bar("CoinBar")
	_coin_row.add_child(_coin_bar)
	_flower_row = _hbox("FlowerProgress", 16)
	_poster.add_child(_flower_row)
	_gate_frame = CampArtFrame.new()
	_gate_frame.name = "GateArt"
	_gate_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_flower_row.add_child(_gate_frame)
	_flower_value = _label("FlowerValue")
	_flower_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_flower_row.add_child(_flower_value)
	_flower_bar = _bar("FlowerBar")
	_flower_row.add_child(_flower_bar)
	_gate_caption = _label("GateCaption")
	UiHome.ellipsis(_gate_caption)
	_poster.add_child(_gate_caption)
	_unlock_button = _button("UnlockButton")
	_unlock_button.custom_minimum_size.y = UiHome.UNLOCK_BTN_H
	_poster.add_child(_unlock_button)

	_cta = _button("CardCta")
	_cta.custom_minimum_size.y = UiHome.CTA_H
	_body.add_child(_cta)


func _ensure_roster_slots(count: int) -> void:
	while _roster_slots.size() < count:
		var slot := VBoxContainer.new()
		slot.name = "RosterSlot%d" % _roster_slots.size()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.add_theme_constant_override("separation", UiHome.ROSTER_SLOT_GAP)
		var frame := CampArtFrame.new()
		frame.name = "ArtFrame"
		frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		slot.add_child(frame)
		var pips := _label("RarityPips")
		pips.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.add_child(pips)
		_roster_row.add_child(slot)
		_roster_slots.append(slot)
		_roster_frames.append(frame)
		_roster_pips.append(pips)


# --- primjena podataka (HomeScreen.dc.html · card()) ---

func _apply() -> void:
	var v := variant
	var st := state
	var is_col := v == UiHome.COLLAPSED
	var is_exp := v == UiHome.EXPANDED
	var is_next := v == UiHome.NEXTLOCK
	var is_post := v == UiHome.POSTER
	var is_prem := v == UiHome.PREMIUM
	var active := is_active()
	var soon := st == UiHome.ST_SOON
	var dim := st == UiHome.ST_LOCKED
	var light := UiHome.card_light(season_id, st)
	var ink := UiHome.ink(light)
	var sub := UiHome.sub_ink(light)
	var big_head := is_exp or is_post or is_prem
	var fresh := bool(_data.get("fresh", false))
	var display_name := str(_data.get("name", season_id))

	add_theme_stylebox_override("panel", UiHome.season_card(season_id, st, v, active))
	_body.add_theme_constant_override("separation", UiHome.CARD_SEP[v])
	_head.custom_minimum_size.y = UiHome.HEAD_H[v]
	_head.size_flags_vertical = Control.SIZE_EXPAND_FILL if is_col else Control.SIZE_FILL
	_head_text.add_theme_constant_override("separation", 6 if is_col else 8)

	var eyebrow := ""
	if is_post:
		eyebrow = "Next free season"
	elif is_prem:
		eyebrow = "Premium season" if soon else "Premium season · one-time"
	var badge := "Playing now" if active else ""
	var status := ""
	if is_col:
		status = _collapsed_status(st, active)

	_lock_box.visible = dim or soon
	_eyebrow_row.visible = big_head and (not eyebrow.is_empty() or not badge.is_empty() or fresh)
	_style_chip(_badge_top, "Playing now", UiHome.eyebrow_chip(UiHome.RIM, UiHome.COIN_GOLD_EDGE), UiHome.FONT_CHIP, UiHome.INK)
	_badge_top.visible = big_head and not badge.is_empty()
	_style_chip(_new_badge, "New", UiHome.eyebrow_chip(UiHome.MINT, UiHome.MINT_EDGE), UiHome.FONT_CHIP, UiHome.INK)
	_new_badge.visible = big_head and fresh
	_eyebrow.text = eyebrow
	_eyebrow.visible = not eyebrow.is_empty()
	UiHome.style(_eyebrow, UiHome.FONT_EYEBROW, sub, UiHome.W_REGULAR)
	_name.text = display_name
	UiHome.style(_name, UiHome.NAME_PX[v], ink, UiHome.W_BLACK)
	_status.text = status
	_status.visible = not status.is_empty()
	UiHome.style(_status, UiHome.FONT_STATUS, sub, UiHome.W_REGULAR)

	_style_chip(_badge_row, "Playing now", UiHome.badge_row(), UiHome.FONT_BADGE_ROW, UiHome.INK)
	_badge_row.visible = not badge.is_empty() and not big_head
	var chip_on := (is_col and st == UiHome.ST_NEXT) or is_next
	var chip_text := "Next free season" if is_next else "%d / %d  ·  %d / %d" % [
		_int("coins"), _int("coins_need"), _int("flowers"), _int("flowers_need")
	]
	_style_chip(
		_status_chip, chip_text, UiHome.status_chip(light),
		UiHome.FONT_STATUS_CHIP_NEXT if is_next else UiHome.FONT_STATUS_CHIP, ink
	)
	_status_chip.visible = chip_on
	var price := str(_data.get("price", ""))
	_style_chip(_price_tag, price, UiHome.price_tag(), UiHome.FONT_PRICE, UiHome.INK)
	_price_tag.visible = (
		(is_col or is_prem) and (st == UiHome.ST_PREMIUM or st == UiHome.ST_BUSY) and not price.is_empty()
	)
	_open_button.visible = is_exp and (active or st == UiHome.ST_UNLOCKED)
	_open_button.set_styles(UiHome.open_button(light))
	_open_button.set_text("Open meadow ↗")
	_open_button.set_fonts(UiHome.FONT_OPEN)
	_open_button.set_ink(ink)

	_tagline.visible = is_exp or is_post or is_prem
	_tagline.text = str(_data.get("tagline", ""))
	UiHome.style(_tagline, UiHome.FONT_TAGLINE, sub, UiHome.W_REGULAR)

	_roster.visible = is_exp or is_prem
	if _roster.visible:
		_apply_roster(light, ink)

	_poster.visible = is_next or is_post
	if _poster.visible:
		_apply_poster(is_post, st, light, ink, sub, display_name)
	else:
		_unlock_button.visible = false

	_apply_cta(is_prem, st, light, display_name)
	_apply_fresh(big_head and fresh)
	_fit_roster(custom_minimum_size.y)


func _collapsed_status(st: String, active: bool) -> String:
	if active:
		return "Tap to open the meadow ↗"
	match st:
		UiHome.ST_UNLOCKED:
			return "Unlocked · tap to play here"
		UiHome.ST_NEXT:
			return "Next free season"
		UiHome.ST_LOCKED:
			var prev := str(_data.get("prev_name", ""))
			return "Opens after %s" % prev if not prev.is_empty() else "Locked"
		UiHome.ST_PREMIUM, UiHome.ST_BUSY:
			return "Premium · preview inside"
		UiHome.ST_OWNED:
			return "Owned"
		UiHome.ST_SOON:
			return "Coming soon"
	return ""


func _apply_roster(light: bool, ink: Color) -> void:
	_roster.add_theme_stylebox_override("panel", UiHome.roster_panel(light))
	var roster: Array = _data.get("roster", [])
	_ensure_roster_slots(roster.size())
	for i in _roster_slots.size():
		var show := i < roster.size()
		_roster_slots[i].visible = show
		if not show:
			continue
		var entry: Dictionary = roster[i]
		_roster_frames[i].set_art(false, str(entry.get("id", "")), 3)
		_roster_pips[i].text = UiCamp.pips(int(entry.get("rarity", 1)))
		UiHome.style(_roster_pips[i], UiHome.PIPS_PX, ink, UiHome.W_BOLD)


func _apply_poster(is_post: bool, st: String, light: bool, ink: Color, sub: Color, display_name: String) -> void:
	var coins := _int("coins")
	var coins_need := _int("coins_need")
	var flowers := _int("flowers")
	var flowers_need := _int("flowers_need")
	var gate := str(_data.get("gate_name", ""))
	var d_coins := maxi(0, coins_need - coins)
	var d_flowers := maxi(0, flowers_need - flowers)
	var gate_ready := d_coins == 0 and d_flowers == 0
	var unlocking := st == UiHome.ST_UNLOCKING
	_poster.add_theme_constant_override("separation", 14 if is_post else 12)

	var need := "Need %d more coins and %d more %s" % [d_coins, d_flowers, gate]
	if gate_ready:
		need = "Both ready — unlock it whenever you like."
	if unlocking:
		need = "Welcome to %s." % display_name
	_need.text = need
	UiHome.style(_need, UiHome.FONT_NEED if is_post else UiHome.FONT_NEED_COMPACT, ink, UiHome.W_BOLD)

	var icon_side := 60.0 if is_post else 56.0
	var value_w := 300.0 if is_post else 240.0
	var value_px := UiHome.FONT_VALUE if is_post else UiHome.FONT_VALUE_COMPACT
	var bar_h := UiHome.BAR_H_POSTER if is_post else UiHome.BAR_H_COMPACT
	for row in [_coin_row, _flower_row]:
		var r := row as HBoxContainer
		r.size_flags_vertical = Control.SIZE_EXPAND_FILL if is_post else Control.SIZE_FILL
		r.custom_minimum_size.y = icon_side if is_post else 66.0
	_coin_icon.custom_minimum_size = Vector2(icon_side, icon_side)
	_coin_value.text = "%d / %d" % [coins, coins_need]
	_coin_value.custom_minimum_size.x = value_w
	UiHome.style(_coin_value, value_px, ink, UiHome.W_BLACK)
	_coin_bar.custom_minimum_size.y = bar_h
	_coin_bar.set_colors(UiHome.bar_track(light), UiHome.COIN_GOLD)
	_coin_bar.set_ratio(float(coins) / maxf(float(coins_need), 1.0), is_inside_tree())

	_gate_frame.configure_frame(icon_side, 18, 3, 8.0, 11, 2, 34.0 if is_post else 30.0)
	_gate_frame.set_art(false, str(_data.get("gate_type_id", "")), 3)
	_flower_value.text = "%d / %d" % [flowers, flowers_need]
	_flower_value.custom_minimum_size.x = value_w
	UiHome.style(_flower_value, value_px, ink, UiHome.W_BLACK)
	_flower_bar.custom_minimum_size.y = bar_h
	_flower_bar.set_colors(UiHome.bar_track(light), UiHome.WARM_WHITE)
	_flower_bar.set_ratio(float(flowers) / maxf(float(flowers_need), 1.0), is_inside_tree())

	_gate_caption.visible = is_post
	_gate_caption.text = "%s ★★★ · merge it in the Arena" % gate
	UiHome.style(_gate_caption, UiHome.FONT_CAPTION, sub, UiHome.W_REGULAR)

	_unlock_button.visible = is_post
	if not is_post:
		return
	var ready := st == UiHome.ST_READY
	var btn_state := st if ready or unlocking else UiHome.ST_LOCKED
	var title := "Unlock %s" % display_name
	var btn_sub := "needs %d more coins and %d more %s" % [d_coins, d_flowers, gate]
	if ready or gate_ready:
		btn_sub = "spends %d coins and %d %s" % [coins_need, flowers_need, gate]
	if unlocking:
		title = "%s unlocked" % display_name
		btn_sub = "spent %d coins and %d %s" % [coins_need, flowers_need, gate]
	var btn_style := UiHome.unlock_button(btn_state)
	_unlock_button.set_styles(btn_style, btn_style)
	_unlock_button.set_text(title, btn_sub)
	_unlock_button.set_fonts(UiHome.FONT_UNLOCK, UiHome.FONT_BTN_SUB)
	_unlock_button.set_ink(UiHome.unlock_ink(btn_state))
	_unlock_button.disabled = not ready


func _apply_cta(is_prem: bool, st: String, light: bool, display_name: String) -> void:
	var show := is_prem and st in [UiHome.ST_PREMIUM, UiHome.ST_BUSY, UiHome.ST_SOON, UiHome.ST_OWNED]
	_cta.visible = show
	if _busy_tween:
		_busy_tween.kill()
		_busy_tween = null
	_cta.modulate.a = 1.0
	if not show:
		return
	var title := "Get %s" % display_name
	var sub := "%s · one-time, no subscription" % str(_data.get("price", ""))
	match st:
		UiHome.ST_BUSY:
			title = "Purchasing…"
			sub = "finish in the store window"
		UiHome.ST_SOON:
			title = "Coming soon"
			sub = "not for sale yet"
		UiHome.ST_OWNED:
			title = "Open meadow ↗"
			sub = "owned — plays like a free season"
	var style := UiHome.cta_button(st, light)
	_cta.set_styles(style, style)
	_cta.set_text(title, sub)
	_cta.set_fonts(UiHome.FONT_CTA, UiHome.FONT_BTN_SUB)
	_cta.set_ink(UiHome.cta_ink(st, light))
	_cta.disabled = st == UiHome.ST_BUSY or st == UiHome.ST_SOON
	if st == UiHome.ST_BUSY and is_inside_tree():
		_cta.modulate.a = 0.85
		_busy_tween = create_tween().set_loops()
		_busy_tween.tween_property(_cta, "modulate:a", 0.55, UiHome.T_BUSY_PULSE * 0.5)
		_busy_tween.tween_property(_cta, "modulate:a", 0.85, UiHome.T_BUSY_PULSE * 0.5)


## Cip "New" posle otkljucavanja: 0,3 s pojava, 3 s stoji, pa nestaje.
func _apply_fresh(show: bool) -> void:
	if not show:
		if _fresh_tween:
			_fresh_tween.kill()
			_fresh_tween = null
		_new_badge.modulate.a = 1.0
		return
	if _fresh_shown:
		return
	_fresh_shown = true
	if not is_inside_tree():
		return
	_new_badge.modulate.a = 0.0
	_fresh_tween = create_tween()
	_fresh_tween.tween_property(_new_badge, "modulate:a", 1.0, UiHome.T_NEW_IN)
	_fresh_tween.tween_interval(UiHome.T_NEW_HOLD)
	_fresh_tween.tween_property(_new_badge, "modulate:a", 0.0, UiHome.T_NEW_IN)
	_fresh_tween.tween_callback(func() -> void: fresh_done.emit(season_id))


## Okvir cvijeta u rosteru: najvise 116 px, koliko stane u visinu kartice.
func _fit_roster(h: float) -> void:
	if not _roster.visible:
		return
	var p := float(UiHome.CARD_PAD[variant])
	var border := float(UiHome.CARD_BORDER_ACTIVE if is_active() else UiHome.CARD_BORDER)
	var sep := float(UiHome.CARD_SEP[variant])
	var used := 2.0 * (p + border) + float(UiHome.HEAD_H[variant]) + sep + UiHome.TAGLINE_H + sep
	if _cta.visible:
		used += UiHome.CTA_H + sep
	var inner := h - used - 2.0 * (UiHome.ROSTER_PAD_V + UiHome.ROSTER_BORDER)
	var side := clampf(inner - UiHome.ROSTER_SLOT_GAP - UiHome.PIPS_PX, UiHome.ART_MIN, UiHome.ART_MAX)
	side = floorf(side)
	for frame in _roster_frames:
		frame.configure_frame(
			side, int(round(side * 0.22)), 3, maxf(7.0, round(side * 0.095)),
			int(round(side * 0.15)), 2, round(side * 0.58)
		)


# --- input: tap vs skrol (kao Camp chip) ---

func _gui_input(event: InputEvent) -> void:
	var dy := DRAG_SCROLL.drag_delta(event)
	if not is_zero_approx(dy):
		_drag_dist += absf(dy)
		if _drag_dist >= DRAG_SCROLL.TAP_SLOP and _pressing:
			_pressing = false
			_press_to(1.0)
		DRAG_SCROLL.apply(DRAG_SCROLL.find_scroll(self), dy)
		accept_event()
		return
	var down := false
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		down = mb.pressed
	elif event is InputEventScreenTouch:
		down = (event as InputEventScreenTouch).pressed
	else:
		return
	if down:
		_pressing = true
		_drag_dist = 0.0
		_press_to(PRESS_SCALE)
	else:
		var was_tap := _pressing and _drag_dist < DRAG_SCROLL.TAP_SLOP
		_pressing = false
		_press_to(1.0)
		if was_tap:
			tapped.emit(season_id)
	accept_event()


func _press_to(target: float) -> void:
	if _press_tween:
		_press_tween.kill()
	if not is_inside_tree():
		scale = Vector2.ONE * target
		return
	_press_tween = create_tween()
	_press_tween.tween_property(self, "scale", Vector2.ONE * target, PRESS_SEC)


func _on_resized() -> void:
	pivot_offset = size * 0.5


# --- helperi ---

func _int(key: String) -> int:
	return int(_data.get(key, 0))


func _hbox(node_name: String, sep: int) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.name = node_name
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_constant_override("separation", sep)
	return b


func _label(node_name: String) -> Label:
	var l := Label.new()
	l.name = node_name
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


func _chip(node_name: String, h: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.name = node_name
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.custom_minimum_size.y = h
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var l := _label("Text")
	p.add_child(l)
	return p


func _style_chip(chip: PanelContainer, text: String, style: StyleBoxFlat, px: int, color: Color) -> void:
	chip.add_theme_stylebox_override("panel", style)
	var l := chip.get_child(0) as Label
	l.text = text
	UiHome.style(l, px, color, UiHome.W_BLACK)


func _icon_rect(node_name: String, tex: Texture2D, side: float) -> TextureRect:
	var t := TextureRect.new()
	t.name = node_name
	t.texture = tex
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(side, side)
	return t


func _bar(node_name: String) -> HomeBar:
	var b := HomeBar.new()
	b.name = node_name
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b


func _button(node_name: String) -> CampButton:
	var b := CampButton.new()
	b.name = node_name
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return b
