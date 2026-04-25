class_name RoomManager extends ThingWithProperties

@export var bottomTexture: TextureRect
@export var skyTexture:TextureRect
@export var roomBottomIndicator: TextureRect

@onready var skyGradient:Gradient = skyTexture.texture.gradient
	

func _ready() -> void:
	properties = [
	#preload("uid://byn3kv4q02kpl") #color/modulate
	preload("uid://mbfludt3gdah") #bottom
	,preload("uid://dy8ne4mwwjsur") #color1
	,preload("uid://m0mno6q11rr8") #color2
	]
	super()
	
	#signalBus.startPlayMode.connect(func(): roomBottomIndicator.visible = false)
	#signalBus.startEditMode.connect(func(): roomBottomIndicator.visible = true)

func getProperty(property:String):
	#if property == "roomBottom":
		#return rootNode
	if property == "bgColor1":
		return skyGradient.colors[1]
	if property == "bgColor2":
		return skyGradient.colors[0]
	return rootNode.get(property)
#
func setProperty(property:String, value, tween = false):
	if property == "roomBottom":
		set("position",Vector2(get("position").x,value))
	if property == "bgColor1":
		skyGradient.colors[1] = value
	if property == "bgColor2":
		skyGradient.colors[0] = value
		
	super(property,value,tween)
	#if property == "scale":
		#value = abs(value)
	#if tween:
		#propertyTween = create_tween()
		#propertyTween.set_trans(Tween.TRANS_CUBIC)
		#propertyTween.set_ease(Tween.EASE_OUT)
		#propertyTween.parallel().tween_property(rootNode,property,value ,0.3)
	#else:
		#rootNode.set(property, value )
		
func editModeStarted():
	pass #do nothing
func playModeStarted():
	pass #do nothing
