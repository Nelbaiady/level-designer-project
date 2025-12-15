extends Label

func _ready() -> void:
	signalBus.editingObject.connect(setText)

func setText(objName, _ins):
	text = objName
