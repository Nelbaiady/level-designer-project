extends Control
var hotbarTween:Tween

var wasEditing = true

func _ready() -> void:
	globalEditor.showPropertiesSidebar.connect(showSidebar)
#func _physics_process(_delta: float) -> void:
	#if globalEditor.isEditing and !wasEditing:
		#wasEditing = true
		#showSidebar()
#
	#elif !globalEditor.isEditing and wasEditing:
		#wasEditing = false
		#hideSidebar()

func showSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_OUT)
	hotbarTween.tween_property(self,"anchor_left",0.805,0.1)

func hideSidebar():
	hotbarTween = create_tween()
	hotbarTween.set_trans(Tween.TRANS_CUBIC)
	hotbarTween.set_ease(Tween.EASE_IN)
	hotbarTween.tween_property(self,"anchor_left",1,0.1)


func _on_close_button_pressed() -> void:
	hideSidebar()
