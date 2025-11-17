extends Panel
var wasEditing = true
var hotbarTween:Tween

func _physics_process(_delta: float) -> void:
	if globalEditor.isEditing and !wasEditing:
		wasEditing = true
		#offset_top = 0
		hotbarTween = create_tween()
		hotbarTween.set_trans(Tween.TRANS_CUBIC)
		hotbarTween.set_ease(Tween.EASE_OUT)
		hotbarTween.tween_property(self,"offset_top",0,0.1)
	elif !globalEditor.isEditing and wasEditing:
		wasEditing = false
		#offset_top = -size.y
		hotbarTween = create_tween()
		hotbarTween.set_trans(Tween.TRANS_CUBIC)
		hotbarTween.set_ease(Tween.EASE_IN)
		hotbarTween.tween_property(self,"offset_top",-size.y,0.1)
		print("not editing rn")
