extends Node
var isBeingEdited:bool = false
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	]
@onready var clickCollision: Area2D = $"../Area2D"
@onready var rootNode: CharacterBody2D = $".."

func _ready() -> void:
	clickCollision.input_event.connect(clickedOn)
	signalBus.startEditMode.connect(resetPlayer)

func resetPlayer():
	rootNode.velocity = Vector2.ZERO
	rootNode.animationPlayer.current_animation="idle"
	for i in globalEditor.playerProperties:
		var value = globalEditor.playerProperties[i] 
		var resetPlayerTween = create_tween()
		resetPlayerTween.set_trans(Tween.TRANS_CUBIC)
		resetPlayerTween.set_ease(Tween.EASE_OUT)
		resetPlayerTween.tween_property(rootNode,i,value ,0.3)

func clickedOn(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_action_pressed("mouseClickRight"):
		if globalEditor.isEditing or globalEditor.isObjectBeingEdited:
			summonPropertiesUI()
			signalBus.editingObject.emit("Player",-1)

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value):
	if property == "scale":
		value = abs(value)
	rootNode.set(property, value )
	globalEditor.playerProperties[property] = value

func summonPropertiesUI():
	populatePropertiesUI()

func populatePropertiesUI():
	signalBus.showPropertiesSidebar.emit()
#	Empty the UI first
	for i in globalEditor.propertiesUI.get_children():
		i.queue_free()
#	tell the editor to focus on this object
	if globalEditor.objectBeingEdited:
		globalEditor.objectBeingEdited.setNotEditing()
	globalEditor.objectBeingEdited = self
	isBeingEdited = true
#	populate the properties editor
	for i in properties:
		var newNode = i.uiNode.instantiate()
		globalEditor.propertiesUI.add_child(newNode)
		newNode.label.text = i.displayName
		newNode.propertyName = i.codeName
		newNode.value = getProperty(i.codeName)
		newNode.updateValue()
	if !signalBus.updateProperty.is_connected(setProperty):
		signalBus.updateProperty.connect(setProperty)
func setNotEditing():
	isBeingEdited = false
	signalBus.updateProperty.disconnect(setProperty)
