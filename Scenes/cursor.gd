extends Node2D

var cursorMoveVector:Vector2 
var mousePosition:Vector2 
@export var cursorMoveSpeed: int = 10
var cursorOnScreen: bool = false
var prioritizeController:bool = false

@onready var itemIcon: TextureRect = $"../../cursorItemIcon"

#func _ready() -> void:
	#mousePosition = get_viewport().get_mouse_position()
	#position = get_viewport().get_mouse_position()
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#position = get_global_mouse_position()
func _process(_delta: float) -> void:
	
	if get_viewport().get_mouse_position() != mousePosition and !prioritizeController:
		#print(get_viewport().get_mouse_position(), "    ", mousePosition)
		position = get_global_mouse_position()
		mousePosition = get_viewport().get_mouse_position()
	else:
		cursorMoveVector = Vector2(Input.get_axis("left","right"),Input.get_axis("up","down"))
		#check if you went out of bounds on either axis
		position += cursorMoveVector * cursorMoveSpeed
		if cursorMoveVector:
			prioritizeController = true
		if prioritizeController:
			position.x = clamp(position.x, get_viewport().get_camera_2d().global_position.x - get_viewport_rect().size.x / 2,get_viewport().get_camera_2d().global_position.x + get_viewport_rect().size.x / 2)
			position.y = clamp(position.y, get_viewport().get_camera_2d().global_position.y - get_viewport_rect().size.y / 2,get_viewport().get_camera_2d().global_position.y + get_viewport_rect().size.y / 2)
			cursorOnScreen = true
			

func _notification(event):
	if event == NOTIFICATION_WM_MOUSE_ENTER:
		cursorOnScreen = true
		prioritizeController = false
	elif event == NOTIFICATION_WM_MOUSE_EXIT:
		cursorOnScreen = false
