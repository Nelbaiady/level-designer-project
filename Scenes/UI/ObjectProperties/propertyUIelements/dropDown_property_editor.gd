class_name DropDownPropertyEditor extends PropertyEditor

var optionen = {}

func _ready() -> void:
	valueNodes = [$HBoxContainer/OptionButton]
	#valueNodes[0]
	#$HBoxContainer/OptionButton.add_icon_item(preload("uid://b1kn3s452k3i3"),"curr")

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


#func propertyReady():
	#super()
	#if globalEditor.isEditing:
		#valueNodes[0].button_pressed = value

#func _on_check_box_pressed() -> void:
	#value = !value
	#valueNodes[0].button_pressed = value
	#emitUpdate()
