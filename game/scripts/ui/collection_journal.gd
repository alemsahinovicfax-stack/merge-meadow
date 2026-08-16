extends Control

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")
const TEXT_LAYOUT := preload("res://scripts/ui/ui_text_layout.gd")

@onready var summary_label: Label = $RootVBox/SummaryLabel
@onready var title_label: Label = $RootVBox/TopBar/TitleLabel
@onready var list_scroll: ScrollContainer = $RootVBox/ListScroll
@onready var list: VBoxContainer = $RootVBox/ListScroll/List
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton
@onready var root_vbox: VBoxContainer = $RootVBox


func _ready() -> void:
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_button.clicked.connect(_on_back_pressed)
	_setup_typography()
	GameState.mark_collection_journal_viewed()
	_refresh()


func _setup_typography() -> void:
	if title_label:
		TEXT_LAYOUT.screen_title(title_label)
	if summary_label:
		TEXT_LAYOUT.card_title_scroll(summary_label)
		summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if root_vbox:
		SAFE_AREA.apply_top_margin(root_vbox, 8.0)
		SAFE_AREA.apply_bottom_margin(root_vbox, 8.0)


func _refresh() -> void:
	if summary_label:
		summary_label.text = GameState.format_collection_journal_summary()
	if title_label:
		var frame_id := GameState.get_equipped_cosmetic(CosmeticCatalog.SLOT_JOURNAL_FRAME)
		title_label.add_theme_color_override(
			"font_color",
			CosmeticCatalog.get_journal_title_color(frame_id)
		)
	_rebuild_list()


func _rebuild_list() -> void:
	if list == null:
		return
	for child in list.get_children():
		list.remove_child(child)
		child.queue_free()
	for entry in GameState.get_collection_journal_entries():
		var row := JournalRow.new()
		list.add_child(row)
		row.apply(entry)


func _on_back_pressed() -> void:
	if GameState.meta_hub_active:
		GameState.go_to_meta_page(MetaHubPages.CAMP)
	else:
		SceneRouter.change_to(GameState.SCENE_CAMP)


func set_meta_hub_mode(enabled: bool) -> void:
	if back_button:
		back_button.visible = not enabled


func refresh_for_meta_hub() -> void:
	_refresh()
