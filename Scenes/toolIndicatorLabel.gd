extends Label


func _ready() -> void:
	updateToolDisplay(globalEditor.currentTool)
	signalBus.setCurrentTool.connect(updateToolDisplay)

func updateToolDisplay(newTool):
	print("swithed tool to ",newTool)
	text = globalEditor.Tools.find_key(newTool)
