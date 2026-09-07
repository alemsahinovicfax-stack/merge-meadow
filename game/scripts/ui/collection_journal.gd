extends Control

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")

const ROWS_PER_FRAME := 6

@onready var summary_label: Label = $RootVBox/SummaryLabel
@onready var title_label: Label = $RootVBox/TopBar/TitleLabel
@onready var list_scroll: ScrollContainer = $RootVBox/ListScroll
@onready var list: VBoxContainer = $RootVBox/ListScroll/List
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton
@onready var root_vbox: VBoxContainer = $RootVBox

var _pending_entries: Array[Dictionary] = []
var _build_index: int = 0
var _building: bool = false


func _ready() -> void:
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_button.clicked.connect(_on_back_pressed)
	_setup_typography()
	set_process(false)
	_refresh_chrome()
	if GameState.is_meta_hub_embedded(self):
		_start_list_build()
		return
	GameState.mark_collection_journal_viewed()
	_start_list_build()


func _process(_delta: float) -> void:
	if not _building or list == null:
		set_process(false)
		return
	var n := 0
	while n < ROWS_PER_FRAME and _build_index < _pending_entries.size():
		var row := JournalRow.new()
		list.add_child(row)
		row.apply(_pending_entries[_build_index])
		_build_index += 1
		n += 1
	if _build_index >= _pending_entries.size():
		_building = false
		set_process(false)


func _setup_typography() -> void:
	if title_label:
		TEXT_LAYOUT.screen_title(title_label)
	if summary_label:
		TEXT_LAYOUT.card_title_scroll(summary_label)
		summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if root_vbox:
		SAFE_AREA.apply_top_margin(root_vbox, 8.0)
		SAFE_AREA.apply_bottom_margin(root_vbox, 8.0)


func _refresh_chrome() -> void:
	if summary_label:
		summary_label.text = GameState.format_collection_journal_summary()
	if title_label:
		var frame_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_JOURNAL_FRAME)
		title_label.add_theme_color_override(
			"font_color",
			CosmeticCatalog.get_journal_title_color(frame_id)
		)


func _clear_list() -> void:
	if list == null:
		return
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()


func _start_list_build() -> void:
	_pending_entries = GameState.get_collection_journal_entries()
	_build_index = 0
	_clear_list()
	_building = true
	set_process(true)


func _apply_entries_in_place() -> void:
	var entries := GameState.get_collection_journal_entries()
	if list == null:
		return
	if list.get_child_count() != entries.size():
		_start_list_build()
		return
	for i in entries.size():
		var row := list.get_child(i)
		if row.has_method("apply"):
			row.call("apply", entries[i])


func refresh_for_meta_hub() -> void:
	GameState.mark_collection_journal_viewed()
	_refresh_chrome()
	if _building:
		return
	if list and list.get_child_count() > 0:
		_apply_entries_in_place()
	else:
		_start_list_build()


func _on_back_pressed() -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.CAMP)
	else:
		SceneRouter.change_to(GameState.SCENE_CAMP)


func set_meta_hub_mode(enabled: bool) -> void:
	if back_button:
		back_button.visible = not enabled
