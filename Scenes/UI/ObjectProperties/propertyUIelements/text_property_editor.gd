class_name TextPropertyEditor extends PropertyEditor


func _ready() -> void:
	valueNodes = [$HBoxContainer/LineEdit]
	valueNodes[0].text = value
	
func _input(event: InputEvent):
	#when the player clicks away, the texbox is unfocuses
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickLeft"):
		if !Rect2(Vector2(0,0), size).has_point(make_input_local(event).position):
			release_focus()

func _on_line_edit_text_changed(new_text: String) -> void:
	value = new_text
	#signalBus.updateProperty.emit(propertyName, value)
	emitUpdate()
