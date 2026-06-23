class_name Selector extends Control

@export var offset:Vector2
func _ready():
	if offset: offset_transform_position = offset
	#offset_transform_position = Vector2(3,4)

##when instructed to, this selector will go to the given location
func goToPosition(newPos:Vector2):
	system.basicTween(self,"position",newPos,system.uiTweenTime/2,Tween.EaseType.EASE_OUT)

var timePassed = 0
var nextScaleOffset
func _physics_process(delta: float):
	timePassed+=delta
	nextScaleOffset = 1+abs(sin(timePassed*5))/12 
	offset_transform_scale = Vector2(nextScaleOffset,nextScaleOffset)
