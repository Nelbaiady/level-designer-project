extends Panel

var value:String = ""
var propertyName: String
@onready var label: Label = $HBoxContainer/Label
@onready var valueNode = $HBoxContainer/LineEdit

func _ready() -> void:
	valueNode.text = value
func updateValue():
	valueNode.text = value

func _on_line_edit_text_changed(new_text: String) -> void:
	value = new_text
	signalBus.updateProperty.emit(propertyName, value)
