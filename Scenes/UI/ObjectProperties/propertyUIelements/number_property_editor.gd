extends Panel

var value:Vector2 = Vector2.ONE
var propertyName: String
@onready var label: Label = $HBoxContainer/Label
@onready var valueNode = $HBoxContainer/xValueSpinBox


func _ready() -> void:
	valueNode.value = value.x
func updateValue():
	valueNode.value = value.x

func _on_value_spin_box_value_changed(newValue: float) -> void:
	value.x = newValue
	signalBus.updateProperty.emit(propertyName, value)
	signalBus.spinboxSpun.emit()
