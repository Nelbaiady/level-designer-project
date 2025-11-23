extends Node2D

var cursorMoveVector:Vector2 
var mousePosition:Vector2 
@export var cursorMoveSpeed: int = 13
var mouseOnScreen: bool = false
var cursorOnScreen: bool = false
var prioritizeController:bool = false

#@onready var itemIcon: TextureRect = $"../../cursorItemIcon"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass
	
func _process(_delta: float) -> void:
	if globalEditor.popupIsOpen:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if globalEditor.isEditing:
		#To make UI block controller input, we make the controller trigger a real mouse click
		if Input.is_action_pressed("controllerClickLeft"):
			click()
		#Left stick input vector
		cursorMoveVector = Vector2(Input.get_axis("LstickL","LstickR"),Input.get_axis("LstickU","LstickD"))
		#If the mouse moved and is on screen, use mouse controls
		if (get_viewport().get_mouse_position() != mousePosition) and mouseOnScreen:
			prioritizeController = false
		#If the mouse isnt making any movement in the game window and the left stick is moved in any direction, 
		#use controller to move the cursor
		if cursorMoveVector:
			prioritizeController = true
			cursorOnScreen = true
		#code for moving the cursor with controlls
		if prioritizeController:
			position += cursorMoveVector * cursorMoveSpeed
			#Make sure the cursor does not go off screen
			position.x = clamp(position.x, get_viewport().get_camera_2d().global_position.x - get_viewport_rect().size.x / 2,get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x / 2 - 1)#-1 on the max of both clamps because the mouse otherwise goes off screen
			position.y = clamp(position.y, get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2,get_viewport().get_camera_2d().global_position.y + get_viewport_rect().size.y / 2 - 1)
			#Move the mouse itself too if it's inside the game window
			if mouseOnScreen:
				get_viewport().warp_mouse(get_viewport().canvas_transform * global_position)
		else:
			position = get_global_mouse_position()
			mousePosition = get_viewport().get_mouse_position()
	visible = cursorOnScreen and globalEditor.isEditing
func _notification(event):
	#mouse enters the window
	if event == NOTIFICATION_WM_MOUSE_ENTER:
		mouseOnScreen = true
		cursorOnScreen = true
		prioritizeController = false
	#mouse exits the window
	elif event == NOTIFICATION_WM_MOUSE_EXIT:
		mouseOnScreen = false
		cursorOnScreen = false
		prioritizeController = true

# REFERENEC: https://forum.godotengine.org/t/how-can-i-simulate-a-mouse-click-with-controller-inputs/1644
func click():
	var clickEvent = InputEventMouseButton.new()
	#clickEvent.position = get_global_mouse_position()
	clickEvent.position = position
	clickEvent.button_index = MOUSE_BUTTON_LEFT
	clickEvent.pressed = true
	Input.parse_input_event(clickEvent)
	await get_tree().process_frame
	clickEvent.pressed = false
	Input.parse_input_event(clickEvent)
