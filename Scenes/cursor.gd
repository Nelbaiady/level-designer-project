extends Node2D

var cursorMoveVector:Vector2 
var mousePosition:Vector2 
@export var cursorMoveSpeed: int = 10
@export var cursorMoveSpeedMult: float = 1
var mouseOnScreen: bool = false
var cursorOnScreen: bool = false
var prioritizeController:bool = false
#var popupWasOpen: bool = false #unused
var isSpinBoxing: bool = false
#@onready var itemIcon: TextureRect = $"../../cursorItemIcon"
@onready var cursor_item_icon: TextureRect = $"../../cursorItemIcon"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	signalBus.spinboxSpun.connect( spinBoxing )
	
func _process(_delta: float) -> void:
	if globalEditor.isEditing or globalEditor.isObjectBeingEdited:
		#To make UI block controller input, we make the controller trigger a real mouse click
		if Input.is_action_just_pressed("controllerClickLeft"):
			click()
		if Input.is_action_just_released("controllerClickLeft"):
			unClick()
		if Input.is_action_just_pressed("controllerClickRight"):
			rightClick()
		if Input.is_action_just_released("controllerClickRight"):
			unRightClick()
		#Left stick input vector
		cursorMoveVector = Vector2(Input.get_vector("rLeft","rRight","rUp","rDown"))
		#If the mouse moved and is on screen, use mouse controls
		if (get_viewport().get_mouse_position() != mousePosition) and mouseOnScreen:
			prioritizeController = false
		#If the mouse isnt making any movement in the game window and the left stick is moved in any direction, 
		#use controller to move the cursor
		if cursorMoveVector:
			prioritizeController = true
			cursorOnScreen = true
		#code for moving the cursor with controllers
		if prioritizeController:
			cursorMoveSpeedMult = 1-Input.get_action_strength("L2") + 0.1
			position = get_global_mouse_position() + cursorMoveVector * cursorMoveSpeed * cursorMoveSpeedMult
			#Make sure the cursor does not go off screen
			position.x = clamp(position.x, get_viewport().get_camera_2d().global_position.x - get_viewport_rect().size.x / 2,get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x / 2 - 1)#-1 on the max of both clamps because the mouse otherwise goes off screen
			position.y = clamp(position.y, get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2,get_viewport().get_camera_2d().global_position.y + get_viewport_rect().size.y / 2 - 1)
			#Move the mouse itself too if it's inside the game window
			if mouseOnScreen:
				get_viewport().warp_mouse(get_viewport().canvas_transform * global_position)
		else:
			position = get_global_mouse_position()
			mousePosition = get_viewport().get_mouse_position()
	visible = cursorOnScreen and (globalEditor.isEditing or globalEditor.isObjectBeingEdited) and !isSpinBoxing

func _notification(event):
	#mouse enters the window
	if event == NOTIFICATION_WM_MOUSE_ENTER:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		mouseOnScreen = true
		cursorOnScreen = true
		prioritizeController = false
	#mouse exits the window
	elif event == NOTIFICATION_WM_MOUSE_EXIT:
		mouseOnScreen = false
		cursorOnScreen = false
		prioritizeController = true

# REFERENCE: https://forum.godotengine.org/t/how-can-i-simulate-a-mouse-click-with-controller-inputs/1644
func click():
	var clickEvent = InputEventMouseButton.new()
	clickEvent.position = get_viewport().canvas_transform * global_position
	#clickEvent.position = position
	clickEvent.button_index = MOUSE_BUTTON_LEFT
	clickEvent.pressed = true
	#get_viewport().push_input(clickEvent)
	Input.parse_input_event(clickEvent)
	#await get_tree().process_frame
	#clickEvent.pressed = true
	#Input.parse_input_event(clickEvent)
func unClick():
	var clickEvent = InputEventMouseButton.new()
	clickEvent.position = get_viewport().canvas_transform * global_position
	#clickEvent.position = position
	clickEvent.button_index = MOUSE_BUTTON_LEFT
	clickEvent.pressed = false
	#get_viewport().push_input(clickEvent)
	Input.parse_input_event(clickEvent)
	
func rightClick():
	var clickEvent = InputEventMouseButton.new()
	clickEvent.position = get_viewport().canvas_transform * global_position
	clickEvent.button_index = MOUSE_BUTTON_RIGHT
	clickEvent.pressed = true
	Input.parse_input_event(clickEvent)
func unRightClick():
	var clickEvent = InputEventMouseButton.new()
	clickEvent.position = get_viewport().canvas_transform * global_position
	clickEvent.button_index = MOUSE_BUTTON_RIGHT
	clickEvent.pressed = false
	Input.parse_input_event(clickEvent)

func spinBoxing():
	if Input.is_action_pressed("mouseClickLeft"):
		isSpinBoxing = true
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("mouseClickLeft"):
		if isSpinBoxing:
			isSpinBoxing = false
