extends Node2D

var cursorMoveVector:Vector2 
var mousePosition:Vector2 
@export var cursorMoveSpeed: int = 10
var mouseOnScreen: bool = false
var cursorOnScreen: bool = false
var prioritizeController:bool = false

#@onready var itemIcon: TextureRect = $"../../cursorItemIcon"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	#mousePosition = get_viewport().get_mouse_position()
	#position = get_viewport().get_mouse_position()
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#position = get_global_mouse_position()
func _process(_delta: float) -> void:
	if globalEditor.isEditing:
		cursorMoveVector = Vector2(Input.get_axis("left","right"),Input.get_axis("up","down"))
		if (get_viewport().get_mouse_position() != mousePosition) and mouseOnScreen:
			prioritizeController = false
		if cursorMoveVector:
			prioritizeController = true
			cursorOnScreen = true
		if prioritizeController:
			#check if you went out of bounds on either axis
			position += cursorMoveVector * cursorMoveSpeed
			if prioritizeController:
				position.x = clamp(position.x, get_viewport().get_camera_2d().global_position.x - get_viewport_rect().size.x / 2,get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x / 2)
				position.y = clamp(position.y, get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2,get_viewport().get_camera_2d().global_position.y + get_viewport_rect().size.y / 2)
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
