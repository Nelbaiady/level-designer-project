class_name CheckBoxPropertyEditor extends PropertyEditor

func _ready() -> void:
	valueNodes = [$HBoxContainer/CheckBox]
func propertyReady():
	super()
	if globalEditor.isEditing:
		valueNodes[0].button_pressed = value

func _on_check_box_pressed() -> void:
	value = !value
	valueNodes[0].button_pressed = value
	emitUpdate()
