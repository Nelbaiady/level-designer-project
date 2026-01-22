extends Node
var isBeingEdited:bool = false
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	,preload("uid://bts6u1j5o4xl8") #jump power
	,preload("uid://b15t6r3lo518i") #can Jump
	,preload("uid://7hr3aqaumfr2") #can Crouch
	,preload("uid://bethifqoxndpo") #can Crawl
	,preload("uid://do5ll6ym26tfy") #acceleration
	,preload("uid://cer7cfvecm4ww") #acceleration
	,preload("uid://d7aufjc2xj1h") #deceleration
	]
@onready var clickCollision: Area2D = $"../Area2D"
@onready var rootNode: CharacterBody2D = $".."

func _ready() -> void:
	clickCollision.input_event.connect(clickedOn)
	signalBus.startEditMode.connect(resetPlayer)
	signalBus.reloadPlayer.connect(loadPlayer)

func loadPlayer():
	for i in globalEditor.playerProperties:
		setProperty(i,globalEditor.playerProperties[i])
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
			populatePropertiesUI()
			signalBus.editingObject.emit("Player",-1)

func getProperty(property:String):
	return rootNode.get(property)

func setProperty(property:String, value):
	if property == "scale":
		value = abs(value)
	rootNode.set(property, value )
	globalEditor.playerProperties[property] = value

func populatePropertiesUI():
	signalBus.populatePropertiesUI.emit(self)
	
func setNotEditing():
	isBeingEdited = false
	signalBus.updateProperty.disconnect(setProperty)
