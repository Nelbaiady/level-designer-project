extends Panel

var value:Color = Color.WHITE
var propertyName: String
@onready var label: Label = $HBoxContainer/Label
@onready var valueNode = $HBoxContainer/ColorPickerButton

func _ready() -> void:
	valueNode.color = value
func updateValue():
	valueNode.color = value
	
func _on_color_picker_button_color_changed(color: Color) -> void:
	value = color
	globalEditor.updateProperty.emit(propertyName, value)
