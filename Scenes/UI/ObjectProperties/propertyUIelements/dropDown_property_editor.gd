class_name DropDownPropertyEditor extends PropertyEditor

func _ready() -> void:
	valueNodes = [$HBoxContainer/OptionButton]

	#valueNodes[0]
	#$HBoxContainer/OptionButton.add_icon_item(preload("uid://b1kn3s452k3i3"),"curr")

func dealWithData(_data):
	var index:=0
	for i in property.choices:
		if property.choices[i].begins_with("uid://"):
			valueNodes[0].add_icon_item(load(property.choices[i]),i)
		elif i is String:
			valueNodes[0].add_item(i)
		valueNodes[0].set_item_metadata(index,property.choices[i])
		index+=1

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

#func propertyReady():
	#super()
	#if globalEditor.isEditing:
		#valueNodes[0].button_pressed = value

func _on_option_button_item_selected(index: int) -> void:
	value = load($HBoxContainer/OptionButton.get_item_metadata(index))
	emitUpdate()
