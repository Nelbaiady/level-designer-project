class_name PlayModeTopArea extends HBoxContainer

var hotbarTween:Tween

func _ready() -> void:
	signalBus.startEditMode.connect(hideHud)
	signalBus.startPlayMode.connect(showHud)

func hideHud():
		hotbarTween = create_tween()
		hotbarTween.set_trans(Tween.TRANS_CUBIC)
		hotbarTween.set_ease(Tween.EASE_IN)
		hotbarTween.tween_property(self,"offset_top",-size.y,0.15)
func showHud():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"offset_top",0,0.15)
