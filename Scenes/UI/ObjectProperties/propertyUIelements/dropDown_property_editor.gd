class_name DropDownPropertyEditor extends PropertyEditor

func _ready() -> void:
	valueNodes = [$HBoxContainer/OptionButton]



func dealWithData(_data):

	var index:=0
	for i in property.choices:
		#if the property is a texture
		if property.choices[i].begins_with("uid://"):
			valueNodes[0].add_icon_item(load(property.choices[i]),i)
			#if the object's current value is the same as the one in the current loop, select it in the dropdown
			if property.choices[i] == str(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(value.resource_path))):
				$HBoxContainer/OptionButton.select(index)
				pass
		elif i is String:
			valueNodes[0].add_item(i)
		valueNodes[0].set_item_metadata(index,property.choices[i])
		index+=1
		

func _on_option_button_item_selected(index: int) -> void:
	value = load(valueNodes[0].get_item_metadata(index))
	emitUpdate()
