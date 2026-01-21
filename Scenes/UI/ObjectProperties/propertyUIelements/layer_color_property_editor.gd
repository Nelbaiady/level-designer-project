class_name LayerColorPropertyEditor extends ColorPropertyEditor 
var layerIndex
func emitUpdate():
	signalBus.updateLayerProperty.emit(propertyName, value, layerIndex)

func dealWithData(_data):
	layerIndex = _data[0]
