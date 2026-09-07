extends VBoxContainer

## Shared locked-season poster — Home stacked; Camp split coins | flower.

const CONTRAST := preload("res://scripts/ui/season_card_contrast.gd")
const ASSETS := preload("res://scripts/visual/pickup_assets.gd")
const RarityStars := preload("res://scripts/ui/rarity_stars.gd")

const COIN_SIDE := 40.0
const FLOWER_SIDE := 92.0
const DIVIDER_HEIGHT := 2.0
const DIVIDER_WIDTH_RATIO := 0.70
const DIVIDER_GAP := 8.0
const BAR_HEIGHT := 10.0
const COUNT_FONT := 18
const NAME_FONT := 16

const CAMP_COIN_SIDE := 88.0
const CAMP_FLOWER_SIDE := 88.0
const CAMP_COUNT_FONT := 32
const CAMP_NAME_FONT := 26
const CAMP_STAR_FONT := 28
const CAMP_BAR_HEIGHT := 16.0
const CAMP_VLINE_WIDTH := 5.0
const CAMP_VLINE_HEIGHT := 110.0
const CAMP_STAR_SLOT_H := 28.0

var split_columns: bool = false
var coin_star_spacer: Control

var coin_icon: TextureRect
var coins_label: Label
var coins_bar: ProgressBar
var section_divider: Control
var divider_line: ColorRect
var flower_visual: Control
var stars_label: Label
var stars_row: HBoxContainer
var flower_name_label: Label
var t3_label: Label
var t3_bar: ProgressBar


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 4)
	split_columns = name == "SeasonUnlockProgress"
	_bind_children()
	if split_columns:
		_build_split_row()
	else:
		_ensure_divider()
	_ignore_hits(self)
	_apply_coin_texture()
	_apply_flower_size()
	_apply_compact_metrics()


func refresh(season_id: String) -> void:
	_bind_children()
	if not split_columns:
		_ensure_divider()
	var def: SeasonDef = GameState.get_season_def(season_id)
	if def == null:
		return
	var coins := GameState.wallet_coins
	var t3 := GameState.star3_flower_count_for_unlock(season_id)
	var coin_need := maxi(1, def.coins_cost)
	var t3_need := maxi(1, def.t3_flowers_required)
	if coins_label:
		coins_label.text = "%d / %d" % [coins, def.coins_cost]
		coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if coins_bar:
		coins_bar.max_value = coin_need
		coins_bar.value = mini(coins, def.coins_cost)
	if t3_label:
		t3_label.text = "%d / %d" % [t3, def.t3_flowers_required]
		t3_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if t3_bar:
		t3_bar.max_value = t3_need
		t3_bar.value = mini(t3, def.t3_flowers_required)
	var prev := GameState.previous_free_id_for(season_id)
	var flower_id := GameState.star3_type_id_for_season(prev)
	if flower_visual and "type_id" in flower_visual:
		flower_visual.set("type_id", flower_id)
	if stars_row:
		RarityStars.apply_row(stars_row, 3, CAMP_STAR_FONT)
	elif stars_label:
		stars_label.text = "★★★"
		stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if flower_name_label:
		flower_name_label.text = GameState.get_seed_display_name(flower_id)
		flower_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_coin_texture()
	_apply_flower_size()
	_apply_compact_metrics()
	_tint_divider(season_id)
	_layout_divider()
	_apply_ink(CONTRAST.text_color(season_id))


func _bind_children() -> void:
	if coin_icon == null:
		coin_icon = _first_tex(["CoinIcon", "UnlockCoinIcon", "SeasonLinkCoinIcon"])
	if coins_label == null:
		coins_label = _first_label(["CoinsLabel", "UnlockGateCoins", "SeasonLinkCoins"])
	if coins_bar == null:
		coins_bar = _first_bar(["CoinsBar", "UnlockGateCoinsBar", "SeasonLinkCoinsBar"])
	if flower_visual == null:
		flower_visual = _first_ctrl(["FlowerVisual", "SeasonLinkFlower"])
	if stars_label == null:
		stars_label = _first_label(["StarsLabel", "SeasonLinkStars"])
	if flower_name_label == null:
		flower_name_label = _first_label(["FlowerName", "UnlockFlowerName", "SeasonLinkFlowerName"])
	if t3_label == null:
		t3_label = _first_label(["T3Label", "UnlockGateT3", "SeasonLinkT3"])
	if t3_bar == null:
		t3_bar = _first_bar(["T3Bar", "UnlockGateT3Bar", "SeasonLinkT3Bar"])


func _build_split_row() -> void:
	if get_node_or_null("SplitRow") != null:
		return
	var legacy := get_node_or_null("SectionDivider") as Control
	if legacy:
		legacy.name = "LegacyDivider"
		legacy.visible = false
	var row := HBoxContainer.new()
	row.name = "SplitRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var coin_col := VBoxContainer.new()
	coin_col.name = "CoinCol"
	coin_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coin_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coin_col.size_flags_stretch_ratio = 1.0
	coin_col.alignment = BoxContainer.ALIGNMENT_CENTER
	coin_col.add_theme_constant_override("separation", 4)
	var flower_col := VBoxContainer.new()
	flower_col.name = "FlowerCol"
	flower_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flower_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flower_col.size_flags_stretch_ratio = 1.0
	flower_col.alignment = BoxContainer.ALIGNMENT_CENTER
	flower_col.add_theme_constant_override("separation", 4)
	var vline := ColorRect.new()
	vline.name = "SectionDivider"
	vline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vline.custom_minimum_size = Vector2(2, 80)
	vline.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section_divider = vline
	divider_line = vline
	row.add_child(coin_col)
	row.add_child(vline)
	row.add_child(flower_col)
	add_child(row)
	move_child(row, 0)
	_reparent_into(coin_col, [coin_icon, coins_label, coins_bar])
	_reparent_into(flower_col, [flower_visual, stars_label, flower_name_label, t3_label, t3_bar])
	if stars_label:
		stars_label.visible = false
	stars_row = RarityStars.make_row(3, CAMP_STAR_FONT)
	if flower_visual and flower_visual.get_parent() == flower_col:
		flower_col.add_child(stars_row)
		flower_col.move_child(stars_row, flower_visual.get_index() + 1)
	else:
		flower_col.add_child(stars_row)


