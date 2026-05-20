class_name PlayerProperties extends ThingWithProperties

func _ready() -> void:
	properties = [
	preload("uid://bh2hcytk84e13") #position
	,preload("uid://dqbrp3ghialya") #size/scale
	,preload("uid://byn3kv4q02kpl") #color/modulate
	,preload("uid://bts6u1j5o4xl8") #jump power
	,preload("uid://hjumgb2dqxve") #max jumps
	,preload("uid://cf7n3dro2vyxa") #coyote time
	,preload("uid://dx4l3tqek45ja") #jump buffer
	,preload("uid://7hr3aqaumfr2") #can Crouch
	,preload("uid://utkx0vgp3gc5") #can Chourc
	#,preload("uid://bethifqoxndpo") #can Crawl
	,preload("uid://do5ll6ym26tfy") #acceleration
	,preload("uid://bt3t4oe46o4a8") #top running speed
	,preload("uid://d3y2ia0lj7kk5") #max health
	]
	
	signalBus.reloadPlayer.connect(loadPlayerProperties)
	clickCollision = $"../clickBoxArea"
	super()
	
	clickCollision.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_INHERIT
	
##sets the player's properties to the ones in globalEditor
func loadPlayerProperties():
	for i in globalEditor.playerProperties:
		setProperty(i,globalEditor.playerProperties[i])

func editModeStarted():
	resetPlayer()
	clickCollision.process_mode = Node.PROCESS_MODE_ALWAYS

func setProperty(property:String, value, _tween:=false):
	if property == "scale":
		value = abs(value)
	rootNode.set(property, value )
	globalEditor.playerProperties[property] = value

func resetPlayer():
	rootNode.velocity = Vector2.ZERO
	rootNode.animationPlayer.current_animation="idle"
	
	var resetPlayerTween = create_tween()
	resetPlayerTween.set_trans(Tween.TRANS_CUBIC)
	resetPlayerTween.set_ease(Tween.EASE_OUT)
	resetPlayerTween.parallel().tween_property(rootNode.sprite,"position",Vector2(0,44),system.uiTweenTime)

	for i in globalEditor.playerProperties:
		var value = globalEditor.playerProperties[i] 
		resetPlayerTween.parallel().tween_property(rootNode,i,value, system.uiTweenTime)
