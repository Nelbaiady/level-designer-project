extends PropertyEditor


#var value:String = ""
#var propertyName: String
#@onready var label: Label = $HBoxContainer/Label
#@onready var valueNode = $HBoxContainer/LineEdit

func _ready() -> void:
	valueNodes = [$HBoxContainer/LineEdit]
	valueNodes[0].text = value
#func updateValue():
	#valueNodes[0].text = value

func _on_line_edit_text_changed(new_text: String) -> void:
	value = new_text
	signalBus.updateProperty.emit(propertyName, value)
