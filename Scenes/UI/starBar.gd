class_name StarBar extends Control

@export_category("parameters")
@export var starBarLabelText:String
@export var isEditable:bool = true

@export_category("nodes")
@export var slider:HSlider
@export var starLine:Line2D
@export var ztarLine:Line2D
@export var starBarLabel:Label

var defaultStarColor
var lineStart
var lineEnd
var lineLength
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider.editable = isEditable
	starBarLabel.text = starBarLabelText
	lineStart = starLine.points[0]
	lineEnd = starLine.points[1]
	lineLength = (lineEnd-lineStart).length()
	defaultStarColor = starLine.default_color
func _on_slider_value_changed(value: float) -> void:
	setStarBarValue(value)
func setStarBarValue(value):
	var valuePosition = lineStart + Vector2.RIGHT*lineLength/10*value
	var starTween = create_tween()
	starTween.set_trans(Tween.TRANS_CUBIC)
	starTween.set_ease(Tween.EASE_IN_OUT)
	starTween.tween_property(starLine,"points", PackedVector2Array([lineStart, valuePosition]), system.uiTweenTime/3)
	starTween.parallel().tween_property(ztarLine,"points", PackedVector2Array([lineEnd, valuePosition]) ,system.uiTweenTime/2)

func _on_slider_mouse_entered() -> void:
	if isEditable: starLine.default_color = Color(0xf1e2b0ff)

func _on_slider_mouse_exited() -> void:
	starLine.default_color = defaultStarColor
