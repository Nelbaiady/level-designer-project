class_name StarBar extends Control

@export var slider:HSlider
@export var starLine:Line2D
@export var ztarLine:Line2D

var defaultStarColor
var lineStart
var lineEnd
var lineLength
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lineStart = starLine.points[0]
	lineEnd = starLine.points[1]
	lineLength = (lineEnd-lineStart).length()
	defaultStarColor = starLine.default_color
func _on_slider_value_changed(value: float) -> void:
	print(value)
	starLine.points[1] = lineStart + Vector2.RIGHT*lineLength/10*value
	ztarLine.points[1] = lineStart + Vector2.RIGHT*lineLength/10*value


func _on_slider_mouse_entered() -> void:
	starLine.default_color = Color(0xf1e2b0ff)

func _on_slider_mouse_exited() -> void:
	starLine.default_color = defaultStarColor
