class_name NumberPropertyEditor extends PropertyEditor


func _ready() -> void:
	valueNodes = [$HBoxContainer/ValueSpinBox]


func _on_value_spin_box_value_changed(newValue: float) -> void:
	
	value = newValue
	#signalBus.updateProperty.emit(propertyName, value)
	emitUpdate()
	signalBus.spinboxSpun.emit()
