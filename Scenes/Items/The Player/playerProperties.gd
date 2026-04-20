class_name PlayerProperties extends Node

#@onready var selectionParticles: GPUParticles2D = $selectionParticles
const COLOR_PULSE = preload("uid://cbnkbef0ahxkp")
@onready var clickCollision: Area2D = $"../clickBoxArea"
@onready var rootNode: Player = $".."
@export var properties: Array[ObjectProperty] = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	,preload("uid://bts6u1j5o4xl8") #jump power
	,preload("uid://hjumgb2dqxve") #max jumps
	,preload("uid://cf7n3dro2vyxa") #coyote time
	,preload("uid://7hr3aqaumfr2") #can Crouch
	,preload("uid://utkx0vgp3gc5") #can Chourc
	,preload("uid://bethifqoxndpo") #can Crawl
	,preload("uid://do5ll6ym26tfy") #acceleration
	,preload("uid://bt3t4oe46o4a8") #top running speed
	,preload("uid://d3y2ia0lj7kk5") #max health
	
	#,preload("uid://d3y2ia0lj7kk5") #maxHealth
	]
var isBeingEdited:bool = false

func _ready() -> void:
	clickCollision.input_event.connect(clickedOn)
	signalBus.startEditMode.connect(resetPlayer)
	signalBus.reloadPlayer.connect(loadPlayer)
	signalBus.editingObject.connect(objectEditingStarted)
	signalBus.hidePropertiesSidebar.connect(objectEditingStopped)



##outline when selecting an object
func objectEditingStarted(_name, _id):
	if globalEditor.objectBeingEdited == self:
		rootNode.material = ShaderMaterial.new()
		rootNode.material.shader = COLOR_PULSE
		rootNode.material.set_shader_parameter("mode",1)
		rootNode.material.set_shader_parameter("cycle_speed",8)
		rootNode.material.set_shader_parameter("shine_color",Color(0.8, 0.9, 1.0, 0.7))
	else:
		objectEditingStopped()
func objectEditingStopped():
	rootNode.material = null

func loadPlayer():
	for i in globalEditor.playerProperties:
		setProperty(i,globalEditor.playerProperties[i])
func resetPlayer():
	rootNode.velocity = Vector2.ZERO
	rootNode.animationPlayer.current_animation="idle"
	
	var resetPlayerTween = create_tween()
	resetPlayerTween.set_trans(Tween.TRANS_CUBIC)
	resetPlayerTween.set_ease(Tween.EASE_OUT)
	resetPlayerTween.parallel().tween_property(rootNode.sprite,"position",Vector2(0,44),0.3)
	for i in globalEditor.playerProperties:
		var value = globalEditor.playerProperties[i] 
		resetPlayerTween.parallel().tween_property(rootNode,i,value ,0.3)

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
