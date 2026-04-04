class_name ControlMapping extends Node

var placeItemIcon : String
var moveCameraIcon : String
var moveCursorIcon : String
var selectToolIcon : String
var selectItemIcon : String
var editObjectIcon : String
var toggleGameModeIcon : String
var pauseIcon : String
const controllerFont = preload("uid://dldjup34y8kp1")
const keyboardFont = preload("uid://bp4pn6tp2pbqa")



var currentFont = keyboardFont


func _ready() -> void:
	setIcons()
	signalBus.updateControlIcons.connect(setIcons)

func setIcons():
	#controller icons
	if system.isUsingController:
		placeItemIcon = "E010"
		moveCameraIcon = "E05A"
		moveCursorIcon = "E062"
		selectToolIcon = "E035"
		selectItemIcon = "E03E"
		editObjectIcon = "E00A"
		toggleGameModeIcon = "E00C"
		pauseIcon = "E00E"
		currentFont = controllerFont
	#keyboard icons
	#[char=",controlMapping.moveCameraIcon,"]
	if !system.isUsingController:
		placeItemIcon = "E0E4"
		moveCameraIcon = "E0D7][char=E015][char=E0B9][char=E056"
		moveCursorIcon = "E0E5"
		selectToolIcon = "E0AF][char=E05A"
		selectItemIcon = "E0F0"
		editObjectIcon = "E0E8"
		toggleGameModeIcon = "E0C5"
		pauseIcon = "E062"
		currentFont = keyboardFont
	signalBus.controlIconsUpdated.emit.call_deferred()
