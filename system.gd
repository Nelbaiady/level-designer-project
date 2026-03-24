class_name System extends Node

var fullscreen := false
var wasMaximized := false ##remembers if the window was maximized when it goes to fullscreen so it can go back if the user turns fullscreen back off

var isPaused := false

var isWebVersion:=OS.has_feature("web")

func _ready() -> void:
	signalBus.togglePause.connect(togglePause)

func togglePause():
	isPaused = !isPaused
	signalBus.pauseToggled.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
			wasMaximized = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			if wasMaximized:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("pause"):
		if globalEditor.isEditing: #temporary condition until we figure out a pause menu for gameplay
			togglePause()
