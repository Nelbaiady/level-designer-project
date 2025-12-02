extends Node2D

@export var clickCollision:Area2D
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]
var propertyUiElements = []
enum categories {gizmo, npc, decoration}
@export var category: categories
var rootNode:Node 
var isBeingEdited = false


func _ready() -> void:
	rootNode= get_parent()
	if !clickCollision:
		printerr("Object ",rootNode.name," has no click collision")
	else:
		clickCollision.input_event.connect(clickedOn)

func _physics_process(_delta: float) -> void:
	#rootNode
	#if clickBox.
	#properties.set("position")
	#if Input.is_action_just_pressed("6"):
	pass

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value):
	rootNode.set(property,value)

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		summonPropertiesUI()

func summonPropertiesUI():
	populatePropertiesUI()

func populatePropertiesUI():
	globalEditor.showPropertiesSidebar.emit()
#	Empty the UI first
	for i in globalEditor.propertiesUI.get_children():
		i.queue_free()
	propertyUiElements.clear()
#	tell the editor to focus on this object
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = self
	isBeingEdited = true
#	populate the properties editor
	for i in properties:
		var newNode = i.uiNode.instantiate()
		propertyUiElements.append(newNode)
		globalEditor.propertiesUI.add_child(newNode)
		newNode.label.text = i.displayName
		newNode.propertyName = i.codeName
		#print(i.codeName, " ", getProperty(i.codeName))
		newNode.value = getProperty(i.codeName)
		newNode.updateValue()
	globalEditor.updateProperty.connect(setProperty)

func setNotEditing():
	isBeingEdited = false
	propertyUiElements.clear()
	globalEditor.updateProperty.disconnect(setProperty)
