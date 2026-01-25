class_name VectorPropertyEditor extends PropertyEditor

func propertyReady():
	super()
	valueNodes[0].value = value.x
	valueNodes[1].value = value.y

func _ready() -> void:
	valueNodes = [$HBoxContainer/xValueSpinBox, $HBoxContainer/yValueSpinBox]

func updateValue():
	valueNodes[0].value = value.x
	valueNodes[1].value = value.y
	
func _on_x_value_spin_box_value_changed(newValue: float) -> void:
	value.x = newValue
	emitUpdate()
	signalBus.spinboxSpun.emit()

func _on_y_value_spin_box_value_changed(newValue: float) -> void:
	value.y = newValue
	emitUpdate()
	signalBus.spinboxSpun.emit()
