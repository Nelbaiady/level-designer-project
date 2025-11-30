extends Panel

var value:Vector2 = Vector2.ONE
var propertyName: String
@onready var label: Label = $HBoxContainer/Label
@onready var xValueNode = $HBoxContainer/xValueSpinBox
@onready var yValueNode = $HBoxContainer/yValueSpinBox

func _ready() -> void:
	xValueNode.value = value.x
	yValueNode.value = value.y
func updateValue():
	#print(value)
	xValueNode.value = value.x
	yValueNode.value = value.y
func _on_x_value_spin_box_value_changed(newValue: float) -> void:
	value.x = newValue
	globalEditor.updateProperty.emit(propertyName, value)

func _on_y_value_spin_box_value_changed(newValue: float) -> void:
	value.y = newValue
	globalEditor.updateProperty.emit(propertyName, value)
