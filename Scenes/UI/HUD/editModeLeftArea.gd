class_name EditModeLeftArea extends VBoxContainer
#var wasEditing = true
var hotbarTween:Tween

func _ready() -> void:
	signalBus.startEditMode.connect(showHud)
	signalBus.startPlayMode.connect(hideHud)

func showHud():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"offset_left",0,0.15)
func hideHud():
		hotbarTween = create_tween()
		hotbarTween.set_trans(Tween.TRANS_CUBIC)
		hotbarTween.set_ease(Tween.EASE_IN)
		hotbarTween.tween_property(self,"offset_left",-size.x-1200,0.15)
