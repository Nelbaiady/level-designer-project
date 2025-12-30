extends PropertyEditor

#var minValue: float
#var maxValue: float
#
#var value:Color = Color.WHITE
#var propertyName: String
#@onready var label: Label = $HBoxContainer/Label

#@onready var valueNode = $HBoxContainer/ColorPickerButton

func _ready() -> void:
	valueNodes = [$HBoxContainer/ColorPickerButton]
func updateValue():
	valueNodes[0].color = value

func propertyReady():
	valueNodes[0].color = value

func _on_color_picker_button_color_changed(color: Color) -> void:
	value = color
	signalBus.updateProperty.emit(propertyName, value)

func _on_color_picker_button_pressed() -> void:
	#signalBus.colorPickerToggled.emit(true)
	globalEditor.colorPickerPopupIsOpen = true
	print("color picker opened")

func _on_color_picker_button_popup_closed() -> void:
	#signalBus.colorPickerToggled.emit(false)
	globalEditor.colorPickerPopupIsOpen = false
	print("color picker closed")
