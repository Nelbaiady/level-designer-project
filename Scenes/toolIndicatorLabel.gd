extends Label


func _ready() -> void:
	updateToolDisplay(globalEditor.currentTool)
	signalBus.setCurrentTool.connect(updateToolDisplay)

func updateToolDisplay(newTool):
	text = globalEditor.Tools.find_key(newTool)
