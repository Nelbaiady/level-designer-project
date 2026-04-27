class_name LayerScrollScalePropertyEditor extends VectorPropertyEditor 
var layerIndex
func emitUpdate():
	signalBus.updateLayerProperty.emit(property.codeName, value, layerIndex)

##in this case, dealWithData sets the layer index to that of the layerEditor node
func dealWithData(_data):
	layerIndex = _data[0]
