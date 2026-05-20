class_name ObjectInstance extends ThingWithProperties
func _ready():
	super()
	signalBus.placeObjectSignal.connect(setStartingStuff)
	signalBus.eraseSpecificObject.connect(checkErase)
	signalBus.eraseObject.connect(checkErase)	
	

func getProperty(property:String):
	if getObjectFromLevelStruct()["properties"].has(property):
		return getObjectFromLevelStruct()["properties"][property]
	else:
		return super(property)

func setProperty(property:String, value, tween = false):
	super(property,value,tween)
	getObjectFromLevelStruct()["properties"][property] = value

func checkErase(id=-1):
	if id !=-1:
		if id != -1 and id == instanceID:
			eraseSelf()
	elif isMouseOver and globalEditor.currentLayer==layer.index:
		system.undoRedo.add_undo_method(globalEditor.placeObject.bind(globalEditor.itemRoster[rosterID], rootNode.position, getSelfFromLevelStruct().properties, instanceID))
		system.undoRedo.add_do_method(globalEditor.eraseSpecificObject.bind(instanceID))
		eraseSelf()
		
func getSelfFromLevelStruct():
	return globalEditor.level.rooms[globalEditor.currentRoom].layers[layer.index].objects[instanceID]
	
func eraseSelf():
	if isBeingEdited: signalBus.hidePropertiesSidebar.emit()
	globalEditor.freedObjectIndicesStack.push_back(instanceID)
	globalEditor.getCurrentLevelLayerDict()["objects"].erase(instanceID)
	rootNode.queue_free()
	
func getObjectFromLevelStruct() -> Dictionary: 
	return globalEditor.getCurrentLevelRoomDict()["layers"][layer.index]["objects"][ instanceID ]
