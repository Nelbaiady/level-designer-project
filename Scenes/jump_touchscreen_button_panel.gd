extends Panel

func _ready() -> void:
	hide()
	if system.isUsingTouchControls:
		signalBus.startEditMode.connect(hide)
		signalBus.startPlayMode.connect(show)
