extends Control
var hotbarTween:Tween

var wasEditing = true

func _physics_process(_delta: float) -> void:
	if globalEditor.isEditing and !wasEditing:
		wasEditing = true
		showSidebar()

	elif !globalEditor.isEditing and wasEditing:
		wasEditing = false
		hideSidebar()

func showSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"offset_left",0,0.1)

func hideSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_IN)
	hotbarTween.tween_property(self,"offset_left",size.x,0.1)
