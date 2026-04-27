class_name EditModeTopArea extends HBoxContainer
#var wasEditing = true
var hotbarTween:Tween

func _ready() -> void:
	signalBus.startEditMode.connect(showHud)
	signalBus.startPlayMode.connect(hideHud)

func showHud():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"offset_top",0,system.uiTweenTime/2)
func hideHud():
		hotbarTween = create_tween()
		hotbarTween.set_trans(Tween.TRANS_CUBIC)
		hotbarTween.set_ease(Tween.EASE_IN)
		hotbarTween.tween_property(self,"offset_top",-size.y,system.uiTweenTime/2)