func _reparent_into(dest: Node, nodes: Array) -> void:
	for item in nodes:
		if item == null or not (item is Node):
			continue
		var n := item as Node
		var parent := n.get_parent()
		if parent == dest:
			continue
		var keep_owner := n.owner
		var keep_unique := n.unique_name_in_owner
		if parent:
			parent.remove_child(n)
		dest.add_child(n)
		if keep_owner:
			n.owner = keep_owner
		n.unique_name_in_owner = keep_unique


func _ensure_divider() -> void:
	if split_columns:
		return
	section_divider = get_node_or_null("SectionDivider") as Control
	if section_divider == null:
		section_divider = Control.new()
		section_divider.name = "SectionDivider"
		add_child(section_divider)
	section_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section_divider.custom_minimum_size = Vector2(0, DIVIDER_HEIGHT + DIVIDER_GAP * 2.0)
	section_divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if coins_bar and coins_bar.get_parent() == self:
		var want := coins_bar.get_index() + 1
		if section_divider.get_index() != want:
			move_child(section_divider, want)
	if not section_divider.resized.is_connected(_layout_divider):
		section_divider.resized.connect(_layout_divider)
	divider_line = section_divider.get_node_or_null("Line") as ColorRect
	if divider_line == null:
		divider_line = ColorRect.new()
		divider_line.name = "Line"
		divider_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		section_divider.add_child(divider_line)


func _layout_divider() -> void:
	if split_columns:
		if divider_line:
			divider_line.custom_minimum_size = Vector2(2, 80)
		return
	if section_divider == null or divider_line == null:
		return
	var w := maxf(8.0, section_divider.size.x * DIVIDER_WIDTH_RATIO)
	var x := (section_divider.size.x - w) * 0.5
	divider_line.position = Vector2(x, DIVIDER_GAP)
	divider_line.size = Vector2(w, DIVIDER_HEIGHT)


func _tint_divider(season_id: String) -> void:
	if divider_line:
		divider_line.color = CONTRAST.border_color(season_id)


func _first_tex(names: Array[String]) -> TextureRect:
	for n in names:
		var node := find_child(n, true, false) as TextureRect
		if node:
			return node
	return null


func _first_label(names: Array[String]) -> Label:
	for n in names:
		var node := find_child(n, true, false) as Label
		if node:
			return node
	return null


func _first_bar(names: Array[String]) -> ProgressBar:
	for n in names:
		var node := find_child(n, true, false) as ProgressBar
		if node:
			return node
	return null


func _first_ctrl(names: Array[String]) -> Control:
	for n in names:
		var node := find_child(n, true, false) as Control
		if node:
			return node
	return null


func _coin_side() -> float:
	return CAMP_COIN_SIDE if split_columns else COIN_SIDE


func _flower_side() -> float:
	return CAMP_FLOWER_SIDE if split_columns else FLOWER_SIDE


func _count_font() -> int:
	return CAMP_COUNT_FONT if split_columns else COUNT_FONT


func _name_font() -> int:
	return CAMP_NAME_FONT if split_columns else NAME_FONT


func _bar_height() -> float:
	return CAMP_BAR_HEIGHT if split_columns else BAR_HEIGHT


func _apply_coin_texture() -> void:
	if coin_icon == null:
		return
	var tex := ASSETS.get_coin_texture()
	coin_icon.texture = tex
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var side := _coin_side()
	coin_icon.custom_minimum_size = Vector2(side, side)
	coin_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _apply_flower_size() -> void:
	if flower_visual == null:
		return
	var side := _flower_side()
	flower_visual.custom_minimum_size = Vector2(side, side)
	flower_visual.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if "icon_side" in flower_visual:
		flower_visual.set("icon_side", side)


func _apply_compact_metrics() -> void:
	var bar_h := _bar_height()
	var count_px := _count_font()
	var name_px := _name_font()
	if coins_bar:
		coins_bar.custom_minimum_size.y = bar_h
	if t3_bar:
		t3_bar.custom_minimum_size.y = bar_h
	if coins_label:
		coins_label.add_theme_font_size_override("font_size", count_px)
	if t3_label:
		t3_label.add_theme_font_size_override("font_size", count_px)
	if stars_label and stars_label.visible:
		stars_label.add_theme_font_size_override("font_size", name_px)
	if flower_name_label:
		flower_name_label.add_theme_font_size_override("font_size", name_px)
	if stars_row:
		RarityStars.apply_row(stars_row, 3, CAMP_STAR_FONT if split_columns else name_px)


func _apply_ink(ink: Color) -> void:
	for lab in [coins_label, flower_name_label, t3_label]:
		if lab:
			lab.add_theme_color_override("font_color", ink)
	if stars_label and stars_label.visible:
		stars_label.add_theme_color_override("font_color", ink)


func _ignore_hits(n: Control) -> void:
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in n.get_children():
		if child is Control:
			_ignore_hits(child as Control)
