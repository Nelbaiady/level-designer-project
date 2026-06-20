class_name CursorHint extends Control
enum Directions {TL, T, TR, L, M, R, BL, B, BR}
@export var label: Label
@export var hint_margin_container: MarginContainer
@export var hintContainer: PanelContainer

func _ready():
	signalBus.popupsOpened.connect(hideHint)
	
#func setHintText(newHintText=""):
	#if !newHintText: hide()
	#else:
		#show()
		##updateText(newHintText)

var sizeTween:Tween

func showHint():
	if !system.popupIsOpen:
		hintContainer.scale = Vector2.ZERO
		hintContainer.show()
		sizeTween = create_tween()
		sizeTween.set_trans(Tween.TRANS_CUBIC)
		sizeTween.set_ease(Tween.EASE_IN_OUT)
		sizeTween.tween_property(hintContainer,"scale",Vector2.ONE,system.uiTweenTime/3)

func hideHint():
	#hintContainer.size = Vector2.ZERO
	if sizeTween and sizeTween.is_running(): sizeTween.stop()
	sizeTween = create_tween()
	sizeTween.set_trans(Tween.TRANS_CUBIC)
	sizeTween.set_ease(Tween.EASE_IN_OUT)
	sizeTween.tween_property(hintContainer,"scale",Vector2.ZERO,system.uiTweenTime/3)
	#await sizeTween.finished
	#hintContainer.hide()
	
	
func setDirection(dir: Directions):
	#var preset: Control.LayoutPreset
	var pivotOffset := Vector2.ZERO
	match dir:
		Directions.TL:
			setPreset(Control.PRESET_BOTTOM_RIGHT)
			pivotOffset = Vector2(hintContainer.size.x,hintContainer.size.y)
		Directions.T:
			setPreset(Control.PRESET_CENTER_BOTTOM)
			pivotOffset = Vector2(hintContainer.size.x/2,hintContainer.size.y)
		Directions.TR:
			setPreset(Control.PRESET_BOTTOM_LEFT)
			pivotOffset = Vector2(0,hintContainer.size.y)
		Directions.L:
			setPreset(Control.PRESET_CENTER_RIGHT)
			pivotOffset = Vector2(hintContainer.size.x,hintContainer.size.y/2)
		Directions.M:
			setPreset(Control.PRESET_CENTER)
			pivotOffset = Vector2(hintContainer.size.x/2,hintContainer.size.y/2)
		Directions.R:
			setPreset(Control.PRESET_CENTER_LEFT)
			pivotOffset = Vector2(0,hintContainer.size.y/2)
		Directions.BL:
			setPreset(Control.PRESET_TOP_RIGHT)
			pivotOffset = Vector2(hintContainer.size.x,0)
		Directions.B:
			setPreset(Control.PRESET_CENTER_TOP)
			pivotOffset = Vector2(hintContainer.size.x/2,0)
		Directions.BR:
			setPreset(Control.PRESET_TOP_LEFT)
			pivotOffset = Vector2(0,0)
	hintContainer.pivot_offset = pivotOffset

func setPreset(preset:Control.LayoutPreset):
	hintContainer.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_MINSIZE,28)
#func setPivot(pivot):
	#hintContainer.pivot_offset = pivotOffset
