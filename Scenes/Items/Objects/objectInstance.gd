class_name ObjectInstance extends Node2D

@onready var selectionParticles: GPUParticles2D = $selectionParticles
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
var layer:LevelLayer

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
		signalBus.editingObject.connect(objectEditingStarted)
		signalBus.hidePropertiesSidebar.connect(objectEditingStopped)
		signalBus.startEditMode.connect(editModeStarted)
		#signalBus.startPlayMode.connect(playModeStarted)

##outline when selecting an object
func objectEditingStarted(_name, _id):
	if globalEditor.objectBeingEdited == self:
		selectionParticles.emitting = true
	else:
		selectionParticles.emitting = false
func objectEditingStopped():
	selectionParticles.emitting = false
	
func setStartingStuff(instID, obj, loadedProperties:Dictionary):
	layer = rootNode.get_parent().get_parent()
	if obj == rootNode:
		instanceID = instID
		if loadedProperties:
			for i in loadedProperties:
				setProperty(i,loadedProperties[i])
	#print(globalEditor.level.rooms)
	rosterID = globalEditor.getCurrentLevelLayerDict()["objects"][instanceID]["rosterID"]
	signalBus.placeObjectSignal.disconnect(setStartingStuff)

func editModeStarted():
	#rootNode.process_mode = Node.PROCESS_MODE_DISABLED
	for property in properties:
		print("setting ",property.codeName," to ",getProperty(property.codeName))
		setProperty(property.codeName, getProperty(property.codeName), true)
#func playModeStarted():
	#pass

func getProperty(property:String):
	if getObjectFromLevelStruct()["properties"].has(property):
		return getObjectFromLevelStruct()["properties"][property]
	else:
		return rootNode.get(property)
func setProperty(property:String, value, tween = false):
	if property == "scale":
		value = abs(value)
	getObjectFromLevelStruct()["properties"][property] = value
	if tween:
		var propertyTween = create_tween()
		propertyTween.set_trans(Tween.TRANS_CUBIC)
		propertyTween.set_ease(Tween.EASE_OUT)
		propertyTween.tween_property(rootNode,property,value ,0.3)
	else:
		rootNode.set(property, value )

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		if globalEditor.isEditing or globalEditor.isObjectBeingEdited:
			summonPropertiesUI()
			signalBus.editingObject.emit(globalEditor.itemRoster[rosterID].name,instanceID)
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickLeft") and globalEditor.isEditing:
		if globalEditor.currentTool == globalEditor.Tools.erase:
			eraseSelf()

func summonPropertiesUI():
	populatePropertiesUI()

func populatePropertiesUI():
	signalBus.populatePropertiesUI.emit(self)

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
	globalEditor.getCurrentLevelLayerDict()["objects"].erase(instanceID)
	
func getObjectFromLevelStruct() -> Dictionary: 
	return globalEditor.getCurrentLevelRoomDict()["layers"][layer.index]["objects"][ instanceID ]
