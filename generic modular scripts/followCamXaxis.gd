##This script can be added to anything that is meant to cover the entire screen width, but wont follow the camera vertically
class_name FollowCamXaxis extends TextureRect

func _ready():
	get_tree().root.size_changed.connect(updateSize)
	#signalBus.cameraTransformUpdate.connect(updatePosition)
	updateSize()
	updatePosition()
	
func updateSize():
	size.x = get_viewport_rect().size.x+2
	
func _process(_delta: float) -> void:
	updatePosition()
	
func updatePosition():
	position.x = (-get_viewport().canvas_transform.origin).x-1
