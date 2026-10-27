class_name ActivityStatsView
extends VBoxContainer

## RET-01 — sadržaj skrivenog ekrana statistike (Settings → 5 dodira na verziju). Sve stane na
## jedan screenshot: dan od prvog pokretanja, D1 / D3 / D7 / D14 / D30, prvih 14 dana, ukupno i
## napredak. Samo prikaz — Copy dugme i toast drži SettingsScreen. Podaci: ActivityLog.snapshot().

const DAY_PLAYED := "played"
const DAY_MISSED := "missed"
const DAY_LATER := "later"
const DAY_UNKNOWN := "unknown"


func _init() -> void:
	name = "ActivityStats"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override("separation", UiSettings.SECTION_GAP)


## Stanje dana iz niza ActivityLog.days_string (1 / 0 / -) i današnjeg dana.
static func day_state(days: String, day: int, today_day: int) -> String:
	if day > today_day:
		return DAY_LATER
	if day >= days.length():
		return DAY_UNKNOWN
	match days[day]:
		"1":
			return DAY_PLAYED
		"0":
			return DAY_MISSED
	return DAY_UNKNOWN


func refresh(snap: Dictionary, version: String) -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var today_day := int(snap.get("today_day", -1))
	var days := str(snap.get("days", ""))
	_build_header(snap, version, today_day)
	_build_retention(days, today_day)
	_build_strip(snap, days, today_day)
	_build_play(snap)


func _build_header(snap: Dictionary, version: String, today_day: int) -> void:
	var rows := _card("", "StatsHead")
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 20)
	rows.add_child(line)
	var day := _label(UiSettings.S.stats_day % maxi(0, today_day), 900, UiSettings.TITLE_FONT, UiSettings.INK)
	day.name = "StatsToday"
	line.add_child(day)
	var since := _label(UiSettings.S.stats_since % str(snap.get("first_day", "")), 700, UiSettings.LABEL_FONT, UiSettings.SUB_INK)
	since.size_flags_vertical = Control.SIZE_SHRINK_END
	line.add_child(since)
	rows.add_child(_label(UiSettings.S.stats_version % version, 700, UiSettings.SUB_FONT, UiSettings.SUB_INK))


func _build_retention(days: String, today_day: int) -> void:
	var rows := _card(UiSettings.S.stats_back, "StatsRetention")
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_theme_constant_override("separation", 32)
	rows.add_child(line)
	for d in UiSettings.STATS_RETENTION_DAYS:
		var state := day_state(days, d, today_day)
		var chip := _cell("D%d" % d, _mark(state), _fill(state), UiSettings.STATS_CHIP, UiSettings.LABEL_FONT)
		chip.name = "StatsDay_D%d" % d
		chip.set_meta("state", state)
		line.add_child(chip)


func _build_strip(snap: Dictionary, days: String, today_day: int) -> void:
	var rows := _card(UiSettings.S.stats_first_days, "StatsStrip")
	var grid := GridContainer.new()
	grid.name = "StripGrid"
	grid.columns = 7
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	rows.add_child(grid)
	for d in UiSettings.STATS_STRIP_DAYS:
		var state := day_state(days, d, today_day)
		var cell := _cell("D%d" % d, "", _fill(state), UiSettings.STATS_CELL, UiSettings.SUB_FONT)
		cell.name = "StripDay_%d" % d
		grid.add_child(cell)
	var played := _label(UiSettings.S.stats_days % [int(snap.get("days_played", 0)), int(snap.get("days_total", 0))],
		900, UiSettings.LABEL_FONT, UiSettings.INK)
	played.name = "StatsDaysPlayed"
	rows.add_child(played)


