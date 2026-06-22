##selectee but for editor tools
extends Selectee

@export var tool:globalEditor.Tools

func _ready() -> void:
	signalBus.setCurrentTool.connect(updateToolSelection)
	get_tree().root.connect("size_changed", updateToolSelection)
	updateToolSelection.call_deferred()
	if has_signal("pressed"):
		connect("pressed", selectMe)

func selectMe():
	signalBus.setCurrentTool.emit(tool)

func updateToolSelection(newTool = globalEditor.currentTool):
	if newTool == tool:
		callSelector()
