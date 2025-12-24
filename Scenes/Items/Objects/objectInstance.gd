extends Node2D

@export var clickCollision:Area2D
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]
#var propertyUiElements = []
enum Categories {gizmo, npc, decoration}
@export var category: Categories
var rootNode:Node 
var isBeingEdited = false
var isMouseOver:bool = false
var rosterID:int
var instanceID:int = -1

func _ready() -> void:
	rootNode= get_parent()
	signalBus.placeObjectSignal.connect(setStartingStuff)
	if !clickCollision:
		printerr("Object ",rootNode.name, " instance number ", instanceID, " has no click collision")
	else:
		clickCollision.input_event.connect(clickedOn)
		clickCollision.mouse_entered.connect(mouseEntered)
		clickCollision.mouse_exited.connect(mouseExited)
		signalBus.eraseObject.connect(checkErase)

func setStartingStuff(instID, obj, loadedProperties:Dictionary):
	if obj == rootNode:
		instanceID = instID
		if loadedProperties:
			for i in loadedProperties:
				setProperty(i,loadedProperties[i])
	rosterID = globalEditor.objectsHash[instanceID]["rosterID"]
	signalBus.placeObjectSignal.disconnect(setStartingStuff)

func _physics_process(_delta: float) -> void:
	pass

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value):
	if property == "scale":
		value = abs(value)
	globalEditor.objectsHash[ instanceID ]["properties"][property] = value
	rootNode.set(property, value )

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		summonPropertiesUI()
		signalBus.editingObject.emit(globalEditor.itemRoster[rosterID].name,instanceID)
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickLeft"):
		if globalEditor.currentTool == globalEditor.Tools.erase:
			eraseSelf()

func summonPropertiesUI():
	populatePropertiesUI()

func populatePropertiesUI():
	signalBus.showPropertiesSidebar.emit()
#	Empty the UI first
	for i in globalEditor.propertiesUI.get_children():
		i.queue_free()
	#propertyUiElements.clear()
#	tell the editor to focus on this object
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = self
	isBeingEdited = true
#	populate the properties editor
	for i in properties:
		var newNode = i.uiNode.instantiate()
		#propertyUiElements.append(newNode)
		globalEditor.propertiesUI.add_child(newNode)
		newNode.label.text = i.displayName
		newNode.propertyName = i.codeName
		newNode.value = getProperty(i.codeName)
		newNode.updateValue()
	signalBus.updateProperty.connect(setProperty)

func mouseEntered():
	isMouseOver = true
func mouseExited():
	isMouseOver = false

func setNotEditing():
	isBeingEdited = false
	#propertyUiElements.clear()
	signalBus.updateProperty.disconnect(setProperty)

func checkErase():
	if isMouseOver:
		eraseSelf()
func eraseSelf():
	rootNode.queue_free()
