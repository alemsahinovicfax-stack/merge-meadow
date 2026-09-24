extends VBoxContainer

## Field title — season name + tagline. Not a button (MOUSE_FILTER_IGNORE).

var label_text: String = "":
	set(value):
		label_text = value
		_apply()

var tagline_text: String = "":
	set(value):
		tagline_text = value
		_apply()

@onready var _name_label: Label = get_node_or_null("NameLabel") as Label
@onready var _tag_label: Label = get_node_or_null("Tagline") as Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply()


func _apply() -> void:
	if _name_label:
		_name_label.text = label_text
		_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _tag_label:
		_tag_label.text = tagline_text
		_tag_label.visible = not tagline_text.is_empty()
		_tag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
