class_name PropertyEditor extends Panel

var value
var minValue: float
var maxValue: float
var hasMin:bool
var hasMax:bool
var step: float
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

##function triggered when the node is created. Sets up everything.
func setStartValues(val, minVal, maxVal, stp, propName, labelText, hasMinVal=false,hasMaxVal=false, data=[]):
	dealWithData(data)
	value=val
	minValue=minVal
	maxValue=maxVal
	hasMin = hasMinVal
	hasMax = hasMaxVal
	step = stp
	propertyName=propName
	label.text = labelText
	propertyReadySignal.connect(propertyReady)
	propertyReadySignal.emit()
#virtual function
func propertyReady():
	if len(valueNodes)==1 and ("value" in valueNodes[0]):
		valueNodes[0].value = value
#	if a min and max value are set, make sure the ui input reflects that
	#if (minValue!=null and maxValue!=null) and (minValue!=0 and maxValue!=0):
	for i in valueNodes:
		if hasMin:
			i.min_value = minValue
		if hasMax:
			i.max_value = maxValue
		if i is SpinBox:
			i.allow_greater = !hasMax
			i.allow_lesser = !hasMin
#	prevent these things from being selectable
	for i in valueNodes:
		if i is SpinBox:
			i.get_line_edit().focus_mode = Control.FOCUS_CLICK
	if step != 0:
		for i in valueNodes:
			#if i is SpinBox:
			i.custom_arrow_step = step

func updateValue():
	valueNodes[0] = value
	#valueNodes[0].focus_mode = Control.FOCUS_CLICK

func emitUpdate():
	signalBus.updateProperty.emit(propertyName, value)

func dealWithData(_data):
	pass
