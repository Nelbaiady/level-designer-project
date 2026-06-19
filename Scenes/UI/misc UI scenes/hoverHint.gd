class_name HoverHint extends Control


@export var hintContainer: PanelContainer
@export var hintTexture: TextureRect
@export var hint_area_2d: Area2D

enum Directions {TL, T, TR, L, M, R, BL, B, BR}
@export var direction: Directions
@export var hint_margin_container: MarginContainer

@export var hintText: String ##optionally define the content of the hint as a simple string
@export var hintNode: Node ##optionally define the content of the hint as a node in the scene
@export var hintLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#hintTexture.mouse_entered.connect(showHint)
	#hintTexture.mouse_exited.connect(hideHint)
	hint_area_2d.area_entered.connect(checkHover.bind(true))
	hint_area_2d.area_exited.connect(checkHover.bind(false))
	
	custom_minimum_size = hintTexture.size
	
	updateText()

func updateText(newText=""):
	if newText:
		hintLabel.show()
		hintLabel.text = newText
	elif hintText: 
		hintLabel.show()
		hintLabel.text = hintText
	elif hintNode:
		hintLabel.hide()
		hintNode.reparent(hint_margin_container)
	elif get_child_count() > 2:
		get_child(2).reparent(hint_margin_container)
	setDirection()

func checkHover(area:Area2D, entered:=true):
	if area.is_in_group("cursor"):
		if entered: showHint()
		else: hideHint()
	
##sets the position and pivot point to a particular edge or corner
func setDirection(dir: Directions = direction):
	var preset: Control.LayoutPreset
	var pivotOffset := Vector2.ZERO
	match dir:
		Directions.TL:
			preset = Control.PRESET_BOTTOM_RIGHT
			pivotOffset = Vector2(hintContainer.size.x,hintContainer.size.y)
		Directions.T:
			preset = Control.PRESET_CENTER_BOTTOM
			pivotOffset = Vector2(hintContainer.size.x/2,hintContainer.size.y)
		Directions.TR:
			preset = Control.PRESET_BOTTOM_LEFT
			pivotOffset = Vector2(0,hintContainer.size.y)
		Directions.L:
			preset = Control.PRESET_CENTER_RIGHT
			pivotOffset = Vector2(hintContainer.size.x,hintContainer.size.y/2)
		Directions.M:
			preset = Control.PRESET_CENTER
			pivotOffset = Vector2(hintContainer.size.x/2,hintContainer.size.y/2)
		Directions.R:
			preset = Control.PRESET_CENTER_LEFT
			pivotOffset = Vector2(0,hintContainer.size.y/2)
		Directions.BL:
			preset = Control.PRESET_TOP_RIGHT
			pivotOffset = Vector2(hintContainer.size.x,0)
		Directions.B:
			preset = Control.PRESET_CENTER_TOP
			pivotOffset = Vector2(hintContainer.size.x/2,0)
		Directions.BR:
			preset = Control.PRESET_TOP_LEFT
			pivotOffset = Vector2(0,0)
	hintContainer.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_KEEP_SIZE,int(hintTexture.size.x*0.7))
	hintContainer.pivot_offset = pivotOffset


func showHint():
	setDirection()
	hintContainer.scale = Vector2.ZERO
	hintContainer.show()
	var sizeTween = create_tween()
	sizeTween.set_trans(Tween.TRANS_CUBIC)
	sizeTween.set_ease(Tween.EASE_IN_OUT)
	sizeTween.tween_property(hintContainer,"scale",Vector2.ONE,system.uiTweenTime/3)

	#hintContainer.size = hintContainerSize

func hideHint():
	#hintContainer.size = Vector2.ZERO
	var sizeTween = create_tween()
	sizeTween.set_trans(Tween.TRANS_CUBIC)
	sizeTween.set_ease(Tween.EASE_IN_OUT)
	sizeTween.tween_property(hintContainer,"scale",Vector2.ZERO,system.uiTweenTime/3)
	#hintContainer.hide()
