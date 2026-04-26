class_name Level extends Node2D

##for handling the editing of properties
var layerPropertiesHandler: LayerPropertiesHandler
##Layer scene
const LAYER = preload("uid://j4eyk5hksqrt")

##how much below the texture is the actual bottomless pit rather than the texture indicator
#const bottomTextureOffset = 0
var roomBottom:int = 720
var bgColor1:Color = Color(0.97, 0.81, 1.0)
var bgColor2:Color = Color(0.769, 0.746, 0.995)

@export var roomManager:RoomManager ##manages room

#var rooms = [{"layers":{0:{"objects":{}} ,1:{"objects":{}}}  }]
var rooms = [{ "layers":{} }]
var layers:Dictionary[int,LevelLayer] = {} ##Dictionary that holds the layer ID and the corresponding layer's node

#resets this and all other rooms to the default values
func resetRooms():
	rooms = [{ "layers":{} }]
	roomBottom = 720
	bgColor1 = Color(0.97, 0.81, 1.0)
	bgColor2 = Color(0.769, 0.746, 0.995)
	roomManager.setProperty("roomBottom",roomBottom,true)
	roomManager.setProperty("bgColor1",bgColor1,true)
	roomManager.setProperty("bgColor2",bgColor2,true)


func _ready() -> void:
#	find all layers and store them in the layers dictionary
	collectChildren()
	signalBus.onLevelReady.emit(self)
	signalBus.updateLayerProperty.connect(setLayerProperty)
	signalBus.moveLayerUp.connect(moveLayerUp)
	signalBus.moveLayerDown.connect(moveLayerDown)
	signalBus.addLayerAbove.connect(addLayerAbove)
	signalBus.addLayerBelow.connect(addLayerBelow)
	signalBus.deleteLayer.connect(deleteLayer)

##corrects a bug where currentLayer would be set to a nonexistent layer
func clampLayer():
	if globalEditor.currentLayer <= layers.keys().min() and layers.keys().min()!=0:
		globalEditor.currentLayer=layers.keys().min()+1
	if globalEditor.currentLayer >= layers.keys().max() and layers.keys().max()!=0:
		globalEditor.currentLayer=layers.keys().max()-1
##adds a layer at the very top, since only the top layer has this button
func addLayerAbove(layerID):
	storeTempProperties()
	var newLayer = LAYER.instantiate()
	add_child(newLayer)
	move_child(newLayer,layers[layerID].get_index())
	refreshEverything()
##adds a layer below the givel layerID's layer
func addLayerBelow(layerID):
	storeTempProperties()
	if layerID > globalEditor.currentLayer:
		globalEditor.currentLayer-=1
	var newLayer = LAYER.instantiate()
	layers[layerID].add_sibling(newLayer)
	refreshEverything()
func deleteLayer(layerID):
	storeTempProperties()
	if layerID == globalEditor.currentLayer: #making sure we don't have a nonexistant layer selected after this
		globalEditor.currentLayer = 0
	clampLayer()
	
	var layerToDelete = layers[layerID]
	layerToDelete.queue_free()
	remove_child(layerToDelete) #apparently queue_free sometimes keeps the node as a null child
	layers.erase(layerID)
	refreshEverything()
##Moves a layer up one step, adapting the indices so that layer 0 is always the same, and updates data structures and ui
func moveLayerUp(layerID):
	globalEditor.currentLayer+= (2 if layerID==-1 else 1) if layerID==globalEditor.currentLayer else 0
	#fixes a bug where currentLayer would be set to a nonexistent layer
	#if globalEditor.currentLayer <= layers.keys().min():
		#globalEditor.currentLayer=layers.keys().min()+1
	clampLayer()
		
	storeTempProperties()
	#	get the layer node's index position relative to its siblings
	var targetNodeIndex:int
	targetNodeIndex = layers[layerID+1].get_index()
	move_child(layers[layerID],targetNodeIndex)
	#signalBus.updateLayerUI.emit()
	refreshEverything()
func moveLayerDown(layerID):
	globalEditor.currentLayer-= (2 if layerID==1 else 1) if layerID==globalEditor.currentLayer else 0
	#fixes a bug where currentLayer would be set to a nonexistent layer
	if globalEditor.currentLayer >= layers.keys().max():
		globalEditor.currentLayer=layers.keys().max()-1
	clampLayer()
	
	storeTempProperties()
	#	get the layer node's index position relative to its siblings
	var targetNodeIndex:int
	targetNodeIndex = layers[layerID-1].get_index()
	move_child(layers[layerID],targetNodeIndex)
	#signalBus.updateLayerUI.emit()
	refreshEverything()
func storeTempProperties(): ##stores all of a layer's properties in a variable in the node temporarily because an operation is expected to alter this layer
	for i in layers: #store properties from rooms
		layers[i].tempProperties = rooms[globalEditor.currentRoom]["layers"][i]
func restoreTempProperties(): ##restores all of a layer's properties from a variable in the node after changes are made to the layer
	for i in layers: #restore properties into rooms
		if layers[i].tempProperties != {}:
			rooms[globalEditor.currentRoom]["layers"][i] = layers[i].tempProperties
##updates all data structures
func refreshEverything():
	updateChildren()
	collectChildren()
	restoreTempProperties()
	if globalEditor.isObjectBeingEdited:
		signalBus.populateLayersUI.emit(layerPropertiesHandler) #refresh the UI to show new layer positions

##swaps the keys between any 2 dictionaries
func swapDictKeys(dict, key1, key2):
	var temp = dict[key1]
	dict[key1] = dict[key2]
	dict[key2] = temp

##adjusts indexes and the rooms structure according to how they would be if the selected layer indexes were swapped
func swapLayers(idx1, idx2):
	swapDictKeys(rooms[globalEditor.currentRoom]["layers"],idx1,idx2)

##looks for and collects children layers to the rooms structure and the layers variable
func collectChildren():
	rooms[globalEditor.currentRoom]["layers"]={}
	layers = {}
	for i in get_children():
		if i is LevelLayer:
			layers[i.index] = i 
			rooms[globalEditor.currentRoom]["layers"][i.index]={"objects":{},"layerProperties":{}}
		if i is RoomManager:
			roomBottom = i.global_position.y

##when changes are made, tries to update the children's indeces
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

func setLayerProperty(property:String, value, layerID):
	if !layers.has( layerID ):
		printerr("Error: no layer of id ",layerID)
		return -1
	#globalEditor.getCurrentLevelLayerDict()["objects"][ instanceID ]["properties"][property] = value
	getCurrentRoomDict()["layers"][layerID]["layerProperties"][property]=value
	if property == "scroll_scale":
		signalBus.shimmyCamera.emit()
	layers[layerID].set(property, value)

func _on_layers_button_pressed() -> void:
	signalBus.populateLayersUI.emit(layerPropertiesHandler)