## Ukupno (tri broja u jednom redu) + napredak — jedna kartica, da sve stane na screenshot.
func _build_play(snap: Dictionary) -> void:
	var rows := _card(UiSettings.S.stats_play, "StatsPlay")
	var totals := HBoxContainer.new()
	totals.name = "Totals"
	totals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(totals)
	totals.add_child(_number(int(snap.get("sessions", 0)), UiSettings.S.stats_sessions))
	totals.add_child(_number(int(snap.get("minutes", 0)), UiSettings.S.stats_minutes))
	totals.add_child(_number(int(snap.get("runs", 0)), UiSettings.S.stats_runs))
	var season_id := str(snap.get("best_season", ""))
	var furthest: String = UiSettings.S.stats_not_yet
	if not season_id.is_empty():
		var def := GameState.get_season_def(season_id)
		var shown := def.display_name if def != null and not def.display_name.is_empty() else season_id
		furthest = UiSettings.S.stats_levels % [shown, int(snap.get("best_level", 0))]
	rows.add_child(_pair(UiSettings.S.stats_furthest, furthest))
	rows.add_child(_pair(UiSettings.S.stats_tutorial, _day_text(int(snap.get("tutorial_day", -1)))))
	rows.add_child(_pair(UiSettings.S.stats_endless, _day_text(int(snap.get("endless_day", -1)))))
	var merge_sec := int(snap.get("first_merge_sec", -1))
	var merge: String = UiSettings.S.stats_not_yet
	if merge_sec >= 0:
		merge = UiSettings.S.stats_play_time % [merge_sec / 60, merge_sec % 60]
	rows.add_child(_pair(UiSettings.S.stats_merge, merge))


# --- male komponente -----------------------------------------------------------

func _card(title: String, node_name: String) -> VBoxContainer:
	var sec := VBoxContainer.new()
	sec.name = node_name
	sec.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sec.add_theme_constant_override("separation", UiSettings.SECTION_TITLE_GAP)
	add_child(sec)
	if not title.is_empty():
		sec.add_child(_label(title, 900, UiSettings.SECTION_TITLE_FONT, UiSettings.INK))
	var card := PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", UiSettings.section_card(false))
	sec.add_child(card)
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", int(UiSettings.CARD_PAD.x))
	pad.add_theme_constant_override("margin_right", int(UiSettings.CARD_PAD.x))
	pad.add_theme_constant_override("margin_top", 28)
	pad.add_theme_constant_override("margin_bottom", 28)
	card.add_child(pad)
	var rows := VBoxContainer.new()
	rows.name = "Rows"
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_theme_constant_override("separation", 16)
	pad.add_child(rows)
	return rows


func _cell(top: String, mark: String, fill: Color, min_size: Vector2, px: int) -> PanelContainer:
	var cell := PanelContainer.new()
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.custom_minimum_size = min_size
	cell.add_theme_stylebox_override("panel", UiSettings.box(fill, 20, 3))
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 0)
	cell.add_child(v)
	var t := _label(top, 900, px, UiSettings.INK)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	if not mark.is_empty():
		var m := _label(mark, 900, px, UiSettings.INK)
		m.name = "Mark"
		m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(m)
	return cell


func _number(value: int, caption: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 0)
	var n := _label(str(value), 900, UiSettings.STATS_NUMBER_FONT, UiSettings.INK)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(n)
	var c := _label(caption, 700, UiSettings.SUB_FONT, UiSettings.SUB_INK)
	c.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(c)
	return v


func _pair(key: String, value: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size = Vector2(0, UiSettings.STATS_ROW_H)
	var k := _label(key, 700, UiSettings.LABEL_FONT, UiSettings.SUB_INK)
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	k.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(k)
	var v := _label(value, 900, UiSettings.LABEL_FONT, UiSettings.INK)
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(v)
	return row


func _label(text: String, weight: int, px: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	UiStage.style(l, weight, px, color)
	return l


func _mark(state: String) -> String:
	match state:
		DAY_PLAYED:
			return UiSettings.S.stats_yes
		DAY_MISSED:
			return UiSettings.S.stats_no
		DAY_LATER:
			return UiSettings.S.stats_later
	return UiSettings.S.stats_unknown


func _fill(state: String) -> Color:
	match state:
		DAY_PLAYED:
			return UiSettings.ON
		DAY_MISSED:
			return UiSettings.FAIL
	return UiSettings.OFF


func _day_text(day: int) -> String:
	return UiSettings.S.stats_on_day % day if day >= 0 else UiSettings.S.stats_not_yet
