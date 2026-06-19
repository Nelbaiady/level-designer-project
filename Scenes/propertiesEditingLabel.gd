extends Label
#@export var hover_hint: HoverHint

func _ready() -> void:
	signalBus.editingObject.connect(setText)
	#signalBus.setThingDescription.connect(setHintText)

func setText(objName, _ins):
	text = objName

#func setHintText(hintText=""):
	#if !hintText: hover_hint.hide()
	#else:
		#hover_hint.show()
		#hover_hint.updateText(hintText)
