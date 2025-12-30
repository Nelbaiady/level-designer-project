extends PropertyEditor

#var minValue: float
#var maxValue: float
#
#var value:float = 0
#var propertyName: String
#@onready var label: Label = $HBoxContainer/Label
#@onready var valueNode = $HBoxContainer/ValueSpinBox


func _ready() -> void:
	valueNodes = [$HBoxContainer/ValueSpinBox]

#func updateValue():
	#valueNodes[0].value = value

func _on_value_spin_box_value_changed(newValue: float) -> void:
	value = newValue
	signalBus.updateProperty.emit(propertyName, value)
	signalBus.spinboxSpun.emit()
