extends Control

const JournalRow := preload("res://scripts/ui/collection_journal_row.gd")
const SAFE_AREA := preload("res://scripts/ui/safe_area_helper.gd")

@onready var summary_label: Label = $RootVBox/SummaryLabel
@onready var title_label: Label = $RootVBox/TopBar/TitleLabel
@onready var list_scroll: ScrollContainer = $RootVBox/ListScroll
@onready var list: VBoxContainer = $RootVBox/ListScroll/List
@onready var back_button: UiClickButton = $RootVBox/TopBar/BackButton


func _ready() -> void:
	$Bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_button.clicked.connect(_on_back_pressed)
	if list_scroll:
		list_scroll.resized.connect(_sync_list_width)
	GameState.mark_collection_journal_viewed()
	_refresh()


func _sync_list_width() -> void:
	if list and list_scroll:
		list.custom_minimum_size.x = list_scroll.size.x


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
	call_deferred("_sync_list_width")


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
	SceneRouter.change_to(GameState.SCENE_CAMP)
