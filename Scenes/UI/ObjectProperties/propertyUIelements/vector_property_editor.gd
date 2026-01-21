class_name VectorPropertyEditor extends PropertyEditor

func propertyReady():
	super()
	valueNodes[0].value = value.x
	valueNodes[1].value = value.y
	#if (minValue!=null and maxValue!=null) and (minValue!=0 and maxValue!=0):
		#for i in valueNodes:
			#i.min_value = minValue
			#i.max_value = maxValue
	#for i in valueNodes:
		#if i is SpinBox:
			#i.get_line_edit().focus_mode = Control.FOCUS_CLICK

func _ready() -> void:
	valueNodes = [$HBoxContainer/xValueSpinBox, $HBoxContainer/yValueSpinBox]

func updateValue():
	valueNodes[0].value = value.x
	valueNodes[1].value = value.y
	
func _on_x_value_spin_box_value_changed(newValue: float) -> void:
	value.x = newValue
	#signalBus.updateProperty.emit(propertyName, value)
	emitUpdate()
	signalBus.spinboxSpun.emit()

func _on_y_value_spin_box_value_changed(newValue: float) -> void:
	value.y = newValue
	#signalBus.updateProperty.emit(propertyName, value)
	emitUpdate()
	signalBus.spinboxSpun.emit()
