class_name PropertyEditor extends Panel

var value
var minValue: float
var maxValue: float
#the property's in-code name
var propertyName: String
#display name label
@onready var label: Label = $HBoxContainer/Label
#ui nodes the player will be editing
#the interface nodes the value is changed from. This differs for each property editor
@onready var valueNodes = []

#signal for the subclass to start setting up
signal propertyReadySignal()
#signal setStartValuesSignal(value, minValue, maxValue, propertyName, labelText)
#setStartValuesSignal.connect(setStartValues)
#func _ready() -> void:

#function triggered when the node is created. Sets up everything.
func setStartValues(val, minVal, maxVal, propName, labelText):
	value=val
	minValue=minVal
	maxValue=maxVal
	propertyName=propName
	label.text = labelText
	print("maxvalue in ",propertyName, " is", maxValue)
	propertyReadySignal.connect(propertyReady)
	propertyReadySignal.emit()
#virtual function
func propertyReady():
	valueNodes[0].value = value
#	if a min and max value are set, make sure the ui input reflects that
	if (minValue!=null and maxValue!=null) and (minValue!=0 and maxValue!=0):
		for i in valueNodes:
			i.min_value = minValue
			i.max_value = maxValue
#	prevent these things from being selectable
	for i in valueNodes:
		if i is SpinBox:
			i.get_line_edit().focus_mode = Control.FOCUS_CLICK

func updateValue():
	valueNodes[0] = value
	#valueNodes[0].focus_mode = Control.FOCUS_CLICK
