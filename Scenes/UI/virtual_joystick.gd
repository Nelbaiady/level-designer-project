extends VirtualJoystick

func _ready() -> void:
	visible = system.isUsingTouchControls
		
	pressed.connect(stickIsActive)
	released.connect(stickIsInactive)

#func _process(delta: float) -> void:
	#print(Input.get_vector("LstickL","LstickR","LstickU","LstickD"))

func stickIsActive():
	signalBus.touchStickPressed.emit()

func stickIsInactive(_vector):
	signalBus.touchStickReleased.emit()
	
