class_name Level extends Node2D

##for handling the editing of properties
var propertiesHandler: PropertiesHandler

#var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{0:{"objects":{}} ,1:{"objects":{}}}  }]
var rooms = [{"backgroundColor":Color.FLORAL_WHITE,"layers":{}  }]
var layers:Dictionary[int,LevelLayer] = {} ##Dictionary that holds the layer ID and the corresponding layer's node
func _ready() -> void:
#	find all layers and store them in the layers dictionary
	collectChildren()
	signalBus.onLevelReady.emit(self)
	signalBus.updateLayerProperty.connect(setProperty)
	signalBus.moveLayerUp.connect(moveLayerUp)
	signalBus.moveLayerDown.connect(moveLayerDown)

##Moves a layer up one step, adapting the indices so that layer 0 is always the same, and updates data structures and ui
func moveLayerUp(layerID):
	globalEditor.currentLayer+= (2 if layerID==-1 else 1) if layerID==globalEditor.currentLayer else 0
	for i in layers: #store properties from rooms
		layers[i].tempProperties = rooms[globalEditor.currentRoom]["layers"][i]
	#	get the layer node's index position relative to its siblings
	var targetNodeIndex:int
	targetNodeIndex = layers[layerID+1].get_index()
	move_child(layers[layerID],targetNodeIndex)
	#signalBus.updateLayerUI.emit()
	updateChildren()
	collectChildren()
	for i in layers: #restore properties into rooms
		rooms[globalEditor.currentRoom]["layers"][i] = layers[i].tempProperties
	signalBus.populateLayersUI.emit(propertiesHandler) #refresh the UI to show new layer positions

func moveLayerDown(layerID):
	globalEditor.currentLayer-= (2 if layerID==1 else 1) if layerID==globalEditor.currentLayer else 0
	for i in layers: #store properties from rooms
		layers[i].tempProperties = rooms[globalEditor.currentRoom]["layers"][i]
	#	get the layer node's index position relative to its siblings
	var targetNodeIndex:int
	targetNodeIndex = layers[layerID-1].get_index()
	move_child(layers[layerID],targetNodeIndex)
	#signalBus.updateLayerUI.emit()
	updateChildren()
	collectChildren()
	for i in layers: #restore properties into rooms
		rooms[globalEditor.currentRoom]["layers"][i] = layers[i].tempProperties
	signalBus.populateLayersUI.emit(propertiesHandler) #refresh the UI to show new layer positions

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

#when changes are made, tries to update the children's indexes
func updateChildren():
	var children = get_children()
	var zeroDepthTop := 0 ##how deep in is layer 0 from the top
	var passedByZero := false
	#first loop to count layers above and below layer 0
	for i in children:
		if i is LevelLayer:
			if i.index==0:
				passedByZero = true
			else:
				zeroDepthTop += 1 if !passedByZero else 0
	passedByZero = false
	var distanceBottom = 0 #when descending below layer 0 keep track of if we reached the bottom layer
	#second loop to update indices
	for i in children:
		if i is LevelLayer:
			if i.index==0:
				passedByZero = true
			else:
				if passedByZero:
					distanceBottom -= 1
					i.index = distanceBottom
				else:
					i.index = zeroDepthTop
					zeroDepthTop -=1

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
