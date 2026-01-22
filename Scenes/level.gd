class_name Level extends Node2D

##for handling the editing of properties
var propertiesHandler: PropertiesHandler

#var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"objects":{}} ,1:{"objects":{}}}  }]
var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{}  }]
var layers:Dictionary[int,LevelLayer] = {}
func _ready() -> void:
#	find all layers and store them in the layers dictionary
	collectChildren()
	signalBus.onLevelReady.emit(self)
	signalBus.updateLayerProperty.connect(setProperty)
	

##swaps the keys between any 2 dictionaries
func swapDictKeys(dict, key1, key2):
	var temp = dict[key1]
	dict[key1] = dict[key2]
	dict[key2] = temp

##adjusts indexes and the rooms structure according to how they would be if the selected layer indexes were swapped
func swapLayers(idx1, idx2):
	swapDictKeys(rooms[globalEditor.currentRoom]["layers"],idx1,idx2)

#looks for and collects children layers to the rooms structure and the layers variable
func collectChildren():
	rooms[globalEditor.currentRoom]["layers"]={}
	layers = {}
	for i in get_children():
		if i is LevelLayer:
			layers[i.index] = i 
			rooms[globalEditor.currentRoom]["layers"][i.index]={"objects":{},"layerProperties":{}}
			
func getCurrentRoomDict():
	return rooms[globalEditor.currentRoom]
func getCurrentLayerDict():
	return rooms[globalEditor.currentRoom]["layers"][globalEditor.currentLayer]

func setProperty(property:String, value, layerID):
	if !layers.has( layerID ):
		printerr("Error: no layer of id ",layerID)
		return -1
	#globalEditor.getCurrentLevelLayerDict()["objects"][ instanceID ]["properties"][property] = value
	getCurrentRoomDict()["layers"][layerID]["layerProperties"][property]=value
	layers[layerID].set(property, value)

func _on_layers_button_pressed() -> void:
	#globalEditor.propertiesSidebar.populateLayersUI(propertiesHandler)
	signalBus.populateLayersUI.emit(propertiesHandler)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("0"):
		print(getCurrentLayerDict())
