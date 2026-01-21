class_name LayerCheckBoxPropertyEditor extends CheckBox

var layerIndex
var value = false

func _ready() -> void:
	value = (layerIndex==globalEditor.currentLayer)
	signalBus.selectLayer.connect(updateValue)

func updateValue(newLayer):
	value = (layerIndex==newLayer)
	button_pressed = value

func _on_pressed() -> void:
	globalEditor.currentLayer = layerIndex
	signalBus.selectLayer.emit(layerIndex)
