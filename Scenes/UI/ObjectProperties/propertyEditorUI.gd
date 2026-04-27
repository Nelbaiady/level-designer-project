##This script handles the interface of an entry on the properties sidebar that edits a single property.
class_name PropertyEditor extends Panel

var value
#var minValue: float
#var maxValue: float
#var hasMin:bool
#var hasMax:bool
#var step: float
#var propertyName: String ##the property's in-code name
var property: ObjectProperty
#display name label
@onready var label: Label = $HBoxContainer/Label
#ui nodes the player will be editing
#the interface nodes the value is  from. This differs for each property editor
@onready var valueNodes = []

#signal for the subclass to start setting up
signal propertyReadySignal()


##function triggered when the node is created. Sets up everything.
func setStartValues(startVal, prop:ObjectProperty=null, data=[]):
	property = prop
	dealWithData(data)
	value=startVal
	#minValue=minVal
	#maxValue=maxVal
	#hasMin = hasMinVal
	#hasMax = hasMaxVal
	#step = stp
	#propertyName=propName
	#label.text = labelText
	label.text = prop.displayName
	propertyReadySignal.connect(propertyReady)
	propertyReadySignal.emit()
#virtual function
func propertyReady():
	if len(valueNodes)==1 and ("value" in valueNodes[0]) and globalEditor.isEditing:
		valueNodes[0].value = value
#	if a min and max value are set, make sure the ui input reflects that
	#if (minValue!=null and maxValue!=null) and (minValue!=0 and maxValue!=0):
	for i in valueNodes:
		#if hasMin:
		if property.hasMin:
			#i.min_value = minValue
			i.min_value = property.minValue
		#if hasMax:
		if property.hasMax:
			i.max_value = property.maxValue
			#i.max_value = maxValue
		if i is SpinBox:
			#i.allow_greater = !hasMax
			#i.allow_lesser = !hasMin
			i.allow_greater = !property.hasMax
			i.allow_lesser = !property.hasMin
#	prevent these things from being selectable
	for i in valueNodes:
		if i is SpinBox:
			i.get_line_edit().focus_mode = Control.FOCUS_CLICK
	#if step != 0:
	if property.step != 0:
		for i in valueNodes:
			#i.custom_arrow_step = step
			i.custom_arrow_step = property.step

func updateValue():
	valueNodes[0] = value
	#valueNodes[0].focus_mode = Control.FOCUS_CLICK

func emitUpdate():
	signalBus.updateProperty.emit(property.codeName, value)

func dealWithData(_data):
	pass
