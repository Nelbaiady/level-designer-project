##generic script for anything that has editable properties
class_name ThingWithProperties extends Node

#@onready var selectionParticles: GPUParticles2D = $selectionParticles
const COLOR_PULSE = preload("uid://cbnkbef0ahxkp")

@export var clickCollision:Area2D ##collision for selecting this thing
##list of properties the thing has
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]
enum Categories {gizmo, npc, decoration}
@export var category: Categories
var rootNode:Node
var isBeingEdited = false
var isMouseOver:bool = false
var rosterID:int
var instanceID:int = -1
var layer:LevelLayer

##used to tween object properties
var propertyTween:Tween

func _ready() -> void:
	rootNode = get_parent()
	#keep searching up the hierarchy until you find the layer
	var ancestor = rootNode
	while ancestor:
		if ancestor is LevelLayer:
			layer = ancestor
			break
		ancestor = ancestor.get_parent()
	if !clickCollision:
		pass
	
	if globalEditor.isEditing:
		rootNode.process_mode=Node.PROCESS_MODE_DISABLED
		clickCollision.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		rootNode.process_mode=Node.PROCESS_MODE_INHERIT
		clickCollision.process_mode = Node.PROCESS_MODE_ALWAYS
	signalBus.startEditMode.connect(editModeStarted)
	signalBus.startPlayMode.connect(playModeStarted)


	if !clickCollision:
		printerr("Object ",rootNode.name, " instance number ", instanceID, " has no click collision")
	else:
		clickCollision.input_event.connect(clickedOn)
		clickCollision.mouse_entered.connect(mouseEntered)
		clickCollision.mouse_exited.connect(mouseExited)
		signalBus.editingObject.connect(objectEditingStarted)
		signalBus.hidePropertiesSidebar.connect(objectEditingStopped)

##effect when selecting an object
func objectEditingStarted(_name, id):
	if id == instanceID:
		rootNode.material = ShaderMaterial.new()
		rootNode.material.shader = COLOR_PULSE
		rootNode.material.set_shader_parameter("mode",1)
		rootNode.material.set_shader_parameter("cycle_speed",8)
		rootNode.material.set_shader_parameter("shine_color",Color(0.8, 0.9, 1.0, 0.7))
	else:
		objectEditingStopped()

func objectEditingStopped():
	rootNode.material = null

##sets an object's properties to the given values
func setStartingStuff(instID, obj, loadedProperties:Dictionary):
	signalBus.placeObjectSignal.disconnect(setStartingStuff)
	#layer = rootNode.get_parent().get_parent()
	if layer.index !=0:
		rootNode.process_mode=Node.PROCESS_MODE_DISABLED
	if obj == rootNode:
		instanceID = instID
		if loadedProperties:
			for i in loadedProperties:
				setProperty(i,loadedProperties[i])
	rosterID = globalEditor.getCurrentLevelLayerDict()["objects"][instanceID]["rosterID"]


func editModeStarted():
	for property in properties:
		setProperty(property.codeName, getProperty(property.codeName), true)
	#await propertyTween.finished
	rootNode.process_mode = Node.PROCESS_MODE_DISABLED
	clickCollision.process_mode = Node.PROCESS_MODE_ALWAYS
func playModeStarted():
	if layer.index == 0:
		rootNode.process_mode = Node.PROCESS_MODE_INHERIT
		clickCollision.process_mode = Node.PROCESS_MODE_DISABLED

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value, tween = false):
	if property == "scale":
		value = abs(value)
	if tween:
		propertyTween = create_tween()
		propertyTween.set_trans(Tween.TRANS_CUBIC)
		propertyTween.set_ease(Tween.EASE_OUT)
		propertyTween.parallel().tween_property(rootNode,property,value ,0.3)
	else:
		rootNode.set(property, value )

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		if globalEditor.isEditing or globalEditor.isObjectBeingEdited:
			
			signalBus.populatePropertiesUI.emit(self)
			signalBus.editingObject.emit(globalEditor.itemRoster[rosterID].name,instanceID)

func mouseEntered():
	isMouseOver = true
func mouseExited():
	isMouseOver = false

func setNotEditing():
	isBeingEdited = false
	signalBus.updateProperty.disconnect(setProperty)
